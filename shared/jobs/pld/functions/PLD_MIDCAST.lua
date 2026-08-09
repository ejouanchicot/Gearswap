---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Paladin with specialized Cure and enmity optimization.
---
---   Features:
---   - Cure III/IV: Dynamic CureSelf/CureOther via CureSetBuilder
---   - Enmity spells: Flash, Enlight
---   - Phalanx: XP mode (SIRD vs Potency)
---   - Enhancing Magic: Database-driven spell_family routing
---   - Divine Magic, Blue Magic support (PLD/BLU subjob)
---
---   @file    PLD_MIDCAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-03 | Updated: 2025-11-05
---   @requires shared/jobs/pld/functions/logic/cure_set_builder
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local CureSetBuilder = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    MidcastManager = mm
    local _, csb = pcall(require, 'shared/jobs/pld/functions/logic/cure_set_builder')
    CureSetBuilder = csb

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

---   Pre-midcast hook (Cure III/IV dynamic target-based set selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first midcast
    ensure_modules_loaded()

    -- ══════════════════════════════════════════════════════════════════════════
    -- CURE III/IV: DYNAMIC TARGET-BASED SETS (CureSetBuilder)
    -- ══════════════════════════════════════════════════════════════════════════
    -- These spells use CureSetBuilder logic module for optimal gear selection
    -- Must be handled in job_midcast BEFORE MidcastManager
    if spell.name == 'Cure III' or spell.name == 'Cure IV' then
        local target_type = spell.target.type == 'SELF' and 'SELF' or 'OTHER'
        local cure_set = CureSetBuilder.generate(spell, target_type)
        if cure_set then
            equip(cure_set)
        end
        eventArgs.handled = true
        return
    end
end

--- Cures pick their set by who is being healed: PLD's own cure gear is not
--- what it wants when topping someone else up.
local function midcast_healing(spell)
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell,
        target_func = function(sp)
            return sp.target.type == 'SELF' and 'Self' or 'Other'
        end
    })
end

--- Flash has its own set: it is cast for enmity, not for the blind.
local function midcast_flash(spell)
    MidcastManager.select_set({
        skill = 'Flash',
        spell = spell
    })
end

--- Enlight is enmity gear too, under its own skill name.
local function midcast_enlight(spell)
    MidcastManager.select_set({
        skill = 'Enmity',
        spell = spell
    })
end

--- Phalanx, which has a set of its own and a mode that overrides it.
---
--- With PhalanxSIRD or Xp on, the SIRD set wins outright: the point is to not
--- lose the cast to a hit, and potency is worth nothing if it is interrupted.
local function midcast_phalanx(spell)
    local use_sird = (state.PhalanxSIRD and state.PhalanxSIRD.value == 'On')
        or (state.Xp and state.Xp.value == 'On')

    if use_sird and sets.midcast.SIRDPhalanx then
        equip(sets.midcast.SIRDPhalanx)
        return
    end

    MidcastManager.select_set({
        skill = 'Phalanx',
        spell = spell
    })
end

--- Everything else under Enhancing, routed by spell family.
local function midcast_enhancing(spell)
    if spell.name == 'Phalanx' then
        midcast_phalanx(spell)
        return
    end

    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target,
        database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    })
end

local function midcast_divine(spell)
    MidcastManager.select_set({
        skill = 'Divine Magic',
        spell = spell
    })
end

--- Blue Magic from a /BLU subjob. Cocoon is a self-buff and wants defence
--- gear; the rest are offensive and do not.
local function midcast_blue(spell)
    MidcastManager.select_set({
        skill = (spell.name == 'Cocoon') and 'Cocoon' or 'Blue Magic',
        spell = spell
    })
end

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Cure III and IV are already dressed by job_midcast above.
    if eventArgs.handled then
        return
    end

    -- Name before skill: Flash and Enlight are Divine spells that want enmity
    -- gear rather than the Divine set, so they have to be caught first.
    if spell.skill == 'Healing Magic' then
        midcast_healing(spell)
    elseif spell.name == 'Flash' then
        midcast_flash(spell)
    elseif spell.name == 'Enlight' or spell.name == 'Enlight II' then
        midcast_enlight(spell)
    elseif spell.skill == 'Enhancing Magic' then
        midcast_enhancing(spell)
    elseif spell.skill == 'Divine Magic' then
        midcast_divine(spell)
    elseif spell.skill == 'Blue Magic' then
        midcast_blue(spell)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}

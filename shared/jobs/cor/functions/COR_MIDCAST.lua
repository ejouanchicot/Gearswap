---  ═══════════════════════════════════════════════════════════════════════════
---   COR Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Corsair including Ranged Attack and subjob spells.
---
---   Features:
---   - Ranged Attack: Bullet flight time gear
---   - Healing Magic: Cure spells (from subjob)
---   - Enhancing Magic: Buff spells (from subjob)
---   - Elemental Magic: Nuking (if COR/RDM or COR/BLM)
---
---   Important Notes:
---   - Phantom Rolls/Quick Draw are instantaneous (PRECAST only, no midcast)
---
---   @file    COR_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.1 - Added spell_family database support
---   @date    Created: 2025-10-07 | Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    MidcastManager = mm

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    modules_loaded = true
end

---   Pre-midcast hook (job-specific logic before set selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- No COR-specific PRE-midcast logic
end

-- Skills COR routes straight through under their own name. Everything COR can
-- cast comes from a subjob, so the set is named after the skill and there is
-- nothing job-specific to add.
local PASSTHROUGH_SKILLS = {
    ['Healing Magic'] = true,
    ['Elemental Magic'] = true,
    ['Enfeebling Magic'] = true,
}

---   Post-midcast hook
---   @param spell table Spell information from GearSwap
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments
function job_post_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Ranged attacks are matched on type, not skill, and want the RA set:
    -- the gear that matters is snapshot while the bullet is in flight.
    if spell.type == 'Ranged Attack' then
        MidcastManager.select_set({skill = 'RA', spell = spell})
        return
    end

    -- Enhancing is the one that needs more than its name: which set wins
    -- depends on the spell family and on whether it is going on yourself.
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end

    if PASSTHROUGH_SKILLS[spell.skill] then
        MidcastManager.select_set({skill = spell.skill, spell = spell})
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


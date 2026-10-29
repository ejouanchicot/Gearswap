---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for White Mage with comprehensive spell-specific sets.
---
---   Features:
---   - Cure: CureMode (Potency vs SIRD), Afflatus Solace, CureMelee
---   - Curaga: CureMode support
---   - Status Removal: Cursna, Paralyna, Erase (+ Divine Caress)
---   - Enhancing Magic: Database-driven spell_family routing (Regen, Refresh, BarElement, etc.)
---   - Divine Magic: Banish, Holy, Repose
---   - Enfeebling Magic: MND-based vs INT-based
---
---   @file    shared/jobs/whm/functions/WHM_MIDCAST.lua
---   @author  ejouanchicot
---   @version 3.0 - Added spell_family database support
---   @date    Created: 2025-10-21 | Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastDeps = require('shared/utils/midcast/midcast_deps')

-- Filled in by the first midcast; the handlers below read them from here.
local MidcastManager = nil
local EnhancingSPELLS = nil

-- Divine Caress works with the -na spells only: not Erase, Esuna nor Sacrifice (BG Wiki Divine Caress)
local NOT_CARESSED = {['Erase'] = true, ['Esuna'] = true, ['Sacrifice'] = true}

--- Whether Divine Caress acts on this status removal: the buff is up and the spell is a -na.
--- @param spell table Spell information from GearSwap
--- @return boolean
local function caress_applies(spell)
    return buffactive['Divine Caress'] and spell and not NOT_CARESSED[spell.english] or false
end

--- The version of a spell's own set for an ability that changes that spell, named by the spell:
--- sets.midcast[<spell>][version], then [<spell without its tier>], then [group] (Banish.Misery for
--- Banish II, StatusRemoval.Caress for Paralyna, BarElement.Solace for Barfire).
--- @param spell table Spell information from GearSwap
--- @param group string The spell's group set (StatusRemoval, BarElement, Banish)
--- @param version string Solace, Caress, Misery
--- @return table|nil nil when no such version exists (the spell's set stays)
local function version_of(spell, group, version)
    for _, key in ipairs({spell.english, (spell.english:gsub(' [IVX]+$', '')), group}) do
        local set = sets.midcast[key]
        if type(set) == 'table' and type(set[version]) == 'table' then return set[version] end
    end
    return nil
end

--- Equip that version when there is one.
local function wear_version(spell, group, version)
    local set = version_of(spell, group, version)
    if set then equip(set) end
end

---   Pre-midcast hook (CureMode SIRD/Potency selection for Cure and Curaga)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_midcast(spell, action, spellMap, eventArgs)
    -- ══════════════════════════════════════════════════════════════════════════
    -- HEALING MAGIC - CURE/CURAGA (CureMode SIRD logic)
    -- ══════════════════════════════════════════════════════════════════════════
    -- Handle CureMode (Potency vs SIRD) BEFORE MidcastManager
    -- This ensures correct set selection based on state

    if spellMap == 'Cure' or spellMap == 'Curaga' then
        if state.CureMode and state.CureMode.current == 'SIRD' then
            -- SIRD mode: use interrupt-resistant gear
            if spellMap == 'Curaga' then
                equip(sets.midcast.CuragaSIRD or sets.midcast.Curaga)
            else
                equip(sets.midcast.CureSIRD or sets.midcast.Cure)
            end
        else
            -- Potency mode (default): use max cure potency gear
            if spellMap == 'Curaga' then
                equip(sets.midcast.Curaga)
            else
                equip(sets.midcast.Cure)
            end
        end
        eventArgs.handled = true
        return
    end

    -- CureSolace - apply CureMode even with Afflatus Solace (SIRD: CureSIRD.Solace when it exists)
    if spellMap == 'CureSolace' then
        if state.CureMode and state.CureMode.current == 'SIRD' then
            local sird = sets.midcast.CureSIRD
            equip((sird and sird.Solace) or sird or sets.midcast.CureSolace)
        else
            equip(sets.midcast.CureSolace)
        end
        eventArgs.handled = true
        return
    end

    -- CureMelee (engaged while casting Cure)
    if spellMap == 'CureMelee' then
        equip(sets.midcast.CureMelee or sets.midcast.Cure)
        eventArgs.handled = true
        return
    end
end

--- Layers for a cast job_midcast already dressed (eventArgs.handled). The Solace pieces of a
--- Cure are in sets.midcast.CureSolace itself (its Stoneskin comes on a single-target Cure only).
--- @param spell table Spell information from GearSwap
--- @param spellMap string Spell mapping (Cure, Curaga, CureSolace, ...)
local function job_post_midcast_eventargs_handled(spell, spellMap)
    if spellMap == 'StatusRemoval' and caress_applies(spell) then
        wear_version(spell, 'StatusRemoval', 'Caress')
    end

    -- Low MP: sets.midcast.CureMPConservation on top (WHM_CURE_CONFIG mp_conservation_below,
    -- shared/utils/whm/cure_manager.lua). Not CureMelee: a weapon swap there would cost the TP.
    if spellMap == 'Cure' or spellMap == 'Curaga' or spellMap == 'CureSolace' then
        local ok, CureManager = pcall(require, 'shared/utils/whm/cure_manager')
        if ok and CureManager and CureManager.lay_mp_conservation then
            CureManager.lay_mp_conservation(spell)
        end
    end
end

--- Status removal: MidcastManager set, then its Caress version under Divine Caress (-na spells only).
--- @param spell table Spell information from GearSwap
local function job_post_midcast_statusremoval(spell)
    MidcastManager.select_set({
        skill = 'StatusRemoval',
        spell = spell
    })

    if caress_applies(spell) then
        wear_version(spell, 'StatusRemoval', 'Caress')
    end
end

--- Enhancing Magic: spell-family routing, then the Solace version of an element Bar-spell.
--- @param spell table Spell information from GearSwap
local function job_post_midcast_enhancing_magic(spell)
    -- Use database-driven spell_family routing (replaces manual pattern matching)
    -- Database automatically routes: Regen, Refresh, BarElement, BarAilment, Stoneskin, Aquaveil, Boost, etc.
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target,
        database_func = EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    })

    -- Afflatus Solace adds MDB to the element Bar-spells only (BG Wiki Afflatus Solace)
    if buffactive['Afflatus Solace'] and EnhancingSPELLS and EnhancingSPELLS.get_spell_family
        and EnhancingSPELLS.get_spell_family(spell.english) == 'BarElement' then
        wear_version(spell, 'BarElement', 'Solace')
    end
end

--- Which set an enfeeble wants, by what it scales on.
---
--- Repose is WHM's own sleep and has a set of its own; it is Divine Magic,
--- so job_post_midcast never routes it here today. The rest split on the
--- spellMap from job_get_spell_map below: MndEnfeebles for White Magic,
--- IntEnfeebles otherwise.
--- @param spell table Spell information from GearSwap
--- @param spellMap string Spell mapping
--- @return string Pseudo-skill passed to MidcastManager
local function enfeeble_skill_for(spell, spellMap)
    if spell.name == 'Repose' then
        return 'Repose'
    elseif spellMap == 'MndEnfeebles' then
        return 'MndEnfeebles'
    elseif spellMap == 'IntEnfeebles' then
        return 'IntEnfeebles'
    end
    return 'Enfeebling Magic'
end

--- CastingMode Resistant picks <set>.Resistant when it exists (else the set
--- itself): sets.midcast.MndEnfeebles.Resistant, ['Divine Magic'].Resistant...
local function midcast_enfeebling(spell, spellMap)
    MidcastManager.select_set({
        skill = enfeeble_skill_for(spell, spellMap),
        spell = spell,
        mode_state = state.CastingMode,
    })
end

local function midcast_dark(spell)
    MidcastManager.select_set({skill = 'Dark Magic', spell = spell})
end

local function midcast_elemental(spell)
    MidcastManager.select_set({skill = 'Elemental Magic', spell = spell})
end

--- Post-midcast hook: watchdog, then MidcastManager routing by spell map/skill.
--- @param spell table Spell information from GearSwap
--- @param action string Action type
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function job_post_midcast(spell, action, spellMap, eventArgs)
    MidcastManager, EnhancingSPELLS = MidcastDeps.load()

    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Cures are already dressed by job_midcast (CureMode, Solace,
    -- CureMelee); re-selecting here would undo that.
    if eventArgs.handled then
        job_post_midcast_eventargs_handled(spell, spellMap)
        return
    end

    if spellMap == 'StatusRemoval' then
        job_post_midcast_statusremoval(spell)
    elseif spell.skill == 'Enhancing Magic' then
        job_post_midcast_enhancing_magic(spell)
    elseif spell.skill == 'Divine Magic' then
        MidcastManager.select_set({skill = 'Divine Magic', spell = spell, mode_state = state.CastingMode})
        -- Afflatus Misery changes the Banish family (Piety Pantaloons): its Misery version
        if buffactive['Afflatus Misery'] and spell.english:find('^Banish') then
            wear_version(spell, 'Banish', 'Misery')
        end
    elseif spell.skill == 'Enfeebling Magic' then
        midcast_enfeebling(spell, spellMap)
    elseif spell.skill == 'Dark Magic' then
        midcast_dark(spell)
    elseif spell.skill == 'Elemental Magic' then
        midcast_elemental(spell)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SPELL MAP CUSTOMIZATION
---  ═══════════════════════════════════════════════════════════════════════════

---   Custom spell mapping for WHM-specific behavior
---   Called by Mote-Include before spell is cast to determine set selection.
---
---   @param spell table Spell data
---   @param default_spell_map string Default mapping from Mote-Include
---   @return string|nil Custom spell map or nil to use default
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        -- ══════════════════════════════════════════════════════════════════════════
        -- CURE MAPPING (with Afflatus Solace detection)
        -- ══════════════════════════════════════════════════════════════════════════
        -- Map Cure/Curaga to CureMelee if engaged (checked FIRST, higher priority),
        -- but only when that set holds gear. The template ships
        -- `sets.midcast.CureMelee = {}` as a placeholder: job_midcast would equip
        -- that empty table and skip Mote's default, so the cure kept its precast
        -- gear. Without it, the cure keeps its Cure/Curaga map and CureMode.
        local melee_set = sets.midcast and sets.midcast.CureMelee
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and player and player.status == 'Engaged'
            and melee_set and next(melee_set) ~= nil then
            return 'CureMelee'
        end

        -- Map ONLY Cure (not Curaga) to CureSolace if Afflatus Solace is active
        -- Curaga stays as 'Curaga' and uses CureMode logic normally
        if default_spell_map == 'Cure' and buffactive['Afflatus Solace'] then
            return 'CureSolace'
        end

        -- ══════════════════════════════════════════════════════════════════════════
        -- ENFEEBLING MAPPING (MND vs INT)
        -- ══════════════════════════════════════════════════════════════════════════
        -- Map enfeebling spells based on primary stat
        if spell.skill == 'Enfeebling Magic' then
            if spell.type == 'WhiteMagic' then
                return 'MndEnfeebles'  -- Slow, Paralyze, Silence, etc.
            else
                return 'IntEnfeebles'  -- Blind, Poison (rare for WHM)
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast
_G.job_get_spell_map = job_get_spell_map

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
    job_get_spell_map = job_get_spell_map,
}

---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for White Mage with comprehensive spell-specific sets.
---
---   Features:
---   - Cure: CureMode (Potency vs SIRD), Afflatus Solace, Divine Caress
---   - Curaga: CureMode support
---   - Status Removal: Cursna, Paralyna, Erase
---   - Enhancing Magic: Database-driven spell_family routing (Regen, Refresh, BarElement, etc.)
---   - Divine Magic: Banish, Holy, Repose
---   - Enfeebling Magic: MND-based vs INT-based
---
---   @file    WHM_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.0 - Added spell_family database support
---   @date    Created: 2025-10-21 | Updated: 2025-11-05
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

    -- CureSolace - apply CureMode even with Afflatus Solace
    if spellMap == 'CureSolace' then
        if state.CureMode and state.CureMode.current == 'SIRD' then
            equip(sets.midcast.CureSIRD or sets.midcast.CureSolace)
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

--- Extracted from job_post_midcast: the `eventArgs.handled` branch.
local function job_post_midcast_eventargs_handled(spellMap)
    -- Apply Divine Caress boosting if StatusRemoval
    if spellMap == 'StatusRemoval' and buffactive['Divine Caress'] then
        equip(sets.buff['Divine Caress'])
    end

    -- Apply Afflatus Solace gear bonuses
    if buffactive['Afflatus Solace'] then
        if spellMap == 'Cure' or spellMap == 'Curaga' or spellMap == 'CureSolace' then
            equip(sets.buff['Afflatus Solace'])
        end
    end
end

--- Extracted from job_post_midcast: the `spellMap == 'StatusRemoval'` branch.
local function job_post_midcast_statusremoval(spell)
    MidcastManager.select_set({
        skill = 'StatusRemoval',
        spell = spell
    })

    -- Apply Divine Caress boosting if buff is active
    if buffactive['Divine Caress'] then
        equip(sets.buff['Divine Caress'])
    end
end

--- Extracted from job_post_midcast: the `spell.skill == 'Enhancing Magic'` branch.
local function job_post_midcast_enhancing_magic(spell)
    -- Use database-driven spell_family routing (replaces manual pattern matching)
    -- Database automatically routes: Regen, Refresh, BarElement, BarAilment, Stoneskin, Aquaveil, Boost, etc.
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target,
        database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    })

    -- Apply Afflatus Solace bonus for Bar-element spells
    if spell.name:match('^Bar') and buffactive['Afflatus Solace'] then
        equip(sets.buff['Afflatus Solace'])
    end

end

--- Which set an enfeeble wants, by what it scales on.
---
--- Repose is WHM's own sleep and has a set of its own. The rest split on
--- Mote's spellMap - MndEnfeebles or IntEnfeebles - which is followed rather
--- than duplicated, so a second list of spell names cannot drift out of step
--- with Mote's.
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

local function midcast_enfeebling(spell, spellMap)
    MidcastManager.select_set({
        skill = enfeeble_skill_for(spell, spellMap),
        spell = spell
    })
end

local function midcast_dark(spell)
    MidcastManager.select_set({skill = 'Dark Magic', spell = spell})
end

local function midcast_elemental(spell)
    MidcastManager.select_set({skill = 'Elemental Magic', spell = spell})
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Cures are already dressed by job_midcast, which knows the target's
    -- missing HP; re-selecting here would undo that.
    if eventArgs.handled then
        job_post_midcast_eventargs_handled(spellMap)
        return
    end

    if spellMap == 'StatusRemoval' then
        job_post_midcast_statusremoval(spell)
    elseif spell.skill == 'Enhancing Magic' then
        job_post_midcast_enhancing_magic(spell)
    elseif spell.skill == 'Divine Magic' then
        MidcastManager.select_set({skill = 'Divine Magic', spell = spell})
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
        -- Map Cure/Curaga to CureMelee if engaged (checked FIRST, higher priority)
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and player and player.status == 'Engaged' then
            return 'CureMelee'
        end

        -- Map ONLY Cure (not Curaga) to CureSolace if Afflatus Solace is active
        -- Curaga stays as 'Curaga' and uses CureMode logic normally
        if default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
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

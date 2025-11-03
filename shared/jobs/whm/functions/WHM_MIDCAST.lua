---============================================================================
--- WHM Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for White Mage with comprehensive spell-specific sets.
---
--- Features:
---   - Cure: CureMode (Potency vs SIRD), Afflatus Solace, Divine Caress
---   - Curaga: CureMode support
---   - Status Removal: Cursna, Paralyna, Erase
---   - Enhancing Magic: Regen, Refresh, BarElement, Stoneskin, Aquaveil, etc.
---   - Divine Magic: Banish, Holy, Repose
---   - Enfeebling Magic: MND-based vs INT-based
---
--- @file WHM_MIDCAST.lua
--- @author Tetsouo
--- @version 2.0 - Migrated to MidcastManager
--- @date Created: 2025-10-21 | Updated: 2025-10-25
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

function job_midcast(spell, action, spellMap, eventArgs)
    -- ==========================================================================
    -- HEALING MAGIC - CURE/CURAGA (CureMode SIRD logic)
    -- ==========================================================================
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

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Skip if already handled (Cure/Curaga/CureSolace)
    if eventArgs.handled then
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
        return
    end

    -- ==========================================================================
    -- STATUS REMOVAL (Cursna, Paralyna, Erase, etc.)
    -- ==========================================================================
    if spellMap == 'StatusRemoval' then
        MidcastManager.select_set({
            skill = 'StatusRemoval',
            spell = spell
        })

        -- Apply Divine Caress boosting if buff is active
        if buffactive['Divine Caress'] then
            equip(sets.buff['Divine Caress'])
        end
        return
    end

    -- ==========================================================================
    -- ENHANCING MAGIC (Spell-Specific Sets)
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        -- Spell-specific routing for WHM enhancing spells
        if spell.name == 'Stoneskin' then
            MidcastManager.select_set({skill = 'Stoneskin', spell = spell})
        elseif spell.name == 'Aquaveil' then
            MidcastManager.select_set({skill = 'Aquaveil', spell = spell})
        elseif spell.name:match('Regen') then
            MidcastManager.select_set({skill = 'Regen', spell = spell})
        elseif spell.name:match('Refresh') then
            MidcastManager.select_set({skill = 'Refresh', spell = spell})
        elseif spell.name:match('^Bar') then
            -- Bar-Element spells (Barfire, Barfira, etc.)
            MidcastManager.select_set({skill = 'BarElement', spell = spell})

            -- Apply Afflatus Solace bonus if active
            if buffactive['Afflatus Solace'] then
                equip(sets.buff['Afflatus Solace'])
            end
        elseif spell.name == 'Auspice' then
            MidcastManager.select_set({skill = 'Auspice', spell = spell})
        elseif spell.name:match('Haste') then
            MidcastManager.select_set({skill = 'Haste', spell = spell})
        elseif spell.name == 'Sneak' then
            MidcastManager.select_set({skill = 'Sneak', spell = spell})
        elseif spell.name == 'Invisible' then
            MidcastManager.select_set({skill = 'Invisible', spell = spell})
        elseif spell.name:match('Reraise') then
            MidcastManager.select_set({skill = 'Reraise', spell = spell})
        elseif spell.name:match('Raise') and not spell.name:match('Reraise') then
            MidcastManager.select_set({skill = 'Raise', spell = spell})
        elseif spell.name == 'Arise' then
            MidcastManager.select_set({skill = 'Arise', spell = spell})
        else
            -- Generic Enhancing Magic (catch-all)
            MidcastManager.select_set({
                skill = 'Enhancing Magic',
                spell = spell,
                target_func = MidcastManager.get_enhancing_target
            })
        end
        return
    end

    -- ==========================================================================
    -- DIVINE MAGIC
    -- ==========================================================================
    if spell.skill == 'Divine Magic' then
        MidcastManager.select_set({
            skill = 'Divine Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        -- Repose (WHM-specific sleep)
        if spell.name == 'Repose' then
            MidcastManager.select_set({skill = 'Repose', spell = spell})
        elseif spellMap == 'MndEnfeebles' then
            MidcastManager.select_set({skill = 'MndEnfeebles', spell = spell})
        elseif spellMap == 'IntEnfeebles' then
            MidcastManager.select_set({skill = 'IntEnfeebles', spell = spell})
        else
            MidcastManager.select_set({skill = 'Enfeebling Magic', spell = spell})
        end
        return
    end

    -- ==========================================================================
    -- DARK MAGIC / ELEMENTAL MAGIC
    -- ==========================================================================
    if spell.skill == 'Dark Magic' then
        MidcastManager.select_set({
            skill = 'Dark Magic',
            spell = spell
        })
        return
    end

    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell
        })
        return
    end
end

---============================================================================
--- SPELL MAP CUSTOMIZATION
---============================================================================

--- Custom spell mapping for WHM-specific behavior
--- Called by Mote-Include before spell is cast to determine set selection.
---
--- @param spell table Spell data
--- @param default_spell_map string Default mapping from Mote-Include
--- @return string|nil Custom spell map or nil to use default
function job_get_spell_map(spell, default_spell_map)
    if spell.action_type == 'Magic' then
        -- ==========================================================================
        -- CURE MAPPING (with Afflatus Solace detection)
        -- ==========================================================================
        -- Map Cure/Curaga to CureMelee if engaged (checked FIRST, higher priority)
        if (default_spell_map == 'Cure' or default_spell_map == 'Curaga') and player.status == 'Engaged' then
            return 'CureMelee'
        end

        -- Map ONLY Cure (not Curaga) to CureSolace if Afflatus Solace is active
        -- Curaga stays as 'Curaga' and uses CureMode logic normally
        if default_spell_map == 'Cure' and state.Buff['Afflatus Solace'] then
            return 'CureSolace'
        end

        -- ==========================================================================
        -- ENFEEBLING MAPPING (MND vs INT)
        -- ==========================================================================
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

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast
_G.job_get_spell_map = job_get_spell_map

local WHM_MIDCAST = {}
WHM_MIDCAST.job_midcast = job_midcast
WHM_MIDCAST.job_post_midcast = job_post_midcast
WHM_MIDCAST.job_get_spell_map = job_get_spell_map

return WHM_MIDCAST

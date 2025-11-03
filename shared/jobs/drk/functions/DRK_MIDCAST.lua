---============================================================================
--- DRK Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Dark Knight with specialized Dark Magic enhancements.
---
--- Features:
---   - Dark Magic: Dread Spikes, Absorb spells, Drain/Aspir
---   - Dark Seal buff enhancement (head)
---   - Nether Void buff enhancement (legs)
---   - Enfeebling Magic and Elemental Magic support
---
--- @file DRK_MIDCAST.lua
--- @author Tetsouo
--- @version 2.0 - Migrated to MidcastManager
--- @date Created: 2025-10-23 | Updated: 2025-10-25
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')

function job_midcast(spell, action, spellMap, eventArgs)
    -- No DRK-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- ==========================================================================
    -- DARK MAGIC (with spell-specific sets)
    -- ==========================================================================
    if spell.skill == 'Dark Magic' then
        -- Spell-specific routing
        if spell.name == 'Dread Spikes' then
            MidcastManager.select_set({
                skill = 'Dread Spikes',
                spell = spell
            })
        elseif spell.name:match('Absorb') then
            MidcastManager.select_set({
                skill = 'Absorb',
                spell = spell
            })
        else
            MidcastManager.select_set({
                skill = 'Dark Magic',
                spell = spell
            })
        end

        -- =======================================================================
        -- DARK SEAL & NETHER VOID BUFF ENHANCEMENT
        -- =======================================================================
        -- Applied AFTER MidcastManager to override with buff-specific gear
        local enhancements = {}

        -- Dark Seal (Buff ID 345)
        -- Effect: Dark Magic duration +10% per merit level
        -- Affects: Dread Spikes, Absorb spells, Drain III
        if buffactive['Dark Seal'] or buffactive[345] then
            if sets.buff and sets.buff['Dark Seal'] and sets.buff['Dark Seal'].head then
                enhancements.head = sets.buff['Dark Seal'].head
            end
        end

        -- Nether Void (Buff ID 439)
        -- Effect: +45% absorption potency (total 95% with gear)
        -- Affects: Absorb spells, Drain/Aspir (NOT Dread Spikes)
        if buffactive['Nether Void'] or buffactive[439] then
            -- Only apply to Absorb/Drain spells (Nether Void doesn't affect Dread Spikes)
            if spell.name:match('Absorb') or spell.name:match('Drain') or spell.name:match('Aspir') then
                if sets.buff and sets.buff['Nether Void'] and sets.buff['Nether Void'].legs then
                    enhancements.legs = sets.buff['Nether Void'].legs
                end
            end
        end

        -- Apply buff enhancements if any buffs are active
        if next(enhancements) then
            equip(enhancements)
        end

        return
    end

    -- ==========================================================================
    -- ENFEEBLING MAGIC
    -- ==========================================================================
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ELEMENTAL MAGIC
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell
        })
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local DRK_MIDCAST = {}
DRK_MIDCAST.job_midcast = job_midcast
DRK_MIDCAST.job_post_midcast = job_post_midcast

return DRK_MIDCAST

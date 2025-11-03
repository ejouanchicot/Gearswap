---============================================================================
--- GEO Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Geomancer including specialized Geomancy spells.
---
--- Features:
---   - Geomancy: Indi/Geo spells (handbell + duration)
---   - Healing Magic: Cure spells (if GEO/WHM)
---   - Enhancing Magic: Duration gear
---   - Enfeebling Magic: MACC gear
---   - Elemental Magic: Nuking (if needed)
---
--- @file GEO_MIDCAST.lua
--- @author Tetsouo
--- @version 2.0 - Migrated to MidcastManager
--- @date Created: 2025-10-09 | Updated: 2025-10-25
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')
local MessageFormatter = require('shared/utils/messages/message_formatter')

function job_midcast(spell, action, spellMap, eventArgs)
    -- No GEO-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- ==========================================================================
    -- GEOMANCY (Indi/Geo spells)
    -- ==========================================================================
    -- FIXED: spellMap est nil pour Geomancy, on utilise spell.skill à la place
    if spell.skill == 'Geomancy' then
        -- Display casting message
        if spell.english and spell.english:find("^Indi%-") then
            MessageFormatter.show_indi_cast(spell.english)
        elseif spell.english and spell.english:find("^Geo%-") then
            MessageFormatter.show_geo_cast(spell.english)
        end

        -- Equip Geomancy gear
        MidcastManager.select_set({
            skill = 'Geomancy',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- HEALING MAGIC (Cure/Curaga - if GEO/WHM)
    -- ==========================================================================
    if spellMap == 'Cure' or spellMap == 'Curaga' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
        return
    end

    -- ==========================================================================
    -- ELEMENTAL MAGIC (Nuking)
    -- ==========================================================================
    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell
        })
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
    -- ENHANCING MAGIC
    -- ==========================================================================
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target
        })
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local GEO_MIDCAST = {}
GEO_MIDCAST.job_midcast = job_midcast
GEO_MIDCAST.job_post_midcast = job_post_midcast

return GEO_MIDCAST

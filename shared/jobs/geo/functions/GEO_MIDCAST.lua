---============================================================================
--- GEO Midcast Module - Powered by MidcastManager
---============================================================================
--- Handles midcast for Geomancer. Only intercepts Geomancy spells (job-specific).
--- All other magic (Cure, Elemental, Enfeebling, Enhancing) is handled by
--- Mote-Include's natural pattern matching.
---
--- Features:
---   - Geomancy: Indi/Geo spells (handbell + duration) - INTERCEPTED
---   - All other magic: Handled by Mote-Include naturally
---
--- @file GEO_MIDCAST.lua
--- @author Tetsouo
--- @version 3.1 - Added spell_family database support
--- @date Created: 2025-10-09 | Updated: 2025-11-05
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load ENHANCING_MAGIC_DATABASE for spell_family routing
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

function job_midcast(spell, action, spellMap, eventArgs)
    -- No GEO-specific PRE-midcast logic
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- ==========================================================================
    -- GEOMANCY (Indi/Geo spells) - Job-specific, Mote doesn't handle
    -- ==========================================================================
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
    -- ALL OTHER MAGIC - Let Mote-Include handle naturally
    -- ==========================================================================
    -- Mote automatically handles:
    --   - Cure/Curaga >> sets.midcast.Cure / sets.midcast.Curaga
    --   - Elemental Magic >> sets.midcast['Elemental Magic']
    --   - Enfeebling Magic >> sets.midcast['Enfeebling Magic']
    --   - Enhancing Magic >> sets.midcast['Enhancing Magic']
    --   - Specific spells >> sets.midcast[spell.english]
    --
    -- No need to intercept - Mote's logic is sufficient for GEO!
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

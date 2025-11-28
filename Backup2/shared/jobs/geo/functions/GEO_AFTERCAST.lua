---============================================================================
--- GEO Aftercast Module - Post-Action Handling
---============================================================================
--- Handles aftercast cleanup for Geomancer job.
--- Returns to idle/engaged gear after spell completion.
---
--- @file GEO_AFTERCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-09
---============================================================================

---============================================================================
--- ENTRUST PENDING FLAG (Initialize global tracker)
---============================================================================
-- Track Entrust usage (persist until Indi spell is cast or buff expires)
if _G.geo_entrust_pending == nil then
    _G.geo_entrust_pending = false
end

---============================================================================
--- AFTERCAST HOOKS
---============================================================================

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- GEO-SPECIFIC AFTERCAST LOGIC

    -- Track Entrust usage for immediate gear application (before buff appears in buffactive)
    if spell.type == 'JobAbility' and spell.english == 'Entrust' and not spell.interrupted then
        _G.geo_entrust_pending = true
    end

    -- Clear Entrust pending flag after Indi spell completes (buff consumed)
    if spell.skill == 'Geomancy' and spell.english and spell.english:find("^Indi%-") and not spell.interrupted then
        _G.geo_entrust_pending = false
    end

    -- Force gear refresh after actions complete (handles Odyssey lag)
    if not spell.interrupted then
        coroutine.schedule(function()
            send_command('gs c update')
        end, 0.1)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_aftercast = job_aftercast

-- Export module
local GEO_AFTERCAST = {}
GEO_AFTERCAST.job_aftercast = job_aftercast

return GEO_AFTERCAST

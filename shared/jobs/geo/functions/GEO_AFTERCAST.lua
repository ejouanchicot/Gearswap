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
--- AFTERCAST HOOKS
---============================================================================

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- GEO-SPECIFIC AFTERCAST LOGIC

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

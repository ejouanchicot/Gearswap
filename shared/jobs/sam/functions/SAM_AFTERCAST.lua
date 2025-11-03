---============================================================================
--- SAM Aftercast Module - Aftercast Logic
---============================================================================
--- @file SAM_AFTERCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- SAM-specific aftercast logic

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

_G.job_aftercast = job_aftercast

local SAM_AFTERCAST = {}
SAM_AFTERCAST.job_aftercast = job_aftercast

return SAM_AFTERCAST

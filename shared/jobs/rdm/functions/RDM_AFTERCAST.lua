---============================================================================
--- RDM Aftercast Module - Post-Action Cleanup
---============================================================================
--- Handles gear return after actions complete (return to idle/engaged).
---
--- @file RDM_AFTERCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

--- Handle aftercast events (return to idle/engaged gear)
--- @param spell table Spell data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- RDM-specific aftercast logic
    -- Mote-Include will automatically return to idle/engaged sets

    -- Force gear refresh after actions complete (handles Odyssey lag)
    if not spell.interrupted then
        coroutine.schedule(function()
            send_command('gs c update')
        end, 0.1)
    end
end

-- Export to global scope
_G.job_aftercast = job_aftercast

-- Export module
local RDM_AFTERCAST = {}
RDM_AFTERCAST.job_aftercast = job_aftercast

return RDM_AFTERCAST

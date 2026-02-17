---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles gear return after actions complete (return to idle/engaged).
---
---   @file    shared/jobs/rdm/functions/RDM_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

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

-- Export to global scope (used by Mote-Include via include())
_G.job_aftercast = job_aftercast

-- Export as module
return {
    job_aftercast = job_aftercast
}

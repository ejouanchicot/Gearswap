---============================================================================
--- DNC Aftercast Module - Aftercast Action Handling
---============================================================================
--- Handles all aftercast actions for Dancer job.
---
--- Features:
---   • Return to appropriate gear sets after actions (idle/engaged)
---   • Post-weaponskill equipment swaps (back to TP gear)
---   • Post-ability cleanup (Step/Samba/Flourish aftermath)
---   • Status-aware gear selection (moving, town, combat)
---
--- @file    DNC_AFTERCAST.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-04
---============================================================================

---============================================================================
--- AFTERCAST HOOKS
---============================================================================

--- Called after action completes
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
--- @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- DNC-specific aftercast logic here
    -- Example: return to idle/engaged sets after WS/JA

    -- Force gear refresh after actions complete (handles Odyssey lag)
    if not spell.interrupted then
        coroutine.schedule(function()
            send_command('gs c update')
        end, 0.1)
    end
end

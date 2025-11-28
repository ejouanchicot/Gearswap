---============================================================================
--- WHM Aftercast Module - Aftercast State Management
---============================================================================
--- Handles all aftercast logic for White Mage job:
---   • Return to idle/engaged state after spell completion
---   • Buff management and state updates
---   • Post-spell cleanup
---
--- @file    WHM_AFTERCAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-21
---============================================================================

---============================================================================
--- AFTERCAST HOOK
---============================================================================

--- Called after spell/ability completes (success or failure)
--- Handles cleanup and return to idle/engaged state.
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping (not used)
--- @param eventArgs table Event arguments
--- @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- WHM-specific aftercast logic
    -- Most aftercast handling is done by Mote-Include automatically
    -- This function is for job-specific cleanup or state updates

    -- Examples:
    --   • Update buff tracking (Afflatus Solace/Misery)
    --   • Reset state variables after certain spells
    --   • Apply post-spell automation

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

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast

-- Export as module
return {
    job_aftercast = job_aftercast
}

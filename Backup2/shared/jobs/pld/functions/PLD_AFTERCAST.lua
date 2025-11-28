---============================================================================
--- PLD Aftercast Module - Aftercast Action Handling
---============================================================================
--- Handles all aftercast actions for Paladin job:
---   • Return to appropriate gear sets after actions
---   • Post-weaponskill equipment swaps
---   • Post-ability cleanup
---
--- @file    jobs/pld/functions/PLD_AFTERCAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
--- @requires Tetsouo architecture
---============================================================================
---============================================================================
--- AFTERCAST HOOK
---============================================================================
--- Called after action completes
--- Mote-Include automatically handles returning to idle/engaged sets.
--- PLD currently doesn't need custom aftercast logic.
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (not used)
--- @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- PLD-specific aftercast logic here
    -- Examples:
    --   • Post-WS equipment swaps
    --   • Post-JA cleanup
    --   • Buff-dependent gear changes

    -- Currently: Mote handles all aftercast transitions

    -- Force gear refresh after actions complete (handles Odyssey lag)
    if not spell.interrupted then
        coroutine.schedule(function()
            send_command('gs c update')
        end, 0.1)
    end
end

---============================================================================
--- POST-AFTERCAST HOOK
---============================================================================

--- Called after aftercast set selection for additional adjustments
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (not used)
--- @return void
function job_post_aftercast(spell, action, spellMap, eventArgs)
    -- PLD-specific post-aftercast adjustments
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast
_G.job_post_aftercast = job_post_aftercast

-- Export as module (for future require() usage)
return {
    job_aftercast = job_aftercast,
    job_post_aftercast = job_post_aftercast
}

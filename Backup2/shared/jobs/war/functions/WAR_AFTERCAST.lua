---============================================================================
--- WAR Aftercast Module - Aftercast Action Handling
---============================================================================
--- Handles all aftercast actions for Warrior job:
---   • Return to appropriate gear sets after actions
---   • Post-weaponskill equipment swaps
---   • Post-ability cleanup
---
--- @file    WAR_AFTERCAST.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-09-29
--- @requires Tetsouo architecture
---============================================================================
---============================================================================
--- AFTERCAST HOOK
---============================================================================
--- Called after action completes
--- Mote-Include automatically handles returning to idle/engaged sets.
--- WAR currently doesn't need custom aftercast logic.
---
--- @param spell     table  Spell/ability data
--- @param action    string Action type (not used)
--- @param spellMap  string Spell mapping (not used)
--- @param eventArgs table  Event arguments (not used)
--- @return void
function job_aftercast(spell, action, spellMap, eventArgs)
    -- WAR-specific aftercast logic here
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
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_aftercast = job_aftercast

-- Export as module (for future require() usage)
return {
    job_aftercast = job_aftercast
}

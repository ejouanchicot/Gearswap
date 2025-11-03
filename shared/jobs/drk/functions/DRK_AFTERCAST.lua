---============================================================================
--- DRK Aftercast Module - Aftercast Action Handling
---============================================================================
--- Handles all aftercast actions for Dark Knight job:
---   • Return to appropriate gear sets after actions
---   • Post-weaponskill equipment swaps
---   • Post-ability cleanup
---   • Buff pending flag confirmation
---
--- @file    DRK_AFTERCAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-23
--- @requires Tetsouo architecture, drk_buff_anticipation
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Load DRK buff anticipation logic
local DRKBuffAnticipation = require('shared/jobs/drk/functions/logic/drk_buff_anticipation')

-- Initialize pending flags at module load
DRKBuffAnticipation.initialize_flags()

---============================================================================
--- AFTERCAST HOOK
---============================================================================
--- Called after action completes
--- Confirms pending flags for JA buffs (if not interrupted)
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

    -- Confirm buff pending flags after JA completes (if not interrupted)
    if spell.type == 'JobAbility' and not spell.interrupted then
        if spell.name == 'Dark Seal' then
            _G.drk_dark_seal_pending = true
        elseif spell.name == 'Nether Void' then
            _G.drk_nether_void_pending = true
        end
    end

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
    -- DRK-specific post-aftercast adjustments
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

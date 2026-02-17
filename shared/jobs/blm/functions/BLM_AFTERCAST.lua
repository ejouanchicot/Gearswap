---============================================================================
--- BLM Aftercast Module - Post-Action Cleanup
---============================================================================
--- Handles aftercast logic for Black Mage job.
--- Returns to idle/engaged gear after spell completes.
---
--- @file BLM_AFTERCAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

---============================================================================
--- AFTERCAST HOOKS
---============================================================================

function job_aftercast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track aftercast
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_aftercast()
    end

    -- Clear Impact body lock flag (like BRD clears Marsyas lock)
    if spell.english == 'Impact' then
        _G.casting_impact = nil
        _G.impact_body = nil
    end

    -- BLM-SPECIFIC AFTERCAST LOGIC
    -- Currently none - Mote handles return to idle/engaged automatically

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
local BLM_AFTERCAST = {}
BLM_AFTERCAST.job_aftercast = job_aftercast

return BLM_AFTERCAST

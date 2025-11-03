---============================================================================
--- WHM Movement Module - Movement Detection & Speed Gear
---============================================================================
--- Handles movement detection and automatic speed gear application.
--- Integrates with AutoMove system for universal movement handling.
---
--- @file WHM_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
--- @requires shared/utils/movement/automove.lua
---============================================================================

---============================================================================
--- AUTOMOVE INTEGRATION
---============================================================================

-- AutoMove integration (automatic speed gear handling)
if AutoMove then
    -- AutoMove will automatically handle:
    --   • Movement detection
    --   • Speed gear swapping (sets.MoveSpeed from whm_sets.lua)
    --   • Idle gear restoration when stopped

    -- No additional callbacks needed - AutoMove handles everything
else
    -- AutoMove not available - movement speed gear disabled
    local success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if success and MessageFormatter then
        MessageFormatter.show_warning("WHM: AutoMove system not available")
    end
end

---============================================================================
--- EQUIPPING GEAR HANDLER
---============================================================================

--- Called when gear is being equipped (movement speed check)
--- AutoMove handles movement detection automatically, but this hook
--- allows for job-specific overrides if needed.
---
--- @param playerStatus string Player status ('Idle', 'Engaged', etc.)
--- @param eventArgs table Event arguments
--- @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- AutoMove handles movement speed automatically
    -- This function is here for WHM-specific movement logic if needed

    -- Optional: Timara WHM pattern (manual movement handling)
    -- if state.Moving and state.Moving.value == 'true' then
    --     send_command('gs equip sets.MoveSpeed')
    -- end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_handle_equipping_gear = job_handle_equipping_gear

-- Export as module
return {
    job_handle_equipping_gear = job_handle_equipping_gear
}

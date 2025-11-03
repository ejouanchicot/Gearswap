---============================================================================
--- DRK Movement Management Module - Movement Detection & Speed Gear
---============================================================================
--- Handles movement detection and automatic movement speed gear application:
---   • AutoMove utility integration
---   • Movement callback registration
---   • Automatic speed gear swapping
---
--- Uses centralized AutoMove for position tracking (performance optimization).
---
--- @file    DRK_MOVEMENT.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-23
--- @requires utils/movement/automove.lua
---============================================================================

---============================================================================
--- AUTOMOVE INTEGRATION
---============================================================================
-- Register with AutoMove for automatic speed gear
if AutoMove then
    -- AutoMove will automatically handle:
    --   • Movement detection
    --   • Speed gear swapping (sets.MoveSpeed from drk_sets.lua)
    --   • Idle gear restoration when stopped

    -- No additional callbacks needed - AutoMove handles everything
else
    -- AutoMove not available - movement speed gear disabled
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    MessageFormatter.show_warning("DRK: AutoMove system not available")
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export as module (for future require() usage)
return {
    -- Module loaded, AutoMove handles everything automatically
}

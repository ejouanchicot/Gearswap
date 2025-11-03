---============================================================================
--- BST Movement Module - Movement Gear Handling
---============================================================================
--- Handles movement speed gear for Beastmaster.
--- Registers with AutoMove for automatic movement detection.
---
--- @file jobs/bst/functions/BST_MOVEMENT.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- AUTOMOVE INTEGRATION
---============================================================================

-- AutoMove handles movement detection and speed gear automatically
if AutoMove then
    -- AutoMove will automatically handle:
    --   • Movement detection
    --   • Speed gear swapping (sets.MoveSpeed from bst_sets.lua)
    --   • Idle gear restoration when stopped

    -- No additional callbacks needed - movement gear applied in SetBuilder.build_idle_set()
else
    -- AutoMove not available - movement speed gear disabled
    MessageFormatter.show_warning('AutoMove system not available')
end

---============================================================================
--- MOVEMENT GEAR HOOK
---============================================================================

--- Called when equipping gear (before actual equip)
--- Not needed for BST - SetBuilder handles movement gear in build_idle_set()
---
--- @param playerStatus string Player status ("Idle", "Engaged", etc.)
--- @param eventArgs table Event arguments (not used)
--- @return void
function job_handle_equipping_gear(playerStatus, eventArgs)
    -- Movement gear handled by SetBuilder.build_idle_set()
    -- No additional logic required
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

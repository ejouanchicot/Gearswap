---============================================================================
--- WHM Functions Façade - Module Loader
---============================================================================
--- Loads all WHM-specific function modules in correct order.
--- Ensures all hooks are registered with GearSwap/Mote-Include system.
---
--- @file whm_functions.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-21
---============================================================================

-- Load all modules in dependency order
include('../shared/jobs/whm/functions/WHM_LOCKSTYLE.lua')
include('../shared/jobs/whm/functions/WHM_MACROBOOK.lua')
include('../shared/jobs/whm/functions/WHM_PRECAST.lua')
include('../shared/jobs/whm/functions/WHM_MIDCAST.lua')
include('../shared/jobs/whm/functions/WHM_AFTERCAST.lua')
include('../shared/jobs/whm/functions/WHM_IDLE.lua')
include('../shared/jobs/whm/functions/WHM_ENGAGED.lua')
include('../shared/jobs/whm/functions/WHM_STATUS.lua')
include('../shared/jobs/whm/functions/WHM_BUFFS.lua')
include('../shared/jobs/whm/functions/WHM_COMMANDS.lua')
include('../shared/jobs/whm/functions/WHM_MOVEMENT.lua')

-- Load dual-boxing manager
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

print('[WHM] Functions loaded successfully')

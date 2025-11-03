---============================================================================
--- SAM Functions Façade - Module Loader
---============================================================================
--- Loads all SAM-specific function modules in correct order.
--- @file sam_functions.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

-- Load all modules in dependency order (paths relative to TETSOUO_SAM.lua)
include('../shared/jobs/sam/functions/SAM_LOCKSTYLE.lua')
include('../shared/jobs/sam/functions/SAM_MACROBOOK.lua')
include('../shared/jobs/sam/functions/SAM_PRECAST.lua')
include('../shared/jobs/sam/functions/SAM_MIDCAST.lua')
include('../shared/jobs/sam/functions/SAM_AFTERCAST.lua')
include('../shared/jobs/sam/functions/SAM_IDLE.lua')
include('../shared/jobs/sam/functions/SAM_ENGAGED.lua')
include('../shared/jobs/sam/functions/SAM_STATUS.lua')
include('../shared/jobs/sam/functions/SAM_BUFFS.lua')
include('../shared/jobs/sam/functions/SAM_COMMANDS.lua')
include('../shared/jobs/sam/functions/SAM_MOVEMENT.lua')

-- Load dual-boxing manager
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

print('[SAM] Functions loaded successfully')

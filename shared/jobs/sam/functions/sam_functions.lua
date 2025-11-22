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
-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('SAM')
-- ═══════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/sam/functions/SAM_LOCKSTYLE.lua')
include('../shared/jobs/sam/functions/SAM_MACROBOOK.lua')
include('../shared/jobs/sam/functions/SAM_PRECAST.lua')
TIMER('SAM_PRECAST')
include('../shared/jobs/sam/functions/SAM_MIDCAST.lua')
TIMER('SAM_MIDCAST')
include('../shared/jobs/sam/functions/SAM_AFTERCAST.lua')
TIMER('SAM_AFTERCAST')
include('../shared/jobs/sam/functions/SAM_IDLE.lua')
TIMER('SAM_IDLE')
include('../shared/jobs/sam/functions/SAM_ENGAGED.lua')
TIMER('SAM_ENGAGED')
include('../shared/jobs/sam/functions/SAM_STATUS.lua')
TIMER('SAM_STATUS')
include('../shared/jobs/sam/functions/SAM_BUFFS.lua')
TIMER('SAM_BUFFS')
include('../shared/jobs/sam/functions/SAM_COMMANDS.lua')
TIMER('SAM_COMMANDS')
include('../shared/jobs/sam/functions/SAM_MOVEMENT.lua')
TIMER('SAM_MOVEMENT')

-- Load dual-boxing manager
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

print('[SAM] Functions loaded successfully')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL SAM_functions', true)
-- ═══════════════════════════════════════════════════════════════════

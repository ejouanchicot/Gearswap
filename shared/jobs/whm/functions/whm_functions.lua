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
-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('WHM')
-- ═══════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/whm/functions/WHM_LOCKSTYLE.lua')
include('../shared/jobs/whm/functions/WHM_MACROBOOK.lua')
include('../shared/jobs/whm/functions/WHM_PRECAST.lua')
TIMER('WHM_PRECAST')
include('../shared/jobs/whm/functions/WHM_MIDCAST.lua')
TIMER('WHM_MIDCAST')
include('../shared/jobs/whm/functions/WHM_AFTERCAST.lua')
TIMER('WHM_AFTERCAST')
include('../shared/jobs/whm/functions/WHM_IDLE.lua')
TIMER('WHM_IDLE')
include('../shared/jobs/whm/functions/WHM_ENGAGED.lua')
TIMER('WHM_ENGAGED')
include('../shared/jobs/whm/functions/WHM_STATUS.lua')
TIMER('WHM_STATUS')
include('../shared/jobs/whm/functions/WHM_BUFFS.lua')
TIMER('WHM_BUFFS')
include('../shared/jobs/whm/functions/WHM_COMMANDS.lua')
TIMER('WHM_COMMANDS')
include('../shared/jobs/whm/functions/WHM_MOVEMENT.lua')
TIMER('WHM_MOVEMENT')

-- Load dual-boxing manager
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

print('[WHM] Functions loaded successfully')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL WHM_functions', true)
-- ═══════════════════════════════════════════════════════════════════

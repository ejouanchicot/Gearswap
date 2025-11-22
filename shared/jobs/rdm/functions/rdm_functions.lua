---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Functions Façade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads all RDM-specific function modules in correct dependency order.
---   This file acts as the central coordinator for all RDM modules.
---
---   Features:
---     • Modular architecture (11 hooks + 1 logic module)
---     • Dependency-ordered loading (lockstyle >> macros >> combat >> utility)
---     • Separation of concerns (hooks = orchestration, logic = implementation)
---
---   Logic Modules:
---     • set_builder.lua - Shared set construction (engaged/idle/nuking)
---
---   @file    shared/jobs/rdm/functions/rdm_functions.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: INITIALIZATION MODULES
---  ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('RDM')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_LOCKSTYLE.lua')
TIMER('RDM_LOCKSTYLE')
include('../shared/jobs/rdm/functions/RDM_MACROBOOK.lua')
TIMER('RDM_MACROBOOK')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 2: COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_PRECAST.lua')
TIMER('RDM_PRECAST')
include('../shared/jobs/rdm/functions/RDM_MIDCAST.lua')
TIMER('RDM_MIDCAST')
include('../shared/jobs/rdm/functions/RDM_AFTERCAST.lua')
TIMER('RDM_AFTERCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 3: GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_IDLE.lua')
TIMER('RDM_IDLE')
include('../shared/jobs/rdm/functions/RDM_ENGAGED.lua')
TIMER('RDM_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 4: EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_STATUS.lua')
TIMER('RDM_STATUS')
include('../shared/jobs/rdm/functions/RDM_BUFFS.lua')
TIMER('RDM_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 5: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_COMMANDS.lua')
TIMER('RDM_COMMANDS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: DUAL-BOXING SYSTEM (non-critical, loaded last)
---  ═══════════════════════════════════════════════════════════════════════════

-- Load dual-boxing manager (auto-initializes and handles ALT<>>MAIN communication)
local dualbox_success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL RDM_functions', true)
-- ═══════════════════════════════════════════════════════════════════

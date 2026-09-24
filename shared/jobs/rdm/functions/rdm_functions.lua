---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads every RDM hook module, then the dual-box manager.
---
---   Load order: lockstyle >> macrobook >> precast/midcast/aftercast >>
---   idle/engaged >> status/buffs >> movement >> commands >> dual-box.
---
---   Logic Modules:
---     • set_builder.lua - Shared set construction (engaged/idle), lazy-loaded
---       by RDM_IDLE / RDM_ENGAGED
---
---   @file    shared/jobs/rdm/functions/rdm_functions.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: INITIALIZATION MODULES
---  ═══════════════════════════════════════════════════════════════════════════

-- Performance profiling (toggle with: //gs c perf start)
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('RDM')

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
---   SECTION 5: MOVEMENT HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_MOVEMENT.lua')
TIMER('RDM_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/rdm/functions/RDM_COMMANDS.lua')
TIMER('RDM_COMMANDS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 7: DUAL-BOXING SYSTEM (non-critical, loaded last)
---  ═══════════════════════════════════════════════════════════════════════════

-- Load dual-boxing manager (auto-initializes and handles ALT<>MAIN communication).
-- Plain `require` matches the convention used by every other job facade -
-- dualbox_manager is load-bearing infrastructure and must fail loud, not
-- silently degrade.
require('shared/utils/dualbox/dualbox_manager')

TIMER('TOTAL RDM_functions', true)

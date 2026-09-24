---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Functions Module - Facade Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Central loading facade for all DRK job modules.
---   This file includes all specialized DRK modules and makes their functions
---   available to the main job file.
---
---   Architecture:
---   • Hook modules (DRK_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
---   @file    shared/jobs/drk/functions/drk_functions.lua
---   @author  Tetsouo
---   @version 1.0 - Initial DRK Implementation
---   @date    Created: 2025-10-23
---   @requires All DRK_*.lua modules in functions directory
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: MESSAGE SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('DRK')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 2: COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/drk/functions/DRK_PRECAST.lua')
TIMER('DRK_PRECAST')
include('../shared/jobs/drk/functions/DRK_MIDCAST.lua')
TIMER('DRK_MIDCAST')
include('../shared/jobs/drk/functions/DRK_AFTERCAST.lua')
TIMER('DRK_AFTERCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 3: GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/drk/functions/DRK_IDLE.lua')
TIMER('DRK_IDLE')
include('../shared/jobs/drk/functions/DRK_ENGAGED.lua')
TIMER('DRK_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 4: EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/drk/functions/DRK_STATUS.lua')
TIMER('DRK_STATUS')
include('../shared/jobs/drk/functions/DRK_BUFFS.lua')
TIMER('DRK_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 5: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/drk/functions/DRK_LOCKSTYLE.lua')
include('../shared/jobs/drk/functions/DRK_MACROBOOK.lua')
include('../shared/jobs/drk/functions/DRK_COMMANDS.lua')
TIMER('DRK_COMMANDS')
include('../shared/jobs/drk/functions/DRK_MOVEMENT.lua')
TIMER('DRK_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   LOGIC MODULES REFERENCE
---  ═══════════════════════════════════════════════════════════════════════════
---   The following business logic modules are loaded via require() in hooks:
---
---   • set_builder.lua            - Engaged/idle set construction (AM3, PDT, weapon)
---   • drk_buff_anticipation.lua  - Dark Seal / Nether Void engaged variants
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: DUAL-BOXING SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- Loaded for its side effects (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION COMPLETE
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('DRK', 'All functions loaded (11 hooks)')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL DRK_functions', true)
-- ═══════════════════════════════════════════════════════════════════

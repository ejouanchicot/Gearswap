---============================================================================
--- RUN Functions Module - Facade Loader
---============================================================================
--- Central loading facade for all RUN job modules.
--- This file includes all specialized RUN modules and makes their functions
--- available to the main job file.
---
--- Architecture:
---   • Hook modules (RUN_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
--- @file    pld_functions.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-03 | Updated: 2025-10-06
--- @requires All RUN_*.lua modules in functions directory
---============================================================================
---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('RUN')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/run/functions/RUN_PRECAST.lua')
TIMER('RUN_PRECAST')
include('../shared/jobs/run/functions/RUN_MIDCAST.lua')
TIMER('RUN_MIDCAST')
include('../shared/jobs/run/functions/RUN_AFTERCAST.lua')
TIMER('RUN_AFTERCAST')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/run/functions/RUN_IDLE.lua')
TIMER('RUN_IDLE')
include('../shared/jobs/run/functions/RUN_ENGAGED.lua')
TIMER('RUN_ENGAGED')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/run/functions/RUN_STATUS.lua')
TIMER('RUN_STATUS')
include('../shared/jobs/run/functions/RUN_BUFFS.lua')
TIMER('RUN_BUFFS')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/run/functions/RUN_LOCKSTYLE.lua')
include('../shared/jobs/run/functions/RUN_MACROBOOK.lua')
include('../shared/jobs/run/functions/RUN_COMMANDS.lua')
TIMER('RUN_COMMANDS')
include('../shared/jobs/run/functions/RUN_MOVEMENT.lua')
TIMER('RUN_MOVEMENT')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/aoe_manager.lua
---     • Blue Magic AOE spell rotation (RUN/BLU subjob)
---     • Auto-target selection for AOE spells
---     • Spell tier escalation based on target count
---
---   logic/cure_set_builder.lua
---     • Dynamic Cure III/IV set generation
---     • Potency optimization based on HP thresholds
---     • Light Arts bonus detection & gear adjustment
---
---   logic/rune_manager.lua
---     • Rune ability management (RUN/RUN subjob)
---     • Mode-based rune selection (Sulpor/Lux)
---     • Auto-application timing coordination
---
---   logic/set_builder.lua
---     • Shared engaged set construction
---     • Shared idle set construction
---     • Hybrid mode application (PDT/MDT/Normal)
---============================================================================

---============================================================================
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (uses deferred init + lazy message loading)
local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[RUN] Functions loaded successfully')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL RUN_functions', true)
-- ═══════════════════════════════════════════════════════════════════

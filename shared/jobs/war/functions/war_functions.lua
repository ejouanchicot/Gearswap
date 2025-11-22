---============================================================================
--- WAR Functions Module - Facade Loader
---============================================================================
--- Central loading facade for all WAR job modules.
--- This file includes all specialized WAR modules and makes their functions
--- available to the main job file.
---
--- Architecture:
---   • Hook modules (WAR_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
--- @file    war_functions.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-09-29 | Updated: 2025-10-06
--- @requires All WAR_*.lua modules in functions directory
---============================================================================
-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('WAR')
-- ═══════════════════════════════════════════════════════════════════

---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/war/functions/WAR_PRECAST.lua')
TIMER('WAR_PRECAST')
include('../shared/jobs/war/functions/WAR_MIDCAST.lua')
TIMER('WAR_MIDCAST')
include('../shared/jobs/war/functions/WAR_AFTERCAST.lua')
TIMER('WAR_AFTERCAST')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/war/functions/WAR_IDLE.lua')
TIMER('WAR_IDLE')
include('../shared/jobs/war/functions/WAR_ENGAGED.lua')
TIMER('WAR_ENGAGED')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/war/functions/WAR_STATUS.lua')
TIMER('WAR_STATUS')
include('../shared/jobs/war/functions/WAR_BUFFS.lua')
TIMER('WAR_BUFFS')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/war/functions/WAR_LOCKSTYLE.lua')
TIMER('WAR_LOCKSTYLE')
include('../shared/jobs/war/functions/WAR_MACROBOOK.lua')
TIMER('WAR_MACROBOOK')
include('../shared/jobs/war/functions/WAR_COMMANDS.lua')
TIMER('WAR_COMMANDS')
include('../shared/jobs/war/functions/WAR_MOVEMENT.lua')
TIMER('WAR_MOVEMENT')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/smartbuff_manager.lua
---     • WAR core abilities (Berserk, Aggressor, Warcry, etc.)
---     • SAM subjob automation (Hasso/Seigan + Third Eye)
---     • DRG subjob automation (Jump/High Jump TP building)
---
---   logic/set_builder.lua
---     • Shared engaged set construction
---     • Shared idle set construction
---     • Aftermath Lv.3 detection & gear application
---============================================================================

---============================================================================
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (auto-initializes and handles ALT<>>MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')
TIMER('DualBoxManager')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL war_functions')
-- ═══════════════════════════════════════════════════════════════════

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[WAR] All functions loaded (11 hooks + 2 logic modules)')

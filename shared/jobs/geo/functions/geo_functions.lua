---  ═══════════════════════════════════════════════════════════════════════════
---   GEO Functions Module - Facade Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Central loading facade for all GEO job modules.
---   This file includes all specialized GEO modules and makes their functions
---   available to the main job file.
---
---   Architecture:
---   • Hook modules (GEO_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
---   @file    shared/jobs/geo/functions/geo_functions.lua
---   @author  Tetsouo
---   @version 2.0 - Logic Extracted to logic/
---   @date    Created: 2025-10-09 | Updated: 2025-10-14
---   @requires All GEO_*.lua modules in functions directory
---  ═══════════════════════════════════════════════════════════════════════════

-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('GEO')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: MESSAGE SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- Message system (must load first for buff status display)
include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 2: COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/geo/functions/GEO_PRECAST.lua')
TIMER('GEO_PRECAST')
include('../shared/jobs/geo/functions/GEO_MIDCAST.lua')
TIMER('GEO_MIDCAST')
include('../shared/jobs/geo/functions/GEO_AFTERCAST.lua')
TIMER('GEO_AFTERCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 3: GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/geo/functions/GEO_IDLE.lua')
TIMER('GEO_IDLE')
include('../shared/jobs/geo/functions/GEO_ENGAGED.lua')
TIMER('GEO_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 4: EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/geo/functions/GEO_STATUS.lua')
TIMER('GEO_STATUS')
include('../shared/jobs/geo/functions/GEO_BUFFS.lua')
TIMER('GEO_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 5: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/geo/functions/GEO_LOCKSTYLE.lua')
include('../shared/jobs/geo/functions/GEO_MACROBOOK.lua')
include('../shared/jobs/geo/functions/GEO_COMMANDS.lua')
TIMER('GEO_COMMANDS')
include('../shared/jobs/geo/functions/GEO_MOVEMENT.lua')
TIMER('GEO_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   LOGIC MODULES REFERENCE
---  ═══════════════════════════════════════════════════════════════════════════
---   The following business logic modules are loaded via require() in hooks:
---
---   logic/geo_spell_refiner.lua
---     • Nuke tier fallback (not learned / on recast) for the nuke commands
---
---   logic/set_builder.lua
---     • Engaged/idle set construction (luopan vs no luopan)
---     • HybridMode base selection (PDT/Normal) when no luopan is out
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: DUAL-BOXING SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- Loaded for its side effect: requiring dualbox_manager runs its deferred init.
require('shared/utils/dualbox/dualbox_manager')

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION COMPLETE
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('GEO', 'All functions loaded (11 hooks + 2 logic modules)')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL GEO_functions', true)
-- ═══════════════════════════════════════════════════════════════════

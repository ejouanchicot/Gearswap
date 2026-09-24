---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Central loading facade for all DNC job modules. This file orchestrates the
---   loading of 11 hook modules; the 5 logic modules under logic/ are loaded
---   on demand via require() by the hooks.
---
---   Architecture:
---   • Hook modules (DNC_*.lua) - GearSwap event handlers (loaded via include)
---   • Logic modules (logic/*.lua) - Business logic (loaded via require)
---   • Buff message formatter (included first)
---
---   @file    shared/jobs/dnc/functions/dnc_functions.lua
---   @author  Tetsouo
---   @version 2.0 - Logic Extracted to logic/
---   @date    Created: 2025-10-04
---   @date    Updated: 2025-10-06
---   @requires All DNC_*.lua modules in functions directory
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: MESSAGE SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('DNC')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 2: COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════
-- Handle precast/midcast/aftercast phases (gear swap timing-critical)

include('../shared/jobs/dnc/functions/DNC_PRECAST.lua')   -- Precast: guard, cooldowns, Samba TP, Jump/Climactic, WS
TIMER('DNC_PRECAST')
include('../shared/jobs/dnc/functions/DNC_MIDCAST.lua')   -- Midcast: Utsusemi, subjob magic
TIMER('DNC_MIDCAST')
include('../shared/jobs/dnc/functions/DNC_AFTERCAST.lua') -- Aftercast: watchdog
TIMER('DNC_AFTERCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 3: GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/dnc/functions/DNC_IDLE.lua')    -- Idle gear: town, weapon, movement
TIMER('DNC_IDLE')
include('../shared/jobs/dnc/functions/DNC_ENGAGED.lua') -- Combat gear: dance/HybridMode base, weapon
TIMER('DNC_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 4: EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/dnc/functions/DNC_STATUS.lua')  -- Status change: Idle/Engaged/Dead/Resting
TIMER('DNC_STATUS')
include('../shared/jobs/dnc/functions/DNC_BUFFS.lua')   -- Buff change: Doom, Saber/Fan Dance gear refresh
TIMER('DNC_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 5: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/dnc/functions/DNC_LOCKSTYLE.lua') -- Lockstyle (LockstyleManager factory)
include('../shared/jobs/dnc/functions/DNC_MACROBOOK.lua') -- Macro book selection per subjob
include('../shared/jobs/dnc/functions/DNC_COMMANDS.lua')  -- Commands: step, dance, smartbuff + shared
TIMER('DNC_COMMANDS')
include('../shared/jobs/dnc/functions/DNC_MOVEMENT.lua')  -- Movement status accessor
TIMER('DNC_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   LOGIC MODULES (Loaded dynamically via require() by hook modules)
---  ═══════════════════════════════════════════════════════════════════════════
---   These modules contain business logic and are loaded on-demand by hooks:
---
---   • climactic_manager.lua    - Auto-trigger Climactic Flourish before WS
---   • set_builder.lua          - Shared set construction (engaged/idle)
---   • smartbuff_manager.lua    - Dance, samba and subjob buffs (smartbuff/dance)
---   • step_manager.lua         - Step + Presto management
---   • ws_variant_selector.lua  - WS variant from dance/Climactic buffs
---
---   Auto-Jump before WS on /DRG lives in shared/utils/drg/auto_jump.lua.
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: DUAL-BOXING SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- Loaded for its side effects (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('DNC', 'All functions loaded (hooks + logic modules)')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL DNC_functions', true)
-- ═══════════════════════════════════════════════════════════════════

---============================================================================
--- DNC Functions Façade - Module Loader
---============================================================================
--- Central loading façade for all DNC job modules. This file orchestrates the
--- loading of 11 hook modules and provides the foundation for 6 logic modules
--- (loaded dynamically via require() by hooks).
---
--- Features:
---   • Modular architecture (11 hooks + 6 logic modules)
---   • Dependency-ordered loading (messages >> combat >> status >> utility)
---   • Separation of concerns (hooks = orchestration, logic = implementation)
---   • Clean integration with GearSwap event system
---
--- Architecture:
---   • Hook modules (DNC_*.lua) - GearSwap event handlers (loaded via include)
---   • Logic modules (logic/*.lua) - Business logic (loaded via require)
---   • Message system (loaded first for all modules)
---
--- @file    dnc_functions.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-04
--- @date    Updated: 2025-10-06
--- @requires All DNC_*.lua modules in functions directory
---============================================================================

---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Load message system first (required by all modules for consistent output)

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('DNC')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================
-- Handle precast/midcast/aftercast phases (gear swap timing-critical)

include('../shared/jobs/dnc/functions/DNC_PRECAST.lua')   -- Precast: Fast Cast, WS, Abilities
TIMER('DNC_PRECAST')
include('../shared/jobs/dnc/functions/DNC_MIDCAST.lua')   -- Midcast: Spell potency, Waltz healing
TIMER('DNC_MIDCAST')
include('../shared/jobs/dnc/functions/DNC_AFTERCAST.lua') -- Aftercast: Return to idle/engaged
TIMER('DNC_AFTERCAST')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/dnc/functions/DNC_IDLE.lua')    -- Idle gear: PDT, movement, town
TIMER('DNC_IDLE')
include('../shared/jobs/dnc/functions/DNC_ENGAGED.lua') -- Combat gear: DPS, TP bonus, DW tiers
TIMER('DNC_ENGAGED')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/dnc/functions/DNC_STATUS.lua')  -- Status change: Idle/Engaged/Dead/Resting
TIMER('DNC_STATUS')
include('../shared/jobs/dnc/functions/DNC_BUFFS.lua')   -- Buff change: Climactic Flourish tracking
TIMER('DNC_BUFFS')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/dnc/functions/DNC_LOCKSTYLE.lua') -- Lockstyle management with delays
include('../shared/jobs/dnc/functions/DNC_MACROBOOK.lua') -- Macro book selection per subjob
include('../shared/jobs/dnc/functions/DNC_COMMANDS.lua')  -- Custom commands (steps, waltz, jump)
TIMER('DNC_COMMANDS')
include('../shared/jobs/dnc/functions/DNC_MOVEMENT.lua')  -- Movement tracking, Haste Samba auto-off
TIMER('DNC_MOVEMENT')

---============================================================================
--- LOGIC MODULES (Loaded dynamically via require() by hook modules)
---============================================================================
--- These modules contain business logic and are loaded on-demand by hooks:
---
---   • climactic_manager.lua   - Auto-trigger Climactic Flourish before WS
---   • jump_manager.lua         - Auto-trigger Jump before WS (DRG subjob)
---   • set_builder.lua          - Shared set construction (engaged/idle)
---   • smartbuff_manager.lua    - Subjob buff application (Hasso, Seigan, etc.)
---   • step_manager.lua         - Step + Presto management
---   • ws_variant_selector.lua  - WS buff variant selection (Clim/TPBonus)
---============================================================================

---============================================================================
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (uses deferred init + lazy message loading)
local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION
---============================================================================

-- All module functions are now available in global scope
-- Individual modules handle their own initialization if needed

print('[DNC] All functions loaded (hooks + logic modules)')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL DNC_functions', true)
-- ═══════════════════════════════════════════════════════════════════

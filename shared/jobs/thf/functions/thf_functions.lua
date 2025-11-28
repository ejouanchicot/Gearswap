---============================================================================
--- THF Functions Façade - Module Loader
---============================================================================
--- Loads all THF-specific function modules in correct dependency order.
--- This façade coordinates all THF hooks and provides clean integration with
--- the GearSwap event system via Mote-Include framework.
---
--- Features:
---   • Modular architecture (11 hooks + 3 logic modules)
---   • Dependency-ordered loading (messages >> combat >> status >> utility)
---   • Separation of concerns (hooks = orchestration, logic = implementation)
---   • Clean integration with GearSwap event system
---
--- Architecture:
---   • Hook modules (11): PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS,
---     BUFFS, COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • Logic modules (3): sa_ta_manager, set_builder, smartbuff_manager
---   • Loaded via include() for GearSwap _G integration
---   • Logic modules use require() within hooks for encapsulation
---
--- Loading Order:
---   1. Message system (buff display foundation)
---   2. Combat action hooks (precast >> midcast >> aftercast)
---   3. Status & state hooks (status >> buffs >> idle >> engaged)
---   4. Utility & command hooks (macrobook >> lockstyle >> commands >> movement)
---
--- Dependencies:
---   • Mote-Include (provides base hook structure)
---   • AutoMove (movement tracking - loaded in main file before this)
---   • utils/messages/message_buffs.lua (buff gain/loss messages)
---
--- @file    jobs/thf/functions/thf_functions.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================

-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('THF')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/thf/functions/THF_PRECAST.lua')   -- Precast: Fast Cast, WS, SA/TA, TH
TIMER('THF_PRECAST')
include('../shared/jobs/thf/functions/THF_MIDCAST.lua')   -- Midcast: Spell potency, Utsusemi
TIMER('THF_MIDCAST')
include('../shared/jobs/thf/functions/THF_AFTERCAST.lua') -- Aftercast: Return to idle/engaged
TIMER('THF_AFTERCAST')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/thf/functions/THF_IDLE.lua')    -- Idle gear: PDT, movement, town
TIMER('THF_IDLE')
include('../shared/jobs/thf/functions/THF_ENGAGED.lua') -- Combat gear: DPS, TP bonus, DW tiers
TIMER('THF_ENGAGED')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/thf/functions/THF_STATUS.lua')  -- Status change: Idle/Engaged/Dead/Resting
TIMER('THF_STATUS')
include('../shared/jobs/thf/functions/THF_BUFFS.lua')   -- Buff change: SA/TA tracking
TIMER('THF_BUFFS')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/thf/functions/THF_LOCKSTYLE.lua') -- Lockstyle management with delays
include('../shared/jobs/thf/functions/THF_MACROBOOK.lua') -- Macro book selection per subjob
include('../shared/jobs/thf/functions/THF_COMMANDS.lua')  -- Custom commands (sata, smartbuff, etc.)
TIMER('THF_COMMANDS')
include('../shared/jobs/thf/functions/THF_MOVEMENT.lua')  -- Movement tracking, gear swapping
TIMER('THF_MOVEMENT')

---============================================================================
--- LOGIC MODULES (Loaded via require() in hook modules)
---============================================================================
--- • logic/sa_ta_manager.lua    - Sneak Attack/Trick Attack automation
--- • logic/set_builder.lua      - Shared set construction (engaged/idle)
--- • logic/smartbuff_manager.lua - Subjob-specific buff management
---============================================================================

-- Load dual-boxing manager (uses deferred init + lazy message loading)
local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')

print('[THF] All functions loaded successfully')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL THF_functions', true)
-- ═══════════════════════════════════════════════════════════════════

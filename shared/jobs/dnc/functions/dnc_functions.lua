---============================================================================
--- DNC Functions Façade - Module Loader
---============================================================================
--- Central loading façade for all DNC job modules. This file orchestrates the
--- loading of 11 hook modules and provides the foundation for 6 logic modules
--- (loaded dynamically via require() by hooks).
---
--- Features:
---   • Modular architecture (11 hooks + 6 logic modules)
---   • Dependency-ordered loading (messages → combat → status → utility)
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

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================
-- Handle precast/midcast/aftercast phases (gear swap timing-critical)

include('../shared/jobs/dnc/functions/DNC_PRECAST.lua')   -- Precast: Fast Cast, WS, Abilities
include('../shared/jobs/dnc/functions/DNC_MIDCAST.lua')   -- Midcast: Spell potency, Waltz healing
include('../shared/jobs/dnc/functions/DNC_AFTERCAST.lua') -- Aftercast: Return to idle/engaged

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/dnc/functions/DNC_IDLE.lua')    -- Idle gear: PDT, movement, town
include('../shared/jobs/dnc/functions/DNC_ENGAGED.lua') -- Combat gear: DPS, TP bonus, DW tiers

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/dnc/functions/DNC_STATUS.lua')  -- Status change: Idle/Engaged/Dead/Resting
include('../shared/jobs/dnc/functions/DNC_BUFFS.lua')   -- Buff change: Climactic Flourish tracking

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/dnc/functions/DNC_LOCKSTYLE.lua') -- Lockstyle management with delays
include('../shared/jobs/dnc/functions/DNC_MACROBOOK.lua') -- Macro book selection per subjob
include('../shared/jobs/dnc/functions/DNC_COMMANDS.lua')  -- Custom commands (steps, waltz, jump)
include('../shared/jobs/dnc/functions/DNC_MOVEMENT.lua')  -- Movement tracking, Haste Samba auto-off

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

-- Load dual-boxing manager (auto-initializes and handles ALT<->MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION
---============================================================================

-- All module functions are now available in global scope
-- Individual modules handle their own initialization if needed

print('[DNC] All functions loaded (hooks + logic modules)')

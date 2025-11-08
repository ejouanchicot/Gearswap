---============================================================================
--- COR Functions Façade - Module Loader
---============================================================================
--- Loads all COR-specific function modules in correct order.
---
--- Features:
---   • Modular architecture (11 hooks + 3 logic modules)
---   • Dependency-ordered loading (messages >> combat >> status >> utility)
---   • Separation of concerns (hooks = orchestration, logic = implementation)
---   • Clean integration with GearSwap event system
---
--- Architecture:
---   • Hook modules (11): GearSwap event handlers loaded via include()
---   • Logic modules (3): Business logic loaded via require() in hooks
---   • Separation: Hooks = 10-20% code, Logic = 80-90% code
---
--- Logic Modules:
---   • set_builder.lua - Shared set construction (idle/engaged with COR specifics)
---   • roll_data.lua - Phantom Roll game data (lucky/unlucky numbers, bonuses)
---   • roll_tracker.lua - Roll tracking with party job detection
---
--- Dependencies:
---   • message_buffs.lua (roll status display)
---   • All COR_*.lua hook modules (11 total)
---
--- @file    jobs/cor/functions/cor_functions.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-07
---============================================================================

---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================

include('../shared/utils/messages/formatters/magic/message_buffs.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/cor/functions/COR_PRECAST.lua')
include('../shared/jobs/cor/functions/COR_MIDCAST.lua')
include('../shared/jobs/cor/functions/COR_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/cor/functions/COR_IDLE.lua')
include('../shared/jobs/cor/functions/COR_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/cor/functions/COR_STATUS.lua')
include('../shared/jobs/cor/functions/COR_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/cor/functions/COR_LOCKSTYLE.lua')
include('../shared/jobs/cor/functions/COR_MACROBOOK.lua')
include('../shared/jobs/cor/functions/COR_COMMANDS.lua')
include('../shared/jobs/cor/functions/COR_MOVEMENT.lua')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/roll_data.lua
---     • Phantom Roll game data (lucky/unlucky numbers, bonuses)
---     • Roll effects and stat bonuses
---
---   logic/roll_tracker.lua
---     • Roll tracking with party job detection
---     • Active roll monitoring and Double-Up support
---
---   logic/set_builder.lua
---     • Shared set construction with COR-specific logic
---     • Idle/engaged gear assembly
---============================================================================

---============================================================================
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (auto-initializes and handles ALT<>>MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[COR] All functions loaded (11 hooks + 3 logic modules)')

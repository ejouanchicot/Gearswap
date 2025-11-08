---============================================================================
--- PLD Functions Module - Facade Loader
---============================================================================
--- Central loading facade for all PLD job modules.
--- This file includes all specialized PLD modules and makes their functions
--- available to the main job file.
---
--- Architecture:
---   • Hook modules (PLD_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
--- @file    pld_functions.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-03 | Updated: 2025-10-06
--- @requires All PLD_*.lua modules in functions directory
---============================================================================
---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
include('../shared/utils/messages/formatters/magic/message_buffs.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/pld/functions/PLD_PRECAST.lua')
include('../shared/jobs/pld/functions/PLD_MIDCAST.lua')
include('../shared/jobs/pld/functions/PLD_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/pld/functions/PLD_IDLE.lua')
include('../shared/jobs/pld/functions/PLD_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/pld/functions/PLD_STATUS.lua')
include('../shared/jobs/pld/functions/PLD_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/pld/functions/PLD_LOCKSTYLE.lua')
include('../shared/jobs/pld/functions/PLD_MACROBOOK.lua')
include('../shared/jobs/pld/functions/PLD_COMMANDS.lua')
include('../shared/jobs/pld/functions/PLD_MOVEMENT.lua')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/aoe_manager.lua
---     • Blue Magic AOE spell rotation (PLD/BLU subjob)
---     • Auto-target selection for AOE spells
---     • Spell tier escalation based on target count
---
---   logic/cure_set_builder.lua
---     • Dynamic Cure III/IV set generation
---     • Potency optimization based on HP thresholds
---     • Light Arts bonus detection & gear adjustment
---
---   logic/rune_manager.lua
---     • Rune ability management (PLD/RUN subjob)
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

-- Load dual-boxing manager (auto-initializes and handles ALT<>>MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[PLD] All functions loaded (11 hooks + 4 logic modules)')

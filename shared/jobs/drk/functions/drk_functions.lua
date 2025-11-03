---============================================================================
--- DRK Functions Module - Facade Loader
---============================================================================
--- Central loading facade for all DRK job modules.
--- This file includes all specialized DRK modules and makes their functions
--- available to the main job file.
---
--- Architecture:
---   • Hook modules (DRK_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
--- @file    drk_functions.lua
--- @author  Tetsouo
--- @version 1.0 - Initial DRK Implementation
--- @date    Created: 2025-10-23
--- @requires All DRK_*.lua modules in functions directory
---============================================================================
---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
include('../shared/utils/messages/message_buffs.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/drk/functions/DRK_PRECAST.lua')
include('../shared/jobs/drk/functions/DRK_MIDCAST.lua')
include('../shared/jobs/drk/functions/DRK_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/drk/functions/DRK_IDLE.lua')
include('../shared/jobs/drk/functions/DRK_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/drk/functions/DRK_STATUS.lua')
include('../shared/jobs/drk/functions/DRK_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/drk/functions/DRK_LOCKSTYLE.lua')
include('../shared/jobs/drk/functions/DRK_MACROBOOK.lua')
include('../shared/jobs/drk/functions/DRK_COMMANDS.lua')
include('../shared/jobs/drk/functions/DRK_MOVEMENT.lua')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   To be added as needed for DRK-specific complex logic
---============================================================================

---============================================================================
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (auto-initializes and handles ALT<->MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[DRK] All functions loaded (11 hooks)')

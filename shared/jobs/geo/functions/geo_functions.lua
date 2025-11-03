---============================================================================
--- GEO Functions Module - Facade Loader
---============================================================================
--- Central loading facade for all GEO job modules.
--- This file includes all specialized GEO modules and makes their functions
--- available to the main job file.
---
--- Architecture:
---   • Hook modules (GEO_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---
--- @file    geo_functions.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-09 | Updated: 2025-10-14
--- @requires All GEO_*.lua modules in functions directory
---============================================================================
---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
include('../shared/utils/messages/message_buffs.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/geo/functions/GEO_PRECAST.lua')
include('../shared/jobs/geo/functions/GEO_MIDCAST.lua')
include('../shared/jobs/geo/functions/GEO_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/geo/functions/GEO_IDLE.lua')
include('../shared/jobs/geo/functions/GEO_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/geo/functions/GEO_STATUS.lua')
include('../shared/jobs/geo/functions/GEO_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/geo/functions/GEO_LOCKSTYLE.lua')
include('../shared/jobs/geo/functions/GEO_MACROBOOK.lua')
include('../shared/jobs/geo/functions/GEO_COMMANDS.lua')
include('../shared/jobs/geo/functions/GEO_MOVEMENT.lua')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/geo_spell_refiner.lua
---     • Auto-select optimal Indi/Geo spell based on mode
---     • Nuke tier and spell element selection
---     • Spell refinement based on context
---
---   logic/set_builder.lua
---     • Shared engaged set construction
---     • Shared idle set construction
---     • Hybrid mode application (PDT/MDT/Normal)
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
print('[GEO] All functions loaded (11 hooks + 2 logic modules)')

---============================================================================
--- RDM Functions Façade - Module Loader
---============================================================================
--- Loads all RDM-specific function modules in correct dependency order.
--- This file acts as the central coordinator for all RDM modules.
---
--- Features:
---   • Modular architecture (11 hooks + 1 logic module)
---   • Dependency-ordered loading (lockstyle → macros → combat → utility)
---   • Separation of concerns (hooks = orchestration, logic = implementation)
---
--- Logic Modules:
---   • set_builder.lua - Shared set construction (engaged/idle/nuking)
---
--- @file rdm_functions.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

---============================================================================
--- SECTION 1: INITIALIZATION MODULES
---============================================================================

include('../shared/jobs/rdm/functions/RDM_LOCKSTYLE.lua')
include('../shared/jobs/rdm/functions/RDM_MACROBOOK.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/rdm/functions/RDM_PRECAST.lua')
include('../shared/jobs/rdm/functions/RDM_MIDCAST.lua')
include('../shared/jobs/rdm/functions/RDM_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/rdm/functions/RDM_IDLE.lua')
include('../shared/jobs/rdm/functions/RDM_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/rdm/functions/RDM_STATUS.lua')
include('../shared/jobs/rdm/functions/RDM_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/rdm/functions/RDM_COMMANDS.lua')
include('../shared/jobs/rdm/functions/RDM_MOVEMENT.lua')

---============================================================================
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (auto-initializes and handles ALT<->MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[RDM] All functions loaded (11 hooks + 1 logic module)')

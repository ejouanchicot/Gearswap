---============================================================================
--- PUP Functions Façade - Module Loader
---============================================================================
--- Loads all PUP-specific function modules in correct order.
--- CRITICAL: All 11 hook modules must be loaded via include() for _G availability.
---
--- @file jobs/pup/functions/pup_functions.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
include('../shared/utils/messages/formatters/magic/message_buffs.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/pup/functions/PUP_PRECAST.lua')
include('../shared/jobs/pup/functions/PUP_MIDCAST.lua')
include('../shared/jobs/pup/functions/PUP_AFTERCAST.lua')

-- Pet-specific hooks (for Ready Moves and pet abilities)
include('../shared/jobs/pup/functions/PUP_PET_PRECAST.lua')
include('../shared/jobs/pup/functions/PUP_PET_MIDCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/pup/functions/PUP_IDLE.lua')
include('../shared/jobs/pup/functions/PUP_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/pup/functions/PUP_STATUS.lua')
include('../shared/jobs/pup/functions/PUP_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/pup/functions/PUP_LOCKSTYLE.lua')
include('../shared/jobs/pup/functions/PUP_MACROBOOK.lua')
include('../shared/jobs/pup/functions/PUP_COMMANDS.lua')
include('../shared/jobs/pup/functions/PUP_MOVEMENT.lua')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/ecosystem_manager.lua
---     • Dynamic state creation (species/ammoSet per ecosystem)
---     • Ecosystem cycling and species management
---     • Ammo set tracking and pet food coordination
---
---   logic/pet_manager.lua
---     • Auto pet engage (based on state.AutoPetEngage)
---     • Pet status monitoring (updates state.petEngaged)
---     • Pet action validation and coordination
---
---   logic/ready_move_categorizer.lua
---     • Physical vs Magical Ready Move categorization
---     • Potency tier detection (Low/Mid/High)
---     • Equipment set selection optimization
---
---   logic/set_builder.lua
---     • Shared engaged set construction (master + pet bifurcation)
---     • Shared idle set construction (PetPDT vs MasterPDT)
---     • Pet mode detection and gear swapping
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
print('[PUP] All functions loaded (13 hooks + 4 logic modules)')

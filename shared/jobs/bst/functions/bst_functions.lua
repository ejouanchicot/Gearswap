---============================================================================
--- BST Functions Façade - Module Loader
---============================================================================
--- Loads all BST-specific function modules in correct order.
--- CRITICAL: All 11 hook modules must be loaded via include() for _G availability.
---
--- @file jobs/bst/functions/bst_functions.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

---============================================================================
--- SECTION 1: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('BST')
-- ═══════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/bst/functions/BST_PRECAST.lua')
TIMER('BST_PRECAST')
include('../shared/jobs/bst/functions/BST_MIDCAST.lua')
TIMER('BST_MIDCAST')
include('../shared/jobs/bst/functions/BST_AFTERCAST.lua')
TIMER('BST_AFTERCAST')

-- Pet-specific hooks (for Ready Moves and pet abilities)
include('../shared/jobs/bst/functions/BST_PET_PRECAST.lua')
TIMER('BST_PET_PRECAST')
include('../shared/jobs/bst/functions/BST_PET_MIDCAST.lua')
TIMER('BST_PET_MIDCAST')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/bst/functions/BST_IDLE.lua')
TIMER('BST_IDLE')
include('../shared/jobs/bst/functions/BST_ENGAGED.lua')
TIMER('BST_ENGAGED')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/bst/functions/BST_STATUS.lua')
TIMER('BST_STATUS')
include('../shared/jobs/bst/functions/BST_BUFFS.lua')
TIMER('BST_BUFFS')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/bst/functions/BST_LOCKSTYLE.lua')
include('../shared/jobs/bst/functions/BST_MACROBOOK.lua')
include('../shared/jobs/bst/functions/BST_COMMANDS.lua')
TIMER('BST_COMMANDS')
include('../shared/jobs/bst/functions/BST_MOVEMENT.lua')
TIMER('BST_MOVEMENT')

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
print('[BST] All functions loaded (13 hooks + 4 logic modules)')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL BST_functions', true)
-- ═══════════════════════════════════════════════════════════════════

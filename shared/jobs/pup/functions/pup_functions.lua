---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads all PUP hook modules via include() (they publish Mote hooks in _G).
---   NOTE: PUP is incomplete - the logic/ modules listed below and the PUP
---   configs do not exist, so the job does not load today.
---
---   @file    shared/jobs/pup/functions/pup_functions.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-17
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: MESSAGE SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════
-- Performance profiling (toggle with: //gs c perf start)
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('PUP')

-- Message system (must load first for buff status display)
include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 2: COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/pup/functions/PUP_PRECAST.lua')
TIMER('PUP_PRECAST')
include('../shared/jobs/pup/functions/PUP_MIDCAST.lua')
TIMER('PUP_MIDCAST')
include('../shared/jobs/pup/functions/PUP_AFTERCAST.lua')
TIMER('PUP_AFTERCAST')

-- Pet-specific hooks (for Ready Moves and pet abilities)
include('../shared/jobs/pup/functions/PUP_PET_PRECAST.lua')
TIMER('PUP_PET_PRECAST')
include('../shared/jobs/pup/functions/PUP_PET_MIDCAST.lua')
TIMER('PUP_PET_MIDCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 3: GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/pup/functions/PUP_IDLE.lua')
TIMER('PUP_IDLE')
include('../shared/jobs/pup/functions/PUP_ENGAGED.lua')
TIMER('PUP_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 4: EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/pup/functions/PUP_STATUS.lua')
TIMER('PUP_STATUS')
include('../shared/jobs/pup/functions/PUP_BUFFS.lua')
TIMER('PUP_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 5: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/pup/functions/PUP_LOCKSTYLE.lua')
include('../shared/jobs/pup/functions/PUP_MACROBOOK.lua')
include('../shared/jobs/pup/functions/PUP_COMMANDS.lua')
TIMER('PUP_COMMANDS')
include('../shared/jobs/pup/functions/PUP_MOVEMENT.lua')
TIMER('PUP_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   LOGIC MODULES REFERENCE
---  ═══════════════════════════════════════════════════════════════════════════
---   The hooks require() these business logic modules. NONE of them exists
---   yet under shared/jobs/pup/functions/logic/; the descriptions below are
---   the intended design (taken from BST), not working code.
---
---   logic/ecosystem_manager.lua
---     • Dynamic state creation (species/ammoSet per ecosystem)
---     • Ecosystem cycling and species management
---     • Ammo set tracking and pet food coordination
---
---   logic/pet_manager.lua
---     • Auto pet engage (based on state.AutoPetEngage)
---     • Pet status monitoring (updates state.PetEngaged)
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
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: DUAL-BOXING SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- Load dual-boxing manager (auto-initializes on load)
require('shared/utils/dualbox/dualbox_manager')

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION COMPLETE
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('PUP', 'All functions loaded (13 hooks + 4 logic modules)')

TIMER('TOTAL PUP_functions', true)

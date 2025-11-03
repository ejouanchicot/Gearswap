---============================================================================
--- BRD Functions Façade - Module Loader
---============================================================================
--- Loads all BRD-specific function modules in correct dependency order.
--- This façade ensures all hooks are registered before GearSwap events fire.
---
--- Features:
---   • Modular architecture (11 hooks + 3 logic modules)
---   • Dependency-ordered loading (lockstyle → macros → combat → utility)
---   • Separation of concerns (hooks = orchestration, logic = implementation)
---
--- Logic Modules:
---   • song_rotation_manager.lua - Song casting, dummy phases, dynamic timing
---   • song_refinement.lua - Song tier downgrade system (Lullaby II → I, etc.)
---   • set_builder.lua - Shared set construction (engaged/idle)
---
--- @file brd_functions.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

---============================================================================
--- SECTION 1: INITIALIZATION MODULES
---============================================================================

include('../shared/jobs/brd/functions/BRD_LOCKSTYLE.lua')
include('../shared/jobs/brd/functions/BRD_MACROBOOK.lua')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/brd/functions/BRD_PRECAST.lua')
include('../shared/jobs/brd/functions/BRD_MIDCAST.lua')
include('../shared/jobs/brd/functions/BRD_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/brd/functions/BRD_IDLE.lua')
include('../shared/jobs/brd/functions/BRD_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/brd/functions/BRD_STATUS.lua')
include('../shared/jobs/brd/functions/BRD_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/brd/functions/BRD_COMMANDS.lua')
include('../shared/jobs/brd/functions/BRD_MOVEMENT.lua')

---============================================================================
--- FAÇADE LOAD COMPLETE
---============================================================================

-- Load dual-boxing manager
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

print('[BRD] Functions loaded successfully')

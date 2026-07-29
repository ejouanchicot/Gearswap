---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads all SMN-specific function modules in correct order.
---   All hook modules must be loaded via include() for _G availability.
---
---   @file    shared/jobs/smn/smn_functions.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('SMN')

---  ═══════════════════════════════════════════════════════════════════════════
---   MESSAGE SYSTEM (must load first for buff status display)
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

---  ═══════════════════════════════════════════════════════════════════════════
---   COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/smn/functions/SMN_PRECAST.lua')
TIMER('SMN_PRECAST')
include('../shared/jobs/smn/functions/SMN_MIDCAST.lua')
TIMER('SMN_MIDCAST')
include('../shared/jobs/smn/functions/SMN_AFTERCAST.lua')
TIMER('SMN_AFTERCAST')

-- Pet hooks (Blood Pact damage gear)
include('../shared/jobs/smn/functions/SMN_PET_MIDCAST.lua')
TIMER('SMN_PET_MIDCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/smn/functions/SMN_IDLE.lua')
TIMER('SMN_IDLE')
include('../shared/jobs/smn/functions/SMN_ENGAGED.lua')
TIMER('SMN_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/smn/functions/SMN_STATUS.lua')
TIMER('SMN_STATUS')
include('../shared/jobs/smn/functions/SMN_BUFFS.lua')
TIMER('SMN_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/smn/functions/SMN_LOCKSTYLE.lua')
include('../shared/jobs/smn/functions/SMN_MACROBOOK.lua')
include('../shared/jobs/smn/functions/SMN_COMMANDS.lua')
TIMER('SMN_COMMANDS')
include('../shared/jobs/smn/functions/SMN_MOVEMENT.lua')
TIMER('SMN_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   DUAL-BOXING SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION COMPLETE
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('SMN', 'All functions loaded (12 hooks + 1 logic module)')

TIMER('TOTAL SMN_functions', true)

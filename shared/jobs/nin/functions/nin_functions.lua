---  ═══════════════════════════════════════════════════════════════════════════
---   NIN Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads the Ninja hook modules in dependency order and wires them into
---   Mote-Include's globals.
---
---   Architecture:
---   • Hook modules (11): PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS,
---     BUFFS, COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • Logic modules (2, required by the hooks):
---       logic/ninjutsu.lua     Ninjutsu spell -> family (Utsusemi,
---                              Elemental...), Magic Burst mode, Futae layer
---       logic/set_builder.lua  idle / engaged sets: town or HybridMode
---                              idle, OffenseMode / DT, Yonin / Innin /
---                              Sange / Issekigan layers, weapons, movement
---                              (night set dusk to dawn)
---
---   @file    shared/jobs/nin/functions/nin_functions.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('NIN')

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

-- Combat action hooks
include('../shared/jobs/nin/functions/NIN_PRECAST.lua')   -- Guard, cooldown, WS
TIMER('NIN_PRECAST')
include('../shared/jobs/nin/functions/NIN_MIDCAST.lua')   -- Ninjutsu families via MidcastManager, Futae
TIMER('NIN_MIDCAST')
include('../shared/jobs/nin/functions/NIN_AFTERCAST.lua') -- Watchdog tick
TIMER('NIN_AFTERCAST')

-- Gear selection hooks
include('../shared/jobs/nin/functions/NIN_IDLE.lua')      -- Town / HybridMode idle, weapons, movement
TIMER('NIN_IDLE')
include('../shared/jobs/nin/functions/NIN_ENGAGED.lua')   -- OffenseMode, DT, buff layers, weapons
TIMER('NIN_ENGAGED')

-- Event hooks
include('../shared/jobs/nin/functions/NIN_STATUS.lua')    -- Status change (Doom slots)
TIMER('NIN_STATUS')
include('../shared/jobs/nin/functions/NIN_BUFFS.lua')     -- Doom, Yonin / Innin / Sange / Issekigan
TIMER('NIN_BUFFS')

-- Utility hooks (LOCKSTYLE / MACROBOOK are lazy: built on first call)
include('../shared/jobs/nin/functions/NIN_LOCKSTYLE.lua')
include('../shared/jobs/nin/functions/NIN_MACROBOOK.lua')
include('../shared/jobs/nin/functions/NIN_COMMANDS.lua')  -- Commands, state change hook
TIMER('NIN_COMMANDS')
include('../shared/jobs/nin/functions/NIN_MOVEMENT.lua')  -- Movement status API
TIMER('NIN_MOVEMENT')

-- Dual-boxing manager (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('NIN', 'All functions loaded successfully')

TIMER('TOTAL NIN_functions', true)

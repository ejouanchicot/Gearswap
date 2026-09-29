---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads the Dragoon hook modules in dependency order and wires them into
---   Mote-Include's globals.
---
---   Architecture:
---   • Hook modules (12 + pet midcast): PRECAST, MIDCAST, PET_MIDCAST,
---     AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS, COMMANDS, MOVEMENT,
---     LOCKSTYLE, MACROBOOK
---   • Logic modules (3, required by the hooks):
---       logic/set_builder.lua  idle / engaged sets: town, HybridMode DT,
---                              wyvern layer, Spirit Surge, weapons, movement
---       logic/wyvern.lua       Healing Breath trigger line by subjob, the
---                              set of each wyvern breath
---       logic/jumps.lua        //gs c jump on a Dragoon main job
---
---   @file    shared/jobs/drg/functions/drg_functions.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('DRG')

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

-- Combat action hooks
include('../shared/jobs/drg/functions/DRG_PRECAST.lua')      -- Guard, cooldown, WS
TIMER('DRG_PRECAST')
include('../shared/jobs/drg/functions/DRG_MIDCAST.lua')      -- Subjob magic via MidcastManager, Healing Breath trigger
TIMER('DRG_MIDCAST')
include('../shared/jobs/drg/functions/DRG_PET_MIDCAST.lua')  -- Wyvern breaths
TIMER('DRG_PET_MIDCAST')
include('../shared/jobs/drg/functions/DRG_AFTERCAST.lua')    -- Watchdog tick
TIMER('DRG_AFTERCAST')

-- Gear selection hooks
include('../shared/jobs/drg/functions/DRG_IDLE.lua')         -- Idle, town, wyvern layer, weapons, movement
TIMER('DRG_IDLE')
include('../shared/jobs/drg/functions/DRG_ENGAGED.lua')      -- OffenseMode, DT, Spirit Surge, weapons
TIMER('DRG_ENGAGED')

-- Event hooks
include('../shared/jobs/drg/functions/DRG_STATUS.lua')       -- Status (LifecycleManager)
TIMER('DRG_STATUS')
include('../shared/jobs/drg/functions/DRG_BUFFS.lua')        -- Doom, Spirit Surge
TIMER('DRG_BUFFS')

-- Utility hooks (LOCKSTYLE / MACROBOOK are lazy: built on first call)
include('../shared/jobs/drg/functions/DRG_LOCKSTYLE.lua')
include('../shared/jobs/drg/functions/DRG_MACROBOOK.lua')
include('../shared/jobs/drg/functions/DRG_COMMANDS.lua')     -- Commands (jump), state change hook
TIMER('DRG_COMMANDS')
include('../shared/jobs/drg/functions/DRG_MOVEMENT.lua')     -- Movement status API
TIMER('DRG_MOVEMENT')

-- Dual-boxing manager (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('DRG', 'All functions loaded successfully')

TIMER('TOTAL DRG_functions', true)

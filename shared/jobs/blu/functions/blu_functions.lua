---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads the Blue Mage hook modules in dependency order and wires them into
---   Mote-Include's globals.
---
---   Architecture:
---   • Hook modules (11): PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS,
---     BUFFS, COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
---   • Logic modules (5, required by the hooks):
---       logic/spell_map.lua       Blue Magic spell -> gear category
---                                 (config/blu/BLU_SPELL_MAP.lua)
---       logic/set_builder.lua     idle / engaged sets, single wield (.SW)
---       logic/unbridled.lua       Unbridled Learning before an unbridled
---                                 spell (option, config/AUTO_ABILITIES.lua)
---       logic/expiacion_guard.lua Expiacion held back under 3000 TP without
---                                 Aftermath Lv.3 (option)
---       logic/azure_sets.lua      AzureSets addon loaded while on BLU
---
---   @file    shared/jobs/blu/functions/blu_functions.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('BLU')

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

-- Combat action hooks
include('../shared/jobs/blu/functions/BLU_PRECAST.lua')   -- Guard, cooldown, Unbridled Learning, Expiacion, WS
TIMER('BLU_PRECAST')
include('../shared/jobs/blu/functions/BLU_MIDCAST.lua')   -- Blue Magic categories via MidcastManager, buff overlays
TIMER('BLU_MIDCAST')
include('../shared/jobs/blu/functions/BLU_AFTERCAST.lua') -- Watchdog tick
TIMER('BLU_AFTERCAST')

-- Gear selection hooks
include('../shared/jobs/blu/functions/BLU_IDLE.lua')      -- IdleMode, town, weapons, movement
TIMER('BLU_IDLE')
include('../shared/jobs/blu/functions/BLU_ENGAGED.lua')   -- OffenseMode, single wield (.SW), weapons
TIMER('BLU_ENGAGED')

-- Event hooks
include('../shared/jobs/blu/functions/BLU_STATUS.lua')    -- Status change (Doom slots)
TIMER('BLU_STATUS')
include('../shared/jobs/blu/functions/BLU_BUFFS.lua')     -- Buff change (Doom)
TIMER('BLU_BUFFS')

-- Utility hooks (LOCKSTYLE / MACROBOOK are lazy: built on first call)
include('../shared/jobs/blu/functions/BLU_LOCKSTYLE.lua')
include('../shared/jobs/blu/functions/BLU_MACROBOOK.lua')
include('../shared/jobs/blu/functions/BLU_COMMANDS.lua')  -- Commands, state change hook
TIMER('BLU_COMMANDS')
include('../shared/jobs/blu/functions/BLU_MOVEMENT.lua')  -- Movement status API
TIMER('BLU_MOVEMENT')

-- Dual-boxing manager (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('BLU', 'All functions loaded successfully')

TIMER('TOTAL BLU_functions', true)

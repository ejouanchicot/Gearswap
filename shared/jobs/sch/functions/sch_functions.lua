---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads the Scholar hook modules in dependency order and wires them into
---   Mote-Include's globals.
---
---   Architecture:
---   • Hook modules (12): PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED,
---     STATUS, BUFFS, COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK (+ facade)
---   • Logic modules (4, required by the hooks):
---       logic/grimoire.lua        Arts in force, grimoire / stratagem layers
---       logic/spell_tiers.lua     tier families for the shared TierRefiner
---       logic/spell_commands.lua  nuke / helix / storm from Element, strat
---       logic/set_builder.lua     idle (Sublimation layer) and engaged sets
---
---   @file    shared/jobs/sch/functions/sch_functions.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('SCH')

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

-- Combat action hooks
include('../shared/jobs/sch/functions/SCH_PRECAST.lua')      -- Guard, tiers / cooldown, charges, WS
TIMER('SCH_PRECAST')
include('../shared/jobs/sch/functions/SCH_MIDCAST.lua')      -- MidcastManager + grimoire layers
TIMER('SCH_MIDCAST')
include('../shared/jobs/sch/functions/SCH_AFTERCAST.lua')    -- Watchdog tick
TIMER('SCH_AFTERCAST')

-- Gear selection hooks
include('../shared/jobs/sch/functions/SCH_IDLE.lua')         -- Town / Hybrid idle, Sublimation, weapons, movement
TIMER('SCH_IDLE')
include('../shared/jobs/sch/functions/SCH_ENGAGED.lua')      -- OffenseMode, DT, weapons
TIMER('SCH_ENGAGED')

-- Event hooks
include('../shared/jobs/sch/functions/SCH_STATUS.lua')       -- Status (Doom, held engage)
TIMER('SCH_STATUS')
include('../shared/jobs/sch/functions/SCH_BUFFS.lua')        -- Doom, Sublimation refresh
TIMER('SCH_BUFFS')

-- Utility hooks (LOCKSTYLE / MACROBOOK are lazy: built on first call)
include('../shared/jobs/sch/functions/SCH_LOCKSTYLE.lua')
include('../shared/jobs/sch/functions/SCH_MACROBOOK.lua')
include('../shared/jobs/sch/functions/SCH_COMMANDS.lua')     -- Commands (arts, nuke, strat), state change hook
TIMER('SCH_COMMANDS')
include('../shared/jobs/sch/functions/SCH_MOVEMENT.lua')     -- Movement status API
TIMER('SCH_MOVEMENT')

-- Dual-boxing manager (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('SCH', 'All functions loaded successfully')

TIMER('TOTAL SCH_functions', true)

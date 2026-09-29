---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads the Ranger hook modules in dependency order and wires them into
---   Mote-Include's globals.
---
---   Architecture:
---   • Hook modules (12): PRECAST, MIDCAST, AFTERCAST, IDLE, ENGAGED, STATUS,
---     BUFFS, COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK (+ this facade)
---   • Logic modules (2, required by the hooks):
---       logic/ranged.lua       ranged attack: Flurry precast groups
---                              (shared FlurryTracker) and the buff layers
---                              laid on the shot (Barrage, Double Shot...)
---       logic/set_builder.lua  idle / engaged sets: HybridMode, town,
---                              Mote layers, weapons (main, sub, range),
---                              movement
---
---   @file    shared/jobs/rng/functions/rng_functions.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('RNG')

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

-- Combat action hooks
include('../shared/jobs/rng/functions/RNG_PRECAST.lua')      -- Guard, cooldown, Flurry, WS
TIMER('RNG_PRECAST')
include('../shared/jobs/rng/functions/RNG_MIDCAST.lua')      -- Ranged attack + subjob magic via MidcastManager
TIMER('RNG_MIDCAST')
include('../shared/jobs/rng/functions/RNG_AFTERCAST.lua')    -- Watchdog tick, ammo container refill
TIMER('RNG_AFTERCAST')

-- Gear selection hooks
include('../shared/jobs/rng/functions/RNG_IDLE.lua')         -- HybridMode idle, town, weapons, movement
TIMER('RNG_IDLE')
include('../shared/jobs/rng/functions/RNG_ENGAGED.lua')      -- OffenseMode, DT, weapons
TIMER('RNG_ENGAGED')

-- Event hooks
include('../shared/jobs/rng/functions/RNG_STATUS.lua')       -- Status change (shared handler)
TIMER('RNG_STATUS')
include('../shared/jobs/rng/functions/RNG_BUFFS.lua')        -- Doom (shared handler)
TIMER('RNG_BUFFS')

-- Utility hooks (LOCKSTYLE / MACROBOOK are lazy: built on first call)
include('../shared/jobs/rng/functions/RNG_LOCKSTYLE.lua')
include('../shared/jobs/rng/functions/RNG_MACROBOOK.lua')
include('../shared/jobs/rng/functions/RNG_COMMANDS.lua')     -- Commands, state change hook
TIMER('RNG_COMMANDS')
include('../shared/jobs/rng/functions/RNG_MOVEMENT.lua')     -- Movement status API
TIMER('RNG_MOVEMENT')

-- Dual-boxing manager (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('RNG', 'All functions loaded successfully')

TIMER('TOTAL RNG_functions', true)

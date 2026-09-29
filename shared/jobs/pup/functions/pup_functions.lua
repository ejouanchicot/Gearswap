---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Functions Facade - Module Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads the Puppetmaster hook modules in dependency order and wires them
---   into Mote-Include's globals.
---
---   Architecture:
---   • Hook modules (12): PRECAST, MIDCAST, PET_MIDCAST, AFTERCAST, IDLE,
---     ENGAGED, STATUS (+ pet change / pet status), BUFFS, COMMANDS,
---     MOVEMENT, LOCKSTYLE, MACROBOOK
---   • Logic modules (3, required by the hooks):
---       logic/automaton.lua    what the automaton is (head / frame ->
---                              PetMode) and does (out, fighting, TP)
---       logic/pet_ws.lua       automaton WS gear due or not, and the 0.5 s
---                              poll that sends gs c update when it flips
---       logic/set_builder.lua  idle / engaged sets: master, town, pet
---                              layers, Overdrive, pet WS, weapon, movement
---
---   @file    shared/jobs/pup/functions/pup_functions.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('PUP')

include('../shared/utils/messages/formatters/magic/message_buffs.lua')  -- Buff gain/loss messages
TIMER('message_buffs')

-- Combat action hooks
include('../shared/jobs/pup/functions/PUP_PRECAST.lua')      -- Guard, cooldown, WS
TIMER('PUP_PRECAST')
include('../shared/jobs/pup/functions/PUP_MIDCAST.lua')      -- Subjob magic via MidcastManager, Maneuver map
TIMER('PUP_MIDCAST')
include('../shared/jobs/pup/functions/PUP_PET_MIDCAST.lua')  -- Automaton weaponskills (spells: Mote)
TIMER('PUP_PET_MIDCAST')
include('../shared/jobs/pup/functions/PUP_AFTERCAST.lua')    -- Watchdog tick
TIMER('PUP_AFTERCAST')

-- Gear selection hooks
include('../shared/jobs/pup/functions/PUP_IDLE.lua')         -- Master / pet idle, town, weapon, movement
TIMER('PUP_IDLE')
include('../shared/jobs/pup/functions/PUP_ENGAGED.lua')      -- OffenseMode, master + pet, DT, weapon
TIMER('PUP_ENGAGED')

-- Event hooks
include('../shared/jobs/pup/functions/PUP_STATUS.lua')       -- Status, pet change, pet status
TIMER('PUP_STATUS')
include('../shared/jobs/pup/functions/PUP_BUFFS.lua')        -- Doom, Overdrive
TIMER('PUP_BUFFS')

-- Utility hooks (LOCKSTYLE / MACROBOOK are lazy: built on first call)
include('../shared/jobs/pup/functions/PUP_LOCKSTYLE.lua')
include('../shared/jobs/pup/functions/PUP_MACROBOOK.lua')
include('../shared/jobs/pup/functions/PUP_COMMANDS.lua')     -- Commands (petmode), state change hook
TIMER('PUP_COMMANDS')
include('../shared/jobs/pup/functions/PUP_MOVEMENT.lua')     -- Movement status API
TIMER('PUP_MOVEMENT')

-- Dual-boxing manager (deferred init + lazy message loading)
require('shared/utils/dualbox/dualbox_manager')

local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('PUP', 'All functions loaded successfully')

TIMER('TOTAL PUP_functions', true)

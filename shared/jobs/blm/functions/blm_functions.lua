---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Functions Module - Facade Loader + Global Function Exports
---  ═══════════════════════════════════════════════════════════════════════════
---   Central loading facade for all BLM job modules.
---   This file includes all specialized BLM modules and makes their functions
---   available to the main job file.
---
---   ADDITIONALLY: Exports key functions globally
---   • BuffSelf() - Automated self-buffing
---   • SaveMP() - MP-based elemental set switch (no caller, see below)
---   • refine_various_spells() - Spell tier downgrading
---   • checkArts() - Scholar subjob Dark Arts automation
---   • CastStorm() - Storm casting with Klimaform
---
---   Architecture:
---   • Hook modules (BLM_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---   • Global exports allow direct function calls in hooks (old system compatibility)
---
---   @file    shared/jobs/blm/functions/blm_functions.lua
---   @author  Tetsouo
---   @version 2.0 (Added facade pattern + global exports)
---   @date    Created: 2025-10-15 | Updated: 2025-10-15
---   @requires All BLM_*.lua modules in functions directory
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 1: PERFORMANCE PROFILER (Load first for timing)
---  ═══════════════════════════════════════════════════════════════════════════
-- TIMER() calls are no-ops unless //gs c perf start
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('BLM')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 2: MESSAGE SYSTEM (Load first for caching by logic modules)
---  ═══════════════════════════════════════════════════════════════════════════
-- Message system (must load first for buff status display)

include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

-- MessageFormatter lazy loaded (only needed for error messages in checkArts)
local MessageFormatter = nil

---   Ensure MessageFormatter is loaded (for error messages)
local function ensure_message_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 3: LOGIC MODULES (Lazy Loading - loaded on first use)
---  ═══════════════════════════════════════════════════════════════════════════

-- Logic modules loaded on demand (performance optimization)
local BuffManager = nil
local SetBuilder = nil
local SpellRefiner = nil
local StormManager = nil

---   Ensure BuffManager is loaded
local function ensure_buff_manager()
    if not BuffManager then
        BuffManager = require('shared/jobs/blm/functions/logic/buff_manager')
    end
end

---   Ensure SetBuilder is loaded
local function ensure_set_builder()
    if not SetBuilder then
        SetBuilder = require('shared/jobs/blm/functions/logic/set_builder')
    end
end

---   Ensure SpellRefiner is loaded
local function ensure_spell_refiner()
    if not SpellRefiner then
        SpellRefiner = require('shared/jobs/blm/functions/logic/spell_refiner')
    end
end

---   Ensure StormManager is loaded
local function ensure_storm_manager()
    if not StormManager then
        StormManager = require('shared/jobs/blm/functions/logic/storm_manager')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 4: COMBAT ACTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/blm/functions/BLM_PRECAST.lua')
TIMER('BLM_PRECAST')
include('../shared/jobs/blm/functions/BLM_MIDCAST.lua')
TIMER('BLM_MIDCAST')
include('../shared/jobs/blm/functions/BLM_AFTERCAST.lua')
TIMER('BLM_AFTERCAST')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 5: GEAR SELECTION HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/blm/functions/BLM_IDLE.lua')
TIMER('BLM_IDLE')
include('../shared/jobs/blm/functions/BLM_ENGAGED.lua')
TIMER('BLM_ENGAGED')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 6: EVENT MONITORING HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

include('../shared/jobs/blm/functions/BLM_STATUS.lua')
TIMER('BLM_STATUS')
include('../shared/jobs/blm/functions/BLM_BUFFS.lua')
TIMER('BLM_BUFFS')

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 7: UTILITY HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/blm/functions/BLM_LOCKSTYLE.lua')
include('../shared/jobs/blm/functions/BLM_MACROBOOK.lua')
include('../shared/jobs/blm/functions/BLM_COMMANDS.lua')
TIMER('BLM_COMMANDS')
include('../shared/jobs/blm/functions/BLM_MOVEMENT.lua')
TIMER('BLM_MOVEMENT')

---  ═══════════════════════════════════════════════════════════════════════════
---   LOGIC MODULES REFERENCE (Lazy Loaded - loaded on first use)
---  ═══════════════════════════════════════════════════════════════════════════
---   The following business logic modules use lazy loading for performance:
---
---   logic/buff_manager.lua (loaded on first BuffSelf() call)
---     • Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
---   logic/set_builder.lua (required by BLM_IDLE / BLM_ENGAGED for the idle and
---     engaged builders; loaded here only by SaveMP())
---     • Engaged set construction (weapons)
---     • Idle set construction (town, weapons, movement, Mana Wall)
---   logic/spell_refiner.lua (loaded on first spell cast with refinement)
---     • Spell tier downgrading (Fire VI >> V >> IV >> III >> II >> I)
---   logic/storm_manager.lua (loaded on first CastStorm() call)
---     • Automated storm casting with Klimaform
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 8: GLOBAL FUNCTION EXPORTS (FACADE PATTERN)
---  ═══════════════════════════════════════════════════════════════════════════
---   These functions are exported globally to maintain compatibility with
---   old system where functions are called directly in hooks (not via require)
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   BuffSelf - Automated Self-Buffing
---  ═══════════════════════════════════════════════════════════════════════════
---   Casts Stoneskin, Blink, Aquaveil, Ice Spikes when missing, skipping the
---   ones the job/subjob cannot cast and the ones still on recast
---   @return boolean True when casts were queued or a status was displayed
---   @usage BuffSelf()
function BuffSelf()
    ensure_buff_manager()
    return BuffManager.BuffSelf()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SaveMP - MP Conservation Gear Switching
---  ═══════════════════════════════════════════════════════════════════════════
---   Writes an MP-based set (global blm_dynamic_sets, threshold 1000 MP) into
---   sets.midcast['Elemental Magic'] or its .MagicBurst entry. No sets file
---   defines blm_dynamic_sets, so the current set is written back onto itself,
---   and nothing in the project calls SaveMP().
---   @usage SaveMP()
function SaveMP()
    ensure_set_builder()
    return SetBuilder.SaveMP()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   refine_various_spells - Spell Tier Downgrading
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically downgrades spell tiers based on recast and MP availability
---   Example: Fire VI >> Fire V >> Fire IV >> Fire III >> Fire II >> Fire I
---   Also handles -ja spells (Firaja >> Firaga III) and Breakga >> Break
---   @param spell table The spell being cast
---   @param eventArgs table Event arguments (can set eventArgs.cancel = true)
---   @return any Result of SpellRefiner.refine_various_spells
---   @usage refine_various_spells(spell, eventArgs)
function refine_various_spells(spell, eventArgs)
    ensure_spell_refiner()
    return SpellRefiner.refine_various_spells(spell, eventArgs)
end

--- Reject a malformed call, saying which part is wrong.
--- @return boolean True when the arguments are usable
local function arts_args_valid(spell, eventArgs)
    local problem
    if type(spell) ~= 'table' then
        problem = 'spell must be a table'
    elseif type(eventArgs) ~= 'table' then
        problem = 'eventArgs must be a table'
    elseif not spell.name then
        problem = 'spell.name missing'
    end

    if problem then
        ensure_message_formatter()
        MessageFormatter.show_error('checkArts - ' .. problem)
        return false
    end
    return true
end

--- Is Dark Arts available to this character right now?
---
--- Sub-job level 0 is a real state, not a mistake: Odyssey Sheol Gaol locks
--- subjobs, and the ability is gone there even though the subjob still reads
--- as SCH.
--- @return boolean
local function dark_arts_ready()
    if not player or player.sub_job ~= 'SCH' or player.sub_job_level == 0 then
        return false
    end

    local res_success, res = pcall(require, 'resources')
    if not res_success or not res then
        return false
    end

    local ability_recasts = windower.ffxi.get_ability_recasts()
    if not ability_recasts then
        return false
    end

    local dark_arts_data = res.job_abilities:with('en', 'Dark Arts')
    local dark_arts_id = dark_arts_data and dark_arts_data.recast_id or 232

    -- 99999 rather than 0 when the id is unknown: an unknown recast must read
    -- as "not ready", never as "off cooldown".
    return (ability_recasts[dark_arts_id] or 99999) < 1
end

--- Is Dark Arts already up?
---
--- Addendum: Black counts. It replaces Dark Arts in buffactive rather than
--- sitting alongside it, so checking only 'Dark Arts' would re-cast over an
--- Addendum that is already active.
--- @return boolean
local function dark_arts_active()
    return buffactive ~= nil
        and (buffactive['Dark Arts'] or buffactive['Addendum: Black']) ~= nil
end

---   Put Dark Arts up before an elemental nuke, on BLM/SCH.
---   @param spell table Spell information from GearSwap
---   @param eventArgs table Event arguments
function checkArts(spell, eventArgs)
    if not arts_args_valid(spell, eventArgs) then
        return
    end

    if spell.skill ~= 'Elemental Magic' then
        return
    end

    if dark_arts_active() or not dark_arts_ready() then
        return
    end

    -- Two seconds between attempts. The buff takes a moment to register, and
    -- without this a second nuke sent in that window cancels itself and queues
    -- Dark Arts again on top of the first.
    local currentTime = os.clock()
    _G.BLM_ARTS_LAST_CAST = _G.BLM_ARTS_LAST_CAST or 0
    if currentTime - _G.BLM_ARTS_LAST_CAST < 2.0 then
        return
    end

    cancel_spell()
    -- cancel_spell() has already killed the cast, so the follow-up is the only
    -- thing that will send it - it goes out with or without the Arts.
    local AbilityHelper = require('shared/utils/precast/ability_helper')
    send_command('input /ja "Dark Arts" <me>')
    AbilityHelper.follow_up('Dark Arts', 'input /ma "' .. spell.name .. '" <t>', 2)
    _G.BLM_ARTS_LAST_CAST = currentTime
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CastStorm - Automated Storm Casting with Klimaform
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically casts Klimaform before Storm if needed
---   If Klimaform already active, casts Storm only
---   If spells on cooldown, displays recast information
---   @param storm_name string Name of the storm spell (e.g., "Firestorm")
---   @return any Result of StormManager.cast_storm_with_klimaform
---   @usage CastStorm("Firestorm")
function CastStorm(storm_name)
    ensure_storm_manager()
    return StormManager.cast_storm_with_klimaform(storm_name)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT TO GLOBAL SCOPE
---  ═══════════════════════════════════════════════════════════════════════════
---   These exports allow functions to be called directly in hooks
---   (like old system: refine_various_spells(spell, eventArgs))
---  ═══════════════════════════════════════════════════════════════════════════

_G.BuffSelf = BuffSelf
_G.SaveMP = SaveMP
_G.refine_various_spells = refine_various_spells
_G.checkArts = checkArts
_G.CastStorm = CastStorm

---  ═══════════════════════════════════════════════════════════════════════════
---   SECTION 9: DUAL-BOXING SYSTEM
---  ═══════════════════════════════════════════════════════════════════════════

-- Load dual-boxing manager (auto-initializes and handles ALT<>>MAIN communication)
-- Uses deferred initialization (2s delay) and lazy message loading
local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION COMPLETE
---  ═══════════════════════════════════════════════════════════════════════════

-- All hook functions loaded, logic modules will load on demand
local MessageFormatter = require('shared/utils/messages/message_formatter')
MessageFormatter.show_debug('BLM', 'Hook functions loaded (11 hooks + 5 global exports with lazy loading)')

TIMER('TOTAL BLM_functions', true)

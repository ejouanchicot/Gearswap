---============================================================================
--- BLM Functions Module - Facade Loader + Global Function Exports
---============================================================================
--- Central loading facade for all BLM job modules.
--- This file includes all specialized BLM modules and makes their functions
--- available to the main job file.
---
--- ADDITIONALLY: Exports key functions globally (like old BLM_FUNCTION.lua)
---   • BuffSelf() - Automated self-buffing
---   • SaveMP() - MP conservation gear switching
---   • refine_various_spells() - Spell tier downgrading
---   • checkArts() - Scholar subjob Dark Arts automation
---
--- Architecture:
---   • Hook modules (BLM_*.lua) provide GearSwap event handlers
---   • Logic modules (logic/*.lua) contain business logic, loaded via require()
---   • Global exports allow direct function calls in hooks (old system compatibility)
---
--- @file    blm_functions.lua
--- @author  Tetsouo
--- @version 2.0 (Added facade pattern + global exports)
--- @date    Created: 2025-10-15 | Updated: 2025-10-15
--- @requires All BLM_*.lua modules in functions directory
---============================================================================

---============================================================================
--- SECTION 1: PERFORMANCE PROFILER (Load first for timing)
---============================================================================
-- ═══════════════════════════════════════════════════════════════════
-- PERFORMANCE PROFILING (Toggle with: //gs c perf start)
-- ═══════════════════════════════════════════════════════════════════
local Profiler = require('shared/utils/debug/performance_profiler')
local TIMER = Profiler.create_timer('BLM')
-- ═══════════════════════════════════════════════════════════════════

---============================================================================
--- SECTION 2: MESSAGE SYSTEM (Load first for caching by logic modules)
---============================================================================
-- Message system (must load first for buff status display)

include('../shared/utils/messages/formatters/magic/message_buffs.lua')
TIMER('message_buffs')

-- MessageFormatter lazy loaded (only needed for error messages in checkArts)
local MessageFormatter = nil

--- Ensure MessageFormatter is loaded (for error messages)
local function ensure_message_formatter()
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end
end

---============================================================================
--- SECTION 3: LOGIC MODULES (Lazy Loading - loaded on first use)
---============================================================================

-- Logic modules loaded on demand (performance optimization)
local BuffManager = nil
local SetBuilder = nil
local SpellRefiner = nil
local StormManager = nil

--- Ensure BuffManager is loaded
local function ensure_buff_manager()
    if not BuffManager then
        BuffManager = require('shared/jobs/blm/functions/logic/buff_manager')
    end
end

--- Ensure SetBuilder is loaded
local function ensure_set_builder()
    if not SetBuilder then
        SetBuilder = require('shared/jobs/blm/functions/logic/set_builder')
    end
end

--- Ensure SpellRefiner is loaded
local function ensure_spell_refiner()
    if not SpellRefiner then
        SpellRefiner = require('shared/jobs/blm/functions/logic/spell_refiner')
    end
end

--- Ensure StormManager is loaded
local function ensure_storm_manager()
    if not StormManager then
        StormManager = require('shared/jobs/blm/functions/logic/storm_manager')
    end
end

---============================================================================
--- SECTION 4: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_PRECAST.lua')
TIMER('BLM_PRECAST')
include('../shared/jobs/blm/functions/BLM_MIDCAST.lua')
TIMER('BLM_MIDCAST')
include('../shared/jobs/blm/functions/BLM_AFTERCAST.lua')
TIMER('BLM_AFTERCAST')

---============================================================================
--- SECTION 5: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_IDLE.lua')
TIMER('BLM_IDLE')
include('../shared/jobs/blm/functions/BLM_ENGAGED.lua')
TIMER('BLM_ENGAGED')

---============================================================================
--- SECTION 6: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_STATUS.lua')
TIMER('BLM_STATUS')
include('../shared/jobs/blm/functions/BLM_BUFFS.lua')
TIMER('BLM_BUFFS')

---============================================================================
--- SECTION 7: UTILITY HOOKS
---============================================================================

-- LOCKSTYLE and MACROBOOK use lazy loading - loaded on first call, not during startup
include('../shared/jobs/blm/functions/BLM_LOCKSTYLE.lua')
include('../shared/jobs/blm/functions/BLM_MACROBOOK.lua')
include('../shared/jobs/blm/functions/BLM_COMMANDS.lua')
TIMER('BLM_COMMANDS')
include('../shared/jobs/blm/functions/BLM_MOVEMENT.lua')
TIMER('BLM_MOVEMENT')

---============================================================================
--- LOGIC MODULES REFERENCE (Lazy Loaded - loaded on first use)
---============================================================================
--- The following business logic modules use lazy loading for performance:
---
---   logic/buff_manager.lua (loaded on first BuffSelf() call)
---     • Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
---   logic/set_builder.lua (loaded on first SaveMP() call)
---     • MP conservation gear switching
---     • Shared engaged set construction
---     • Shared idle set construction
---   logic/spell_refiner.lua (loaded on first spell cast with refinement)
---     • Spell tier downgrading (Fire VI >> V >> IV >> III >> II >> I)
---   logic/storm_manager.lua (loaded on first CastStorm() call)
---     • Automated storm casting with Klimaform
---============================================================================

---============================================================================
--- SECTION 8: GLOBAL FUNCTION EXPORTS (FACADE PATTERN)
---============================================================================
--- These functions are exported globally to maintain compatibility with
--- old system where functions are called directly in hooks (not via require)
---============================================================================

---============================================================================
--- BuffSelf - Automated Self-Buffing
---============================================================================
--- Automatically casts Stoneskin, Blink, Aquaveil, Ice Spikes if not active
--- Includes anti-spam protection and recast checking
--- @usage BuffSelf()
function BuffSelf()
    ensure_buff_manager()
    return BuffManager.BuffSelf()
end

---============================================================================
--- SaveMP - MP Conservation Gear Switching
---============================================================================
--- Dynamically switches elemental magic gear based on current MP
--- Low MP (< 1000): Conservation gear (max Refresh)
--- High MP (>= 1000): Full potency gear (max MAB)
--- @usage SaveMP()
function SaveMP()
    ensure_set_builder()
    return SetBuilder.SaveMP()
end

---============================================================================
--- refine_various_spells - Spell Tier Downgrading
---============================================================================
--- Automatically downgrades spell tiers based on recast and MP availability
--- Example: Fire VI >> Fire V >> Fire IV >> Fire III >> Fire II >> Fire I
--- Also handles -ja spells (Firaja >> Firaga III) and Breakga >> Break
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments (can set eventArgs.cancel = true)
--- @usage refine_various_spells(spell, eventArgs)
function refine_various_spells(spell, eventArgs)
    ensure_spell_refiner()
    return SpellRefiner.refine_various_spells(spell, eventArgs)
end

---============================================================================
--- checkArts - Scholar Subjob Dark Arts Automation
---============================================================================
--- Automatically activates Dark Arts when casting Elemental Magic
--- Only for BLM/SCH subjob combination
--- Includes lag compensation to prevent Dark Arts spam
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments
--- @usage checkArts(spell, eventArgs)
function checkArts(spell, eventArgs)
    -- Check if parameters are tables
    if type(spell) ~= 'table' then
        ensure_message_formatter()
        MessageFormatter.show_error('checkArts - spell must be a table')
        return
    end

    if type(eventArgs) ~= 'table' then
        ensure_message_formatter()
        MessageFormatter.show_error('checkArts - eventArgs must be a table')
        return
    end

    -- Check if spell has required keys
    if not spell.name then
        ensure_message_formatter()
        MessageFormatter.show_error('checkArts - spell.name missing')
        return
    end

    -- Check if player's sub-job is Scholar (SCH)
    if not player or player.sub_job ~= 'SCH' or player.sub_job_level == 0 then
        return
    end

    -- Get resources for Dark Arts ID
    local res_success, res = pcall(require, 'resources')
    if not res_success or not res then
        return
    end

    -- Get Dark Arts recast ID
    local dark_arts_data = res.job_abilities:with('en', 'Dark Arts')
    local dark_arts_id = dark_arts_data and dark_arts_data.recast_id or 232
    local ability_recasts = windower.ffxi.get_ability_recasts()

    if not ability_recasts then
        return
    end

    local darkArtsRecast = ability_recasts[dark_arts_id] or 99999

    -- Check conditions for Dark Arts activation
    if spell.skill == 'Elemental Magic' and
        not (buffactive and (buffactive['Dark Arts'] or buffactive['Addendum: Black'])) and
        darkArtsRecast < 1 then

        -- LAG COMPENSATION: Simple timestamp check (2s cooldown)
        local currentTime = os.clock()
        _G.BLM_ARTS_LAST_CAST = _G.BLM_ARTS_LAST_CAST or 0

        if currentTime - _G.BLM_ARTS_LAST_CAST >= 2.0 then
            -- Cancel current spell
            cancel_spell()

            -- Activate Dark Arts and recast spell after 2s
            send_command('input /ja "Dark Arts" <me>; wait 2; input /ma "' .. spell.name .. '" <t>')

            -- Update timestamp
            _G.BLM_ARTS_LAST_CAST = currentTime

            -- NOTE: Message disabled - Job Ability message will show automatically
            -- MessageFormatter.show_dark_arts_activated(spell.name)
        end
    end
end

---============================================================================
--- CastStorm - Automated Storm Casting with Klimaform
---============================================================================
--- Automatically casts Klimaform before Storm if needed
--- If Klimaform already active, casts Storm only
--- If spells on cooldown, displays recast information
--- @param storm_name string Name of the storm spell (e.g., "Firestorm")
--- @usage CastStorm("Firestorm")
function CastStorm(storm_name)
    ensure_storm_manager()
    return StormManager.cast_storm_with_klimaform(storm_name)
end

---============================================================================
--- EXPORT TO GLOBAL SCOPE
---============================================================================
--- These exports allow functions to be called directly in hooks
--- (like old system: refine_various_spells(spell, eventArgs))
---============================================================================

_G.BuffSelf = BuffSelf
_G.SaveMP = SaveMP
_G.refine_various_spells = refine_various_spells
_G.checkArts = checkArts
_G.CastStorm = CastStorm

---============================================================================
--- SECTION 9: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (auto-initializes and handles ALT<>>MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All hook functions loaded, logic modules will load on demand
print('[BLM] Hook functions loaded (11 hooks + 5 global exports with lazy loading)')

-- ═══════════════════════════════════════════════════════════════════
TIMER('TOTAL BLM_functions', true)
-- ═══════════════════════════════════════════════════════════════════

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
--- SECTION 1: LOAD LOGIC MODULES (for facade delegation)
---============================================================================

-- Load logic modules that contain the actual implementation
local BuffManager = require('shared/jobs/blm/functions/logic/buff_manager')
local SetBuilder = require('shared/jobs/blm/functions/logic/set_builder')
local SpellRefiner = require('shared/jobs/blm/functions/logic/spell_refiner')
local StormManager = require('shared/jobs/blm/functions/logic/storm_manager')

---============================================================================
--- SECTION 2: MESSAGE SYSTEM
---============================================================================
-- Message system (must load first for buff status display)
include('../shared/utils/messages/formatters/magic/message_buffs.lua')

-- Load MessageFormatter for standardized messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- SECTION 2: COMBAT ACTION HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_PRECAST.lua')
include('../shared/jobs/blm/functions/BLM_MIDCAST.lua')
include('../shared/jobs/blm/functions/BLM_AFTERCAST.lua')

---============================================================================
--- SECTION 3: GEAR SELECTION HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_IDLE.lua')
include('../shared/jobs/blm/functions/BLM_ENGAGED.lua')

---============================================================================
--- SECTION 4: EVENT MONITORING HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_STATUS.lua')
include('../shared/jobs/blm/functions/BLM_BUFFS.lua')

---============================================================================
--- SECTION 5: UTILITY HOOKS
---============================================================================

include('../shared/jobs/blm/functions/BLM_LOCKSTYLE.lua')
include('../shared/jobs/blm/functions/BLM_MACROBOOK.lua')
include('../shared/jobs/blm/functions/BLM_COMMANDS.lua')
include('../shared/jobs/blm/functions/BLM_MOVEMENT.lua')

---============================================================================
--- LOGIC MODULES REFERENCE
---============================================================================
--- The following business logic modules are loaded via require() in hooks:
---
---   logic/buff_manager.lua
---     • Automated self-buffing (Stoneskin, Blink, Aquaveil, Ice Spikes)
---   logic/set_builder.lua
---     • MP conservation gear switching
---     • Shared engaged set construction
---     • Shared idle set construction
---   logic/spell_refiner.lua
---     • Spell tier downgrading (Fire VI → V → IV → III → II → I)
---============================================================================

---============================================================================
--- SECTION 6: GLOBAL FUNCTION EXPORTS (FACADE PATTERN)
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
    if BuffManager then
        return BuffManager.BuffSelf()
    else
        MessageFormatter.show_error('BuffManager not loaded')
    end
end

---============================================================================
--- SaveMP - MP Conservation Gear Switching
---============================================================================
--- Dynamically switches elemental magic gear based on current MP
--- Low MP (< 1000): Conservation gear (max Refresh)
--- High MP (>= 1000): Full potency gear (max MAB)
--- @usage SaveMP()
function SaveMP()
    if SetBuilder then
        return SetBuilder.SaveMP()
    else
        MessageFormatter.show_error('SetBuilder not loaded')
    end
end

---============================================================================
--- refine_various_spells - Spell Tier Downgrading
---============================================================================
--- Automatically downgrades spell tiers based on recast and MP availability
--- Example: Fire VI → Fire V → Fire IV → Fire III → Fire II → Fire I
--- Also handles -ja spells (Firaja → Firaga III) and Breakga → Break
--- @param spell table The spell being cast
--- @param eventArgs table Event arguments (can set eventArgs.cancel = true)
--- @usage refine_various_spells(spell, eventArgs)
function refine_various_spells(spell, eventArgs)
    if SpellRefiner then
        return SpellRefiner.refine_various_spells(spell, eventArgs)
    else
        MessageFormatter.show_error('SpellRefiner not loaded')
    end
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
        MessageFormatter.show_error('checkArts - spell must be a table')
        return
    end

    if type(eventArgs) ~= 'table' then
        MessageFormatter.show_error('checkArts - eventArgs must be a table')
        return
    end

    -- Check if spell has required keys
    if not spell.name then
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
    if StormManager then
        return StormManager.cast_storm_with_klimaform(storm_name)
    else
        MessageFormatter.show_error('StormManager not loaded')
    end
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
--- SECTION 6: DUAL-BOXING SYSTEM
---============================================================================

-- Load dual-boxing manager (auto-initializes and handles ALT<->MAIN communication)
local DualBoxManager = require('../shared/utils/dualbox/dualbox_manager')

---============================================================================
--- INITIALIZATION COMPLETE
---============================================================================

-- All module functions are now available in global scope
print('[BLM] All functions loaded (11 hooks + 4 logic modules + 5 global exports)')

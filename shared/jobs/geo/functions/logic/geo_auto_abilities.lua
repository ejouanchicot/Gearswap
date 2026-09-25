---============================================================================
--- GEO Auto Abilities - Entrust before an ally's Indi-, Full Circle before a Geo-
---============================================================================
--- Both off unless <Character>/config/AUTO_ABILITIES.lua turns them on
--- (shared/utils/core/auto_options.lua):
---   geo_entrust      an Indi- aimed at a party member (not self) cancels,
---                    fires Entrust, then recasts once Entrust is up
---                    (AbilityHelper.try_ability);
---   geo_full_circle  a Geo- cast while a luopan is out cancels, fires Full
---                    Circle, then recasts after the ability delay. Full Circle
---                    gives no buff to wait on; a spell sent sooner is refused.
---
--- @file    shared/jobs/geo/functions/logic/geo_auto_abilities.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local GeoAutoAbilities = {}

local AutoOptions = require('shared/utils/core/auto_options')
local AbilityHelper = require('shared/utils/precast/ability_helper')

-- Same delay as //gs c escort: a spell right after a job ability is refused
local FULL_CIRCLE_DELAY = 2
-- The recast of the Geo- must not trigger Full Circle a second time
local REPLAY_WINDOW = 5

--- A party member other than this character.
--- @param target table spell.target
--- @return boolean
local function is_ally(target)
    if not target or target.type == 'SELF' then return false end
    return (target.type == 'PLAYER' or target.type == 'NPC') and target.in_party == true
end

local function starts_with(text, prefix)
    return type(text) == 'string' and text:sub(1, #prefix) == prefix
end

--- Full Circle first when a luopan is out.
--- @return boolean True when the spell was cancelled for it
local function full_circle_first(spell, eventArgs)
    if not (pet and pet.isvalid) then return false end
    local replay = windower._geo_full_circle_replay
    if replay and replay.spell == spell.english and os.clock() < replay.expires then
        windower._geo_full_circle_replay = nil
        return false
    end
    if not AbilityHelper.is_ability_ready('Full Circle') then return false end
    eventArgs.cancel = true
    send_command('input /ja "Full Circle" <me>')
    local cast = ('input /ma "%s" %s'):format(spell.english, spell.target.id)
    windower._geo_full_circle_replay = {spell = spell.english, expires = os.clock() + REPLAY_WINDOW}
    coroutine.schedule(function() send_command(cast) end, FULL_CIRCLE_DELAY)
    return true
end

--- Run the options that apply to this spell.
--- @param spell table Spell object from GearSwap
--- @param eventArgs table Event args (cancel / handled set when one fires)
function GeoAutoAbilities.apply(spell, eventArgs)
    if spell.skill ~= 'Geomancy' then return end
    if starts_with(spell.english, 'Indi-') and is_ally(spell.target)
        and AutoOptions.on('geo_entrust') then
        AbilityHelper.try_ability(spell, eventArgs, 'Entrust', 1.5)
    elseif starts_with(spell.english, 'Geo-') and AutoOptions.on('geo_full_circle') then
        full_circle_first(spell, eventArgs)
    end
end

return GeoAutoAbilities

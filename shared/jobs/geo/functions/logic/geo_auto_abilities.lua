---============================================================================
--- GEO Auto Abilities - Entrust before an ally's Indi-, Full Circle before a Geo-
---============================================================================
--- Both off unless <Character>/geo/combat/GEO_CONFIG.lua turns them on
--- (shared/utils/core/auto_options.lua):
---   geo_entrust      an Indi- aimed at a party member (not self) cancels,
---                    fires Entrust, then recasts once Entrust is up
---                    (AbilityHelper.try_ability);
---   geo_full_circle  a Geo- cast while a luopan is out cancels, fires Full
---                    Circle, then recasts after the ability delay. Full Circle
---                    gives no buff to wait on; a spell sent sooner is refused.
---                    Not while //gs c behind is on (Aminon). For a bot's pull
---                    bubble (a Silmaril trigger), it clears a luopan left from
---                    before: the trigger's spell then goes, and the trigger is
---                    done instead of being refused again and again (2026-11-13).
---
---   widened_compass_on  a list of monster names (GEO_CONFIG, {} = off): a Geo-
---                    cast on one of them while Widened Compass is ready and
---                    not up cancels, fires Widened Compass, then recasts the
---                    Geo- once its buff is up (AbilityHelper.try_ability_smart
---                    waits on the buff). Silmaril never fires Widened Compass
---                    (the box exists in its profile, its code never uses it);
---                    the player did it by hand on Aita (2026-11-13: "Widened
---                    Compass before the Geo-Gravity, then the normal fight").
---
--- @file    shared/jobs/geo/functions/logic/geo_auto_abilities.lua
--- @author  ejouanchicot
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
    -- standing behind the monster (Aminon): its lock-on script sends the Geo- again every few seconds while the
    -- bubble is up; dismissing it each time would lose the bubble (luopan_behind.lua cancels those instead)
    local ok, behind = pcall(function() return require('shared/jobs/geo/functions/logic/luopan_behind').behind_on() end)
    if ok and behind then return false end
    local replay = windower._geo_full_circle_replay
    if replay and replay.spell == spell.english and os.clock() < replay.expires then
        windower._geo_full_circle_replay = nil
        return false
    end
    local Queue = AbilityHelper.queue()
    -- a Full Circle already waiting in the ability queue (Bolster came): that one goes, the bot casts again after
    if Queue.queued('Full Circle') then
        eventArgs.cancel = true
        return true
    end
    if not AbilityHelper.is_ability_ready('Full Circle') then return false end
    eventArgs.cancel = true
    send_command('input /ja "Full Circle" <me>')
    Queue.sent_outside('Full Circle')
    local cast = ('input /ma "%s" %s'):format(spell.english, spell.target.id)
    windower._geo_full_circle_replay = {spell = spell.english, expires = os.clock() + REPLAY_WINDOW}
    coroutine.schedule(function()
        Queue.allow_next(spell.english)
        send_command(cast)
    end, FULL_CIRCLE_DELAY)
    return true
end

--- The monsters Widened Compass goes before a Geo- on, from GEO_CONFIG (lower-case set), nil when none.
--- @return table|nil
function GeoAutoAbilities.compass_mobs()
    local ok, list = pcall(function() return require('shared/utils/core/job_config').get('GEO', 'widened_compass_on', {}) end)
    if not (ok and type(list) == 'table' and #list > 0) then return nil end
    local set = {}
    for _, name in ipairs(list) do set[tostring(name):lower()] = true end
    return set
end

--- Seconds after Widened Compass during which any other Geo- is cancelled: only this module's recast goes. The bot
--- (Silmaril's Geomancy page) sends the Geo- again while it waits; that one went, then this recast found a luopan
--- out and auto Full Circle threw the fresh Blaze of Glory bubble away (pre-run review 2026-11-13).
local COMPASS_GUARD = 6
-- the recast's own wait: Widened Compass's buff, at most this many seconds (AbilityHelper.follow_up)
local COMPASS_WAIT = 1.5

--- Widened Compass first when this Geo- goes on one of the listed monsters.
--- @return boolean True when the Geo- was cancelled (it comes again once the buff is up)
local function compass_first(spell, eventArgs)
    local mobs = GeoAutoAbilities.compass_mobs()
    local target = spell.target
    if not (mobs and target and type(target.name) == 'string' and mobs[target.name:lower()]) then return false end
    local wait = windower._geo_compass_wait
    if wait and os.clock() < wait.expires then
        if wait.replay then
            wait.replay = false       -- this is the recast sent below: it goes, the next ones are dropped
            return false
        end
        eventArgs.cancel = true       -- the bot's own Geo- during the wait
        return true
    end
    if AbilityHelper.is_buff_active('Widened Compass') or not AbilityHelper.is_ability_ready('Widened Compass') then
        return false
    end
    eventArgs.cancel = true
    send_command('input /ja "Widened Compass" <me>')
    AbilityHelper.queue().sent_outside('Widened Compass')
    local state = {expires = os.clock() + COMPASS_GUARD, replay = false}
    windower._geo_compass_wait = state
    local cast = ('input /ma "%s" %s'):format(spell.english, target.id)
    AbilityHelper.follow_up('Widened Compass', function()
        if windower._geo_compass_wait ~= state then return end
        state.replay = true
        state.expires = os.clock() + COMPASS_GUARD
        AbilityHelper.queue().allow_next(spell.english)
        send_command(cast)
    end, COMPASS_WAIT)
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
    elseif starts_with(spell.english, 'Geo-') then
        if compass_first(spell, eventArgs) then return end
        if AutoOptions.on('geo_full_circle') then full_circle_first(spell, eventArgs) end
    end
end

return GeoAutoAbilities

---============================================================================
--- GEO Bolster Follow - Blaze of Glory under Bolster, Ecliptic Attrition after
---============================================================================
--- Off unless <Character>/geo/combat/GEO_CONFIG.lua sets `bolster_follow = true`.
---
--- Silmaril never uses Blaze of Glory or Ecliptic Attrition while Bolster is up
--- (13 Bolsters out of 13 in the Sortie logs, 2026-09-24 to 2026-10-16), so a
--- luopan placed under Bolster lost both once Bolster wore off. BG-Wiki (Bolster,
--- Blaze of Glory): Blaze of Glory can be used under Bolster, its potency does not
--- stack with Bolster's but stays on the luopan once Bolster ends; Ecliptic
--- Attrition cannot be used under Bolster.
---   Bolster gained, no luopan out  -> Blaze of Glory: the next Geo- (the bot's)
---                                     goes out with it
---   Bolster lost, luopan out       -> placed with Blaze of Glory: Ecliptic
---                                     Attrition on it; placed without: Full
---                                     Circle, the bot places it again with
---                                     Blaze of Glory and Ecliptic Attrition
--- Each step is tried again a few times: a job ability sent during the bot's
--- cast is refused.
---
--- @file    shared/jobs/geo/functions/logic/bolster_follow.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-17
---============================================================================

local BolsterFollow = {}

local AbilityHelper = require('shared/utils/precast/ability_helper')

local FIRST_DELAY = 1.5   -- after the Bolster event: the job ability delay of Bolster itself
local RETRY_DELAY = 2
local TRIES = 3

local function enabled()
    return require('shared/utils/core/job_config').get('GEO', 'bolster_follow', false) == true
end

--- Read from the game: the steps run in coroutines, where GearSwap's `pet` and
--- `buffactive` may not have caught up yet.
local function luopan_out()
    local mob = windower.ffxi.get_mob_by_target('pet')
    return mob ~= nil and mob.name == 'Luopan' and mob.hpp > 0
end

local function bolster_up()
    return AbilityHelper.is_buff_active('Bolster')
end

--- Kept on `windower`: a GearSwap reload between the Geo- and the end of Bolster
--- (3 minutes) must not forget how the luopan was placed.
local function placed_with_bog() return windower._geo_luopan_bog == true end

--- A step sent until `done()` says it went through or `wanted()` stops holding.
--- A newer Bolster event (seq) drops the older one's remaining tries.
local function try_step(seq, ability, wanted, done, tries_left)
    if windower._geo_bolster_seq ~= seq or not wanted() or done() then return end
    if AbilityHelper.is_ability_ready(ability) then
        send_command('input /ja "' .. ability .. '" <me>')
    end
    if tries_left > 1 then
        coroutine.schedule(function() try_step(seq, ability, wanted, done, tries_left - 1) end, RETRY_DELAY)
    end
end

local function start(ability, wanted, done)
    local seq = (windower._geo_bolster_seq or 0) + 1
    windower._geo_bolster_seq = seq
    coroutine.schedule(function() try_step(seq, ability, wanted, done, TRIES) end, FIRST_DELAY)
end

local function on_bolster_gained()
    start('Blaze of Glory',
        function() return bolster_up() and not luopan_out() end,
        function() return AbilityHelper.is_buff_active('Blaze of Glory') end)
end

local function on_bolster_lost()
    if not luopan_out() then return end
    if placed_with_bog() then
        start('Ecliptic Attrition',
            function() return luopan_out() and not bolster_up() end,
            function() return not AbilityHelper.is_ability_ready('Ecliptic Attrition') end)
    else
        start('Full Circle', luopan_out, function() return not luopan_out() end)
    end
end

--- A Geo- about to go out: remember whether Blaze of Glory goes with it.
--- @param spell table GearSwap spell (precast, not cancelled)
function BolsterFollow.note_cast(spell)
    if spell.skill == 'Geomancy' and spell.english:sub(1, 4) == 'Geo-' then
        windower._geo_luopan_bog = buffactive['Blaze of Glory'] ~= nil
    end
end

--- Bolster gained or lost.
--- @param buff string Buff name
--- @param gain boolean True when gained
function BolsterFollow.on_buff_change(buff, gain)
    if buff ~= 'Bolster' or not enabled() then return end
    if gain then on_bolster_gained() else on_bolster_lost() end
end

return BolsterFollow

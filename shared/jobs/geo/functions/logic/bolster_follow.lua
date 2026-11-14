---============================================================================
--- GEO Bolster Follow - what the luopan gets when Bolster comes and goes
---============================================================================
--- The reactions to Bolster are off unless <Character>/geo/combat/GEO_CONFIG.lua
--- sets `bolster_follow = true`; the luopan tracking always runs (the fight
--- opening reads it: shared/jobs/geo/functions/logic/fight_opening.lua).
---
--- Silmaril never uses Blaze of Glory or Ecliptic Attrition while Bolster is up
--- (13 Bolsters out of 13 in the Sortie logs, 2026-09-24 to 2026-10-16). BG-Wiki
--- (Bolster, Blaze of Glory): Bolster does NOT boost a luopan already placed,
--- only the next one; Blaze of Glory can be used under Bolster, its potency does
--- not stack with Bolster's but stays on the luopan once Bolster ends; Ecliptic
--- Attrition cannot be used under Bolster.
---   Bolster gained, luopan out     -> Full Circle (that luopan is not boosted),
---                                     then Blaze of Glory: the bot's next Geo-
---                                     goes out with both
---   Bolster gained, no luopan out  -> Blaze of Glory
---   Bolster lost, luopan out       -> placed with Blaze of Glory: Ecliptic
---                                     Attrition on it; placed without: Full
---                                     Circle, the bot places it again
--- Every ability goes through the ability queue (one at a time, in the bot's
--- gaps, never twice: shared/utils/precast/ability_queue.lua).
---
--- @file    shared/jobs/geo/functions/logic/bolster_follow.lua
--- @author  ejouanchicot
--- @version 2.0 - ability queue, luopan placed under Bolster or not
--- @date    Created: 2026-10-17 | Updated: 2026-11-14
---============================================================================

local BolsterFollow = {}

local AbilityHelper = require('shared/utils/precast/ability_helper')

local function enabled()
    return require('shared/utils/core/job_config').get('GEO', 'bolster_follow', false) == true
end

local function queue() return AbilityHelper.queue() end

--- Read from the game: the steps run in coroutines, where GearSwap's `pet` and
--- `buffactive` may not have caught up yet.
--- @return boolean
function BolsterFollow.luopan_out()
    local mob = windower.ffxi.get_mob_by_target('pet')
    return mob ~= nil and mob.name == 'Luopan' and mob.hpp > 0
end
local luopan_out = BolsterFollow.luopan_out

--- @return boolean
function BolsterFollow.bolster_up()
    return AbilityHelper.is_buff_active('Bolster')
end
local bolster_up = BolsterFollow.bolster_up

--- How the luopan out was placed. Kept on `windower`: a GearSwap reload between
--- the Geo- and the end of Bolster (3 minutes) must not forget it.
--- @return boolean
function BolsterFollow.placed_with_bog() return windower._geo_luopan_bog == true end

--- @return boolean True when the luopan out was placed under the Bolster now up
function BolsterFollow.placed_under_bolster() return windower._geo_luopan_bolster == true end

--- Full Circle on the luopan out, then Blaze of Glory (when ready): the bot's next Geo- carries both.
--- @param still function|nil Extra condition both steps need (a fight still under way...)
function BolsterFollow.replace_luopan(still)
    still = still or function() return true end
    if luopan_out() then
        queue().queue('Full Circle', {
            wanted = function() return still() and luopan_out() end,
            done = function() return not luopan_out() end})
    end
    if AbilityHelper.is_ability_ready('Blaze of Glory') then
        queue().queue('Blaze of Glory', {
            -- the luopan may still be out while its Full Circle waits ahead in the queue
            wanted = function() return still() and (not luopan_out() or queue().queued('Full Circle')) end,
            done = function() return AbilityHelper.is_buff_active('Blaze of Glory') end})
    end
end

local function on_bolster_gained()
    -- any luopan out was placed before this Bolster: not boosted (a new one must be cast)
    BolsterFollow.replace_luopan(bolster_up)
end

local function on_bolster_lost()
    if not luopan_out() then return end
    if BolsterFollow.placed_with_bog() then
        queue().queue('Ecliptic Attrition', {
            wanted = function() return luopan_out() and not bolster_up() end})
    else
        queue().queue('Full Circle', {wanted = luopan_out, done = function() return not luopan_out() end})
    end
end

--- A Geo- about to go out: remember whether Blaze of Glory and Bolster go with it.
--- @param spell table GearSwap spell (precast, not cancelled)
function BolsterFollow.note_cast(spell)
    if spell.skill == 'Geomancy' and spell.english:sub(1, 4) == 'Geo-' then
        windower._geo_luopan_bog = buffactive['Blaze of Glory'] ~= nil
        windower._geo_luopan_bolster = buffactive['Bolster'] ~= nil
    end
end

--- Bolster gained or lost.
--- @param buff string Buff name
--- @param gain boolean True when gained
function BolsterFollow.on_buff_change(buff, gain)
    if buff ~= 'Bolster' then return end
    -- its boost ends with it, on a luopan still out too (BG-Wiki)
    if not gain then windower._geo_luopan_bolster = false end
    if not enabled() then return end
    if gain then on_bolster_gained() else on_bolster_lost() end
end

return BolsterFollow

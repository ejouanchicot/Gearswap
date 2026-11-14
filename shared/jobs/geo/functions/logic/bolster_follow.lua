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

--- A job ability is refused while a spell is cast and for a while after it ends (message 88): every refused
--- Ecliptic Attrition of 2026-11-13/14 went 0 to 2.5 s after one of the bot's spells (aftercast) or during one;
--- those 3 s and more after went through. A try waits for that gap (GEO_AFTERCAST notes when a spell ends).
local CAST_LOCK = 3.5
local BUSY_LOOK = 0.5
local WAIT_MAX = 20       -- seconds a step may wait for the gap before trying anyway

local function busy()
    local casting = rawget(_G, 'midaction') and midaction()
    return casting or os.clock() - (windower._geo_cast_end or -math.huge) < CAST_LOCK
end

--- A step sent until `done()` says it went through or `wanted()` stops holding.
--- A newer Bolster event (seq) drops the older one's remaining tries.
local function try_step(seq, ability, wanted, done, tries_left, deadline)
    if windower._geo_bolster_seq ~= seq or not wanted() or done() then return end
    if busy() and os.clock() < deadline then
        coroutine.schedule(function() try_step(seq, ability, wanted, done, tries_left, deadline) end, BUSY_LOOK)
        return
    end
    if AbilityHelper.is_ability_ready(ability) then
        send_command('input /ja "' .. ability .. '" <me>')
    end
    if tries_left > 1 then
        coroutine.schedule(function() try_step(seq, ability, wanted, done, tries_left - 1, deadline) end, RETRY_DELAY)
    end
end

local function start(ability, wanted, done)
    local seq = (windower._geo_bolster_seq or 0) + 1
    windower._geo_bolster_seq = seq
    local deadline = os.clock() + FIRST_DELAY + WAIT_MAX
    coroutine.schedule(function() try_step(seq, ability, wanted, done, TRIES, deadline) end, FIRST_DELAY)
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

---============================================================================
--- FIGHT OPENING (//gs c fightopen, sent by //gs c sortie <target> fight)
---============================================================================
--- Chosen here from this character's own recasts and buffs (the leader cannot see them), asked 2026-11-14:
---   Bolster up            -> Blaze of Glory if no luopan is out (the bot's Geo- carries it); never Full Circle,
---                            never Ecliptic Attrition (refused under Bolster: BG-Wiki)
---   Bolster ready         -> [Full Circle if a luopan is out], Bolster, Blaze of Glory; Ecliptic Attrition
---                            comes when Bolster ends (on_bolster_lost above)
---   Bolster not ready,
---     Blaze of Glory ready -> [Full Circle if a luopan is out], Blaze of Glory, then Ecliptic Attrition once
---                            the bot's new bubble is placed
---     neither             -> Ecliptic Attrition: now on a luopan out, else once the bot's bubble is placed
--- Only the abilities the target lists (SORTIE_CONFIG fight_ja) are used.

local OPEN_GAP = 1.5        -- between two abilities: a job ability's own delay
local EA_AFTER_WINDOW = 45  -- seconds the bot has to place its bubble for Ecliptic Attrition to follow

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('OPENING', fmt, unpack(args)) end)
end

--- The opening for this state (pure: tested in scripts/atelier/fight_opening_test.lua).
--- @param allow table {bolster, bog, ea = bool}: what the target lists
--- @param s table {bolster_up, bolster_ready, bog_ready, ea_ready, luopan = bool}
--- @return table steps Ability names in order
--- @return boolean ea_after Ecliptic Attrition once the next bubble is placed
function BolsterFollow.plan(allow, s)
    local steps = {}
    if s.bolster_up then
        if allow.bog and s.bog_ready and not s.luopan then steps[1] = 'Blaze of Glory' end
        return steps, false
    end
    if allow.bolster and s.bolster_ready then
        if s.luopan then steps[#steps + 1] = 'Full Circle' end
        steps[#steps + 1] = 'Bolster'
        if allow.bog and s.bog_ready then steps[#steps + 1] = 'Blaze of Glory' end
        return steps, false
    end
    if allow.bog and s.bog_ready then
        if s.luopan then steps[#steps + 1] = 'Full Circle' end
        steps[#steps + 1] = 'Blaze of Glory'
        return steps, allow.ea == true and s.ea_ready == true
    end
    if allow.ea and s.ea_ready then
        if s.luopan then return {'Ecliptic Attrition'}, false end
        return steps, true
    end
    return steps, false
end

local function current_state()
    local ready = AbilityHelper.is_ability_ready
    return {bolster_up = bolster_up(), bolster_ready = ready('Bolster'), bog_ready = ready('Blaze of Glory'),
        ea_ready = ready('Ecliptic Attrition'), luopan = luopan_out()}
end

local BOG_CHECKS = 3   -- looks for Blaze of Glory's buff before answering, OPEN_GAP apart (one resend)

--- The end of the opening: with Blaze of Glory in it, its buff is waited for (sent again once if refused): the
--- profile the leader then loads casts its Geo- at once, and without the buff it went out plain (review 2026-11-14).
local function finish_open(st, leader, key, ea_after, want_bog, checks)
    if windower._geo_open ~= st then return end
    if want_bog and checks > 0 and not AbilityHelper.is_buff_active('Blaze of Glory') then
        if checks == BOG_CHECKS - 1 and AbilityHelper.is_ability_ready('Blaze of Glory') then
            trace('Blaze of Glory not up: sent again')
            send_command('input /ja "Blaze of Glory" <me>')
        end
        coroutine.schedule(function() finish_open(st, leader, key, ea_after, want_bog, checks - 1) end, OPEN_GAP)
        return
    end
    windower._geo_open = nil
    if ea_after then windower._geo_ea_after = os.clock() + EA_AFTER_WINDOW end
    send_command(('send %s gs c sortie %s opened'):format(leader, key))
end

--- Run the opening, then answer the leader (`send <leader> gs c sortie <key> opened`).
--- @param leader string
--- @param key string The Sortie target
--- @param words string Comma list: bolster, bog, ea
function BolsterFollow.open_fight(leader, key, words)
    local allow = {}
    for word in tostring(words or ''):gmatch('[^,]+') do allow[word] = true end
    local steps, ea_after = BolsterFollow.plan(allow, current_state())
    local st = {}
    windower._geo_open, windower._geo_ea_after = st, nil
    trace('%s: %s%s', key, #steps > 0 and table.concat(steps, ', ') or 'nothing',
        ea_after and ' (Ecliptic Attrition after the bubble)' or '')
    for i, ability in ipairs(steps) do
        coroutine.schedule(function()
            if windower._geo_open == st then send_command('input /ja "' .. ability .. '" <me>') end
        end, OPEN_GAP * (i - 1))
    end
    local want_bog = false
    for _, ability in ipairs(steps) do if ability == 'Blaze of Glory' then want_bog = true end end
    coroutine.schedule(function() finish_open(st, leader, key, ea_after, want_bog, BOG_CHECKS) end, OPEN_GAP * #steps)
end

--- //gs c fightopen off: the leader dropped that fight; nothing more of it goes.
function BolsterFollow.cancel_open()
    if windower._geo_open or windower._geo_ea_after then trace('dropped') end
    windower._geo_open, windower._geo_ea_after = nil, nil
    -- the Bolster steps already scheduled (on_bolster_gained's Blaze of Glory) stop too
    windower._geo_bolster_seq = (windower._geo_bolster_seq or 0) + 1
end

--- A Geo- placed (aftercast, not interrupted): Ecliptic Attrition on it when the opening asked for it.
function BolsterFollow.on_bubble_placed()
    local until_ = windower._geo_ea_after
    if not until_ then return end
    windower._geo_ea_after = nil
    if os.clock() > until_ then return end
    trace('bubble placed: Ecliptic Attrition')
    start('Ecliptic Attrition',
        function() return luopan_out() and not bolster_up() end,
        function() return not AbilityHelper.is_ability_ready('Ecliptic Attrition') end)
end

--- Bolster gained or lost.
--- @param buff string Buff name
--- @param gain boolean True when gained
function BolsterFollow.on_buff_change(buff, gain)
    if buff ~= 'Bolster' or not enabled() then return end
    if gain then on_bolster_gained() else on_bolster_lost() end
end

return BolsterFollow

---============================================================================
--- GEO Fight Opening - the abilities a Sortie fight opens with, and given back
---============================================================================
--- //gs c fightopen <leader> <target> <bolster,bog,ea> is sent by //gs c sortie
--- <target> fight on the leader (shared/utils/sortie/sortie_commands.lua), bot
--- off. The abilities are chosen here from this character's own recasts and
--- buffs (the leader cannot see them); only those the target lists (SORTIE_CONFIG
--- fight_ja) are used:
---   Bolster up            -> luopan out placed before it: Full Circle, Blaze of
---                            Glory (Bolster does not boost a luopan already out);
---                            no luopan: Blaze of Glory; a luopan placed under it:
---                            nothing. Never Ecliptic Attrition (refused under
---                            Bolster: BG-Wiki)
---   Bolster ready         -> [Full Circle if a luopan is out], Bolster, Blaze of
---                            Glory; Ecliptic Attrition comes when Bolster ends
---                            (bolster_follow.lua)
---   Bolster not ready,
---     Blaze of Glory ready -> [Full Circle if a luopan is out], Blaze of Glory,
---                            then Ecliptic Attrition once the bot's bubble is placed
---     neither             -> Ecliptic Attrition: now on a luopan out, else once
---                            the bot's bubble is placed
--- Then `send <leader> gs c sortie <target> opened`.
---
--- Until //gs c fightend (or fightopen off), the recasts are watched: one that
--- jumps back to 0 was given back by the COR (asked 2026-11-14):
---   Bolster (Wild Card only)        -> the opening again
---   Blaze of Glory (Random Deal)    -> with no Bolster up and a luopan placed
---                                      without it: Full Circle, Blaze of Glory,
---                                      the bot's new bubble, Ecliptic Attrition
---   Ecliptic Attrition alone        -> nothing (the bot's profiles keep it for
---                                      a Blaze of Glory luopan)
--- Every ability goes through the ability queue (shared/utils/precast/ability_queue.lua).
---
--- @file    shared/jobs/geo/functions/logic/fight_opening.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-11-14 (moved out of bolster_follow.lua)
---============================================================================

local FightOpening = {}

local AbilityHelper = require('shared/utils/precast/ability_helper')
local BF = require('shared/jobs/geo/functions/logic/bolster_follow')

local EA_AFTER_WINDOW = 45  -- seconds the bot has to place its bubble for Ecliptic Attrition to follow
local OPEN_LOOK = 0.5       -- how often the opening looks whether its abilities are through
local OPEN_MAX = 13         -- seconds before `opened` goes anyway (the leader waits 15)
local WATCH_EVERY = 2       -- seconds between two looks at the recasts during a fight
local GIVEN_BACK_FROM = 5   -- a recast above this one look and 0 the next was given back, not run out
local WATCH_MAX = 45 * 60   -- a fight never told over stops being watched (a Sortie lasts 60 min)

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('OPENING', fmt, unpack(args)) end)
end

local function queue() return AbilityHelper.queue() end

--- Seconds a luopan is waited for: it shows only a moment after the Geo-'s aftercast (in game 2026-11-14,
--- Ecliptic Attrition was dropped at once for "no luopan").
local LUOPAN_WAIT = 5

--- Ecliptic Attrition still wanted: Bolster down, and a luopan out (or soon: just placed).
--- @param since number os.clock() when it was queued
local function ea_wanted(since)
    return not BF.bolster_up() and (BF.luopan_out() or os.clock() < since + LUOPAN_WAIT)
end

--- What tells that each ability went through.
local DONE = {
    ['Full Circle'] = function() return not BF.luopan_out() end,
    ['Bolster'] = function() return AbilityHelper.is_buff_active('Bolster') end,
    ['Blaze of Glory'] = function() return AbilityHelper.is_buff_active('Blaze of Glory') end,
    ['Ecliptic Attrition'] = function() return not AbilityHelper.is_ability_ready('Ecliptic Attrition') end,
}

--- The opening for this state (pure: tested in scripts/atelier/fight_opening_test.lua).
--- @param allow table {bolster, bog, ea = bool}: what the target lists
--- @param s table {bolster_up, bolster_ready, bog_ready, ea_ready, luopan, bubble_bolster = bool}
--- @return table steps Ability names in order
--- @return boolean ea_after Ecliptic Attrition once the next bubble is placed
function FightOpening.plan(allow, s)
    local steps = {}
    if s.bolster_up then
        if s.luopan and s.bubble_bolster then return steps, false end
        if s.luopan then steps[1] = 'Full Circle' end
        if allow.bog and s.bog_ready then steps[#steps + 1] = 'Blaze of Glory' end
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
    return {bolster_up = BF.bolster_up(), bolster_ready = ready('Bolster'), bog_ready = ready('Blaze of Glory'),
        ea_ready = ready('Ecliptic Attrition'), luopan = BF.luopan_out(), bubble_bolster = BF.placed_under_bolster()}
end

--- Queue these steps for the fight `st`; Ecliptic Attrition after the next bubble when asked.
local function run_steps(st, steps, ea_after)
    local still = function() return windower._geo_fight == st end
    for _, ability in ipairs(steps) do
        local wanted, can_send = still, nil
        if ability == 'Ecliptic Attrition' then
            local since = os.clock()
            wanted, can_send = function() return still() and ea_wanted(since) end, BF.luopan_out
        end
        queue().queue(ability, {wanted = wanted, done = DONE[ability], can_send = can_send})
    end
    windower._geo_ea_after = ea_after and (os.clock() + EA_AFTER_WINDOW) or nil
end

local function any_queued(steps)
    for _, ability in ipairs(steps) do
        if queue().queued(ability) then return true end
    end
    return false
end

--- `opened` once none of the opening's abilities waits any more (or after OPEN_MAX).
local function answer_when_through(st, steps, ea_after, until_)
    if windower._geo_fight ~= st or not st.opening then return end
    if any_queued(steps) and os.clock() < until_ then
        coroutine.schedule(function() answer_when_through(st, steps, ea_after, until_) end, OPEN_LOOK)
        return
    end
    st.opening = false
    if ea_after then windower._geo_ea_after = os.clock() + EA_AFTER_WINDOW end
    send_command(('send %s gs c sortie %s opened'):format(st.leader, st.key))
end

--- Seconds of recast left for an ability, nil when unknown (an empty table, as during a zone change, is unknown:
--- read as 0 it would look like a recast given back).
local function recast_left(ability)
    local ok, left = pcall(function()
        local data = require('resources').job_abilities:with('en', ability)
        local recasts = windower.ffxi.get_ability_recasts()
        if not (data and recasts and next(recasts) ~= nil) then return nil end
        return recasts[data.recast_id or data.id] or 0
    end)
    return ok and left or nil
end

--- Given back: ready now, while the time gone since the last look should have left more than GIVEN_BACK_FROM
--- (a game frozen a few seconds between two looks is not taken for a COR).
local function given_back(before, now_left, elapsed)
    return before ~= nil and now_left == 0 and before - elapsed > GIVEN_BACK_FROM
end

--- Bolster given back (Wild Card): the opening again. Blaze of Glory given back (Random Deal): a new bubble
--- with it, unless Bolster is up or the luopan out already has it.
local function on_given_back(st, ability)
    local s = current_state()
    if ability == 'Bolster' then
        local steps, ea_after = FightOpening.plan(st.allow, s)
        trace('%s: Bolster given back: %s', st.key, #steps > 0 and table.concat(steps, ', ') or 'nothing')
        return run_steps(st, steps, ea_after)
    end
    if s.bolster_up or (s.luopan and BF.placed_with_bog()) then
        trace('%s: Blaze of Glory given back: kept for later (%s)', st.key,
            s.bolster_up and 'Bolster up' or 'the luopan has it')
        return
    end
    local steps, ea_after = FightOpening.plan({bog = true, ea = st.allow.ea}, s)
    trace('%s: Blaze of Glory given back: %s', st.key, table.concat(steps, ', '))
    run_steps(st, steps, ea_after)
end

local function watch(st)
    if windower._geo_fight ~= st or windower._load_gen ~= st.load_gen then return end
    if os.clock() > st.watch_until then
        trace('%s: no longer watched (%d min)', st.key, WATCH_MAX / 60)
        windower._geo_fight = nil
        return
    end
    local bolster, bog = recast_left('Bolster'), recast_left('Blaze of Glory')
    local elapsed = os.clock() - (st.last_look or os.clock())
    if st.allow.bolster and given_back(st.last_bolster, bolster, elapsed) then
        on_given_back(st, 'Bolster')
    elseif st.allow.bog and given_back(st.last_bog, bog, elapsed) then
        on_given_back(st, 'Blaze of Glory')
    end
    st.last_bolster, st.last_bog, st.last_look = bolster, bog, os.clock()
    coroutine.schedule(function() watch(st) end, WATCH_EVERY)
end

--- Run the opening, answer the leader, then watch the recasts until the fight is over.
--- @param leader string
--- @param key string The Sortie target
--- @param words string Comma list: bolster, bog, ea
function FightOpening.open_fight(leader, key, words)
    local allow = {}
    for word in tostring(words or ''):gmatch('[^,]+') do allow[word] = true end
    FightOpening.fight_end()
    local steps, ea_after = FightOpening.plan(allow, current_state())
    local st = {leader = leader, key = key, allow = allow, opening = true, load_gen = windower._load_gen,
        watch_until = os.clock() + WATCH_MAX, last_bolster = recast_left('Bolster'), last_bog = recast_left('Blaze of Glory'),
        last_look = os.clock()}
    windower._geo_fight = st
    trace('%s: %s%s', key, #steps > 0 and table.concat(steps, ', ') or 'nothing',
        ea_after and ' (Ecliptic Attrition after the bubble)' or '')
    run_steps(st, steps, nil)
    answer_when_through(st, steps, ea_after, os.clock() + OPEN_MAX)
    coroutine.schedule(function() watch(st) end, WATCH_EVERY)
end

--- //gs c fightend (or fightopen off): the leader left that fight; nothing more of it goes.
function FightOpening.fight_end()
    if windower._geo_fight or windower._geo_ea_after then trace('fight over') end
    windower._geo_fight, windower._geo_ea_after = nil, nil
end

--- A Geo- placed (aftercast, not interrupted): Ecliptic Attrition on it when the opening asked for it.
function FightOpening.on_bubble_placed()
    local until_ = windower._geo_ea_after
    if not until_ then return end
    windower._geo_ea_after = nil
    if os.clock() > until_ then return end
    trace('bubble placed: Ecliptic Attrition')
    local since = os.clock()
    queue().queue('Ecliptic Attrition', {
        wanted = function() return ea_wanted(since) end,
        can_send = BF.luopan_out,
        done = DONE['Ecliptic Attrition']})
end

return FightOpening

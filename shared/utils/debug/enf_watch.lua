---============================================================================
--- Enfeeble Watch - an enfeeble on a mob, from the cast to its wear-off
---============================================================================
--- What shared/utils/debug/enh_test.lua reads of an enfeebling spell the
--- character casts on a mob (2026-10-14, Red Mage):
---   - whether it landed: her own spell action (0x028, category 4, the spell's
---     id) and its message: landed 236/237 (267/268/270/271/278 for the other
---     targets and the bursts), resisted 85/284/653-656, no effect 75/114
---   - how long it lasted: the wear-off of its status on that mob, sent apart
---     (0x029: 206 "effect wears off", 204/350 "is no longer"), from the second
---     her action came. A partial resist halves a duration and has no message
---     of its own (BG Wiki Resist): only the length tells it
---   - the mob's own melee rounds while it lasts (0x028, category 1, the mob as
---     actor): the seconds between two rounds with no move of its own between
---     them (Slow), and its "is paralyzed" (Paralyze): a move of its own
---     (category 11) or a finished spell (category 4, what a crab sent under
---     Paralyze II, Kaories 2026-10-14) with message 84, or 29/84 in 0x029. The
---     rounds lost are also read from the gaps, against the last reading with
---     no enfeeble, a check that needs no message
---   - every mob event, with its second, for the log
---   - the mob's defeat (0x029, 6/20/97) ends the reading with no length.
---
---   EnfWatch.cast(spell_id, buff_id, timeout, on_land, on_end)   before the cast
---   EnfWatch.rounds(mob_id, seconds, on_end)                     with no enfeeble
---   EnfWatch.stop()
--- on_end(seconds|nil, text, defeated)
---
--- @file shared/utils/debug/enf_watch.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-14
---============================================================================

local ActionListener = require('shared/utils/core/action_listener')

local EnfWatch = {}

local KEY = 'enf_watch'
local SPELL_DONE, MELEE, MOB_MOVE = 4, 1, 11
-- res/action_messages.lua
local LANDED = {[236] = true, [237] = true, [267] = true, [268] = true, [270] = true, [271] = true, [278] = true}
local RESISTED = {[85] = true, [284] = true, [653] = true, [654] = true, [655] = true, [656] = true}
local NO_EFFECT = {[75] = true, [114] = true}
local WORN = {[204] = true, [206] = true, [350] = true}
local DEFEATED = {[6] = true, [20] = true, [97] = true}
local PARALYZED = {[29] = true, [84] = true}
local POLL = 1
local LAND_WAIT = 25   -- seconds a cast is given to land or be resisted (an interrupted cast sends nothing)

local watch = nil   -- {spell_id, buff, mob, landed_at, rounds, moved, paralyzed, events, ends_at, on_land, on_end}
local reference = nil   -- the median gap of the last reading with no enfeeble (EnfWatch.rounds), this load

--- The rounds a gap stands for, past the one that ended it: a 12.3 s gap at 4.1 s a round is 2 lost.
local function lost_in(gap, ref)
    return math.max(0, math.floor(gap / ref + 0.5) - 1)
end

--- The rounds the mob lost against the reference: its paralyses show as gaps of two rounds or more,
--- whether or not the game told it was paralyzed.
local function lost_text(w, gaps)
    if not reference or #gaps == 0 then return 'lost rounds: no reference' end
    local lost = 0
    for _, g in ipairs(gaps) do lost = lost + lost_in(g, reference) end
    return ('lost rounds %d of %d (%.0f %%) at %.2f s a round'):format(lost, lost + #gaps, 100 * lost / (lost + #gaps), reference)
end

--- The seconds between two rounds, and how many, as "median 3.6 s, mean 3.7 s (41)", then each mob
--- event as it came (seconds from the land: r round, m<ability>/<message> move, c<category>/<message>
--- other action, x<message> 0x029 about the mob).
local function rounds_text(w)
    local gaps, sorted = {}, {}
    for i = 2, #w.rounds do
        if not w.rounds[i].after_move then gaps[#gaps + 1] = w.rounds[i].at - w.rounds[i - 1].at end
    end
    for i, g in ipairs(gaps) do sorted[i] = g end
    table.sort(sorted)
    local sum = 0
    for _, g in ipairs(gaps) do sum = sum + g end
    local median = sorted[math.ceil(#sorted / 2)]
    if w.read_only and #gaps >= 10 then reference = median end
    local between = median and ('median %.2f s, mean %.2f s (%d)'):format(median, sum / #gaps, #gaps) or 'none'
    local attacks = #w.rounds + w.paralyzed
    local rate = attacks > 0 and (' (%.0f %% of %d attacks)'):format(100 * w.paralyzed / attacks, attacks) or ''
    return ('mob rounds %d, between two %s, its moves %d, paralyzed %d%s | %s | events: %s'):format(#w.rounds, between,
        w.moves, w.paralyzed, rate, lost_text(w, gaps), table.concat(w.events, ' '))
end

local function note(w, what)
    w.events[#w.events + 1] = ('%s@%.1f'):format(what, os.clock() - (w.landed_at or w.started))
end

local function finish(seconds, text, defeated)
    local w = watch
    if not w then return end
    watch = nil
    ActionListener.off(KEY)
    local length = seconds and math.floor(seconds * 10 + 0.5) / 10 or nil
    w.on_end(length, text .. ' | ' .. rounds_text(w), defeated)
end

--- Her own cast's result, then the mob's own actions.
local function on_action(act)
    local w = watch
    local p = windower.ffxi.get_player()
    if not (w and p) then return end
    if not w.mob and act.actor_id == p.id and act.category == SPELL_DONE and act.param == w.spell_id then
        local target = (act.targets or {})[1] or {}
        local message = ((target.actions or {})[1] or {}).message
        if LANDED[message] then
            w.mob, w.landed_at = target.id, os.clock()
            return w.on_land and w.on_land(message)
        end
        local kind = RESISTED[message] and 'RESISTED' or NO_EFFECT[message] and 'NO EFFECT' or 'NOT LANDED'
        return finish(nil, ('%s (message %s)'):format(kind, tostring(message)))
    end
    if w.mob and act.actor_id == w.mob then
        local message = ((((act.targets or {})[1] or {}).actions or {})[1] or {}).message
        if act.category == MELEE then
            w.rounds[#w.rounds + 1] = {at = os.clock(), after_move = w.moved}
            w.moved = false
            note(w, 'r')
        elseif act.category == MOB_MOVE then
            -- a paralyzed mob's lost turn comes as a move of its own with message 84 (Tetsouo's fight logs:
            -- "MOB 0 | msg 84"), not in 0x029: a paralysis, not a move
            -- its gap is kept: the paralyzed round is what lost_text counts
            if PARALYZED[message] then w.paralyzed = w.paralyzed + 1 else w.moves, w.moved = w.moves + 1, true end
            note(w, ('m%s/%s'):format(tostring(act.param), tostring(message)))
        else
            -- Paralyze II on a crab (Kaories, 2026-10-14): each lost round came as category 4, message 84
            if PARALYZED[message] then w.paralyzed = w.paralyzed + 1 end
            note(w, ('c%d/%s'):format(act.category, tostring(message)))
        end
    end
end

--- The wear-off, the defeat and the paralysis of the mob (0x029).
local function on_message(original)
    local w = watch
    if not (w and w.mob) then return end
    local ok, packets = pcall(require, 'packets')
    local m = ok and packets.parse('incoming', original)
    if type(m) ~= 'table' then return end
    local about_mob = m.Target == w.mob or m.Actor == w.mob
    if about_mob then note(w, 'x' .. tostring(m.Message)) end
    if WORN[m.Message] and about_mob and m['Param 1'] == w.buff then
        return finish(os.clock() - w.landed_at, ('LANDED, worn off (message %d)'):format(m.Message))
    end
    if DEFEATED[m.Message] and m.Target == w.mob then
        return finish(nil, ('mob defeated %.0f s after it landed'):format(os.clock() - (w.landed_at or os.clock())), true)
    end
    if PARALYZED[m.Message] and m.Actor == w.mob then w.paralyzed = w.paralyzed + 1 end
end

--- One raw 0x029 listener a load (GearSwap's events are dropped at each load).
local function listen()
    ActionListener.on(KEY, on_action)
    if rawget(_G, '_enf_watch_id') then return end
    _G._enf_watch_id = windower.raw_register_event('incoming chunk', function(id, original)
        if id == 0x029 and watch then on_message(original) end
    end)
end

local function poll(w)
    if watch ~= w then return end
    if not w.mob and os.clock() - w.started >= LAND_WAIT then return finish(nil, 'NO ANSWER to the cast') end
    if os.clock() >= w.ends_at then
        local what = w.mob and (w.read_only and 'READ' or 'TIMEOUT, no wear-off seen') or 'NO ANSWER to the cast'
        return finish(w.read_only and w.ends_at - w.started or nil, what)
    end
    coroutine.schedule(function() poll(w) end, POLL)
end

local function begin(w)
    EnfWatch.stop()
    w.rounds, w.moves, w.moved, w.paralyzed, w.events, w.started = {}, 0, false, 0, {}, os.clock()
    watch = w
    listen()
    coroutine.schedule(function() poll(w) end, POLL)
end

--- Follow the next cast of a spell: call it right before sending it.
--- @param spell_id number The spell's id (res/spells.lua)
--- @param buff_id number The status it puts on the mob
--- @param timeout number Seconds before giving up, from now
--- @param on_land function|nil Called with the message once it landed
--- @param on_end function Called once: (seconds|nil, text, defeated)
function EnfWatch.cast(spell_id, buff_id, timeout, on_land, on_end)
    begin({spell_id = spell_id, buff = buff_id, ends_at = os.clock() + timeout, on_land = on_land, on_end = on_end})
end

--- The mob's rounds for a while, with no enfeeble cast (the reference for Slow and Paralyze).
--- @param mob_id number The mob
--- @param seconds number How long
--- @param on_end function Called once: (seconds, text, defeated)
function EnfWatch.rounds(mob_id, seconds, on_end)
    begin({mob = mob_id, landed_at = os.clock(), ends_at = os.clock() + seconds, read_only = true, on_end = on_end})
end

--- Stop following, without an answer.
function EnfWatch.stop()
    watch = nil
    ActionListener.off(KEY)
end

return EnfWatch

---============================================================================
--- Enhancing Test, in a fight - what an Enspell adds to each hit
---============================================================================
--- Read from the character's own melee actions (0x028, category 1): each swing
--- that carries an additional effect of damage gives the Enspell's damage of
--- that hit. A tier I Enspell's damage is set when it is cast (BG-Wiki
--- Enspell), so the character goes back to her own sets while it is read.
---
---   EnhTestFight.enspell(25, 180, done)   at most 25 procs or 180 s, then done(text)
---   EnhTestFight.taken(40, 300, nil, done) the next 40 plain hits taken (Phalanx, Spikes), or 300 s
---   EnhTestFight.taken(99, 300, 37, done)  the hits taken until Stoneskin (buff 37) is used up
---   EnhTestFight.stop()                   stops reading
---
--- The text: every value seen and how often (a resisted proc is a half or a
--- quarter), the hits that landed, the swings of each round (one weapon: 2 a
--- double attack, 3 a triple attack, for Temper), whether Composure was up at
--- each proc, the day and the weather (they change an Enspell's damage).
---
--- @file shared/utils/debug/enh_test_fight.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-14
---============================================================================

local ActionListener = require('shared/utils/core/action_listener')

local EnhTestFight = {}

local KEY = 'enh_test_fight'
local MELEE = 1
--- res/action_messages.lua: "Additional effect: <n> points of damage." and "... takes <n> additional points of damage."
local ADDED_DAMAGE = {[163] = true, [229] = true}
local LANDED = {[1] = true, [67] = true}
local CRIT = 67
local COMPOSURE = 419
local POLL = 1

local reading = nil   -- {values, landed, rounds, composure, procs_wanted, ends_at, done}

local function has_buff(id)
    for _, buff in ipairs((windower.ffxi.get_player() or {}).buffs or {}) do
        if buff == id then return true end
    end
    return false
end

--- "Lightningsday, Thunder": the day and weather the procs were read on.
local function day_and_weather()
    local info = windower.ffxi.get_info() or {}
    local res = require('resources')
    local day = res.days[info.day or -1]
    local weather = res.weather[info.weather or -1]
    return (day and day.en or '?') .. ', ' .. (weather and weather.en or '?')
end

--- "64 x18, 32 x5": each value seen, the highest first, and how many times.
local function values_text(values)
    local count, order = {}, {}
    for _, v in ipairs(values) do
        if not count[v] then order[#order + 1] = v end
        count[v] = (count[v] or 0) + 1
    end
    table.sort(order, function(a, b) return a > b end)
    local parts = {}
    for _, v in ipairs(order) do parts[#parts + 1] = v .. ' x' .. count[v] end
    return #parts > 0 and table.concat(parts, ', ') or 'none'
end

local function rounds_text(rounds)
    local parts = {}
    for swings = 1, 8 do
        if rounds[swings] then parts[#parts + 1] = swings .. ':' .. rounds[swings] end
    end
    return #parts > 0 and table.concat(parts, ' ') or 'none'
end

local function finish()
    local r = reading
    if not r then return end
    reading = nil
    ActionListener.off(KEY)
    r.done(('ENSPELL %d procs: %s | on a critical hit: %s | %d hits landed, swings a round %s | Composure at %d of them | %s'):format(
        #r.values, values_text(r.values), values_text(r.on_crit), r.landed, rounds_text(r.rounds), r.composure,
        day_and_weather()))
end

--- One melee round of the character.
local function on_action(act)
    local r = reading
    local p = windower.ffxi.get_player()
    if not (r and p and act.actor_id == p.id and act.category == MELEE) then return end
    for _, target in ipairs(act.targets or {}) do
        local actions = target.actions or {}
        r.rounds[#actions] = (r.rounds[#actions] or 0) + 1
        for _, a in ipairs(actions) do
            if LANDED[a.message] then r.landed = r.landed + 1 end
            if a.has_add_effect and ADDED_DAMAGE[a.add_effect_message] then
                r.values[#r.values + 1] = a.add_effect_param or 0
                -- a proc twice the others came once (315 among 157s, 2026-10-14): on a critical hit?
                if a.message == CRIT then r.on_crit[#r.on_crit + 1] = a.add_effect_param or 0 end
                if has_buff(COMPOSURE) then r.composure = r.composure + 1 end
            end
        end
    end
end

local function watch(r)
    if reading ~= r then return end
    if #r.values >= r.procs_wanted or os.time() >= r.ends_at then return finish() end
    coroutine.schedule(function() watch(r) end, POLL)
end

--- Read the Enspell's damage of the next swings.
--- @param procs number Procs wanted
--- @param seconds number Longest reading (the buff's length, less a margin)
--- @param done function Called once with the text
function EnhTestFight.enspell(procs, seconds, done)
    EnhTestFight.stop()
    local r = {values = {}, on_crit = {}, landed = 0, rounds = {}, composure = 0, procs_wanted = procs,
        ends_at = os.time() + math.max(seconds, 10), done = done}
    reading = r
    ActionListener.on(KEY, on_action)
    coroutine.schedule(function() watch(r) end, POLL)
end

---============================================================================
--- HITS TAKEN - Phalanx, Stoneskin and Spikes, read from the hits the character takes
---============================================================================
--- Every melee swing at the character is written as it came: its damage, then c a critical hit, rN a reaction other
--- than a plain hit (a block, a parry: N as sent), s Stoneskin up, b while she was casting (her casting gear),
--- and @HP her HP when it came (the game's HP, sent apart: the hit's own loss shows a moment later). A swing that
--- missed or that a shadow took is counted apart. Plain hits = landed, not critical, plain reaction, not casting.

local SHADOW = {[31] = true, [32] = true}   -- res/action_messages.lua: "... of <target>'s shadows absorbs the damage"
local PLAIN_REACTION = 8                     -- category 1: 8 a hit (battlemod/statics.lua reaction_offsets)
local STONESKIN = 37
local CASTING, CAST_DONE = 8, 4
local taking = nil   -- {hits, plain, spikes, missed, shadows, wanted, until_lost, busy_until, ends_at, done}

local function taken_text(t)
    local plain = {}
    for _, d in ipairs(t.plain) do plain[#plain + 1] = d end
    table.sort(plain)
    local sum = 0
    for _, d in ipairs(plain) do sum = sum + d end
    local stats = #plain > 0 and ('min %d max %d mean %.1f'):format(plain[1], plain[#plain], sum / #plain) or 'none'
    return ('TAKEN %d plain hits: %s | %d missed, %d to shadows | spikes: %s | every swing: %s'):format(#plain, stats,
        t.missed, t.shadows, values_text(t.spikes), #t.hits > 0 and table.concat(t.hits, ' ') or 'none')
end

local function finish_taken()
    local t = taking
    if not t then return end
    taking = nil
    ActionListener.off(KEY)
    t.done(taken_text(t))
end

--- A swing at the character, or her own cast starting or ending (her casting gear is not the one measured).
local function on_taken(act)
    local t = taking
    local p = windower.ffxi.get_player()
    if not (t and p) then return end
    if act.actor_id == p.id then
        if act.category == CASTING then t.busy_until = os.time() + 10 end
        if act.category == CAST_DONE then t.busy_until = os.time() + 1 end
        return
    end
    if act.category ~= MELEE then return end
    local busy = os.time() <= t.busy_until
    for _, target in ipairs(act.targets or {}) do
        for _, a in ipairs(target.id == p.id and target.actions or {}) do
            if SHADOW[a.message] then
                t.shadows = t.shadows + 1
            elseif not LANDED[a.message] then
                t.missed = t.missed + 1
            else
                local mark = (a.message == CRIT and 'c' or '') .. (a.reaction ~= PLAIN_REACTION and ('r' .. tostring(a.reaction)) or '')
                    .. (has_buff(STONESKIN) and 's' or '') .. (busy and 'b' or '')
                t.hits[#t.hits + 1] = (a.param or 0) .. mark .. '@' .. tostring((p.vitals or {}).hp)
                if mark == '' then t.plain[#t.plain + 1] = a.param or 0 end
            end
            if a.has_spike_effect then t.spikes[#t.spikes + 1] = a.spike_effect_param or 0 end
        end
    end
end

local function watch_taken(t)
    if taking ~= t then return end
    local lost = t.until_lost and #t.hits > 0 and not has_buff(t.until_lost)
    if lost or #t.plain >= t.wanted or os.time() >= t.ends_at then return finish_taken() end
    coroutine.schedule(function() watch_taken(t) end, POLL)
end

--- Write the next swings the character takes.
--- @param hits number Plain hits wanted
--- @param seconds number Longest reading
--- @param until_lost number|nil A buff id: the reading ends once it is gone (a Stoneskin used up)
--- @param done function Called once with the text
function EnhTestFight.taken(hits, seconds, until_lost, done)
    EnhTestFight.stop()
    local t = {hits = {}, plain = {}, spikes = {}, missed = 0, shadows = 0, wanted = hits, until_lost = until_lost,
        busy_until = 0, ends_at = os.time() + math.max(seconds, 10), done = done}
    taking = t
    ActionListener.on(KEY, on_taken)
    coroutine.schedule(function() watch_taken(t) end, POLL)
end

--- Stop reading, without an answer.
function EnhTestFight.stop()
    reading = nil
    taking = nil
    ActionListener.off(KEY)
end

return EnhTestFight

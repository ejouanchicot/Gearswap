---============================================================================
--- Enhancing Test, in a fight - what an Enspell adds to each hit
---============================================================================
--- Read from the character's own melee actions (0x028, category 1): each swing
--- that carries an additional effect of damage gives the Enspell's damage of
--- that hit. A tier I Enspell's damage is set when it is cast (BG-Wiki
--- Enspell), so the character goes back to her own sets while it is read.
---
---   EnhTestFight.enspell(25, 180, done)   at most 25 procs or 180 s, then done(text)
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
    r.done(('ENSPELL %d procs: %s | %d hits landed, swings a round %s | Composure at %d of them | %s'):format(
        #r.values, values_text(r.values), r.landed, rounds_text(r.rounds), r.composure, day_and_weather()))
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
    local r = {values = {}, landed = 0, rounds = {}, composure = 0, procs_wanted = procs,
        ends_at = os.time() + math.max(seconds, 10), done = done}
    reading = r
    ActionListener.on(KEY, on_action)
    coroutine.schedule(function() watch(r) end, POLL)
end

--- Stop reading, without an answer.
function EnhTestFight.stop()
    reading = nil
    ActionListener.off(KEY)
end

return EnhTestFight

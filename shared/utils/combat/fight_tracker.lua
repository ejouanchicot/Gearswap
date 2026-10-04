---============================================================================
--- Fight Tracker - a chat block at each fight and each kill
---============================================================================
--- Listens to what the server already sends (no packet made or blocked); the
--- one thing it does in game is a plain /check, once a fight, 3 s after you
--- engage, when you are still on that mob (what you would type yourself).
---   - a fight starts when you engage (or change target while engaged)
---   - it ends when the mob dies (0x029 defeat messages), or 2 s after you
---     disengage without a kill
---   - your melee swings and weaponskills on it (0x028, the packet as the
---     server sent it: shared/utils/core/action_listener.lua)
---   - its level from that /check's answer (0x029 check messages), kept by
---     mob name for the session (your own /check counts too)
---
--- //gs c fights            the session: kills, time a kill, level by mob
--- //gs c fights on|off     the chat blocks on or off (tracking goes on)
--- //gs c fights reset      a new session
---
--- The session lives on windower.* (kept through reloads and job changes,
--- lost when Windower closes).
---
--- @file    shared/utils/combat/fight_tracker.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-05
---============================================================================

local FightTracker = {}

local InfoBlock = require('shared/utils/messages/info_block')

local STATUS_ENGAGED = 1
local LEFT_DELAY = 2
-- the /check, a few seconds into the fight, and how long its answer is waited for before the block shows anyway
local CHECK_DELAY, CHECK_WAIT = 3, 2

-- 0x029 messages (res/action_messages.lua): the target defeated, and a /check's answer (the level in Param 1)
local DEATH = {[6] = true, [20] = true, [97] = true, [113] = true, [406] = true, [605] = true, [646] = true}
local CHECK = {[170] = 'high evasion and defense', [171] = 'high evasion', [172] = 'high evasion, low defense',
    [173] = 'high defense', [174] = 'average', [175] = 'low defense', [176] = 'low evasion, high defense',
    [177] = 'low evasion', [178] = 'low evasion and defense', [249] = 'impossible to gauge'}
-- 0x028 melee results: hit, critical, miss, shadow, dodge, parry
local MELEE_HIT, MELEE_CRIT = {[1] = true}, {[67] = true}
local MELEE_MISS = {[15] = true, [63] = true, [31] = true, [32] = true, [70] = true}
local WS_HIT, WS_MISS = {[185] = true}, {[188] = true}

--- The session, kept on windower.* so a reload or a job change keeps it.
local function session()
    local s = windower._fight_tracker
    if not s then
        s = {on = true, started = os.time(), fights = 0, total = 0, kills = {}, time = {}, levels = {}, fight = nil}
        windower._fight_tracker = s
    end
    return s
end

local function mmss(sec)
    sec = math.max(0, math.floor(sec + 0.5))
    return string.format('%d:%02d', math.floor(sec / 60), sec % 60)
end

local function level_text(name)
    local lv = session().levels[name]
    if not lv then return 'unknown (/check it to see it)', 'dim' end
    return 'Lv ' .. lv.level .. (lv.note and (', ' .. lv.note) or ''), nil
end

local function show(tag, title, fields)
    if session().on then InfoBlock.show({tag = tag, title = title, fields = fields}) end
end

---============================================================================
--- FIGHTS
---============================================================================

--- The fight's block, once: when the /check answers, or without it
local function announce(f)
    if f.shown then return end
    f.shown = true
    local s, lv, kind = session(), level_text(f.name)
    show('FIGHT', f.name, {
        {'Level', lv, kind},
        {'Killed before', tostring(s.kills[f.name] or 0)},
        {'Fight', '#' .. f.number .. ' this session'},
    })
end

local function engaged_target()
    local p = windower.ffxi.get_player()
    if not p or p.status ~= STATUS_ENGAGED then return nil end
    local t = windower.ffxi.get_mob_by_target('t')
    return t and t.is_npc and t.hpp and t.hpp > 0 and t or nil
end

--- The /check, if the fight is still on with that mob targeted; else the block without it
local function check_later(f)
    coroutine.schedule(function()
        if session().fight ~= f or f.shown then return end
        local t = engaged_target()
        if not t or t.id ~= f.id then return announce(f) end
        windower.send_command('input /check <t>')
        coroutine.schedule(function() if session().fight == f then announce(f) end end, CHECK_WAIT)
    end, CHECK_DELAY)
end

local function start(mob)
    local s = session()
    s.fights = s.fights + 1
    s.fight = {id = mob.id, name = mob.name, start = os.time(), dmg = 0, number = s.fights,
        melee = {hits = 0, crits = 0, misses = 0, dmg = 0}, ws = {n = 0, misses = 0, dmg = 0}}
    check_later(s.fight)
end

local function melee_text(m)
    local swings = m.hits + m.crits + m.misses
    if swings == 0 then return 'none' end
    return string.format('%d/%d landed (%d %%), %d crit(s)', m.hits + m.crits, swings,
        math.floor(100 * (m.hits + m.crits) / swings + 0.5), m.crits)
end

local function ws_text(w)
    if w.n == 0 then return 'none' end
    local landed = w.n - w.misses
    return string.format('%d (%d missed), average %d', w.n, w.misses, landed > 0 and math.floor(w.dmg / landed + 0.5) or 0)
end

local function finish(killed)
    local s, f = session(), session().fight
    if not f then return end
    s.fight = nil
    -- killed before its block (a mob dead in 3 s): the kill block alone, its level in it
    f.shown = true
    local secs = os.time() - f.start
    local fields = {{'Time', mmss(secs)},
        {'Your damage', string.format('%d (melee %d, WS %d)', f.dmg, f.melee.dmg, f.ws.dmg)},
        {'Melee', melee_text(f.melee)}, {'Weaponskills', ws_text(f.ws)}}
    if not killed then return show('FIGHT', f.name .. ' (left, not killed)', fields) end
    s.total = s.total + 1
    s.kills[f.name] = (s.kills[f.name] or 0) + 1
    local t = s.time[f.name] or {sum = 0, n = 0}
    t.sum, t.n = t.sum + secs, t.n + 1
    s.time[f.name] = t
    fields[#fields + 1] = {'Level', level_text(f.name)}
    fields[#fields + 1] = {'Killed', string.format('%d (average %s a kill)', s.kills[f.name], mmss(t.sum / t.n)), 'good'}
    fields[#fields + 1] = {'Session', string.format('%d kill(s) in %s', s.total, mmss(os.time() - s.started))}
    show('KILL', f.name, fields)
end

---============================================================================
--- EVENTS
---============================================================================

local function on_engage()
    local mob, f = engaged_target(), session().fight
    if not mob or (f and f.id == mob.id) then return end
    if f then finish(false) end
    start(mob)
end

local function on_status(new, old)
    if new == STATUS_ENGAGED then return on_engage() end
    if old ~= STATUS_ENGAGED or not session().fight then return end
    local id = session().fight.id
    -- the defeat message usually comes first: a fight still open after the delay was left
    coroutine.schedule(function()
        local f = session().fight
        if f and f.id == id and not engaged_target() then finish(false) end
    end, LEFT_DELAY)
end

local function on_incoming(id, original)
    if id ~= 0x029 then return end
    local actor, target = original:unpack('I', 0x05), original:unpack('I', 0x09)
    local message = original:unpack('H', 0x19) % 32768
    local f = session().fight
    if DEATH[message] then
        if f and target == f.id then finish(true) end
        return
    end
    if CHECK[message] then
        local mob = windower.ffxi.get_mob_by_id(target) or windower.ffxi.get_mob_by_id(actor)
        local level = original:unpack('I', 0x0D)
        if mob and mob.is_npc and level and level > 0 then
            session().levels[mob.name] = {level = level, note = CHECK[message] ~= 'average' and CHECK[message] or nil}
            if f and mob.id == f.id then announce(f) end
        end
    end
end

local function add_melee(f, a)
    local m = f.melee
    if MELEE_HIT[a.message] then m.hits = m.hits + 1
    elseif MELEE_CRIT[a.message] then m.crits = m.crits + 1
    elseif MELEE_MISS[a.message] then m.misses = m.misses + 1 return
    else return end
    m.dmg, f.dmg = m.dmg + (a.param or 0), f.dmg + (a.param or 0)
end

local function add_ws(f, a)
    if WS_MISS[a.message] then f.ws.n, f.ws.misses = f.ws.n + 1, f.ws.misses + 1 return end
    if not WS_HIT[a.message] then return end
    f.ws.n, f.ws.dmg, f.dmg = f.ws.n + 1, f.ws.dmg + (a.param or 0), f.dmg + (a.param or 0)
end

local function on_action(act)
    local f, p = session().fight, windower.ffxi.get_player()
    if not f or not p or act.actor_id ~= p.id or (act.category ~= 1 and act.category ~= 3) then return end
    for _, target in ipairs(act.targets or {}) do
        if target.id == f.id then
            for _, a in ipairs(target.actions or {}) do
                if act.category == 1 then add_melee(f, a) else add_ws(f, a) end
            end
        end
    end
end

---============================================================================
--- INSTALL AND COMMAND
---============================================================================

--- Listen, once per load (raw events: a plain one from a job file runs GearSwap's refresh on every packet).
function FightTracker.init()
    if rawget(_G, '_fight_tracker_listening') then return end
    _G._fight_tracker_listening = true
    require('shared/utils/core/action_listener').on('fight_tracker', on_action)
    windower.raw_register_event('incoming chunk', function(id, original) pcall(on_incoming, id, original) end)
    windower.raw_register_event('status change', function(new, old) pcall(on_status, new, old) end)
    windower.raw_register_event('target change', function() pcall(on_engage) end)
    windower.raw_register_event('zone change', function() session().fight = nil end)
end

local function summary()
    local s, fields = session(), {}
    fields[1] = {'Chat blocks', s.on}
    fields[2] = {'Session', string.format('%d kill(s), %d fight(s) in %s', s.total, s.fights, mmss(os.time() - s.started))}
    local names = {}
    for name in pairs(s.kills) do names[#names + 1] = name end
    table.sort(names, function(a, b) return s.kills[a] > s.kills[b] end)
    for _, name in ipairs(names) do
        local t, lv = s.time[name], s.levels[name]
        fields[#fields + 1] = {name, string.format('%d kill(s), average %s%s', s.kills[name], mmss(t.sum / t.n), lv and (', Lv ' .. lv.level) or '')}
    end
    InfoBlock.show({tag = 'FIGHTS', title = 'This session', fields = fields})
end

--- //gs c fights [on|off|reset]
--- @param args table Words after "fights"
--- @return boolean true (handled)
function FightTracker.command(args)
    local word = args and args[1] and args[1]:lower()
    local s = session()
    if word == 'on' then s.on = true
    elseif word == 'off' then s.on = false
    elseif word == 'reset' then windower._fight_tracker = nil session().on = s.on end
    summary()
    return true
end

return FightTracker

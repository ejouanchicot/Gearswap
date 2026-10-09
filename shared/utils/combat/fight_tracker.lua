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
--- Off unless the player turned it on: nothing is listened to, no /check is
--- sent, no block is shown.
--- //gs c fights            the session: kills, time a kill, level by mob
--- //gs c fights on|off     the tracker on or off; the choice is kept
---                          (<Character>/saved/fights.on, as the trace does)
--- //gs c fights reset      a new session
--- //gs c fights hits on|off  one line a swing and a weaponskill (damage, critical or not, TP) in
---                          <Character>/logs/fights/<date>_hits.log, to check damage formulas against
---                          the game; kept until Windower closes. With _common/combat/FIGHTS_CONFIG.lua,
---                          the commands written there are sent to an alt when it starts and stops
--- //gs c fights hits <step>  a STEP line in that journal, after the commands FIGHTS_CONFIG.lua gives
---                          that step (your weapon, a mode...); a word it does not know is written
---                          as a plain MARK line. Swings and weaponskills are counted from that
---                          line on and shown every 50 swings / 5 weaponskills; with a goal
---                          (//gs c fights hits polearm 300, //gs c fights hits vorpal 20 ws, or
---                          `goal` / `unit` in the step) the count is shown against it and its end said.
---                          Each fight and each step also writes your job, every piece worn and,
---                          from a /checkparam <me> sent 3 s later, your accuracy and attack.
---                          The mob's own moves and spells (a Defense Boost it gives itself) and
---                          the spells others land on it (a Dispel) are written too, with the
---                          status gained or removed, so swings on a buffed mob can be set apart
--- //gs c fights hits run   the steps of FIGHTS_CONFIG.lua `sequence` one after the other, each
---                          started when the one before reached its goal, then the journal off.
---                          A step with `ws` uses that weaponskill itself once its `tp` is there:
---                          you only engage and fight
--- Each fight left and each kill is also a line of the day's journal,
--- <Character>/logs/fights/<date>.log.
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
-- 0x029 answers to /checkparam (res/action_messages.lua 712-715): two numbers each
local PARAM = {[712] = {'Primary Accuracy', 'Primary Attack'}, [713] = {'Auxiliary Accuracy', 'Auxiliary Attack'},
    [714] = {'Ranged Accuracy', 'Ranged Attack'}, [715] = {'Evasion', 'Defense'}}
local PARAM_DELAY = 3
local GEAR_SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear', 'body', 'hands',
    'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}

--- The marker file of the player's choice.
local function marker_path()
    if not (player and player.name) then return nil end
    local ok, path = pcall(function() return require('shared/utils/core/char_paths').writable('saved', 'fights.on') end)
    return ok and path or nil
end

--- Whether the player turned the tracker on. On windower.* (outlives a job
--- change) and in a marker file, read once: //lua r gearswap resets windower.*.
--- @return boolean
local function enabled()
    if windower._fight_tracker_on == nil then
        local path = marker_path()
        local file = path and io.open(path, 'r')
        windower._fight_tracker_on = file ~= nil
        if file then file:close() end
    end
    return windower._fight_tracker_on == true
end

--- Keep the player's choice: the marker file is there when on.
--- @param on boolean
local function set_enabled(on)
    windower._fight_tracker_on = on
    local path = marker_path()
    if not path then return end
    if on then
        local file = io.open(path, 'w')
        if file then file:write('on') file:close() end
    else
        os.remove(path)
    end
end

--- The session, kept on windower.* so a reload or a job change keeps it.
local function session()
    local s = windower._fight_tracker
    if not s then
        s = {started = os.time(), fights = 0, total = 0, kills = {}, time = {}, levels = {}, fight = nil}
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

--- One line of the day's journal (<Character>/logs/fights/<date>.log): the
--- block's title and its fields, so a session can be read after the game closed.
local function journal(tag, title, fields)
    local parts = {}
    for _, f in ipairs(fields) do parts[#parts + 1] = f[1] .. ': ' .. tostring(f[2]) end
    FightTracker.append('.log', ('%s %s | %s'):format(tag, title, table.concat(parts, ' | ')))
end

--- One timed line at the end of a file of the day in <Character>/logs/fights/.
--- @param suffix string '.log' (fights and kills) or '_hits.log' (every swing)
--- @param text string
function FightTracker.append(suffix, text)
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').log('fights', os.date('%Y-%m-%d') .. suffix)
    end)
    local file = ok and path and io.open(path, 'a')
    if not file then return end
    file:write(os.date('%H:%M:%S') .. ' ' .. text .. '\n')
    file:close()
end

local function show(tag, title, fields)
    if enabled() then InfoBlock.show({tag = tag, title = title, fields = fields}) end
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
    if not killed then
        journal('LEFT', f.name, fields)
        return show('FIGHT', f.name .. ' (left, not killed)', fields)
    end
    s.total = s.total + 1
    s.kills[f.name] = (s.kills[f.name] or 0) + 1
    local t = s.time[f.name] or {sum = 0, n = 0}
    t.sum, t.n = t.sum + secs, t.n + 1
    s.time[f.name] = t
    fields[#fields + 1] = {'Level', level_text(f.name)}
    fields[#fields + 1] = {'Killed', string.format('%d (average %s a kill)', s.kills[f.name], mmss(t.sum / t.n)), 'good'}
    fields[#fields + 1] = {'Session', string.format('%d kill(s) in %s', s.total, mmss(os.time() - s.started))}
    journal('KILL', f.name, fields)
    show('KILL', f.name, fields)
end

---============================================================================
--- EVENTS
---============================================================================

local function on_engage()
    if not enabled() then return end
    local mob, f = engaged_target(), session().fight
    if not mob or (f and f.id == mob.id) then return end
    if f then finish(false) end
    start(mob)
end

local function on_status(new, old)
    if not enabled() then return end
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
    if id ~= 0x029 or not enabled() then return end
    local actor, target = original:unpack('I', 0x05), original:unpack('I', 0x09)
    local message = original:unpack('H', 0x19) % 32768
    local f = session().fight
    if DEATH[message] then
        if f and target == f.id then finish(true) end
        return
    end
    if PARAM[message] and windower._fight_hits_on then
        FightTracker.append('_hits.log', ('PARAM %s %d | %s %d'):format(PARAM[message][1], original:unpack('I', 0x0D),
            PARAM[message][2], original:unpack('I', 0x11)))
        return
    end
    if CHECK[message] then
        local mob = windower.ffxi.get_mob_by_id(target) or windower.ffxi.get_mob_by_id(actor)
        local level = original:unpack('I', 0x0D)
        if mob and mob.is_npc and level and level > 0 then
            if windower._fight_hits_on then
                FightTracker.append('_hits.log', ('CHECK %s | Lv %d | %s'):format(mob.name, level, CHECK[message]))
            end
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

---============================================================================
--- EVERY SWING (//gs c fights hits on)
---============================================================================

local function names_of(ids, table_name)
    local ok, res = pcall(require, 'resources')
    local out = {}
    for _, id in ipairs(ids or {}) do
        local entry = ok and res[table_name] and res[table_name][id]
        out[#out + 1] = entry and entry.en or tostring(id)
    end
    return out
end

--- The count since the last STEP or MARK line: {swings, ws, goal, unit, label}.
local function hits_count()
    windower._fight_hits_count = windower._fight_hits_count or {swings = 0, ws = 0}
    return windower._fight_hits_count
end

local EVERY = {swings = 50, ws = 5}

--- One more swing or weaponskill: shown every EVERY of its kind, and when the goal is reached.
--- @param unit string 'swings' or 'ws'
local function hits_counted(unit)
    local c = hits_count()
    c[unit] = c[unit] + 1
    local reached = c.goal and c.unit == unit and c[unit] == c.goal
    if reached then c.done = true end
    if not reached and c[unit] % EVERY[unit] ~= 0 then return end
    local name = unit == 'ws' and 'Weaponskills' or 'Swings'
    InfoBlock.show({tag = 'FIGHTS', title = c.label or 'Measure', fields = {
        {name, c.goal and c.unit == unit and (c[unit] .. ' / ' .. c.goal) or tostring(c[unit])},
        reached and {'Goal', 'reached: next step'} or nil,
    }})
end

--- What the character is and wears now: a JOB line, a GEAR line, and a /checkparam <me> PARAM_DELAY
--- seconds later (its answer is written as PARAM lines by on_incoming), once the gear has settled.
--- @param p table windower.ffxi.get_player()
local function hits_snapshot(p)
    -- read from the game, not from GearSwap's `player.equipment`: outside its own events that table
    -- is the one of its last refresh (2026-10-09: the idle set was written for an engaged character)
    local items = windower.ffxi.get_items() or {}
    local worn, pieces, ok, res = items.equipment or {}, {}, pcall(require, 'resources')
    for _, slot in ipairs(GEAR_SLOTS) do
        local index, bag = worn[slot], worn[slot .. '_bag']
        local item = index and index > 0 and bag and windower.ffxi.get_items(bag, index)
        local info = ok and item and item.id and res.items[item.id]
        pieces[#pieces + 1] = slot .. '=' .. (info and info.en or 'empty')
    end
    FightTracker.append('_hits.log', ('JOB %s%s/%s%s | buffs %s'):format(tostring(p.main_job), tostring(p.main_job_level),
        tostring(p.sub_job), tostring(p.sub_job_level), table.concat(names_of(p.buffs, 'buffs'), ', ')))
    FightTracker.append('_hits.log', 'GEAR ' .. table.concat(pieces, ', '))
    coroutine.schedule(function()
        if windower._fight_hits_on then send_command('input /checkparam <me>') end
    end, PARAM_DELAY)
end

--- The fight's first lines: the mob, then what the character is and wears, once a fight.
local function hits_header(f, p)
    if f.hits_started then return end
    f.hits_started = true
    local lv = session().levels[f.name]
    FightTracker.append('_hits.log', ('FIGHT %s | %s'):format(f.name or '?',
        lv and ('Lv ' .. lv.level .. (lv.note and (', ' .. lv.note) or '')) or 'level not checked yet'))
    hits_snapshot(p)
end

--- A BUFFS line when the buffs up are not those of the swing before (a Berserk that wore off).
local function hits_buffs(f, p)
    local ids = {}
    for _, id in ipairs(p.buffs or {}) do ids[#ids + 1] = id end
    table.sort(ids)
    local signature = table.concat(ids, ',')
    if f.buffs_seen and f.buffs_seen ~= signature then
        FightTracker.append('_hits.log', 'BUFFS ' .. table.concat(names_of(ids, 'buffs'), ', '))
    end
    f.buffs_seen = signature
end

--- One line a swing (its round, damage, critical / hit / miss) or a weaponskill (its name and damage),
--- with the TP read when the packet came (after the swing or the weaponskill).
local function hits_line(f, p, act, a)
    hits_header(f, p)
    hits_buffs(f, p)
    local tp = p.vitals and p.vitals.tp or '?'
    if act.category == 1 then
        local kind = MELEE_CRIT[a.message] and 'crit' or MELEE_HIT[a.message] and 'hit' or 'miss'
        FightTracker.append('_hits.log', ('SWING round %d | %s | dmg %d | tp %s | msg %s'):format(f.round, kind,
            kind == 'miss' and 0 or (a.param or 0), tostring(tp), tostring(a.message)))
        hits_counted('swings')
    else
        local name = names_of({act.param}, 'weapon_skills')[1]
        FightTracker.append('_hits.log', ('WS %s | %s | dmg %d | tp after %s'):format(name,
            WS_HIT[a.message] and 'hit' or 'miss', WS_HIT[a.message] and (a.param or 0) or 0, tostring(tp)))
        hits_counted('ws')
    end
end

--- The character's _common/combat/FIGHTS_CONFIG.lua, or an empty table.
local function fights_config()
    local ok, cfg = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'FIGHTS_CONFIG')
    end)
    return ok and type(cfg) == 'table' and cfg or {}
end

--- The commands the player wants an alt to get when the per-swing journal starts or stops
--- (FIGHTS_CONFIG.lua: hits_alt, hits_on, hits_off). Nothing without them.
--- @param on boolean
local function tell_alt(on)
    local cfg = fights_config()
    if type(cfg.hits_alt) ~= 'string' then return end
    local commands = on and cfg.hits_on or not on and cfg.hits_off
    for _, command in ipairs(type(commands) == 'table' and commands or {}) do
        send_command('send ' .. cfg.hits_alt .. ' ' .. command)
    end
end

--- The goal typed after a step or a mark (`polearm 300`, `vorpal 20 ws`), else the step's own
--- (`goal`, `unit` in FIGHTS_CONFIG.lua). A number typed alone is a mark, not a goal.
--- @return number|nil goal, string unit 'swings' or 'ws'
local function goal_of(words, step)
    for i = 2, #words do
        local n = tonumber(words[i])
        if n then return n, (words[i + 1] or ''):lower() == 'ws' and 'ws' or 'swings' end
    end
    return tonumber(step.goal), step.unit == 'ws' and 'ws' or 'swings'
end

--- A step of a measuring session: its commands (FIGHTS_CONFIG.lua `steps`) run on this character,
--- then a STEP line in the journal. A name with no step there is a MARK line with the words typed.
--- @param words table The words after "hits"
local function hits_step(words)
    local name = words[1]:lower()
    local commands = (fights_config().steps or {})[name]
    local goal, unit = goal_of(words, type(commands) == 'table' and commands or {})
    windower._fight_hits_count = {swings = 0, ws = 0, goal = goal, unit = unit, label = table.concat(words, ' '),
        step = type(commands) == 'table' and commands or nil}
    if type(commands) ~= 'table' then
        FightTracker.append('_hits.log', 'MARK ' .. table.concat(words, ' '))
    else
        local ran = ''
        for i, command in ipairs(commands) do
            send_command(command)
            ran = ran .. (i > 1 and ' ; ' or '') .. command
        end
        FightTracker.append('_hits.log', 'STEP ' .. name .. ' | ' .. ran)
    end
    -- what is worn once the step's commands have run (a weapon change takes a moment)
    coroutine.schedule(function()
        local p = windower.ffxi.get_player()
        if p and windower._fight_hits_on then pcall(hits_snapshot, p) end
    end, PARAM_DELAY)
end

--- The journal on or off, with the alt told.
local function hits_switch(on)
    windower._fight_hits_on = on
    if on then
        set_enabled(true)
        FightTracker.init()
    else
        windower._fight_hits_run = nil
    end
    tell_alt(on)
end

--- //gs c fights hits [on|off|run|<step> ...]
local function hits_command(words)
    local word = (words[1] or 'on'):lower()
    if word == 'on' or word == 'off' then return hits_switch(word == 'on') end
    if word == 'run' then
        local sequence = fights_config().sequence
        if type(sequence) ~= 'table' or not sequence[1] then return end
        if not windower._fight_hits_on then hits_switch(true) end
        windower._fight_hits_run = {sequence = sequence, index = 1}
        return hits_step({sequence[1]})
    end
    if windower._fight_hits_on then hits_step(words) end
end

local WS_RETRY = 3

--- After a packet of swings or a weaponskill. A running sequence (//gs c fights hits run) goes to its
--- next step once the goal is reached, and stops the journal after the last. Else the step's own
--- weaponskill is used when the TP is there (`ws`, `tp` in the step; asked again after WS_RETRY s).
--- @param p table windower.ffxi.get_player()
local function hits_after(p)
    local c, run = hits_count(), windower._fight_hits_run
    if c.done and run then
        run.index = run.index + 1
        if run.sequence[run.index] then return hits_step({run.sequence[run.index]}) end
        InfoBlock.show({tag = 'FIGHTS', title = 'Measure', fields = {{'Sequence', 'finished, journal off'}}})
        return hits_switch(false)
    end
    local step, tp = c.step, p.vitals and p.vitals.tp or 0
    if step and step.ws and not c.done and tp >= (tonumber(step.tp) or 1000)
        and os.clock() - (c.ws_asked or -WS_RETRY) >= WS_RETRY then
        c.ws_asked = os.clock()
        send_command('input /ws "' .. step.ws .. '" <t>')
    end
end

-- 0x028 categories: a spell that finished, a monster's move that finished
local SPELL_DONE, MOB_MOVE = 4, 11

--- What happens to the mob besides the player's own hits: a MOB line for each of its moves and spells,
--- an ON-MOB line for each spell someone else lands on it, each with the message and the status named.
--- @param f table The fight
--- @param act table Action of anyone but the player
local function hits_mob(f, act)
    local by_mob = act.actor_id == f.id
    if act.category ~= SPELL_DONE and not (by_mob and act.category == MOB_MOVE) then return end
    local what = names_of({act.param}, act.category == SPELL_DONE and 'spells' or 'monster_abilities')[1]
    local actor = by_mob and 'MOB' or ('ON-MOB ' .. tostring((windower.ffxi.get_mob_by_id(act.actor_id) or {}).name))
    for _, target in ipairs(act.targets or {}) do
        for _, a in ipairs((by_mob or target.id == f.id) and target.actions or {}) do
            FightTracker.append('_hits.log', ('%s %s | msg %s | %s'):format(actor, what, tostring(a.message),
                (a.param or 0) > 0 and names_of({a.param}, 'buffs')[1] or '-'))
        end
    end
end

local function on_action(act)
    local f, p = session().fight, windower.ffxi.get_player()
    if f and p and act.actor_id ~= p.id and windower._fight_hits_on then pcall(hits_mob, f, act) end
    if not f or not p or act.actor_id ~= p.id or (act.category ~= 1 and act.category ~= 3) then return end
    if act.category == 1 then f.round = (f.round or 0) + 1 end
    for _, target in ipairs(act.targets or {}) do
        if target.id == f.id then
            for _, a in ipairs(target.actions or {}) do
                if act.category == 1 then add_melee(f, a) else add_ws(f, a) end
                if windower._fight_hits_on then pcall(hits_line, f, p, act, a) end
            end
        end
    end
    if windower._fight_hits_on then pcall(hits_after, p) end
end

---============================================================================
--- INSTALL AND COMMAND
---============================================================================

--- Listen, once per load, only when the player turned the tracker on (raw events: a plain one from a
--- job file runs GearSwap's refresh on every packet). Turned off later in the same load, the listeners
--- stay and do nothing.
function FightTracker.init()
    if not enabled() or rawget(_G, '_fight_tracker_listening') then return end
    _G._fight_tracker_listening = true
    require('shared/utils/core/action_listener').on('fight_tracker', on_action)
    windower.raw_register_event('incoming chunk', function(id, original) pcall(on_incoming, id, original) end)
    windower.raw_register_event('status change', function(new, old) pcall(on_status, new, old) end)
    windower.raw_register_event('target change', function() pcall(on_engage) end)
    windower.raw_register_event('zone change', function() session().fight = nil end)
end

local function summary()
    local s, fields = session(), {}
    fields[1] = {'Tracker', enabled()}
    if windower._fight_hits_on then fields[#fields + 1] = {'Every swing', 'written to logs/fights/<date>_hits.log'} end
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
    if word == 'on' then
        set_enabled(true)
        FightTracker.init()
    elseif word == 'off' then
        set_enabled(false)
        s.fight = nil
    elseif word == 'reset' then
        windower._fight_tracker = nil
    elseif word == 'hits' then
        local words = {}
        for i = 2, #args do words[#words + 1] = args[i] end
        hits_command(words)
    end
    summary()
    return true
end

return FightTracker

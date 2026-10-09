---============================================================================
--- Fight Hits - a journal of every swing and weaponskill (//gs c fights hits)
---============================================================================
--- The measuring half of the fight tracker (fight_tracker.lua feeds it the
--- actions it already listens to): what the game really answers, written to
--- <Character>/logs/fights/<date>_hits.log so damage formulas can be checked
--- against it afterwards.
---   SWING    one a swing: its round, hit / crit / miss, damage, TP, message
---   WS       one a weaponskill: name, damage, the TP before and after
---   WSGEAR   the pieces worn when the weaponskill is readied, and when it lands
---   FIGHT, JOB, GEAR, PARAM   the mob, what the character is and wears, and
---            its accuracy / attack from a /checkparam <me> sent 3 s later
---   BUFFS    the buffs up, each time they change between two swings
---   MOB, ON-MOB   the mob's own moves and spells, the spells others land on
---            it, with the status gained or removed (a Defense Boost, a Dispel)
---   STEP, MARK    the parts of a session (//gs c fights hits <step>)
---
--- Steps come from <Character>/_common/combat/FIGHTS_CONFIG.lua (every key is
--- explained there): commands run on this character, a goal counted in swings
--- or weaponskills, a weaponskill used by itself at a TP, abilities kept up.
--- //gs c fights hits run plays its `sequence`. Nothing here moves, targets
--- or engages the character.
---
--- The journal's state lives on windower.* (kept through a job change, lost
--- when Windower closes or on //lua r gearswap).
---
--- @file    shared/utils/combat/fight_hits.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-09
---============================================================================

local FightHits = {}

local InfoBlock = require('shared/utils/messages/info_block')

-- 0x028 results of a swing and of a weaponskill (fight_tracker.lua reads them from here)
FightHits.MELEE_HIT, FightHits.MELEE_CRIT = {[1] = true}, {[67] = true}
FightHits.WS_HIT, FightHits.WS_MISS = {[185] = true}, {[188] = true}
-- 0x028 categories: a spell that finished, a weaponskill readied, a monster's move that finished
local SPELL_DONE, MOB_MOVE = 4, 11
-- 0x028 message "<number> of <target>'s effects disappears!": its number is a count, not a status
local SEVERAL_REMOVED = 792
FightHits.WS_READY = 7

-- 0x029 answers to /checkparam (res/action_messages.lua 712-715): two numbers each
local PARAM = {[712] = {'Primary Accuracy', 'Primary Attack'}, [713] = {'Auxiliary Accuracy', 'Auxiliary Attack'},
    [714] = {'Ranged Accuracy', 'Ranged Attack'}, [715] = {'Evasion', 'Defense'}}
local PARAM_DELAY = 3
local GEAR_SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear', 'body', 'hands',
    'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}
local EVERY = {swings = 50, ws = 5}
-- seconds before a weaponskill or a kept ability is asked again
local WS_RETRY, KEEP_RETRY = 3, 5
local FILE = '_hits.log'

-- set by fight_tracker.lua: enable() turns the tracker on, level(name) gives a mob's checked level as
-- text, fighting() says whether a fight is open
FightHits.hooks = {enable = function() end, level = function() return nil end, fighting = function() return false end}

--- One timed line at the end of a file of the day in <Character>/logs/fights/.
--- @param suffix string '.log' (fights and kills) or '_hits.log' (this journal)
--- @param text string
function FightHits.append(suffix, text)
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').log('fights', os.date('%Y-%m-%d') .. suffix)
    end)
    local file = ok and path and io.open(path, 'a')
    if not file then return end
    file:write(os.date('%H:%M:%S') .. ' ' .. text .. '\n')
    file:close()
end

local function write(text)
    FightHits.append(FILE, text)
end

--- @return boolean True while the journal is on
function FightHits.on()
    return windower._fight_hits_on == true
end

local function names_of(ids, table_name)
    local ok, res = pcall(require, 'resources')
    local out = {}
    for _, id in ipairs(ids or {}) do
        local entry = ok and res[table_name] and res[table_name][id]
        out[#out + 1] = entry and entry.en or tostring(id)
    end
    return out
end

--- The count since the last STEP or MARK line: {swings, ws, goal, unit, label, step, last_tp}.
local function count()
    windower._fight_hits_count = windower._fight_hits_count or {swings = 0, ws = 0}
    return windower._fight_hits_count
end

---============================================================================
--- WHAT THE CHARACTER IS AND WEARS
---============================================================================

--- The pieces worn right now, read from the game: GearSwap's `player.equipment` is, outside its own
--- events, the table of its last refresh (2026-10-09: the idle set written for an engaged character).
--- @return string "main=..., sub=..., ..."
local function worn()
    local items = windower.ffxi.get_items() or {}
    local equipment, pieces, ok, res = items.equipment or {}, {}, pcall(require, 'resources')
    for _, slot in ipairs(GEAR_SLOTS) do
        local index, bag = equipment[slot], equipment[slot .. '_bag']
        local item = index and index > 0 and bag and windower.ffxi.get_items(bag, index)
        local info = ok and item and item.id and res.items[item.id]
        pieces[#pieces + 1] = slot .. '=' .. (info and info.en or 'empty')
    end
    return table.concat(pieces, ', ')
end

--- A JOB line, a GEAR line, and a /checkparam <me> PARAM_DELAY seconds later (its answer is written
--- as PARAM lines by FightHits.param), once the gear has settled.
--- @param p table windower.ffxi.get_player()
local function snapshot(p)
    write(('JOB %s%s/%s%s | buffs %s'):format(tostring(p.main_job), tostring(p.main_job_level),
        tostring(p.sub_job), tostring(p.sub_job_level), table.concat(names_of(p.buffs, 'buffs'), ', ')))
    write('GEAR ' .. worn())
    coroutine.schedule(function()
        if FightHits.on() then send_command('input /checkparam <me>') end
    end, PARAM_DELAY)
end

--- The pieces worn around a weaponskill: when it is readied (its own set) and when it lands.
--- @param moment string 'ready' or 'done'
function FightHits.ws_gear(moment)
    write('WSGEAR ' .. moment .. ' | ' .. worn())
end

--- A /checkparam answer, written as a PARAM line.
--- @param message number 0x029 message id
--- @param original string The packet
--- @return boolean True when the message was one
function FightHits.param(message, original)
    if not PARAM[message] then return false end
    write(('PARAM %s %d | %s %d'):format(PARAM[message][1], original:unpack('I', 0x0D),
        PARAM[message][2], original:unpack('I', 0x11)))
    return true
end

--- A /check answer, written as a CHECK line.
function FightHits.check(name, level, note)
    write(('CHECK %s | Lv %d | %s'):format(tostring(name), level, tostring(note)))
end

---============================================================================
--- SWINGS AND WEAPONSKILLS
---============================================================================

--- The fight's first lines: the mob, then what the character is and wears, once a fight.
local function header(f, p)
    if f.hits_started then return end
    f.hits_started = true
    write(('FIGHT %s | %s'):format(f.name or '?', FightHits.hooks.level(f.name) or 'level not checked yet'))
    snapshot(p)
end

--- A BUFFS line when the buffs up are not those of the swing before (a Berserk that wore off).
local function buffs_changed(f, p)
    local ids = {}
    for _, id in ipairs(p.buffs or {}) do ids[#ids + 1] = id end
    table.sort(ids)
    local signature = table.concat(ids, ',')
    if f.buffs_seen and f.buffs_seen ~= signature then
        write('BUFFS ' .. table.concat(names_of(ids, 'buffs'), ', '))
    end
    f.buffs_seen = signature
end

--- The buffs on the character, by lower-case name.
local function buffs_up(p)
    local up = {}
    for _, name in ipairs(names_of(p.buffs, 'buffs')) do up[name:lower()] = true end
    return up
end

--- True when the step's conditions are met: every ability it keeps up (`keep`) and the buff it
--- measures under (`under`, an Aftermath level for instance) are on the character.
local function kept_up(p, step)
    if not step then return true end
    local up = buffs_up(p)
    for _, name in ipairs(step.keep or {}) do
        if not up[name:lower()] then return false end
    end
    return not step.under or up[step.under:lower()] == true
end

--- One more swing or weaponskill: shown every EVERY of its kind, and when the goal is reached.
--- In a step that keeps abilities up, only what happens under them is counted.
--- @param unit string 'swings' or 'ws'
--- @param p table windower.ffxi.get_player()
local function counted(unit, p)
    local c = count()
    if not kept_up(p, c.step) then return end
    c[unit] = c[unit] + 1
    local reached = c.goal and c.unit == unit and c[unit] == c.goal
    if reached then c.done = true end
    if not reached and c[unit] % EVERY[unit] ~= 0 then return end
    InfoBlock.show({tag = 'FIGHTS', title = c.label or 'Measure', fields = {
        {unit == 'ws' and 'Weaponskills' or 'Swings', c.goal and c.unit == unit and (c[unit] .. ' / ' .. c.goal) or tostring(c[unit])},
        reached and {'Goal', 'reached: next step'} or nil,
    }})
end

--- One line a swing (its round, damage, critical / hit / miss) or a weaponskill (its name, damage,
--- the TP of the swing before and the TP read when its packet came).
--- @param f table The fight
--- @param p table windower.ffxi.get_player()
--- @param act table The action (category 1 or 3)
--- @param a table One of its results on the mob
function FightHits.line(f, p, act, a)
    header(f, p)
    buffs_changed(f, p)
    local c, tp = count(), p.vitals and p.vitals.tp or '?'
    if act.category == 1 then
        local kind = FightHits.MELEE_CRIT[a.message] and 'crit' or FightHits.MELEE_HIT[a.message] and 'hit' or 'miss'
        write(('SWING round %d | %s | dmg %d | tp %s | msg %s'):format(f.round or 0, kind,
            kind == 'miss' and 0 or (a.param or 0), tostring(tp), tostring(a.message)))
        c.last_tp = tp
        return counted('swings', p)
    end
    local landed = FightHits.WS_HIT[a.message]
    write(('WS %s | %s | dmg %d | tp before %s | tp after %s'):format(names_of({act.param}, 'weapon_skills')[1],
        landed and 'hit' or 'miss', landed and (a.param or 0) or 0, tostring(c.last_tp or '?'), tostring(tp)))
    FightHits.ws_gear('done')
    counted('ws', p)
end

--- What happens to the mob besides the player's own hits: a MOB line for each of its moves and spells,
--- an ON-MOB line for each spell someone else lands on it, each with the message and the status named.
--- @param f table The fight
--- @param act table Action of anyone but the player
function FightHits.other(f, act)
    local by_mob = act.actor_id == f.id
    if act.category ~= SPELL_DONE and not (by_mob and act.category == MOB_MOVE) then return end
    local what = names_of({act.param}, act.category == SPELL_DONE and 'spells' or 'monster_abilities')[1]
    local actor = by_mob and 'MOB' or ('ON-MOB ' .. tostring((windower.ffxi.get_mob_by_id(act.actor_id) or {}).name))
    for _, target in ipairs(act.targets or {}) do
        for _, a in ipairs((by_mob or target.id == f.id) and target.actions or {}) do
            local status = (a.param or 0) > 0 and names_of({a.param}, 'buffs')[1] or '-'
            if a.message == SEVERAL_REMOVED then status = tostring(a.param) .. ' effects removed' end
            write(('%s %s | msg %s | %s'):format(actor, what, tostring(a.message), status))
        end
    end
end

---============================================================================
--- STEPS, SEQUENCE AND COMMAND
---============================================================================

--- The character's _common/combat/FIGHTS_CONFIG.lua, or an empty table.
local function config()
    local ok, cfg = pcall(function()
        return require('shared/utils/core/char_paths').optional('common', 'FIGHTS_CONFIG')
    end)
    return ok and type(cfg) == 'table' and cfg or {}
end

--- The commands the player wants an alt to get when the journal starts or stops
--- (FIGHTS_CONFIG.lua: hits_alt, hits_on, hits_off). Nothing without them.
--- @param on boolean
local function tell_alt(on)
    local cfg = config()
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
local function step(words)
    local name = words[1]:lower()
    local commands = (config().steps or {})[name]
    local goal, unit = goal_of(words, type(commands) == 'table' and commands or {})
    windower._fight_hits_count = {swings = 0, ws = 0, goal = goal, unit = unit, label = table.concat(words, ' '),
        step = type(commands) == 'table' and commands or nil}
    if type(commands) ~= 'table' then
        write('MARK ' .. table.concat(words, ' '))
    else
        -- the commands alone: Windower's table.concat also joins the named fields (goal, ws...)
        local ran = ''
        for i, command in ipairs(commands) do
            send_command(command)
            ran = ran .. (i > 1 and ' ; ' or '') .. command
        end
        write('STEP ' .. name .. ' | ' .. ran)
    end
    -- what is worn once the step's commands have run (a weapon change takes a moment)
    coroutine.schedule(function()
        local p = windower.ffxi.get_player()
        if p and FightHits.on() then pcall(snapshot, p) end
    end, PARAM_DELAY)
end

--- The journal on or off, with the alt told. Stopped in the middle of a fight, the alt keeps its
--- orders until that mob is dead (FightHits.fight_ended): cut at once, it left the player alone
--- with the mob (2026-10-09).
local function switch(on)
    windower._fight_hits_on = on
    if on then
        windower._fight_hits_alt_pending = nil
        FightHits.hooks.enable()
        return tell_alt(true)
    end
    windower._fight_hits_run = nil
    if not FightHits.hooks.fighting() then return tell_alt(false) end
    windower._fight_hits_alt_pending = true
    InfoBlock.show({tag = 'FIGHTS', title = 'Measure', fields = {{'Journal', 'off'}, {'Alt', 'stops when this mob is dead'}}})
end

--- The fight is over (the mob dead, or left): the alt's stop orders held back by switch() go now.
function FightHits.fight_ended()
    if not windower._fight_hits_alt_pending then return end
    windower._fight_hits_alt_pending = nil
    tell_alt(false)
end

--- //gs c fights hits [on|off|run [sequence]|<step> ...]
--- @param words table The words after "hits"
function FightHits.command(words)
    local word = (words[1] or 'on'):lower()
    if word == 'on' or word == 'off' then return switch(word == 'on') end
    if word == 'run' then
        local cfg = config()
        local sequence = words[2] and (cfg.sequences or {})[words[2]:lower()] or cfg.sequence
        if type(sequence) ~= 'table' or not sequence[1] then return end
        if not FightHits.on() then switch(true) end
        windower._fight_hits_run = {sequence = sequence, index = 1}
        return step({sequence[1]})
    end
    if FightHits.on() then step(words) end
end

--- True when an ability can be used now (its recast is over).
local function ability_ready(name)
    local ok, res = pcall(require, 'resources')
    for _, ability in pairs(ok and res.job_abilities or {}) do
        if ability.en == name then
            return (windower.ffxi.get_ability_recasts()[ability.recast_id] or 0) == 0
        end
    end
    return false
end

--- The abilities a step keeps up (`keep`): the first one missing and ready is used, one every
--- KEEP_RETRY seconds (a refused ability must not be asked at every swing).
local function keep_up(p, c)
    local up = buffs_up(p)
    for _, name in ipairs(c.step.keep or {}) do
        if not up[name:lower()] and os.clock() - (c.keep_asked or -KEEP_RETRY) >= KEEP_RETRY and ability_ready(name) then
            c.keep_asked = os.clock()
            return send_command('input /ja "' .. name .. '" <me>')
        end
    end
end

--- After a packet of swings or a weaponskill. A running sequence (//gs c fights hits run) goes to its
--- next step once the goal is reached, and stops the journal after the last. Else the step's kept
--- abilities are used when missing, and its own weaponskill when the TP is there (`ws`, `tp`; asked
--- again after WS_RETRY s). A step that measures under a buff (`under`) uses its weaponskill only
--- while that buff is missing: the weaponskill is what gives it (an Aftermath).
--- @param p table windower.ffxi.get_player()
function FightHits.after(p)
    local c, run = count(), windower._fight_hits_run
    if c.done and run then
        run.index = run.index + 1
        if run.sequence[run.index] then return step({run.sequence[run.index]}) end
        InfoBlock.show({tag = 'FIGHTS', title = 'Measure', fields = {{'Sequence', 'finished'}}})
        return switch(false)
    end
    if not c.step or c.done then return end
    keep_up(p, c)
    local tp = p.vitals and p.vitals.tp or 0
    local wanted = c.step.ws and not (c.step.under and buffs_up(p)[c.step.under:lower()])
    if wanted and tp >= (tonumber(c.step.tp) or 1000) and os.clock() - (c.ws_asked or -WS_RETRY) >= WS_RETRY then
        c.ws_asked = os.clock()
        send_command('input /ws "' .. c.step.ws .. '" <t>')
    end
end

return FightHits

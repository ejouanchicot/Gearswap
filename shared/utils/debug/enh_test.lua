---============================================================================
--- Enhancing Test - a spell's real duration, piece by piece
---============================================================================
--- Plays a list of cases and writes what the game answered, so the duration
--- formulas of the Atelier can be checked against the game before they are
--- used (2026-10-14, Red Mage enhancing magic).
---
--- A case: the pieces to wear (every other slot is emptied), Composure on or
--- off, a spell and its target. Between two cases the character is back in
--- its own sets: a Refresh III is kept up there and the MP are waited for
--- when they run short (a case is cast with almost nothing on). The pieces are put on, every slot is then
--- held (gs disable all) so the job's own precast and midcast sets cannot
--- change them, the spell is cast, and the buff's length is read from the
--- game's own buff packet (shared/utils/buffs/buff_timers.lua): on this
--- character for a spell cast on oneself, on the target's GearSwap for a
--- spell cast on another character of the box group, which sends it back.
---
---   //gs c enhtest run <plan>    plays a plan of <Char>/_common/tools/ENHTEST_CONFIG.lua
---   //gs c enhtest stop          stops and gives the slots back
---   //gs c enhtest plans         the plans of the config
---
--- Sent between the two characters (send addon), not typed:
---   //gs c enhtest expect <buff id> <caster>   the target drops that buff and waits for it
---   //gs c enhtest got <buff id> <seconds>     the target's answer
---
--- The result goes to <Char>/logs/enhtest/<date>.log, one line a case:
---   CASE listed20 | Haste II on Kaories | Composure off | 240 s | sub=Ammurapi Shield, waist=Embla Sash
--- A length is the buff's end minus the second its packet came: +/- 1 s.
---
--- A case with natural = true is cast in the character's own sets instead (nothing put on, nothing held): what
--- GearSwap really wears for that spell and that target.
---
--- A case can also measure what the spell gives, where the game shows it out of a fight:
---   measure = 'stat', stat = 'MND'   the attribute just before the cast, from the game's stats packet, the
---                                    case's pieces on; stat = {'MND', 'VIT'} reads several. The game sends that
---                                    packet when the gear changes, not when a buff comes: a Gain shows in the
---                                    reading of the case after it (a Gain does not replace a stronger one, so the
---                                    cases go from the weakest to the strongest)
---   measure = 'mp'                   the MP gained at each tick with the buff, then without it (a Refresh):
---                                    the difference is what the spell gives, whatever the pieces give themselves
---   measure = 'hp'                   the same with the HP (a Regen). Out of a fight the HP are full: the
---                                    character is first emptied of every piece, then the case's pieces go on;
---                                    the HP they add are missing, and the Regen has something to fill. The
---                                    case's pieces must add more HP than the ticks watched give back.
---
--- @file shared/utils/debug/enh_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-14
---============================================================================

local EnhTest = {}

local SLOTS = {'main', 'sub', 'range', 'ammo', 'head', 'neck', 'left_ear', 'right_ear', 'body', 'hands',
    'left_ring', 'right_ring', 'back', 'waist', 'legs', 'feet'}
local COMPOSURE = 419             -- res/buffs.lua
local GEAR_SETTLE = 2.5           -- seconds for the pieces to be on before the slots are held
local AFTER_ABILITY = 2.0         -- seconds after Composure before the cast
local AFTER_DROP = 1.5            -- seconds for a dropped buff to be gone
local RESULT_WAIT = 25            -- seconds a cast is given to answer
local RECAST_WAIT = 90            -- seconds a spell's recast is waited for
local BETWEEN = 1.5               -- seconds between two cases
local REFRESH = 43                -- res/buffs.lua
local REFRESH_SPELL = 'Refresh III'
local REFRESH_CAST = 7            -- seconds for that spell to be cast, in the character's own sets
local MP_MARGIN = 150             -- MP kept above the spell's cost before a case starts
local MP_WAIT = 600               -- seconds the MP are waited for, at most
local MP_WINDOW = 10              -- seconds the MP are watched, with the buff then without (three ticks)
local MP_EVERY = 0.5              -- seconds between two looks at the MP

local run = nil                   -- the plan being played: {cases, at, token, plan}
local expecting = {}              -- target side: [buff id] = {caster, until}

local function res() return require('resources') end

local function say(text)
    local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
    if ok and MessageFormatter then MessageFormatter.show_debug('EnhTest', text) end
end

local function write(text)
    local ok, path = pcall(function()
        return require('shared/utils/core/char_paths').log('enhtest', os.date('%Y-%m-%d') .. '.log')
    end)
    local file = ok and path and io.open(path, 'a')
    if not file then return end
    file:write(os.date('%H:%M:%S') .. ' ' .. text .. '\n')
    file:close()
end

--- A file of the character's _common/tools/, run, or nil.
local function tools_file(name)
    local ok, path = pcall(function() return require('shared/utils/core/char_paths').file('common', name) end)
    if not (ok and path) then return nil end
    local read, out = pcall(dofile, path)
    return read and out or nil
end

--- The character's ENHTEST_CONFIG.lua, read again at each run (a plan is changed between two runs). A config that
--- is a function is given ENHTEST_SETS.lua's table (sets written by a script from the set file), or nil.
--- @return table|nil
local function config()
    local cfg = tools_file('ENHTEST_CONFIG.lua')
    if type(cfg) == 'function' then cfg = cfg(tools_file('ENHTEST_SETS.lua')) end
    return type(cfg) == 'table' and cfg or nil
end

--- A spell of the game's data by its name.
--- @return table|nil
local function spell_named(name)
    for _, spell in pairs(res().spells) do
        if spell.en == name then return spell end
    end
    return nil
end

--- True when this character has that buff.
local function has_buff(id)
    for _, buff in ipairs((windower.ffxi.get_player() or {}).buffs or {}) do
        if buff == id then return true end
    end
    return false
end

--- "sub=Ammurapi Shield, waist=Embla Sash": what is really worn, slot by slot. Read from the game's bags:
--- GearSwap's player.equipment is only refreshed inside its own events, so from a coroutine it can still show
--- the set before.
local function worn_text()
    local equipment = (windower.ffxi.get_items() or {}).equipment or {}
    local parts = {}
    for _, slot in ipairs(SLOTS) do
        local index, bag = equipment[slot], equipment[slot .. '_bag']
        local item = index and index ~= 0 and bag and windower.ffxi.get_items(bag, index)
        local known = item and item.id and res().items[item.id]
        if known then parts[#parts + 1] = slot .. '=' .. known.en end
    end
    return #parts > 0 and table.concat(parts, ', ') or 'nothing'
end

--- The MP or HP now, from the game (GearSwap's player.mp is refreshed in its own events only).
--- @param field string 'mp' or 'hp'
local function vital_now(field)
    local vitals = (windower.ffxi.get_player() or {}).vitals
    return vitals and vitals[field] or 0
end
local function mp_now() return vital_now('mp') end

--- An attribute as the game last sent it (stats packet 0x061): its base plus what gear and buffs add.
--- @param name string 'STR', 'MND'...
--- @return number|nil
local function stat_now(name)
    local raw = windower.packets and windower.packets.last_incoming and windower.packets.last_incoming(0x061)
    local ok, packets = pcall(require, 'packets')
    local parsed = raw and ok and packets.parse('incoming', raw)
    if type(parsed) ~= 'table' then return nil end
    return (parsed['Base ' .. name] or 0) + (parsed['Added ' .. name] or 0)
end

--- "MND 173 VIT 138" for a case's `stat`: one name, or several ({'MND', 'VIT'}).
local function stats_text(stat)
    local parts = {}
    for _, name in ipairs(type(stat) == 'table' and stat or {stat}) do
        parts[#parts + 1] = name .. ' ' .. tostring(stat_now(name))
    end
    return table.concat(parts, ' ')
end

local function give_slots_back()
    send_command('gs enable all')
    if type(sets) == 'table' then sets.enhtest = nil end
end

local next_case

--- The case's line, then the next case.
--- @param seconds number|nil The buff's length, nil when nothing answered
--- @param measured string|nil What a `measure` case read
local function conclude(seconds, measured)
    local case = run and run.case
    if not case then return end
    run.case = nil
    local line = ('CASE %s | %s on %s | Composure %s | %s | %s%s'):format(case.name or '?', case.spell, case.target_name,
        has_buff(COMPOSURE) and 'on' or 'off', seconds and (seconds .. ' s') or 'NO ANSWER',
        measured and (measured .. ' | ') or '', case.worn or '?')
    write(line)
    say(line)
    give_slots_back()
    local token = run.token
    coroutine.schedule(function() if run and run.token == token then next_case() end end, BETWEEN)
end

--- The MP or HP gained at each tick for MP_WINDOW seconds, as "+15 +15 +15".
--- @param field string 'mp' or 'hp'
--- @param done function Called with that text
local function watch_vital(token, field, done)
    local last, gains, left = vital_now(field), {}, math.floor(MP_WINDOW / MP_EVERY)
    local function look()
        if not (run and run.token == token) then return end
        local value = vital_now(field)
        if value > last then gains[#gains + 1] = '+' .. (value - last) end
        last, left = value, left - 1
        if left > 0 then return coroutine.schedule(look, MP_EVERY) end
        done(#gains > 0 and table.concat(gains, ' ') or 'nothing gained')
    end
    coroutine.schedule(look, MP_EVERY)
end

--- What a `measure` case reads once its buff is on, then its line.
local function measure(token, case, seconds)
    case.answered = true
    if case.measure == 'stat' then
        return conclude(seconds, 'before: ' .. tostring(case.stat_before))
    end
    local field = case.measure
    watch_vital(token, field, function(with)
        if not (run and run.case == case) then return end
        windower.ffxi.cancel_buff(case.buff)
        coroutine.schedule(function()
            watch_vital(token, field, function(without)
                if run and run.case == case then
                    conclude(seconds, ('%s a tick with: %s | without: %s | %s left to fill: %d'):format(field:upper(), with,
                        without, field:upper(), ((windower.ffxi.get_player() or {}).vitals or {})['max_' .. field]
                        and (windower.ffxi.get_player().vitals['max_' .. field] - vital_now(field)) or -1))
                end
            end)
        end, AFTER_DROP)
    end)
end

--- Cast the case's spell once its recast is up, and wait for the answer.
local function cast(token, case, waited)
    if not (run and run.token == token) then return end
    local recast = (windower.ffxi.get_spell_recasts() or {})[case.spell_id] or 0
    if recast > 0 and waited < RECAST_WAIT then
        return coroutine.schedule(function() cast(token, case, waited + 1) end, 1)
    end
    case.worn = case.natural and 'her own sets' or worn_text()
    if case.measure == 'stat' then case.stat_before = stats_text(case.stat) end
    run.case = case
    send_command(('input /ma "%s" %s'):format(case.spell, case.on_self and '<me>' or case.target_name))
    coroutine.schedule(function()
        if run and run.token == token and run.case == case and not case.answered then conclude(nil) end
    end, RESULT_WAIT)
end

--- The buff the spell gives is taken off whoever receives it, so the next one is a new buff with its full length.
local function drop_then_cast(token, case)
    if not (run and run.token == token) then return end
    if case.on_self then
        if has_buff(case.buff) then windower.ffxi.cancel_buff(case.buff) end
    else
        send_command(('send %s gs c enhtest expect %d %s'):format(case.target_name, case.buff, player.name))
    end
    coroutine.schedule(function() cast(token, case, 0) end, AFTER_DROP)
end

--- The case's pieces put on, every other slot emptied, then every slot held.
local function wear(token, case)
    if not (run and run.token == token) then return end
    local set, bare = {}, {}
    for _, slot in ipairs(SLOTS) do set[slot], bare[slot] = case.gear[slot] or empty, empty end
    send_command('gs enable all')
    if case.measure == 'hp' and not case.emptied then
        -- emptied first, the case's pieces a moment later: the HP they add are then missing
        case.emptied = true
        sets.enhtest = bare
        send_command('gs equip sets.enhtest')
        return coroutine.schedule(function() wear(token, case) end, GEAR_SETTLE)
    end
    if case.natural then
        -- the character's own sets: nothing put on, nothing held
        sets.enhtest = nil
        return coroutine.schedule(function() drop_then_cast(token, case) end, case.measure == 'hp' and GEAR_SETTLE or 0.3)
    end
    sets.enhtest = set
    send_command('gs equip sets.enhtest')
    coroutine.schedule(function()
        if not (run and run.token == token) then return end
        send_command('gs disable all')
        coroutine.schedule(function() drop_then_cast(token, case) end, 0.5)
    end, GEAR_SETTLE)
end

--- Composure as the case wants it, BEFORE the pieces: the ability's own precast and aftercast sets would
--- take them off.
local function set_composure(token, case)
    if not (run and run.token == token) then return end
    local wait = 0.1
    if case.composure == true and not has_buff(COMPOSURE) then
        send_command('input /ja "Composure" <me>')
        wait = AFTER_ABILITY
    elseif case.composure == false and has_buff(COMPOSURE) then
        windower.ffxi.cancel_buff(COMPOSURE)
        wait = AFTER_DROP
    end
    coroutine.schedule(function() wear(token, case) end, wait)
end

--- Enough MP for the case, waited for in the character's own sets (the slots are free between two cases).
local function wait_for_mp(token, case, waited)
    if not (run and run.token == token) then return end
    local need = (case.mp_cost or 0) + MP_MARGIN
    if mp_now() < need and waited < MP_WAIT then
        if waited == 0 then say(('waiting for %d MP (%d now)'):format(need, mp_now())) end
        return coroutine.schedule(function() wait_for_mp(token, case, waited + 3) end, 3)
    end
    set_composure(token, case)
end

--- A case is cast with almost nothing on: the MP come from a Refresh kept up between the cases, cast in the
--- character's own sets, and from waiting when they run short.
local function keep_refresh(token, case)
    if not (run and run.token == token) then return end
    if case.buff ~= REFRESH and not has_buff(REFRESH) and spell_named(REFRESH_SPELL) then
        send_command(('input /ma "%s" <me>'):format(REFRESH_SPELL))
        return coroutine.schedule(function() wait_for_mp(token, case, 0) end, REFRESH_CAST)
    end
    wait_for_mp(token, case, 0)
end

next_case = function()
    if not run then return end
    run.at = run.at + 1
    local case = run.cases[run.at]
    if not case then
        write(('END plan %s'):format(run.plan))
        say(('plan %s done: %d cases'):format(run.plan, #run.cases))
        run = nil
        return give_slots_back()
    end
    local spell = spell_named(case.spell or '')
    if not (spell and spell.status) then
        write(('CASE %s | unknown spell or a spell that gives no buff: %s'):format(case.name or '?', tostring(case.spell)))
        return next_case()
    end
    local target = case.target and case.target ~= 'me' and case.target or player.name
    local this = {name = case.name, spell = case.spell, spell_id = spell.id, buff = spell.status, composure = case.composure,
        target_name = target, on_self = target == player.name, gear = case.gear or {}, mp_cost = spell.mp_cost, natural = case.natural,
        measure = case.measure, stat = case.stat}
    say(('case %d/%d: %s'):format(run.at, #run.cases, case.name or '?'))
    send_command('gs enable all')
    keep_refresh(run.token, this)
end

--- A buff appeared or was cast again on this character (buff_timers.lua).
--- @param id number Buff id
--- @param seconds number Its length
function EnhTest.on_buff(id, seconds)
    local wanted = expecting[id]
    if wanted and os.time() <= wanted.until_time then
        expecting[id] = nil
        send_command(('send %s gs c enhtest got %d %d'):format(wanted.caster, id, seconds))
    end
    local case = run and run.case
    if case and case.on_self and case.buff == id and not case.answered then
        if case.measure then return measure(run.token, case, seconds) end
        conclude(seconds)
    end
end

--- This module hears of every buff gained while it is in use (buff_timers.lua calls its watcher).
local function listen()
    require('shared/utils/buffs/buff_timers').watcher = EnhTest.on_buff
end

local function start(plan)
    listen()
    local cfg = config()
    local cases = cfg and cfg.plans and cfg.plans[plan or '']
    if not cases then return say('no such plan in ENHTEST_CONFIG.lua: ' .. tostring(plan)) end
    run = {cases = cases, at = 0, token = os.clock(), plan = plan}
    write(('START plan %s, %d cases, %s %s/%s'):format(plan, #cases, player.name, player.main_job, player.sub_job or ''))
    next_case()
end

--- //gs c enhtest ...
--- @param args table The words after `enhtest`
--- @return boolean handled
function EnhTest.command(args)
    local action = (args[1] or ''):lower()
    if action == 'run' then
        start(args[2])
    elseif action == 'stop' then
        run = nil
        give_slots_back()
        say('stopped')
    elseif action == 'plans' then
        local names = {}
        for name in pairs((config() or {}).plans or {}) do names[#names + 1] = name end
        table.sort(names)
        say('plans: ' .. (#names > 0 and table.concat(names, ', ') or 'none'))
    elseif action == 'expect' and tonumber(args[2]) and args[3] then
        local id = tonumber(args[2])
        listen()
        if has_buff(id) then windower.ffxi.cancel_buff(id) end
        expecting[id] = {caster = args[3], until_time = os.time() + RESULT_WAIT + RECAST_WAIT}
    elseif action == 'got' and tonumber(args[2]) and tonumber(args[3]) then
        if run and run.case and not run.case.on_self and run.case.buff == tonumber(args[2]) then
            conclude(tonumber(args[3]))
        end
    else
        say('//gs c enhtest run <plan> | stop | plans')
    end
    return true
end

return EnhTest

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
---   //gs c enhtest run <plan> [n] plays a plan of <Char>/_common/tools/ENHTEST_CONFIG.lua (from its case n)
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
---   measure = 'resist', resist = 'Fire'   a Barspell: that resistance with nothing on, before the cast and after
---                                    (stats packet 0x061, sent again by emptying the slots)
---   measure = 'enspell', procs = 25  a tier I Enspell's damage on the next melee hits, read in the character's own
---                                    sets (it is set at the cast): shared/utils/debug/enh_test_fight.lua
---   measure = 'taken', hits = 40     the next swings the character takes, in her own sets (Phalanx, Spikes);
---                                    until_lost = true reads them until the buff is gone instead (Stoneskin)
--- cast = false reads without casting (the case's spell names the buff taken off first); drop_buffs = {ids} takes
--- other buffs off before (Blink's shadows, a Phalanx under a Stoneskin case).
---
---   measure = 'enfeeble'         an enfeeble cast on the party's battle target (<bt>): landed or resisted, its
---                                    length to the wear-off, the mob's rounds and paralysis meanwhile
---                                    (shared/utils/debug/enf_watch.lua); with cast = false, the mob's rounds alone
---                                    for `read` seconds (the reference). A mob defeated first: the case played again
---                                    on the next one (twice at most). saboteur = true / false: Saboteur put on or
---                                    taken off before the pieces, like Composure
---
--- In a fight: fight = true waits for the character to be engaged before the case; keep_weapons = true leaves main,
--- sub, range and ammo as they are (the other slots are emptied as usual); pause_bot = true turns Silmaril off
--- (sm off) while the case is cast and back on after, so its own casts do not cut in.
---
--- @file shared/utils/debug/enh_test.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-10-14
---============================================================================

local EnhTest = {}

local Read = require('shared/utils/debug/enh_test_read')
local SLOTS = Read.SLOTS
local COMPOSURE = 419             -- res/buffs.lua
local SABOTEUR, SABOTEUR_RECAST = 454, 36   -- res/buffs.lua, res/job_abilities.lua recast_id
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
local STATS_WAIT = 4              -- seconds for the stats packet after a change of gear (it came 2.5 s and more late)
local BOT_SETTLE = 3              -- seconds after sm off for a cast of Silmaril's own to end
local FIGHT_WAIT = 1800           -- seconds a case waits for the character to be engaged
local FIGHT_MARGIN = 5            -- seconds an Enspell is read for less than its length
local FIGHT_READ = 300            -- seconds the hits taken are read for, at most
local WEAPONS = {main = true, sub = true, range = true, ammo = true}
local WEAR_TRIES = 3              -- times a case's pieces are put on again when the game does not show them
local ENF_WAIT = 1500             -- seconds an enfeeble is followed to its wear-off, at most
local ENF_REPLAYS = 2             -- times a case is played again when its mob is defeated first
local ENF_BUSY_WAIT, ENF_BUSY_TRIES = 30, 20   -- the status already on the mob: cast again after 30 s, 10 min at most

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
--- is a function is given ENHTEST_SETS.lua's table (sets written by a script from the set file), or nil, then
--- GearSwap's own sets (the job's sets as loaded: a case can take a real set's pieces).
--- @return table|nil
local function config()
    local cfg = tools_file('ENHTEST_CONFIG.lua')
    if type(cfg) == 'function' then cfg = cfg(tools_file('ENHTEST_SETS.lua'), sets) end
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

local worn_text, wrong_slots, stats_text, resist_now = Read.worn_text, Read.wrong_slots, Read.stats_text, Read.resist
local function vital_now(field) return Read.vital(field) end
local function mp_now() return Read.vital('mp') end

local function give_slots_back()
    send_command('gs enable all')
    if type(sets) == 'table' then sets.enhtest = nil end
end

--- The character's own sets, then every slot emptied, then `after` once the game sent its stats again. Through
--- her own sets first: emptying slots already empty changes nothing, and the game would send nothing.
local function emptied_then(token, case, after)
    send_command('gs enable all')
    send_command('gs c update')
    coroutine.schedule(function()
        if not (run and run.token == token) then return end
        sets.enhtest = case.bare
        send_command('gs equip sets.enhtest')
        coroutine.schedule(function()
            if run and run.token == token then after() end
        end, STATS_WAIT)
    end, GEAR_SETTLE)
end

--- Silmaril off while a case with pause_bot is cast, back on after.
local function bot(case, on)
    if not (case and case.pause_bot) or (case.bot_off or false) == not on then return end
    case.bot_off = not on
    send_command(on and 'sm on' or 'sm off')
end

local next_case
local retreat   -- below: a case's cast put off while the character is low
local follow_enfeeble, enfeeble_end   -- below, after conclude

--- The character's HP in percent, from the game.
local function hpp_now() return ((windower.ffxi.get_player() or {}).vitals or {}).hpp or 100 end

--- True when a case taking hits must not keep the character bare and unhealed any longer (Silmaril paused, the slots
--- held): she died twice so on 2026-10-14.
local function too_low(case) return case.abort_hpp ~= nil and hpp_now() < case.abort_hpp end

--- The case's line, then the next case.
--- @param seconds number|nil The buff's length, nil when nothing answered
--- @param measured string|nil What a `measure` case read
local function conclude(seconds, measured, wait)
    local case = run and run.case
    if not case then return end
    run.case = nil
    local line = ('CASE %s | %s on %s | Composure %s%s | %s | %s%s'):format(case.name or '?', case.spell, case.target_name,
        has_buff(COMPOSURE) and 'on' or 'off', case.saboteur_at_cast ~= nil and (' | Saboteur ' .. (case.saboteur_at_cast and 'on' or 'off')) or '', seconds and (seconds .. ' s') or (case.cast == false and 'not cast' or 'NO ANSWER'),
        measured and (measured .. ' | ') or '', case.worn or '?')
    write(line)
    say(line)
    give_slots_back()
    bot(case, true)
    local token = run.token
    coroutine.schedule(function() if run and run.token == token then next_case() end end, BETWEEN + (wait or 0))
end

--- An enfeeble's line. Its mob defeated before the wear-off: the same case again on the next mob (run.replays).
--- The same status still on the mob ("no effect", message 75: a stopped run's last cast, 2026-10-14): the case
--- again every ENF_BUSY_WAIT seconds until it wears off.
enfeeble_end = function(case, length, text, defeated)
    local replays, busy = run.replays[run.at] or 0, run.busy[run.at] or 0
    if defeated and replays < ENF_REPLAYS then
        run.replays[run.at] = replays + 1
        run.at = run.at - 1
        text = text .. ' | played again'
    elseif text:find('^NO EFFECT') and busy < ENF_BUSY_TRIES then
        run.busy[run.at] = busy + 1
        run.at = run.at - 1
        return conclude(length, text .. (' | already on the mob, cast again in %d s'):format(ENF_BUSY_WAIT), ENF_BUSY_WAIT)
    end
    conclude(length, text)
end

--- Follow the case's enfeeble from its cast: once it landed, her own sets and Silmaril are given back for the wait.
follow_enfeeble = function(token, case)
    case.answered = true
    require('shared/utils/debug/enf_watch').cast(case.spell_id, case.buff, ENF_WAIT, function()
        if not (run and run.case == case) then return end
        give_slots_back()
        send_command('gs c update')
        bot(case, true)
    end, function(length, text, defeated)
        if run and run.case == case then enfeeble_end(case, length, text, defeated) end
    end)
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
    if case.measure == 'resist' then
        -- the slots emptied again: a change of gear makes the game send its stats, the Barspell now in them
        return emptied_then(token, case, function()
            if run and run.case == case then
                conclude(seconds, ('%s resistance, nothing on: %s before, %s after'):format(case.resist,
                    tostring(case.resist_before), tostring(resist_now(case.resist))))
            end
        end)
    end
    if case.measure == 'enspell' then
        -- her own sets back on (the damage was set at the cast), Silmaril back on to keep fighting
        give_slots_back()
        send_command('gs c update')
        bot(case, true)
        return require('shared/utils/debug/enh_test_fight').enspell(case.procs or 25,
            (seconds or 0) - FIGHT_MARGIN, function(text)
                if run and run.case == case then conclude(seconds, text) end
            end)
    end
    if case.measure == 'enfeeble' then
        -- cast = false: the mob's rounds with no enfeeble of hers (the reference for Slow and Paralyze)
        local mob = windower.ffxi.get_mob_by_target('bt')
        if not mob then return conclude(nil, 'no battle target') end
        give_slots_back()
        bot(case, true)
        return require('shared/utils/debug/enf_watch').rounds(mob.id, case.read or 180, function(length, text, defeated)
            if run and run.case == case then enfeeble_end(case, length, text, defeated) end
        end)
    end
    if case.measure == 'taken' then
        -- her own sets back on: every case is read in the same gear, only the buff changes
        give_slots_back()
        send_command('gs c update')
        bot(case, true)
        return require('shared/utils/debug/enh_test_fight').taken(case.hits or 40, FIGHT_READ,
            case.until_lost and case.buff or nil, function(text)
                if run and run.case == case then conclude(seconds, text) end
            end)
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
    if too_low(case) then return retreat(token, case) end
    case.worn = case.natural and 'her own sets' or worn_text()
    if case.measure == 'stat' then case.stat_before = stats_text(case.stat) end
    if case.saboteur ~= nil then case.saboteur_at_cast = has_buff(SABOTEUR) end
    run.case = case
    if case.measure == 'enfeeble' then follow_enfeeble(token, case) end
    send_command(('input /ma "%s" %s'):format(case.spell, case.on_self and '<me>' or case.target_name))
    if case.measure == 'enfeeble' then return end
    coroutine.schedule(function()
        if run and run.token == token and run.case == case and not case.answered then conclude(nil) end
    end, RESULT_WAIT)
end

--- The buff the spell gives is taken off whoever receives it, so the next one is a new buff with its full length.
local function drop_then_cast(token, case)
    if not (run and run.token == token) then return end
    for _, id in ipairs(case.drop_buffs or {}) do
        if has_buff(id) then windower.ffxi.cancel_buff(id) end
    end
    if case.on_self then
        if has_buff(case.buff) then windower.ffxi.cancel_buff(case.buff) end
    elseif case.measure ~= 'enfeeble' then
        send_command(('send %s gs c enhtest expect %d %s'):format(case.target_name, case.buff, player.name))
    end
    if case.cast == false then
        -- read without the buff: nothing cast, the case's spell only names the buff taken off
        case.worn = 'not cast'
        run.case = case
        return coroutine.schedule(function()
            if run and run.case == case then measure(token, case, nil) end
        end, AFTER_DROP)
    end
    coroutine.schedule(function() cast(token, case, 0) end, AFTER_DROP)
end

--- The case's pieces put on, every other slot emptied, then every slot held.
local function wear(token, case)
    if not (run and run.token == token) then return end
    local set, bare = {}, {}
    for _, slot in ipairs(SLOTS) do
        -- a slot left nil in a set is not touched: the weapons a fight is fought with stay
        if not (case.keep_weapons and WEAPONS[slot]) then set[slot], bare[slot] = case.gear[slot] or empty, empty end
    end
    case.bare = bare
    send_command('gs enable all')
    if case.measure == 'resist' and not case.emptied then
        -- the Barspell taken off, the slots emptied: the resistance read before, with nothing on
        case.emptied = true
        if has_buff(case.buff) then windower.ffxi.cancel_buff(case.buff) end
        return emptied_then(token, case, function()
            case.resist_before = resist_now(case.resist)
            wear(token, case)
        end)
    end
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
        coroutine.schedule(function()
            if not (run and run.token == token) then return end
            -- a cast of Silmaril's own ending in between puts her sets back over the pieces (2026-10-14): again
            if too_low(case) then return retreat(token, case) end
            local wrong = wrong_slots(set)
            if wrong and (case.tries or 0) < WEAR_TRIES then
                case.tries = (case.tries or 0) + 1
                say('pieces not on (' .. wrong .. '), put on again')
                return wear(token, case)
            end
            drop_then_cast(token, case)
        end, 0.5)
    end, GEAR_SETTLE)
end

--- Saboteur as the case wants it, after Composure and before the pieces (its recast waited for: 3 minutes).
local function set_saboteur(token, case, waited)
    if not (run and run.token == token) then return end
    if case.saboteur == false and has_buff(SABOTEUR) then
        windower.ffxi.cancel_buff(SABOTEUR)
        return coroutine.schedule(function() wear(token, case) end, AFTER_DROP)
    end
    if case.saboteur ~= true or has_buff(SABOTEUR) then return wear(token, case) end
    local recast = (windower.ffxi.get_ability_recasts() or {})[SABOTEUR_RECAST] or 0
    if recast > 0 and waited < 300 then
        if waited == 0 then say(('waiting %d s for Saboteur'):format(math.ceil(recast))) end
        return coroutine.schedule(function() set_saboteur(token, case, waited + 2) end, 2)
    end
    send_command('input /ja "Saboteur" <me>')
    coroutine.schedule(function() wear(token, case) end, AFTER_ABILITY)
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
    coroutine.schedule(function() set_saboteur(token, case, 0) end, wait)
end

--- Enough MP for the case, waited for in the character's own sets (the slots are free between two cases).
local function wait_for_mp(token, case, waited)
    if not (run and run.token == token) then return end
    local need = (case.mp_cost or 0) + MP_MARGIN
    if mp_now() < need and waited < MP_WAIT then
        if waited == 0 then say(('waiting for %d MP (%d now)'):format(need, mp_now())) end
        return coroutine.schedule(function() wait_for_mp(token, case, waited + 3) end, 3)
    end
    if case.min_hpp and hpp_now() < case.min_hpp then
        -- Silmaril still on: it heals her before she is paused and bared for the cast
        if not case.hp_said then case.hp_said = true; say(('waiting for %d %% HP (%d now)'):format(case.min_hpp, hpp_now())) end
        return coroutine.schedule(function() wait_for_mp(token, case, waited) end, 1)
    end
    case.hp_said = nil
    run.paused = case.pause_bot and case or nil
    bot(case, false)
    coroutine.schedule(function() set_composure(token, case) end, case.pause_bot and BOT_SETTLE or 0)
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

--- The cast put off: her sets and Silmaril back at once, the case started again once she is healed (min_hpp).
retreat = function(token, case)
    give_slots_back()
    send_command('gs c update')
    bot(case, true)
    case.tries, case.emptied = nil, nil
    say(('HP %d %%: cast put off until she is healed'):format(hpp_now()))
    coroutine.schedule(function()
        if run and run.token == token then keep_refresh(token, case) end
    end, BOT_SETTLE)
end

--- A fight case waits for the character to be engaged; then Silmaril is paused when the case asks for it.
local function when_engaged(token, case, waited)
    if not (run and run.token == token) then return end
    local engaged = (windower.ffxi.get_player() or {}).status == 1
    -- an enfeeble needs the party's mob: after a defeat, the next one pulled (2026-10-14, cast at nothing)
    local mob = case.measure == 'enfeeble' and windower.ffxi.get_mob_by_target('bt')
    local no_mob = case.measure == 'enfeeble' and not (mob and (mob.hpp or 0) > 0)
    if (no_mob or case.fight and not engaged) and waited < FIGHT_WAIT then
        if waited == 0 then say(no_mob and 'waiting for a mob' or 'waiting for a fight') end
        return coroutine.schedule(function() when_engaged(token, case, waited + 2) end, 2)
    end
    keep_refresh(token, case)
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
    local target = case.measure == 'enfeeble' and '<bt>' or case.target and case.target ~= 'me' and case.target or player.name
    local this = {name = case.name, spell = case.spell, spell_id = spell.id, buff = spell.status, composure = case.composure,
        target_name = target, on_self = target == player.name, gear = case.gear or {}, mp_cost = spell.mp_cost, natural = case.natural,
        measure = case.measure, stat = case.stat, resist = case.resist, procs = case.procs, fight = case.fight,
        keep_weapons = case.keep_weapons, pause_bot = case.pause_bot, hits = case.hits, cast = case.cast,
        until_lost = case.until_lost, drop_buffs = case.drop_buffs, min_hpp = case.min_hpp, abort_hpp = case.abort_hpp,
        saboteur = case.saboteur, read = case.read}
    say(('case %d/%d: %s'):format(run.at, #run.cases, case.name or '?'))
    if case.say then say(case.say) end
    send_command('gs enable all')
    when_engaged(run.token, this, 0)
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

--- @param from number|nil The case to start at (1 by default): a plan broken off is taken up where it stopped
local function start(plan, from)
    listen()
    local cfg = config()
    local cases = cfg and cfg.plans and cfg.plans[plan or '']
    if not cases then return say('no such plan in ENHTEST_CONFIG.lua: ' .. tostring(plan)) end
    local first = math.max(1, math.floor(tonumber(from) or 1))
    run = {cases = cases, at = first - 1, token = os.clock(), plan = plan, replays = {}, busy = {}}
    write(('START plan %s, %d cases from %d, %s %s/%s'):format(plan, #cases, first, player.name, player.main_job,
        player.sub_job or ''))
    -- a plan's own commands first (cases.start: the Silmaril profile it is played with), then its cases
    for _, cmd in ipairs(type(cases.start) == 'table' and cases.start or {}) do send_command(cmd) end
    local token = run.token
    coroutine.schedule(function() if run and run.token == token then next_case() end end, cases.start and BOT_SETTLE or 0)
end

--- //gs c enhtest ...
--- @param args table The words after `enhtest`
--- @return boolean handled
function EnhTest.command(args)
    local action = (args[1] or ''):lower()
    if action == 'run' then
        start(args[2], args[3])
    elseif action == 'stop' then
        if run and run.paused then bot(run.paused, true) end
        require('shared/utils/debug/enh_test_fight').stop()
        require('shared/utils/debug/enf_watch').stop()
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

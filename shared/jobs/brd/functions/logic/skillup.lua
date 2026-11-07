---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Instrument Skill-up Loop
---  ═══════════════════════════════════════════════════════════════════════════
---   //gs c skillup horn | harp | off | status
---
---   Sings buff songs on yourself one after the other with one instrument held,
---   so its skill (Wind Instrument for a horn, String Instrument for a harp)
---   goes up, until //gs c skillup off. The player's way (2026-11-07): any buff
---   song on yourself; Army's Paeon VI, V, IV, III, II in turn, the next one as
---   soon as the one before is done (each song has its own recast, so there is
---   no wait for one song's recast).
---
---   The instrument: the song's own set is equipped as usual, then, for the loop's
---   songs only, the range slot gets the instrument of the loop and the ammo slot
---   is emptied (midcast_router.lua handle_singing reads SkillUp.instrument());
---   another song keeps its own (Honor March its Marsyas, a dummy song Daurdabla).
---
---   The loop looks every POLL seconds. A song counts as sung when its recast
---   starts; the next one goes GAP seconds after the last action ended (the last
---   time midaction was seen: a song's recast can start before its cast is over,
---   and a song sent right at its end was refused by the game, 2026-11-07), once
---   you are Idle: the first of the list, from the one after the last sung, whose
---   recast is ready. A song not learned is left out at the start. A song refused
---   (no action started REFUSED_AFTER seconds after it was sent) is sent again
---   after the gap; one started whose recast never comes (interrupted, moved) is a
---   failure after PENDING_TIMEOUT seconds; MAX_FAILS in a row stop the loop. It
---   stops by itself when the job is not BRD, when you are dead or engaged. Each
---   step goes in the trace (//gs c trace, tag SKILLUP).
---
---   No stop at the skill cap: the game's skill figures can't be read here with
---   their cap, so the player stops the loop.
---
---   Settings (<Character>/brd/combat/BRD_SONG_CONFIG.lua, shared/utils/core/job_config.lua; all optional):
---     skillup = {songs = {"Army's Paeon VI", "Army's Paeon V"}, horn = 'Loughnashade', harp = 'Daurdabla', gap = 3}
---
---   @file    shared/jobs/brd/functions/logic/skillup.lua
---   @author  ejouanchicot
---   @version 1.2
---   @date    Created: 2026-11-07
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')

local SkillUp = {}

local DEFAULTS = {songs = {"Army's Paeon VI", "Army's Paeon V", "Army's Paeon IV", "Army's Paeon III", "Army's Paeon II"},
    horn = 'Loughnashade', harp = 'Daurdabla', gap = 3}
local SKILL_OF = {horn = 'Wind Instrument', harp = 'String Instrument'}
local POLL = 0.5
local PENDING_TIMEOUT = 15
local REFUSED_AFTER = 4
local MAX_FAILS = 5

-- counter: raised on every start and stop, so a scheduled poll of an older loop does nothing.
-- songs: {name, recast_id} in turn; next: the index tried first; pending: the song sent, its recast not
-- started yet (sent_at); done_at: when the last one was seen sung
local STATE = {active = false, counter = 0, kind = nil, instrument = nil, songs = {}, by_name = {}, next = 1,
    pending = nil, started = false, sent_at = nil, done_at = nil, last_busy = nil, gap = 3, sung = 0, fails = 0}

--- The loop's instrument for one of its songs while it runs (midcast_router.lua), nil otherwise
--- @param song string|nil The song being sung (spell.english); nil asks whether the loop runs
--- @return string|nil
function SkillUp.instrument(song)
    if not STATE.active or (song ~= nil and not STATE.by_name[song]) then return nil end
    return STATE.instrument
end

--- A line in the trace (//gs c trace: shared/utils/debug/trace_log.lua), when it loads
local function trace(fmt, ...)
    local ok, TraceLog = pcall(require, 'shared/utils/debug/trace_log')
    if ok and type(TraceLog) == 'table' and TraceLog.log then pcall(TraceLog.log, 'SKILLUP', fmt, ...) end
end

--- Whether the loop can go on: still BRD, alive, not engaged
local function can_sing()
    return player and player.main_job == 'BRD' and player.status ~= 'Dead' and player.status ~= 'Engaged'
end

local function halt(reason)
    if not STATE.active then return false end
    STATE.active = false
    STATE.counter = STATE.counter + 1
    trace('stop: %s, %d sung', tostring(reason or 'asked'), STATE.sung)
    if reason then MessageFormatter.show_warning('[BRD] Skill-up stopped: ' .. reason .. ' (' .. STATE.sung .. ' songs sung)') end
    return true
end

--- Another action under way (GearSwap's midaction), false when it can't be told
local function busy()
    local f = rawget(_G, 'midaction')
    if type(f) ~= 'function' then return false end
    local ok, mid = pcall(f)
    return ok and mid and true or false
end

--- The pending song: sung once its recast runs, a failure once it waited too long
--- @return boolean false when the loop must stop
local function settle(recasts, now)
    local p = STATE.pending
    if not p then return true end
    if (recasts[p.recast_id] or 0) > 0 then
        STATE.sung, STATE.fails, STATE.pending, STATE.done_at = STATE.sung + 1, 0, nil, now
        trace('sung %s: %d', p.name, STATE.sung)
    elseif not STATE.started and now - STATE.sent_at >= REFUSED_AFTER then
        STATE.fails, STATE.pending, STATE.last_busy = STATE.fails + 1, nil, now
        trace('%s refused (no action %ds after it was sent): fail %d', p.name, REFUSED_AFTER, STATE.fails)
        if STATE.fails >= MAX_FAILS then halt(MAX_FAILS .. ' songs in a row did not go through'); return false end
    elseif now - STATE.sent_at > PENDING_TIMEOUT then
        STATE.fails, STATE.pending = STATE.fails + 1, nil
        trace('no recast for %s %ds after it was sent: fail %d', p.name, PENDING_TIMEOUT, STATE.fails)
        if STATE.fails >= MAX_FAILS then halt(MAX_FAILS .. ' songs in a row did not go through'); return false end
    end
    return true
end

--- The next song to sing: the first ready one from STATE.next on, in the list's order
local function next_song(recasts)
    local n = #STATE.songs
    for i = 0, n - 1 do
        local at = (STATE.next - 1 + i) % n + 1
        local song = STATE.songs[at]
        if (recasts[song.recast_id] or 0) == 0 then return song, at end
    end
    return nil
end

local function poll(my_counter)
    if not STATE.active or STATE.counter ~= my_counter then return end
    if not can_sing() then return halt('not a BRD idle any more') end
    local recasts = windower.ffxi.get_spell_recasts()
    if type(recasts) ~= 'table' then return halt('the song recasts cannot be read') end
    local now = os.time()
    if busy() then
        STATE.last_busy = now
        if STATE.pending then STATE.started = true end
    end
    if not settle(recasts, now) then return end
    -- (idle only: no song sent in a cutscene, mounted, resting; never over another action, whose gear the
    -- song's precast would replace; GAP after the last song, the game's own pause between two casts)
    local ready = not STATE.pending and player.status == 'Idle' and not busy()
        and (not STATE.last_busy or now - STATE.last_busy >= STATE.gap)
        and (not STATE.done_at or now - STATE.done_at >= STATE.gap)
    local song, at = nil, nil
    if ready then song, at = next_song(recasts) end
    if song then
        STATE.pending, STATE.started, STATE.sent_at, STATE.next = song, false, now, at % #STATE.songs + 1
        trace('cast %s (%s)', song.name, STATE.instrument)
        send_command('input /ma "' .. song.name .. '" <me>')
    end
    coroutine.schedule(function() poll(my_counter) end, POLL)
end

--- The game's data of a spell by its English name: GearSwap's own resources (gearswap.res: roll_gear.lua),
--- else the library as the BRD's other files read it (song_slots.lua); a plain search of the table, no
--- :with. Before 2026-11-07 it read `res.spells:with` alone: "unknown song" in game for a song learned
--- @param name string
--- @return table|nil
local function spell_named(name)
    local gsw = rawget(_G, 'gearswap')
    local data = (type(gsw) == 'table' and gsw.res) or rawget(_G, 'res') or (rawget(_G, 'gs') and gs.res)
    if not (data and data.spells) then
        local ok, lib = pcall(require, 'resources')
        data = ok and lib or nil
    end
    for _, spell in pairs(data and data.spells or {}) do
        if type(spell) == 'table' and spell.en == name then return spell end
    end
    return nil
end

--- The songs of the settings this character can sing, and the names left out (unknown or not learned)
--- @param names table
--- @return table songs, table left
local function songs_of(names)
    local ok, learned = pcall(windower.ffxi.get_spells)
    learned = ok and type(learned) == 'table' and learned or nil
    local songs, left = {}, {}
    for _, name in ipairs(names) do
        local spell = spell_named(name)
        if spell and (not learned or learned[spell.id] ~= false) then
            songs[#songs + 1] = {name = name, recast_id = spell.recast_id}
        else
            left[#left + 1] = name
        end
    end
    return songs, left
end

--- Start the loop for a horn or a harp
--- @param kind string 'horn' or 'harp'
local function start(kind)
    local cfg = require('shared/utils/core/job_config').get('BRD', 'skillup', DEFAULTS)
    if not can_sing() then
        MessageFormatter.show_error('[BRD] Skill-up: only as a BRD, not engaged')
        return
    end
    local songs, left = songs_of(cfg.songs)
    if #left > 0 then MessageFormatter.show_warning('[BRD] Skill-up: left out (unknown or not learned): ' .. table.concat(left, ', ')) end
    if #songs == 0 then
        MessageFormatter.show_error('[BRD] Skill-up: no song to sing')
        return
    end
    halt()
    STATE.active = true
    STATE.counter = STATE.counter + 1
    STATE.kind, STATE.instrument, STATE.songs, STATE.gap = kind, cfg[kind], songs, tonumber(cfg.gap) or 3
    STATE.by_name = {}
    for _, song in ipairs(songs) do STATE.by_name[song.name] = true end
    STATE.next, STATE.pending, STATE.sent_at, STATE.done_at, STATE.sung, STATE.fails = 1, nil, nil, nil, 0, 0
    STATE.started, STATE.last_busy = false, nil
    local names = {}
    for _, song in ipairs(songs) do names[#names + 1] = song.name end
    MessageFormatter.show_success('[BRD] Skill-up ' .. SKILL_OF[kind] .. ' with ' .. STATE.instrument .. ': '
        .. table.concat(names, ', ') .. ' on you, in turn. //gs c skillup off to stop.')
    trace('start %s with %s: %s', kind, STATE.instrument, table.concat(names, ', '))
    local my_counter = STATE.counter
    poll(my_counter)
end

--- //gs c skillup [horn|harp|off|status]
--- @param arg string|nil
function SkillUp.handle(arg)
    local sub = arg and arg:lower() or 'status'
    if sub == 'horn' or sub == 'wind' then return start('horn') end
    if sub == 'harp' or sub == 'string' then return start('harp') end
    if sub == 'off' or sub == 'stop' then
        if halt() then MessageFormatter.show_success('[BRD] Skill-up stopped (' .. STATE.sung .. ' songs sung)')
        else MessageFormatter.show_info('[BRD] Skill-up is not running') end
        return
    end
    if STATE.active then
        MessageFormatter.show_info('[BRD] Skill-up ' .. SKILL_OF[STATE.kind] .. ' running with ' .. STATE.instrument
            .. ', ' .. STATE.sung .. ' songs sung')
    else
        MessageFormatter.show_info('[BRD] Skill-up is not running: //gs c skillup horn | harp')
    end
end

--- Stop without a word (job unload)
function SkillUp.cancel()
    halt()
end

_G.BRDSkillUp = SkillUp
return SkillUp

---============================================================================
--- BRD Song Queue - sing a list of songs one after the other, whatever the lag
---============================================================================
--- A rotation used to be scheduled in advance, one song every N seconds. A
--- song slower than N (less Fast Cast, lag, a Marcato slipped in first) made
--- the next /ma arrive mid-cast, the game refused it, and the song was lost.
---
--- Here the next song goes out only once the previous one is over:
---   - its aftercast came in (any BardSong: Marcato re-sends the song, and
---     SongRefinement may send another tier under another name), then a
---     short gap for the post-cast delay;
---   - interrupted: sung again, at most MAX_RETRIES times, then skipped with
---     a warning;
---   - the cast never starts (shared/utils/core/cast_tracker.lua: no "cast
---     started" packet within START_WINDOW, nor any other action such as a
---     Marcato sent first): refused by the game, a failed try at once;
---   - started but no aftercast within its cast time (computed from the
---     precast set, shared/utils/precast/cast_time.lua) + END_MARGIN: a
---     failed try (packet lost).
--- Starting a queue, or //gs c songstop, drops the one running.
---
--- The queue lives on `windower`: a gs reload keeps it going, the next
--- load's aftercast carries it on. Every timer checks the queue's sequence
--- number, so a stale one does nothing.
---
--- @file    shared/jobs/brd/functions/logic/song_queue.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local SongQueue = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')

local DEFAULT_GAP = 3.0       -- after a cast, before the next /ma is accepted (1.5 was refused in game, 3.0 chosen)
local DEFAULT_LOCKED_EXTRA = 1.0 -- more after Honor March / Aria of Passion: the song after was refused at 2.5
local START_WINDOW = 2.5      -- a /ma the game accepts starts casting by then
local JA_FIRST_WAIT = 3.0     -- a Marcato sent first: the song follows 2 s later
local END_MARGIN = 3.0        -- added to the computed cast time
local CAST_TIMEOUT = 12       -- cast time unknown
local MAX_RETRIES = 2

local CastTracker = require('shared/utils/core/cast_tracker')

--- Gap after a song, from BRD_TIMING_CONFIG when it sets one. A song that
--- holds its own instrument for the cast (Marsyas, Loughnashade) needs more
--- before the next one goes through.
--- @param song string|nil The song that just ended
local function gap(song)
    local timing = rawget(_G, 'BRDTimingConfig')
    local rotation = type(timing) == 'table' and timing.ROTATION_DELAYS or {}
    local delay = rotation.after_song or DEFAULT_GAP
    local ok, Lock = pcall(require, 'shared/jobs/brd/functions/logic/instrument_lock_config')
    if song and ok and Lock.requires_lock and Lock.requires_lock(song) then
        delay = delay + (rotation.after_locked_song or DEFAULT_LOCKED_EXTRA)
    end
    return delay
end

local function current()
    return windower._brd_song_queue
end

--- A line of //gs c trace (shared/utils/debug/trace_log.lua), when it is on:
--- each song sent, ended, tried again or skipped, with its place in the list.
local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('SONGS', fmt, unpack(args)) end)
end

local send_step

--- Run `fn` after `delay` if the queue has not moved on meanwhile.
local function later(queue, delay, fn)
    local seq, index, tries = queue.seq, queue.index, queue.tries
    coroutine.schedule(function()
        local q = current()
        if q and q.seq == seq and q.index == index and q.tries == tries then fn(q) end
    end, delay)
end

local function advance(queue, ended_song)
    queue.index, queue.tries = queue.index + 1, 0
    later(queue, gap(ended_song), send_step)
end

local function retry(queue, reason)
    trace('queue: %s failed (%s), try %d', tostring(queue.songs[queue.index]), reason, queue.tries + 1)
    if queue.tries >= MAX_RETRIES then
        MessageFormatter.show_warning(('Songs: %s skipped (%s).'):format(queue.songs[queue.index], reason))
        return advance(queue)
    end
    queue.tries = queue.tries + 1
    later(queue, gap(), send_step)
end

--- Cast time computed at this song's precast, when it is this song's.
local function computed_cast_time()
    local computed = rawget(_G, '_precast_cast_time')
    local ok, res = pcall(require, 'resources')
    local spell = computed and ok and res.spells[computed.id]
    return spell and spell.type == 'BardSong' and computed.seconds or nil
end

--- Once the cast has started, give it its cast time before calling it lost.
--- Not started: refused, unless another action came first (a Marcato).
local function watch_start(queue, waited_for_ja)
    -- Marcato is still being used ahead of this song (song_opening.lua
    -- marcato_then, which sends the song itself): not a refusal yet
    local marcato = windower._brd_marcato_step
    if marcato and os.clock() < marcato.expires then
        return later(queue, 1.0, function(q) watch_start(q, waited_for_ja) end)
    end
    if CastTracker.started_since(queue.sent_at) then
        local seconds = computed_cast_time()
        local timeout = seconds and (seconds + END_MARGIN) or CAST_TIMEOUT
        return later(queue, timeout, function(q) retry(q, 'no end of cast') end)
    end
    if not waited_for_ja and CastTracker.acted_since(queue.sent_at) then
        return later(queue, JA_FIRST_WAIT, function(q) watch_start(q, true) end)
    end
    retry(queue, 'refused by the game')
end

--- Sing the current song, or end the queue.
--- The queue lives on `windower` so a reload or a subjob change mid-rotation
--- does not drop it; a main job change does: its timers would otherwise keep
--- sending songs the new job cannot sing.
send_step = function(queue)
    local song = queue.songs[queue.index]
    local ok, me = pcall(windower.ffxi.get_player)
    if not song or not (ok and me and me.main_job == 'BRD') then
        trace('queue: over (%s)', song and 'no longer BRD' or 'every song sent')
        windower._brd_song_queue = nil
        return
    end
    -- A debuff landed (shared/utils/buffs/buff_guard.lua): asleep,
    -- petrified, stunned or Mute stop the queue; Silence / Paralysis get
    -- their cure first, then this song
    local g_ok, Guard = pcall(require, 'shared/utils/buffs/buff_guard')
    if g_ok and Guard then
        local verdict, first = Guard.check({command = song, magic = true, label = 'songs'})
        if verdict == 'stop' or verdict == 'stop_magic' then
            trace('queue: stopped by a debuff before %s', song)
            windower._brd_song_queue = nil
            return
        end
        if verdict == 'before' and type(first) == 'table' and first[1] then
            send_command(first[1].command)
            return later(queue, first[1].wait or 5, send_step)
        end
    end
    queue.sent_at = os.clock()
    trace('queue: %d/%d %s sent', queue.index, #queue.songs, song)
    send_command(('input /ma "%s" %s'):format(song, queue.target))
    later(queue, START_WINDOW, function(q) watch_start(q, false) end)
end

--- Sing `songs` in order on `target`, dropping any queue already running.
--- @param songs table Song names
--- @param target string '<me>', '<stpc>'...
function SongQueue.start(songs, target)
    local previous = current()
    local queue = {songs = songs, target = target or '<me>', index = 1, tries = 0,
        seq = (previous and previous.seq or windower._brd_song_queue_seq or 0) + 1}
    windower._brd_song_queue_seq = queue.seq
    windower._brd_song_queue = queue
    trace('queue: start, %s on %s', table.concat(songs, ', '), queue.target)
    local g_ok, Guard = pcall(require, 'shared/utils/buffs/buff_guard')
    if g_ok and Guard then Guard.reset() end
    send_step(queue)
end

--- Drop the running queue.
--- @return boolean True when one was running
function SongQueue.stop()
    local running = current() ~= nil
    if running then trace('queue: stopped (songstop or a new rotation)') end
    windower._brd_song_queue = nil
    return running
end

--- Feed a BRD aftercast to the queue.
--- @param spell table Spell object from GearSwap
function SongQueue.on_aftercast(spell)
    local queue = current()
    if not queue or not spell or spell.type ~= 'BardSong' then return end
    if spell.interrupted then
        retry(queue, 'interrupted')
    else
        trace('queue: %s ended', tostring(spell.english))
        advance(queue, spell.english)
    end
end

return SongQueue

---============================================================================
--- BRD Song Opening - what happens between the key and the first song
---============================================================================
--- //gs c songs first asks whether there is anything to sing, then uses the
--- abilities that go before the songs, each one checked before the next:
---   1. Nothing to sing: every song of the plan is ours and has more than
---      `brd_songs_refresh_below` seconds left (_common/combat/TUNING.lua,
---      180 when unset, 0 turns the check off). Nothing is sent, neither
---      Nightingale nor a song. //gs c songs force sings anyway.
---   2. Nitro, when state.AutoNitro is On and Nightingale and Troubadour are
---      each up or ready (one on recast: no Nitro, the songs alone):
---      Nightingale, its buff seen, Troubadour, its buff seen, the songs.
---      An ability the game refuses (sent during an action lock) is sent
---      again (AbilityHelper.ensure); one that never goes stops everything,
---      no song is sung without it.
---   3. Marcato ahead of its song (BRD_PRECAST.lua try_marcato): the same
---      check, then the song. Here the song goes out even when Marcato never
---      did: its cast was cancelled for it and the rotation waits on it.
--- A second //gs c songs while the abilities are going out is ignored;
--- //gs c songstop drops them.
---
--- @file    shared/jobs/brd/functions/logic/song_opening.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-10-07
---============================================================================

local SongOpening = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')
local AbilityHelper = require('shared/utils/precast/ability_helper')

-- After a job ability lands, before the next action is accepted
local AFTER_JA = 1.0
-- An opening older than this was lost (reload mid-way): a new one may start
local OPENING_STALE = 30
-- The longest AbilityHelper.ensure can take, with a margin: the song queue
-- waits that long at most for the song Marcato goes before (song_queue.lua)
local MARCATO_STEP_MAX = 13
-- The song sent again after Marcato goes through try_marcato once more
local MARCATO_REPLAY = 3
local DEFAULT_REFRESH_BELOW = 180

local function trace(fmt, ...)
    local args = {...}
    pcall(function() require('shared/utils/debug/trace_log').log('SONGS', fmt, unpack(args)) end)
end

---============================================================================
--- NOTHING TO SING
---============================================================================

--- Whether the songs of the plan are all ours with time left.
--- Songs are matched by family (song_owner.lua): two songs of one family
--- (Honor March and Victory March, two Etudes) are not told apart.
--- @param songs table The pack's songs, in order
--- @param count number How many of them the rotation holds
--- @return number|nil Seconds left on the shortest, nil when something must be sung
function SongOpening.nothing_to_sing(songs, count)
    local below = require('shared/utils/core/tuning').get('brd_songs_refresh_below', DEFAULT_REFRESH_BELOW)
    if type(below) ~= 'number' or below <= 0 or count < 1 then return nil end
    local SongOwner = require('shared/jobs/brd/functions/logic/song_owner')
    local have, shortest = {}, nil
    for _, song in ipairs(SongOwner.own_songs()) do
        if song.left > below then
            have[song.family] = (have[song.family] or 0) + 1
            shortest = math.min(shortest or song.left, song.left)
        end
    end
    for i = 1, count do
        local family = songs[i] and SongOwner.family_of(songs[i])
        if not family or (have[family] or 0) < 1 then return nil end
        have[family] = have[family] - 1
    end
    return shortest
end

---============================================================================
--- NITRO, THEN THE SONGS
---============================================================================

--- Whether the abilities before the songs are going out now.
--- @return boolean
function SongOpening.running()
    local opening = windower._brd_song_opening
    return opening ~= nil and os.clock() - opening.at < OPENING_STALE
end

--- Drop the abilities going out.
--- @return boolean True when some were
function SongOpening.stop()
    local running = SongOpening.running()
    windower._brd_song_opening = nil
    return running
end

--- Up, or ready to be used.
local function available(ability)
    return AbilityHelper.is_buff_active(ability) or AbilityHelper.is_ability_ready(ability)
end

--- Whether Nitro goes before the songs: AutoNitro On, both abilities up or
--- ready, and at least one still to use.
local function nitro_wanted()
    if not (state.AutoNitro and state.AutoNitro.value == 'On') then return false end
    if not (available('Nightingale') and available('Troubadour')) then return false end
    return not (AbilityHelper.is_buff_active('Nightingale') and AbilityHelper.is_buff_active('Troubadour'))
end

--- Sing `order` on `target`, after Nightingale and Troubadour when they go.
--- @param order table Song list
--- @param target string
function SongOpening.start(order, target)
    local Queue = require('shared/jobs/brd/functions/logic/song_queue')
    if not nitro_wanted() then return Queue.start(order, target) end

    local opening = {at = os.clock()}
    windower._brd_song_opening = opening
    local function alive() return windower._brd_song_opening == opening end
    local function failed(ability)
        return function(reason)
            trace('opening: %s never went (%s), nothing sung', ability, reason)
            windower._brd_song_opening = nil
            MessageFormatter.show_warning(('Songs: %s did not go, nothing sung.'):format(ability))
        end
    end
    local function step(ability, next_step)
        return function()
            trace('opening: %s', ability)
            AbilityHelper.ensure(ability, function()
                coroutine.schedule(function() if alive() then next_step() end end, AFTER_JA)
            end, failed(ability), alive)
        end
    end
    local function sing()
        trace('opening: Nightingale and Troubadour up, %d songs', #order)
        windower._brd_song_opening = nil
        Queue.start(order, target)
    end
    step('Nightingale', step('Troubadour', sing))()
end

---============================================================================
--- MARCATO, THEN ITS SONG
---============================================================================

--- Use Marcato, then sing `song` on <me> once Marcato is up.
--- @param song string The song whose cast was cancelled for Marcato
function SongOpening.marcato_then(song)
    local function resend(delay)
        coroutine.schedule(function()
            windower._brd_marcato_step = nil
            windower._brd_marcato_replay = {song = song, expires = os.clock() + MARCATO_REPLAY}
            send_command(('input /ma "%s" <me>'):format(song))
        end, delay)
    end
    windower._brd_marcato_step = {expires = os.clock() + MARCATO_STEP_MAX}
    AbilityHelper.ensure('Marcato', function() resend(AFTER_JA) end, function(reason)
        trace('Marcato never went (%s), %s sung without it', reason, song)
        MessageFormatter.show_warning(('Songs: Marcato did not go, %s sung without it.'):format(song))
        resend(0)
    end)
end

--- Whether this cast is the song marcato_then sends once Marcato was dealt
--- with: Marcato is not tried again for it. Consumes the marker.
--- @param song string
--- @return boolean
function SongOpening.is_marcato_replay(song)
    local marker = windower._brd_marcato_replay
    if not marker then return false end
    windower._brd_marcato_replay = nil
    return marker.song == song and os.clock() < marker.expires
end

return SongOpening

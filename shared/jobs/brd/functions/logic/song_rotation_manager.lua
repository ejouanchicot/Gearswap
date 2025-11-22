---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Song Rotation Manager Logic Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles song rotation logic, pack selection, and Victory March replacement.
---   Business logic for BRD song casting sequences.
---
---   @file    shared/jobs/brd/functions/logic/song_rotation_manager.lua
---   @author  Tetsouo
---   @version 1.1 - Fix: Remove hardcoded instruments (only Marsyas/Loughnashade locked)
---   @date    Created: 2025-10-13 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local SongRotationManager = {}

-- Load configuration
local BRDSongConfig = _G.BRDSongConfig or {}  -- Loaded from character main file
local BRDTimingConfig = _G.BRDTimingConfig or {}  -- Loaded from character main file

-- Load message formatter for BRD messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   SONG PACK RETRIEVAL
---  ═══════════════════════════════════════════════════════════════════════════

--- Get current song pack based on state
--- @return table Song pack data with songs array
function SongRotationManager.get_current_pack()
    if not state or not state.SongMode then
        return BRDSongConfig.SONG_PACKS.March -- Default fallback
    end

    local pack_name = state.SongMode.current
    local pack = BRDSongConfig.SONG_PACKS[pack_name]

    if not pack then
        MessageFormatter.show_pack_not_found(pack_name)
        return BRDSongConfig.SONG_PACKS.March
    end

    return pack
end

--- Get songs from current pack with Victory March replacement
--- @return table Array of song names
function SongRotationManager.get_songs_with_replacement()
    local pack = SongRotationManager.get_current_pack()
    if not pack or not pack.songs then
        return {}
    end

    local songs = {}
    for i, song in ipairs(pack.songs) do
        songs[i] = song
    end

    -- Check for Victory March replacement
    if BRDSongConfig.VICTORY_MARCH_REPLACE.enabled then
        for i, song in ipairs(songs) do
            if song == 'Victory March' then
                -- Check if Haste buff active
                if buffactive['Haste'] or buffactive['Haste II'] then
                    local replacement_mode = state.MainInstrument and state.MainInstrument.current or 'Madrigal'
                    local replacement = BRDSongConfig.VICTORY_MARCH_REPLACE.replacements[replacement_mode]
                    if replacement then
                        songs[i] = replacement
                    end
                end
                break
            end
        end
    end

    return songs
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SONG DISPLAY
---  ═══════════════════════════════════════════════════════════════════════════

--- Get short name for song display
--- @param song_name string Full song name
--- @return string Short name
function SongRotationManager.get_short_name(song_name)
    return BRDSongConfig.SHORT_NAMES[song_name] or song_name
end

--- Update song slot states for UI display
--- Display songs from current pack configuration
function SongRotationManager.update_song_slots()
    -- Get songs from current pack (with Victory March replacement if applicable)
    local songs = SongRotationManager.get_songs_with_replacement()

    -- Update each slot (1-5) with pack songs
    for i = 1, 5 do
        local state_name = 'BRDSong' .. i
        if state and state[state_name] then
            local song_name = songs[i] or 'Empty'
            -- Use short name for UI display
            local display_name = song_name ~= 'Empty' and SongRotationManager.get_short_name(song_name) or 'Empty'
            state[state_name].value = display_name
            state[state_name].current = display_name
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DUMMY SONG MANAGEMENT
---  ═══════════════════════════════════════════════════════════════════════════

--- Get dummy songs array
--- @return table Array of dummy song names
function SongRotationManager.get_dummy_songs()
    return BRDSongConfig.DUMMY_SONGS.standard
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INSTRUMENT SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if song is a dummy song
--- @param song_name string Song name
--- @return boolean is_dummy
local function is_dummy_song(song_name)
    local dummy_songs = BRDSongConfig.DUMMY_SONGS.standard
    for _, dummy in ipairs(dummy_songs) do
        if song_name == dummy then
            return true
        end
    end
    return false
end

--- Get required instrument for specific song
--- Only returns instruments for songs that are LOCKED (cannot be cast without them)
--- For dummy songs: instrument selected by sets.midcast.DummySong
--- For other songs: instrument selected by state.MainInstrument or sets.midcast.BardSong
--- @param song_name string Song name
--- @return string|nil Instrument name or nil (uses sets/state)
function SongRotationManager.get_required_instrument(song_name)
    -- LOCKED SONGS (cannot be cast without specific instrument):

    -- Honor March: Locked to Marsyas (song unavailable without Marsyas)
    if song_name == 'Honor March' then
        return 'Marsyas'
    end

    -- Aria of Passion: Locked to Loughnashade (song unavailable without Loughnashade)
    if song_name == 'Aria of Passion' then
        return 'Loughnashade'
    end

    -- Dummy songs: Let sets.midcast.DummySong decide instrument
    -- Valid choices: Daurdabla (+2), Loughnashade (+2), Blurred Harp (+1), Blurred Harp +1 (+1)
    if is_dummy_song(song_name) then
        return nil  -- Use sets.midcast.DummySong (player's choice)
    end

    -- For all other songs: Use player's current instrument preference
    return nil  -- Use state.MainInstrument or sets.midcast.BardSong
end

---  ═══════════════════════════════════════════════════════════════════════════
---   3-PHASE DUMMY SONG CASTING WITH DYNAMIC TIMING
---  ═══════════════════════════════════════════════════════════════════════════

--- Get appropriate song delay based on active buffs and Marcato state
--- @param marcato_used boolean Whether Marcato was used for this rotation
--- @return number Delay in seconds
local function get_song_delay(marcato_used)
    local has_nightingale = buffactive['Nightingale'] or false
    local has_troubadour = buffactive['Troubadour'] or false

    -- Use dynamic timing config
    return BRDTimingConfig.get_song_delay(has_nightingale, has_troubadour, marcato_used)
end

--- Cast a phase of songs with proper delays
--- @param songs table Array of songs to cast
--- @param start_index number Starting song index (1-based)
--- @param count number Number of songs to cast
--- @param target string Target for songs ("<me>" or "<stnpc>")
--- @param base_delay number Starting delay
--- @param song_delay number Delay between songs
--- @return number Updated delay for next phase
local function cast_song_phase(songs, start_index, count, target, base_delay, song_delay)
    local delay = base_delay

    for i = start_index, start_index + count - 1 do
        if songs[i] then
            send_command('wait ' .. delay .. '; input /ma "' .. songs[i] .. '" ' .. target)
            delay = delay + song_delay
        end
    end

    return delay
end

--- Cast songs using 3-phase rotation (Party >> Dummy >> Party)
--- @param use_marcato boolean Whether to use Marcato for first song (Honor March)
--- @param target string Target for songs ("<me>" for party, "<stpc>" for pianissimo)
--- @return boolean Success status
function SongRotationManager.cast_songs_with_phases(use_marcato, target)
    target = target or '<me>'
    local buff_songs = SongRotationManager.get_songs_with_replacement()
    local dummy_songs = SongRotationManager.get_dummy_songs()
    local delay = 0
    local marcato_used = false

    -- Check for Clarion Call (allows 5 songs instead of 4)
    local has_clarion = buffactive['Clarion Call'] or false
    local total_songs = has_clarion and 5 or 4

    -- Get dynamic song delay (Marcato handled in cast_song helper now)
    local song_delay = get_song_delay(false)

    if total_songs >= 5 then
        -- 5-song rotation (Clarion Call active)
        MessageFormatter.show_songs_casting(total_songs, '5-Song')

        -- Phase 1: First 3 real songs
        delay = cast_song_phase(buff_songs, 1, 3, target, delay, song_delay)

        -- Phase 2: 2 dummy songs
        delay = cast_song_phase(dummy_songs, 1, 2, target, delay, song_delay)

        -- Phase 3: Last 2 real songs (replace dummies)
        delay = cast_song_phase(buff_songs, 4, 2, target, delay, song_delay)
    else
        -- 4-song rotation (standard)
        MessageFormatter.show_songs_casting(total_songs, '4-Song')

        -- Phase 1: First 2 real songs
        delay = cast_song_phase(buff_songs, 1, 2, target, delay, song_delay)

        -- Phase 2: 2 dummy songs
        delay = cast_song_phase(dummy_songs, 1, 2, target, delay, song_delay)

        -- Phase 3: Last 2 real songs (replace dummies)
        delay = cast_song_phase(buff_songs, 3, 2, target, delay, song_delay)
    end

    -- Display song list
    local pack_name = state.SongMode and state.SongMode.current or 'Unknown'
    local song_list = {}
    for i = 1, total_songs do
        if buff_songs[i] then
            table.insert(song_list, SongRotationManager.get_short_name(buff_songs[i]))
        end
    end
    MessageFormatter.show_song_pack(pack_name, song_list)

    return true
end

--- Cast dummy songs to fill slots (4 or 5 depending on Clarion Call)
--- @return boolean Success status
function SongRotationManager.cast_dummy_songs()
    local dummy_songs = SongRotationManager.get_dummy_songs()

    -- Dummy songs never use Marcato, so marcato_used = false
    local song_delay = get_song_delay(false)

    -- Check for Clarion Call
    local has_clarion = buffactive['Clarion Call'] or false
    local total_songs = has_clarion and 5 or 4

    MessageFormatter.show_dummy_casting(total_songs)

    -- Cast dummies sequentially
    for i = 1, total_songs do
        if dummy_songs[i] then
            local delay = (i - 1) * song_delay
            send_command('wait ' .. delay .. '; input /ma "' .. dummy_songs[i] .. '" <me>')
        end
    end

    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL EXPORT FOR UI
---  ═══════════════════════════════════════════════════════════════════════════

-- Export update function for UI display
_G.update_brd_song_slots = SongRotationManager.update_song_slots

return SongRotationManager

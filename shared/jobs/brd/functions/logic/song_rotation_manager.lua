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

-- Load message formatter for BRD messages
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   SONG PACK RETRIEVAL
---  ═══════════════════════════════════════════════════════════════════════════

---   Get current song pack based on state
---   @return table Song pack data with songs array
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

---   Resolve the song replacing Victory March, based on state.VictoryMarch
---   @return string|nil Replacement song name, or nil to keep Victory March
local function resolve_victory_replacement()
    local config = BRDSongConfig.VICTORY_MARCH_REPLACE
    local mode = state.VictoryMarch and state.VictoryMarch.current or config.default

    if mode == 'Etude' then
        local stat = state.EtudeType and state.EtudeType.current
        return stat and BRDSongConfig.ETUDES[stat] or nil
    end

    return config.replacements[mode]
end

---   Get songs from current pack with Victory March replacement
---   @return table Array of song names
function SongRotationManager.get_songs_with_replacement()
    local pack = SongRotationManager.get_current_pack()
    if not pack or not pack.songs then
        return {}
    end

    local songs = {}
    for i, song in ipairs(pack.songs) do
        songs[i] = song
    end

    -- Victory March only stacks its Haste with itself, so swap it out when Haste is already up
    if BRDSongConfig.VICTORY_MARCH_REPLACE.enabled then
        for i, song in ipairs(songs) do
            if song == 'Victory March' then
                if buffactive['Haste'] or buffactive['Haste II'] then
                    local replacement = resolve_victory_replacement()
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

---   Get short name for song display
---   @param song_name string Full song name
---   @return string Short name
function SongRotationManager.get_short_name(song_name)
    return BRDSongConfig.SHORT_NAMES[song_name] or song_name
end

---   Update song slot states (BRDSong1..5) for UI display, with short names
---   Also exported as _G.update_brd_song_slots (read by ui_display.lua)
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

---   Get dummy songs array
---   @return table Array of dummy song names
function SongRotationManager.get_dummy_songs()
    return BRDSongConfig.DUMMY_SONGS.standard
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INSTRUMENT SELECTION
---  ═══════════════════════════════════════════════════════════════════════════

---   Get required instrument for specific song (read by
---   MidcastManager.get_song_instrument through _G.SongRotationManager)
---   Only returns instruments for songs that are LOCKED (cannot be cast without them)
---   For dummy songs: instrument selected by sets.midcast.DummySong
---   For buff songs: state.MainInstrument, applied by midcast_router after the song set
---   (debuff songs keep the instrument of their own set)
---   @param song_name string Song name
---   @return string|nil Instrument name or nil (uses sets/state)
function SongRotationManager.get_required_instrument(song_name)
    return require('shared/jobs/brd/functions/logic/instrument_lock_config').get_instrument(song_name)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   3-PHASE DUMMY SONG CASTING (queued: song_queue.lua)
---  ═══════════════════════════════════════════════════════════════════════════

---   Append songs[start_index .. start_index + count - 1] to `into`.
---   @param into table Song list being built
---   @param songs table Songs to take from
---   @param start_index number First index (1-based)
---   @param count number How many
local function add_phase(into, songs, start_index, count)
    for i = start_index, start_index + count - 1 do
        if songs[i] then into[#into + 1] = songs[i] end
    end
end

---   Cast songs using 3-phase rotation (Party >> Dummy >> Party)
---   @param use_marcato boolean Unused: Marcato is inserted by BRD_PRECAST (try_marcato)
---   @param target string Target for songs ("<me>" for party, "<stpc>" for pianissimo)
---   @return boolean Success status
function SongRotationManager.cast_songs_with_phases(use_marcato, target)
    target = target or '<me>'
    local buff_songs = SongRotationManager.get_songs_with_replacement()
    local dummy_songs = SongRotationManager.get_dummy_songs()
    local order = {}

    -- Songs the instruments and Clarion Call can hold, dummies still needed
    -- (song_slots.lua). One song after the other, each once the previous is
    -- over (song_queue.lua); Marcato is inserted by BRD_PRECAST, not here.
    -- The slots the main instrument opens, then the dummies, then the rest of
    -- the real songs over them.
    local total_songs, dummies, base = require('shared/jobs/brd/functions/logic/song_slots').plan(#buff_songs)
    dummies = math.min(dummies, #dummy_songs)
    MessageFormatter.show_songs_casting(total_songs, ('%d-Song, %d dummy'):format(total_songs, dummies))
    add_phase(order, buff_songs, 1, base)
    add_phase(order, dummy_songs, 1, dummies)
    add_phase(order, buff_songs, base + 1, total_songs - base)
    require('shared/jobs/brd/functions/logic/song_queue').start(order, target)

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

---   Cast the dummy songs that open slots beyond the main instrument's
---   @return boolean Success status
function SongRotationManager.cast_dummy_songs()
    local dummy_songs = SongRotationManager.get_dummy_songs()

    -- The slots the dummy instrument opens beyond the main one (song_slots.lua)
    local total_songs, _, base = require('shared/jobs/brd/functions/logic/song_slots').plan(99)
    local count = math.min(#dummy_songs, total_songs - base)

    MessageFormatter.show_dummy_casting(count)

    -- One after the other, each once the previous is over (song_queue.lua)
    local order = {}
    add_phase(order, dummy_songs, 1, count)
    require('shared/jobs/brd/functions/logic/song_queue').start(order, '<me>')

    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL EXPORT FOR UI
---  ═══════════════════════════════════════════════════════════════════════════

-- Export update function for UI display
_G.update_brd_song_slots = SongRotationManager.update_song_slots

return SongRotationManager

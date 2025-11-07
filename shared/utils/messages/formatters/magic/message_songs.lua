---============================================================================
--- Song Message Formatter - Bard Song Messages (NEW SYSTEM)
---============================================================================
--- BRD-specific song casting, rotation, and instrument messages.
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- Usage Examples:
---   SongMessages.show_songs_casting(4, "4-Song")
---   SongMessages.show_song_pack("MELEE", {"March", "Madrigal", "Minuet", "Minuet"})
---   SongMessages.show_honor_march_locked()
---   SongMessages.show_daurdabla_dummy()
---   SongMessages.show_pianissimo_target("Kaories")
---
--- @file    messages/message_songs.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local SongMessages = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')

---============================================================================
--- SONG ROTATION MESSAGES
---============================================================================

--- Display song rotation start
--- Format: [JOB] 4-Song Rotation: Phase 1 > Phase 2 (dummies) > Phase 3
---
--- @param song_count number Number of songs being cast
--- @param rotation_type string "4-Song" or "5-Song"
function SongMessages.show_songs_casting(song_count, rotation_type)
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'songs_casting', {
        job_tag = job_tag,
        rotation_type = rotation_type
    })
end

--- Display song pack selection
--- Format: [JOB] MELEE Pack: March > Madrigal > Minuet > Minuet
---
--- @param pack_name string Name of the song pack
--- @param song_list table Array of short song names
function SongMessages.show_song_pack(pack_name, song_list)
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'song_pack', {
        job_tag = job_tag,
        pack_name = pack_name,
        song_list = table.concat(song_list, " > ")
    })
end

---============================================================================
--- HONOR MARCH PROTECTION MESSAGES
---============================================================================

--- Display Honor March protection locked
--- Format: [JOB] Honor March Protection: Marsyas locked
function SongMessages.show_honor_march_locked()
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'honor_march_locked', {job_tag = job_tag})
end

--- Display Honor March protection released
--- Format: [JOB] Honor March Protection: Released
function SongMessages.show_honor_march_released()
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'honor_march_released', {job_tag = job_tag})
end

---============================================================================
--- INSTRUMENT SELECTION MESSAGES
---============================================================================

--- Display Daurdabla dummy song message
--- Format: [JOB] Dummy Song using Daurdabla to expand song slots
function SongMessages.show_daurdabla_dummy()
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'daurdabla_dummy', {job_tag = job_tag})
end

---============================================================================
--- PIANISSIMO MESSAGES
---============================================================================

--- Display Pianissimo used
--- Format: [JOB] Pianissimo: Single-target song
function SongMessages.show_pianissimo_used()
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'pianissimo_used', {job_tag = job_tag})
end

--- Display Pianissimo target
--- Format: [JOB] [Pianissimo] Targeting: Kaories
---
--- @param target_name string Name of the target
function SongMessages.show_pianissimo_target(target_name)
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'pianissimo_target', {
        job_tag = job_tag,
        target_name = target_name or 'Unknown'
    })
end

---============================================================================
--- MARCATO MESSAGES (Song-Related)
---============================================================================

--- Display Marcato + Honor March message
--- Format: [JOB] Using Marcato for Honor March (Nightingale + Troubadour active)
---
--- @param song_name string Optional song name (defaults to "Honor March")
function SongMessages.show_marcato_honor_march(song_name)
    song_name = song_name or "Honor March" -- Backward compatibility

    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'marcato_honor_march', {
        job_tag = job_tag,
        song_name = song_name
    })
end

--- Display Marcato skip (buffs not active)
--- Format: [JOB] Marcato skipped: Requires Nightingale + Troubadour
function SongMessages.show_marcato_skip_buffs()
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'marcato_skip_buffs', {job_tag = job_tag})
end

--- Display Marcato skip (Soul Voice active)
--- Format: [JOB] Marcato skipped: Soul Voice active (not needed)
function SongMessages.show_marcato_skip_soul_voice()
    local job_tag = MessageCore.get_job_tag()

    M.send('SONGS', 'marcato_skip_soul_voice', {job_tag = job_tag})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SongMessages

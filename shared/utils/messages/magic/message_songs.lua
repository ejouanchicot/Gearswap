---============================================================================
--- Bard Song Messages - Song Casting and Management
---============================================================================
--- BRD-specific song casting, rotation, and instrument messages.
--- Organized in MAGIC category (song spells) rather than JOB category.
---
--- Usage Examples:
---   SongMessages.show_songs_casting(4, "4-Song")
---   SongMessages.show_song_pack("MELEE", {"March", "Madrigal", "Minuet", "Minuet"})
---   SongMessages.show_honor_march_locked()
---   SongMessages.show_daurdabla_dummy()
---   SongMessages.show_pianissimo_target("Kaories")
---
--- @file utils/messages/magic/message_songs.lua
--- @author Tetsouo
--- @version 1.0 - Global Refactor
--- @date Created: 2025-10-29
---============================================================================

local SongMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local count_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s Rotation: %sPhase 1 > Phase 2 (dummies) > Phase 3",
        job_color, job_tag,
        count_color, rotation_type,
        action_color,
        MessageCore.create_color_code(Colors.SPELL)
    )

    add_to_chat(001, formatted_message)
end

--- Display song pack selection
--- Format: [JOB] MELEE Pack: March > Madrigal > Minuet > Minuet
---
--- @param pack_name string Name of the song pack
--- @param song_list table Array of short song names
function SongMessages.show_song_pack(pack_name, song_list)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local pack_color = MessageCore.create_color_code(Colors.SUCCESS)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s Pack: %s%s",
        job_color, job_tag,
        pack_color, pack_name,
        action_color,
        song_color, table.concat(song_list, " > ")
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- HONOR MARCH PROTECTION MESSAGES
---============================================================================

--- Display Honor March protection locked
--- Format: [JOB] Honor March Protection: Marsyas locked
function SongMessages.show_honor_march_locked()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s Protection: %sMarsyas locked",
        job_color, job_tag,
        song_color, "Honor March",
        action_color,
        MessageCore.create_color_code(Colors.SUCCESS)
    )

    add_to_chat(001, formatted_message)
end

--- Display Honor March protection released
--- Format: [JOB] Honor March Protection: Released
function SongMessages.show_honor_march_released()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s Protection: %sReleased",
        job_color, job_tag,
        song_color, "Honor March",
        action_color,
        MessageCore.create_color_code(Colors.SUCCESS)
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- INSTRUMENT SELECTION MESSAGES
---============================================================================

--- Display Daurdabla dummy song message
--- Format: [JOB] Dummy Song using Daurdabla to expand song slots
function SongMessages.show_daurdabla_dummy()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Dummy Song using %sDaurdabla%s to expand song slots",
        job_color, job_tag,
        action_color,
        MessageCore.create_color_code(Colors.SUCCESS), action_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- PIANISSIMO MESSAGES
---============================================================================

--- Display Pianissimo used
--- Format: [JOB] Pianissimo: Single-target song
function SongMessages.show_pianissimo_used()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s: %sSingle-target song",
        job_color, job_tag,
        ability_color, "Pianissimo",
        action_color,
        MessageCore.create_color_code(Colors.SUCCESS)
    )

    add_to_chat(001, formatted_message)
end

--- Display Pianissimo target
--- Format: [JOB] [Pianissimo] Targeting: Kaories
---
--- @param target_name string Name of the target
function SongMessages.show_pianissimo_target(target_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local target_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s [%s%s%s]%s Targeting: %s%s",
        job_color, job_tag,
        action_color,
        ability_color, "Pianissimo",
        action_color,
        action_color,
        target_color, target_name or 'Unknown'
    )

    add_to_chat(001, formatted_message)
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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Using %s%s%s for %s%s%s (%sNightingale + Troubadour active%s)",
        job_color, job_tag,
        action_color,
        ability_color, "Marcato",
        action_color,
        song_color, song_name,
        action_color,
        MessageCore.create_color_code(Colors.SUCCESS), action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Marcato skip (buffs not active)
--- Format: [JOB] Marcato skipped: Requires Nightingale + Troubadour
function SongMessages.show_marcato_skip_buffs()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s skipped: %sRequires Nightingale + Troubadour",
        job_color, job_tag,
        ability_color, "Marcato",
        action_color,
        MessageCore.create_color_code(Colors.WARNING)
    )

    add_to_chat(001, formatted_message)
end

--- Display Marcato skip (Soul Voice active)
--- Format: [JOB] Marcato skipped: Soul Voice active (not needed)
function SongMessages.show_marcato_skip_soul_voice()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s skipped: %sSoul Voice active (not needed)",
        job_color, job_tag,
        ability_color, "Marcato",
        action_color,
        MessageCore.create_color_code(Colors.WARNING)
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SongMessages

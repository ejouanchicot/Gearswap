---============================================================================
--- BRD Messages Module - Bard Song and Ability Message Formatting
---============================================================================
--- Provides formatted messages for Bard job system following Tetsouo standard.
--- Uses multi-color inline formatting for professional display.
---
--- @file utils/messages/message_brd.lua
--- @author Tetsouo
--- @version 3.0
--- @date Updated: 2025-10-13
---============================================================================

local BRDMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

---============================================================================
--- ABILITY MESSAGES
---============================================================================

function BRDMessages.show_soul_voice_activated()
    -- Multi-color format: [JOB](cyan) + Ability(yellow) + activated(green) + text(white)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s activated! %sSong power boost!",
        job_color, job_tag,
        ability_color, "Soul Voice",
        success_color,
        action_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_soul_voice_ended()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s ended",
        job_color, job_tag,
        ability_color, "Soul Voice",
        action_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_nightingale_activated()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s: %sCasting Time reduced",
        job_color, job_tag,
        ability_color, "Nightingale",
        action_color,
        success_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_nightingale_active()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)

    local formatted_message = string.format(
        "%s[%s] %s%s%s active",
        job_color, job_tag,
        ability_color, "Nightingale",
        success_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_troubadour_activated()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s: %sSong duration extended",
        job_color, job_tag,
        ability_color, "Troubadour",
        action_color,
        success_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_troubadour_active()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)

    local formatted_message = string.format(
        "%s[%s] %s%s%s active",
        job_color, job_tag,
        ability_color, "Troubadour",
        success_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_marcato_used()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Using %s%s",
        job_color, job_tag,
        action_color,
        ability_color, "Marcato"
    )

    add_to_chat(001, formatted_message)
end

--- @param song_name string Optional song name (defaults to "Honor March")
function BRDMessages.show_marcato_honor_march(song_name)
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

function BRDMessages.show_marcato_skip_buffs()
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

function BRDMessages.show_marcato_skip_soul_voice()
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

function BRDMessages.show_pianissimo_used()
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

--- @param target_name string Name of the target
function BRDMessages.show_pianissimo_target(target_name)
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

--- @param ability_name string Name of the ability
function BRDMessages.show_ability_command(ability_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Using %s%s",
        job_color, job_tag,
        action_color,
        ability_color, ability_name
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- HONOR MARCH PROTECTION MESSAGES
---============================================================================

function BRDMessages.show_honor_march_locked()
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

function BRDMessages.show_honor_march_released()
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

function BRDMessages.show_daurdabla_dummy()
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
--- SONG CASTING MESSAGES
---============================================================================

--- @param song_count number Number of songs being cast
--- @param rotation_type string "4-Song" or "5-Song"
function BRDMessages.show_songs_casting(song_count, rotation_type)
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

--- @param pack_name string Name of the song pack
--- @param song_list table Array of short song names
function BRDMessages.show_song_pack(pack_name, song_list)
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

--- @param song_count number Number of songs being refreshed
function BRDMessages.show_songs_refresh(song_count)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local count_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Refreshing %s%d%s melee songs %s(no dummies)",
        job_color, job_tag,
        action_color,
        count_color, song_count,
        action_color,
        MessageCore.create_color_code(Colors.SEPARATOR)
    )

    add_to_chat(001, formatted_message)
end

--- @param total_songs number Total number of dummy songs
function BRDMessages.show_dummy_casting(total_songs)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local count_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%d%s dummy songs",
        job_color, job_tag,
        action_color,
        count_color, total_songs,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- @param dummy_name string Name of the dummy song
function BRDMessages.show_dummy_cast(dummy_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s",
        job_color, job_tag,
        action_color,
        song_color, dummy_name
    )

    add_to_chat(001, formatted_message)
end

--- @param song_count number Number of songs being cast
function BRDMessages.show_tank_casting(song_count)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local pack_color = MessageCore.create_color_code(Colors.SUCCESS)
    local count_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s%s Pack %s(%d songs)",
        job_color, job_tag,
        action_color,
        pack_color, "Tank",
        action_color,
        count_color, song_count
    )

    add_to_chat(001, formatted_message)
end

--- @param song_count number Number of songs being refreshed
function BRDMessages.show_tank_refresh(song_count)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local count_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Refreshing %s%d%s Tank songs",
        job_color, job_tag,
        action_color,
        count_color, song_count,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- @param song_count number Number of songs being cast
function BRDMessages.show_healer_casting(song_count)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local pack_color = MessageCore.create_color_code(Colors.SUCCESS)
    local count_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s%s Pack %s(%d songs)",
        job_color, job_tag,
        action_color,
        pack_color, "Healer",
        action_color,
        count_color, song_count
    )

    add_to_chat(001, formatted_message)
end

--- @param song_count number Number of songs being refreshed
function BRDMessages.show_healer_refresh(song_count)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local count_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Refreshing %s%d%s Healer songs",
        job_color, job_tag,
        action_color,
        count_color, song_count,
        action_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- INDIVIDUAL SONG MESSAGES
---============================================================================

--- @param slot number Song slot (1-5)
--- @param song_name string Name of the song
function BRDMessages.show_song_cast(slot, song_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local slot_color = MessageCore.create_color_code(Colors.SUCCESS)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %sSong %d%s: %s%s",
        job_color, job_tag,
        action_color,
        slot_color, slot,
        action_color,
        song_color, song_name
    )

    add_to_chat(001, formatted_message)
end

--- @param slot number Song slot (3, 4, or 5)
--- @param dummy_count number Number of dummies required
function BRDMessages.show_song_guidance(slot, dummy_count)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local slot_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local dummy_text = dummy_count > 1 and "dummies" or "dummy"

    local formatted_message = string.format(
        "%s[%s]%s Note: %sSong %d%s requires songs 1-2 + %s%d %s%s to be active",
        job_color, job_tag,
        action_color,
        slot_color, slot,
        action_color,
        MessageCore.create_color_code(Colors.WARNING), dummy_count, dummy_text,
        action_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_clarion_required()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    add_to_chat(001, string.format(
        "%s[%s] %s%sSong 5%s requires %sClarion Call%s active!",
        job_color, job_tag,
        error_color, "Song 5",
        action_color,
        MessageCore.create_color_code(Colors.JA), action_color
    ))

    add_to_chat(001, string.format(
        "%s[%s]%s Use %sSoul Voice%s to enable %sClarion Call",
        job_color, job_tag,
        action_color,
        MessageCore.create_color_code(Colors.JA), action_color,
        MessageCore.create_color_code(Colors.JA)
    ))
end

---============================================================================
--- DEBUFF SONG MESSAGES
---============================================================================

--- @param lullaby_type string "Horde" or "Foe"
function BRDMessages.show_lullaby_cast(lullaby_type)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s Lullaby II",
        job_color, job_tag,
        action_color,
        song_color, lullaby_type
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_elegy_cast()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s",
        job_color, job_tag,
        action_color,
        song_color, "Carnage Elegy"
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_requiem_cast()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s",
        job_color, job_tag,
        action_color,
        song_color, "Foe Requiem VII"
    )

    add_to_chat(001, formatted_message)
end

--- @param element string Element name (Fire, Ice, etc.)
function BRDMessages.show_threnody_cast(element)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local element_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s%s Threnody II",
        job_color, job_tag,
        action_color,
        element_color, element,
        song_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- BUFF SONG MESSAGES
---============================================================================

--- @param element string Element name (Fire, Ice, etc.)
function BRDMessages.show_carol_cast(element)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local element_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s%s Carol II",
        job_color, job_tag,
        action_color,
        element_color, element,
        song_color
    )

    add_to_chat(001, formatted_message)
end

--- @param stat string Stat name (STR, DEX, etc.)
function BRDMessages.show_etude_cast(stat)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local stat_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s%s Etude",
        job_color, job_tag,
        action_color,
        stat_color, stat,
        song_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- SONG REFINEMENT MESSAGES
---============================================================================

--- @param original string Original song name
--- @param downgrade string Downgraded song name
--- @param recast_seconds number Recast time remaining
function BRDMessages.show_song_refinement(original, downgrade, recast_seconds)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local time_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s on cooldown %s(%.1fs)%s > Downgrading to %s%s",
        job_color, job_tag,
        song_color, original,
        action_color,
        time_color, recast_seconds,
        action_color,
        song_color, downgrade
    )

    add_to_chat(001, formatted_message)
end

--- @param song_name string Song name
--- @param recast_seconds number Recast time remaining
function BRDMessages.show_song_refinement_failed(song_name, recast_seconds)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local song_color = MessageCore.create_color_code(Colors.SPELL)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local time_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s on cooldown %s(%.1fs)%s - %sNo downgrade available",
        job_color, job_tag,
        song_color, song_name,
        action_color,
        time_color, recast_seconds,
        action_color,
        error_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- BUFF STATUS MESSAGES (job_buff_change)
---============================================================================

function BRDMessages.show_doom_gained()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%sDOOM!%s Use Cursna or Holy Water!",
        job_color, job_tag,
        error_color, "DOOM!",
        action_color
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_doom_removed()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        success_color, "Doom removed"
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- ERROR MESSAGES
---============================================================================

function BRDMessages.show_no_pack_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "No song pack configured"
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_tank_not_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Tank pack not configured"
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_healer_not_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Healer pack not configured"
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_no_element_selected()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "No threnody element selected"
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_no_carol_element()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "No carol element selected"
    )

    add_to_chat(001, formatted_message)
end

function BRDMessages.show_no_etude_type()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "No etude type selected"
    )

    add_to_chat(001, formatted_message)
end

--- @param slot number Song slot (1-5)
function BRDMessages.show_no_song_in_slot(slot)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local slot_color = MessageCore.create_color_code(Colors.WARNING)

    local formatted_message = string.format(
        "%s[%s] %s%sNo song in slot %s%d",
        job_color, job_tag,
        error_color, "No song in slot ",
        slot_color, slot
    )

    add_to_chat(001, formatted_message)
end

--- @param pack_name string Name of the pack
function BRDMessages.show_pack_not_found(pack_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local pack_color = MessageCore.create_color_code(Colors.WARNING)

    local formatted_message = string.format(
        "%s[%s] %s%sPack not found: %s%s",
        job_color, job_tag,
        error_color, "Pack not found: ",
        pack_color, tostring(pack_name)
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BRDMessages

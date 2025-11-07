---============================================================================
--- BRD Messages Module - Bard Song and Ability Message Formatting
---============================================================================
--- Uses NEW message system with inline colors
--- Delegates to api/messages.lua for all formatting
---
--- @file utils/messages/message_brd.lua
--- @author Tetsouo
--- @version 2.0 (NEW SYSTEM)
--- @date Created: 2025-10-13 | Migrated: 2025-11-06
---============================================================================

local BRDMessages = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')

-- Get job tag (for subjob support: BRD/WHM → "BRD/WHM")
local function get_job_tag()
    local main_job = player and player.main_job or 'BRD'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- ABILITY MESSAGES (NEW SYSTEM)
---============================================================================

function BRDMessages.show_soul_voice_activated()
    M.job('BRD', 'soul_voice_activated', {
        job = get_job_tag()
    })
end

function BRDMessages.show_soul_voice_ended()
    M.job('BRD', 'soul_voice_ended', {
        job = get_job_tag()
    })
end

function BRDMessages.show_nightingale_activated()
    M.job('BRD', 'nightingale_activated', {
        job = get_job_tag()
    })
end

function BRDMessages.show_nightingale_active()
    M.job('BRD', 'nightingale_active', {
        job = get_job_tag()
    })
end

function BRDMessages.show_troubadour_activated()
    M.job('BRD', 'troubadour_activated', {
        job = get_job_tag()
    })
end

function BRDMessages.show_troubadour_active()
    M.job('BRD', 'troubadour_active', {
        job = get_job_tag()
    })
end

function BRDMessages.show_marcato_used()
    M.job('BRD', 'marcato_used', {
        job = get_job_tag()
    })
end

--- @param song_name string Optional song name (defaults to "Honor March")
function BRDMessages.show_marcato_honor_march(song_name)
    -- DISABLED: Too verbose
    -- song_name = song_name or "Honor March"
    -- M.job('BRD', 'marcato_honor_march', {
    --     job = get_job_tag(),
    --     song = song_name
    -- })
end

function BRDMessages.show_marcato_skip_buffs()
    M.job('BRD', 'marcato_skip_buffs', {
        job = get_job_tag()
    })
end

function BRDMessages.show_marcato_skip_soul_voice()
    M.job('BRD', 'marcato_skip_soul_voice', {
        job = get_job_tag()
    })
end

function BRDMessages.show_pianissimo_used()
    M.job('BRD', 'pianissimo_used', {
        job = get_job_tag()
    })
end

--- @param target_name string Name of the target
function BRDMessages.show_pianissimo_target(target_name)
    M.job('BRD', 'pianissimo_target', {
        job = get_job_tag(),
        target = target_name or 'Unknown'
    })
end

--- @param ability_name string Name of the ability
function BRDMessages.show_ability_command(ability_name)
    M.job('BRD', 'ability_command', {
        job = get_job_tag(),
        ability = ability_name
    })
end

---============================================================================
--- HONOR MARCH PROTECTION MESSAGES (NEW SYSTEM)
---============================================================================

function BRDMessages.show_honor_march_locked()
    -- DISABLED: Too verbose
    -- M.job('BRD', 'honor_march_locked', {
    --     job = get_job_tag()
    -- })
end

function BRDMessages.show_honor_march_released()
    -- DISABLED: Too verbose
    -- M.job('BRD', 'honor_march_released', {
    --     job = get_job_tag()
    -- })
end

---============================================================================
--- INSTRUMENT SELECTION MESSAGES (NEW SYSTEM)
---============================================================================

function BRDMessages.show_daurdabla_dummy()
    M.job('BRD', 'daurdabla_dummy', {
        job = get_job_tag()
    })
end

---============================================================================
--- SONG CASTING MESSAGES (NEW SYSTEM)
---============================================================================

--- @param song_count number Number of songs being cast
--- @param rotation_type string "4-Song" or "5-Song"
function BRDMessages.show_songs_casting(song_count, rotation_type)
    M.job('BRD', 'songs_casting', {
        job = get_job_tag(),
        rotation = rotation_type
    })
end

--- @param pack_name string Name of the song pack
--- @param song_list table Array of short song names
function BRDMessages.show_song_pack(pack_name, song_list)
    M.job('BRD', 'song_pack', {
        job = get_job_tag(),
        pack = pack_name,
        songs = table.concat(song_list, " > ")
    })
end

--- @param song_count number Number of songs being refreshed
function BRDMessages.show_songs_refresh(song_count)
    M.job('BRD', 'songs_refresh', {
        job = get_job_tag(),
        count = song_count
    })
end

--- @param total_songs number Total number of dummy songs
function BRDMessages.show_dummy_casting(total_songs)
    M.job('BRD', 'dummy_casting', {
        job = get_job_tag(),
        count = total_songs
    })
end

--- @param dummy_name string Name of the dummy song
function BRDMessages.show_dummy_cast(dummy_name)
    M.job('BRD', 'dummy_cast', {
        job = get_job_tag(),
        dummy = dummy_name
    })
end

--- @param song_count number Number of songs being cast
function BRDMessages.show_tank_casting(song_count)
    M.job('BRD', 'tank_casting', {
        job = get_job_tag(),
        count = song_count
    })
end

--- @param song_count number Number of songs being refreshed
function BRDMessages.show_tank_refresh(song_count)
    M.job('BRD', 'tank_refresh', {
        job = get_job_tag(),
        count = song_count
    })
end

--- @param song_count number Number of songs being cast
function BRDMessages.show_healer_casting(song_count)
    M.job('BRD', 'healer_casting', {
        job = get_job_tag(),
        count = song_count
    })
end

--- @param song_count number Number of songs being refreshed
function BRDMessages.show_healer_refresh(song_count)
    M.job('BRD', 'healer_refresh', {
        job = get_job_tag(),
        count = song_count
    })
end

---============================================================================
--- INDIVIDUAL SONG MESSAGES (NEW SYSTEM)
---============================================================================

--- @param slot number Song slot (1-5)
--- @param song_name string Name of the song
function BRDMessages.show_song_cast(slot, song_name)
    -- DISABLED: Duplicate message (keep only the one with description)
    -- M.job('BRD', 'song_cast', {
    --     job = get_job_tag(),
    --     slot = slot,
    --     song = song_name
    -- })
end

--- @param slot number Song slot (3, 4, or 5)
--- @param dummy_count number Number of dummies required
function BRDMessages.show_song_guidance(slot, dummy_count)
    local dummy_text = dummy_count > 1 and "dummies" or "dummy"
    M.job('BRD', 'song_guidance', {
        job = get_job_tag(),
        slot = slot,
        dummy_count = dummy_count,
        dummy_text = dummy_text
    })
end

function BRDMessages.show_clarion_required()
    M.job('BRD', 'clarion_required', {
        job = get_job_tag()
    })
    M.job('BRD', 'clarion_help', {
        job = get_job_tag()
    })
end

---============================================================================
--- DEBUFF SONG MESSAGES (NEW SYSTEM)
---============================================================================

--- @param lullaby_type string "Horde" or "Foe"
function BRDMessages.show_lullaby_cast(lullaby_type)
    M.job('BRD', 'lullaby_cast', {
        job = get_job_tag(),
        type = lullaby_type
    })
end

function BRDMessages.show_elegy_cast()
    M.job('BRD', 'elegy_cast', {
        job = get_job_tag()
    })
end

function BRDMessages.show_requiem_cast()
    M.job('BRD', 'requiem_cast', {
        job = get_job_tag()
    })
end

--- @param element string Element name (Fire, Ice, etc.)
function BRDMessages.show_threnody_cast(element)
    M.job('BRD', 'threnody_cast', {
        job = get_job_tag(),
        element = element
    })
end

---============================================================================
--- BUFF SONG MESSAGES (NEW SYSTEM)
---============================================================================

--- @param element string Element name (Fire, Ice, etc.)
function BRDMessages.show_carol_cast(element)
    M.job('BRD', 'carol_cast', {
        job = get_job_tag(),
        element = element
    })
end

--- @param stat string Stat name (STR, DEX, etc.)
function BRDMessages.show_etude_cast(stat)
    M.job('BRD', 'etude_cast', {
        job = get_job_tag(),
        stat = stat
    })
end

---============================================================================
--- SONG REFINEMENT MESSAGES (NEW SYSTEM)
---============================================================================

--- @param original string Original song name
--- @param downgrade string Downgraded song name
--- @param recast_seconds number Recast time remaining
function BRDMessages.show_song_refinement(original, downgrade, recast_seconds)
    M.job('BRD', 'song_refinement', {
        job = get_job_tag(),
        original = original,
        downgrade = downgrade,
        recast = string.format("%.1f", recast_seconds)
    })
end

--- @param song_name string Song name
--- @param recast_seconds number Recast time remaining
function BRDMessages.show_song_refinement_failed(song_name, recast_seconds)
    M.job('BRD', 'song_refinement_failed', {
        job = get_job_tag(),
        song = song_name,
        recast = string.format("%.1f", recast_seconds)
    })
end

---============================================================================
--- BUFF STATUS MESSAGES (NEW SYSTEM)
---============================================================================

function BRDMessages.show_doom_gained()
    M.job('BRD', 'doom_gained', {
        job = get_job_tag()
    })
end

function BRDMessages.show_doom_removed()
    M.job('BRD', 'doom_removed', {
        job = get_job_tag()
    })
end

---============================================================================
--- ERROR MESSAGES (NEW SYSTEM)
---============================================================================

function BRDMessages.show_no_pack_configured()
    M.job('BRD', 'no_pack_configured', {
        job = get_job_tag()
    })
end

function BRDMessages.show_tank_not_configured()
    M.job('BRD', 'tank_not_configured', {
        job = get_job_tag()
    })
end

function BRDMessages.show_healer_not_configured()
    M.job('BRD', 'healer_not_configured', {
        job = get_job_tag()
    })
end

function BRDMessages.show_no_element_selected()
    M.job('BRD', 'no_element_selected', {
        job = get_job_tag()
    })
end

function BRDMessages.show_no_carol_element()
    M.job('BRD', 'no_carol_element', {
        job = get_job_tag()
    })
end

function BRDMessages.show_no_etude_type()
    M.job('BRD', 'no_etude_type', {
        job = get_job_tag()
    })
end

--- @param slot number Song slot (1-5)
function BRDMessages.show_no_song_in_slot(slot)
    M.job('BRD', 'no_song_in_slot', {
        job = get_job_tag(),
        slot = slot
    })
end

--- @param pack_name string Name of the pack
function BRDMessages.show_pack_not_found(pack_name)
    M.job('BRD', 'pack_not_found', {
        job = get_job_tag(),
        pack = tostring(pack_name)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BRDMessages

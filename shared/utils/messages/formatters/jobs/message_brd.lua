---============================================================================
--- BRD Messages Module - Bard Song and Ability Message Formatting
---============================================================================
--- Ability, instrument, song and error lines for BRD.
--- Templates: data/jobs/brd_messages.lua, sent through M.job.
---
--- @file shared/utils/messages/formatters/jobs/message_brd.lua
--- @author ejouanchicot
--- @version 2.0
--- @date Created: 2025-10-13 | Migrated: 2025-11-06
---============================================================================

local BRDMessages = {}

local M = require('shared/utils/messages/api/messages')

-- Job tag with subjob ("BRD/WHM"). Same logic as MessageCore.get_job_tag,
-- except the fallback is 'BRD' instead of 'JOB'.
local function get_job_tag()
    local main_job = player and player.main_job or 'BRD'
    local sub_job = player and player.sub_job or ''
    if sub_job and sub_job ~= '' and sub_job ~= 'NON' then
        return main_job .. '/' .. sub_job
    end
    return main_job
end

---============================================================================
--- ELEMENT COLOR MAPPING
---============================================================================

--- Element-specific color codes for Threnody/Carol songs (inline FFXI color codes)
--- @type table<string, string>
local ELEMENT_COLORS = {
    ['Fire']      = string.char(0x1F, 2),    -- Fire (code 002)
    ['Ice']       = string.char(0x1F, 30),   -- Ice (code 030)
    ['Wind']      = string.char(0x1F, 14),   -- Wind (code 014)
    ['Earth']     = string.char(0x1F, 37),   -- Earth (code 037)
    ['Lightning'] = string.char(0x1F, 16),   -- Lightning/Thunder (code 016)
    ['Thunder']   = string.char(0x1F, 16),   -- Thunder (alias for Lightning)
    ['Water']     = string.char(0x1F, 219),  -- Water (code 219)
    ['Light']     = string.char(0x1F, 187),  -- Light (code 187)
    ['Dark']      = string.char(0x1F, 200),  -- Dark (code 200)
}

--- Get element color code from element name
--- @param element string Element name (e.g., "Fire", "Ice")
--- @return string element_color Inline color code
local function get_element_color(element)
    return ELEMENT_COLORS[element] or string.char(0x1F, 13)  -- Cyan fallback
end

---============================================================================
--- ABILITY MESSAGES
---============================================================================

--- Show the BRD.marcato_used message
function BRDMessages.show_marcato_used()
    M.job('BRD', 'marcato_used', {
        job = get_job_tag()
    })
end

--- Show the BRD.pianissimo_used message
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
--- INSTRUMENT LOCK PROTECTION MESSAGES
---============================================================================

--- Show instrument lock message (generic for any song+instrument)
--- @param song_name string Song name (e.g., "Honor March", "Aria of Passion")
--- @param instrument string Instrument name (e.g., "Marsyas", "Loughnashade")
function BRDMessages.show_instrument_locked(song_name, instrument)
    M.job('BRD', 'instrument_locked', {
        job = get_job_tag(),
        song = song_name,
        instrument = instrument
    })
end

--- Show instrument release message (generic for any song+instrument)
--- @param song_name string Song name
--- @param instrument string Instrument name
function BRDMessages.show_instrument_released(song_name, instrument)
    M.job('BRD', 'instrument_released', {
        job = get_job_tag(),
        song = song_name,
        instrument = instrument
    })
end

---============================================================================
--- INSTRUMENT SELECTION MESSAGES
---============================================================================

--- Display dummy song instrument usage
--- @param song_name string Song name (e.g., 'Gold Capriccio', 'Foe Lullaby')
--- @param instrument string Instrument name (e.g., 'Daurdabla', 'Loughnashade', 'Blurred Harp +1')
function BRDMessages.show_daurdabla_dummy(song_name, instrument)
    M.job('BRD', 'daurdabla_dummy', {
        job = get_job_tag(),
        song_name = song_name or 'Unknown',
        instrument = instrument or 'Daurdabla'  -- Fallback if not provided
    })
end

---============================================================================
--- SONG CASTING MESSAGES
---============================================================================

--- @param song_count number Number of songs being cast (not shown)
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

--- @param total_songs number Total number of dummy songs
function BRDMessages.show_dummy_casting(total_songs)
    M.job('BRD', 'dummy_casting', {
        job = get_job_tag(),
        count = total_songs
    })
end

---============================================================================
--- DEBUFF SONG MESSAGES
---============================================================================

--- @param spell string The lullaby sent (BRD_SONG_CONFIG.lua DEBUFF_SONGS)
function BRDMessages.show_lullaby_cast(spell)
    M.job('BRD', 'lullaby_cast', {
        job = get_job_tag(),
        spell = spell or 'Lullaby'
    })
end

--- Show the BRD.elegy_cast message
--- @param spell string The elegy sent
function BRDMessages.show_elegy_cast(spell)
    M.job('BRD', 'elegy_cast', {
        job = get_job_tag(),
        spell = spell or 'Elegy'
    })
end

--- Show the BRD.requiem_cast message
--- @param spell string The requiem sent
function BRDMessages.show_requiem_cast(spell)
    M.job('BRD', 'requiem_cast', {
        job = get_job_tag(),
        spell = spell or 'Requiem'
    })
end

--- @param element string Element name (Fire, Ice, Lightning, etc.)
function BRDMessages.show_threnody_cast(element)
    local element_color = get_element_color(element)
    local gray_code = string.char(0x1F, 160)

    -- Color the entire spell name (element + "Threnody II")
    local colored_spell = element_color .. element .. ' Threnody II' .. gray_code

    M.job('BRD', 'threnody_cast', {
        job = get_job_tag(),
        spell = colored_spell
    })
end

---============================================================================
--- BUFF SONG MESSAGES
---============================================================================

--- @param element string Element name (Fire, Ice, Lightning, etc.)
function BRDMessages.show_carol_cast(element)
    local element_color = get_element_color(element)
    local gray_code = string.char(0x1F, 160)

    -- Color the entire spell name (element + "Carol II")
    local colored_spell = element_color .. element .. ' Carol II' .. gray_code

    M.job('BRD', 'carol_cast', {
        job = get_job_tag(),
        spell = colored_spell
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
--- SONG REFINEMENT MESSAGES
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
--- ERROR MESSAGES
---============================================================================

--- Show the BRD.no_element_selected message
function BRDMessages.show_no_element_selected()
    M.job('BRD', 'no_element_selected', {
        job = get_job_tag()
    })
end

--- Show the BRD.no_carol_element message
function BRDMessages.show_no_carol_element()
    M.job('BRD', 'no_carol_element', {
        job = get_job_tag()
    })
end

--- Show the BRD.no_etude_type message
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

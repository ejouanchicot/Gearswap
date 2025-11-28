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

-- Get job tag (for subjob support: BRD/WHM >> "BRD/WHM")
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
--- INSTRUMENT LOCK PROTECTION MESSAGES (NEW SYSTEM)
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

--- Legacy function names (for backward compatibility)
function BRDMessages.show_honor_march_locked()
    BRDMessages.show_instrument_locked('Honor March', 'Marsyas')
end

function BRDMessages.show_honor_march_released()
    BRDMessages.show_instrument_released('Honor March', 'Marsyas')
end

---============================================================================
--- INSTRUMENT SELECTION MESSAGES (NEW SYSTEM)
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
--- HELPER: Get element color from database
---============================================================================

--- Helper to get element color from spell database
--- @param spell_data table Spell data from database
--- @return string|nil element_color Inline color code or nil
local function get_element_color_from_data(spell_data)
    if not spell_data or not spell_data.element then
        return nil
    end
    return ELEMENT_COLORS[spell_data.element]
end

---============================================================================
--- GENERIC SONG CAST (with element color support)
---============================================================================

--- Display generic song cast with element color from database
--- Format: [BRD] [ELEMENT_COLOR][Song Name] >> Description
--- @param spell_name string Full spell name (e.g., "Valor Minuet IV")
--- @param spell_data table Spell data from database (must have 'element' and 'description')
function BRDMessages.show_song_cast_generic(spell_name, spell_data)
    if not spell_data then
        M.error(string.format("Spell '%s' has no database entry", spell_name))
        return
    end

    -- Get element color from database
    local element_color = get_element_color_from_data(spell_data)
    local gray_code = string.char(0x1F, 160)

    -- Add element color to spell name if spell has an element
    local colored_spell = spell_name
    if element_color then
        colored_spell = element_color .. spell_name .. gray_code
    end

    -- Use generic spell template with element color
    M.send('MAGIC', 'spell_activated_full', {
        job = get_job_tag(),
        spell = colored_spell,
        description = spell_data.description or "Unknown effect"
    })
end

---============================================================================
--- BUFF SONG MESSAGES (NEW SYSTEM)
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

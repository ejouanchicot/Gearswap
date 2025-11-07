---============================================================================
--- BRD Midcast Module - Powered by MidcastManager (Subjob Spells Only)
---============================================================================
--- Handles midcast for Bard with specialized Song instrument selection.
---
--- Features:
---   - Songs: Instrument selection (Gjallarhorn, Marsyas, Daurdabla)
---   - Dummy Songs: Duration gear (Troubadour)
---   - Lullaby: Special handling (no weapon swap)
---   - Subjob Spells: Cure, Enhancing Magic (via MidcastManager)
---
--- Note: Song logic is BRD-specific and NOT handled by MidcastManager.
---
--- @file BRD_MIDCAST.lua
--- @author Tetsouo
--- @version 3.0 - Added spell_family database support
--- @date Created: 2025-10-13 | Updated: 2025-11-05
---============================================================================

local MidcastManager = require('shared/utils/midcast/midcast_manager')
local SongRotationManager = require('shared/jobs/brd/functions/logic/song_rotation_manager')
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Load ENHANCING_MAGIC_DATABASE for spell_family routing
local EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

-- Load BRD_SPELL_DATABASE for song descriptions
local BRDSpells_success, BRDSpells = pcall(require, 'shared/data/magic/BRD_SPELL_DATABASE')

---============================================================================
--- SONG INSTRUMENT DETECTION
---============================================================================

--- Determine which instrument to use for a song
--- @param spell table Spell information
--- @return string|nil Instrument name or nil if no specific instrument
local function get_song_instrument(spell)
    if not spell or spell.skill ~= 'Singing' then
        return nil
    end

    -- Use centralized instrument selection logic
    return SongRotationManager.get_required_instrument(spell.english)
end

--- Check if song is a dummy song (for duration gear)
--- Uses centralized BRDSongConfig.DUMMY_SONGS list instead of pattern matching
--- @param spell_name string Song name
--- @return boolean is_dummy
local function is_dummy_song(spell_name)
    -- Use centralized config (loaded in character main file)
    if not _G.BRDSongConfig or not _G.BRDSongConfig.DUMMY_SONGS then
        return false
    end

    for _, dummy in ipairs(_G.BRDSongConfig.DUMMY_SONGS.standard) do
        if spell_name == dummy then
            return true
        end
    end

    return false
end

--- Check if song should NOT equip weapons (debuff songs that use sets without main/sub)
--- @param spell_name string Song name
--- @return boolean should_skip_weapons
local function is_no_weapon_song(spell_name)
    -- Lullaby songs (all variants)
    if spell_name:match('Lullaby') then
        return true
    end

    -- Threnody songs (all variants)
    if spell_name:match('Threnody') then
        return true
    end

    -- Debuff songs that use DebuffSong set (no main/sub defined)
    local debuff_songs = {
        'Battlefield Elegy',
        'Carnage Elegy',
        'Foe Requiem',
        "Maiden's Virelai",
        'Pining Nocturne',
        'Magic Finale'
    }

    for _, song in ipairs(debuff_songs) do
        if spell_name:match(song) then
            return true
        end
    end

    return false
end

---============================================================================
--- MIDCAST HOOKS
---============================================================================

function job_midcast(spell, action, spellMap, eventArgs)
    -- No BRD-specific PRE-midcast logic
end

function job_customize_midcast_set(midcastSet, spell)
    return midcastSet
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    ---========================================================================
    --- SINGING (BRD-SPECIFIC - NOT HANDLED BY MIDCASTMANAGER)
    ---========================================================================
    if spell.skill == 'Singing' then
        -- Display song message with description (like GEO does for Geomancy)
        if spell.english then
            local description = nil
            if BRDSpells_success and BRDSpells and BRDSpells.spells[spell.english] then
                description = BRDSpells.spells[spell.english].description
            end
            MessageFormatter.show_spell_activated(spell.english, description, nil)
        end

        -- CRITICAL: Instrument Lock Protection - ensure locked instrument stays equipped
        if _G.casting_locked_song and spell.type == 'BardSong' then
            if _G.locked_song_name == spell.english and _G.locked_instrument then
                equip({range = _G.locked_instrument})
                return
            end
        end

        local instrument = get_song_instrument(spell)
        local is_dummy = is_dummy_song(spell.english)
        local no_weapon_swap = is_no_weapon_song(spell.english)

        -- Dummy songs: Force Daurdabla only (for song slots expansion)
        if is_dummy then
            equip({range = 'Daurdabla'})
            MessageFormatter.show_daurdabla_dummy()
            return
        end

        -- Debuff songs: Skip instrument-specific logic (Mote equipped DebuffSong set)
        if no_weapon_swap then
            return
        end

        -- Normal songs: Use instrument-specific gear
        if instrument and sets.midcast.Songs and sets.midcast.Songs[instrument] then
            equip(sets.midcast.Songs[instrument])
        end

        -- Troubadour: Use duration gear
        if buffactive['Troubadour'] and sets.midcast.Songs.Duration then
            equip(sets.midcast.Songs.Duration)
        end

        return
    end

    ---========================================================================
    --- SUBJOB SPELLS (Handled by MidcastManager)
    ---========================================================================

    -- Healing Magic (Cure)
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
        return
    end

    -- Enhancing Magic (from subjob)
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end

    -- Enfeebling Magic (if RDM subjob)
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell
        })
        return
    end

    -- Elemental Magic (if BLM subjob)
    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell
        })
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_customize_midcast_set = job_customize_midcast_set
_G.job_post_midcast = job_post_midcast

local BRD_MIDCAST = {}
BRD_MIDCAST.job_midcast = job_midcast
BRD_MIDCAST.job_customize_midcast_set = job_customize_midcast_set
BRD_MIDCAST.job_post_midcast = job_post_midcast

return BRD_MIDCAST

---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Midcast Module - Powered by MidcastManager (Subjob Spells Only)
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Bard with specialized Song instrument selection.
---
---   Features:
---     - Songs: Instrument selection (Gjallarhorn, Marsyas, Loughnashade)
---     - Dummy Songs: Player-chosen instrument (sets.midcast.DummySong)
---     - Lullaby: Special handling (no weapon swap)
---     - Subjob Spells: Cure, Enhancing Magic (via MidcastManager)
---
---   Note: Song logic is BRD-specific and NOT handled by MidcastManager.
---
---   @file    shared/jobs/brd/functions/BRD_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.1 - Fix: Dummy songs use sets.midcast.DummySong (flexible instrument)
---   @date    Created: 2025-10-13 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local SongRotationManager = nil
local MessageFormatter = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local BRDSpells = nil
local BRDSpells_success = false

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    MidcastManager = require('shared/utils/midcast/midcast_manager')
    SongRotationManager = require('shared/jobs/brd/functions/logic/song_rotation_manager')
    MessageFormatter = require('shared/utils/messages/message_formatter')

    -- Expose SongRotationManager globally for MidcastManager
    _G.SongRotationManager = SongRotationManager

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    -- Load BRD_SPELL_DATABASE for song descriptions
    BRDSpells_success, BRDSpells = pcall(require, 'shared/data/magic/BRD_SPELL_DATABASE')

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SONG INSTRUMENT DETECTION
---  ═══════════════════════════════════════════════════════════════════════════

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

---  ═══════════════════════════════════════════════════════════════════════════
---   MIDCAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

function job_midcast(spell, action, spellMap, eventArgs)
    -- No BRD-specific PRE-midcast logic
end

function job_customize_midcast_set(midcastSet, spell)
    return midcastSet
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first midcast
    ensure_modules_loaded()

    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    ---========================================================================
    --- SINGING (NOW HANDLED BY MIDCASTMANAGER)
    ---========================================================================
    if spell.skill == 'Singing' then
        -- Check if dummy song FIRST
        local is_dummy = is_dummy_song(spell.english)

        -- Normal songs (non-dummy): Display message with description
        if not is_dummy and spell.english then
            local description = nil
            local element = nil
            local target_name = nil
            local target_type = nil

            if BRDSpells_success and BRDSpells and BRDSpells.spells[spell.english] then
                description = BRDSpells.spells[spell.english].description
                element = BRDSpells.spells[spell.english].element
            end

            -- Get target info if targeting someone other than self
            if spell.target and spell.target.name and spell.target.name ~= player.name then
                target_name = spell.target.name

                -- Detect target type with priority logic
                if spell.target.in_party or spell.target.in_alliance then
                    target_type = "PLAYER"
                elseif spell.target.charmed then
                    target_type = "PLAYER"
                elseif spell.target.spawn_type == 16 then
                    target_type = "MONSTER"
                elseif spell.target.is_npc then
                    target_type = "NPC"
                elseif spell.target.type then
                    target_type = spell.target.type
                else
                    target_type = "MONSTER"
                end
            end

            MessageFormatter.show_spell_activated(spell.english, description, target_name, spell.skill, element, target_type)
        end

        -- Dummy songs: Display instrument message ONLY (no generic spell message)
        if is_dummy then
            -- Equip the full DummySong set (includes player's chosen instrument)
            if sets.midcast and sets.midcast.DummySong then
                equip(sets.midcast.DummySong)

                -- Extract instrument name from the set for display
                local instrument = sets.midcast.DummySong.range or 'Unknown'
                MessageFormatter.show_daurdabla_dummy(spell.english, instrument)
            end
            return
        end

        -- Debuff songs (Lullaby, Threnody, etc.): NO weapon swap
        -- Let Mote-Include equip the appropriate set, we just skip instrument logic
        local no_weapon_swap = is_no_weapon_song(spell.english)
        if no_weapon_swap then
            -- Let Mote's midcast handle it (will use sets.midcast.Lullaby, sets.midcast.DebuffSong, etc.)
            return
        end

        -- Normal songs: Delegate to MidcastManager with skill='Singing'
        -- MidcastManager will handle:
        --   - Exact spell name fallback (Honor March, Aria of Passion)
        --   - Base song fallback
        --   - Song type fallback (Minne, Madrigal, etc.)
        --   - Instrument selection
        --   - Troubadour buff handling
        --   - Debug display
        MidcastManager.select_set({
            skill = 'Singing',
            spell = spell
        })

        -- CRITICAL: Instrument Lock Protection - force locked instrument AFTER MidcastManager
        -- This ensures Honor March/Aria of Passion keep their required instrument throughout cast
        if _G.casting_locked_song and spell.type == 'BardSong' then
            if _G.locked_song_name == spell.english and _G.locked_instrument then
                equip({range = _G.locked_instrument})
                if _G.MidcastManagerDebugState then
                    MessageFormatter.show_debug('BRD', 'Instrument locked: ' .. _G.locked_instrument)
                end
            end
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_customize_midcast_set = job_customize_midcast_set
_G.job_post_midcast = job_post_midcast

local BRD_MIDCAST = {}
BRD_MIDCAST.job_midcast = job_midcast
BRD_MIDCAST.job_customize_midcast_set = job_customize_midcast_set
BRD_MIDCAST.job_post_midcast = job_post_midcast

return BRD_MIDCAST

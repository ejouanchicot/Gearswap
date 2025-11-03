---============================================================================
--- BRD Spell Database - Complete Bard Song Data (Façade)
---============================================================================
--- Contains all BRD songs with accurate level requirements and official bg-wiki descriptions.
--- BRD-UNIQUE - Only Bard can cast songs.
---
--- @file BRD_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 3.0 - Modular Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---
--- ARCHITECTURE:
---   • song/song_buffs.lua: Party buff songs (68 total - Minuets, Paeons, Marches, Madrigals, Ballads, Etudes, Carols, Mambos, Status Resist, etc.)
---   • song/song_debuffs.lua: Enemy debuff songs (32 total - Requiems, Threnodies, Lullabies, Elegies, Finale, Virelai, Nocturne)
---   • song/song_special.lua: Special utility songs (2 total - Mazurkas only)
---
--- NOTES:
---   - BRD uses SONGS (not traditional spells)
---   - Songs have duration and can stack (max 2-5 songs depending on gear/merits)
---   - Songs are categorized by type: Buff, Debuff, Sleep, Charm, Utility
---   - Instruments affect song potency and duration
---   - Simplified descriptions (removed redundant "for party members within area of effect")
---   - Level requirements:
---     • 1-49: Subjob accessible
---     • 50-59: Subjob Master Level only
---     • 60+: Main job only
---     • 99 JP: Job Points required
---     • 99ℳ/ℒ: Master/Limit Level required
---============================================================================

local BRDSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

local buff_songs = require('shared/data/magic/song/song_buffs')
local debuff_songs = require('shared/data/magic/song/song_debuffs')
local special_songs = require('shared/data/magic/song/song_special')

---============================================================================
--- MERGE SPELL DATA
---============================================================================

BRDSpells.spells = {}

-- Merge buff songs
for song_name, song_data in pairs(buff_songs.spells) do
    BRDSpells.spells[song_name] = song_data
end

-- Merge debuff songs
for song_name, song_data in pairs(debuff_songs.spells) do
    BRDSpells.spells[song_name] = song_data
end

-- Merge special songs
for song_name, song_data in pairs(special_songs.spells) do
    BRDSpells.spells[song_name] = song_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn song at level
--- @param song_name string Song name
--- @param job_code string Job code (BRD, etc.)
--- @param level number Player level
--- @return boolean True if player can learn song
function BRDSpells.can_learn(song_name, job_code, level)
    local song = BRDSpells.spells[song_name]
    if not song then
        return false
    end

    local required_level = song[job_code]

    -- nil = job doesn't have access
    if not required_level then
        return false
    end

    return level >= required_level
end

--- Get all songs by category for a job
--- @param category string Category (Minne, Minuet, Paeon, Requiem, etc.)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of song names
function BRDSpells.get_songs_by_category(category, job_code, level)
    local available = {}

    for song_name, song_data in pairs(BRDSpells.spells) do
        if song_data.category == category then
            if BRDSpells.can_learn(song_name, job_code, level) then
                table.insert(available, song_name)
            end
        end
    end

    return available
end

--- Get songs by type
--- @param song_type string Song type ("Buff", "Debuff", "Sleep", "Charm", "Utility")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of song names
function BRDSpells.get_songs_by_type(song_type, job_code, level)
    local available = {}

    for song_name, song_data in pairs(BRDSpells.spells) do
        if song_data.song_type == song_type then
            if BRDSpells.can_learn(song_name, job_code, level) then
                table.insert(available, song_name)
            end
        end
    end

    return available
end

--- Get carol or threnody by element
--- @param category string "Carol" or "Threnody"
--- @param element string Element (Fire, Ice, Earth, Water, Wind, Thunder, Light, Dark)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of song names (tier I and II if available)
function BRDSpells.get_elemental_songs(category, element, job_code, level)
    local available = {}

    for song_name, song_data in pairs(BRDSpells.spells) do
        if song_data.category == category and song_data.element == element then
            if BRDSpells.can_learn(song_name, job_code, level) then
                table.insert(available, song_name)
            end
        end
    end

    return available
end

--- Get etude by stat
--- @param stat string Stat (STR, DEX, VIT, AGI, INT, MND, CHR)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of etude names (tier I and II if available)
function BRDSpells.get_etude_by_stat(stat, job_code, level)
    local available = {}

    for song_name, song_data in pairs(BRDSpells.spells) do
        if song_data.category == "Etude" and song_data.stat == stat then
            if BRDSpells.can_learn(song_name, job_code, level) then
                table.insert(available, song_name)
            end
        end
    end

    return available
end

--- Get all buff songs (most commonly used)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of buff song names
function BRDSpells.get_buff_songs(job_code, level)
    return BRDSpells.get_songs_by_type("Buff", job_code, level)
end

--- Get all debuff songs
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of debuff song names
function BRDSpells.get_debuff_songs(job_code, level)
    return BRDSpells.get_songs_by_type("Debuff", job_code, level)
end

return BRDSpells

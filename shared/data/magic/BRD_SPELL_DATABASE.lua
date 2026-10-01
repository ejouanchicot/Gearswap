---============================================================================
--- BRD Spell Database - Complete Bard Song Data (Facade)
---============================================================================
--- Contains all BRD songs with accurate level requirements and official bg-wiki descriptions.
--- BRD-UNIQUE - Only Bard can cast songs.
---
--- @file shared/data/magic/BRD_SPELL_DATABASE.lua
--- @author ejouanchicot
--- @version 3.0 - Improved formatting - Modular Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
--- @verified bg-wiki.com (2025-10-31)
---
--- ARCHITECTURE:
---   • song/song_buffs.lua: Party buff songs (73 total - Minuets, Paeons, Marches, Madrigals, Ballads, Etudes, Carols, Mambos, Status Resist, etc.)
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

return BRDSpells

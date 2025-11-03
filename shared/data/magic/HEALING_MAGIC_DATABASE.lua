---============================================================================
--- HEALING MAGIC DATABASE - Index & Helper Functions
---============================================================================
--- Centralized database for ALL Healing Magic spells across all jobs.
--- Replaces job-specific databases with skill-based architecture.
---
--- Features:
---   • Complete metadata for all Healing spells (loaded from 4 modules)
---   • Multi-job support (WHM, RDM, PLD, SCH)
---   • Cure types: single, aoe, self_aoe, self
---   • Element, tier, magic_type, descriptions
---   • Job Point requirements (Full Cure, Reraise IV)
---
--- Architecture:
---   - Modular: 4 sub-modules (~150-200 lines each)
---   - Skill-based (not job-based) for zero duplication
---   - Compatible with spell_message_handler.lua
---   - Type field for cure targeting (single/aoe/self_aoe/self)
---
--- Module Structure:
---   - healing_cure.lua (7 spells): Cure I-VI + Full Cure
---   - healing_curaga.lua (8 spells): Curaga I-V + Cura I-III (AoE heals)
---   - healing_raise.lua (8 spells): Raise I-III + Reraise I-IV + Arise
---   - healing_status.lua (9 spells): -na spells + Esuna + Sacrifice
---
--- Total: 32 Healing Magic spells
---
--- Usage:
---   local HealingSPELLS = require('shared/data/magic/HEALING_MAGIC_DATABASE')
---   local spell_data = HealingSPELLS.spells["Cure IV"]
---   local cure_type = spell_data.type  -- "single"
---
--- @file HEALING_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Modular Architecture (4 files)
--- @date Created: 2025-10-30
---============================================================================

local HEALING_MAGIC_DATABASE = {}

---============================================================================
--- LOAD SUB-MODULES
---============================================================================

local CURE = require('shared/data/magic/healing/healing_cure')
local CURAGA = require('shared/data/magic/healing/healing_curaga')
local RAISE = require('shared/data/magic/healing/healing_raise')
local STATUS = require('shared/data/magic/healing/healing_status')

---============================================================================
--- MERGE ALL SPELL DATABASES
---============================================================================

HEALING_MAGIC_DATABASE.spells = {}

-- Merge Cure spells (7 spells: Cure I-VI + Full Cure)
for spell_name, spell_data in pairs(CURE.spells) do
    HEALING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge AoE Cure spells (8 spells: Curaga I-V + Cura I-III)
for spell_name, spell_data in pairs(CURAGA.spells) do
    HEALING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Raise/Reraise spells (8 spells: Raise I-III + Reraise I-IV + Arise)
for spell_name, spell_data in pairs(RAISE.spells) do
    HEALING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Status removal spells (9 spells: -na + Esuna + Sacrifice)
for spell_name, spell_data in pairs(STATUS.spells) do
    HEALING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get cure type for a spell
--- @param spell_name string Name of spell
--- @return string|nil cure_type ("single", "aoe", "self_aoe", "self")
function HEALING_MAGIC_DATABASE.get_cure_type(spell_name)
    local spell_data = HEALING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.type
    end
    return nil
end

--- Check if spell is AoE (Curaga, Cura, Esuna)
--- @param spell_name string Name of spell
--- @return boolean is_aoe
function HEALING_MAGIC_DATABASE.is_aoe(spell_name)
    local spell_data = HEALING_MAGIC_DATABASE.spells[spell_name]
    if spell_data and (spell_data.type == "aoe" or spell_data.type == "self_aoe") then
        return true
    end
    return false
end

--- Check if spell is a status removal spell (-na, Esuna, Sacrifice)
--- @param spell_name string Name of spell
--- @return boolean is_status_removal
function HEALING_MAGIC_DATABASE.is_status_removal(spell_name)
    -- Check if spell ends with "na" or is Esuna/Sacrifice
    if spell_name:sub(-2) == "na" or spell_name == "Esuna" or spell_name == "Sacrifice" then
        return true
    end
    return false
end

--- Check if spell is a raise spell (Raise, Reraise, Arise)
--- @param spell_name string Name of spell
--- @return boolean is_raise
function HEALING_MAGIC_DATABASE.is_raise(spell_name)
    local spell_data = HEALING_MAGIC_DATABASE.spells[spell_name]
    if spell_data and spell_data.category == "Healing" then
        if spell_name:find("Raise") or spell_name:find("Reraise") or spell_name == "Arise" then
            return true
        end
    end
    return false
end

--- Check if spell is a cure spell (Cure, Curaga, Cura)
--- @param spell_name string Name of spell
--- @return boolean is_cure
function HEALING_MAGIC_DATABASE.is_cure(spell_name)
    if spell_name:find("Cure") or spell_name:find("Cura") then
        return true
    end
    return false
end

--- Get spell description
--- @param spell_name string Name of spell
--- @return string|nil description
function HEALING_MAGIC_DATABASE.get_description(spell_name)
    local spell_data = HEALING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.description
    end
    return nil
end

--- Get database statistics
--- @return table stats {total_spells, by_type, by_category, by_job}
function HEALING_MAGIC_DATABASE.get_stats()
    local stats = {
        total_spells = 0,
        by_type = {},
        by_category = {},
        by_job = {}
    }

    for spell_name, spell_data in pairs(HEALING_MAGIC_DATABASE.spells) do
        stats.total_spells = stats.total_spells + 1

        -- Count by type (single, aoe, self_aoe, self)
        local stype = spell_data.type or "unknown"
        stats.by_type[stype] = (stats.by_type[stype] or 0) + 1

        -- Count by category (Healing is the only category here)
        local cat = spell_data.category or "unknown"
        stats.by_category[cat] = (stats.by_category[cat] or 0) + 1

        -- Count by job
        for job, level in pairs(spell_data) do
            if type(level) == "number" then  -- Job entries are job = level_number
                stats.by_job[job] = (stats.by_job[job] or 0) + 1
            end
        end
    end

    return stats
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return HEALING_MAGIC_DATABASE

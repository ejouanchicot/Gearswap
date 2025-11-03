---============================================================================
--- RDM Spell Database - Façade (Public API)
---============================================================================
--- Provides unified access to all RDM spells using skill-based architecture.
--- Merges spells from HEALING_MAGIC_DATABASE, ENHANCING_MAGIC_DATABASE,
--- ENFEEBLING_MAGIC_DATABASE, and RDM-specific elemental spells.
---
--- @file RDM_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 3.0 - Skill-Based Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
---
--- ARCHITECTURE:
---   • ELEMENTAL_MAGIC_DATABASE (skill-based): Fire I-V, Blizzard I-V, etc.
---   • HEALING_MAGIC_DATABASE (skill-based): Cure I-IV, Raise I-II
---   • ENHANCING_MAGIC_DATABASE (skill-based): Protect, Shell, Regen, Refresh, Bar, En, etc.
---   • ENFEEBLING_MAGIC_DATABASE (skill-based): All enfeebling spells
---
--- USAGE:
---   local RDMSpells = require('shared/data/magic/RDM_SPELL_DATABASE')
---   local spell_data = RDMSpells.spells["Cure II"]
---   -- Access via helper functions: can_learn(), get_spells_by_category(), etc.
---
--- NOTES:
--- - RDM is a hybrid job with White Magic, Black Magic, and Red Magic
--- - RDM has access to elemental spells up to tier V (no tier VI)
--- - All spells accessible as main job or sub-job (no main_job_only restriction)
--- - Level 99 spells may require merits/gifts
---============================================================================

local RDMSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

-- Skill-based databases (universal)
local HealingDB = require('shared/data/magic/HEALING_MAGIC_DATABASE')
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')
local EnfeeblngDB = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
local ElementalDB = require('shared/data/magic/ELEMENTAL_MAGIC_DATABASE')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

RDMSpells.spells = {}

-- Merge RDM-accessible Elemental Magic spells from skill database (Fire I-V, etc.)
for spell_name, spell_data in pairs(ElementalDB.spells) do
    if spell_data.RDM then  -- Only if RDM has access to this spell
        RDMSpells.spells[spell_name] = spell_data
    end
end

-- Merge RDM-accessible Healing Magic spells from skill database (Cure I-IV, Raise I-II)
for spell_name, spell_data in pairs(HealingDB.spells) do
    if spell_data.RDM then  -- Only if RDM has access to this spell
        RDMSpells.spells[spell_name] = spell_data
    end
end

-- Merge RDM-accessible Enhancing spells from skill database
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.RDM then  -- Only if RDM has access to this spell
        RDMSpells.spells[spell_name] = spell_data
    end
end

-- Merge RDM-accessible Enfeebling spells from skill database
for spell_name, spell_data in pairs(EnfeeblngDB.spells) do
    if spell_data.RDM then  -- Only if RDM has access to this spell
        RDMSpells.spells[spell_name] = spell_data
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (RDM, etc.)
--- @param level number Player level
--- @return boolean True if player can learn spell
function RDMSpells.can_learn(spell_name, job_code, level)
    local spell = RDMSpells.spells[spell_name]
    if not spell then
        return false
    end

    local required_level = spell[job_code]

    -- nil = job doesn't have access
    if not required_level then
        return false
    end

    return level >= required_level
end

--- Get all spells by category for a job
--- @param category string Category (Elemental, Healing, Enhancing, Enfeebling, etc.)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function RDMSpells.get_spells_by_category(category, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(RDMSpells.spells) do
        if spell_data.category == category then
            if RDMSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all elemental spells by element and type
--- @param element string Element (Fire, Ice, etc.)
--- @param spell_type string "single" or "aoe"
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function RDMSpells.get_elemental_spells(element, spell_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(RDMSpells.spells) do
        if spell_data.category == "Elemental" and spell_data.element == element and spell_data.type == spell_type then
            if RDMSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get spells by magic type (White, Black, Red)
--- @param magic_type string Magic type ("White", "Black", "Red", "Dark")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function RDMSpells.get_spells_by_magic_type(magic_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(RDMSpells.spells) do
        if spell_data.magic_type == magic_type then
            if RDMSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get enfeebling type for spell (for equipment set selection)
--- @param spell_name string Spell name
--- @return string|nil Enfeebling type or nil if not enfeebling spell
---
--- Enfeebling Types:
--- - "macc": Magic Accuracy pure (Paralyze, Slow, Blind, Distract, Frazzle, Gravity, Poison)
--- - "mnd_potency": MND + Enfeebling Potency (Paralyze II, Slow II, Addle II)
--- - "int_potency": INT + Enfeebling Potency (Blind II)
--- - "skill_potency": Enfeebling Skill + Potency (Poison II)
--- - "skill_mnd_potency": Skill + MND + Potency (Frazzle III, Distract III)
--- - "potency": Potency pure (Dia I-III, Bio I-III, Gravity II)
--- - "duration": Duration focus (Sleep, Bind, Break, Silence)
function RDMSpells.get_enfeebling_type(spell_name)
    local spell = RDMSpells.spells[spell_name]
    if not spell then
        return nil
    end

    return spell.enfeebling_type
end

return RDMSpells

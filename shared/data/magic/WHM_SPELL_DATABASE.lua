---============================================================================
--- WHM Spell Database - Façade (Public API)
---============================================================================
--- Provides unified access to all WHM spells using skill-based architecture.
--- Merges spells from HEALING_MAGIC_DATABASE, ENHANCING_MAGIC_DATABASE,
--- and WHM-specific support spells (Divine, Enfeebling).
---
--- @file WHM_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 3.0 - Skill-Based Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
---
--- ARCHITECTURE:
---   • HEALING_MAGIC_DATABASE (skill-based): Cure, Curaga, Cura, Raise, -na, Esuna
---   • ENHANCING_MAGIC_DATABASE (skill-based): Protect, Shell, Regen, Bar, Boost, Teleport
---   • DIVINE_MAGIC_DATABASE (skill-based): Banish, Holy, Flash, Repose
---   • ENFEEBLING_MAGIC_DATABASE (skill-based): Paralyze, Slow, Silence, Addle, Dia
---
--- USAGE:
---   local WHMSpells = require('shared/data/magic/WHM_SPELL_DATABASE')
---   local spell_data = WHMSpells.spells["Cure IV"]
---   -- Access via helper functions: can_learn(), get_spells_by_category(), etc.
---
--- NOTES:
--- - WHM is the primary healer job in FFXI
--- - Has access to Cure I-VI, Curaga I-V, Cura I-III, Full Cure
--- - Unique Bar spells for elemental and status protection
--- - Teleport and Recall utility spells
--- - Boost spells for stat enhancement
--- - Limited enfeebling (Paralyze, Slow, Silence, Addle)
--- - Level 99 spells may require merits/gifts
---============================================================================

local WHMSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

-- Skill-based databases (universal)
local HealingDB = require('shared/data/magic/HEALING_MAGIC_DATABASE')
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')
local DivineDB = require('shared/data/magic/DIVINE_MAGIC_DATABASE')
local EnfeeblngDB = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

WHMSpells.spells = {}

-- Merge Healing Magic spells from skill database
-- (Cure I-VI, Curaga I-V, Cura I-III, Raise/Reraise, -na spells, Esuna, Sacrifice)
for spell_name, spell_data in pairs(HealingDB.spells) do
    if spell_data.WHM then  -- Only if WHM has access to this spell
        WHMSpells.spells[spell_name] = spell_data
    end
end

-- Merge WHM-accessible Enhancing spells from skill database
-- (Bar, Boost, Teleport, Recall, Protect, Shell, Regen, Erase, etc.)
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.WHM then  -- Only if WHM has access to this spell
        WHMSpells.spells[spell_name] = spell_data
    end
end

-- Merge WHM-accessible Divine Magic spells (Banish, Holy, Flash, Repose, etc.)
for spell_name, spell_data in pairs(DivineDB.spells) do
    if spell_data.WHM then  -- Only if WHM has access to this spell
        WHMSpells.spells[spell_name] = spell_data
    end
end

-- Merge WHM-accessible Enfeebling spells (Paralyze, Slow, Silence, Addle, Dia)
for spell_name, spell_data in pairs(EnfeeblngDB.spells) do
    if spell_data.WHM then  -- Only if WHM has access to this spell
        WHMSpells.spells[spell_name] = spell_data
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (WHM, etc.)
--- @param level number Player level
--- @return boolean True if player can learn spell
function WHMSpells.can_learn(spell_name, job_code, level)
    local spell = WHMSpells.spells[spell_name]
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
--- @param category string Category (Healing, Raise, Enhancing, BarElemental, etc.)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function WHMSpells.get_spells_by_category(category, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(WHMSpells.spells) do
        if spell_data.category == category then
            if WHMSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get cure spells by type
--- @param cure_type string "single", "aoe", or "self_aoe"
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function WHMSpells.get_cure_spells(cure_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(WHMSpells.spells) do
        if spell_data.category == 'Healing' and spell_data.type == cure_type then
            if WHMSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get bar spell by element
--- @param element string Element (Fire, Ice, Earth, Water, Wind, Thunder)
--- @param spell_type string "single" or "aoe"
--- @param job_code string Job code
--- @param level number Player level
--- @return string|nil Bar spell name
function WHMSpells.get_bar_elemental(element, spell_type, job_code, level)
    for spell_name, spell_data in pairs(WHMSpells.spells) do
        if spell_data.category == 'BarElemental' and spell_data.element == element and spell_data.type == spell_type then
            if WHMSpells.can_learn(spell_name, job_code, level) then
                return spell_name
            end
        end
    end

    return nil
end

--- Get all boost spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of boost spell names
function WHMSpells.get_boost_spells(job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(WHMSpells.spells) do
        if spell_data.category == 'Boost' then
            if WHMSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get teleport spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table Table of {spell_name = destination}
function WHMSpells.get_teleport_spells(job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(WHMSpells.spells) do
        if spell_data.category == 'Teleport' then
            if WHMSpells.can_learn(spell_name, job_code, level) then
                available[spell_name] = spell_data.destination
            end
        end
    end

    return available
end

--- Get recall spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table Table of {spell_name = destination}
function WHMSpells.get_recall_spells(job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(WHMSpells.spells) do
        if spell_data.category == 'Recall' then
            if WHMSpells.can_learn(spell_name, job_code, level) then
                available[spell_name] = spell_data.destination
            end
        end
    end

    return available
end

return WHMSpells

---============================================================================
--- SCH Spell Database - Façade (Public API)
---============================================================================
--- Provides unified access to all SCH spells using skill-based architecture.
--- Merges spells from HEALING_MAGIC_DATABASE, ENHANCING_MAGIC_DATABASE,
--- ENFEEBLING_MAGIC_DATABASE, and SCH-specific spells (Helix, Storm, Dark).
---
--- @file SCH_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 3.0 - Improved formatting - Skill-Based Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
---
--- ARCHITECTURE:
---   • HEALING_MAGIC_DATABASE (skill-based): Cure I-IV, Raise/Reraise I-III, -na spells
---   • ENHANCING_MAGIC_DATABASE (skill-based): Protect, Shell, Regen, Bar, etc.
---   • ENFEEBLING_MAGIC_DATABASE (skill-based): All enfeebling spells
---   • ELEMENTAL_MAGIC_DATABASE (skill-based): Fire I-V, Blizzard I-V, etc.
---   • DARK_MAGIC_DATABASE (skill-based): Drain, Aspir, Bio, Stun
---   • elemental/helix.lua: SCH-unique Helix spells (16 spells - DoT + stat down)
---   • enhancing/storm.lua: SCH-unique Storm spells (16 spells - weather effects)
---
--- USAGE:
---   local SCHSpells = require('shared/data/magic/SCH_SPELL_DATABASE')
---   local spell_data = SCHSpells.spells["Cure III"]
---   -- Access via helper functions: can_learn(), get_spells_by_category(), get_arts_requirement(), etc.
---
--- NOTES:
---   - SCH uses Arts system: Dark Arts (offensive) vs Light Arts (support)
---   - Addendum Black: Unlocks tier IV-V elemental + Sleep II, Break
---   - Addendum White: Unlocks status removal (Poisona, Paralyna, etc.) + Raise II-III
---   - Helix Spells: SCH-unique elemental DoT spells (16 total - I/II for 8 elements)
---     • Deal elemental damage over time affected by weather
---     • Additional effect: Lower enemy stats (Fire→INT, Ice→STR, etc.)
---   - Storm Spells: SCH-unique weather effect spells (16 total - I/II for 8 elements)
---     • Change weather around party member (Firestorm→'hot', Hailstorm→'snowy', etc.)
---     • Enhance elemental damage and add resistance
---   - Level 99 spells may require merits/gifts
---============================================================================

local SCHSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

-- Skill-based databases (universal)
local HealingDB = require('shared/data/magic/HEALING_MAGIC_DATABASE')
local EnhancingDB = require('shared/data/magic/ENHANCING_MAGIC_DATABASE')
local EnfeeblngDB = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
local ElementalDB = require('shared/data/magic/ELEMENTAL_MAGIC_DATABASE')
local DarkDB = require('shared/data/magic/DARK_MAGIC_DATABASE')

-- Job-specific modules (SCH-unique spells)
local helix = require('shared/data/magic/elemental/helix')
local storm = require('shared/data/magic/enhancing/storm')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

SCHSpells.spells = {}

-- Merge Healing Magic spells from skill database (Cure I-IV, Raise/Reraise I-III, -na spells)
for spell_name, spell_data in pairs(HealingDB.spells) do
    if spell_data.SCH then  -- Only if SCH has access to this spell
        SCHSpells.spells[spell_name] = spell_data
    end
end

-- Merge Enhancing Magic spells from skill database (Protect, Shell, Regen, Bar, etc.)
for spell_name, spell_data in pairs(EnhancingDB.spells) do
    if spell_data.SCH then  -- Only if SCH has access to this spell
        SCHSpells.spells[spell_name] = spell_data
    end
end

-- Merge Enfeebling Magic spells from skill database
for spell_name, spell_data in pairs(EnfeeblngDB.spells) do
    if spell_data.SCH then  -- Only if SCH has access to this spell
        SCHSpells.spells[spell_name] = spell_data
    end
end

-- Merge SCH-accessible Elemental Magic spells (Fire I-V, etc.)
for spell_name, spell_data in pairs(ElementalDB.spells) do
    if spell_data.SCH then  -- Only if SCH has access to this spell
        SCHSpells.spells[spell_name] = spell_data
    end
end

-- Merge SCH-accessible Dark Magic spells (Drain, Aspir, Bio, etc.)
for spell_name, spell_data in pairs(DarkDB.spells) do
    if spell_data.SCH then  -- Only if SCH has access to this spell
        SCHSpells.spells[spell_name] = spell_data
    end
end

-- Merge helix spells (SCH-unique DoT spells)
for spell_name, spell_data in pairs(helix.spells) do
    SCHSpells.spells[spell_name] = spell_data
end

-- Merge storm spells (SCH-unique weather spells)
for spell_name, spell_data in pairs(storm.spells) do
    SCHSpells.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (SCH, etc.)
--- @param level number Player level
--- @return boolean True if player can learn spell
function SCHSpells.can_learn(spell_name, job_code, level)
    local spell = SCHSpells.spells[spell_name]
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
--- @param category string Category (Elemental, Helix, Storm, Healing, Enhancing, etc.)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function SCHSpells.get_spells_by_category(category, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(SCHSpells.spells) do
        if spell_data.category == category then
            if SCHSpells.can_learn(spell_name, job_code, level) then
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
function SCHSpells.get_elemental_spells(element, spell_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(SCHSpells.spells) do
        if spell_data.category == "Elemental" and spell_data.element == element and spell_data.type == spell_type then
            if SCHSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get helix spell by element
--- @param element string Element (Fire, Ice, Earth, Water, Wind, Thunder, Dark, Light)
--- @param job_code string Job code
--- @param level number Player level
--- @return table Table with tier I and II helix names (if available)
function SCHSpells.get_helix_spells(element, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(SCHSpells.spells) do
        if spell_data.category == "Helix" and spell_data.element == element then
            if SCHSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get storm spell by element
--- @param element string Element (Fire, Ice, Earth, Water, Wind, Thunder, Dark, Light)
--- @param job_code string Job code
--- @param level number Player level
--- @return table Table with tier I and II storm names (if available)
function SCHSpells.get_storm_spells(element, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(SCHSpells.spells) do
        if spell_data.category == "Storm" and spell_data.element == element then
            if SCHSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get arts requirement for spell
--- @param spell_name string Spell name
--- @return string|nil Arts requirement ("Dark Arts", "Light Arts", "Addendum Black", "Addendum White")
function SCHSpells.get_arts_requirement(spell_name)
    local spell = SCHSpells.spells[spell_name]
    if not spell then
        return nil
    end

    return spell.arts
end

return SCHSpells

---============================================================================
--- BLU Spell Database - Complete Blue Mage Spell Data (Façade)
---============================================================================
--- Contains all BLU spells with accurate level requirements, spell points,
--- and trait data for optimal spell set building.
--- Data extracted from FFXI BLU spell list.
---
--- @file config/magic/BLU_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 2.1 - Improved formatting - Improved alignment - Façade Architecture
--- @date Created: 2025-10-12 | Updated: 2025-11-06
--- @date Refactored: 2025-10-12 | Updated: 2025-11-06
---
--- NOTES:
--- - BLU learns spells from monsters (not NPCs)
--- - Maximum 20 spells can be set at once
--- - Maximum 80 Spell Points total (trait_points sum)
--- - Spell Types: Physical, Magical, Breath, Healing, Buff, Debuff
--- - Physical spells have skillchain properties
--- - (U) = Unbridled spells (require Unbridled Learning/Wisdom)
--- - Trait points determine spell cost (higher = more powerful traits)
---
--- ARCHITECTURE:
--- - This file is a FAÇADE that loads internal modules
--- - Internal modules: physical, magical, breath, healing, buff, debuff
--- - All helper functions remain in this façade file
--- - Public API remains 100% unchanged for backward compatibility
---============================================================================

local BLUSpells = {}

---============================================================================
--- LOAD MODULAR FILES (NEW ARCHITECTURE - 19 files organized by category)
---============================================================================

-- Physical spells (5 files - 59 spells)
local physical_slashing = require('shared/data/magic/blu/physical/blu_physical_slashing')
local physical_blunt = require('shared/data/magic/blu/physical/blu_physical_blunt')
local physical_piercing = require('shared/data/magic/blu/physical/blu_physical_piercing')
local physical_h2h = require('shared/data/magic/blu/physical/blu_physical_h2h')
local physical_ranged = require('shared/data/magic/blu/physical/blu_physical_ranged')

-- Magical spells (8 files - 60 spells)
local magical_dark = require('shared/data/magic/blu/magical/blu_magical_dark')
local magical_water = require('shared/data/magic/blu/magical/blu_magical_water')
local magical_wind = require('shared/data/magic/blu/magical/blu_magical_wind')
local magical_fire = require('shared/data/magic/blu/magical/blu_magical_fire')
local magical_light = require('shared/data/magic/blu/magical/blu_magical_light')
local magical_thunder = require('shared/data/magic/blu/magical/blu_magical_thunder')
local magical_earth = require('shared/data/magic/blu/magical/blu_magical_earth')
local magical_ice = require('shared/data/magic/blu/magical/blu_magical_ice')

-- Breath spells (1 file - 11 spells)
local breath_spells = require('shared/data/magic/blu/breath/blu_breath')

-- Healing spells (1 file - 9 spells)
local healing_spells = require('shared/data/magic/blu/healing/blu_healing')

-- Buff spells (2 files - 28 spells)
local buffs_offensive = require('shared/data/magic/blu/buffs/blu_buffs_offensive')
local buffs_defensive = require('shared/data/magic/blu/buffs/blu_buffs_defensive')

-- Debuff spells (2 files - 29 spells)
local debuffs_control = require('shared/data/magic/blu/debuffs/blu_debuffs_control')
local debuffs_stats = require('shared/data/magic/blu/debuffs/blu_debuffs_stats')

---============================================================================
--- MERGE SPELL DATA (196 total BLU spells)
---============================================================================

BLUSpells.spells = {}

-- Merge physical spells (59 spells from 5 files)
for spell_name, spell_data in pairs(physical_slashing.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_blunt.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_piercing.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_h2h.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_ranged.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge magical spells (60 spells from 8 files)
for spell_name, spell_data in pairs(magical_dark.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_water.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_wind.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_fire.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_light.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_thunder.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_earth.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_ice.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge breath spells (11 spells from 1 file)
for spell_name, spell_data in pairs(breath_spells.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge healing spells (9 spells from 1 file)
for spell_name, spell_data in pairs(healing_spells.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge buff spells (28 spells from 2 files)
for spell_name, spell_data in pairs(buffs_offensive.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(buffs_defensive.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge debuff spells (29 spells from 2 files)
for spell_name, spell_data in pairs(debuffs_control.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(debuffs_stats.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (BLU, etc.)
--- @param level number Player level
--- @return boolean True if player can learn spell
function BLUSpells.can_learn(spell_name, job_code, level)
    local spell = BLUSpells.spells[spell_name]
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

--- Get all spells by spell type
--- @param spell_type string Spell type ("Physical", "Magical", "Breath", "Healing", "Buff", "Debuff")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function BLUSpells.get_spells_by_type(spell_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(BLUSpells.spells) do
        if spell_data.spell_type == spell_type then
            if BLUSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all physical spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of physical spell names
function BLUSpells.get_physical_spells(job_code, level)
    return BLUSpells.get_spells_by_type("Physical", job_code, level)
end

--- Get all magical spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of magical spell names
function BLUSpells.get_magical_spells(job_code, level)
    return BLUSpells.get_spells_by_type("Magical", job_code, level)
end

--- Get all breath spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of breath spell names
function BLUSpells.get_breath_spells(job_code, level)
    return BLUSpells.get_spells_by_type("Breath", job_code, level)
end

--- Get all healing spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of healing spell names
function BLUSpells.get_healing_spells(job_code, level)
    return BLUSpells.get_spells_by_type("Healing", job_code, level)
end

--- Get all buff spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of buff spell names
function BLUSpells.get_buff_spells(job_code, level)
    return BLUSpells.get_spells_by_type("Buff", job_code, level)
end

--- Get all debuff spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of debuff spell names
function BLUSpells.get_debuff_spells(job_code, level)
    return BLUSpells.get_spells_by_type("Debuff", job_code, level)
end

--- Get spells by element
--- @param element string Element (Fire, Ice, Wind, Earth, Thunder, Water, Light, Dark)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function BLUSpells.get_spells_by_element(element, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(BLUSpells.spells) do
        if spell_data.element             == element then
            if BLUSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get spells by trait
--- @param trait string Trait name (e.g., "Attack Bonus", "Magic Attack Bonus", "Fast Cast")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function BLUSpells.get_spells_by_trait(trait, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(BLUSpells.spells) do
        if spell_data.trait == trait then
            if BLUSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all unbridled spells (require Unbridled Learning/Wisdom)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of unbridled spell names
function BLUSpells.get_unbridled_spells(job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(BLUSpells.spells) do
        if spell_data.unbridled then
            if BLUSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Calculate total trait points for a spell list
--- @param spell_list table List of spell names
--- @return number Total trait points
function BLUSpells.calculate_trait_points(spell_list)
    local total = 0

    for _, spell_name in ipairs(spell_list) do
        local spell = BLUSpells.spells[spell_name]
        if spell and spell.trait_points then
            total = total + spell.trait_points
        end
    end

    return total
end

--- Get skillchain property for a spell
--- @param spell_name string Spell name
--- @return string|nil Skillchain property or nil
function BLUSpells.get_skillchain_property(spell_name)
    local spell = BLUSpells.spells[spell_name]
    if not spell then
        return nil
    end

    return spell.property
end

--- Get spell data
--- @param spell_name string Spell name
--- @return table|nil Spell data or nil
function BLUSpells.get_spell_data(spell_name)
    return BLUSpells.spells[spell_name]
end

return BLUSpells

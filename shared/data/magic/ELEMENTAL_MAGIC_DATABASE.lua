---============================================================================
--- Elemental Magic Database - Façade (Public API)
---============================================================================
--- Provides unified access to all Elemental Magic spells.
--- Merges spells from 7 modules into a single interface.
---
--- @file ELEMENTAL_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @verified bg-wiki.com (2025-10-30) - ALL 99 spells individually verified
---
--- ARCHITECTURE:
---   • elemental/elemental_single.lua (36 spells): Fire I-VI, Blizzard I-VI, etc.
---   • elemental/elemental_aoe_ga.lua (18 spells): Firaga I-III, Blizzaga I-III, etc. (BLM-only)
---   • elemental/elemental_aoe_ja.lua (6 spells): Firaja, Blizzaja, etc. (BLM-only tier IV)
---   • elemental/elemental_aoe_ra.lua (18 spells): Fira I-III, Blizzara I-III, etc. (GEO-only)
---   • elemental/elemental_ancient.lua (12 spells): Flare I-II, Freeze I-II, etc. (BLM-only)
---   • elemental/elemental_dot.lua (6 spells): Burn, Choke, Drown, Frost, Rasp, Shock (BLM-only)
---   • elemental/elemental_special.lua (3 spells): Comet, Meteor, Impact
---
--- EXCLUDED FROM DATABASE:
---   • Helix spells (Pyrohelix, Cryohelix, etc.) - SCH-unique, remain in internal/sch/helix.lua
---
--- USAGE:
---   local ElementalSpells = require('shared/data/magic/ELEMENTAL_MAGIC_DATABASE')
---   local spell_data = ElementalSpells.spells["Fire III"]
---   -- Access via helper functions: can_learn(), get_spells_by_element(), etc.
---
--- NOTES:
--- - Total: 99 spells
--- - Jobs: BLM (primary), SCH, RDM, GEO, DRK, WHM, SMN (Impact only)
--- - Tier I-III: Multi-job access
--- - Tier IV-VI: Restricted access (SCH requires Addendum: Black, RDM/GEO require JP Gifts)
--- - -ga spells: BLM-only AOE
--- - -ra spells: GEO-only AOE
--- - -ja spells: BLM-only AOE tier IV
--- - Ancient Magic: BLM-only high-power
--- - DOT spells: BLM-only damage over time
---============================================================================

local ElementalSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

local single = require('shared/data/magic/elemental/elemental_single')
local aoe_ga = require('shared/data/magic/elemental/elemental_aoe_ga')
local aoe_ja = require('shared/data/magic/elemental/elemental_aoe_ja')
local aoe_ra = require('shared/data/magic/elemental/elemental_aoe_ra')
local ancient = require('shared/data/magic/elemental/elemental_ancient')
local dot = require('shared/data/magic/elemental/elemental_dot')
local special = require('shared/data/magic/elemental/elemental_special')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

ElementalSpells.spells = {}

-- Merge single-target spells (36 spells: Fire I-VI, Blizzard I-VI, etc.)
for spell_name, spell_data in pairs(single.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

-- Merge AOE -ga spells (18 spells: Firaga I-III, etc., BLM-only)
for spell_name, spell_data in pairs(aoe_ga.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

-- Merge AOE -ja spells (6 spells: Firaja, etc., BLM-only tier IV)
for spell_name, spell_data in pairs(aoe_ja.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

-- Merge AOE -ra spells (18 spells: Fira I-III, etc., GEO-only)
for spell_name, spell_data in pairs(aoe_ra.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

-- Merge ancient magic spells (12 spells: Flare I-II, Freeze I-II, etc., BLM-only)
for spell_name, spell_data in pairs(ancient.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

-- Merge DOT spells (6 spells: Burn, Choke, etc., BLM-only)
for spell_name, spell_data in pairs(dot.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

-- Merge special spells (3 spells: Comet, Meteor, Impact)
for spell_name, spell_data in pairs(special.spells) do
    ElementalSpells.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (BLM, SCH, RDM, GEO, DRK, etc.)
--- @param level number Player level
--- @return boolean True if player can learn spell
function ElementalSpells.can_learn(spell_name, job_code, level)
    local spell = ElementalSpells.spells[spell_name]
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

--- Get all spells by element
--- @param element string Element (Fire, Ice, Wind, Earth, Thunder, Water, Dark)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function ElementalSpells.get_spells_by_element(element, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(ElementalSpells.spells) do
        if spell_data.element == element then
            if ElementalSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all spells by type
--- @param spell_type string Type ("single", "aoe", "self")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function ElementalSpells.get_spells_by_type(spell_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(ElementalSpells.spells) do
        if spell_data.type == spell_type then
            if ElementalSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all spells by tier
--- @param tier string Tier ("I", "II", "III", "IV", "V", "VI")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function ElementalSpells.get_spells_by_tier(tier, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(ElementalSpells.spells) do
        if spell_data.tier == tier then
            if ElementalSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get element for spell
--- @param spell_name string Spell name
--- @return string|nil Element or nil if spell not found
function ElementalSpells.get_element(spell_name)
    local spell = ElementalSpells.spells[spell_name]
    if not spell then
        return nil
    end

    return spell.element
end

--- Get spell tier
--- @param spell_name string Spell name
--- @return string|nil Tier or nil if spell not found
function ElementalSpells.get_tier(spell_name)
    local spell = ElementalSpells.spells[spell_name]
    if not spell then
        return nil
    end

    return spell.tier
end

--- Check if spell is AOE
--- @param spell_name string Spell name
--- @return boolean True if AOE spell
function ElementalSpells.is_aoe(spell_name)
    local spell = ElementalSpells.spells[spell_name]
    if not spell then
        return false
    end

    return spell.type == "aoe"
end

--- Get all Ancient Magic spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of Ancient Magic spell names
function ElementalSpells.get_ancient_magic(job_code, level)
    local available = {}

    -- Ancient Magic spells are Flare/Freeze/Tornado/Quake/Burst/Flood I-II
    local ancient_names = {
        "Flare", "Flare II", "Freeze", "Freeze II", "Tornado", "Tornado II",
        "Quake", "Quake II", "Burst", "Burst II", "Flood", "Flood II"
    }

    for _, spell_name in ipairs(ancient_names) do
        if ElementalSpells.can_learn(spell_name, job_code, level) then
            table.insert(available, spell_name)
        end
    end

    return available
end

--- Get all DOT spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of DOT spell names
function ElementalSpells.get_dot_spells(job_code, level)
    local available = {}

    -- DOT spells are Burn, Choke, Drown, Frost, Rasp, Shock
    local dot_names = {"Burn", "Choke", "Drown", "Frost", "Rasp", "Shock"}

    for _, spell_name in ipairs(dot_names) do
        if ElementalSpells.can_learn(spell_name, job_code, level) then
            table.insert(available, spell_name)
        end
    end

    return available
end

return ElementalSpells

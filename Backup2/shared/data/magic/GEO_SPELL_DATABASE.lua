---============================================================================
--- GEO Spell Database - Façade (Public API)
---============================================================================
--- Provides unified access to all GEO spells using modular architecture.
--- Merges spells from geomancy/, ELEMENTAL_MAGIC_DATABASE, and DARK_MAGIC_DATABASE.
---
--- @file GEO_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 3.0 - Improved formatting - Modular Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
---
--- ARCHITECTURE:
---   • geomancy/geomancy_indi.lua: All Indicolure (Indi-*) spells
---   • geomancy/geomancy_geo.lua: All Geocolure (Geo-*) spells - MAIN JOB ONLY
---   • ELEMENTAL_MAGIC_DATABASE (skill-based): Fire I-V, -ra series
---   • DARK_MAGIC_DATABASE (skill-based): Drain, Aspir I-III
---
--- USAGE:
---   local GEOSpells = require('shared/data/magic/GEO_SPELL_DATABASE')
---   local spell_data = GEOSpells.spells["Indi-Haste"]
---   -- Access via helper functions: can_learn(), get_colure_pair(), etc.
---
--- NOTES:
---   - Indicolure (Indi-*) spells: Self-centered aura, subjob accessible (with level restrictions)
---   - Geocolure (Geo-*) spells: Luopan-based AOE field, **MAIN JOB ONLY**
---   - Geo- spells learned through Geomantic Reservoirs after learning Indi- version
---   - Elemental spells: GEO has access up to tier V (no tier VI), includes -ra AOE series
---   - Dark magic: Drain, Aspir, Aspir II (90), Aspir III (99 JP)
---   - Levels 1-49: Subjob accessible
---   - Levels 50-59: Subjob with Master Level only
---   - Levels 60+: Main job only
---   - "JP" = Job Points required (level 99 Merit/Gift)
---============================================================================

local GEOSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

-- Geomancy-specific modules
local indi = require('shared/data/magic/geomancy/geomancy_indi')
local geo = require('shared/data/magic/geomancy/geomancy_geo')

-- Universal skill databases
local ElementalDB = require('shared/data/magic/ELEMENTAL_MAGIC_DATABASE')
local DarkDB = require('shared/data/magic/DARK_MAGIC_DATABASE')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

GEOSpells.spells = {}

-- Merge Indicolure spells (Indi-*)
for spell_name, spell_data in pairs(indi.spells) do
    GEOSpells.spells[spell_name] = spell_data
end

-- Merge Geocolure spells (Geo-*)
for spell_name, spell_data in pairs(geo.spells) do
    GEOSpells.spells[spell_name] = spell_data
end

-- Merge GEO-accessible Elemental Magic spells (Fire I-V, -ra series)
for spell_name, spell_data in pairs(ElementalDB.spells) do
    if spell_data.GEO then  -- Only if GEO has access to this spell
        GEOSpells.spells[spell_name] = spell_data
    end
end

-- Merge GEO-accessible Dark Magic spells (Drain, Aspir, Aspir II/III)
for spell_name, spell_data in pairs(DarkDB.spells) do
    if spell_data.GEO then  -- Only if GEO has access to this spell
        GEOSpells.spells[spell_name] = spell_data
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (GEO, etc.)
--- @param level number Player level
--- @param is_main_job boolean True if this is main job
--- @param has_master boolean True if player has master level
--- @return boolean True if player can learn spell
function GEOSpells.can_learn(spell_name, job_code, level, is_main_job, has_master)
    local spell = GEOSpells.spells[spell_name]
    if not spell then
        return false
    end

    local required_level = spell[job_code]

    -- nil = job doesn't have access
    if not required_level then
        return false
    end

    -- "JP" = Job Points required
    if required_level == "JP" then
        return false -- For now, skip JP spells
    end

    -- Main job only check (ALL Geocolure spells)
    if spell.main_job_only and not is_main_job then
        return false
    end

    -- Sub-job master level check
    if spell.subjob_master_only and not is_main_job and not has_master then
        return false
    end

    return level >= required_level
end

--- Get all spells by category for a job
--- @param category string Category (Indicolure, Geocolure, Elemental, Dark)
--- @param job_code string Job code
--- @param level number Player level
--- @param is_main_job boolean True if main job
--- @param has_master boolean True if has master level
--- @return table List of spell names
function GEOSpells.get_spells_by_category(category, job_code, level, is_main_job, has_master)
    local available = {}

    for spell_name, spell_data in pairs(GEOSpells.spells) do
        if spell_data.category == category then
            if GEOSpells.can_learn(spell_name, job_code, level, is_main_job, has_master) then
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
--- @param is_main_job boolean True if main job
--- @param has_master boolean True if has master level
--- @return table List of spell names
function GEOSpells.get_elemental_spells(element, spell_type, job_code, level, is_main_job, has_master)
    local available = {}

    for spell_name, spell_data in pairs(GEOSpells.spells) do
        if spell_data.category == "Elemental" and spell_data.element == element and spell_data.type == spell_type then
            if GEOSpells.can_learn(spell_name, job_code, level, is_main_job, has_master) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get Indicolure/Geocolure pairs
--- @param effect string Effect type (e.g., "Haste", "Refresh")
--- @param job_code string Job code
--- @param level number Player level
--- @param is_main_job boolean True if main job
--- @param has_master boolean True if has master level
--- @return table Table with indi and geo spell names
function GEOSpells.get_colure_pair(effect, job_code, level, is_main_job, has_master)
    local indi_name = "Indi-" .. effect
    local geo_name = "Geo-" .. effect

    local result = {
        indi = nil,
        geo = nil
    }

    if GEOSpells.can_learn(indi_name, job_code, level, is_main_job, has_master) then
        result.indi = indi_name
    end

    if GEOSpells.can_learn(geo_name, job_code, level, is_main_job, has_master) then
        result.geo = geo_name
    end

    return result
end

return GEOSpells

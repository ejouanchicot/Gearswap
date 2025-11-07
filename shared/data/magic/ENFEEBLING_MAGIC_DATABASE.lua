---============================================================================
--- ENFEEBLING MAGIC DATABASE - Index & Helper Functions
---============================================================================
--- Centralized database for ALL Enfeebling Magic spells across all jobs.
--- Replaces job-specific databases with skill-based architecture.
---
--- Features:
---   • Complete metadata for all Enfeebling spells (loaded from 3 modules)
---   • Multi-job support (RDM, WHM, BLM, GEO, DRK, SCH)
---   • enfeebling_type for RDM nested sets (macc, mnd_potency, int_potency, etc.)
---   • Element, tier, magic_type, descriptions
---   • AoE spell detection
---
--- Architecture:
---   - Modular: 3 sub-modules (~150-200 lines each)
---   - Skill-based (not job-based) for zero duplication
---   - Compatible with spell_message_handler.lua
---   - enfeebling_type field for RDM MidcastManager nested sets
---
--- Module Structure:
---   - enfeebling_dots.lua (10 spells): Dia/Bio/Poison (DoT effects)
---   - enfeebling_debuffs.lua (17 spells): Paralyze/Slow/Blind/Gravity + Red Magic
---   - enfeebling_control.lua (9 spells): Sleep/Bind/Silence/Break/Dispel (CC + utility)
---
--- Usage:
---   local EnfeeblingSPELLS = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
---   local spell_data = EnfeeblingSPELLS.spells["Slow II"]
---   local enfeebling_type = spell_data.enfeebling_type  -- "mnd_potency"
---
--- @file ENFEEBLING_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 2.1 - Improved formatting - Improved alignment - Modular Architecture (3 files)
--- @date Created: 2025-10-30 | Updated: 2025-11-06 | Updated: 2025-10-30
---============================================================================

local ENFEEBLING_MAGIC_DATABASE = {}

---============================================================================
--- LOAD SUB-MODULES
---============================================================================

local DOTS = require('shared/data/magic/enfeebling/enfeebling_dots')
local DEBUFFS = require('shared/data/magic/enfeebling/enfeebling_debuffs')
local CONTROL = require('shared/data/magic/enfeebling/enfeebling_control')

---============================================================================
--- MERGE ALL SPELL DATABASES
---============================================================================

ENFEEBLING_MAGIC_DATABASE.spells = {}

-- Merge DoT spells (10 spells)
for spell_name, spell_data in pairs(DOTS.spells) do
    ENFEEBLING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Debuff spells (17 spells)
for spell_name, spell_data in pairs(DEBUFFS.spells) do
    ENFEEBLING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Control spells (9 spells)
for spell_name, spell_data in pairs(CONTROL.spells) do
    ENFEEBLING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get enfeebling type for a spell (for RDM nested sets)
--- @param spell_name string Name of spell
--- @return string|nil enfeebling_type ("macc", "mnd_potency", "int_potency", etc.)
function ENFEEBLING_MAGIC_DATABASE.get_enfeebling_type(spell_name)
    local spell_data = ENFEEBLING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.enfeebling_type
    end
    return nil
end

--- Check if spell is AoE
--- @param spell_name string Name of spell
--- @return boolean is_aoe
function ENFEEBLING_MAGIC_DATABASE.is_aoe(spell_name)
    local spell_data = ENFEEBLING_MAGIC_DATABASE.spells[spell_name]
    if spell_data and spell_data.type == "aoe" then
        return true
    end
    return false
end

--- Get spell description
--- @param spell_name string Name of spell
--- @return string|nil description
function ENFEEBLING_MAGIC_DATABASE.get_description(spell_name)
    local spell_data = ENFEEBLING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.description
    end
    return nil
end

--- Get database statistics
--- @return table stats {total_spells, by_type, by_element, by_job}
function ENFEEBLING_MAGIC_DATABASE.get_stats()
    local stats = {
        total_spells = 0,
        by_type = {},
        by_element = {},
        by_job = {}
    }

    for spell_name, spell_data in pairs(ENFEEBLING_MAGIC_DATABASE.spells) do
        stats.total_spells = stats.total_spells + 1

        -- Count by enfeebling_type
        local etype = spell_data.enfeebling_type or "unknown"
        stats.by_type[etype] = (stats.by_type[etype] or 0) + 1

        -- Count by element
        local elem = spell_data.element or "None"
        stats.by_element[elem] = (stats.by_element[elem] or 0) + 1

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

return ENFEEBLING_MAGIC_DATABASE

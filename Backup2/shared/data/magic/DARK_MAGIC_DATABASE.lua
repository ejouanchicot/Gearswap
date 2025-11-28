---============================================================================
--- DARK MAGIC DATABASE - Index & Helper Functions
---============================================================================
--- Central repository for ALL Dark Magic spells in FFXI
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Features:
---   - 26 complete Dark Magic spells (loaded from 4 modules)
---   - Multi-job support (BLM, DRK, GEO, RDM, SCH)
---   - 100% accurate elements, levels, tiers from bg-wiki
---   - Special notation for Job Points spells (JP)
---   - Helper functions for spell lookups
---
--- Architecture:
---   - Modular: 4 sub-modules
---   - Skill-based (not job-based) for zero duplication
---   - Compatible with spell_message_handler.lua
---   - Element tracking (Darkness for all, except Stun = Lightning)
---
--- Module Structure:
---   - dark_absorb.lua (10 spells): Absorb-ACC, Absorb-STR, etc. (DRK only)
---   - dark_drain.lua (6 spells): Aspir I-III, Drain I-III
---   - dark_bio.lua (3 spells): Bio I-III (DoT spells)
---   - dark_utility.lua (7 spells): Death, Stun, Tractor, Dread Spikes, Endark, Kaustra
---
--- IMPORTANT NOTES:
---   - All Dark Magic spells are Darkness element EXCEPT Stun (Lightning)
---   - Many spells are DRK main job only (Absorb series, Drain II/III, Dread Spikes, Endark)
---   - Job Points (JP) spells: Death, Aspir III, Drain III, Endark II
---
--- @file DARK_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 2.0 - Improved formatting - Improved alignment - Modular Architecture (4 files)
--- @date Created: 2025-10-31 | Updated: 2025-11-06 | Updated: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Category:Dark_Magic
---============================================================================

local DARK_MAGIC_DATABASE = {}

---============================================================================
--- LOAD SUB-MODULES
---============================================================================

local ABSORB = require('shared/data/magic/dark/dark_absorb')
local DRAIN = require('shared/data/magic/dark/dark_drain')
local BIO = require('shared/data/magic/dark/dark_bio')
local UTILITY = require('shared/data/magic/dark/dark_utility')

---============================================================================
--- MERGE ALL SPELL DATABASES
---============================================================================

DARK_MAGIC_DATABASE.spells = {}

-- Merge Absorb spells (10 spells - DRK only)
for spell_name, spell_data in pairs(ABSORB.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Drain/Aspir spells (6 spells)
for spell_name, spell_data in pairs(DRAIN.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Bio spells (3 spells - DoT)
for spell_name, spell_data in pairs(BIO.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Utility spells (7 spells)
for spell_name, spell_data in pairs(UTILITY.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get spell description
--- @param spell_name string Name of spell
--- @return string|nil description
function DARK_MAGIC_DATABASE.get_description(spell_name)
    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.description
    end
    return nil
end

--- Get spell tier
--- @param spell_name string Name of spell
--- @return string|nil tier (I, II, III or nil)
function DARK_MAGIC_DATABASE.get_tier(spell_name)
    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.tier
    end
    return nil
end

--- Get spell element
--- @param spell_name string Name of spell
--- @return string element (Dark or Lightning for Stun)
function DARK_MAGIC_DATABASE.get_element(spell_name)
    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.element or "Dark"
    end
    return "Dark"
end

--- Check if spell is Job Points required
--- @param spell_name string Name of spell
--- @param job_code string Job code (BLM, DRK, etc.)
--- @return boolean is_jp_spell
function DARK_MAGIC_DATABASE.is_job_points_spell(spell_name, job_code)
    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if not spell_data then
        return false
    end

    local required_level = spell_data[job_code]
    return required_level == "JP"
end

--- Check if spell is DRK main job only
--- @param spell_name string Name of spell
--- @return boolean is_drk_only
function DARK_MAGIC_DATABASE.is_drk_only(spell_name)
    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if not spell_data then
        return false
    end

    return spell_data.main_job_only and spell_data.DRK ~= nil
end

--- Get all spells by category
--- @param category string Category name (Dark)
--- @param job_code string Job code
--- @param level number Player level
--- @param is_main_job boolean True if main job
--- @return table List of spell names
function DARK_MAGIC_DATABASE.get_spells_by_category(category, job_code, level, is_main_job)
    local available = {}

    for spell_name, spell_data in pairs(DARK_MAGIC_DATABASE.spells) do
        if spell_data.category            == category then
            local required_level = spell_data[job_code]

            -- Check if job has access
            if required_level then
                -- Skip JP spells for now
                if required_level ~= "JP" then
                    -- Check main job restriction
                    if not spell_data.main_job_only or is_main_job then
                        -- Check level requirement
                        if level >= required_level then
                            table.insert(available, spell_name)
                        end
                    end
                end
            end
        end
    end

    return available
end

--- Get all Absorb spells (DRK only)
--- @param level number Player level
--- @return table List of Absorb spell names
function DARK_MAGIC_DATABASE.get_absorb_spells(level)
    local available = {}

    for spell_name, spell_data in pairs(DARK_MAGIC_DATABASE.spells) do
        if spell_name:match("^Absorb%-") and spell_data.DRK then
            if level >= spell_data.DRK then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get Aspir/Drain spells by tier
--- @param spell_base string "Aspir" or "Drain"
--- @param tier string "I", "II", or "III"
--- @param job_code string Job code
--- @param level number Player level
--- @return string|nil spell_name
function DARK_MAGIC_DATABASE.get_drain_spell(spell_base, tier, job_code, level)
    local spell_name = spell_base
    if tier ~= "I" then
        spell_name = spell_base .. " " .. tier
    end

    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if not spell_data then
        return nil
    end

    local required_level = spell_data[job_code]
    if required_level and required_level ~= "JP" and level >= required_level then
        return spell_name
    end

    return nil
end

--- Get Bio spell by tier
--- @param tier string "I", "II", or "III"
--- @param job_code string Job code
--- @param level number Player level
--- @return string|nil spell_name
function DARK_MAGIC_DATABASE.get_bio_spell(tier, job_code, level)
    local spell_name = "Bio"
    if tier                == "II" then
        spell_name = "Bio II"
    elseif tier                == "III" then
        spell_name = "Bio III"
    end

    local spell_data = DARK_MAGIC_DATABASE.spells[spell_name]
    if not spell_data then
        return nil
    end

    local required_level = spell_data[job_code]
    if required_level and level >= required_level then
        return spell_name
    end

    return nil
end

---============================================================================
--- SPELL COUNT SUMMARY
---============================================================================
--- Total: 26 Dark Magic spells
---   - Absorb series: 10 spells (DRK only)
---   - Aspir series: 3 spells (multi-job)
---   - Bio series: 3 spells (multi-job)
---   - Drain series: 3 spells (DRK focus)
---   - Utility: 7 spells (Death, Stun, Tractor, Dread Spikes, Endark x2, Kaustra)
---
--- Jobs with Dark Magic access:
---   - BLM: Aspir, Drain, Bio, Death, Stun, Tractor
---   - DRK: All Absorbs, All Drains, Bio, Endark, Dread Spikes, Stun, Tractor
---   - GEO: Aspir, Drain
---   - RDM: Bio
---   - SCH: Aspir, Drain, Bio III, Kaustra
---============================================================================

return DARK_MAGIC_DATABASE

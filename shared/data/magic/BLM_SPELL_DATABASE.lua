---============================================================================
--- BLM Spell Database - Façade (Public API)
---============================================================================
--- Provides unified access to all BLM spells using skill-based architecture.
--- Merges spells from ELEMENTAL_MAGIC_DATABASE, DARK_MAGIC_DATABASE,
--- and ENFEEBLING_MAGIC_DATABASE.
---
--- @file BLM_SPELL_DATABASE.lua
--- @author Tetsouo
--- @version 3.0 - Improved formatting - Skill-Based Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
---
--- ARCHITECTURE:
---   • ELEMENTAL_MAGIC_DATABASE (skill-based): Fire I-VI, -ga, -ja, Ancient, DOT
---   • DARK_MAGIC_DATABASE (skill-based): Drain, Aspir, Bio, Stun, Dread Spikes
---   • ENFEEBLING_MAGIC_DATABASE (skill-based): Sleep, Bind, Blind, Poison
---
--- USAGE:
---   local BLMSpells = require('shared/data/magic/BLM_SPELL_DATABASE')
---   local spell_data = BLMSpells.spells["Fire IV"]
---   -- Access via helper functions: can_learn(), get_spells_by_category(), etc.
---
--- NOTES:
---   - BLM is the primary offensive magic job
---   - Has access to elemental magic I-VI, -ga I-III, -ja (tier IV AOE)
---   - Ancient Magic: Flare, Freeze, Tornado, Quake, Burst, Flood (I-II)
---   - DOT spells: Burn, Choke, Drown, Frost, Rasp, Shock
---   - Levels 50-59: Sub-job accessible with Master Level only
---   - Levels 60+: Main job only
---   - "JP" = Job Points required (level 99 Merit/Gift)
---============================================================================

local BLMSpells = {}

---============================================================================
--- LOAD UNIVERSAL DATABASES
---============================================================================

local ElementalDB = require('shared/data/magic/ELEMENTAL_MAGIC_DATABASE')
local DarkDB = require('shared/data/magic/DARK_MAGIC_DATABASE')
local EnfeeblngDB = require('shared/data/magic/ENFEEBLING_MAGIC_DATABASE')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

BLMSpells.spells = {}

-- Merge BLM-accessible Elemental Magic spells (Fire I-VI, -ga, -ja, Ancient, DOT, Special)
for spell_name, spell_data in pairs(ElementalDB.spells) do
    if spell_data.BLM then  -- Only if BLM has access to this spell
        BLMSpells.spells[spell_name] = spell_data
    end
end

-- Merge BLM-accessible Dark Magic spells (Drain, Aspir, Bio, Stun, etc.)
for spell_name, spell_data in pairs(DarkDB.spells) do
    if spell_data.BLM then  -- Only if BLM has access to this spell
        BLMSpells.spells[spell_name] = spell_data
    end
end

-- Merge BLM-accessible Enfeebling spells (Sleep, Bind, Blind, etc.)
for spell_name, spell_data in pairs(EnfeeblngDB.spells) do
    if spell_data.BLM then  -- Only if BLM has access to this spell
        BLMSpells.spells[spell_name] = spell_data
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (BLM, RDM, etc.)
--- @param level number Player level
--- @param is_main_job boolean True if this is main job
--- @param has_master boolean True if player has master level
--- @return boolean True if player can learn spell
function BLMSpells.can_learn(spell_name, job_code, level, is_main_job, has_master)
    local spell = BLMSpells.spells[spell_name]
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
        return false  -- For now, skip JP spells
    end

    -- Main job only check
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
--- @param category string Category (Elemental, Ancient, Dark, etc.)
--- @param job_code string Job code
--- @param level number Player level
--- @param is_main_job boolean True if main job
--- @param has_master boolean True if has master level
--- @return table List of spell names
function BLMSpells.get_spells_by_category(category, job_code, level, is_main_job, has_master)
    local available = {}

    for spell_name, spell_data in pairs(BLMSpells.spells) do
        if spell_data.category == category then
            if BLMSpells.can_learn(spell_name, job_code, level, is_main_job, has_master) then
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
function BLMSpells.get_elemental_spells(element, spell_type, job_code, level, is_main_job, has_master)
    local available = {}

    for spell_name, spell_data in pairs(BLMSpells.spells) do
        if spell_data.category == "Elemental" and spell_data.element == element and spell_data.type == spell_type then
            if BLMSpells.can_learn(spell_name, job_code, level, is_main_job, has_master) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all ancient magic spells
--- @param job_code string Job code
--- @param level number Player level
--- @param is_main_job boolean True if main job
--- @param has_master boolean True if has master level
--- @return table List of ancient magic spell names
function BLMSpells.get_ancient_magic(job_code, level, is_main_job, has_master)
    return BLMSpells.get_spells_by_category("Ancient", job_code, level, is_main_job, has_master)
end

return BLMSpells

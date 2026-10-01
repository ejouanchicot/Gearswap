---============================================================================
--- RDM Spell Database - Facade (Public API)
---============================================================================
--- Provides unified access to all RDM spells using skill-based architecture.
--- Merges spells from HEALING_MAGIC_DATABASE, ENHANCING_MAGIC_DATABASE,
--- ENFEEBLING_MAGIC_DATABASE, and RDM-specific elemental spells.
---
--- @file shared/data/magic/RDM_SPELL_DATABASE.lua
--- @author ejouanchicot
--- @version 3.0 - Improved formatting - Skill-Based Architecture Migration
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
--- - "potency": Potency pure (Dia I-III, Gravity II)
--- - "duration": Duration focus (Sleep, Bind, Break, Silence)
function RDMSpells.get_enfeebling_type(spell_name)
    local spell = RDMSpells.spells[spell_name]
    if not spell then
        return nil
    end

    return spell.enfeebling_type
end

return RDMSpells

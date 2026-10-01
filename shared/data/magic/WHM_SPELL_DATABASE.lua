---============================================================================
--- WHM Spell Database - Facade (Public API)
---============================================================================
--- Provides unified access to all WHM spells using skill-based architecture.
--- Merges spells from HEALING_MAGIC_DATABASE, ENHANCING_MAGIC_DATABASE,
--- and WHM-specific support spells (Divine, Enfeebling).
---
--- @file shared/data/magic/WHM_SPELL_DATABASE.lua
--- @author ejouanchicot
--- @version 3.0 - Improved formatting - Skill-Based Architecture Migration
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

return WHMSpells

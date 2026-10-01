---============================================================================
--- SCH Spell Database - Facade (Public API)
---============================================================================
--- Provides unified access to all SCH spells using skill-based architecture.
--- Merges spells from HEALING_MAGIC_DATABASE, ENHANCING_MAGIC_DATABASE,
--- ENFEEBLING_MAGIC_DATABASE, and SCH-specific spells (Helix, Storm, Dark).
---
--- @file shared/data/magic/SCH_SPELL_DATABASE.lua
--- @author ejouanchicot
--- @version 3.0 - Improved formatting - Skill-Based Architecture Migration
--- @date Created: 2025-10-12 | Updated: 2025-10-31
---
--- ARCHITECTURE:
---   • HEALING_MAGIC_DATABASE (skill-based): Cure I-IV, Raise/Reraise I-III, -na spells
---   • ENHANCING_MAGIC_DATABASE (skill-based): Protect, Shell, Regen, Bar, etc.
---   • ENFEEBLING_MAGIC_DATABASE (skill-based): All enfeebling spells
---   • ELEMENTAL_MAGIC_DATABASE (skill-based): Fire I-V, Blizzard I-V, etc.
---   • DARK_MAGIC_DATABASE (skill-based): Drain, Aspir I-II, Kaustra
---   • elemental/helix.lua: SCH-unique Helix spells (16 spells - DoT + stat down)
---   • enhancing/storm.lua: SCH-unique Storm spells (16 spells - weather effects)
---
--- USAGE:
---   local SCHSpells = require('shared/data/magic/SCH_SPELL_DATABASE')
---   local spell_data = SCHSpells.spells["Cure III"]
---
--- NOTES:
---   - SCH uses Arts system: Dark Arts (offensive) vs Light Arts (support)
---   - Addendum Black: Unlocks tier IV-V elemental + Sleep II, Break
---   - Addendum White: Unlocks status removal (Poisona, Paralyna, etc.) + Raise II-III
---   - Helix Spells: SCH-unique elemental DoT spells (16 total - I/II for 8 elements)
---     • Deal elemental damage over time affected by weather
---     • Additional effect: Lower enemy stats (Fire>>INT, Ice>>STR, etc.)
---   - Storm Spells: SCH-unique weather effect spells (16 total - I/II for 8 elements)
---     • Change weather around party member (Firestorm>>'hot', Hailstorm>>'snowy', etc.)
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

-- Merge SCH-accessible Dark Magic spells (Drain, Aspir, Kaustra)
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

return SCHSpells

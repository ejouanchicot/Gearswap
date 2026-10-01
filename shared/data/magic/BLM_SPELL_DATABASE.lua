---============================================================================
--- BLM Spell Database - Facade (Public API)
---============================================================================
--- Provides unified access to all BLM spells using skill-based architecture.
--- Merges spells from ELEMENTAL_MAGIC_DATABASE, DARK_MAGIC_DATABASE,
--- and ENFEEBLING_MAGIC_DATABASE.
---
--- @file shared/data/magic/BLM_SPELL_DATABASE.lua
--- @author ejouanchicot
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

return BLMSpells

---============================================================================
--- ENHANCING MAGIC DATABASE - Unified Module
---============================================================================
--- Consolidates all enhancing magic spell data from sub-modules and provides
--- a unified interface for spell_family lookup.
---
--- Spell Families (12 total):
---   - BarElement: Bar-element spells (skill-based, cap 500)
---   - BarAilment: Bar-status spells (fixed resistance)
---   - Aquaveil: Spell interruption reduction (breakpoints 301/501)
---   - Refresh: MP regeneration (fixed + gear bonuses)
---   - Regen: HP regeneration (fixed + gear bonuses)
---   - Enspell: Elemental weapon damage (no cap)
---   - Phalanx: Damage reduction (cap 500)
---   - Spikes: Damage reflection (INT/MAB based)
---   - Stoneskin: Damage absorption (MND + skill based, cap 540)
---   - Gain: Self stat buffs (RDM)
---   - Boost: Party stat buffs (WHM)
---   - Storm: Weather effects (SCH)
---   - nil: Generic enhancing (Protect/Shell/Haste/Teleport/etc.)
---
--- @file ENHANCING_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 2.0 - Improved formatting - Improved alignment - Unified database with spell_family support
--- @date Created: 2025-11-05 | Updated: 2025-11-06
---============================================================================

---============================================================================
--- MODULE DEPENDENCIES
---============================================================================

local ENHANCING_BARS = require('shared/data/magic/enhancing/enhancing_bars')
local ENHANCING_BUFFS = require('shared/data/magic/enhancing/enhancing_buffs')
local ENHANCING_COMBAT = require('shared/data/magic/enhancing/enhancing_combat')
local ENHANCING_UTILITY = require('shared/data/magic/enhancing/enhancing_utility')
local STORM = require('shared/data/magic/enhancing/storm')

---============================================================================
--- UNIFIED SPELL DATABASE
---============================================================================

local ENHANCING_MAGIC_DATABASE = {}

-- Consolidate all spell data into a single table
ENHANCING_MAGIC_DATABASE.spells = {}

-- Merge all sub-modules
for spell_name, spell_data in pairs(ENHANCING_BARS.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ENHANCING_BUFFS.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ENHANCING_COMBAT.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(ENHANCING_UTILITY.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

for spell_name, spell_data in pairs(STORM.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- SPELL FAMILY LOOKUP FUNCTION
---============================================================================

--- Get the spell_family for a given enhancing spell
--- Used by MidcastManager to route spells to category-based sets
--- @param spell_name string The name of the spell (e.g., "Gain-STR", "Enfire II")
--- @return string|nil The spell_family ("Gain", "Enspell", "BarElement", etc.) or nil
function ENHANCING_MAGIC_DATABASE.get_spell_family(spell_name)
    local spell_data = ENHANCING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.spell_family
    end
    return nil
end

---============================================================================
--- SPELL DATA LOOKUP FUNCTION
---============================================================================

--- Get full spell data for a given enhancing spell
--- @param spell_name string The name of the spell
--- @return table|nil The complete spell data table or nil
function ENHANCING_MAGIC_DATABASE.get_spell_data(spell_name)
    return ENHANCING_MAGIC_DATABASE.spells[spell_name]
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENHANCING_MAGIC_DATABASE

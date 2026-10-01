---============================================================================
--- Elemental Magic Database - Facade (Public API)
---============================================================================
--- Provides unified access to all Elemental Magic spells.
--- Merges spells from 7 modules into a single interface.
---
--- @file shared/data/magic/ELEMENTAL_MAGIC_DATABASE.lua
--- @author ejouanchicot
--- @version 2.0 - Improved formatting - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
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
---   • Helix spells (Pyrohelix, Cryohelix, etc.) - SCH-unique, in elemental/helix.lua (loaded by SCH_SPELL_DATABASE)
---
--- USAGE:
---   local ElementalSpells = require('shared/data/magic/ELEMENTAL_MAGIC_DATABASE')
---   local spell_data = ElementalSpells.spells["Fire III"]
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

return ElementalSpells

---============================================================================
--- GEO Spell Database - Facade (Public API)
---============================================================================
--- Provides unified access to all GEO spells using modular architecture.
--- Merges spells from geomancy/, ELEMENTAL_MAGIC_DATABASE, and DARK_MAGIC_DATABASE.
---
--- @file shared/data/magic/GEO_SPELL_DATABASE.lua
--- @author ejouanchicot
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

return GEOSpells

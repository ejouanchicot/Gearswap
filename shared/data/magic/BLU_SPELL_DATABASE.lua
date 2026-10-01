---============================================================================
--- BLU Spell Database - Complete Blue Mage Spell Data (Facade)
---============================================================================
--- Contains all BLU spells with accurate level requirements, spell points,
--- and trait data for optimal spell set building.
--- Data extracted from FFXI BLU spell list.
---
--- @file shared/data/magic/BLU_SPELL_DATABASE.lua
--- @author ejouanchicot
--- @version 2.1 - Improved formatting - Improved alignment - Facade Architecture
--- @date Created: 2025-10-12 | Updated: 2025-11-06
--- @date Refactored: 2025-10-12 | Updated: 2025-11-06
---
--- NOTES:
--- - BLU learns spells from monsters (not NPCs)
--- - Maximum 20 spells can be set at once
--- - Maximum 80 Spell Points total (trait_points sum)
--- - Spell Types: Physical, Magical, Breath, Healing, Buff, Debuff
--- - Physical spells have skillchain properties
--- - (U) = Unbridled spells (require Unbridled Learning/Wisdom)
--- - Trait points determine spell cost (higher = more powerful traits)
---
--- ARCHITECTURE:
--- - This file is a FAÇADE that loads internal modules
--- - Internal modules: physical, magical, breath, healing, buff, debuff
--- - All helper functions remain in this facade file
--- - Public API remains 100% unchanged for backward compatibility
---============================================================================

local BLUSpells = {}

---============================================================================
--- LOAD MODULAR FILES (NEW ARCHITECTURE - 19 files organized by category)
---============================================================================

-- Physical spells (5 files - 59 spells)
local physical_slashing = require('shared/data/magic/blu/physical/blu_physical_slashing')
local physical_blunt = require('shared/data/magic/blu/physical/blu_physical_blunt')
local physical_piercing = require('shared/data/magic/blu/physical/blu_physical_piercing')
local physical_h2h = require('shared/data/magic/blu/physical/blu_physical_h2h')
local physical_ranged = require('shared/data/magic/blu/physical/blu_physical_ranged')

-- Magical spells (8 files - 60 spells)
local magical_dark = require('shared/data/magic/blu/magical/blu_magical_dark')
local magical_water = require('shared/data/magic/blu/magical/blu_magical_water')
local magical_wind = require('shared/data/magic/blu/magical/blu_magical_wind')
local magical_fire = require('shared/data/magic/blu/magical/blu_magical_fire')
local magical_light = require('shared/data/magic/blu/magical/blu_magical_light')
local magical_thunder = require('shared/data/magic/blu/magical/blu_magical_thunder')
local magical_earth = require('shared/data/magic/blu/magical/blu_magical_earth')
local magical_ice = require('shared/data/magic/blu/magical/blu_magical_ice')

-- Breath spells (1 file - 11 spells)
local breath_spells = require('shared/data/magic/blu/breath/blu_breath')

-- Healing spells (1 file - 9 spells)
local healing_spells = require('shared/data/magic/blu/healing/blu_healing')

-- Buff spells (2 files - 28 spells)
local buffs_offensive = require('shared/data/magic/blu/buffs/blu_buffs_offensive')
local buffs_defensive = require('shared/data/magic/blu/buffs/blu_buffs_defensive')

-- Debuff spells (2 files - 29 spells)
local debuffs_control = require('shared/data/magic/blu/debuffs/blu_debuffs_control')
local debuffs_stats = require('shared/data/magic/blu/debuffs/blu_debuffs_stats')

---============================================================================
--- MERGE SPELL DATA (196 total BLU spells)
---============================================================================

BLUSpells.spells = {}

-- Merge physical spells (59 spells from 5 files)
for spell_name, spell_data in pairs(physical_slashing.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_blunt.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_piercing.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_h2h.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(physical_ranged.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge magical spells (60 spells from 8 files)
for spell_name, spell_data in pairs(magical_dark.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_water.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_wind.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_fire.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_light.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_thunder.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_earth.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(magical_ice.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge breath spells (11 spells from 1 file)
for spell_name, spell_data in pairs(breath_spells.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge healing spells (9 spells from 1 file)
for spell_name, spell_data in pairs(healing_spells.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge buff spells (28 spells from 2 files)
for spell_name, spell_data in pairs(buffs_offensive.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(buffs_defensive.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

-- Merge debuff spells (29 spells from 2 files)
for spell_name, spell_data in pairs(debuffs_control.spells) do
    BLUSpells.spells[spell_name] = spell_data
end
for spell_name, spell_data in pairs(debuffs_stats.spells) do
    BLUSpells.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get spell data
--- @param spell_name string Spell name
--- @return table|nil Spell data or nil
function BLUSpells.get_spell_data(spell_name)
    return BLUSpells.spells[spell_name]
end

return BLUSpells

---============================================================================
--- Divine Magic Database - Facade (Public API)
---============================================================================
--- Provides unified access to all Divine Magic spells.
--- Merges spells from 3 modules into a single interface.
---
--- @file shared/data/magic/DIVINE_MAGIC_DATABASE.lua
--- @author ejouanchicot
--- @version 2.0 - Improved formatting - Improved alignment
--- @date Created: 2025-10-30 | Updated: 2025-11-06
--- @verified bg-wiki.com (2025-10-30)
---
--- ARCHITECTURE:
---   • divine/divine_banish.lua (5 spells): Banish I-III, Banishga I-II
---   • divine/divine_enlight.lua (2 spells): Enlight I-II (PLD weapon enhancement)
---   • divine/divine_utility.lua (4 spells): Holy I-II, Flash, Repose
---
--- USAGE:
---   local DivineSpells = require('shared/data/magic/DIVINE_MAGIC_DATABASE')
---   local spell_data = DivineSpells.spells["Holy"]
---
--- NOTES:
--- - Total: 11 spells
--- - Jobs: WHM (primary), PLD (secondary), RUN (Flash only)
--- - Element: All spells are Light element
--- - Banish IV: entry commented out in divine_banish.lua, so it is not loaded
--- - Enlight II: Requires 100 Job Points (Job Point Gift)
--- - Effective against undead enemies
---============================================================================

local DivineSpells = {}

---============================================================================
--- LOAD MODULES
---============================================================================

local banish = require('shared/data/magic/divine/divine_banish')
local enlight = require('shared/data/magic/divine/divine_enlight')
local utility = require('shared/data/magic/divine/divine_utility')

---============================================================================
--- MERGE SPELL TABLES
---============================================================================

DivineSpells.spells = {}

-- Merge Banish spells (5 spells: Banish I-III + Banishga I-II)
for spell_name, spell_data in pairs(banish.spells) do
    DivineSpells.spells[spell_name] = spell_data
end

-- Merge Enlight spells (2 spells: Enlight I-II, PLD weapon enhancement)
for spell_name, spell_data in pairs(enlight.spells) do
    DivineSpells.spells[spell_name] = spell_data
end

-- Merge utility spells (4 spells: Holy I-II, Flash, Repose)
for spell_name, spell_data in pairs(utility.spells) do
    DivineSpells.spells[spell_name] = spell_data
end

return DivineSpells

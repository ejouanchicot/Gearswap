---============================================================================
--- DARK MAGIC DATABASE - Index & Helper Functions
---============================================================================
--- Central repository for ALL Dark Magic spells in FFXI
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Features:
---   - 26 complete Dark Magic spells (loaded from 4 modules)
---   - Multi-job support (BLM, DRK, GEO, RDM, SCH)
---   - 100% accurate elements, levels, tiers from bg-wiki
---   - Special notation for Job Points spells (JP)
---   - Helper functions for spell lookups
---
--- Architecture:
---   - Modular: 4 sub-modules
---   - Skill-based (not job-based) for zero duplication
---   - Compatible with spell_message_handler.lua
---   - Element tracking (Darkness for all, except Stun = Lightning)
---
--- Module Structure:
---   - dark_absorb.lua (10 spells): Absorb-ACC, Absorb-STR, etc. (DRK only)
---   - dark_drain.lua (6 spells): Aspir I-III, Drain I-III
---   - dark_bio.lua (3 spells): Bio I-III (DoT spells)
---   - dark_utility.lua (7 spells): Death, Stun, Tractor, Dread Spikes, Endark, Kaustra
---
--- IMPORTANT NOTES:
---   - All Dark Magic spells are Darkness element EXCEPT Stun (Lightning)
---   - Many spells are DRK main job only (Absorb series, Drain II/III, Dread Spikes, Endark)
---   - Job Points (JP) spells: Death, Aspir III, Drain III, Endark II
---
--- @file shared/data/magic/DARK_MAGIC_DATABASE.lua
--- @author ejouanchicot
--- @version 2.0 - Improved formatting - Improved alignment - Modular Architecture (4 files)
--- @date Created: 2025-10-31 | Updated: 2025-11-06
--- @source https://www.bg-wiki.com/ffxi/Category:Dark_Magic
---============================================================================

local DARK_MAGIC_DATABASE = {}

---============================================================================
--- LOAD SUB-MODULES
---============================================================================

local ABSORB = require('shared/data/magic/dark/dark_absorb')
local DRAIN = require('shared/data/magic/dark/dark_drain')
local BIO = require('shared/data/magic/dark/dark_bio')
local UTILITY = require('shared/data/magic/dark/dark_utility')

---============================================================================
--- MERGE ALL SPELL DATABASES
---============================================================================

DARK_MAGIC_DATABASE.spells = {}

-- Merge Absorb spells (10 spells - DRK only)
for spell_name, spell_data in pairs(ABSORB.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Drain/Aspir spells (6 spells)
for spell_name, spell_data in pairs(DRAIN.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Bio spells (3 spells - DoT)
for spell_name, spell_data in pairs(BIO.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Utility spells (7 spells)
for spell_name, spell_data in pairs(UTILITY.spells) do
    DARK_MAGIC_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- SPELL COUNT SUMMARY
---============================================================================
--- Total: 26 Dark Magic spells
---   - Absorb series: 10 spells (DRK only)
---   - Aspir series: 3 spells (multi-job)
---   - Bio series: 3 spells (multi-job)
---   - Drain series: 3 spells (DRK focus)
---   - Utility: 7 spells (Death, Stun, Tractor, Dread Spikes, Endark x2, Kaustra)
---
--- Jobs with Dark Magic access:
---   - BLM: Aspir, Drain, Bio, Death, Stun, Tractor
---   - DRK: All Absorbs, All Drains, Bio, Endark, Dread Spikes, Stun, Tractor
---   - GEO: Aspir, Drain
---   - RDM: Bio
---   - SCH: Aspir, Drain, Kaustra
---============================================================================

return DARK_MAGIC_DATABASE

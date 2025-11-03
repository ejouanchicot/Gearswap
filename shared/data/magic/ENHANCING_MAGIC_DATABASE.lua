---============================================================================
--- ENHANCING MAGIC DATABASE - Index & Helper Functions
---============================================================================
--- Central repository for ALL Enhancing Magic spells in FFXI
--- Data source: bg-wiki.com (official FFXI documentation)
---
--- Features:
---   - 138 complete Enhancing spells (loaded from 4 modules)
---   - Multi-job support (RDM, WHM, PLD, RUN, SCH, GEO, BLM)
---   - 100% accurate elements, levels, tiers from bg-wiki
---   - AoE detection (Protectra, Shellra, Bar-ra, Teleports, Boost spells)
---   - Helper functions for spell lookups
---
--- Architecture:
---   - Modular: 4 sub-modules (~500 lines each)
---   - Skill-based (not job-based) for zero duplication
---   - Compatible with spell_message_handler.lua
---   - No enhancing_type needed (simpler than Enfeebling)
---   - Target detection via MidcastManager.get_enhancing_target()
---
--- Module Structure:
---   - enhancing_bars.lua (28 spells): Bar-element + Bar-status
---   - enhancing_buffs.lua (32 spells): Protect/Shell/Regen/Refresh families
---   - enhancing_combat.lua (37 spells): Spike/Enspells/Storm/Haste/Phalanx/Temper
---   - enhancing_utility.lua (41 spells): Gain/Boost/Recall/Teleport/Warp/Scholar/Utility/Inundation/Klimaform
---
--- @file ENHANCING_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture (4 files)
--- @date Created: 2025-10-30 | Updated: 2025-10-30
---============================================================================

local ENHANCING_MAGIC_DATABASE = {}

---============================================================================
--- LOAD SUB-MODULES
---============================================================================

local BARS = require('shared/data/magic/enhancing/enhancing_bars')
local BUFFS = require('shared/data/magic/enhancing/enhancing_buffs')
local COMBAT = require('shared/data/magic/enhancing/enhancing_combat')
local UTILITY = require('shared/data/magic/enhancing/enhancing_utility')

---============================================================================
--- MERGE ALL SPELL DATABASES
---============================================================================

ENHANCING_MAGIC_DATABASE.spells = {}

-- Merge Bar-spells (28 spells)
for spell_name, spell_data in pairs(BARS.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Buff spells (32 spells)
for spell_name, spell_data in pairs(BUFFS.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Combat spells (37 spells)
for spell_name, spell_data in pairs(COMBAT.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

-- Merge Utility spells (40 spells)
for spell_name, spell_data in pairs(UTILITY.spells) do
    ENHANCING_MAGIC_DATABASE.spells[spell_name] = spell_data
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if spell is AoE
--- @param spell_name string Name of spell
--- @return boolean is_aoe
function ENHANCING_MAGIC_DATABASE.is_aoe(spell_name)
    local spell_data = ENHANCING_MAGIC_DATABASE.spells[spell_name]
    if spell_data and spell_data.type == "aoe" then
        return true
    end
    return false
end

--- Get spell description
--- @param spell_name string Name of spell
--- @return string|nil description
function ENHANCING_MAGIC_DATABASE.get_description(spell_name)
    local spell_data = ENHANCING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.description
    end
    return nil
end

--- Get spell tier
--- @param spell_name string Name of spell
--- @return string|nil tier (I, II, III, IV, V or nil)
function ENHANCING_MAGIC_DATABASE.get_tier(spell_name)
    local spell_data = ENHANCING_MAGIC_DATABASE.spells[spell_name]
    if spell_data then
        return spell_data.tier
    end
    return nil
end

--- Get database statistics
--- @return table stats {total_spells, by_tier, by_element, by_job, by_type}
function ENHANCING_MAGIC_DATABASE.get_stats()
    local stats = {
        total_spells = 0,
        by_tier = {},
        by_element = {},
        by_job = {},
        by_type = {single = 0, aoe = 0}
    }

    for spell_name, spell_data in pairs(ENHANCING_MAGIC_DATABASE.spells) do
        stats.total_spells = stats.total_spells + 1

        -- Count by tier
        local tier = spell_data.tier or "none"
        stats.by_tier[tier] = (stats.by_tier[tier] or 0) + 1

        -- Count by element
        local element = spell_data.element
        stats.by_element[element] = (stats.by_element[element] or 0) + 1

        -- Count by type
        if spell_data.type == "aoe" then
            stats.by_type.aoe = stats.by_type.aoe + 1
        else
            stats.by_type.single = stats.by_type.single + 1
        end

        -- Count by job
        for job, level in pairs(spell_data) do
            if type(level) == "number" then
                stats.by_job[job] = (stats.by_job[job] or 0) + 1
            end
        end
    end

    return stats
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return ENHANCING_MAGIC_DATABASE

---============================================================================
--- Divine Magic Database - Façade (Public API)
---============================================================================
--- Provides unified access to all Divine Magic spells.
--- Merges spells from 3 modules into a single interface.
---
--- @file DIVINE_MAGIC_DATABASE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-30
--- @verified bg-wiki.com (2025-10-30) - 11/12 spells verified (Banish IV level unknown)
---
--- ARCHITECTURE:
---   • divine/divine_banish.lua (6 spells): Banish I-IV, Banishga I-II
---   • divine/divine_enlight.lua (2 spells): Enlight I-II (PLD weapon enhancement)
---   • divine/divine_utility.lua (4 spells): Holy I-II, Flash, Repose
---
--- USAGE:
---   local DivineSpells = require('shared/data/magic/DIVINE_MAGIC_DATABASE')
---   local spell_data = DivineSpells.spells["Holy"]
---   -- Access via helper functions: can_learn(), get_spells_by_job(), etc.
---
--- NOTES:
--- - Total: 12 spells (11 verified, 1 needs verification)
--- - Jobs: WHM (primary), PLD (secondary), RUN (Flash only)
--- - Element: All spells are Light element
--- - Banish IV: Level requirement not documented on bg-wiki (marked as nil)
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

-- Merge Banish spells (6 spells: Banish I-IV + Banishga I-II)
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

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if job can learn spell at level
--- @param spell_name string Spell name
--- @param job_code string Job code (WHM, PLD, RUN, etc.)
--- @param level number Player level
--- @return boolean True if player can learn spell
function DivineSpells.can_learn(spell_name, job_code, level)
    local spell = DivineSpells.spells[spell_name]
    if not spell then
        return false
    end

    local required_level = spell[job_code]

    -- nil = job doesn't have access OR level unknown (e.g., Banish IV)
    if not required_level then
        return false
    end

    return level >= required_level
end

--- Get all spells by job
--- @param job_code string Job code (WHM, PLD, RUN)
--- @param level number Player level
--- @return table List of spell names
function DivineSpells.get_spells_by_job(job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(DivineSpells.spells) do
        if DivineSpells.can_learn(spell_name, job_code, level) then
            table.insert(available, spell_name)
        end
    end

    return available
end

--- Get all spells by type
--- @param spell_type string Type ("single", "aoe", "self")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function DivineSpells.get_spells_by_type(spell_type, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(DivineSpells.spells) do
        if spell_data.type == spell_type then
            if DivineSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all spells by tier
--- @param tier string Tier ("I", "II", "III", "IV")
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of spell names
function DivineSpells.get_spells_by_tier(tier, job_code, level)
    local available = {}

    for spell_name, spell_data in pairs(DivineSpells.spells) do
        if spell_data.tier == tier then
            if DivineSpells.can_learn(spell_name, job_code, level) then
                table.insert(available, spell_name)
            end
        end
    end

    return available
end

--- Get all Banish spells (single-target)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of Banish spell names
function DivineSpells.get_banish_spells(job_code, level)
    local available = {}

    local banish_names = {"Banish", "Banish II", "Banish III", "Banish IV"}

    for _, spell_name in ipairs(banish_names) do
        if DivineSpells.can_learn(spell_name, job_code, level) then
            table.insert(available, spell_name)
        end
    end

    return available
end

--- Get all Banishga spells (AOE)
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of Banishga spell names
function DivineSpells.get_banishga_spells(job_code, level)
    local available = {}

    local banishga_names = {"Banishga", "Banishga II"}

    for _, spell_name in ipairs(banishga_names) do
        if DivineSpells.can_learn(spell_name, job_code, level) then
            table.insert(available, spell_name)
        end
    end

    return available
end

--- Get all Holy spells
--- @param job_code string Job code
--- @param level number Player level
--- @return table List of Holy spell names
function DivineSpells.get_holy_spells(job_code, level)
    local available = {}

    local holy_names = {"Holy", "Holy II"}

    for _, spell_name in ipairs(holy_names) do
        if DivineSpells.can_learn(spell_name, job_code, level) then
            table.insert(available, spell_name)
        end
    end

    return available
end

--- Check if spell is effective against undead
--- @param spell_name string Spell name
--- @return boolean True if effective against undead
function DivineSpells.is_effective_vs_undead(spell_name)
    -- Banish, Banishga, and Holy spells are effective against undead
    local undead_effective = {
        ["Banish"] = true,
        ["Banish II"] = true,
        ["Banish III"] = true,
        ["Banish IV"] = true,
        ["Banishga"] = true,
        ["Banishga II"] = true,
        ["Holy"] = true,
        ["Holy II"] = true,
    }

    return undead_effective[spell_name] or false
end

return DivineSpells

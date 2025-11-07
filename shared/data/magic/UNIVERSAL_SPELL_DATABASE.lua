---============================================================================
--- Universal Spell Database - Auto-merged from all spell databases
---============================================================================
--- Automatically loads and merges all individual spell databases.
--- Used by spell message systems and validation to support all magic types.
---
--- This eliminates the magic type lookup problem:
---   • RDM can display both Enhancing + Enfeebling spells
---   • WHM can display both Healing + Divine spells
---   • BLM can display both Elemental + Dark spells
---   • Any job combination gets full spell coverage
---
--- Architecture:
---   • Individual databases remain separate (easy to maintain)
---   • Universal database merges them at runtime
---   • Message systems use this universal database for lookups
---
--- Database Coverage:
---   JOB-SPECIFIC (7):
---     • BLM (Elemental Magic specialist)
---     • BLU (Blue Magic specialist)
---     • BRD (Songs specialist)
---     • GEO (Geomancy specialist)
---     • RDM (Enhancing/Enfeebling specialist)
---     • SCH (Strategic Magic specialist)
---     • SMN (Summoning specialist)
---     • WHM (Healing/Divine specialist)
---
---   SKILL-BASED (6):
---     • ELEMENTAL_MAGIC (Fire, Blizzard, etc.)
---     • DARK_MAGIC (Bio, Drain, Aspir, etc.)
---     • DIVINE_MAGIC (Banish, Holy, etc.)
---     • ENFEEBLING_MAGIC (Slow, Paralyze, etc.)
---     • ENHANCING_MAGIC (Protect, Shell, Haste, etc.)
---     • HEALING_MAGIC (Cure, Curaga, Raise, etc.)
---
---   TOTAL: 14 databases, ~900+ spells
---
--- @file    UNIVERSAL_SPELL_DATABASE.lua
--- @author  Tetsouo
--- @version 2.0 - Improved formatting - Improved alignment - Initial Release
--- @date    Created: 2025-11-01 | Updated: 2025-11-06
---============================================================================

local UniversalSpells = {}
UniversalSpells.spells = {}
UniversalSpells.databases = {}

-- Message formatter for database load messages
local MessageDatabase = require('shared/utils/messages/formatters/system/message_database')

---============================================================================
--- DATABASE CONFIGURATION
---============================================================================

-- List of all spell databases (job-specific + skill-based)
local spell_database_configs = {
    -- JOB-SPECIFIC DATABASES (7)
    {file = 'BLM_SPELL_DATABASE',        type = 'job',  name = 'BLM'},
    {file = 'BLU_SPELL_DATABASE',        type = 'job',  name = 'BLU'},
    {file = 'BRD_SPELL_DATABASE',        type = 'job',  name = 'BRD'},
    {file = 'GEO_SPELL_DATABASE',        type = 'job',  name = 'GEO'},
    {file = 'RDM_SPELL_DATABASE',        type = 'job',  name = 'RDM'},
    {file = 'SCH_SPELL_DATABASE',        type = 'job',  name = 'SCH'},
    {file = 'SMN_SPELL_DATABASE',        type = 'job',  name = 'SMN'},
    {file = 'WHM_SPELL_DATABASE',        type = 'job',  name = 'WHM'},

    -- SKILL-BASED DATABASES (6)
    {file = 'ELEMENTAL_MAGIC_DATABASE',  type = 'skill', name = 'Elemental Magic'},
    {file = 'DARK_MAGIC_DATABASE',       type = 'skill', name = 'Dark Magic'},
    {file = 'DIVINE_MAGIC_DATABASE',     type = 'skill', name = 'Divine Magic'},
    {file = 'ENFEEBLING_MAGIC_DATABASE', type = 'skill', name = 'Enfeebling Magic'},
    {file = 'ENHANCING_MAGIC_DATABASE',  type = 'skill', name = 'Enhancing Magic'},
    {file = 'HEALING_MAGIC_DATABASE',    type = 'skill', name = 'Healing Magic'}
}

---============================================================================
--- AUTO-MERGE ALL SPELL DATABASES
---============================================================================

local total_loaded = 0
local failed_loads = {}

for _, config in ipairs(spell_database_configs) do
    local success, spell_db = pcall(require, 'shared/data/magic/' .. config.file)

    if success and spell_db then
        local spell_count = 0
        local spells_table = nil

        -- Handle different database formats
        -- Format 1: {spells = {...}}  (new format - BRD, SMN, etc.)
        -- Format 2: Direct table {...} (legacy format - some databases)
        if spell_db.spells then
            spells_table = spell_db.spells
        else
            -- Legacy format - database IS the spells table
            spells_table = spell_db
        end

        -- Merge all spells from this database
        if spells_table then
            for spell_name, spell_data in pairs(spells_table) do
                -- Skip metadata fields (functions, config, etc.)
                if type(spell_data) == 'table' and not spell_name:match('^_') then
                    -- Add database metadata to each spell
                    spell_data.source_database = config.file
                    spell_data.source_type = config.type
                    spell_data.source_name = config.name

                    -- Add to universal database at ROOT LEVEL (for compatibility)
                    UniversalSpells[spell_name] = spell_data

                    -- Also add to .spells table (for helper functions)
                    UniversalSpells.spells[spell_name] = spell_data
                    spell_count = spell_count + 1
                end
            end
        end

        -- Track database info
        UniversalSpells.databases[config.name] = {
            file = config.file,
            type                    = config.type,
            count = spell_count,
            format = spells_table and 'valid' or 'invalid'
        }

        total_loaded = total_loaded + spell_count

    else
        -- Track failed loads
        table.insert(failed_loads, {
            file = config.file,
            type                    = config.type,
            name = config.name,
            error = spell_db or "Unknown error"
        })
    end
end

-- Store load statistics
UniversalSpells.load_stats = {
    total_loaded = total_loaded,
    database_count = #spell_database_configs,
    failed_loads = failed_loads,
    load_date = os.date("%Y-%m-%d %H:%M:%S")
}

---============================================================================
--- HELPER FUNCTIONS - Universal Spell Lookup
---============================================================================

--- Get spell data by name
--- @param spell_name string The spell name
--- @return table|nil Spell data or nil if not found
function UniversalSpells.get_spell_data(spell_name)
    return UniversalSpells.spells[spell_name]
end

--- Check if a spell exists in the database
--- @param spell_name string The spell name
--- @return boolean True if spell exists
function UniversalSpells.spell_exists(spell_name)
    return UniversalSpells.spells[spell_name] ~= nil
end

--- Get spell skill type (Elemental Magic, Healing Magic, etc.)
--- @param spell_name string The spell name
--- @return string|nil Skill type or nil if not found
function UniversalSpells.get_spell_skill(spell_name)
    local spell_data = UniversalSpells.spells[spell_name]
    if not spell_data then
        return nil
    end

    return spell_data.skill or spell_data.type
end

--- Get spell element
--- @param spell_name string The spell name
--- @return string|nil Element or nil if not found/non-elemental
function UniversalSpells.get_spell_element(spell_name)
    local spell_data = UniversalSpells.spells[spell_name]
    if not spell_data then
        return nil
    end

    return spell_data.element
end

--- Get spell target type (Self, Single, AoE, etc.)
--- @param spell_name string The spell name
--- @return string|nil Target type or nil if not found
function UniversalSpells.get_spell_target(spell_name)
    local spell_data = UniversalSpells.spells[spell_name]
    if not spell_data then
        return nil
    end

    return spell_data.target
end

--- Search spells by partial name match (case-insensitive)
--- @param search_term string Search term
--- @return table Array of matching spell names
function UniversalSpells.search_spells(search_term)
    local result = {}
    local search_lower = search_term:lower()

    for spell_name, _ in pairs(UniversalSpells.spells) do
        if spell_name:lower():find(search_lower, 1, true) then
            table.insert(result, spell_name)
        end
    end

    return result
end

--- Get all spells from a specific database
--- @param database_name string Database name (BLM, Elemental Magic, etc.)
--- @return table Array of {spell_name, spell_data} or empty table
function UniversalSpells.get_spells_by_database(database_name)
    local result = {}

    for spell_name, spell_data in pairs(UniversalSpells.spells) do
        if spell_data.source_name == database_name then
            table.insert(result, {name = spell_name, data = spell_data})
        end
    end

    return result
end

--- Get all spells of a specific skill type
--- @param skill_type string Skill type (Elemental Magic, Healing Magic, etc.)
--- @return table Array of {spell_name, spell_data} or empty table
function UniversalSpells.get_spells_by_skill(skill_type)
    local result = {}

    for spell_name, spell_data in pairs(UniversalSpells.spells) do
        if spell_data.skill               == skill_type or spell_data.type == skill_type then
            table.insert(result, {name = spell_name, data = spell_data})
        end
    end

    return result
end

--- Get database load statistics
--- @return table Load statistics with counts and status
function UniversalSpells.get_load_stats()
    return UniversalSpells.load_stats
end

--- Print database load summary to chat
function UniversalSpells.print_load_summary()
    local stats = UniversalSpells.load_stats

    MessageDatabase.show_load_header('Universal Spell Database')
    MessageDatabase.show_total_loaded(stats.total_loaded, 'spells')
    MessageDatabase.show_database_count(stats.database_count)
    MessageDatabase.show_load_date(stats.load_date)

    if #stats.failed_loads > 0 then
        MessageDatabase.show_failed_count(#stats.failed_loads)
        for _, failure in ipairs(stats.failed_loads) do
            MessageDatabase.show_failed_item(failure.file, failure.name)
        end
    end

    MessageDatabase.show_separator()

    -- Print database breakdown
    MessageDatabase.show_breakdown_header()

    -- Job-specific databases
    MessageDatabase.show_category_header('Job-Specific')
    for db_name, info in pairs(UniversalSpells.databases) do
        if info.type == 'job' then
            MessageDatabase.show_database_entry(db_name, info.count, 'spells')
        end
    end

    -- Skill-based databases
    MessageDatabase.show_category_header('Skill-Based')
    for db_name, info in pairs(UniversalSpells.databases) do
        if info.type == 'skill' then
            MessageDatabase.show_database_entry(db_name, info.count, 'spells')
        end
    end

    MessageDatabase.show_separator()
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return UniversalSpells

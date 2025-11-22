---  ═══════════════════════════════════════════════════════════════════════════
---   Job Abilities Manager - Centralized JA Database Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides centralized access to job ability data from databases.
---   Loads ability descriptions, enmity values, and other metadata.
---   Integrates with JABuffs for automatic description display.
---
---   Features:
---     • Auto-loads databases for current job (main + subjob)
---     • Caches loaded databases for performance
---     • Provides ability descriptions for any job
---     • Returns enmity values for abilities
---     • Respects JA_MESSAGES_CONFIG for display control
---
---   Usage Examples:
---     local JAManager = require('shared/utils/job_abilities/job_abilities_manager')
---
---     -- Get ability info
---     local info = JAManager.get_ability_info("Berserk")
---     -- Returns: {description = "ATK+25%, DEF-25%", cumulative_enmity = 0, ...}
---
---     -- Show ability activation with auto-description
---     JAManager.show_ability_activation("Berserk")
---     -- Displays: [WAR/SAM] Berserk activated! ATK+25%, DEF-25%
---
---   @file    shared/utils/job_abilities/job_abilities_manager.lua
---   @author  Tetsouo
---   @version 1.1 - DRY refactor: Extract module loading helpers (-29 lines)
---   @date    Created: 2025-10-31 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local JAManager = {}

-- Load dependencies
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   DATABASE CACHE
---  ═══════════════════════════════════════════════════════════════════════════

--- Cache for loaded job ability databases
--- Format: {job_code = {subjob = {...}, mainjob = {...}, sp = {...}}}
local database_cache = {}

--- Job ability modules configuration
--- Maps job codes to their database module paths
local JOB_MODULES = {
    ['BLM'] = 'shared/data/job_abilities/blm',
    ['BLU'] = 'shared/data/job_abilities/blu',
    ['BRD'] = 'shared/data/job_abilities/brd',
    ['BST'] = 'shared/data/job_abilities/bst',
    ['COR'] = 'shared/data/job_abilities/cor',
    ['DNC'] = 'shared/data/job_abilities/dnc',
    ['DRG'] = 'shared/data/job_abilities/drg',
    ['DRK'] = 'shared/data/job_abilities/drk',
    ['GEO'] = 'shared/data/job_abilities/geo',
    ['MNK'] = 'shared/data/job_abilities/mnk',
    ['NIN'] = 'shared/data/job_abilities/nin',
    ['PLD'] = 'shared/data/job_abilities/pld',
    ['PUP'] = 'shared/data/job_abilities/pup',
    ['RDM'] = 'shared/data/job_abilities/rdm',
    ['RNG'] = 'shared/data/job_abilities/rng',
    ['RUN'] = 'shared/data/job_abilities/run',
    ['SAM'] = 'shared/data/job_abilities/sam',
    ['SCH'] = 'shared/data/job_abilities/sch',
    ['THF'] = 'shared/data/job_abilities/thf',
    ['WAR'] = 'shared/data/job_abilities/war',
    ['WHM'] = 'shared/data/job_abilities/whm'
}

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Load a specific module type (subjob, mainjob, sp) and merge abilities
--- @param base_path string Base module path
--- @param module_suffix string Module suffix (e.g., '_subjob', '_mainjob')
--- @param combined table Table to merge abilities into
local function load_module_type(base_path, module_suffix, combined)
    local success, module = pcall(require, base_path .. module_suffix)
    if success and module and module.abilities then
        for ability_name, ability_data in pairs(module.abilities) do
            combined[ability_name] = ability_data
        end
    end
end

--- Merge abilities from source to target with optional filter
--- @param source table Source abilities table
--- @param target table Target abilities table
--- @param filter_fn function|nil Optional filter function(name, data) -> boolean
local function merge_abilities(source, target, filter_fn)
    if not source then return end

    for ability_name, ability_data in pairs(source) do
        if not filter_fn or filter_fn(ability_name, ability_data) then
            target[ability_name] = ability_data
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DATABASE LOADING
---  ═══════════════════════════════════════════════════════════════════════════

--- Load job ability databases for a specific job
--- @param job_code string Job code (e.g., "WAR", "DNC", "BRD")
--- @return table|nil Combined abilities from all modules (subjob, mainjob, sp)
function JAManager.load_job_database(job_code)
    if not job_code or job_code == "" then
        return nil
    end

    -- Check cache first
    if database_cache[job_code] then
        return database_cache[job_code]
    end

    local base_path = JOB_MODULES[job_code]
    if not base_path then
        return nil  -- Unknown job
    end

    local combined_abilities = {}
    local job_lower = job_code:lower()

    -- Load subjob, mainjob, and SP abilities using helper
    load_module_type(base_path, '/' .. job_lower .. '_subjob', combined_abilities)
    load_module_type(base_path, '/' .. job_lower .. '_mainjob', combined_abilities)
    load_module_type(base_path, '/' .. job_lower .. '_sp', combined_abilities)

    -- Special handling for COR rolls (note: uses 'rolls' key, not 'abilities')
    if job_code == 'COR' then
        local success, module = pcall(require, base_path .. '/cor_rolls')
        if success and module and module.rolls then
            for roll_name, roll_data in pairs(module.rolls) do
                combined_abilities[roll_name] = roll_data
            end
        end
    end

    -- Special handling for SCH stratagems (both grimoires)
    if job_code == 'SCH' then
        load_module_type(base_path, '/sch_white_grimoire_subjob', combined_abilities)
        load_module_type(base_path, '/sch_black_grimoire_subjob', combined_abilities)
    end

    -- Cache the combined abilities
    database_cache[job_code] = combined_abilities

    return combined_abilities
end

--- Load databases for current player jobs (main + sub)
--- @return table Combined abilities from both main and subjob
function JAManager.load_current_jobs()
    if not player then
        return {}
    end

    local main_job = player.main_job
    local sub_job = player.sub_job

    local combined = {}

    -- Load main job database
    local main_db = JAManager.load_job_database(main_job)
    merge_abilities(main_db, combined)

    -- Load subjob database (only subjob-accessible abilities)
    if sub_job and sub_job ~= "" and sub_job ~= "NON" then
        local sub_db = JAManager.load_job_database(sub_job)
        -- Filter: exclude main_job_only abilities unless already in main job
        merge_abilities(sub_db, combined, function(name, data)
            return not data.main_job_only or combined[name]
        end)
    end

    return combined
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ABILITY INFO RETRIEVAL
---  ═══════════════════════════════════════════════════════════════════════════

--- Get information for a specific ability
--- Searches in main job first, then subjob databases
--- @param ability_name string Name of the ability
--- @param job_code string|nil Optional job code to search in specific job
--- @return table|nil Ability data (description, enmity, level, etc.)
function JAManager.get_ability_info(ability_name, job_code)
    if not ability_name then
        return nil
    end

    -- If job_code provided, search in that job's database
    if job_code then
        local job_db = JAManager.load_job_database(job_code)
        if job_db and job_db[ability_name] then
            return job_db[ability_name]
        end
        return nil
    end

    -- Otherwise search in current player's jobs
    local current_db = JAManager.load_current_jobs()
    return current_db[ability_name]
end

--- Get ability description
--- @param ability_name string Name of the ability
--- @return string|nil Description text or nil if not found
function JAManager.get_description(ability_name)
    local info = JAManager.get_ability_info(ability_name)
    return info and info.description or nil
end

--- Get ability enmity values
--- @param ability_name string Name of the ability
--- @return number, number Cumulative enmity, Volatile enmity (0, 0 if not found)
function JAManager.get_enmity(ability_name)
    local info = JAManager.get_ability_info(ability_name)
    if info then
        return info.cumulative_enmity or 0, info.volatile_enmity or 0
    end
    return 0, 0
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MESSAGE DISPLAY INTEGRATION
---  ═══════════════════════════════════════════════════════════════════════════

--- Show ability activation with automatic description lookup
--- Respects JA_MESSAGES_CONFIG display mode (full/on/off)
--- @param ability_name string Name of the ability
--- @param force_description string|nil Optional override description
function JAManager.show_ability_activation(ability_name, force_description)
    if not MessageFormatter or not MessageFormatter.show_ja_activated then
        return
    end

    -- Get description from database if not forced
    local description = force_description
    if not description then
        description = JAManager.get_description(ability_name)
    end

    -- Use JABuffs to display (respects config automatically)
    MessageFormatter.show_ja_activated(ability_name, description)
end

--- Show ability with description (colon format)
--- Format: [JOB] Ability: Description
--- @param ability_name string Name of the ability
--- @param force_description string|nil Optional override description
function JAManager.show_ability_description(ability_name, force_description)
    if not MessageFormatter or not MessageFormatter.show_ja_with_description then
        return
    end

    -- Get description from database if not forced
    local description = force_description
    if not description then
        description = JAManager.get_description(ability_name)
    end

    if description then
        MessageFormatter.show_ja_with_description(ability_name, description)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CACHE MANAGEMENT
---  ═══════════════════════════════════════════════════════════════════════════

--- Clear database cache (useful for testing or job changes)
function JAManager.clear_cache()
    database_cache = {}
end

--- Reload databases for current jobs
function JAManager.reload()
    JAManager.clear_cache()
    return JAManager.load_current_jobs()
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return JAManager

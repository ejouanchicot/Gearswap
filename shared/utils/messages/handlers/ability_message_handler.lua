---============================================================================
--- Universal Ability Message Handler - Multi-Database Ability Message System
---============================================================================
--- Automatically detects and displays ability messages for ANY job/subjob combo.
--- Works by checking ALL ability databases until ability is found.
---
--- **PERFORMANCE OPTIMIZATION:**
---   • LAZY-LOADED: Databases load on first ability usage (not at startup)
---   • Saves 420-630ms during job loading
---   • 21 job databases load only when first ability is used
---
--- Features:
---   - Works for main job AND subjob abilities
---   - Auto-detects ability database (job-based)
---   - Zero job-specific code needed
---   - Respects JA_MESSAGES_CONFIG
---
--- Display Modes:
---   - 'full': Shows ability name + description (NO recast/level info)
---   - 'on': Shows ability name only
---   - 'off': Silent mode
---
--- Architecture:
---   - Lazy-loads all 21 job ability databases on first ability
---   - Searches mainjob + subjob + SP abilities
---   - Falls back gracefully if not found
---
--- Examples:
---   - WAR/RUN using Ignis >> Shows message from RUN database
---   - DNC/WAR using Provoke >> Shows message from WAR database
---   - PLD using Sentinel >> Shows message from PLD database
---
--- @file ability_message_handler.lua
--- @author Tetsouo
--- @version 1.2 - PERFORMANCE: Lazy loading for 21 job databases
--- @date Created: 2025-11-01 | Updated: 2025-11-15
---============================================================================

local AbilityMessageHandler = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCore = require('shared/utils/messages/message_core')

---============================================================================
--- DUPLICATE PREVENTION
---============================================================================

-- Track recently displayed messages to prevent duplicates
-- Format: {ability_name = timestamp}
local recent_messages = {}
local DUPLICATE_THRESHOLD = 0.5  -- seconds (500ms)

---============================================================================
--- JOB-BASED DATABASES (LAZY LOADING - Performance Optimization)
---============================================================================

-- PERFORMANCE FIX: Databases are nil until first ability is used
-- This eliminates 420-630ms startup lag from loading ALL 21 job databases
local JOB_DATABASES = {}

-- List of all jobs with ability databases
local JOBS = {
    'BLM', 'BLU', 'BRD', 'BST', 'COR', 'DNC', 'DRG', 'DRK',
    'GEO', 'MNK', 'NIN', 'PLD', 'PUP', 'RDM', 'RNG', 'RUN',
    'SAM', 'SCH', 'THF', 'WAR', 'WHM'
}

-- LAZY LOADING: Load databases on first ability usage, not at module load
local databases_loaded = false

local function ensure_databases_loaded()
    if databases_loaded then
        return  -- Already loaded
    end

    -- Load each job database (safe loading)
    for _, job_code in ipairs(JOBS) do
        local success, db = pcall(require, 'shared/data/job_abilities/' .. job_code .. '_JA_DATABASE')
        if success and db then
            JOB_DATABASES[job_code] = db
        end
    end

    databases_loaded = true
end

-- Load message config ONCE and cache the reference
-- The table is modified by set_display_mode() so we always see current mode
local JA_MESSAGES_CONFIG = nil

local function ensure_config_loaded()
    if not JA_MESSAGES_CONFIG then
        local success, config = pcall(require, 'shared/config/JA_MESSAGES_CONFIG')
        if success then
            JA_MESSAGES_CONFIG = config
        else
            JA_MESSAGES_CONFIG = {
                display_mode = 'on',
                is_enabled = function() return true end,
                show_description = function() return false end
            }
        end
    end
end

---============================================================================
--- ABILITY LOOKUP
---============================================================================

--- Search for ability in all loaded databases
--- @param ability_name string Ability name
--- @return table|nil ability_data Ability data if found
--- @return string|nil database_name Name of database where ability was found
local function find_ability_in_databases(ability_name)
    -- LAZY LOAD: Ensure databases are loaded before searching
    ensure_databases_loaded()

    -- PRIORITY 1: Check job ability databases
    for job_code, db in pairs(JOB_DATABASES) do
        if db then
            -- Check if db has .abilities field (new format) or is direct table (legacy format)
            local abilities_table = db.abilities or db

            if abilities_table then
                local ability_data = abilities_table[ability_name]
                if ability_data then
                    return ability_data, job_code
                end
            end
        end
    end

    -- PRIORITY 2: Fallback to SMN spell database for Blood Pacts
    -- Blood Pacts are stored as spells but treated as abilities by GearSwap
    local smn_success, SMNSpells = pcall(require, 'shared/data/magic/SMN_SPELL_DATABASE')
    if smn_success and SMNSpells and SMNSpells.spells then
        local blood_pact = SMNSpells.spells[ability_name]
        if blood_pact then
            -- Check if it's actually a Blood Pact (not Avatar Summon)
            if blood_pact.category == "Blood Pact: Rage" or blood_pact.category == "Blood Pact: Ward" then
                return blood_pact, 'SMN'
            end
        end
    end

    return nil, nil
end

---============================================================================
--- MESSAGE DISPLAY
---============================================================================

--- Check if messages are enabled
--- @return boolean True if messages should be shown
local function is_enabled()
    ensure_config_loaded()
    if JA_MESSAGES_CONFIG.is_enabled then
        return JA_MESSAGES_CONFIG.is_enabled()
    end
    return true
end

--- Check if full description should be shown
--- @return boolean True if full description mode
local function show_full_description()
    ensure_config_loaded()
    if JA_MESSAGES_CONFIG.show_description then
        return JA_MESSAGES_CONFIG.show_description()
    end
    return JA_MESSAGES_CONFIG.display_mode == 'full'
end

--- Show ability message if config enabled
--- @param spell table Spell/Ability object from GearSwap
--- @param show_separator boolean Optional - show separator after message (default: true)
function AbilityMessageHandler.show_message(spell, show_separator)
    -- Only handle abilities (not spells, weaponskills, items)
    if not spell or spell.action_type ~= 'Ability' then
        return
    end

    -- EXCLUSION: Skip CorsairRoll (has specialized roll_tracker messages)
    if spell.type == 'CorsairRoll' then
        return
    end

    -- EXCLUSION: Skip Pianissimo (has custom message with target name in BRD_PRECAST)
    if spell.name == 'Pianissimo' then
        return
    end

    -- Check if messages are enabled
    if not is_enabled() then
        return
    end

    -- Find ability in databases
    local ability_data, db_name = find_ability_in_databases(spell.name)

    if not ability_data then
        -- Ability not found in any database (might be pet command, universal ability, etc.)
        return
    end

    -- Prepare description (only if mode is 'full')
    local description = nil
    if show_full_description() then
        description = ability_data.description
    end

    -- Duplicate prevention: Check if this message was shown recently
    local current_time = os.clock()
    local last_shown = recent_messages[spell.name]

    if last_shown and (current_time - last_shown) < DUPLICATE_THRESHOLD then
        -- Message shown recently, skip to avoid duplicate
        return
    end

    -- Update last shown timestamp
    recent_messages[spell.name] = current_time

    -- Display message using JA format (not spell format!)
    -- Mode 'full': shows description
    -- Mode 'on': shows name only (description = nil)
    local message_length = MessageFormatter.show_ja_activated(spell.name, description)

    -- Display separator after ability message (default: true unless explicitly disabled)
    -- Length = message length + 2 additional "=" characters
    if show_separator ~= false then
        MessageCore.show_separator((message_length or 0) + 2)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return AbilityMessageHandler

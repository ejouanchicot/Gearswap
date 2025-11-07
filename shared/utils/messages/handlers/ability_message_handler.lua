---============================================================================
--- Universal Ability Message Handler - Multi-Database Ability Message System
---============================================================================
--- Automatically detects and displays ability messages for ANY job/subjob combo.
--- Works by checking ALL ability databases until ability is found.
---
--- Features:
---   - Works for main job AND subjob abilities
---   - Auto-detects ability database (job-based)
---   - Zero job-specific code needed
---   - Respects ABILITY_MESSAGES_CONFIG
---
--- Architecture:
---   - Loads all 21 job ability databases
---   - Searches mainjob + subjob + SP abilities
---   - Falls back gracefully if not found
---
--- Examples:
---   - WAR/RUN using Ignis → Shows message from RUN database
---   - DNC/WAR using Provoke → Shows message from WAR database
---   - PLD using Sentinel → Shows message from PLD database
---
--- @file ability_message_handler.lua
--- @author Tetsouo
--- @version 1.0 - Initial Release
--- @date Created: 2025-11-01
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
--- JOB-BASED DATABASES (Load All 21 Jobs)
---============================================================================

local JOB_DATABASES = {}

-- List of all jobs with ability databases
local JOBS = {
    'BLM', 'BLU', 'BRD', 'BST', 'COR', 'DNC', 'DRG', 'DRK',
    'GEO', 'MNK', 'NIN', 'PLD', 'PUP', 'RDM', 'RNG', 'RUN',
    'SAM', 'SCH', 'THF', 'WAR', 'WHM'
}

-- Load each job database (safe loading)
for _, job_code in ipairs(JOBS) do
    local success, db = pcall(require, 'shared/data/job_abilities/' .. job_code .. '_JA_DATABASE')
    if success and db then
        JOB_DATABASES[job_code] = db
    end
end

-- Load message config
local ABILITY_MESSAGES_CONFIG = {
    display_mode = 'on',  -- 'on', 'full', 'off'
    enabled = true
}

-- Try to load config if exists
local config_success, config = pcall(require, 'shared/config/ABILITY_MESSAGES_CONFIG')
if config_success and config then
    ABILITY_MESSAGES_CONFIG = config
end

---============================================================================
--- ABILITY LOOKUP
---============================================================================

--- Search for ability in all loaded databases
--- @param ability_name string Ability name
--- @return table|nil ability_data Ability data if found
--- @return string|nil database_name Name of database where ability was found
local function find_ability_in_databases(ability_name)
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
    if type(ABILITY_MESSAGES_CONFIG.enabled) == 'function' then
        return ABILITY_MESSAGES_CONFIG.enabled()
    end
    return ABILITY_MESSAGES_CONFIG.enabled
end

--- Check if full description should be shown
--- @return boolean True if full description mode
local function show_full_description()
    return ABILITY_MESSAGES_CONFIG.display_mode == 'full'
end

--- Show ability message if config enabled
--- @param spell table Spell/Ability object from GearSwap
--- @param show_separator boolean Optional - show separator after message (default: true)
function AbilityMessageHandler.show_message(spell, show_separator)
    -- Only handle abilities (not spells, weaponskills, items)
    if not spell or spell.action_type ~= 'Ability' then
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

    -- Prepare description
    local description = ability_data.description

    -- Prepare notes (only if mode is 'full')
    local notes = nil
    if show_full_description() and ability_data.notes then
        notes = ability_data.notes
    elseif show_full_description() then
        -- Auto-generate notes from data
        local note_parts = {}

        if ability_data.recast then
            table.insert(note_parts, string.format("Recast: %ds", ability_data.recast))
        end

        if ability_data.level then
            table.insert(note_parts, string.format("Level: %d", ability_data.level))
        end

        if ability_data.main_job_only then
            table.insert(note_parts, "Main job only")
        end

        if #note_parts > 0 then
            notes = table.concat(note_parts, ". ") .. "."
        end
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

    -- Display message using JA format (not spell format!) and get message length
    local message_length
    if notes then
        -- Full mode: description + notes
        message_length = MessageFormatter.show_ja_activated(spell.name, description)
        add_to_chat(002, notes)
    else
        -- Normal mode: description only
        message_length = MessageFormatter.show_ja_activated(spell.name, description)
    end

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

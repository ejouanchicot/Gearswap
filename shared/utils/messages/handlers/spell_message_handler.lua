---============================================================================
--- Universal Spell Message Handler - Multi-Database Spell Message System
---============================================================================
--- Automatically detects and displays spell messages for ANY job/subjob combo.
--- Works by checking ALL spell databases until spell is found.
---
--- Features:
---   - Works for main job AND subjob spells
---   - Auto-detects spell database (skill-based or job-based)
---   - Respects ENFEEBLING_MESSAGES_CONFIG
---   - Respects ENHANCING_MESSAGES_CONFIG
---   - Zero job-specific code needed
---   - LAZY LOADING: Databases load on first spell cast (eliminates startup lag)
---
--- Architecture:
---   - PRIORITY 1: Skill-based databases (6 total: ENFEEBLING, ENHANCING, DARK, HEALING, ELEMENTAL, DIVINE)
---   - PRIORITY 2: Job-based databases (BLM_SPELL_DATABASE, RDM_SPELL_DATABASE, etc.)
---
--- Performance:
---   - Databases load on-demand when first spell is cast (not at require time)
---   - Eliminates 100-300ms startup lag from eager loading
---   - Once loaded, databases remain cached for instant access
---
--- Examples:
---   - WAR/RDM casting Haste → Shows message from ENHANCING_MAGIC_DATABASE
---   - DNC/WHM casting Cure III → Shows message from HEALING_MAGIC_DATABASE
---   - BLM casting Bio → Shows message from ENFEEBLING_MAGIC_DATABASE
---   - GEO casting Aspir → Shows message from DARK_MAGIC_DATABASE
---   - BLM casting Fire III → Shows message from ELEMENTAL_MAGIC_DATABASE
---   - WHM casting Banish → Shows message from DIVINE_MAGIC_DATABASE
---
--- @file spell_message_handler.lua
--- @author Tetsouo
--- @version 2.3 - Lazy Loading (performance optimization)
--- @date Created: 2025-10-30 | Updated: 2025-11-04
---============================================================================

local SpellMessageHandler = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCore = require('shared/utils/messages/message_core')

---============================================================================
--- SKILL-BASED DATABASES (Priority 1 - LAZY LOADING)
---============================================================================

local EnfeeblingSPELLS = nil
local EnhancingSPELLS = nil
local DarkSPELLS = nil
local HealingSPELLS = nil
local ElementalSPELLS = nil
local DivineSPELLS = nil

-- LAZY LOADING: Databases load on first access, not at require time
-- This eliminates 100-300ms startup lag from loading ALL spell databases
local function ensure_skill_databases_loaded()
    if not EnfeeblingSPELLS then
        local success, db = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
        if success then EnfeeblingSPELLS = db end
    end

    if not EnhancingSPELLS then
        local success, db = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
        if success then EnhancingSPELLS = db end
    end

    if not DarkSPELLS then
        local success, db = pcall(require, 'shared/data/magic/DARK_MAGIC_DATABASE')
        if success then DarkSPELLS = db end
    end

    if not HealingSPELLS then
        local success, db = pcall(require, 'shared/data/magic/HEALING_MAGIC_DATABASE')
        if success then HealingSPELLS = db end
    end

    if not ElementalSPELLS then
        local success, db = pcall(require, 'shared/data/magic/ELEMENTAL_MAGIC_DATABASE')
        if success then ElementalSPELLS = db end
    end

    if not DivineSPELLS then
        local success, db = pcall(require, 'shared/data/magic/DIVINE_MAGIC_DATABASE')
        if success then DivineSPELLS = db end
    end
end

---============================================================================
--- JOB-BASED DATABASES (Priority 2 - LAZY LOADING)
---============================================================================

local BLMSpells = nil
local RDMSpells = nil
local WHMSpells = nil
local GEOSpells = nil
local BRDSpells = nil
local SCHSpells = nil
local BLUSpells = nil
local SMNSpells = nil

-- LAZY LOADING: Job databases load on first access, not at require time
local function ensure_job_databases_loaded()
    if not BLMSpells then
        local success, db = pcall(require, 'shared/data/magic/BLM_SPELL_DATABASE')
        if success then BLMSpells = db end
    end

    if not RDMSpells then
        local success, db = pcall(require, 'shared/data/magic/RDM_SPELL_DATABASE')
        if success then RDMSpells = db end
    end

    if not WHMSpells then
        local success, db = pcall(require, 'shared/data/magic/WHM_SPELL_DATABASE')
        if success then WHMSpells = db end
    end

    if not GEOSpells then
        local success, db = pcall(require, 'shared/data/magic/GEO_SPELL_DATABASE')
        if success then GEOSpells = db end
    end

    if not BRDSpells then
        local success, db = pcall(require, 'shared/data/magic/BRD_SPELL_DATABASE')
        if success then BRDSpells = db end
    end

    if not SCHSpells then
        local success, db = pcall(require, 'shared/data/magic/SCH_SPELL_DATABASE')
        if success then SCHSpells = db end
    end

    if not BLUSpells then
        local success, db = pcall(require, 'shared/data/magic/BLU_SPELL_DATABASE')
        if success then BLUSpells = db end
    end

    if not SMNSpells then
        local success, db = pcall(require, 'shared/data/magic/SMN_SPELL_DATABASE')
        if success then SMNSpells = db end
    end
end

-- Load message configs
local _, ENFEEBLING_MESSAGES_CONFIG = pcall(require, 'shared/config/ENFEEBLING_MESSAGES_CONFIG')
if not ENFEEBLING_MESSAGES_CONFIG then
    ENFEEBLING_MESSAGES_CONFIG = {
        display_mode = 'on',
        is_enabled = function() return true end,
        show_description = function() return false end
    }
end

local _, ENHANCING_MESSAGES_CONFIG = pcall(require, 'shared/config/ENHANCING_MESSAGES_CONFIG')
if not ENHANCING_MESSAGES_CONFIG then
    ENHANCING_MESSAGES_CONFIG = {
        display_mode = 'on',
        is_enabled = function() return true end,
        show_description = function() return false end
    }
end

---============================================================================
--- SPELL LOOKUP
---============================================================================

--- Search for spell in all loaded databases
--- PRIORITY 1: Skill-based databases (ENFEEBLING_MAGIC_DATABASE, etc.)
--- PRIORITY 2: Job-based databases (BLM_SPELL_DATABASE, etc.)
--- @param spell_name string Spell name
--- @return table|nil spell_data Spell data if found
--- @return string|nil database_name Name of database where spell was found
local function find_spell_in_databases(spell_name)
    -- LAZY LOAD: Ensure databases are loaded before searching
    ensure_skill_databases_loaded()
    ensure_job_databases_loaded()

    -- PRIORITY 1: Check skill-based databases FIRST
    local skill_databases = {
        {name = 'Enfeebling Magic', db = EnfeeblingSPELLS},
        {name = 'Enhancing Magic', db = EnhancingSPELLS},
        {name = 'Dark Magic', db = DarkSPELLS},
        {name = 'Healing Magic', db = HealingSPELLS},
        {name = 'Elemental Magic', db = ElementalSPELLS},
        {name = 'Divine Magic', db = DivineSPELLS},
    }

    for _, db_entry in ipairs(skill_databases) do
        if db_entry.db and db_entry.db.spells then
            local spell_data = db_entry.db.spells[spell_name]
            if spell_data then
                return spell_data, db_entry.name
            end
        end
    end

    -- PRIORITY 2: Fallback to job-based databases (legacy support)
    local job_databases = {
        {name = 'RDM', db = RDMSpells},
        {name = 'WHM', db = WHMSpells},
        {name = 'BLM', db = BLMSpells},
        {name = 'GEO', db = GEOSpells},
        {name = 'BRD', db = BRDSpells},
        {name = 'SCH', db = SCHSpells},
        {name = 'BLU', db = BLUSpells},
        {name = 'SMN', db = SMNSpells},
    }

    for _, db_entry in ipairs(job_databases) do
        if db_entry.db and db_entry.db.spells then
            local spell_data = db_entry.db.spells[spell_name]
            if spell_data then
                return spell_data, db_entry.name
            end
        end
    end

    return nil, nil
end

---============================================================================
--- MESSAGE DISPLAY
---============================================================================

--- Show spell message if config enabled
--- @param spell table Spell object from GearSwap
--- @param show_separator boolean Optional - show separator after message (default: true)
function SpellMessageHandler.show_message(spell, show_separator)
    -- Handle magic spells and Blood Pacts (SMN abilities treated as spells)
    if not spell then
        return
    end

    -- Accept Magic, BloodPactRage, and BloodPactWard action types
    local valid_action_types = {
        ['Magic'] = true,
        ['BloodPactRage'] = true,
        ['BloodPactWard'] = true
    }

    if not valid_action_types[spell.action_type] then
        return
    end

    -- Skip Geomancy spells (handled manually in GEO_MIDCAST)
    if spell.skill == 'Geomancy' then
        return
    end

    -- Skip BRD songs (handled manually in BRD_MIDCAST)
    if spell.skill == 'Singing' then
        return
    end

    -- Find spell in databases FIRST (before checking spell.skill)
    -- This is critical because some spells have mismatched skill vs category
    -- Example: Bio has spell.skill = "Dark Magic" but category = "Enfeebling"
    local spell_data, db_name = find_spell_in_databases(spell.name)

    if not spell_data then
        -- Spell not found in any database
        return
    end

    -- Determine config based on spell CATEGORY (not spell.skill!)
    -- This allows Dark Magic spells with Enfeebling effects to show correctly
    local config = nil
    local category = spell_data.category

    -- Strategy: Only Enfeebling uses ENFEEBLING_MESSAGES_CONFIG
    -- All other categories use ENHANCING_MESSAGES_CONFIG by default
    -- This automatically covers: Enhancing, Healing, Divine, Dark, Elemental, Helix,
    -- Blue Magic (Buff/Physical/Magical/Breath/Debuff), Summoning (Avatar/Spirit/BP),
    -- BRD songs (26+ categories), GEO (Geocolure/Indicolure), and any future categories

    if category == 'Enfeebling' then
        config = ENFEEBLING_MESSAGES_CONFIG
    else
        -- Default: Use ENHANCING_MESSAGES_CONFIG for all other spell types
        -- This includes: Enhancing, Healing, Divine, Dark, Elemental, Helix,
        -- Blue Magic, Summoning, BRD songs, GEO spells, etc.
        config = ENHANCING_MESSAGES_CONFIG
    end

    -- Check if messages are enabled
    if not config or not config.is_enabled() then
        return
    end

    -- Prepare description (only if mode is 'full')
    local description = nil
    if config.show_description() then
        description = spell_data.description
    end

    -- Get target name (for buffs)
    local target_name = nil
    if spell.target and spell.target.name then
        target_name = spell.target.name
    end

    -- Use spell.english instead of spell.name (GearSwap convention)
    local spell_name = spell.english or spell.name or "Unknown"

    -- Display message with target and get message length
    local message_length = MessageFormatter.show_spell_activated(spell_name, description, target_name)

    -- Display separator after spell message (default: true unless explicitly disabled)
    -- Length = message length + 2 additional "=" characters
    if show_separator ~= false then
        MessageCore.show_separator(message_length + 2)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SpellMessageHandler

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
---
--- Architecture:
---   - PRIORITY 1: Skill-based databases (ENFEEBLING_MAGIC_DATABASE, etc.)
---   - PRIORITY 2: Job-based databases (BLM_SPELL_DATABASE, RDM_SPELL_DATABASE, etc.)
---
--- Examples:
---   - WAR/RDM casting Haste → Shows message from RDM database
---   - DNC/WHM casting Cure III → Shows message from WHM database
---   - BLM casting Bio → Shows message from ENFEEBLING_MAGIC_DATABASE
---
--- @file spell_message_handler.lua
--- @author Tetsouo
--- @version 2.0 - Skill-Based Database Migration
--- @date Created: 2025-10-30 | Updated: 2025-10-30
---============================================================================

local SpellMessageHandler = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- SKILL-BASED DATABASES (Priority 1 - NEW ARCHITECTURE)
---============================================================================

local EnfeeblingSPELLS = nil
local EnhancingSPELLS = nil

-- Try to load skill-based databases (safe loading)
local enfeebling_success, enfeebling_db = pcall(require, 'shared/data/magic/ENFEEBLING_MAGIC_DATABASE')
if enfeebling_success then EnfeeblingSPELLS = enfeebling_db end

local enhancing_success, enhancing_db = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')
if enhancing_success then EnhancingSPELLS = enhancing_db end

---============================================================================
--- JOB-BASED DATABASES (Priority 2 - Legacy Support)
---============================================================================

local BLMSpells = nil
local RDMSpells = nil
local WHMSpells = nil
local GEOSpells = nil
local BRDSpells = nil
local SCHSpells = nil
local BLUSpells = nil
local SMNSpells = nil

-- Try to load each job database (safe loading)
local blm_success, blm_db = pcall(require, 'shared/data/magic/BLM_SPELL_DATABASE')
if blm_success then BLMSpells = blm_db end

local rdm_success, rdm_db = pcall(require, 'shared/data/magic/RDM_SPELL_DATABASE')
if rdm_success then RDMSpells = rdm_db end

local whm_success, whm_db = pcall(require, 'shared/data/magic/WHM_SPELL_DATABASE')
if whm_success then WHMSpells = whm_db end

local geo_success, geo_db = pcall(require, 'shared/data/magic/GEO_SPELL_DATABASE')
if geo_success then GEOSpells = geo_db end

local brd_success, brd_db = pcall(require, 'shared/data/magic/BRD_SPELL_DATABASE')
if brd_success then BRDSpells = brd_db end

local sch_success, sch_db = pcall(require, 'shared/data/magic/SCH_SPELL_DATABASE')
if sch_success then SCHSpells = sch_db end

local blu_success, blu_db = pcall(require, 'shared/data/magic/BLU_SPELL_DATABASE')
if blu_success then BLUSpells = blu_db end

local smn_success, smn_db = pcall(require, 'shared/data/magic/SMN_SPELL_DATABASE')
if smn_success then SMNSpells = smn_db end

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
    -- PRIORITY 1: Check skill-based databases FIRST
    local skill_databases = {
        {name = 'Enfeebling Magic', db = EnfeeblingSPELLS},
        {name = 'Enhancing Magic', db = EnhancingSPELLS},
        -- Add more skill databases here as they are created:
        -- {name = 'Healing Magic', db = HealingSPELLS},
        -- etc.
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
function SpellMessageHandler.show_message(spell)
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

    if category == 'Enfeebling' then
        config = ENFEEBLING_MESSAGES_CONFIG
    elseif category == 'Enhancing' or category == 'Healing' or category == 'Divine' then
        config = ENHANCING_MESSAGES_CONFIG
    elseif category == 'Buff' or category == 'Physical' or category == 'Magical' or category == 'Breath' or category == 'Debuff' then
        -- Blue Magic categories - use ENHANCING config (shows messages)
        config = ENHANCING_MESSAGES_CONFIG
    elseif category == 'Avatar Summon' or category == 'Spirit Summon' or category == 'Blood Pact: Rage' or category == 'Blood Pact: Ward' then
        -- Summoning categories - use ENHANCING config (shows messages)
        config = ENHANCING_MESSAGES_CONFIG
    else
        -- Other categories not handled yet (Elemental, etc.)
        return
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

    -- Display message with target
    MessageFormatter.show_spell_activated(spell.name, description, target_name)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SpellMessageHandler

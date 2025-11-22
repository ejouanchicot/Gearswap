---  ═══════════════════════════════════════════════════════════════════════════
---   Job Abilities Precast Helper - Auto-Display JA Descriptions
---  ═══════════════════════════════════════════════════════════════════════════
---   Automatically displays job ability descriptions during precast based on
---   database lookups and configuration settings.
---
---   Features:
---     • Auto-detects when a JA is used and displays description
---     • Respects JA_MESSAGES_CONFIG (full/on/off)
---     • Works for ALL jobs automatically
---     • No manual description mapping needed
---
---   Integration:
---     Add to job_precast or job_post_precast:
---
---     local JAPrecastHelper = require('shared/utils/job_abilities/ja_precast_helper')
---
---     function job_precast(spell, action, spellMap, eventArgs)
---         -- Display JA description if applicable
---         JAPrecastHelper.handle_ja_precast(spell)
---
---         -- Your existing precast logic...
---     end
---
---   @file    shared/utils/job_abilities/ja_precast_helper.lua
---   @author  Tetsouo
---   @version 1.1 - DRY refactor: Extract validate_ja_spell() helper (-10 lines)
---   @date    Created: 2025-10-31 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local JAPrecastHelper = {}

-- Load dependencies
local JAManager = require('shared/utils/job_abilities/job_abilities_manager')

-- Load configuration
local ja_config_success, JAConfig = pcall(require, 'shared/config/JA_MESSAGES_CONFIG')
if not ja_config_success then
    JAConfig = {
        is_enabled = function() return true end,
        show_description = function() return true end
    }
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Validate and extract ability name from spell
--- @param spell table Spell/ability data
--- @return string|nil Ability name or nil if invalid
local function validate_ja_spell(spell)
    -- Only process Job Abilities
    if not spell or spell.type ~= 'JobAbility' then
        return nil
    end

    -- Get ability name (try multiple fields)
    return spell.name or spell.english or spell.en
end

---  ═══════════════════════════════════════════════════════════════════════════
---   JA PRECAST HANDLING
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle job ability precast - display description if enabled
--- @param spell table Spell/ability data from GearSwap
function JAPrecastHelper.handle_ja_precast(spell)
    local ability_name = validate_ja_spell(spell)
    if not ability_name then
        return
    end

    -- Check if messages are enabled
    if not JAConfig.is_enabled() then
        return  -- Silent mode
    end

    -- Check if descriptions should be shown
    if not JAConfig.show_description() then
        return  -- Name-only mode or disabled
    end

    -- Get description from database
    local description = JAManager.get_description(ability_name)

    -- Display activation message with description
    if description then
        JAManager.show_ability_activation(ability_name, description)
    end
end

--- Alternative: Show description only (colon format)
--- Format: [JOB] Ability: Description
--- @param spell table Spell/ability data from GearSwap
function JAPrecastHelper.show_ja_description(spell)
    local ability_name = validate_ja_spell(spell)
    if not ability_name then
        return
    end

    local description = JAManager.get_description(ability_name)
    if description then
        JAManager.show_ability_description(ability_name, description)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENMITY DISPLAY (OPTIONAL)
---  ═══════════════════════════════════════════════════════════════════════════

--- Display enmity values for an ability (optional feature)
--- Format: [JOB] Ability: CE+X, VE+Y
--- @param spell table Spell/ability data from GearSwap
function JAPrecastHelper.show_ja_enmity(spell)
    local ability_name = validate_ja_spell(spell)
    if not ability_name then
        return
    end

    local ce, ve = JAManager.get_enmity(ability_name)
    if ce > 0 or ve > 0 then
        local enmity_text = string.format("CE+%d, VE+%d", ce, ve)
        JAManager.show_ability_description(ability_name, enmity_text)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return JAPrecastHelper

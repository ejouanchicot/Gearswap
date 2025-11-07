---============================================================================
--- JA Buffs Message Formatter - Job Ability Activation (NEW SYSTEM)
---============================================================================
--- Universal job ability activation/deactivation messages for ALL jobs.
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- Usage Examples:
---   JABuffs.show_activated("Soul Voice", "Song power boost!")          -- [BRD/WHM] Soul Voice Song power boost!
---   JABuffs.show_activated("Berserk", "Attack boost!")                 -- [WAR/SAM] Berserk Attack boost!
---   JABuffs.show_activated("Last Resort", "Attack boost, Defense down") -- [DRK/SAM] Last Resort Attack boost, Defense down
---   JABuffs.show_active("Nightingale")                                 -- [BRD/WHM] Nightingale active
---   JABuffs.show_ended("Soul Voice")                                   -- [BRD/WHM] Soul Voice ended
---   JABuffs.show_with_description("Troubadour", "Song duration extended") -- [BRD/WHM] Troubadour: Song duration extended
---
--- @file    messages/message_ja_buffs.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local JABuffs = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')

-- Load JA messages configuration
local ja_config_success, JAConfig = pcall(require, 'shared/config/JA_MESSAGES_CONFIG')
if not ja_config_success then
    -- Fallback: If config not found, default to 'full' mode
    JAConfig = {
        display_mode = 'full',
        is_enabled = function() return true end,
        show_description = function() return true end,
        is_name_only = function() return false end
    }
end

---============================================================================
--- PATTERN 1: JA ACTIVATED WITH DESCRIPTION
---============================================================================

--- Display job ability activation with description
--- Format: [JOB] Ability Description
--- Example: [BRD/WHM] Soul Voice Song power boost!
---
--- Respects JA_MESSAGES_CONFIG display_mode:
---   • 'full'       - Show name + description
---   • 'name_only'  - Show only name
---   • 'disabled'   - Show nothing
---
--- @param ability_name string Name of the job ability
--- @param description string Description of the effect (optional)
function JABuffs.show_activated(ability_name, description)
    -- Check if messages are disabled
    if not JAConfig.is_enabled() then
        return 0  -- Silent mode
    end

    local job_tag = MessageCore.get_job_tag()
    local success, message_length

    -- Check if we should show description
    if description and JAConfig.show_description() then
        -- Mode: 'full' - Show name + description (without "activated!")
        success, message_length = M.send('JA_BUFFS', 'activated_full', {
            job_tag = job_tag,
            ability_name = ability_name,
            description = description
        })
    else
        -- Mode: 'name_only' - Show only name (without "activated!")
        success, message_length = M.send('JA_BUFFS', 'activated_name_only', {
            job_tag = job_tag,
            ability_name = ability_name
        })
    end

    return message_length or 0
end

---============================================================================
--- PATTERN 2: JA ACTIVE (STATUS CHECK)
---============================================================================

--- Display job ability active status
--- Format: [JOB] Ability active
--- Example: [BRD/WHM] Nightingale active
---
--- @param ability_name string Name of the job ability
function JABuffs.show_active(ability_name)
    local job_tag = MessageCore.get_job_tag()

    M.send('JA_BUFFS', 'active', {
        job_tag = job_tag,
        ability_name = ability_name
    })
end

---============================================================================
--- PATTERN 3: JA ENDED (BUFF WORE OFF)
---============================================================================

--- Display job ability ended
--- Format: [JOB] Ability ended
--- Example: [BRD/WHM] Soul Voice ended
---
--- @param ability_name string Name of the job ability
function JABuffs.show_ended(ability_name)
    local job_tag = MessageCore.get_job_tag()

    M.send('JA_BUFFS', 'ended', {
        job_tag = job_tag,
        ability_name = ability_name
    })
end

---============================================================================
--- PATTERN 4: JA WITH DESCRIPTION (COLON FORMAT)
---============================================================================

--- Display job ability with description (colon format)
--- Format: [JOB] Ability: Description
--- Example: [BRD/WHM] Nightingale: Casting Time reduced
---
--- @param ability_name string Name of the job ability
--- @param description string Description of the effect
function JABuffs.show_with_description(ability_name, description)
    local job_tag = MessageCore.get_job_tag()

    M.send('JA_BUFFS', 'with_description', {
        job_tag = job_tag,
        ability_name = ability_name,
        description = description
    })
end

---============================================================================
--- PATTERN 5: JA USING (PRE-ACTION)
---============================================================================

--- Display job ability being used (pre-action notification)
--- Format: [JOB] Using Ability
--- Example: [BRD/WHM] Using Marcato
---
--- @param ability_name string Name of the job ability
function JABuffs.show_using(ability_name)
    local job_tag = MessageCore.get_job_tag()

    M.send('JA_BUFFS', 'using', {
        job_tag = job_tag,
        ability_name = ability_name
    })
end

---============================================================================
--- PATTERN 6: JA USING DOUBLE (TWO ABILITIES)
---============================================================================

--- Display two job abilities being used together
--- Format: [JOB] Using Ability1 + Ability2
--- Example: [BRD/WHM] Using Nightingale + Troubadour
--- Colors: JA names in YELLOW, + in GRAY
---
--- @param ability1 string First ability name
--- @param ability2 string Second ability name
function JABuffs.show_using_double(ability1, ability2)
    local job_tag = MessageCore.get_job_tag()

    M.send('JA_BUFFS', 'using_double', {
        job_tag = job_tag,
        ability1 = ability1,
        ability2 = ability2
    })
end

---============================================================================
--- BACKWARD COMPATIBILITY WRAPPERS (BRD-specific)
---============================================================================
--- These functions maintain backward compatibility with existing BRD code
--- while using the new global system. Can be deprecated after full migration.

function JABuffs.show_soul_voice_activated()
    JABuffs.show_activated("Soul Voice", "Song power boost!")
end

function JABuffs.show_soul_voice_ended()
    JABuffs.show_ended("Soul Voice")
end

function JABuffs.show_nightingale_activated()
    JABuffs.show_with_description("Nightingale", "Casting Time reduced")
end

function JABuffs.show_nightingale_active()
    JABuffs.show_active("Nightingale")
end

function JABuffs.show_troubadour_activated()
    JABuffs.show_with_description("Troubadour", "Song duration extended")
end

function JABuffs.show_troubadour_active()
    JABuffs.show_active("Troubadour")
end

function JABuffs.show_marcato_used()
    JABuffs.show_using("Marcato")
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return JABuffs

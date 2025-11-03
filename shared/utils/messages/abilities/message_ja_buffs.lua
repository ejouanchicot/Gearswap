---============================================================================
--- Job Abilities Buff Messages - Global Module
---============================================================================
--- Universal job ability activation/deactivation messages for ALL jobs.
--- Replaces job-specific implementations (BRD, WAR, DRK, etc.) with unified system.
---
--- Usage Examples:
---   JABuffs.show_activated("Soul Voice", "Song power boost!")          -- [BRD/WHM] Soul Voice Song power boost!
---   JABuffs.show_activated("Berserk", "Attack boost!")                 -- [WAR/SAM] Berserk Attack boost!
---   JABuffs.show_activated("Last Resort", "Attack boost, Defense down") -- [DRK/SAM] Last Resort Attack boost, Defense down
---   JABuffs.show_active("Nightingale")                                 -- [BRD/WHM] Nightingale active
---   JABuffs.show_ended("Soul Voice")                                   -- [BRD/WHM] Soul Voice ended
---   JABuffs.show_with_description("Troubadour", "Song duration extended") -- [BRD/WHM] Troubadour: Song duration extended
---
--- @file utils/messages/abilities/message_ja_buffs.lua
--- @author Tetsouo
--- @version 1.0 - Global Refactor
--- @date Created: 2025-10-29
---============================================================================

local JABuffs = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

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
        return  -- Silent mode
    end

    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message

    -- Check if we should show description
    if description and JAConfig.show_description() then
        -- Mode: 'full' - Show name + description (without "activated!")
        formatted_message = string.format(
            "%s[%s] %s%s %s%s",
            job_color, job_tag,
            ability_color, ability_name,
            action_color, description
        )
    else
        -- Mode: 'name_only' - Show only name (without "activated!")
        formatted_message = string.format(
            "%s[%s] %s%s",
            job_color, job_tag,
            ability_color, ability_name
        )
    end

    add_to_chat(001, formatted_message)
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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)

    local formatted_message = string.format(
        "%s[%s] %s%s%s active",
        job_color, job_tag,
        ability_color, ability_name,
        success_color
    )

    add_to_chat(001, formatted_message)
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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s ended",
        job_color, job_tag,
        ability_color, ability_name,
        action_color
    )

    add_to_chat(001, formatted_message)
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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s: %s%s",
        job_color, job_tag,
        ability_color, ability_name,
        action_color,
        action_color, description  -- FIXED: Description en GRIS (SEPARATOR) au lieu de vert (SUCCESS)
    )

    add_to_chat(001, formatted_message)
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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Using %s%s",
        job_color, job_tag,
        action_color,
        ability_color, ability_name
    )

    add_to_chat(001, formatted_message)
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
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Using %s%s%s + %s%s",
        job_color, job_tag,
        action_color,
        ability_color, ability1,
        action_color,  -- "+" en gris
        ability_color, ability2
    )

    add_to_chat(001, formatted_message)
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

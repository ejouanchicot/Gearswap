---============================================================================
--- GEO Messages Module - Geomancer Spell and Luopan Message Formatting
---============================================================================
--- Provides formatted messages for Geomancer job system following Tetsouo standard.
--- Uses multi-color inline formatting for professional display.
---
--- @file utils/messages/message_geo.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-16
---============================================================================

local GEOMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

---============================================================================
--- INDI/GEO SPELL CASTING MESSAGES
---============================================================================

--- Display Indi spell cast message
--- Format: [GEO/WHM] Casting: Indi-Haste
--- @param spell_name string Full spell name (e.g., "Indi-Haste")
function GEOMessages.show_indi_cast(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)

    local formatted_message = string.format(
        "%s[%s]%s Casting: %s%s",
        job_color, job_tag,
        separator_color,
        spell_color, spell_name
    )

    add_to_chat(001, formatted_message)
end

--- Display Geo spell cast message
--- Format: [GEO/WHM] Casting: Geo-Refresh
--- @param spell_name string Full spell name (e.g., "Geo-Refresh")
function GEOMessages.show_geo_cast(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)

    local formatted_message = string.format(
        "%s[%s]%s Casting: %s%s",
        job_color, job_tag,
        separator_color,
        spell_color, spell_name
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- SPELL REFINEMENT MESSAGES
---============================================================================

--- Display spell refinement message (tier downgrade)
--- @param desired_spell string Original spell name requested
--- @param final_spell string Final spell name after refinement
function GEOMessages.show_spell_refined(desired_spell, final_spell)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local separator_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)

    local formatted_message = string.format(
        "%s[%s]%s Refined: %s%s%s -> %s%s",
        job_color, job_tag,
        separator_color,
        spell_color, desired_spell,
        separator_color,
        spell_color, final_spell
    )

    add_to_chat(001, formatted_message)
end

--- Display no tier available error
--- @param desired_spell string Spell name that was requested
function GEOMessages.show_no_tier_available(desired_spell)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)

    local formatted_message = string.format(
        "%s[%s] %sNo available tier for: %s%s",
        job_color, job_tag,
        error_color,
        spell_color, desired_spell
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return GEOMessages

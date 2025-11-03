---============================================================================
--- RDM Messages Module - Red Mage Job Ability and Spell Message Formatting
---============================================================================
--- Provides formatted messages for Red Mage job system following Tetsouo standard.
--- Uses multi-color inline formatting for professional display.
---
--- @file utils/messages/message_rdm.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-16
---============================================================================

local RDMMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

---============================================================================
--- JOB ABILITY MESSAGES - MIGRATED TO GLOBAL SYSTEM
---============================================================================
--- All RDM Job Ability messages (Convert, Chainspell, Composure, Saboteur,
--- Spontaneity, Stymie) have been migrated to the global JABuffs system.
--- See: shared/jobs/rdm/functions/RDM_PRECAST.lua and RDM_BUFFS.lua
---============================================================================

---============================================================================
--- DEBUFF WARNING MESSAGES
---============================================================================

--- Display DOOM warning message
function RDMMessages.show_doom_warning()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sDOOM! Use Cursna or Holy Water!",
        job_color, job_tag,
        action_color,
        error_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Doom removed message
function RDMMessages.show_doom_removed()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sDoom removed",
        job_color, job_tag,
        action_color,
        success_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- SPELL CASTING MESSAGES
---============================================================================

--- Display spell casting message
--- @param spell_name string Name of the spell being cast
function RDMMessages.show_spell_casting(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting: %s%s",
        job_color, job_tag,
        action_color,
        spell_color, spell_name
    )

    add_to_chat(001, formatted_message)
end

--- Display element list help message
function RDMMessages.show_element_list()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local info_color = MessageCore.create_color_code(Colors.COOLDOWN)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sValid elements: fire, ice, wind, earth, thunder, water",
        job_color, job_tag,
        action_color,
        info_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- STATE DISPLAY MESSAGES
---============================================================================

--- Display current Enspell state
--- @param enspell_value string Current enspell value
function RDMMessages.show_enspell_current(enspell_value)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Enspell: %s%s",
        job_color, job_tag,
        action_color,
        spell_color, enspell_value
    )

    add_to_chat(001, formatted_message)
end

--- Display current Storm state
--- @param storm_value string Current storm value
function RDMMessages.show_storm_current(storm_value)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Storm: %s%s",
        job_color, job_tag,
        action_color,
        spell_color, storm_value
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- ERROR MESSAGES
---============================================================================

--- Display no Enspell selected error
function RDMMessages.show_no_enspell_selected()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sNo Enspell selected (cycle with Alt+8)",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Gain spell not configured error
function RDMMessages.show_gain_spell_not_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sGain spell state not configured",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Bar Element not configured error
function RDMMessages.show_bar_element_not_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sBar Element state not configured",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Bar Ailment not configured error
function RDMMessages.show_bar_ailment_not_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sBar Ailment state not configured",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Spike not configured error
function RDMMessages.show_spike_not_configured()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sSpike state not configured",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Storm requires SCH subjob error
function RDMMessages.show_storm_requires_sch()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sStorm spells require SCH subjob",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RDMMessages

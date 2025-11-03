---============================================================================
--- BLM Messages Module - Black Mage Element and Spell Message Formatting
---============================================================================
--- Provides formatted messages for Black Mage job system following Tetsouo standard.
--- Uses multi-color inline formatting for professional display with element-specific colors.
---
--- @file utils/messages/message_blm.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

local BLMMessages = {}

-- Load message core for formatting
local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS

---============================================================================
--- ELEMENT COLOR MAPPING
---============================================================================

--- Element-specific color codes for visual feedback
--- @type table<string, number>
local ELEMENT_COLORS = {
    -- Main Elements (Light)
    ['Fire'] = 167,      -- Red/Orange
    ['Thunder'] = 200,   -- Yellow
    ['Aero'] = 120,      -- Green/Cyan

    -- Main Elements (Dark)
    ['Stone'] = 36,      -- Brown
    ['Blizzard'] = 4,    -- Blue
    ['Water'] = 6,       -- Cyan

    -- Aja Spells
    ['Firaja'] = 167,
    ['Stoneja'] = 215,
    ['Blizzaja'] = 159,
    ['Aeroja'] = 120,
    ['Thundaja'] = 200,
    ['Waterja'] = 207,

    -- Storm Spells (FFXI standard colors)
    ['FireStorm'] = 003,     -- Fire Storm
    ['Sandstorm'] = 063,     -- Earth Storm
    ['Thunderstorm'] = 016,  -- Thunder Storm
    ['HailStorm'] = 013,     -- Ice Storm
    ['Rainstorm'] = 056,     -- Water Storm
    ['Windstorm'] = 014,     -- Wind Storm
    ['Voidstorm'] = 015,     -- Dark Storm
    ['Aurorastorm'] = 121,   -- Light Storm
}

---============================================================================
--- ELEMENT CYCLE MESSAGES
---============================================================================

--- Display element cycle message with colored element name
--- @param state_type string Type of state (e.g., 'MainLight', 'SubDark')
--- @param element_name string Name of the element
function BLMMessages.show_element_cycle(state_type, element_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    -- Get element-specific color or fallback to default
    local element_color_code = ELEMENT_COLORS[element_name] or Colors.SPELL
    local element_color = MessageCore.create_color_code(element_color_code)

    local formatted_message = string.format(
        "%s[%s]%s Current %s: %s%s",
        job_color, job_tag,
        action_color,
        state_type,
        element_color, element_name
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- SPELL CYCLE MESSAGES
---============================================================================

--- Display Aja spell cycle message
--- @param aja_name string Name of the Aja spell
function BLMMessages.show_aja_cycle(aja_name)
    BLMMessages.show_element_cycle('Aja', aja_name)
end

--- Display Storm spell cycle message
--- @param storm_name string Name of the Storm spell
function BLMMessages.show_storm_cycle(storm_name)
    BLMMessages.show_element_cycle('Storm', storm_name)
end

--- Display tier cycle message
--- @param tier_value string Tier value (6, 5, 4, 3, 2, or base)
function BLMMessages.show_tier_cycle(tier_value)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local tier_color = MessageCore.create_color_code(050) -- Yellow for tier
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Current Tier: %s%s",
        job_color, job_tag,
        action_color,
        tier_color, tier_value
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- BUFF MESSAGES
---============================================================================

--- Display self-buff activation message
function BLMMessages.show_buff_activated()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Self-buffing: %sStoneskin > Blink > Aquaveil > Ice Spikes",
        job_color, job_tag,
        action_color,
        success_color
    )

    add_to_chat(001, formatted_message)
end

--- Display individual buff cast message
--- @param buff_name string Name of the buff spell
function BLMMessages.show_buff_cast(buff_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s",
        job_color, job_tag,
        action_color,
        spell_color, buff_name
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- CASTING MODE MESSAGES
---============================================================================

--- Display Magic Burst mode activation
function BLMMessages.show_magic_burst_on()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local mode_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %sMagic Burst Mode%s: %sON",
        job_color, job_tag,
        mode_color, action_color,
        MessageCore.create_color_code(Colors.JA)
    )

    add_to_chat(001, formatted_message)
end

--- Display Magic Burst mode deactivation
function BLMMessages.show_magic_burst_off()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local mode_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %sMagic Burst Mode%s: %sOFF",
        job_color, job_tag,
        mode_color, action_color,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Free Nuke mode activation
function BLMMessages.show_free_nuke_on()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local mode_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %sFree Nuke Mode%s: %sON",
        job_color, job_tag,
        mode_color, action_color,
        MessageCore.create_color_code(Colors.JA)
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- SPELL REFINEMENT MESSAGES
---============================================================================

--- Display spell refinement (tier downgrade) message
--- @param original string Original spell name
--- @param downgrade string Downgraded spell name
--- @param recast_seconds number Recast time remaining
function BLMMessages.show_spell_refinement(original, downgrade, recast_seconds)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local time_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s on cooldown %s(%.1fs)%s > Downgrading to %s%s",
        job_color, job_tag,
        spell_color, original,
        action_color,
        time_color, recast_seconds,
        action_color,
        spell_color, downgrade
    )

    add_to_chat(001, formatted_message)
end

--- Display spell refinement failed (no downgrade available)
--- @param spell_name string Spell name
--- @param recast_seconds number Recast time remaining
function BLMMessages.show_spell_refinement_failed(spell_name, recast_seconds)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local time_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s on cooldown %s(%.1fs)%s - %sNo downgrade available",
        job_color, job_tag,
        spell_color, spell_name,
        action_color,
        time_color, recast_seconds,
        action_color,
        error_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- MP CONSERVATION MESSAGES
---============================================================================

--- Display MP conservation gear switch message
--- @param mp_status string 'Low' or 'High'
function BLMMessages.show_mp_conservation(mp_status)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local mp_color = mp_status == 'Low' and MessageCore.create_color_code(Colors.WARNING) or MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local gear_type = mp_status == 'Low' and 'Conservation' or 'Full Potency'

    local formatted_message = string.format(
        "%s[%s]%s MP %s%s%s > Using %s%s%s gear",
        job_color, job_tag,
        action_color,
        mp_color, mp_status,
        action_color,
        MessageCore.create_color_code(Colors.SPELL), gear_type,
        action_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- DARK ARTS MESSAGES (SCH SUBJOB)
---============================================================================

--- Display Dark Arts activation message
--- @param spell_name string Name of the spell being cast
function BLMMessages.show_dark_arts_activated(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s%s%s activated for %s%s",
        job_color, job_tag,
        ability_color, "Dark Arts",
        action_color,
        spell_color, spell_name
    )

    add_to_chat(001, formatted_message)
end

--- Display Arts already active message
--- @param arts_status string Status description (e.g., "Light Arts + Addendum: White")
function BLMMessages.show_arts_already_active(arts_status)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %s%s%s already active",
        job_color, job_tag,
        action_color,
        success_color, arts_status,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display Stratagem no charges available message
--- @param stratagem_name string Name of the stratagem (e.g., "Addendum: Black")
--- @param recast_minutes number Recast time in minutes
function BLMMessages.show_stratagem_no_charges(stratagem_name, recast_minutes)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %s%s%s - %sNo charges available%s (next charge: %s%.1fm%s)",
        job_color, job_tag,
        action_color,
        ability_color, stratagem_name,
        action_color,
        warning_color,
        action_color,
        warning_color, recast_minutes,
        action_color
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- ERROR MESSAGES
---============================================================================

--- Display error message for missing BuffSelf function
function BLMMessages.show_buffself_error()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Error: BuffSelf function not loaded"
    )

    add_to_chat(001, formatted_message)
end

--- Display error for invalid spell replacement parameters
function BLMMessages.show_spell_replacement_error()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Error: Invalid parameters for spell replacement"
    )

    add_to_chat(001, formatted_message)
end

--- Display error for invalid spell refinement parameters
function BLMMessages.show_spell_refinement_error()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Error: Invalid parameters for spell refinement"
    )

    add_to_chat(001, formatted_message)
end

--- Display error for failed spell recasts retrieval
function BLMMessages.show_spell_recasts_error()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Error: Failed to get spell recasts"
    )

    add_to_chat(001, formatted_message)
end

--- Display insufficient MP error
--- @param player_mp number Current player MP
function BLMMessages.show_insufficient_mp_error(player_mp)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Not enough Mana %s(%d MP)",
        job_color, job_tag,
        action_color,
        error_color, player_mp
    )

    add_to_chat(001, formatted_message)
end

--- Display Breakga replacement blocked message (lag protection)
function BLMMessages.show_breakga_blocked()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local warning_color = MessageCore.create_color_code(Colors.WARNING)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s %sBreakga replacement blocked (lag protection)",
        job_color, job_tag,
        action_color,
        warning_color
    )

    add_to_chat(001, formatted_message)
end

--- Display error for failed spell recasts in BuffSelf
function BLMMessages.show_buffself_recasts_error()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Error: Failed to get spell recasts for BuffSelf"
    )

    add_to_chat(001, formatted_message)
end

--- Display error for failed resources loading in BuffSelf
function BLMMessages.show_buffself_resources_error()
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local formatted_message = string.format(
        "%s[%s] %s%s",
        job_color, job_tag,
        error_color, "Error: Failed to load resources for BuffSelf"
    )

    add_to_chat(001, formatted_message)
end

--- Display buff casting message with delay
--- @param spell_name string Name of the buff spell
--- @param delay number Delay in seconds before casting
function BLMMessages.show_buff_casting(spell_name, delay)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local time_color = MessageCore.create_color_code(Colors.COOLDOWN)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s%s (delay: %s%ds%s)",
        job_color, job_tag,
        action_color,
        spell_color, spell_name,
        action_color,
        time_color, delay,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display buff status (active or recast)
--- @param status_string string Complete status string with all buffs
function BLMMessages.show_buff_status(status_string)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Buff Status: %s",
        job_color, job_tag,
        action_color,
        status_string
    )

    add_to_chat(001, formatted_message)
end

--- Display error for unknown buff spell
--- @param spell_name string Name of the unknown spell
function BLMMessages.show_unknown_buff_error(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Error: %sUnknown buff spell: %s",
        job_color, job_tag,
        action_color,
        error_color, spell_name
    )

    add_to_chat(001, formatted_message)
end

--- Display buff already active message
--- @param spell_name string Name of the buff spell
function BLMMessages.show_buff_already_active(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local success_color = MessageCore.create_color_code(Colors.SUCCESS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Buff %s%s%s already active",
        job_color, job_tag,
        action_color,
        success_color, spell_name,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display manual buff cast message
--- @param spell_name string Name of the buff spell
function BLMMessages.show_manual_buff_cast(spell_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Manual buff cast: %s%s",
        job_color, job_tag,
        action_color,
        spell_color, spell_name
    )

    add_to_chat(001, formatted_message)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLMMessages

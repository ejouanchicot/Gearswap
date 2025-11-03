---============================================================================
--- Message Combat - Combat state and validation messages
---============================================================================
--- @file utils/message_combat.lua
--- @author Tetsouo
--- @version 1.2
--- @date Updated: 2025-10-09 - Added Jump/High Jump chaining messages
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS  -- Centralized color configuration
local MessageCombat = {}

--- Display a range check error with multi-color formatting
--- @param ability string Ability name
--- @param distance_info string Distance information (e.g., "Distance: 12.5y")
function MessageCombat.show_range_error(ability, distance_info)
    -- Multi-color format: WS(yellow) + Error(red) + Distance(gray)
    local ws_color = MessageCore.create_color_code(Colors.WS)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local distance_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Too Far ! %s(%s)",
        ws_color, ability,
        error_color,
        distance_color, distance_info
    )

    add_to_chat(001, formatted_message)  -- Use 001 to preserve inline colors
end

--- Display a weaponskill validation error with multi-color formatting
--- @param ws_name string Weaponskill name
--- @param reason string Error reason (e.g., "Not enough TP", "Cannot use -")
--- @param detail string Optional detail (e.g., "500/1000")
--- @param status_ailment string Optional status ailment name (e.g., "Amnesia") - will be colored purple
--- @param detail_color_code number Optional custom color code for detail text
function MessageCombat.show_ws_validation_error(ws_name, reason, detail, status_ailment, detail_color_code)
    -- Multi-color format: [JOB/SUBJOB] + [WS](yellow) + Error(red) + Detail(custom/gray) + Status(purple)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ws_color = MessageCore.create_color_code(Colors.WS)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local detail_color = detail_color_code and MessageCore.create_color_code(detail_color_code)
                         or MessageCore.create_color_code(Colors.SEPARATOR)
    local status_color = MessageCore.create_color_code(Colors.DEBUFF)

    local formatted_message
    if status_ailment then
        -- Special format for status ailments: [JOB/SUBJOB] [WS] Cannot use - Amnesia
        formatted_message = string.format(
            "%s[%s] %s[%s]%s %s %s%s",
            job_color, job_tag,
            ws_color, ws_name,
            error_color, reason,
            status_color, status_ailment
        )
    elseif detail then
        formatted_message = string.format(
            "%s[%s] %s[%s]%s %s %s(%s)",
            job_color, job_tag,
            ws_color, ws_name,
            error_color, reason,
            detail_color, detail
        )
    else
        formatted_message = string.format(
            "%s[%s] %s[%s]%s %s",
            job_color, job_tag,
            ws_color, ws_name,
            error_color, reason
        )
    end

    add_to_chat(001, formatted_message)  -- Use 001 to preserve inline colors
end

--- Display a target validation error
--- @param action string Action being attempted
--- @param reason string Why target is invalid
function MessageCombat.show_target_error(action, reason)
    add_to_chat(Colors.RANGE_ERROR, string.format("Target Error: %s (%s)", action, reason))
end

--- Display a combat state change message
--- @param old_state string Previous state
--- @param new_state string New state
function MessageCombat.show_state_change(old_state, new_state)
    add_to_chat(Colors.SUCCESS, string.format("Combat: %s >> %s", old_state, new_state))
end

--- Display ability TP requirement error with multi-color formatting
--- @param ability_name string Ability name
--- @param current_tp number Current TP amount
--- @param required_tp number Required TP amount
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_ability_tp_error(ability_name, current_tp, required_tp, job_tag)
    -- Multi-color format: [JOB](cyan) + Ability(yellow) + Error(red) + TP(gray)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local error_color = MessageCore.create_color_code(Colors.ERROR)
    local detail_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local separator = string.rep("=", 50)

    local formatted_message = string.format(
        "%s[%s] %sAbility: %s%s %sNot enough TP %s(%d/%d TP)",
        job_color, job_tag,
        detail_color,
        ability_color, ability_name,
        error_color,
        detail_color, current_tp, required_tp
    )

    -- Display with separators
    add_to_chat(001, detail_color .. separator)
    add_to_chat(001, formatted_message)
    add_to_chat(001, detail_color .. separator)
end

--- Display weaponskill TP information
--- @param ws_name string Weaponskill name
--- @param total_tp number Total TP (including all bonuses)
function MessageCombat.show_ws_tp(ws_name, total_tp)
    -- Multi-color format: WS(yellow) + Gray separators + TP(green)
    local ws_color = MessageCore.create_color_code(Colors.WS)
    local tp_color = MessageCore.create_color_code(Colors.SUCCESS)
    local gray_color = MessageCore.create_color_code(Colors.SEPARATOR)

    -- Determine TP color based on threshold (gradient: White → Cyan → Green = Lambda → Cool → Ultime)
    local final_tp_color
    if total_tp >= 3000 then
        final_tp_color = MessageCore.create_color_code(Colors.TP_ULTIMATE) -- Green (3000 TP)
    elseif total_tp >= 2000 then
        final_tp_color = MessageCore.create_color_code(Colors.TP_ENHANCED) -- Cyan (2000-2999 TP)
    else
        final_tp_color = MessageCore.create_color_code(Colors.TP_NORMAL) -- White (1000-1999 TP)
    end

    local formatted_message = string.format(
        "%s[%s]%s (%s%d TP%s)",
        ws_color, ws_name,
        gray_color,
        final_tp_color, total_tp,
        gray_color
    )

    add_to_chat(001, formatted_message)  -- Use 001 to preserve inline colors
end

--- Display weaponskill activation with description and TP (combined message)
--- @param ws_name string Weaponskill name
--- @param description string WS description from database
--- @param total_tp number|nil Total TP (optional, if nil will not display TP)
function MessageCombat.show_ws_activated(ws_name, description, total_tp)
    -- Format: [JOB/SUBJOB] [WS_NAME] -> Description (TP colored by amount)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ws_color = MessageCore.create_color_code(Colors.WS)
    local arrow_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local desc_color = MessageCore.create_color_code(Colors.SEPARATOR)  -- Gray like JA descriptions

    local formatted_message = string.format(
        "%s[%s] %s[%s] %s-> %s%s",
        job_color, job_tag,
        ws_color, ws_name,
        arrow_color,
        desc_color, description
    )

    -- Add TP if provided (with color gradient)
    if total_tp then
        local tp_color
        if total_tp >= 3000 then
            tp_color = MessageCore.create_color_code(Colors.TP_ULTIMATE) -- Green (3000 TP)
        elseif total_tp >= 2000 then
            tp_color = MessageCore.create_color_code(Colors.TP_ENHANCED) -- Cyan (2000-2999 TP)
        else
            tp_color = MessageCore.create_color_code(Colors.TP_NORMAL) -- White (1000-1999 TP)
        end

        formatted_message = formatted_message .. string.format(
            " %s(%s%d TP%s)",
            desc_color,
            tp_color, total_tp,
            desc_color
        )
    end

    add_to_chat(001, formatted_message)  -- Use 001 to preserve inline colors
end

--- Display spell casting message with multi-color formatting
--- @param spell_name string Spell name being cast
function MessageCombat.show_spell_cast(spell_name)
    -- Multi-color format: [MAIN/SUB](cyan) + Casting(white) + Spell(cyan)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)

    local formatted_message = string.format(
        "%s[%s]%s Casting %s%s",
        job_color, job_tag,
        action_color,
        spell_color, spell_name
    )

    add_to_chat(001, formatted_message)  -- Use 001 to preserve inline colors
end

--- Display ability usage message with multi-color formatting
--- @param ability_name string Ability name being used
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_ability_use(ability_name, job_tag)
    -- Multi-color format: [MAIN/SUB](cyan) + Using(white) + Ability(yellow)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local ability_color = MessageCore.create_color_code(Colors.JA)

    local formatted_message = string.format(
        "%s[%s]%s Using %s%s",
        job_color, job_tag,
        action_color,
        ability_color, ability_name
    )

    add_to_chat(001, formatted_message)  -- Use 001 to preserve inline colors
end

--- Display waltz healing message with multi-color formatting
--- @param waltz_name string Waltz name being used
--- @param missing_hp number|nil HP being cured (nil for AoE)
--- @param extra_ability string|nil Extra ability used (optional)
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_waltz_heal(waltz_name, missing_hp, extra_ability, job_tag)
    -- Multi-color format: [MAIN/SUB](cyan) + Curing/AoE(white) + HP(green) + using(white) + Waltz(yellow) + Extra(green)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local hp_color = MessageCore.create_color_code(Colors.SUCCESS)
    local waltz_color = MessageCore.create_color_code(Colors.JA)
    local separator = string.rep("=", 50)

    local formatted_message
    if missing_hp then
        -- Single target waltz with HP amount
        formatted_message = string.format(
            "%s[%s]%s Curing %s%d HP%s using %s%s",
            job_color, job_tag,
            action_color,
            hp_color, missing_hp,
            action_color,
            waltz_color, waltz_name
        )
    else
        -- AoE waltz (Divine Waltz)
        formatted_message = string.format(
            "%s[%s]%s AoE Healing using %s%s",
            job_color, job_tag,
            action_color,
            waltz_color, waltz_name
        )
    end

    -- Add extra ability if present
    if extra_ability then
        formatted_message = formatted_message .. string.format(
            "%s + %s%s",
            action_color,
            hp_color, extra_ability
        )
    end

    -- Display with separators
    add_to_chat(001, action_color .. separator)
    add_to_chat(001, formatted_message)
    add_to_chat(001, action_color .. separator)
end

---============================================================================
--- JUMP/HIGH JUMP MESSAGES (DNC/DRG, DRG, THF/DRG)
---============================================================================

--- Display Jump activation message with description from database
--- @param jump_ability string Jump ability name ("Jump" or "High Jump")
--- @param description string Jump description from JA database
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_jump_activated(jump_ability, description, job_tag)
    -- Multi-color format: [MAIN/SUB](cyan) + [Jump](yellow) + ->(gray) + Description(gray)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local arrow_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local desc_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s] %s[%s] %s-> %s%s",
        job_color, job_tag,
        ability_color, jump_ability,
        arrow_color,
        desc_color, description
    )

    add_to_chat(001, formatted_message)
end

--- Display Jump chaining message (with optional description)
--- @param second_jump string Second Jump ability name ("Jump" or "High Jump")
--- @param description string|nil Optional Jump description from JA database
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_jump_chaining(second_jump, description, job_tag)
    -- Multi-color format: [MAIN/SUB](cyan) + Chaining(white) + [Jump](yellow)
    -- If description: + ->(gray) + Description(gray)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ability_color = MessageCore.create_color_code(Colors.JA)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message
    if description then
        -- With description (manual usage)
        local desc_color = MessageCore.create_color_code(Colors.SEPARATOR)
        formatted_message = string.format(
            "%s[%s]%s Chaining %s[%s] %s-> %s%s",
            job_color, job_tag,
            action_color,
            ability_color, second_jump,
            action_color,
            desc_color, description
        )
    else
        -- Without description (auto-sequence flow - simple)
        formatted_message = string.format(
            "%s[%s]%s Chaining %s[%s]",
            job_color, job_tag,
            action_color,
            ability_color, second_jump
        )
    end

    add_to_chat(001, formatted_message)
end

--- Display Jump sequence complete message (after 2 Jumps finished)
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_jump_complete(job_tag)
    -- Multi-color format: [MAIN/SUB](cyan) + Jump sequence complete(white)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Jump sequence complete",
        job_color, job_tag,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display simple re-launch message (when only one Jump was needed)
--- @param ws_name string Weaponskill name to re-launch
--- @param job_tag string|nil Optional job tag override
function MessageCombat.show_jump_relaunch(ws_name, job_tag)
    -- Multi-color format: [MAIN/SUB](cyan) + Re-launch(white) + WS(yellow) + manually(white)
    job_tag = job_tag or MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local ws_color = MessageCore.create_color_code(Colors.WS)
    local action_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local formatted_message = string.format(
        "%s[%s]%s Re-launch %s%s%s manually",
        job_color, job_tag,
        action_color,
        ws_color, ws_name,
        action_color
    )

    add_to_chat(001, formatted_message)
end

--- Display spell activation with description (Enhancing/Enfeebling/Healing)
--- @param spell_name string Spell name
--- @param description string|nil Spell description (if nil, shows name only)
--- @param target_name string|nil Target name (for buffs)
function MessageCombat.show_spell_activated(spell_name, description, target_name)
    local job_tag = MessageCore.get_job_tag()
    local job_color = MessageCore.create_color_code(Colors.JOB_TAG)
    local spell_color = MessageCore.create_color_code(Colors.SPELL)
    local arrow_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local desc_color = MessageCore.create_color_code(Colors.SEPARATOR)
    local target_color = MessageCore.create_color_code(Colors.SUCCESS)  -- Green for target

    local formatted_message

    -- Build target string if provided
    local target_str = ""
    if target_name and target_name ~= player.name then
        target_str = string.format(" %s>> %s%s", arrow_color, target_color, target_name)
    end

    if description then
        -- Mode 'full' - Show description + target
        formatted_message = string.format(
            "%s[%s] %s[%s]%s %s-> %s%s",
            job_color, job_tag,
            spell_color, spell_name,
            target_str,
            arrow_color,
            desc_color, description
        )
    else
        -- Mode 'on' - Name only + target
        formatted_message = string.format(
            "%s[%s] %s[%s]%s",
            job_color, job_tag,
            spell_color, spell_name,
            target_str
        )
    end

    add_to_chat(001, formatted_message)
end

return MessageCombat

---============================================================================
--- Message Status - Error, warning, and success messages
---============================================================================
--- @file utils/message_status.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS
local MessageStatus = {}

--- Display an error message with consistent formatting
--- @param message string Error message to display
function MessageStatus.show_error(message)
    add_to_chat(Colors.ERROR, "Error: " .. message)
end

--- Display a warning message with consistent formatting
--- @param message string Warning message to display
function MessageStatus.show_warning(message)
    add_to_chat(Colors.WARNING, "Warning: " .. message)
end

--- Display a success message with consistent formatting
--- @param message string Success message to display
function MessageStatus.show_success(message)
    add_to_chat(Colors.SUCCESS, message)
end

--- Display an info message with consistent formatting
--- @param message string Info message to display
--- @param color number Optional color code (defaults to 001 white)
function MessageStatus.show_info(message, color)
    add_to_chat(color or 001, message)
end

--- Display TP ready message with professional formatting
--- @param job_tag string Job tag (e.g., "DNC/WAR", "WAR/DRG")
--- @param tp_value number TP threshold value (e.g., 1000)
function MessageStatus.show_tp_ready(job_tag, tp_value)
    local MessageCore = require('shared/utils/messages/message_core')
    local Colors = MessageCore.COLORS

    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorJA = MessageCore.create_color_code(Colors.JA)
    local colorSuccess = MessageCore.create_color_code(Colors.SUCCESS)

    -- Separator
    local separator = string.rep("=", 50)
    add_to_chat(1, colorGray .. separator)

    -- Format: [DNC/WAR] TP >= 1000 (READY)
    local message = colorGray .. '[' .. colorJob .. job_tag .. colorGray .. '] ' ..
                   colorJA .. 'TP >= ' .. tp_value .. colorGray .. ' (' .. colorSuccess .. 'READY' .. colorGray .. ')'
    add_to_chat(1, message)

    -- Separator
    add_to_chat(1, colorGray .. separator)
end

--- Display TP requirement error with professional formatting
--- @param job_tag string Job tag (e.g., "DNC/WAR", "WAR/DRG")
--- @param ability_name string Name of the ability requiring TP
--- @param current_tp number Current TP value
--- @param required_tp number Required TP value
function MessageStatus.show_tp_required(job_tag, ability_name, current_tp, required_tp)
    -- Color codes
    local colorGray = MessageCore.create_color_code(Colors.SEPARATOR)
    local colorJob = MessageCore.create_color_code(Colors.JOB_TAG)
    local colorJA = MessageCore.create_color_code(Colors.JA)
    local colorError = MessageCore.create_color_code(Colors.ERROR)

    -- Separator
    local separator = string.rep("=", 50)
    add_to_chat(1, colorGray .. separator)

    -- Format: [DNC/WAR] Ability: Divine Waltz (350/400 TP)
    local message = colorGray .. '[' .. colorJob .. job_tag .. colorGray .. '] ' ..
                   'Ability: ' .. colorJA .. ability_name .. colorGray ..
                   ' (' .. colorError .. current_tp .. '/' .. required_tp .. ' TP' .. colorGray .. ')'
    add_to_chat(1, message)

    -- Separator
    add_to_chat(1, colorGray .. separator)
end

return MessageStatus

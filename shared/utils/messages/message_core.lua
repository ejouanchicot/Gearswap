---============================================================================
--- Message Core - Base colors and utilities for all message modules
---============================================================================
--- @file utils/message_core.lua
--- @author Tetsouo
--- @version 2.0
--- @date Updated: 2025-10-02 - Centralized color configuration
---============================================================================

local MessageCore = {}

-- Load centralized color configuration
local MessageColors = require('shared/utils/messages/message_colors')
MessageCore.COLORS = MessageColors

--- Create FFXI color code string
--- @param color_code number FFXI color code (1-255)
--- @return string Formatted color code for inline use
function MessageCore.create_color_code(color_code)
    if not color_code or type(color_code) ~= "number" then
        error("create_color_code: Invalid color_code (got " .. tostring(color_code) .. " of type " .. type(color_code) .. ")")
    end
    return string.char(0x1F, color_code)
end

--- Convert GearSwap key symbols to user-friendly display names
--- @param key string Raw key binding (e.g., "!1", "^f1")
--- @return string User-friendly key name (e.g., "ALT+1", "CTRL+F1")
function MessageCore.convert_key_display(key)
    local converted = key
    converted = converted:gsub("!", "ALT+")
    converted = converted:gsub("%^", "CTRL+")
    converted = converted:gsub("~", "SHIFT+")
    converted = converted:gsub("@", "WIN+")
    converted = converted:gsub("f(%d+)", "F%1")
    return converted:upper()
end

--- Display a colored separator line
--- @param length number Optional separator length (default: 50)
function MessageCore.show_separator(length)
    length = length or 50
    local colorGray = MessageCore.create_color_code(MessageCore.COLORS.SEPARATOR)
    local separator = string.rep("=", length)
    add_to_chat(1, colorGray .. separator)
end

--- Get dynamic job tag [MAIN/SUB] based on current player state
--- @return string Job tag (e.g., "WAR/SAM", "PLD/BLU", "PLD")
function MessageCore.get_job_tag()
    if not player then return "JOB" end

    local main_job = player.main_job or "JOB"
    local sub_job = player.sub_job

    if sub_job and sub_job ~= "NON" and sub_job ~= "" then
        return string.format("%s/%s", main_job, sub_job)
    else
        return main_job
    end
end

---============================================================================
--- STANDARD MESSAGE FUNCTIONS
---============================================================================

--- Display info message (cyan)
--- @param message string Message to display
function MessageCore.info(message)
    local job_tag = MessageCore.get_job_tag()
    add_to_chat(121, string.format("[%s] %s", job_tag, message))
end

--- Display success message (green)
--- @param message string Message to display
function MessageCore.success(message)
    local job_tag = MessageCore.get_job_tag()
    add_to_chat(158, string.format("[%s] %s", job_tag, message))
end

--- Display error message (red)
--- @param message string Message to display
function MessageCore.error(message)
    local job_tag = MessageCore.get_job_tag()
    add_to_chat(167, string.format("[%s] %s", job_tag, message))
end

--- Display warning message (yellow)
--- @param message string Message to display
function MessageCore.warning(message)
    local job_tag = MessageCore.get_job_tag()
    add_to_chat(205, string.format("[%s] %s", job_tag, message))
end

---============================================================================
--- UTILITY MESSAGES
---============================================================================

--- Show lockstyle status message
--- @param status_msg string Status message
function MessageCore.show_lockstyle_status(status_msg)
    add_to_chat(207, status_msg)
end

--- Show AutoMove callback error
--- @param error_msg string Error message
function MessageCore.show_automove_error(error_msg)
    add_to_chat(167, string.format("[AutoMove] Callback error: %s", error_msg))
end

--- Show config loader error
--- @param module_name string Module name (e.g., 'ConfigLoader', 'WHM')
--- @param error_msg string Error message
function MessageCore.show_config_error(module_name, error_msg)
    add_to_chat(167, string.format('[%s] %s', module_name, error_msg))
end

--- Show UI module error
--- @param error_msg string Error message
function MessageCore.show_ui_error(error_msg)
    add_to_chat(167, string.format('[UI] %s', error_msg))
end

--- Show UI module info
--- @param info_msg string Info message
function MessageCore.show_ui_info(info_msg)
    add_to_chat(122, string.format('[UI] %s', info_msg))
end

--- Show test mode message
--- @param test_msg string Test mode message
function MessageCore.show_test_mode(test_msg)
    add_to_chat(8, string.format('[TEST MODE] %s', test_msg))
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageCore

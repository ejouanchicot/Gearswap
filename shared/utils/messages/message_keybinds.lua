---============================================================================
--- Message Keybinds - Keybind-specific formatting functions
---============================================================================
--- @file utils/message_keybinds.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS
local MessageKeybinds = {}

--- Format a single keybind line with colors
--- @param key string Raw keybind key (e.g., "!1")
--- @param description string Keybind description
--- @return string Formatted message with color codes
function MessageKeybinds.format_keybind_line(key, description)
    local display_key = MessageCore.convert_key_display(key)
    local key_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
    local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
    return string.format("%s[%s]%s %s", key_color, display_key, desc_color, description)
end

--- Calculate the maximum display width for a set of keybinds
--- @param keybinds table Array of keybind objects
--- @return number Maximum width of formatted keybinds
function MessageKeybinds.calculate_max_width(keybinds)
    local max_width = 0
    for _, bind in pairs(keybinds) do
        local display_key = MessageCore.convert_key_display(bind.key)
        local line_length = string.len(string.format("[%s] %s", display_key, bind.desc))
        if line_length > max_width then
            max_width = line_length
        end
    end
    return max_width
end

--- Display a complete keybind list with header
--- @param title string List title
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
function MessageKeybinds.show_keybind_list(title, keybinds)
    local max_width = MessageKeybinds.calculate_max_width(keybinds)
    max_width = math.max(max_width + 4, string.len(title) + 8)

    local separator = string.rep("=", max_width)
    local title_with_spaces = string.format(" %s ", title)
    local padding = math.floor((max_width - string.len(title_with_spaces)) / 2)
    local padded_title = string.rep("=", padding) ..
    title_with_spaces .. string.rep("=", max_width - padding - string.len(title_with_spaces))

    add_to_chat(Colors.INFO_HEADER, separator)
    add_to_chat(Colors.INFO_HEADER, padded_title)
    add_to_chat(Colors.INFO_HEADER, separator)

    for _, bind in pairs(keybinds) do
        local formatted_line = MessageKeybinds.format_keybind_line(bind.key, bind.desc)
        add_to_chat(001, formatted_line)
    end

    add_to_chat(Colors.INFO_HEADER, separator)
end

--- Display error when no keybinds are defined for a job
--- @param job_name string Job name (e.g., "WAR", "BRD")
function MessageKeybinds.show_no_binds_error(job_name)
    add_to_chat(Colors.ERROR, string.format("Error: No keybinds defined for %s", job_name))
end

--- Display error when a keybind is invalid or malformed
--- @param bind_key string Invalid keybind key
function MessageKeybinds.show_invalid_bind_error(bind_key)
    add_to_chat(Colors.ERROR, string.format("Error: Invalid keybind: %s", bind_key))
end

--- Display error when keybind binding fails
--- @param bind_key string Keybind that failed to bind
--- @param reason string Optional reason for failure
function MessageKeybinds.show_bind_failed_error(bind_key, reason)
    local message = reason and
        string.format("Error: Failed to bind %s (%s)", bind_key, reason) or
        string.format("Error: Failed to bind %s", bind_key)
    add_to_chat(Colors.ERROR, message)
end

return MessageKeybinds

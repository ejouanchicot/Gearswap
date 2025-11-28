---============================================================================
--- Message Keybinds - Keybind-specific formatting functions (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_keybinds.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageKeybinds = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS

---============================================================================
--- HELPER FUNCTIONS (Keep as-is - pure logic, no display)
---============================================================================

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

---============================================================================
--- DISPLAY FUNCTIONS (Migrated to new system)
---============================================================================

--- Display a complete keybind list with header
--- @param title string List title
--- @param keybinds table Array of keybind objects with 'key' and 'desc' fields
function MessageKeybinds.show_keybind_list(title, keybinds)
    local max_width = MessageKeybinds.calculate_max_width(keybinds)
    max_width = math.max(max_width + 4, string.len(title) + 8)

    -- Prepare separator
    local separator = string.rep("=", max_width)

    -- Prepare padded title
    local title_with_spaces = string.format(" %s ", title)
    local padding = math.floor((max_width - string.len(title_with_spaces)) / 2)
    local padded_title = string.rep("=", padding) ..
        title_with_spaces .. string.rep("=", max_width - padding - string.len(title_with_spaces))

    -- Display header
    M.send('KEYBINDS', 'keybind_header_separator', {separator = separator})
    M.send('KEYBINDS', 'keybind_header_title', {padded_title = padded_title})
    M.send('KEYBINDS', 'keybind_header_separator', {separator = separator})

    -- Display each keybind line (use manual colors since display_key varies)
    for _, bind in pairs(keybinds) do
        local display_key = MessageCore.convert_key_display(bind.key)
        local key_color = MessageCore.create_color_code(Colors.KEYBIND_KEY)
        local desc_color = MessageCore.create_color_code(Colors.KEYBIND_DESC)
        local formatted_line = string.format("%s[%s]%s %s", key_color, display_key, desc_color, bind.desc)

        -- Send directly via MessageRenderer (can't use template since colors vary)
        MessageRenderer.send(formatted_line, 1, {namespace = 'KEYBINDS', level = 0})
    end

    -- Display footer
    M.send('KEYBINDS', 'keybind_header_separator', {separator = separator})
end

--- Display error when no keybinds are defined for a job
--- @param job_name string Job name (e.g., "WAR", "BRD")
function MessageKeybinds.show_no_binds_error(job_name)
    M.send('KEYBINDS', 'no_binds_error', {job_name = job_name})
end

--- Display error when a keybind is invalid or malformed
--- @param bind_key string Invalid keybind key
function MessageKeybinds.show_invalid_bind_error(bind_key)
    M.send('KEYBINDS', 'invalid_bind_error', {bind_key = bind_key})
end

--- Display error when keybind binding fails
--- @param bind_key string Keybind that failed to bind
--- @param reason string Optional reason for failure
function MessageKeybinds.show_bind_failed_error(bind_key, reason)
    if reason then
        M.send('KEYBINDS', 'bind_failed_error_reason', {
            bind_key = bind_key,
            reason = reason
        })
    else
        M.send('KEYBINDS', 'bind_failed_error', {bind_key = bind_key})
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageKeybinds

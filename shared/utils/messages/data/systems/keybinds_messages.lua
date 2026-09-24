---============================================================================
--- KEYBINDS Message Data - Keybind Display and Error Messages
---============================================================================
--- Pure data file for keybind-related messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/systems/keybinds_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- KEYBIND DISPLAY MESSAGES
    ---========================================================================

    keybind_header_separator = {
        template = "{gray}{separator}",
        color = 1
    },

    keybind_header_title = {
        template = "{gray}{padded_title}",
        color = 1
    },

    keybind_line = {
        template = "{key_color}[{display_key}]{desc_color} {description}",
        color = 1
    },

    ---========================================================================
    --- KEYBIND ERROR MESSAGES
    ---========================================================================

    no_binds_error = {
        template = "{red}Error: No keybinds defined for {job_name}",
        color = 167
    },

    invalid_bind_error = {
        template = "{red}Error: Invalid keybind: {bind_key}",
        color = 167
    },

    bind_failed_error = {
        template = "{red}Error: Failed to bind {bind_key}",
        color = 167
    },

    bind_failed_error_reason = {
        template = "{red}Error: Failed to bind {bind_key} ({reason})",
        color = 167
    },
}

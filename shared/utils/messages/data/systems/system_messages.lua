---============================================================================
--- SYSTEM Message Data - System Intro and Colortest Messages
---============================================================================
--- Pure data file for system initialization messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/system_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SYSTEM INTRO MESSAGES
    ---========================================================================

    intro_header_separator = {
        template = "{gray}{separator}",
        color = 160
    },

    intro_header_title = {
        template = "{green}  {title}",
        color = 158
    },

    intro_macrobook = {
        template = "{key_color}Macrobook:{desc_color} Book {book} | Set {page}",
        color = 1
    },

    intro_lockstyle = {
        template = "{key_color}Lockstyle:{desc_color} Set {style} (applying in {delay}s...)",
        color = 1
    },

    intro_keybinds = {
        template = "{key_color}Keybinds:{desc_color} {count} loaded",
        color = 1
    },

    intro_ui_visible = {
        template = "{key_color}UI:{desc_color} Visible (toggle with //gs c ui)",
        color = 1
    },

    intro_ui_hidden = {
        template = "{key_color}UI:{desc_color} Hidden (toggle with //gs c ui)",
        color = 1
    },

    intro_footer_separator = {
        template = "{gray}{separator}",
        color = 160
    },

    ---========================================================================
    --- COLOR TEST MESSAGES (Debug)
    ---========================================================================

    colortest_header_separator = {
        template = "{purple}========================================",
        color = 159
    },

    colortest_header_title = {
        template = "{purple}[COR] FFXI Color Code Test (001-255)",
        color = 159
    },

    colortest_sample = {
        template = "{sample_text}",
        color = 121
    },

    colortest_footer_separator = {
        template = "{purple}========================================",
        color = 159
    },

    colortest_footer_complete = {
        template = "{purple}[COR] Color test complete!",
        color = 159
    },
}

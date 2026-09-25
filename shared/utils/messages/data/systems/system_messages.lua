---============================================================================
--- SYSTEM Message Data - System Intro and Colortest Messages
---============================================================================
--- Pure data file for system initialization messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/systems/system_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- SYSTEM INTRO MESSAGES
    ---========================================================================

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

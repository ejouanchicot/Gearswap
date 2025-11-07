---============================================================================
--- MIDCAST Message Data - MidcastManager Debug Messages
---============================================================================
--- Pure data file for MidcastManager debug output
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/midcast_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- DEBUG MODE MESSAGES
    ---========================================================================

    debug_enabled_separator = {
        template = "{gray}===================================================",
        color = 160
    },

    debug_enabled_title = {
        template = "{gray}[MidcastManager] DEBUG MODE ENABLED",
        color = 160
    },

    debug_disabled = {
        template = "{gray}[MidcastManager] DEBUG MODE DISABLED",
        color = 160
    },

    ---========================================================================
    --- DEBUG LOGGING MESSAGES
    ---========================================================================

    debug_log = {
        template = "{gray}[MidcastManager] {message}",
        color = 160
    },

    debug_header_separator = {
        template = "{darkgray}-------------------------------------------------",
        color = 8
    },

    debug_header_title = {
        template = "{darkgray}[MidcastManager] {message}",
        color = 8
    },

    debug_step = {
        template = "{gray}[MidcastManager]   STEP {step}: {message}",
        color = 160
    },

    debug_step_result = {
        template = "{gray}[MidcastManager]   STEP {step}: {message} -> {result}",
        color = 160
    },

    debug_set_exists = {
        template = "{green}[MidcastManager]     +- {set_name} -> [OK] EXISTS",
        color = 158
    },

    debug_set_missing = {
        template = "{red}[MidcastManager]     +- {set_name} -> [FAIL] NOT FOUND",
        color = 167
    },
}

---============================================================================
--- STATUS Message Data - Status Messages (error, warning, success, info)
---============================================================================
--- Pure data file for status messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/status_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- BASIC STATUS MESSAGES
    ---========================================================================

    error = {
        template = "Error: {message}",
        color = 167
    },

    warning = {
        template = "Warning: {message}",
        color = 200
    },

    success = {
        template = "{message}",
        color = 158
    },

    info = {
        template = "{message}",
        color = 1
    },

    ---========================================================================
    --- TP STATUS MESSAGES
    ---========================================================================

    tp_ready = {
        template = "{gray}==================================================\n{gray}[{lightblue}{job}{gray}] {yellow}TP >= {tp_value} {gray}({green}READY{gray})\n{gray}==================================================",
        color = 1
    },

    tp_required = {
        template = "{gray}==================================================\n{gray}[{lightblue}{job}{gray}] Ability: {yellow}{ability} {gray}({red}{current_tp}/{required_tp} TP{gray})\n{gray}==================================================",
        color = 1
    },
}

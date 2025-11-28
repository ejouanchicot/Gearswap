---============================================================================
--- PRECAST Message Data - Precast Debug Messages
---============================================================================
--- Pure data file for Precast debug output
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/precast_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-09
---============================================================================

-- Import MessageColors for region-specific color detection
local MessageColors = require('shared/utils/messages/message_colors')

return {
    ---========================================================================
    --- DEBUG MODE TOGGLE MESSAGES
    ---========================================================================

    debug_enabled_separator = {
        template = "{gray}==========================================================",
        color = 160
    },

    debug_enabled_title = {
        template = "{green}[Precast] DEBUG MODE ENABLED",
        color = 158
    },

    debug_disabled = {
        template = "{gray}[Precast] DEBUG MODE DISABLED",
        color = 160
    },

    ---========================================================================
    --- DEBUG HEADER (action + type)
    ---========================================================================

    debug_header_separator = {
        template = "{gray}==========================================================",
        color = 160
    },

    debug_header_action = {
        template = "{cyan}[PRECAST] {action} {gray}({type})",
        color = 158
    },

    ---========================================================================
    --- DEBUG STEPS (compact format)
    ---========================================================================

    debug_step_ok = {
        template = "{gray}STEP {step}: {label} >> {green}OK: {value}",
        color = 160
    },

    debug_step_warn = {
        template = "{gray}STEP {step}: {label} >> {orange}WARN: {value}",
        color = 160
    },

    debug_step_fail = {
        template = "{gray}STEP {step}: {label} >> {red}FAIL: {value}",
        color = 160
    },

    debug_step_info = {
        template = "{gray}STEP {step}: {label} >> {cyan}{value}",
        color = 160
    },

    ---========================================================================
    --- COMPLETION MESSAGE
    ---========================================================================

    debug_completion_separator = {
        template = "{gray}----------------------------------------------------------",
        color = 160
    },

    debug_completion = {
        template = "{green}[PRECAST] >> Complete - equipping gear",
        color = 158
    },

    ---========================================================================
    --- EQUIPMENT DISPLAY
    ---========================================================================

    debug_set_equipped = {
        template = "{green}SET EQUIPPED: {cyan}{set}",
        color = 158
    },

    debug_equipment_single = {
        template = "{gray}  {slot}: {cyan}{item}",
        color = 160
    },
}

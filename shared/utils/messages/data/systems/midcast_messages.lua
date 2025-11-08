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
    --- DEBUG MODE TOGGLE MESSAGES
    ---========================================================================

    debug_enabled_separator = {
        template = "{gray}---------------------------------------------------------",
        color = 160
    },

    debug_enabled_title = {
        template = "{green}[Midcast] DEBUG MODE ENABLED",
        color = 158
    },

    debug_disabled = {
        template = "{gray}[Midcast] DEBUG MODE DISABLED",
        color = 160
    },

    ---========================================================================
    --- DEBUG HEADER (spell + skill + target)
    ---========================================================================

    debug_header_separator = {
        template = "{gray}---------------------------------------------------------",
        color = 160
    },

    debug_header_spell = {
        template = "{gray}[Midcast] {cyan}{spell} {gray}({skill}) | Target: {cyan}{target}",
        color = 160
    },

    ---========================================================================
    --- DEBUG STEPS (compact format)
    ---========================================================================

    debug_step_ok = {
        template = "{gray}STEP {step}: {label} -> {green}OK: {value}",
        color = 160
    },

    debug_step_warn = {
        template = "{gray}STEP {step}: {label} -> {orange}WARN: {value}",
        color = 160
    },

    debug_step_fail = {
        template = "{gray}STEP {step}: {label} -> {red}FAIL: {value}",
        color = 160
    },

    debug_step_info = {
        template = "{gray}STEP {step}: {label} -> {cyan}{value}",
        color = 160
    },

    ---========================================================================
    --- DEBUG PRIORITIES (P0-P5 checks)
    ---========================================================================

    debug_priorities_header = {
        template = "{gray}STEP 3: Priorities     -> Spell > Nested > Type > Mode > Base",
        color = 160
    },

    debug_priority_found = {
        template = "{gray}  [P{priority}] {label} -> {green}FOUND",
        color = 160
    },

    debug_priority_missing = {
        template = "{gray}  [P{priority}] {label} -> {red}NOT FOUND",
        color = 160
    },

    ---========================================================================
    --- DEBUG RESULT (final equipment)
    ---========================================================================

    debug_result_header = {
        template = "{gray}---------------------------------------------------------",
        color = 160
    },

    debug_result_success = {
        template = "{green}RESULT: Equipped {cyan}{set_type}",
        color = 158
    },

    debug_result_fallback = {
        template = "{orange}RESULT: Fallback to {cyan}{set_type}",
        color = 57
    },

    debug_equipment_line = {
        template = "{gray}  {slot1}: {item1} | {slot2}: {item2}",
        color = 160
    },

    debug_equipment_single = {
        template = "{gray}  {slot}: {item}",
        color = 160
    },
}

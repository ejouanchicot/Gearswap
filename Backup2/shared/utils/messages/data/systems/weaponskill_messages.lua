---============================================================================
--- WEAPONSKILL Message Data - Weaponskill Manager Messages
---============================================================================
--- Pure data file for weaponskill manager and TP calculator messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/weaponskill_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- WS MANAGER MESSAGES
    ---========================================================================

    ws_manager_initialized = {
        template = "{green}[WS Manager] Initialized",
        color = 123
    },

    invalid_spell_parameter = {
        template = "{green}[WS Manager] Invalid spell parameter for range check",
        color = 123
    },

    target_info_missing = {
        template = "{green}[WS Manager] Spell target information missing",
        color = 123
    },

    missing_numeric_values = {
        template = "{green}[WS Manager] Missing numeric values for range calculation",
        color = 123
    },

    too_far = {
        template = "{red}[{ws_name}] Too Far ! ({distance})",
        color = 167
    },

    player_info_missing = {
        template = "{green}[WS Manager] Player info not available",
        color = 123
    },

    amnesia_error = {
        template = "{red}[{ws_name}] Cannot use - Amnesia",
        color = 167
    },

    ---========================================================================
    --- TP CALCULATOR DEBUG MESSAGES
    ---========================================================================

    tp_validation_failed = {
        template = "{red}[TP_DEBUG] Validation failed: current_tp={current_tp}, tp_config={tp_config}",
        color = 167
    },

    tp_calculation = {
        template = "{purple}[TP_DEBUG] current_tp={current_tp}, weapon={weapon}, weapon_bonus={weapon_bonus}, real_tp={real_tp}",
        color = 200
    },

    already_at_max = {
        template = "{red}[TP_DEBUG] Already at/above max threshold (3000+)",
        color = 167
    },

    target_threshold = {
        template = "{purple}[TP_DEBUG] target_threshold={target_threshold}, gap={gap}",
        color = 200
    },

    gap_too_large = {
        template = "{red}[TP_DEBUG] Gap too large: gap={gap} > total_available={total_available}",
        color = 167
    },

    total_available = {
        template = "{purple}[TP_DEBUG] total_available={total_available}, checking pieces...",
        color = 200
    },

    checking_piece = {
        template = "{purple}[TP_DEBUG] Checking piece: {piece_name} (slot={slot}, bonus={bonus}) vs gap={gap}",
        color = 200
    },

    equipping_piece = {
        template = "{green}[TP_DEBUG] ✓ EQUIPPING: {slot}={piece_name} (bonus={bonus} >= gap={gap})",
        color = 158
    },
}

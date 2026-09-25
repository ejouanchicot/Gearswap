---============================================================================
--- WATCHDOG Message Data - Midcast Watchdog Messages
---============================================================================
--- Pure data file for Midcast Watchdog system messages
--- Loaded by the message engine when a formatter sends a key from it (api/messages.lua)
---
--- @file shared/utils/messages/data/systems/watchdog_messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- STATUS MESSAGES
    ---========================================================================

    enabled = {
        template = "{green}[Watchdog] Enabled",
        color = 158
    },

    disabled = {
        template = "{red}[Watchdog] Disabled",
        color = 167
    },

    stopped = {
        template = "{red}[Watchdog] Stopped",
        color = 167
    },

    not_loaded = {
        template = "{red}[Watchdog] Error: Watchdog not loaded",
        color = 167
    },

    ---========================================================================
    --- CONFIGURATION MESSAGES
    ---========================================================================

    buffer_set = {
        template = "{green}[Watchdog] Buffer set to: {seconds}s",
        color = 158
    },

    buffer_formula = {
        template = "{green}[Watchdog] Timeout formula: cast_time + {seconds}s",
        color = 158
    },

    invalid_buffer = {
        template = "{red}[Watchdog] Invalid buffer (must be 0-10s)",
        color = 167
    },

    fallback_set = {
        template = "{green}[Watchdog] Fallback timeout set to: {seconds}s (for unknown spells)",
        color = 158
    },

    invalid_fallback = {
        template = "{red}[Watchdog] Invalid fallback (must be 1-60s)",
        color = 167
    },

    ---========================================================================
    --- DEBUG MESSAGES
    ---========================================================================

    debug_enabled = {
        template = "{lightblue}[Watchdog] Debug mode enabled",
        color = 207
    },

    debug_disabled = {
        template = "{lightblue}[Watchdog] Debug mode disabled",
        color = 207
    },

    debug_midcast_item = {
        template = "{lightblue}[Watchdog DEBUG] Midcast Item: {spell_name} (Delay: {cast_delay}s, Timeout: {timeout}s)",
        color = 207
    },

    debug_midcast_spell = {
        template = "{lightblue}[Watchdog DEBUG] Midcast Spell: {spell_name} (Cast: {cast_time}s, Timeout: {timeout}s)",
        color = 207
    },

    debug_midcast_spell_fc = {
        template = "{lightblue}[Watchdog DEBUG] {spell_name}: Base={base_cast}s, FC={fc_percent}%, Adjusted={adjusted_cast}s, Timeout={timeout}s",
        color = 207
    },

    debug_scanner_disabled = {
        template = "{lightblue}[Watchdog DEBUG] Scanner disabled - watchdog not enabled",
        color = 207
    },

    debug_ignored_action = {
        template = "{lightblue}[Watchdog DEBUG] Ignored: {action_name} (type: {action_type})",
        color = 207
    },

    debug_no_active = {
        template = "{lightblue}[Watchdog DEBUG] No active midcast to scan",
        color = 207
    },

    debug_scan = {
        template = "{lightblue}[Watchdog DEBUG] Scanning: {spell_name} | Age: {age}s / Timeout: {timeout}s",
        color = 207
    },

    ---========================================================================
    --- ERROR/ALERT MESSAGES
    ---========================================================================

    stuck_detected = {
        template = "{yellow}[Watchdog ALERT] Stuck midcast detected: {spell_name} ({action_label})",
        color = 200
    },

    stuck_timing = {
        template = "{yellow}[Watchdog] Cast time: {cast_time}s, Age: {age}s (exceeded timeout)",
        color = 200
    },

    error_in_check = {
        template = "{red}[Watchdog ERROR] Error in check: {error}",
        color = 167
    },

    ---========================================================================
    --- MANUAL CONTROL MESSAGES
    ---========================================================================

    force_clearing = {
        template = "{yellow}[Watchdog] Force-clearing midcast: {spell_name}",
        color = 200
    },

    all_cleared = {
        template = "{green}[Watchdog] All midcast states cleared",
        color = 158
    },

    ---========================================================================
    --- TEST MODE MESSAGES
    ---========================================================================

    test_simulating = {
        template = "{lightblue}[Watchdog TEST] Simulating stuck midcast: {spell_name}",
        color = 207
    },

    test_cast_time = {
        template = "{lightblue}[Watchdog TEST] Cast time: {cast_time}s, Timeout: {timeout}s, Buffer: {buffer}s",
        color = 207
    },

    test_fallback = {
        template = "{lightblue}[Watchdog TEST] Using fallback timeout: {timeout}s",
        color = 207
    },

    test_aftercast_blocked = {
        template = "{yellow}[Watchdog TEST] aftercast will be blocked for 10 seconds...",
        color = 200
    },

    test_started = {
        template = "{green}[Watchdog TEST] Test started - cast a spell within 10 seconds",
        color = 158
    },

    test_deactivated = {
        template = "{green}[Watchdog TEST] Test mode deactivated",
        color = 158
    },

    ---========================================================================
    --- HELP MESSAGE
    ---========================================================================

}

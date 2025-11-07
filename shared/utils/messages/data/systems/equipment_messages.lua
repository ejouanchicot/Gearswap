---============================================================================
--- EQUIPMENT Message Data - Equipment Check Messages
---============================================================================
--- Pure data file for equipment validation messages
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/equipment_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- EQUIPMENT CHECK MESSAGES
    ---========================================================================

    check_header_separator = {
        template = "{lightblue}{separator}",
        color = 122
    },

    check_header_title = {
        template = "{lightblue}    {job_name} EQUIPMENT CHECK",
        color = 122
    },

    set_valid = {
        template = "{green}[OK] {set_path}",
        color = 158
    },

    missing_item = {
        template = "{red}[MISSING] [{slot}] {item_name}",
        color = 167
    },

    missing_item_set = {
        template = "{gray}  Set: {set_path}",
        color = 160
    },

    storage_item = {
        template = "{yellow}[STORAGE] [{slot}] {item_name} - Found in {bag_name}",
        color = 200
    },

    storage_item_set = {
        template = "{gray}  Set: {set_path}",
        color = 160
    },

    summary_separator = {
        template = "{lightblue}{separator}",
        color = 122
    },

    summary_valid_sets = {
        template = "{green}[OK] {valid_sets}/{total_sets} sets complete",
        color = 158
    },

    summary_storage = {
        template = "{yellow}[STORAGE] {storage_count} items need to be retrieved",
        color = 200
    },

    summary_missing = {
        template = "{red}[MISSING] {missing_count} items not found",
        color = 167
    },

    check_error = {
        template = "{red}[ERROR] Failed to check {job_name} equipment: {error_msg}",
        color = 167
    },

    no_sets_found = {
        template = "{yellow}[WARNING] No equipment sets found for {job_name}",
        color = 200
    },

    ---========================================================================
    --- DEBUG MESSAGES
    ---========================================================================

    max_recursion_error = {
        template = "{red}[ERROR] Max recursion depth ({max_depth}) reached at: {path}",
        color = 167
    },

    alias_detected = {
        template = "{gray}[SKIP] Alias detected at: {path} (already visited)",
        color = 160
    },

    scanning = {
        template = "{cyan}[DEBUG] Scanning: {path} (depth: {depth})",
        color = 123
    },

    building_cache = {
        template = "{cyan}[DEBUG] Building item cache...",
        color = 123
    },

    cache_built = {
        template = "{cyan}[DEBUG] Item cache built: {cache_size} entries",
        color = 123
    },

    starting_scan = {
        template = "{cyan}[DEBUG] Starting set scan...",
        color = 123
    },

    scan_complete = {
        template = "{cyan}[DEBUG] Scan complete. Found {set_count} sets",
        color = 123
    },

    cache_build_failed = {
        template = "{red}[ERROR] Failed to build item cache: {error_msg}",
        color = 167
    },

    scan_failed = {
        template = "{red}[ERROR] Set scan failed: {error_msg}",
        color = 167
    },
}

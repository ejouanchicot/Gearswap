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
        template = "{gray}[{green}OK{gray}] {set_path}",
        color = 158
    },

    missing_item = {
        template = "{gray}[{red}MISSING{gray}] [{slot}{gray}] {item_name}",
        color = 167
    },

    missing_item_set = {
        template = "{gray}  Set: {set_path}",
        color = 160
    },

    storage_item = {
        template = "{gray}[{yellow}STORAGE{gray}] [{slot}{gray}] {item_name} - Found in {bag_name}",
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
        template = "{gray}[{green}OK{gray}] {valid_sets}/{total_sets} sets complete",
        color = 158
    },

    summary_storage = {
        template = "{gray}[{yellow}STORAGE{gray}] {storage_count} items need to be retrieved",
        color = 200
    },

    summary_missing = {
        template = "{gray}[{red}MISSING{gray}] {missing_count} items not found",
        color = 167
    },

    check_error = {
        template = "{gray}[{red}ERROR{gray}] Failed to check {job_name} equipment: {error_msg}",
        color = 167
    },

    no_sets_found = {
        template = "{gray}[{yellow}WARNING{gray}] No equipment sets found for {job_name}",
        color = 200
    },

    ---========================================================================
    --- DEBUG MESSAGES
    ---========================================================================

    max_recursion_error = {
        template = "{gray}[{red}ERROR{gray}] Max recursion depth {gray}({max_depth}{gray}) reached at: {path}",
        color = 167
    },

    alias_detected = {
        template = "{gray}[SKIP] Alias detected at: {path} {gray}(already visited{gray})",
        color = 160
    },

    scanning = {
        template = "{gray}[{cyan}DEBUG{gray}] Scanning: {path} {gray}(depth: {depth}{gray})",
        color = 123
    },

    building_cache = {
        template = "{gray}[{cyan}DEBUG{gray}] Building item cache...",
        color = 123
    },

    cache_built = {
        template = "{gray}[{cyan}DEBUG{gray}] Item cache built: {cache_size} entries",
        color = 123
    },

    starting_scan = {
        template = "{gray}[{cyan}DEBUG{gray}] Starting set scan...",
        color = 123
    },

    scan_complete = {
        template = "{gray}[{cyan}DEBUG{gray}] Scan complete. Found {set_count} sets",
        color = 123
    },

    cache_build_failed = {
        template = "{gray}[{red}ERROR{gray}] Failed to build item cache: {error_msg}",
        color = 167
    },

    scan_failed = {
        template = "{gray}[{red}ERROR{gray}] Set scan failed: {error_msg}",
        color = 167
    },
}

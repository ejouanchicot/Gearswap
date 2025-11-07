---============================================================================
--- DATABASE Message Data - Database Load Messages
---============================================================================
--- Pure data file for database loading statistics
--- Used by new message system (api/messages.lua)
---
--- @file data/systems/database_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-06
---============================================================================

return {
    ---========================================================================
    --- LOAD SUMMARY MESSAGES
    ---========================================================================

    load_header_separator = {
        template = "{white}========================================",
        color = 1
    },

    load_header_title = {
        template = "{white}{db_name} - Load Summary",
        color = 1
    },

    total_loaded = {
        template = "{white}Loaded: {count} {item_type}",
        color = 1
    },

    total_loaded_with_expected = {
        template = "{white}Loaded: {loaded} / {expected} {item_type}",
        color = 1
    },

    weapon_type_count = {
        template = "{white}Weapon Types: {count} databases",
        color = 1
    },

    database_count = {
        template = "{white}Databases: {count} total",
        color = 1
    },

    load_date = {
        template = "{white}Load Date: {date}",
        color = 1
    },

    failed_count = {
        template = "{red}Failed Loads: {count}",
        color = 167
    },

    failed_item = {
        template = "{red}  - {file} ({name})",
        color = 167
    },

    separator = {
        template = "{white}========================================",
        color = 1
    },

    ---========================================================================
    --- DATABASE BREAKDOWN MESSAGES
    ---========================================================================

    breakdown_header = {
        template = "{white}Database Breakdown:",
        color = 1
    },

    category_header = {
        template = "{white}{category}:",
        color = 1
    },

    database_entry = {
        template = "{white}  {db_name}: {count} {item_type}",
        color = 1
    },

    weapon_type_entry = {
        template = "{white}  {status} {weapon_type}: {count} WS",
        color = 1
    },
}

---============================================================================
--- Database Message Formatter - Database Load Messages (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_database.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageDatabase = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- LOAD SUMMARY MESSAGES
---============================================================================

--- Show database load summary header
--- @param db_name string Database name (e.g., 'Universal Spell Database', 'Universal WS Database')
function MessageDatabase.show_load_header(db_name)
    M.send('DATABASE', 'load_header_separator')
    M.send('DATABASE', 'load_header_title', {db_name = db_name})
    M.send('DATABASE', 'load_header_separator')
end

--- Show total loaded count
--- @param count number Total items loaded
--- @param item_type string Item type (e.g., 'spells', 'weaponskills', 'abilities')
function MessageDatabase.show_total_loaded(count, item_type)
    M.send('DATABASE', 'total_loaded', {
        count = tostring(count),
        item_type = item_type
    })
end

--- Show total loaded with expected count (for WS database)
--- @param loaded number Total items loaded
--- @param expected number Expected total
--- @param item_type string Item type (e.g., 'weapon skills')
function MessageDatabase.show_total_loaded_with_expected(loaded, expected, item_type)
    M.send('DATABASE', 'total_loaded_with_expected', {
        loaded = tostring(loaded),
        expected = tostring(expected),
        item_type = item_type
    })
end

--- Show weapon type count (for WS database)
--- @param count number Number of weapon types
function MessageDatabase.show_weapon_type_count(count)
    M.send('DATABASE', 'weapon_type_count', {count = tostring(count)})
end

--- Show database count
--- @param count number Number of databases
function MessageDatabase.show_database_count(count)
    M.send('DATABASE', 'database_count', {count = tostring(count)})
end

--- Show load date
--- @param date string Load date
function MessageDatabase.show_load_date(date)
    M.send('DATABASE', 'load_date', {date = date})
end

--- Show failed loads count
--- @param count number Number of failed loads
function MessageDatabase.show_failed_count(count)
    M.send('DATABASE', 'failed_count', {count = tostring(count)})
end

--- Show individual failed load
--- @param file string File name that failed
--- @param name string Database name
function MessageDatabase.show_failed_item(file, name)
    M.send('DATABASE', 'failed_item', {
        file = file,
        name = name
    })
end

--- Show separator
function MessageDatabase.show_separator()
    M.send('DATABASE', 'separator')
end

---============================================================================
--- DATABASE BREAKDOWN MESSAGES
---============================================================================

--- Show breakdown section header
function MessageDatabase.show_breakdown_header()
    M.send('DATABASE', 'breakdown_header')
end

--- Show category header
--- @param category string Category name (e.g., 'Job-Specific', 'Skill-Based')
function MessageDatabase.show_category_header(category)
    M.send('DATABASE', 'category_header', {category = category})
end

--- Show database entry
--- @param db_name string Database name
--- @param count number Item count
--- @param item_type string Item type (e.g., 'spells', 'weaponskills', 'abilities')
function MessageDatabase.show_database_entry(db_name, count, item_type)
    M.send('DATABASE', 'database_entry', {
        db_name = db_name,
        count = tostring(count),
        item_type = item_type
    })
end

--- Show weapon type entry with status (for WS database)
--- @param weapon_type string Weapon type name
--- @param count number Item count
--- @param expected number Expected count
function MessageDatabase.show_weapon_type_entry(weapon_type, count, expected)
    local status = (count == expected) and '✓' or '✗'
    M.send('DATABASE', 'weapon_type_entry', {
        status = status,
        weapon_type = weapon_type,
        count = tostring(count)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageDatabase

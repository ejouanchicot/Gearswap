---============================================================================
--- WAR Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Warrior job.
---
--- Features:
---   • User-customizable key mappings without modifying core job files
---   • State-based keybind organization (Weapon, Combat Modes)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---
--- @file    config/war/WAR_KEYBINDS.lua
--- @author  Morphetrix
--- @version 1.0
--- @date    Created: 2025-09-29
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local WARKeybinds = {}

--- Keybind definitions for WAR job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name" }
WARKeybinds.binds = { -- Weapon Management
{
    key = "!1",
    command = "cycle MainWeapon",
    desc = "Main Weapon",
    state = "MainWeapon"
}, -- Combat Mode Control
{
    key = "!2",
    command = "cycle HybridMode",
    desc = "Hybrid Mode",
    state = "HybridMode"
}}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Apply all keybinds defined in the configuration
--- Validates binds, attempts to bind each key, and displays intro on success.
---
--- @return boolean True if at least one keybind was successfully applied, false otherwise
function WARKeybinds.bind_all()
    -- Validate binds exist
    if not WARKeybinds.binds or #WARKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("WAR")
        return false
    end

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in pairs(WARKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            -- Log specific error if available
            local error_detail = error_msg and tostring(error_msg) or "Command execution failed"
            MessageFormatter.show_bind_failed_error(bind.key, error_detail)
        end
    end

    -- Show intro message if at least one bind succeeded
    if bound_count > 0 then
        WARKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- Safely unbinds all keys defined in the configuration.
---
--- @return boolean True if unbind operations completed, false if no binds defined
function WARKeybinds.unbind_all()
    if not WARKeybinds.binds then
        return false
    end

    for _, bind in pairs(WARKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("WAR keybinds unloaded.")
    return true
end

---============================================================================
--- SYSTEM INTRO & DISPLAY
---============================================================================

--- Display WAR system intro message with macrobook and lockstyle info
--- Attempts to load additional info from WAR_MACROBOOK and WAR_LOCKSTYLE modules.
--- Falls back to basic intro if additional info unavailable.
---
--- @return void
function WARKeybinds.show_intro()
    -- Try to get macro info from WAR_MACROBOOK module
    local macro_info = nil
    local success, WAR_MACROBOOK = pcall(require, 'shared/jobs/war/functions/WAR_MACROBOOK')
    if success and WAR_MACROBOOK and WAR_MACROBOOK.get_war_macro_info then
        macro_info = WAR_MACROBOOK.get_war_macro_info()
    end

    -- Try to get lockstyle info from WAR_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, WAR_LOCKSTYLE = pcall(require, 'shared/jobs/war/functions/WAR_LOCKSTYLE')
    if lockstyle_success and WAR_LOCKSTYLE and WAR_LOCKSTYLE.get_info then
        lockstyle_info = WAR_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("WAR SYSTEM LOADED", WARKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("WAR SYSTEM LOADED", WARKeybinds.binds)
    end
end

--- Display current keybind configuration
--- Formats and displays all configured keybinds in a readable list.
---
--- @return void
function WARKeybinds.show_binds()
    MessageFormatter.show_keybind_list("WAR Keybinds", WARKeybinds.binds)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WARKeybinds

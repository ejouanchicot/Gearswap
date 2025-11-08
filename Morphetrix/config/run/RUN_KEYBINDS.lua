---============================================================================
--- RUN Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Rune Fencer job.
---
--- Features:
---   • User-customizable key mappings without modifying core job files
---   • State-based keybind organization (Weapon, Combat Modes, Subjob-specific)
---   • Subjob filtering (XP mode for RDM, Rune mode for RUN)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---
--- @file    config/run/RUN_KEYBINDS.lua
--- @author  Morphetrix
--- @version 1.0.0
--- @date    Created: 2025-10-03
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local RUNKeybinds = {}

--- Keybind definitions for RUN job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
RUNKeybinds.binds = { -- Hybrid Mode (PDT/MDT)
{
    key = "!1",
    command = "cycle HybridMode",
    desc = "Hybrid Mode",
    state = "HybridMode"
}, -- Weapon Management
{
    key = "!2",
    command = "cycle MainWeapon",
    desc = "Main Weapon",
    state = "MainWeapon"
}, {
    key = "!3",
    command = "cycle SubWeapon",
    desc = "Sub Weapon",
    state = "SubWeapon"
}, -- XP Mode (RUN/RDM subjob only)
{
    key = "!4",
    command = "cycle Xp",
    desc = "XP Mode",
    state = "Xp",
    subjob = "RDM"
}, -- Rune Mode (RUN/RUN subjob only)
{
    key = "!5",
    command = "cycle RuneMode",
    desc = "Rune Mode",
    state = "RuneMode",
    subjob = "RUN"
}}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Get filtered keybinds based on current subjob
--- Filters out subjob-specific binds that don't match current subjob.
---
--- @return table Filtered keybinds appropriate for current subjob
function RUNKeybinds.get_active_binds()
    local active_binds = {}
    local current_subjob = player and player.sub_job or nil

    for _, bind in ipairs(RUNKeybinds.binds) do
        -- Include bind if no subjob requirement, or if subjob matches
        if not bind.subjob or bind.subjob == current_subjob then
            table.insert(active_binds, bind)
        end
    end

    return active_binds
end

--- Apply all keybinds defined in the configuration
--- Validates binds, attempts to bind each key, and displays intro on success.
---
--- @return boolean True if at least one keybind was successfully applied, false otherwise
function RUNKeybinds.bind_all()
    -- Validate binds exist
    if not RUNKeybinds.binds or #RUNKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("RUN")
        return false
    end

    -- Get filtered binds based on current subjob
    local active_binds = RUNKeybinds.get_active_binds()

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in pairs(active_binds) do
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
        RUNKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- Safely unbinds all keys defined in the configuration.
---
--- @return boolean True if unbind operations completed, false if no binds defined
function RUNKeybinds.unbind_all()
    if not RUNKeybinds.binds then
        return false
    end

    for _, bind in pairs(RUNKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("RUN keybinds unloaded.")
    return true
end

---============================================================================
--- SYSTEM INTRO & DISPLAY
---============================================================================

--- Display RUN system intro message with keybinds only
--- Avoids circular dependencies by not requiring RUN_MACROBOOK/RUN_LOCKSTYLE.
---
--- @return void
function RUNKeybinds.show_intro()
    -- Get active binds (filtered by subjob)
    local active_binds = RUNKeybinds.get_active_binds()

    -- Show basic intro (no macro/lockstyle info to avoid circular require)
    MessageFormatter.show_system_intro("RUN SYSTEM LOADED", active_binds)
end

--- Display current keybind configuration
--- Formats and displays all configured keybinds in a readable list.
---
--- @return void
function RUNKeybinds.show_binds()
    MessageFormatter.show_keybind_list("RUN Keybinds", RUNKeybinds.binds)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return RUNKeybinds

---============================================================================
--- PLD Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Paladin job.
---
--- Features:
---   • User-customizable key mappings without modifying core job files
---   • State-based keybind organization (Weapon, Combat Modes, Subjob-specific)
---   • Subjob filtering (XP mode for RDM, Rune mode for RUN)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---
--- @file    config/pld/PLD_KEYBINDS.lua
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

local PLDKeybinds = {}

--- Keybind definitions for PLD job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
PLDKeybinds.binds = { -- Hybrid Mode (PDT/MDT)
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
}, -- XP Mode (PLD/RDM subjob only)
{
    key = "!4",
    command = "cycle Xp",
    desc = "XP Mode",
    state = "Xp",
    subjob = "RDM"
}, -- Rune Mode (PLD/RUN subjob only)
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
function PLDKeybinds.get_active_binds()
    local active_binds = {}
    local current_subjob = player and player.sub_job or nil

    for _, bind in ipairs(PLDKeybinds.binds) do
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
function PLDKeybinds.bind_all()
    -- Validate binds exist
    if not PLDKeybinds.binds or #PLDKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("PLD")
        return false
    end

    -- Get filtered binds based on current subjob
    local active_binds = PLDKeybinds.get_active_binds()

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
        PLDKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- Safely unbinds all keys defined in the configuration.
---
--- @return boolean True if unbind operations completed, false if no binds defined
function PLDKeybinds.unbind_all()
    if not PLDKeybinds.binds then
        return false
    end

    for _, bind in pairs(PLDKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("PLD keybinds unloaded.")
    return true
end

---============================================================================
--- SYSTEM INTRO & DISPLAY
---============================================================================

--- Display PLD system intro message with macrobook and lockstyle info
--- Attempts to load additional info from PLD_MACROBOOK and PLD_LOCKSTYLE modules.
--- Falls back to basic intro if additional info unavailable.
---
--- @return void
function PLDKeybinds.show_intro()
    -- Try to get macro info from PLD_MACROBOOK module
    local macro_info = nil
    local success, PLD_MACROBOOK = pcall(require, 'shared/jobs/pld/functions/PLD_MACROBOOK')
    if success and PLD_MACROBOOK and PLD_MACROBOOK.get_pld_macro_info then
        macro_info = PLD_MACROBOOK.get_pld_macro_info()
    end

    -- Try to get lockstyle info from PLD_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, PLD_LOCKSTYLE = pcall(require, 'shared/jobs/pld/functions/PLD_LOCKSTYLE')
    if lockstyle_success and PLD_LOCKSTYLE and PLD_LOCKSTYLE.get_info then
        lockstyle_info = PLD_LOCKSTYLE.get_info()
    end

    -- Get active binds (filtered by subjob)
    local active_binds = PLDKeybinds.get_active_binds()

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("PLD SYSTEM LOADED", active_binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("PLD SYSTEM LOADED", active_binds)
    end
end

--- Display current keybind configuration
--- Formats and displays all configured keybinds in a readable list.
---
--- @return void
function PLDKeybinds.show_binds()
    MessageFormatter.show_keybind_list("PLD Keybinds", PLDKeybinds.binds)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDKeybinds

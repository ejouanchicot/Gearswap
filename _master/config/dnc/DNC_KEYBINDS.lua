---============================================================================
--- DNC Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Dancer job.
---
--- Features:
---   • User-customizable key mappings without modifying core job files
---   • State-based keybind organization (Weapon, Combat Modes, Steps, Auto-Triggers)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---   • Step management keybinds (Main/Alt/UseAltStep)
---   • Auto-trigger toggles (ClimacticAuto, JumpAuto)
---
--- @file    config/dnc/DNC_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-04
---============================================================================

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local DNCKeybinds = {}

-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions for DNC job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
DNCKeybinds.binds = {
    -- Weapon Management
    { key = "!1", command = "cyclestate MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^1", command = "cyclestate SubWeaponOverride", desc = "Sub Override",  state = "SubWeaponOverride" },

    -- Combat Mode
    { key = "!2", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Step Management
    { key = "!3", command = "cyclestate MainStep", desc = "Main Step",  state = "MainStep" },
    { key = "!4", command = "cyclestate AltStep", desc = "Alt Step",  state = "AltStep" },
    { key = "!5", command = "cyclestate UseAltStep", desc = "Use Alt Step",  state = "UseAltStep" },

    -- Auto-Trigger Controls
    { key = "!6", command = "cyclestate ClimacticAuto", desc = "Climactic Auto",  state = "ClimacticAuto" },
    { key = "!7", command = "cyclestate JumpAuto", desc = "Jump Auto",  state = "JumpAuto" },

    -- Dance Selection
    { key = "!8", command = "cyclestate Dance", desc = "Dance Type",  state = "Dance" },
    { key = "^8", command = "dance", desc = "Activate Dance" },
}

---============================================================================
--- KEYBIND MANAGEMENT FUNCTIONS
---============================================================================

--- Apply all keybinds defined in the configuration
--- @return boolean Success status of binding operation
function DNCKeybinds.bind_all()
    -- Validate binds exist
    if not DNCKeybinds.binds or #DNCKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("DNC")
        return false
    end

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in pairs(DNCKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            -- Log the specific error message if available
            local error_detail = error_msg and tostring(error_msg) or "Command execution failed"
            MessageFormatter.show_bind_failed_error(bind.key, error_detail)
        end
    end

    -- Show intro message if successful
    if bound_count > 0 then
        DNCKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- @return boolean Success status of unbinding operation
function DNCKeybinds.unbind_all()
    if not DNCKeybinds.binds then
        return false
    end

    for _, bind in pairs(DNCKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("DNC keybinds unloaded.")
    return true
end

--- Display DNC system intro message with macrobook and lockstyle info
--- @return void
function DNCKeybinds.show_intro()
    -- Try to get macro info from DNC_MACROBOOK module
    local macro_info = nil
    local success, DNC_MACROBOOK = pcall(require, 'shared/jobs/dnc/functions/DNC_MACROBOOK')
    if success and DNC_MACROBOOK and DNC_MACROBOOK.get_dnc_macro_info then
        macro_info = DNC_MACROBOOK.get_dnc_macro_info()
    end

    -- Try to get lockstyle info from DNC_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, DNC_LOCKSTYLE = pcall(require, 'shared/jobs/dnc/functions/DNC_LOCKSTYLE')
    if lockstyle_success and DNC_LOCKSTYLE and DNC_LOCKSTYLE.get_info then
        lockstyle_info = DNC_LOCKSTYLE.get_info()
    end

    -- Display formatted intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("DNC SYSTEM LOADED", DNCKeybinds.binds, macro_info, lockstyle_info)
    else
        MessageFormatter.show_system_intro("DNC SYSTEM LOADED", DNCKeybinds.binds)
    end
end

return DNCKeybinds

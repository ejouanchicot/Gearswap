---============================================================================
--- THF Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Thief job allowing easy customization
--- without modifying core job files.
---
--- Features:
---   • User-customizable key mappings without touching core job files
---   • State-based keybind organization (Weapon, Combat Modes, TH, Abyssea)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---   • MessageFormatter integration for consistent display
---
--- Keybind Categories:
---   • Weapon Management (Alt+1/2): MainWeapon, SubWeapon
---   • Combat Modes (Alt+3): HybridMode (PDT/Normal)
---   • Treasure Hunter (Alt+4): TreasureMode (Tag/SATA/Full)
---   • Abyssea Proc (Alt+5/6): AbyProc toggle, AbyWeapon cycle
---   • Ranged Lock (Alt+7): RangeLock toggle (On/Off)
---
--- Dependencies:
---   • MessageFormatter (error messages, system intro, keybind display)
---   • THF_MACROBOOK (macro info for intro message)
---   • THF_LOCKSTYLE (lockstyle info for intro message)
---
--- @file    config/thf/THF_KEYBINDS.lua
--- @author  Typioni
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local THFKeybinds = {}

-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions for THF job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
THFKeybinds.binds = {
    -- Weapon Management
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "!2", command = "cycle SubWeapon", desc = "Sub Weapon",  state = "SubWeapon" },

    -- Combat Mode Control
    { key = "!3", command = "cycle HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Treasure Hunter Mode
    { key = "!4", command = "cycle TreasureMode", desc = "TH Mode",  state = "TreasureMode" },

    -- Abyssea Proc Mode (for /WAR subjob)
    { key = "!5", command = "toggle AbyProc", desc = "Aby Proc",  state = "AbyProc", subjob = "WAR" },
    { key = "!6", command = "cycle AbyWeapon", desc = "Aby Weapon",  state = "AbyWeapon", subjob = "WAR" },

    -- Ranged Weapon Lock
    { key = "!7", command = "toggle RangeLock", desc = "Range Lock",  state = "RangeLock" },
}

---============================================================================
--- KEYBIND MANAGEMENT FUNCTIONS
---============================================================================

--- Apply all keybinds defined in the configuration
--- @return boolean Success status of binding operation
function THFKeybinds.bind_all()
    -- Validate binds exist
    if not THFKeybinds.binds or #THFKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("THF")
        return false
    end

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in pairs(THFKeybinds.binds) do
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
        THFKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- @return boolean Success status of unbinding operation
function THFKeybinds.unbind_all()
    if not THFKeybinds.binds then
        return false
    end

    for _, bind in pairs(THFKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("THF keybinds unloaded.")
    return true
end

--- Display THF system intro message with macrobook and lockstyle info
--- @return void
function THFKeybinds.show_intro()
    -- Try to get macro info from THF_MACROBOOK module
    local macro_info = nil
    local success, THF_MACROBOOK = pcall(require, 'shared/jobs/thf/functions/THF_MACROBOOK')
    if success and THF_MACROBOOK and THF_MACROBOOK.get_thf_macro_info then
        macro_info = THF_MACROBOOK.get_thf_macro_info()
    end

    -- Try to get lockstyle info from THF_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, THF_LOCKSTYLE = pcall(require, 'shared/jobs/thf/functions/THF_LOCKSTYLE')
    if lockstyle_success and THF_LOCKSTYLE and THF_LOCKSTYLE.get_info then
        lockstyle_info = THF_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("THF SYSTEM LOADED", THFKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("THF SYSTEM LOADED", THFKeybinds.binds)
    end
end

--- Display current keybind configuration
--- @return void
function THFKeybinds.show_binds()
    MessageFormatter.show_keybind_list("THF Keybinds", THFKeybinds.binds)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return THFKeybinds

---============================================================================
--- COR Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Corsair job allowing easy customization
--- without modifying core job files. Users can modify this file to personalize
--- their key mappings according to their preferences and setup.
---
--- @file config/cor/COR_KEYBINDS.lua
--- @author Typioni
--- @version 1.0
--- @date Created: 2025-10-07
--- @requires Typioni architecture
---============================================================================

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local CORKeybinds = {}

-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions for COR job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
CORKeybinds.binds = {
    -- Weapon Management
    { key = "!1", command = "cycle MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "!2", command = "cycle RangeWeapon", desc = "Range Weapon",  state = "RangeWeapon" },

    -- Quick Draw Element
    { key = "!3", command = "cycle QuickDraw", desc = "Quick Draw Element",  state = "QuickDraw" },

    -- Combat Mode Control
    { key = "!4", command = "cycle HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Rolls (Phantom Roll Selection)
    { key = "!5", command = "cycle MainRoll", desc = "Main Roll",  state = "MainRoll" },
    { key = "!6", command = "cycle SubRoll", desc = "Sub Roll",  state = "SubRoll" },

    -- Luzaf Ring Toggle (affects roll range: ON=16y, OFF=8y)
    { key = "!7", command = "cycle LuzafRing", desc = "Luzaf Ring",  state = "LuzafRing" },
}

---============================================================================
--- KEYBIND MANAGEMENT FUNCTIONS
---============================================================================

--- Apply all keybinds defined in the configuration
--- @return boolean Success status of binding operation
function CORKeybinds.bind_all()
    -- Validate binds exist
    if not CORKeybinds.binds or #CORKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("COR")
        return false
    end

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in pairs(CORKeybinds.binds) do
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
        CORKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- @return boolean Success status of unbinding operation
function CORKeybinds.unbind_all()
    if not CORKeybinds.binds then
        return false
    end

    for _, bind in pairs(CORKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("COR keybinds unloaded.")
    return true
end

--- Display COR system intro message with macrobook and lockstyle info
--- @return void
function CORKeybinds.show_intro()
    -- Try to get macro info from COR_MACROBOOK module
    local macro_info = nil
    local success, COR_MACROBOOK = pcall(require, 'shared/jobs/cor/functions/COR_MACROBOOK')
    if success and COR_MACROBOOK and COR_MACROBOOK.get_cor_macro_info then
        macro_info = COR_MACROBOOK.get_cor_macro_info()
    end

    -- Try to get lockstyle info from COR_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, COR_LOCKSTYLE = pcall(require, 'shared/jobs/cor/functions/COR_LOCKSTYLE')
    if lockstyle_success and COR_LOCKSTYLE and COR_LOCKSTYLE.get_info then
        lockstyle_info = COR_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("COR SYSTEM LOADED", CORKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("COR SYSTEM LOADED", CORKeybinds.binds)
    end
end

--- Display current keybind configuration
--- @return void
function CORKeybinds.show_binds()
    MessageFormatter.show_keybind_list("COR Keybinds", CORKeybinds.binds)
end

return CORKeybinds

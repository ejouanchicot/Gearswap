---============================================================================
--- SAM Keybinds Configuration
---============================================================================
--- Defines keybindings for SAM-specific functions and state cycling.
--- @file SAM_KEYBINDS.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

local SAMKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

SAMKeybinds.binds = {
    -- MainWeapon cycling (Alt+1)
    {
        key = "!1",
        command = "cycle MainWeapon",
        desc = "Main Weapon",
        state = "MainWeapon"
    },

    -- HybridMode cycling (Alt+2)
    {
        key = "!2",
        command = "cycle HybridMode",
        desc = "Hybrid Mode",
        state = "HybridMode"
    },

    -- Lockstyle toggle (Ctrl+[)
    {
        key = "^[",
        command = "input /lockstyle on",
        desc = "Lockstyle On"
    },

    -- Lockstyle off (Alt+[)
    {
        key = "![",
        command = "input /lockstyle off",
        desc = "Lockstyle Off"
    },

    -- Reload (Ctrl+F12)
    {
        key = "^f12",
        command = "reload",
        desc = "Reload GearSwap"
    }
}

---============================================================================
--- KEYBIND FUNCTIONS
---============================================================================

--- Display system intro with keybinds, macro, and lockstyle info
--- Attempts to gather macro and lockstyle information from respective modules.
--- Falls back to basic intro if additional info unavailable.
---
--- @return void
function SAMKeybinds.show_intro()
    local MessageFormatter = require('shared/utils/messages/message_formatter')

    -- Try to get macro info from SAM_MACROBOOK module
    local macro_info = nil
    local success, SAM_MACROBOOK = pcall(require, 'shared/jobs/sam/functions/SAM_MACROBOOK')
    if success and SAM_MACROBOOK and SAM_MACROBOOK.get_sam_macro_info then
        macro_info = SAM_MACROBOOK.get_sam_macro_info()
    end

    -- Try to get lockstyle info from SAM_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, SAM_LOCKSTYLE = pcall(require, 'shared/jobs/sam/functions/SAM_LOCKSTYLE')
    if lockstyle_success and SAM_LOCKSTYLE and SAM_LOCKSTYLE.get_info then
        lockstyle_info = SAM_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("SAM SYSTEM LOADED", SAMKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("SAM SYSTEM LOADED", SAMKeybinds.binds)
    end
end

--- Bind all keybinds
function SAMKeybinds.bind_all()
    for _, bind in pairs(SAMKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if not success then
            add_to_chat(167, '[SAM] Keybind Error: ' .. tostring(error_msg))
        end
    end

    -- Show system intro after binding keybinds
    SAMKeybinds.show_intro()
end

--- Unbind all keybinds
function SAMKeybinds.unbind_all()
    for _, bind in pairs(SAMKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end
    add_to_chat(8, '[SAM] Keybinds unloaded')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return SAMKeybinds

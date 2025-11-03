---============================================================================
--- SAM Keybinds Configuration
---============================================================================
--- Defines keybindings for SAM-specific functions and state cycling.
--- @file SAM_KEYBINDS.lua
--- @author Typioni
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

--- Bind all keybinds
function SAMKeybinds.bind_all()
    for _, bind in pairs(SAMKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if not success then
            add_to_chat(167, '[SAM] Keybind Error: ' .. tostring(error_msg))
        end
    end
    add_to_chat(200, '[SAM] Keybinds loaded')
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

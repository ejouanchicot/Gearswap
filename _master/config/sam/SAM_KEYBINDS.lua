---============================================================================
--- SAM Keybinds Configuration
---============================================================================
--- SAM keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/sam/SAM_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2025-10-21 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local SAMKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================
SAMKeybinds.binds = {
    -- MainWeapon cycling (Ctrl+Numpad1)
    {
        key = "^numpad1",
        command = "cyclestate MainWeapon",
        desc = "Main Weapon",
        state = "MainWeapon"
    },

    -- OffenseMode cycling (Ctrl+Numpad2): engaged accuracy
    {
        key = "^numpad2",
        command = "cyclestate OffenseMode",
        desc = "Offense Mode",
        state = "OffenseMode"
    },

    -- WeaponskillMode cycling (Ctrl+Numpad3): weaponskill accuracy
    {
        key = "^numpad3",
        command = "cyclestate WeaponskillMode",
        desc = "WS Mode",
        state = "WeaponskillMode"
    },

    -- HybridMode cycling (Ctrl+Numpad9)
    {
        key = "^numpad9",
        command = "cyclestate HybridMode",
        desc = "Hybrid Mode",
        state = "HybridMode"
    },
}

return require('shared/utils/keybinds/keybind_manager').create('SAM', SAMKeybinds)

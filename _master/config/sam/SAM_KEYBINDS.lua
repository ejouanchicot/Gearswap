---============================================================================
--- SAM Keybinds Configuration
---============================================================================
--- SAM keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/sam/SAM_KEYBINDS.lua
--- @author  Tetsouo
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

    -- HybridMode cycling (Ctrl+Numpad9)
    {
        key = "^numpad9",
        command = "cyclestate HybridMode",
        desc = "Hybrid Mode",
        state = "HybridMode"
    },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

return require('shared/utils/keybinds/keybind_manager').create('SAM', SAMKeybinds)

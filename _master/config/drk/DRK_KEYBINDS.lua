---============================================================================
--- DRK Keybind Configuration
---============================================================================
--- DRK keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/drk/DRK_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-23 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local DRKKeybinds = {}

--- Keybind definitions for DRK job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name" }
DRKKeybinds.binds = {
    -- Hybrid Mode (PDT/Normal)
    {
        key = "^numpad9",
        command = "cyclestate HybridMode",
        desc = "Hybrid Mode",
        state = "HybridMode"
    },
    -- Weapon Management
    {
        key = "^numpad1",
        command = "cyclestate MainWeapon",
        desc = "Main Weapon",
        state = "MainWeapon"
    },
}

return require('shared/utils/keybinds/keybind_manager').create('DRK', DRKKeybinds)

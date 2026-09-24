---============================================================================
--- THF Keybind Configuration
---============================================================================
--- THF keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/thf/THF_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-06 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local THFKeybinds = {}

-- Keybind definitions for THF job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
THFKeybinds.binds = {
    -- Weapon Management
    { key = "^numpad1", command = "cyclestate MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon", desc = "Sub Weapon",  state = "SubWeapon" },

    -- Combat Mode Control
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Treasure Hunter Mode
    { key = "^numpad3", command = "cyclestate TreasureMode", desc = "TH Mode",  state = "TreasureMode" },

    -- Abyssea Proc Mode (for /WAR subjob)
    { key = "^numpad4", command = "toggle AbyProc", desc = "Aby Proc",  state = "AbyProc", subjob = "WAR" },
    { key = "^numpad5", command = "cyclestate AbyWeapon", desc = "Aby Weapon",  state = "AbyWeapon", subjob = "WAR" },

    -- Ranged Weapon Lock
    { key = "^numpad6", command = "toggle RangeLock", desc = "Range Lock",  state = "RangeLock" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

return require('shared/utils/keybinds/keybind_manager').create('THF', THFKeybinds)

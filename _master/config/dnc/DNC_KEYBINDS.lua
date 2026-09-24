---============================================================================
--- DNC Keybind Configuration
---============================================================================
--- DNC keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/dnc/DNC_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-04 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local DNCKeybinds = {}

-- Keybind definitions for DNC job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
DNCKeybinds.binds = {
    -- Weapon Management
    { key = "^numpad1", command = "cyclestate MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeaponOverride", desc = "Sub Override",  state = "SubWeaponOverride" },

    -- Combat Mode
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Step Management
    { key = "^numpad3", command = "cyclestate MainStep", desc = "Main Step",  state = "MainStep" },
    { key = "^numpad4", command = "cyclestate AltStep", desc = "Alt Step",  state = "AltStep" },
    { key = "^numpad5", command = "cyclestate UseAltStep", desc = "Use Alt Step",  state = "UseAltStep" },

    -- Auto-Trigger Controls
    { key = "^numpad6", command = "cyclestate ClimacticAuto", desc = "Climactic Auto",  state = "ClimacticAuto" },
    { key = "^numpad7", command = "cyclestate JumpAuto", desc = "Jump Auto",  state = "JumpAuto" },

    -- Dance Selection
    { key = "^numpad8", command = "cyclestate Dance", desc = "Dance Type",  state = "Dance" },

    -- Samba Selection
    { key = "^numpad0", command = "cyclestate Samba", desc = "Samba Type",  state = "Samba" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

return require('shared/utils/keybinds/keybind_manager').create('DNC', DNCKeybinds)

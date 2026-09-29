---============================================================================
--- DRG Keybind Configuration
---============================================================================
--- DRG keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua (weapon = 'Polearm' binds a key only while the main
--- hand is a polearm, for per-weapon weaponskill keys).
---
--- Layout: ^numpad1 / ^numpad2 weapons, ^numpad3 Offense Mode (DRG has no
--- signature state), ^numpad9 Hybrid Mode (fixed anchor on every job).
---
--- @file    config/drg/DRG_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local DRGKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
DRGKeybinds.binds = {
    -- Weapons
    { key = "^numpad1", command = "cyclestate MainWeapon",      desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon",       desc = "Sub Weapon",   state = "SubWeapon" },

    -- Modes
    { key = "^numpad3", command = "cyclestate OffenseMode",     desc = "Offense Mode", state = "OffenseMode" },
    { key = "^numpad4", command = "cyclestate WeaponskillMode", desc = "WS Mode",      state = "WeaponskillMode" },
    { key = "^numpad9", command = "cyclestate HybridMode",      desc = "Hybrid Mode",  state = "HybridMode" },

    -- Per-weapon weaponskill key: example, remove the "--" to use it
    -- { key = "numpad3", command = '/ws "Camlann\'s Torment" <t>', desc = "Camlann's Torment", weapon = "Polearm" },
}

return require('shared/utils/keybinds/keybind_manager').create('DRG', DRGKeybinds)

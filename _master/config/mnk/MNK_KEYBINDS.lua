---============================================================================
--- MNK Keybind Configuration
---============================================================================
--- MNK keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua (weapon = 'Hand-to-Hand' binds a key only while the
--- main hand is of that type, for per-weapon weaponskill keys).
---
--- Monk has no sub weapon, so ^numpad2 carries the WS Mode.
---
--- @file    config/mnk/MNK_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local MNKKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
MNKKeybinds.binds = {
    -- Weapon
    { key = "^numpad1", command = "cyclestate MainWeapon",      desc = "Main Weapon",  state = "MainWeapon" },

    -- Modes
    { key = "^numpad2", command = "cyclestate WeaponskillMode", desc = "WS Mode",      state = "WeaponskillMode" },
    { key = "^numpad3", command = "cyclestate OffenseMode",     desc = "Offense Mode", state = "OffenseMode" },
    { key = "^numpad9", command = "cyclestate HybridMode",      desc = "Hybrid Mode",  state = "HybridMode" },

    -- Per-weapon weaponskill key: example, remove the "--" to use it
    -- { key = "numpad3", command = '/ws "Victory Smite" <t>', desc = "Victory Smite", weapon = "Hand-to-Hand" },
}

return require('shared/utils/keybinds/keybind_manager').create('MNK', MNKKeybinds)

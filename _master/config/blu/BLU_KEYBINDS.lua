---============================================================================
--- BLU Keybind Configuration
---============================================================================
--- BLU keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua (weapon = 'Sword' binds a key only while the main
--- hand is a sword, for per-weapon weaponskill keys).
---
--- @file    config/blu/BLU_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

local BLUKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
BLUKeybinds.binds = {
    -- Weapons
    { key = "^numpad1", command = "cyclestate MainWeapon",      desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon",       desc = "Sub Weapon",   state = "SubWeapon" },

    -- Modes
    { key = "^numpad3", command = "cyclestate OffenseMode",     desc = "Offense Mode", state = "OffenseMode" },
    { key = "^numpad4", command = "cyclestate IdleMode",        desc = "Idle Mode",    state = "IdleMode" },
    { key = "^numpad5", command = "cyclestate CastingMode",     desc = "Casting Mode", state = "CastingMode" },
    { key = "^numpad6", command = "cyclestate WeaponskillMode", desc = "WS Mode",      state = "WeaponskillMode" },

    -- Per-weapon weaponskill keys: examples, remove the "--" to use them
    -- { key = "numpad3", command = '/ws "Savage Blade" <t>', desc = "Savage Blade", weapon = "Sword" },
    -- { key = "numpad3", command = '/ws "Black Halo" <t>',   desc = "Black Halo",   weapon = "Club" },
}

return require('shared/utils/keybinds/keybind_manager').create('BLU', BLUKeybinds)

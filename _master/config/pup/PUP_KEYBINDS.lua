---============================================================================
--- PUP Keybind Configuration
---============================================================================
--- PUP keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua (weapon = 'Hand-to-Hand' binds a key only while the
--- main hand is of that type, for per-weapon weaponskill keys).
---
--- Pet WS carries section = 'mode': its name holds "WS", which would put the
--- row with the weaponskill slots otherwise.
---
--- @file    config/pup/PUP_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-29
---============================================================================

local PUPKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
PUPKeybinds.binds = {
    -- Weapon
    { key = "^numpad1", command = "cyclestate MainWeapon",  desc = "Main Weapon",  state = "MainWeapon" },

    -- Master modes
    { key = "^numpad2", command = "cyclestate OffenseMode", desc = "Offense Mode", state = "OffenseMode" },
    { key = "^numpad3", command = "cyclestate HybridMode",  desc = "Hybrid Mode",  state = "HybridMode" },

    -- Automaton
    { key = "^numpad4", command = "cyclestate PetMode",     desc = "Pet Mode",     state = "PetMode" },
    { key = "^numpad5", command = "cyclestate PetWS",       desc = "Pet WS",       state = "PetWS", section = "mode" },

    -- Per-weapon weaponskill key: example, remove the "--" to use it
    -- { key = "numpad3", command = '/ws "Victory Smite" <t>', desc = "Victory Smite", weapon = "Hand-to-Hand" },
}

return require('shared/utils/keybinds/keybind_manager').create('PUP', PUPKeybinds)

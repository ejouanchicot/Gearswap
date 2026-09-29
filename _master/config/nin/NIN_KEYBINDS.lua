---============================================================================
--- NIN Keybind Configuration
---============================================================================
--- NIN keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua (weapon = 'Katana' binds a key only while the main
--- hand is a katana, for per-weapon weaponskill keys).
---
--- Layout (.claude/rules/keybinds.md): ^numpad1/2 weapons, ^numpad3 the
--- job's signature state (Magic Burst), ^numpad9 Hybrid Mode.
---
--- @file    config/nin/NIN_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local NINKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
NINKeybinds.binds = {
    -- Weapons
    { key = "^numpad1", command = "cyclestate MainWeapon",      desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon",       desc = "Sub Weapon",   state = "SubWeapon" },

    -- Signature: elemental ninjutsu burst gear
    { key = "^numpad3", command = "cyclestate MagicBurstMode",  desc = "Magic Burst",  state = "MagicBurstMode" },

    -- Modes
    { key = "^numpad4", command = "cyclestate OffenseMode",     desc = "Offense Mode", state = "OffenseMode" },
    { key = "^numpad5", command = "cyclestate WeaponskillMode", desc = "WS Mode",      state = "WeaponskillMode" },
    { key = "^numpad9", command = "cyclestate HybridMode",      desc = "Hybrid Mode",  state = "HybridMode" },

    -- Per-weapon weaponskill keys: examples, remove the "--" to use them
    -- { key = "!numpad1", command = '/ws "Blade: Hi" <t>',     desc = "Blade: Hi",     weapon = "Katana" },
    -- { key = "!numpad1", command = '/ws "Savage Blade" <t>',  desc = "Savage Blade",  weapon = "Sword" },
}

return require('shared/utils/keybinds/keybind_manager').create('NIN', NINKeybinds)

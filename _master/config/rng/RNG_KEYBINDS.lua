---============================================================================
--- RNG Keybind Configuration
---============================================================================
--- RNG keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua (weapon = 'Sword' binds a key only while the MAIN
--- hand is a sword; the range slot is not read for that filter).
---
--- Layout (.claude/rules/keybinds.md): ^numpad1 main weapon, ^numpad2 the
--- range weapon (the ranger's weapon), ^numpad3 Ranged Mode (the signature
--- mode), ^numpad9 Hybrid Mode, the rest from ^numpad4 up.
---
--- @file    config/rng/RNG_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local RNGKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
RNGKeybinds.binds = {
    -- Weapons
    { key = "^numpad1", command = "cyclestate MainWeapon",      desc = "Main Weapon",   state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate RangeWeapon",     desc = "Range Weapon",  state = "RangeWeapon" },

    -- Signature: ranged attack gear (sets.precast.RA / sets.midcast.RA [.Acc])
    { key = "^numpad3", command = "cyclestate RangedMode",      desc = "Ranged Mode",   state = "RangedMode" },

    -- Modes
    { key = "^numpad9", command = "cyclestate HybridMode",      desc = "Hybrid Mode",   state = "HybridMode" },
    { key = "^numpad4", command = "cyclestate SubWeapon",       desc = "Sub Weapon",    state = "SubWeapon" },
    { key = "^numpad5", command = "cyclestate OffenseMode",     desc = "Offense Mode",  state = "OffenseMode" },
    { key = "^numpad6", command = "cyclestate WeaponskillMode", desc = "WS Mode",       state = "WeaponskillMode" },

    -- Weaponskill keys: examples, remove the "--" to use them
    -- { key = "!numpad1", command = '/ws "Last Stand" <t>',   desc = "Last Stand" },
    -- { key = "!numpad2", command = '/ws "Trueflight" <t>',   desc = "Trueflight" },
    -- { key = "!numpad3", command = '/ws "Savage Blade" <t>', desc = "Savage Blade", weapon = "Sword" },
}

return require('shared/utils/keybinds/keybind_manager').create('RNG', RNGKeybinds)

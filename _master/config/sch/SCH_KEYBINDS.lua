---============================================================================
--- SCH Keybind Configuration
---============================================================================
--- SCH keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- Ctrl = modes (1-2 weapons, 3 the signature mode, 9 Hybrid Mode, as on the
--- other jobs); Apps = actions (Arts, and the spells of the Element mode).
--- Element and Nuke Tier carry section = 'spell' so the HUD shows them with
--- the spells. The action keys have no mode: they are bound, not shown.
---
--- @file    config/sch/SCH_KEYBINDS.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local SCHKeybinds = {}

-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
SCHKeybinds.binds = {
    -- Weapons
    { key = "^numpad1", command = "cyclestate MainWeapon",     desc = "Main Weapon",    state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon",      desc = "Sub Weapon",     state = "SubWeapon" },

    -- Magic
    { key = "^numpad3", command = "cyclestate Element",        desc = "Element",        state = "Element", section = "spell" },
    { key = "^numpad4", command = "cyclestate NukeTier",       desc = "Nuke Tier",      state = "NukeTier", section = "spell" },
    { key = "^numpad5", command = "cyclestate MagicBurstMode", desc = "Magic Burst",    state = "MagicBurstMode" },
    { key = "^numpad7", command = "cyclestate SneakInviAOE",   desc = "Sneak/Invi AOE", state = "SneakInviAOE" },

    -- Modes
    { key = "^numpad6", command = "cyclestate OffenseMode",    desc = "Offense Mode",   state = "OffenseMode" },
    { key = "^numpad8", command = "cyclestate CombatMode",     desc = "Combat Mode",    state = "CombatMode" },
    { key = "^numpad9", command = "cyclestate HybridMode",     desc = "Hybrid Mode",    state = "HybridMode" },

    -- Actions (//gs c <command>, see SCH_COMMANDS.lua)
    { key = "#numpad1", command = "lightarts", desc = "Light Arts / Addendum" },
    { key = "#numpad2", command = "darkarts",  desc = "Dark Arts / Addendum" },
    { key = "#numpad3", command = "nuke",      desc = "Nuke (Element)" },
    { key = "#numpad4", command = "helix",     desc = "Helix (Element)" },
    { key = "#numpad5", command = "storm",     desc = "Storm (Element)" },
}

return require('shared/utils/keybinds/keybind_manager').create('SCH', SCHKeybinds)

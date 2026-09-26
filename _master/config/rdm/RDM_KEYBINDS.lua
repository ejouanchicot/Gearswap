---============================================================================
--- RDM Keybind Configuration
---============================================================================
--- RDM keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/rdm/RDM_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-12 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local RDMKeybinds = {}

-- Keybind definitions - numpad only (Ctrl+Numpad, Apps+Numpad for Storm; AutoMedicine is in config/COMMON_KEYBINDS.lua)
-- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
RDMKeybinds.binds = {
    ---========================================================================
    --- CTRL+NUMPAD DIGITS (States)
    ---========================================================================

    -- Weapon & Combat States
    { key = "^numpad1", command = "cyclestate MainWeapon",     desc = "Main Weapon",     state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon",      desc = "Sub Weapon",      state = "SubWeapon" },
    { key = "^numpad6", command = "cyclestate EngagedMode",    desc = "Engaged Mode",    state = "EngagedMode" },
    { key = "^numpad4", command = "cyclestate IdleMode",       desc = "Idle Mode",       state = "IdleMode" },
    { key = "^numpad5", command = "cyclestate CombatMode",     desc = "Combat Mode",     state = "CombatMode" },

    -- Magic States
    { key = "^numpad3", command = "cyclestate EnfeebleMode",   desc = "Enfeeble Mode",   state = "EnfeebleMode" },
    { key = "^numpad7", command = "cyclestate NukeMode",       desc = "Nuke Mode",       state = "NukeMode" },
    { key = "^numpad0", command = "cyclestate SaboteurMode",   desc = "Saboteur Mode",   state = "SaboteurMode" },
    { key = "^numpad9", command = "cyclestate EnfeebleTier", desc = "Enfeeble Tier", state = "EnfeebleTier" },
    { key = "^numpad8", command = "cyclestate NukeTier",       desc = "Nuke Tier",       state = "NukeTier" },
    { key = "#numpad1", command = "cyclestate Storm",          desc = "Storm (SCH)",     state = "Storm",    subjob = "SCH" },

    ---========================================================================
    --- CTRL+NUMPAD OPERATORS (Enhancement States)
    ---========================================================================

    -- Enhancement Spell Selection
    { key = "^numpad.", command = "cyclestate EnSpell",       desc = "Enspell",         state = "EnSpell" },
    { key = "^numpad+", command = "cyclestate GainSpell",     desc = "Gain Spell",      state = "GainSpell" },
    { key = "^numpad-", command = "cyclestate Barspell",      desc = "Bar Element",     state = "Barspell" },
    { key = "^numpad*", command = "cyclestate BarAilment",    desc = "Bar Ailment",     state = "BarAilment" },
    { key = "^numpad/", command = "cyclestate Spike",         desc = "Spike",           state = "Spike" },
}

return require('shared/utils/keybinds/keybind_manager').create('RDM', RDMKeybinds)

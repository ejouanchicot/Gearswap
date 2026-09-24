---============================================================================
--- PLD Keybind Configuration
---============================================================================
--- PLD keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    Kaories/config/pld/PLD_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-03 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local PLDKeybinds = {}

--- Keybind definitions for PLD job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
PLDKeybinds.binds = { -- Hybrid Mode (PDT/MDT/Sortie)
{
    key = "^numpad9",
    command = "cyclestate HybridMode",
    desc = "Hybrid Mode",
    state = "HybridMode"
}, -- Weapon Management
{
    key = "^numpad1",
    command = "cyclestate MainWeapon",
    desc = "Main Weapon",
    state = "MainWeapon"
}, -- XP Mode (PLD/RDM subjob only)
{
    key = "^numpad4",
    command = "cyclestate Xp",
    desc = "XP Mode",
    state = "Xp",
    subjob = "RDM"
}, -- Rune Mode (PLD/RUN subjob only)
{
    key = "^numpad3",
    command = "cyclestate RuneMode",
    desc = "Rune Mode",
    state = "RuneMode",
    subjob = "RUN"
},
    { key = "^numpad2", command = "cyclestate PhalanxSIRD", desc = "Phalanx SIRD", state = "PhalanxSIRD" },
    { key = "^numpad7", command = "cyclestate SneakInviAOE", desc = "Sneak/Invi AOE", state = "SneakInviAOE", subjob = "SCH" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

return require('shared/utils/keybinds/keybind_manager').create('PLD', PLDKeybinds)

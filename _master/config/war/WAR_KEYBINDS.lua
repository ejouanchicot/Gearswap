---============================================================================
--- WAR Keybind Configuration
---============================================================================
--- WAR keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/war/WAR_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-09-29 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local WARKeybinds = {}

--- Keybind definitions for WAR job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name" }
WARKeybinds.binds = { -- Weapon Management
{
    key = "^numpad1",
    command = "cyclestate MainWeapon",
    desc = "Main Weapon",
    state = "MainWeapon"
}, -- Combat Mode Control
{
    key = "^numpad9",
    command = "cyclestate HybridMode",
    desc = "Hybrid Mode",
    state = "HybridMode"
},
{
    key = "^numpad2",
    command = "cyclestate JumpAuto",
    desc = "Jump Auto",
    state = "JumpAuto"
},
{
    key = "^numpad3",
    command = "cyclestate WS1",
    desc = "WS Slot 1",
    state = "WS1"
},
{
    key = "^numpad4",
    command = "cyclestate WS2",
    desc = "WS Slot 2",
    state = "WS2"
},
{
    key = "^numpad5",
    command = "cyclestate WS3",
    desc = "WS Slot 3",
    state = "WS3"
},
{
    key = "^numpad6",
    command = "cyclestate WS4",
    desc = "WS Slot 4",
    state = "WS4"
},
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
{
    key = "^numpad7",
    command = "cyclestate WS5",
    desc = "WS Slot 5",
    state = "WS5"
}}

return require('shared/utils/keybinds/keybind_manager').create('WAR', WARKeybinds)

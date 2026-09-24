---============================================================================
--- RUN Keybind Configuration
---============================================================================
--- RUN keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/run/RUN_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-03 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local RUNKeybinds = {}

--- Keybind definitions for RUN job
--- Format: { key = "key_combo", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
RUNKeybinds.binds = { -- Hybrid Mode (PDT/MDT)
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
}, {
    key = "^numpad2",
    command = "cyclestate SubWeapon",
    desc = "Sub Weapon",
    state = "SubWeapon"
}, -- Rune Mode (RUN main job - always available)
{
    key = "^numpad3",
    command = "cyclestate RuneMode",
    desc = "Rune Mode",
    state = "RuneMode"
    -- No subjob filter - RuneMode is core RUN functionality
},
}

return require('shared/utils/keybinds/keybind_manager').create('RUN', RUNKeybinds)

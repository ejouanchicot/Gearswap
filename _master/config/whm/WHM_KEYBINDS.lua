---============================================================================
--- WHM Keybind Configuration
---============================================================================
--- WHM keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/whm/WHM_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-21 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local WHMKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

--- Keybind table - defines all keyboard shortcuts for WHM
--- Format: {key = "bind_string", command = "gs_command", desc = "UI_description", state = "state_name"}
WHMKeybinds.binds = {
    -- CureMode cycling (Ctrl+Numpad3)
    {
        key = "^numpad3",
        command = "cyclestate CureMode",
        desc = "Cure Mode",
        state = "CureMode"
    },

    -- IdleMode cycling (Ctrl+Numpad1)
    {
        key = "^numpad1",
        command = "cyclestate IdleMode",
        desc = "Idle Mode",
        state = "IdleMode"
    },

    -- AfflatusMode cycling (Ctrl+Numpad5)
    {
        key = "^numpad5",
        command = "cyclestate AfflatusMode",
        desc = "Afflatus Mode",
        state = "AfflatusMode"
    },

    -- CureAutoTier cycling (Ctrl+Numpad4)
    {
        key = "^numpad4",
        command = "cyclestate CureAutoTier",
        desc = "Cure Auto-Tier",
        state = "CureAutoTier"
    },

    -- CombatMode cycling (Ctrl+Numpad2) - Weapon lock control
    {
        key = "^numpad2",
        command = "cyclestate CombatMode",
        desc = "Combat Mode",
        state = "CombatMode"
    },

    -- CastingMode cycling (Ctrl+Numpad6)
    {
        key = "^numpad6",
        command = "cyclestate CastingMode",
        desc = "Casting Mode",
        state = "CastingMode"
    },

    -- Additional keybinds can be added here:
    -- Examples:
    --   • Auto-Devotion toggle
    --   • Auto-Divine Seal toggle
    --   • Quick Cursna macro
}

return require('shared/utils/keybinds/keybind_manager').create('WHM', WHMKeybinds)

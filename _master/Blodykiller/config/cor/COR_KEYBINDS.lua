---============================================================================
--- COR Keybinds - Blodykiller (template keys + his Bolter's Roll)
---============================================================================
--- COR keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/cor/COR_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-07 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local CORKeybinds = {}

-- Keybind definitions for COR job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name" }
CORKeybinds.binds = {
    -- Weapon Management
    { key = "^numpad1", command = "cyclestate MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate RangeWeapon", desc = "Range Weapon",  state = "RangeWeapon" },

    -- Quick Draw Element
    { key = "^numpad3", command = "cyclestate QuickDraw", desc = "Quick Draw Element",  state = "QuickDraw" },

    -- Combat Mode Control
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Rolls (Phantom Roll Selection)
    { key = "^numpad4", command = "cyclestate MainRoll", desc = "Main Roll",  state = "MainRoll" },
    { key = "^numpad5", command = "cyclestate SubRoll", desc = "Sub Roll",  state = "SubRoll" },

    -- Luzaf Ring Toggle (affects roll range: ON=16y, OFF=8y)
    { key = "^numpad6", command = "cyclestate LuzafRing", desc = "Luzaf Ring",  state = "LuzafRing" },

    -- Alt+F9: Ranged Mode (his BindManager login key, Mote's default)
    { key = "!f9", command = "cyclestate RangedMode", desc = "Ranged Mode", state = "RangedMode" },

    -- Blody's own key (BindManager jobs.main_jobs.COR: "boltersroll")
    { key = "!`", command = "boltersroll", raw = true, desc = "Bolter's Roll" },
}

return require('shared/utils/keybinds/keybind_manager').create('COR', CORKeybinds)

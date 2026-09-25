---============================================================================
--- BST Keybind Configuration
---============================================================================
--- BST keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/bst/BST_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-17 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local BSTKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS (DUAL SYSTEM)
---============================================================================

--- Keybinds table
--- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
---
--- DUAL SYSTEM EXPLANATION:
--- • "cyclestate <State>" entries cycle a Mote state
--- • "ecosystem" / "species" call BST commands directly; their state field
---   only tells the HUD which value to show
BSTKeybinds.binds = {
    ---==========================================================================
    --- WEAPON MANAGEMENT (Ctrl+Numpad)
    ---==========================================================================
    { key = "^numpad1", command = "cyclestate WeaponSet", desc = "Main Weapon", state = "WeaponSet" },
    { key = "^numpad2", command = "cyclestate SubSet", desc = "Sub/Shield", state = "SubSet" },

    ---==========================================================================
    --- COMBAT MODES (Ctrl+Numpad)
    ---==========================================================================
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
    { key = "^numpad4", command = "cyclestate AutoPetEngage", desc = "Auto Pet Engage", state = "AutoPetEngage" },
    { key = "^numpad3", command = "cyclestate PetIdleMode", desc = "Pet Idle Mode", state = "PetIdleMode" },

    ---==========================================================================
    --- ECOSYSTEM/SPECIES MANAGEMENT (Ctrl+Numpad - BST commands)
    ---==========================================================================
    { key = "^numpad5", command = "ecosystem", desc = "Cycle Ecosystem", state = "Ecosystem" },
    { key = "^numpad6", command = "species", desc = "Cycle Species", state = "species" },
}

return require('shared/utils/keybinds/keybind_manager').create('BST', BSTKeybinds)

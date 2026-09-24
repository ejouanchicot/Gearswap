---============================================================================
--- GEO Keybind Configuration
---============================================================================
--- Geomancer keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them.
--- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
---
--- @file config/geo/GEO_KEYBINDS.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-09 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local GEOKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

--- Keybind list with key, command, description, and state
--- Key format: ! = Alt, ^ = Ctrl, @ = Windows, # = Apps, ~ = Shift
GEOKeybinds.binds = {
    ---========================================================================
    --- GEOCOLURE & INDICOLURE
    ---========================================================================

    -- Cycle Spells
    { key = "^numpad3", command = "cyclestate MainIndi", desc = "Main Indi", state = "MainIndi" },
    { key = "^numpad4", command = "cyclestate MainGeo", desc = "Main Geo", state = "MainGeo" },

    ---========================================================================
    --- ELEMENTAL SPELLS
    ---========================================================================

    -- Elemental Spells (Light then Dark)
    { key = "^numpad5", command = "cyclestate MainLightSpell", desc = "Light Spell", state = "MainLightSpell" },
    { key = "^numpad6", command = "cyclestate MainDarkSpell", desc = "Dark Spell", state = "MainDarkSpell" },

    -- Spell Tier (V, IV, III, II, I)
    { key = "^numpad1", command = "cyclestate SpellTier", desc = "Spell Tier", state = "SpellTier" },

    -- AOE Spells (Light then Dark)
    { key = "^numpad7", command = "cyclestate MainLightAOE", desc = "Light AOE", state = "MainLightAOE" },
    { key = "^numpad8", command = "cyclestate MainDarkAOE", desc = "Dark AOE", state = "MainDarkAOE" },

    -- AOE Tier (III, II, I)
    { key = "^numpad2", command = "cyclestate AOETier", desc = "AOE Tier", state = "AOETier" },

    -- Combat Modes
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },
    { key = "^numpad0", command = "cyclestate CombatMode", desc = "Combat Mode",  state = "CombatMode" },
    { key = "^numpad.", command = "cyclestate LuopanMode", desc = "Luopan Mode",  state = "LuopanMode" },

    -- Indicolure Mode (Self vs Entrust)
    { key = "^numpad+", command = "cyclestate IndicolureMode", desc = "Indi Mode", state = "IndicolureMode" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

return require('shared/utils/keybinds/keybind_manager').create('GEO', GEOKeybinds)

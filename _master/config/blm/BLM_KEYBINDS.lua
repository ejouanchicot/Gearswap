---============================================================================
--- BLM Keybind Configuration
---============================================================================
--- BLM keys. Data only: KeybindManager (shared/utils/keybinds) binds,
--- filters, refreshes and unbinds them. Entry fields are listed in
--- keybind_manager.lua.
---
--- @file    config/blm/BLM_KEYBINDS.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-10-15 | Updated: 2026-09-24 (KeybindManager)
---============================================================================

local BLMKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

--- Keybind list with key, command, description, and state
--- Key format: ! = Alt, ^ = Ctrl, @ = Windows, # = Apps, ~ = Shift
--- Numpad only, always with a modifier so the bare numpad stays free for the
--- game and for addons that inject numpad presses (Silmaril hover, follow
--- macros). The modifier carries the meaning:
---
--- Ctrl is the primary bank and is filled first; Apps takes the overflow.
---
--- Ctrl 3 and Ctrl 9 follow the project-wide layout (signature mechanic and
--- HybridMode). Ctrl 1-2 hold weapons on jobs that have them; BLM binds no
--- weapon, so the tiers take those slots.
---
---   Ctrl  = Main side          Apps = Sub side
---   Ctrl+3 Main Light          Apps+3 Sub Light
---   Ctrl+4 Main Dark           Apps+4 Sub Dark
---   Ctrl+5 Main Light AOE      Apps+5 Sub Light AOE
---   Ctrl+6 Main Dark AOE       Apps+6 Sub Dark AOE
---
--- The same digit is always the same spell family; the modifier picks Main or
--- Sub. Ctrl 7-8 and 0 hold Storm, Combat and MB modes; Apps 7-9 and 0 the
--- remaining toggles.
BLMKeybinds.binds = {
    -- Main / Sub Elemental Spells (same digit, Ctrl = Main, Apps = Sub)
    { key = "^numpad3", command = "cyclestate MainLightSpell", desc = "Main Light", state = "MainLightSpell" },
    { key = "#numpad3", command = "cyclestate SubLightSpell", desc = "Sub Light", state = "SubLightSpell" },
    { key = "^numpad4", command = "cyclestate MainDarkSpell", desc = "Main Dark", state = "MainDarkSpell" },
    { key = "#numpad4", command = "cyclestate SubDarkSpell", desc = "Sub Dark", state = "SubDarkSpell" },

    -- Main / Sub AOE Spells
    { key = "^numpad5", command = "cyclestate MainLightAOE", desc = "Main Light AOE", state = "MainLightAOE" },
    { key = "#numpad5", command = "cyclestate SubLightAOE", desc = "Sub Light AOE", state = "SubLightAOE" },
    { key = "^numpad6", command = "cyclestate MainDarkAOE", desc = "Main Dark AOE", state = "MainDarkAOE" },
    { key = "#numpad6", command = "cyclestate SubDarkAOE", desc = "Sub Dark AOE", state = "SubDarkAOE" },

    -- Tiers (shared by Main and Sub)
    { key = "^numpad1", command = "cyclestate SpellTier", desc = "Spell Tier", state = "SpellTier" },
    { key = "^numpad2", command = "cyclestate AOETier", desc = "AOE Tier", state = "AOETier" },

    -- Storm Spells (SCH subjob)
    { key = "^numpad7", command = "cyclestate Storm", desc = "Storm", state = "Storm" },

    -- Combat Modes
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },
    { key = "^numpad8", command = "cyclestate CombatMode", desc = "Combat Mode",  state = "CombatMode" },

    -- Magic Burst / Death
    { key = "^numpad0", command = "cyclestate MagicBurstMode", desc = "MB Mode", state = "MagicBurstMode" },
    { key = "#numpad7", command = "cyclestate DeathMode", desc = "Death Mode", state = "DeathMode" },

    -- Stratagem AOE Toggles (SCH subjob)
    { key = "#numpad8", command = "cyclestate SneakInviAOE", desc = "Sneak/Invi AOE", state = "SneakInviAOE" },
    { key = "#numpad9", command = "cyclestate KlimaformAOE", desc = "Klimaform AOE", state = "KlimaformAOE" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

return require('shared/utils/keybinds/keybind_manager').create('BLM', BLMKeybinds)

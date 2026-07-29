---============================================================================
--- BLM Keybind Configuration
---============================================================================
--- Defines all keybinds for Black Mage job with descriptions.
--- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
---
--- @file config/blm/BLM_KEYBINDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
---============================================================================

local BLMKeybinds = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

--- Keybind list with key, command, description, and state
--- Key format: ! = Alt, ^ = Ctrl, @ = Windows, # = Shift
--- Numpad only, always with a modifier so the bare numpad stays free for the
--- game and for addons that inject numpad presses (Silmaril hover, follow
--- macros). The modifier carries the meaning:
---
--- Ctrl is the primary bank and is filled first; Shift takes the overflow.
---
---   Ctrl  = Main side          Shift = Sub side
---   Ctrl+1 Main Light          Shift+1 Sub Light
---   Ctrl+2 Main Dark           Shift+2 Sub Dark
---   Ctrl+3 Main Light AOE      Shift+3 Sub Light AOE
---   Ctrl+4 Main Dark AOE       Shift+4 Sub Dark AOE
---
--- The same digit is always the same spell family; the modifier picks Main or
--- Sub. Ctrl 5-0 hold tiers, Storm and the main modes; Shift 5-7 the rest.
BLMKeybinds.binds = {
    -- Main / Sub Elemental Spells (same digit, Ctrl = Main, Shift = Sub)
    { key = "^numpad1", command = "cyclestate MainLightSpell", desc = "Main Light", state = "MainLightSpell" },
    { key = "#numpad1", command = "cyclestate SubLightSpell", desc = "Sub Light", state = "SubLightSpell" },
    { key = "^numpad2", command = "cyclestate MainDarkSpell", desc = "Main Dark", state = "MainDarkSpell" },
    { key = "#numpad2", command = "cyclestate SubDarkSpell", desc = "Sub Dark", state = "SubDarkSpell" },

    -- Main / Sub AOE Spells
    { key = "^numpad3", command = "cyclestate MainLightAOE", desc = "Main Light AOE", state = "MainLightAOE" },
    { key = "#numpad3", command = "cyclestate SubLightAOE", desc = "Sub Light AOE", state = "SubLightAOE" },
    { key = "^numpad4", command = "cyclestate MainDarkAOE", desc = "Main Dark AOE", state = "MainDarkAOE" },
    { key = "#numpad4", command = "cyclestate SubDarkAOE", desc = "Sub Dark AOE", state = "SubDarkAOE" },

    -- Tiers (shared by Main and Sub)
    { key = "^numpad5", command = "cyclestate SpellTier", desc = "Spell Tier", state = "SpellTier" },
    { key = "^numpad6", command = "cyclestate AOETier", desc = "AOE Tier", state = "AOETier" },

    -- Storm Spells (SCH subjob)
    { key = "^numpad7", command = "cyclestate Storm", desc = "Storm", state = "Storm" },

    -- Combat Modes
    { key = "^numpad8", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },
    { key = "^numpad9", command = "cyclestate CombatMode", desc = "Combat Mode",  state = "CombatMode" },

    -- Magic Burst / Death
    { key = "^numpad0", command = "cyclestate MagicBurstMode", desc = "MB Mode", state = "MagicBurstMode" },
    { key = "#numpad5", command = "cyclestate DeathMode", desc = "Death Mode", state = "DeathMode" },

    -- Stratagem AOE Toggles (SCH subjob)
    { key = "#numpad6", command = "cyclestate SneakInviAOE", desc = "Sneak/Invi AOE", state = "SneakInviAOE" },
    { key = "#numpad7", command = "cyclestate KlimaformAOE", desc = "Klimaform AOE", state = "KlimaformAOE" },
}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Apply all keybinds
function BLMKeybinds.bind_all()
    if not BLMKeybinds.binds or #BLMKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("BLM")
        return false
    end

    local bound_count = 0
    for _, bind in pairs(BLMKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            MessageFormatter.show_error('[BLM] Keybind Error: ' .. tostring(error_msg))
        end
    end

    if bound_count > 0 then
        -- Show intro with system info like other jobs
        BLMKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
function BLMKeybinds.unbind_all()
    if not BLMKeybinds.binds then
        return
    end

    for _, bind in pairs(BLMKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end
end

--- Display BLM system intro message with macrobook and lockstyle info
function BLMKeybinds.show_intro()
    -- Try to get macro info from BLM_MACROBOOK module
    local macro_info = nil
    local success, BLM_MACROBOOK = pcall(require, 'shared/jobs/blm/functions/BLM_MACROBOOK')
    if success and BLM_MACROBOOK and BLM_MACROBOOK.get_blm_macro_info then
        macro_info = BLM_MACROBOOK.get_blm_macro_info()
    end

    -- Try to get lockstyle info from BLM_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, BLM_LOCKSTYLE = pcall(require, 'shared/jobs/blm/functions/BLM_LOCKSTYLE')
    if lockstyle_success and BLM_LOCKSTYLE and BLM_LOCKSTYLE.get_info then
        lockstyle_info = BLM_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("BLM SYSTEM LOADED", BLMKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("BLM SYSTEM LOADED", BLMKeybinds.binds)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLMKeybinds

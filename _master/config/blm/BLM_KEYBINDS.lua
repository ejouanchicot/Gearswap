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
BLMKeybinds.binds = {
    -- Main Elemental Spells (Light then Dark)
    { key = "!1", command = "cyclestate MainLightSpell", desc = "Main Light", state = "MainLightSpell" },
    { key = "!2", command = "cyclestate MainDarkSpell", desc = "Main Dark", state = "MainDarkSpell" },

    -- Sub Elemental Spells (Light then Dark)
    { key = "^1", command = "cyclestate SubLightSpell", desc = "Sub Light", state = "SubLightSpell" },
    { key = "^2", command = "cyclestate SubDarkSpell", desc = "Sub Dark", state = "SubDarkSpell" },

    -- Spell Tier (VI, V, IV, III, II, I)
    { key = "!-", command = "cyclestate SpellTier", desc = "Spell Tier", state = "SpellTier" },

    -- AOE Spells (Light then Dark)
    { key = "!3", command = "cyclestate MainLightAOE", desc = "Light AOE", state = "MainLightAOE" },
    { key = "!4", command = "cyclestate MainDarkAOE", desc = "Dark AOE", state = "MainDarkAOE" },

    -- AOE Tier (Aja/III/II/I)
    { key = "!=", command = "cyclestate AOETier", desc = "AOE Tier", state = "AOETier" },

    -- Storm Spells (SCH subjob)
    { key = "!0", command = "cyclestate Storm", desc = "Storm", state = "Storm" },

    -- Combat Modes
    { key = "!5", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },
    { key = "!6", command = "cyclestate CombatMode", desc = "Combat Mode",  state = "CombatMode" },

    -- Magic Burst Mode
    { key = "!7", command = "cyclestate MagicBurstMode", desc = "MB Mode", state = "MagicBurstMode" },

    -- Death Mode
    { key = "!8", command = "cyclestate DeathMode", desc = "Death Mode", state = "DeathMode" },
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

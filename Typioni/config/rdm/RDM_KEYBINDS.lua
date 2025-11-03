---============================================================================
--- RDM Keybind Configuration
---============================================================================
--- Defines all keybindings for Red Mage job.
---
--- @file config/rdm/RDM_KEYBINDS.lua
--- @author Typioni
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

local RDMKeybinds = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions - Simplified Alt/Ctrl Only
-- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
RDMKeybinds.binds = {
    ---========================================================================
    --- ALT+ KEYS (States/Cycling)
    ---========================================================================

    -- Weapon Management
    { key = "!1", command = "cycle MainWeapon",     desc = "Main Weapon",   state = "MainWeapon" },
    { key = "!2", command = "cycle SubWeapon",      desc = "Sub Weapon",    state = "SubWeapon" },

    -- Combat Modes
    { key = "!3", command = "cycle EngagedMode",    desc = "Engaged Mode",  state = "EngagedMode" },
    { key = "!4", command = "cycle IdleMode",       desc = "Idle Mode",     state = "IdleMode" },

    -- Magic Modes
    { key = "!5", command = "cycle EnfeebleMode",   desc = "Enfeeble Mode", state = "EnfeebleMode" },
    { key = "!6", command = "cycle NukeMode",       desc = "Nuke Mode",     state = "NukeMode" },

    -- Enspell
    { key = "!7", command = "cycle Enspell",        desc = "Enspell",       state = "Enspell" },

    -- Elemental Spells (Light/Dark)
    { key = "!8", command = "cycle MainLightSpell", desc = "Main Light",    state = "MainLightSpell" },
    { key = "!9", command = "cycle SubLightSpell",  desc = "Sub Light",     state = "SubLightSpell" },
    { key = "!-", command = "cycle MainDarkSpell",  desc = "Main Dark",     state = "MainDarkSpell" },
    { key = "!=", command = "cycle SubDarkSpell",   desc = "Sub Dark",      state = "SubDarkSpell" },

    -- Weapon Lock
    { key = "!0", command = "cycle CombatMode",     desc = "Combat Mode",   state = "CombatMode" },

    ---========================================================================
    --- F-KEYS (Enhancement Spells)
    ---========================================================================

    -- Enhancement Spell Selection
    { key = "f1", command = "cycle GainSpell",      desc = "Gain Spell",    state = "GainSpell" },
    { key = "f2", command = "cycle Barspell",       desc = "Bar Element",   state = "Barspell" },
    { key = "f3", command = "cycle BarAilment",     desc = "Bar Ailment",   state = "BarAilment" },
    { key = "f4", command = "cycle Spike",          desc = "Spike",         state = "Spike" },
    { key = "f5", command = "cycle Storm",          desc = "Storm (SCH)",   state = "Storm",    subjob = "SCH" },

    ---========================================================================
    --- CTRL+ KEYS (Actions/Cast)
    ---========================================================================

    -- Job Abilities
    { key = "^1", command = "convert",              desc = "Convert",       state = nil },
    { key = "^2", command = "chainspell",           desc = "Chainspell",    state = nil },
    { key = "^3", command = "saboteur",             desc = "Saboteur",      state = nil },
    { key = "^4", command = "composure",            desc = "Composure",     state = nil },

    -- Quick Enhancing Spells
    { key = "^5", command = "refresh",              desc = "Refresh",       state = nil },
    { key = "^6", command = "phalanx",              desc = "Phalanx",       state = nil },
    { key = "^7", command = "haste",                desc = "Haste",         state = nil },

    -- Cast Elemental Spells
    { key = "^8", command = "castlight",            desc = "Cast Main Light", state = nil },
    { key = "^9", command = "castdark",             desc = "Cast Main Dark",  state = nil },

    -- Cast Enspell & Nuke Tier
    { key = "^-", command = "castenspell",          desc = "Cast Enspell",  state = nil },
    { key = "^=", command = "cycle NukeTier",       desc = "Nuke Tier",     state = "NukeTier" },
}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Apply all keybinds
function RDMKeybinds.bind_all()
    if not RDMKeybinds.binds or #RDMKeybinds.binds == 0 then
        MessageFormatter.show_error("RDM: No keybinds defined")
        return false
    end

    local bound_count = 0
    for _, bind in pairs(RDMKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            add_to_chat(167, '[RDM] Keybind Error on ' .. bind.key .. ': ' .. tostring(error_msg))
        end
    end

    if bound_count == 0 then
        MessageFormatter.show_error("RDM: Failed to bind any keys")
        return false
    end

    -- Get macro info from RDM_MACROBOOK module
    local macro_info = nil
    local macro_success, RDM_MACROBOOK = pcall(require, 'shared/jobs/rdm/functions/RDM_MACROBOOK')
    if macro_success and RDM_MACROBOOK and RDM_MACROBOOK.get_rdm_macro_info then
        macro_info = RDM_MACROBOOK.get_rdm_macro_info()
    end

    -- Get lockstyle info from RDM_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, RDM_LOCKSTYLE = pcall(require, 'shared/jobs/rdm/functions/RDM_LOCKSTYLE')
    if lockstyle_success and RDM_LOCKSTYLE and RDM_LOCKSTYLE.get_lockstyle_info then
        lockstyle_info = RDM_LOCKSTYLE.get_lockstyle_info()
    end

    -- Display formatted intro with keybinds, macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("RDM SYSTEM LOADED", RDMKeybinds.binds, macro_info, lockstyle_info)
    else
        MessageFormatter.show_system_intro("RDM SYSTEM LOADED", RDMKeybinds.binds)
    end

    return true
end

--- Remove all keybinds
function RDMKeybinds.unbind_all()
    if not RDMKeybinds.binds then return end

    for _, bind in pairs(RDMKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    add_to_chat(122, '[RDM] All keybinds removed')
end

---============================================================================
--- KEYBIND DISPLAY
---============================================================================

--- Formats and displays all configured keybinds in a readable list.
--- Uses MessageFormatter for consistent formatting with other jobs.
--- @return void
function RDMKeybinds.print_keybinds()
    MessageFormatter.show_keybind_list("RDM Keybinds", RDMKeybinds.binds)
end

return RDMKeybinds

---============================================================================
--- RDM Keybind Configuration
---============================================================================
--- Defines all keybindings for Red Mage job.
---
--- @file config/rdm/RDM_KEYBINDS.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-12
---============================================================================

local RDMKeybinds = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions - NUMPAD ONLY (Numpad + Alt+Numpad)
-- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
RDMKeybinds.binds = {
    ---========================================================================
    --- NUMPAD KEYS (States - 10 touches)
    ---========================================================================

    -- Weapon & Combat States (1-5)
    { key = "numpad1", command = "cyclestate MainWeapon",     desc = "Main Weapon",     state = "MainWeapon" },
    { key = "numpad2", command = "cyclestate SubWeapon",      desc = "Sub Weapon",      state = "SubWeapon" },
    { key = "numpad3", command = "cyclestate EngagedMode",    desc = "Engaged Mode",    state = "EngagedMode" },
    { key = "numpad4", command = "cyclestate IdleMode",       desc = "Idle Mode",       state = "IdleMode" },
    { key = "numpad5", command = "cyclestate CombatMode",     desc = "Combat Mode",     state = "CombatMode" },

    -- Magic States (6-9, 0)
    { key = "numpad6", command = "cyclestate EnfeebleMode",   desc = "Enfeeble Mode",   state = "EnfeebleMode" },
    { key = "numpad7", command = "cyclestate NukeMode",       desc = "Nuke Mode",       state = "NukeMode" },
    { key = "numpad8", command = "cyclestate SaboteurMode",   desc = "Saboteur Mode",   state = "SaboteurMode" },
    { key = "numpad9", command = "cyclestate NukeTier",       desc = "Nuke Tier",       state = "NukeTier" },
    { key = "numpad0", command = "cyclestate Storm",          desc = "Storm (SCH)",     state = "Storm",    subjob = "SCH" },

    ---========================================================================
    --- ALT+NUMPAD KEYS (Enhancement States & Cast - 10 touches)
    ---========================================================================

    -- Enhancement Spell Selection (1-5)
    { key = "!numpad1", command = "cyclestate EnSpell",       desc = "Enspell",         state = "EnSpell" },
    { key = "!numpad2", command = "cyclestate GainSpell",     desc = "Gain Spell",      state = "GainSpell" },
    { key = "!numpad3", command = "cyclestate Barspell",      desc = "Bar Element",     state = "Barspell" },
    { key = "!numpad4", command = "cyclestate BarAilment",    desc = "Bar Ailment",     state = "BarAilment" },
    { key = "!numpad5", command = "cyclestate Spike",         desc = "Spike",           state = "Spike" },

    -- Cast Enhancement Spells from states (6-9, 0)
    { key = "!numpad6", command = "castenspell",         desc = "Cast Enspell",    state = nil },
    { key = "!numpad7", command = "castgain",            desc = "Cast Gain",       state = nil },
    { key = "!numpad8", command = "castbar",             desc = "Cast BarElement", state = nil },
    { key = "!numpad9", command = "castbarailment",      desc = "Cast BarAilment", state = nil },
    { key = "!numpad0", command = "castspike",           desc = "Cast Spike",      state = nil },
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
            MessageFormatter.show_error('[RDM] Keybind Error on ' .. bind.key .. ': ' .. tostring(error_msg))
        end
    end

    -- Show intro message if successful
    if bound_count > 0 then
        RDMKeybinds.show_intro()
        return true
    else
        MessageFormatter.show_error("RDM: Failed to bind any keys")
        return false
    end
end

--- Remove all keybinds
function RDMKeybinds.unbind_all()
    if not RDMKeybinds.binds then return end

    for _, bind in pairs(RDMKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("RDM keybinds unloaded.")
    return true
end

--- Display RDM system intro message with macrobook and lockstyle info
--- @return void
function RDMKeybinds.show_intro()
    -- Try to get macro info from RDM_MACROBOOK module
    local macro_info = nil
    local success, RDM_MACROBOOK = pcall(require, 'shared/jobs/rdm/functions/RDM_MACROBOOK')
    if success and RDM_MACROBOOK and RDM_MACROBOOK.get_rdm_macro_info then
        macro_info = RDM_MACROBOOK.get_rdm_macro_info()
    end

    -- Try to get lockstyle info from RDM_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, RDM_LOCKSTYLE = pcall(require, 'shared/jobs/rdm/functions/RDM_LOCKSTYLE')
    if lockstyle_success and RDM_LOCKSTYLE and RDM_LOCKSTYLE.get_info then
        lockstyle_info = RDM_LOCKSTYLE.get_info()
    end

    -- Display formatted intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("RDM SYSTEM LOADED", RDMKeybinds.binds, macro_info, lockstyle_info)
    else
        MessageFormatter.show_system_intro("RDM SYSTEM LOADED", RDMKeybinds.binds)
    end
end

return RDMKeybinds

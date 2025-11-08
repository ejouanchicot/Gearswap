---============================================================================
--- WHM Keybind Configuration - Keyboard Shortcuts
---============================================================================
--- Defines all WHM keybindings for quick state cycling and command execution.
---
--- Features:
---   • CureMode cycling (Alt+1) - Potency vs SIRD
---   • IdleMode cycling (Ctrl+=) - PDT vs Refresh
---   • Lockstyle controls (Ctrl+[/Alt+[)
---   • Integration with UI system (keybinds displayed in UI)
---
--- Usage:
---   • Loaded in user_setup() via require()
---   • Call WHMKeybinds.bind_all() to activate keybinds
---   • Call WHMKeybinds.unbind_all() on file_unload()
---
--- @file    config/whm/WHM_KEYBINDS.lua
--- @author  Morphetrix
--- @version 1.0.0
--- @date    Created: 2025-10-21
---============================================================================

local WHMKeybinds = {}

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

--- Keybind table - defines all keyboard shortcuts for WHM
--- Format: {key = "bind_string", command = "gs_command", desc = "UI_description", state = "state_name"}
WHMKeybinds.binds = {
    -- CureMode cycling (Alt+1 - most important for WHM)
    {
        key = "!1",
        command = "cycle CureMode",
        desc = "Cure Mode",
        state = "CureMode"
    },

    -- IdleMode cycling (Ctrl+=)
    {
        key = "!2",
        command = "cycle IdleMode",
        desc = "Idle Mode",
        state = "IdleMode"
    },

    -- AfflatusMode cycling (Alt+3)
    {
        key = "!3",
        command = "cycle AfflatusMode",
        desc = "Afflatus Mode",
        state = "AfflatusMode"
    },

    -- CureAutoTier cycling (Alt+4)
    {
        key = "!4",
        command = "cycle CureAutoTier",
        desc = "Cure Auto-Tier",
        state = "CureAutoTier"
    },

    -- CombatMode cycling (Alt+0) - Weapon lock control
    {
        key = "!0",
        command = "cycle CombatMode",
        desc = "Combat Mode",
        state = "CombatMode"
    },

    -- CastingMode cycling (Alt+5)
    {
        key = "!5",
        command = "cycle CastingMode",
        desc = "Casting Mode",
        state = "CastingMode"
    },

    -- Lockstyle controls
    {
        key = "^[",
        command = "send input /lockstyle on",
        desc = "Lockstyle ON",
        state = nil
    },
    {
        key = "![",
        command = "send input /lockstyle off",
        desc = "Lockstyle OFF",
        state = nil
    }

    -- Additional keybinds can be added here:
    -- Examples:
    --   • CastingMode cycling (for Resistant mode)
    --   • Auto-Devotion toggle
    --   • Auto-Divine Seal toggle
    --   • Quick Cursna macro
}

---============================================================================
--- KEYBIND ACTIVATION
---============================================================================

--- Display system intro with keybinds, macro, and lockstyle info
--- Attempts to gather macro and lockstyle information from respective modules.
--- Falls back to basic intro if additional info unavailable.
---
--- @return void
function WHMKeybinds.show_intro()
    local MessageFormatter = require('shared/utils/messages/message_formatter')

    -- Try to get macro info from WHM_MACROBOOK module
    local macro_info = nil
    local success, WHM_MACROBOOK = pcall(require, 'shared/jobs/whm/functions/WHM_MACROBOOK')
    if success and WHM_MACROBOOK and WHM_MACROBOOK.get_whm_macro_info then
        macro_info = WHM_MACROBOOK.get_whm_macro_info()
    end

    -- Try to get lockstyle info from WHM_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, WHM_LOCKSTYLE = pcall(require, 'shared/jobs/whm/functions/WHM_LOCKSTYLE')
    if lockstyle_success and WHM_LOCKSTYLE and WHM_LOCKSTYLE.get_info then
        lockstyle_info = WHM_LOCKSTYLE.get_info()
    end

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("WHM SYSTEM LOADED", WHMKeybinds.binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("WHM SYSTEM LOADED", WHMKeybinds.binds)
    end
end

--- Bind all keybinds defined in keybinds table
--- Called from user_setup() during job initialization.
---
--- @return void
function WHMKeybinds.bind_all()
    for _, bind in pairs(WHMKeybinds.binds) do
        local success, error_msg = pcall(function()
            -- Handle different command types
            if bind.command:match("^send ") then
                -- Direct send_command (lockstyle controls)
                local cmd = bind.command:gsub("^send ", "")
                send_command('bind ' .. bind.key .. ' ' .. cmd)
            else
                -- GearSwap command (state cycling)
                send_command('bind ' .. bind.key .. ' gs c ' .. bind.command)
            end
        end)

        if not success then
            add_to_chat(167, '[WHM] Keybind Error (' .. bind.key .. '): ' .. tostring(error_msg))
        end
    end

    -- Show system intro after binding keybinds
    WHMKeybinds.show_intro()
end

--- Unbind all keybinds
--- Called from file_unload() during job unload/change.
---
--- @return void
function WHMKeybinds.unbind_all()
    for _, bind in pairs(WHMKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    add_to_chat(200, '[WHM] Keybinds unloaded successfully')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return WHMKeybinds

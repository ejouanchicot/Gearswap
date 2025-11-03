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
--- @author  Typioni
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

    add_to_chat(200, '[WHM] Keybinds loaded successfully')
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

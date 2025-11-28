---============================================================================
--- UI Commands - Centralized UI Command Handler
---============================================================================
--- Handles ALL UI-related commands for ALL jobs. Eliminates duplication
--- of UI command logic across job-specific COMMANDS.lua files.
---
--- @file utils/ui/UI_COMMANDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-04
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')

local UICommands = {}

-- Load dependencies
local MessageUI = require('shared/utils/messages/formatters/ui/message_ui')

---============================================================================
--- MAIN UI COMMAND HANDLER
---============================================================================

--- Handle all UI commands (centralized for all jobs)
--- @param cmdParams table Command parameters array
--- @return boolean True if command was handled
function UICommands.handle_ui_command(cmdParams)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if not ui_success or not KeybindUI then
        MessageCore.show_ui_error('ERROR: Failed to load UI Manager')
        return false
    end

    local subcommand = cmdParams[2] and cmdParams[2]:lower()

    if not subcommand then
        -- No subcommand: toggle UI
        KeybindUI.toggle()
    elseif subcommand == 'h' or subcommand == 'header' then
        KeybindUI.toggle_header()
    elseif subcommand == 'l' or subcommand == 'legend' then
        KeybindUI.toggle_legend()
    elseif subcommand == 'c' or subcommand == 'columns' then
        KeybindUI.toggle_column_headers()
    elseif subcommand == 'f' or subcommand == 'footer' then
        KeybindUI.toggle_footer()
    elseif subcommand == 's' or subcommand == 'save' then
        KeybindUI.save_position()
    elseif subcommand == 'on' or subcommand == 'enable' then
        KeybindUI.enable()
    elseif subcommand == 'off' or subcommand == 'disable' then
        KeybindUI.disable()
    elseif subcommand == 'font' then
        -- Font command
        local font_name = cmdParams[3]
        if not font_name then
            MessageUI.show_error("Missing font name. Use: //gs c ui font <Consolas|Courier New>")
        else
            KeybindUI.set_font(font_name)
        end
    elseif subcommand == 'bg' or subcommand == 'background' or subcommand == 'theme' then
        -- Background/Theme commands
        local bg_action = cmdParams[3] and cmdParams[3]:lower()

        if not bg_action then
            MessageUI.show_error("Missing theme parameter. Use: //gs c ui theme <preset_name|toggle|r g b a>")
        elseif bg_action == 'toggle' then
            KeybindUI.toggle_background()
        elseif bg_action == 'list' then
            -- List available presets using proper message formatting
            MessageUI.show_theme_list()
        else
            -- Try as preset name first
            local UIConfig = _G.UIConfig or {}  -- Loaded from character main file
            if UIConfig.background_presets and UIConfig.background_presets[bg_action] then
                KeybindUI.set_background_preset(bg_action)
            else
                -- Try custom RGBA (4 numbers required)
                local r, g, b, a = cmdParams[3], cmdParams[4], cmdParams[5], cmdParams[6]
                if r and g and b and a then
                    KeybindUI.set_background_rgba(r, g, b, a)
                else
                    MessageUI.show_error("Unknown theme: " .. bg_action .. ". Use '//gs c ui theme list' to see all themes.")
                end
            end
        end
    elseif subcommand == 'help' or subcommand == '?' then
        MessageUI.show_help()
    else
        -- Unknown subcommand, show help
        MessageUI.show_error("Unknown UI command: " .. subcommand)
        MessageUI.show_help()
    end

    return true
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if command is a UI command
--- @param command string The command to check
--- @return boolean True if this is a UI command
function UICommands.is_ui_command(command)
    return command and command:lower() == 'ui'
end

return UICommands

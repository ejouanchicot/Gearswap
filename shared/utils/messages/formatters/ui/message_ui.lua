---============================================================================
--- UI Message Formatter - UI Control Messages
---============================================================================
--- Handles all UI-related messages (toggle, enable/disable, save position,
--- look options, help, theme list). Every line goes through the templates of
--- data/systems/ui_messages.lua; the lists are blocks (separator, title,
--- lines, separator), one template per line.
---
--- @file    shared/utils/messages/formatters/ui/message_ui.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageUI = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local InfoBlock = require('shared/utils/messages/info_block')

---============================================================================
--- UI TOGGLE MESSAGES
---============================================================================

--- Display UI toggle message (ON/OFF)
--- @param component string Component name (e.g., "Header", "Legend", "Column Headers", "Footer")
--- @param enabled boolean Whether component is enabled
function MessageUI.show_toggle(component, enabled)
    local message_key = enabled and 'toggle_on' or 'toggle_off'

    M.send('UI', message_key, {
        component = component
    })
end

--- Display UI enabled message
function MessageUI.show_enabled()
    M.send('UI', 'enabled')
end

--- Display UI disabled message
function MessageUI.show_disabled()
    M.send('UI', 'disabled')
end

---============================================================================
--- UI POSITION MESSAGES
---============================================================================

--- Display position saved message
--- @param x number X coordinate
--- @param y number Y coordinate
function MessageUI.show_position_saved(x, y)
    M.send('UI', 'position_saved', {
        x = tostring(math.floor(x)),
        y = tostring(math.floor(y))
    })
end

--- Display position save failed message
function MessageUI.show_position_save_failed()
    M.send('UI', 'position_save_failed')
end

---============================================================================
--- UI ERROR MESSAGES
---============================================================================

--- Display UI error message
--- @param error_text string Error description
function MessageUI.show_error(error_text)
    M.send('UI', 'error', {error_text = error_text})
end

---============================================================================
--- LOOK OPTION MESSAGES
---============================================================================

--- A look option changed in game (//gs c ui gap 3, ...).
--- @param option string "layout.column_gap"
--- @param value string Lua text of the new value, or "standard"
--- @param error_text string|nil Why it could not be saved; nil when saved
function MessageUI.show_style_set(option, value, error_text)
    M.send('UI', error_text and 'style_not_saved' or 'style_saved', {
        option = option,
        value = value,
        error_text = error_text
    })
end

--- Current look values (//gs c ui style): separator, title, one
--- "Label : value" line per field, separator.
--- @param fields table List of {label, value}; value true/false prints ON/OFF
function MessageUI.show_style_list(fields)
    InfoBlock.show({tag = 'UI', title = 'Current look', fields = fields})
end

---============================================================================
--- BACKGROUND MESSAGES
---============================================================================

--- Display background preset applied message
--- @param preset_name string Preset name
--- @param r number Red value
--- @param g number Green value
--- @param b number Blue value
--- @param a number Alpha value
function MessageUI.show_background_preset(preset_name, r, g, b, a)
    M.send('UI', 'background_preset', {
        preset_name = preset_name,
        r = tostring(r),
        g = tostring(g),
        b = tostring(b),
        a = tostring(a)
    })
end

--- Display custom background RGBA message
--- @param r number Red value
--- @param g number Green value
--- @param b number Blue value
--- @param a number Alpha value
function MessageUI.show_background_rgba(r, g, b, a)
    M.send('UI', 'background_rgba', {
        r = tostring(r),
        g = tostring(g),
        b = tostring(b),
        a = tostring(a)
    })
end

---============================================================================
--- HELP AND THEME LIST
---============================================================================

--- //gs c ui help, rendered by HelpScreen in the look of //gs c commands.
local HELP = {
    title = 'UI', subtitle = 'HUD and chat look', col = 41,
    groups = {
        {title = 'DISPLAY', rows = {
            {'//gs c ui', '', 'Show / hide the HUD'},
            {'//gs c ui ', 'on|off', 'Enable / disable'},
            {'//gs c ui ', 'h|l|c|f', 'Header/legend/columns/footer'},
            {'//gs c ui s', '', 'Save position'},
            {'//gs c ui font ', '<name>', 'Consolas or courier'},
            {'//gs c ui bg ', '<theme>', 'Background theme'},
            {'//gs c ui bg ', '<r> <g> <b> <a>', 'Custom background'},
            {'//gs c ui bg ', 'toggle|list', 'Background on/off, themes'},
        }},
        {title = 'LOOK', note = 'saved in UI_CONFIG.lua', rows = {
            {'//gs c ui style', '', 'Show the current look'},
            {'//gs c ui compact ', '[on|off]', 'Tighter HUD'},
            {'//gs c ui gap ', '<1-10>', 'Spaces key > label'},
            {'//gs c ui valuegap ', '<1-10>', 'Spaces label > value'},
            {'//gs c ui margin ', '<0-3> [0-3]', 'Blank lines top, bottom'},
            {'//gs c ui side ', '<0-3>', 'Spaces left and right'},
            {'//gs c ui padding ', '<0-20>', 'Pixels around the text'},
            {'//gs c ui keys ', 'symbols|words', '^f1 or CTRL+F1'},
            {'//gs c ui bullet ', '<name>', 'dot arrow square gt none'},
            {'//gs c ui order ', '<sections>', 'Section order'},
            {'//gs c ui roworder ', '<states>', 'Row order in sections'},
            {'//gs c ui color ', '<name> <r> <g> <b>', 'key value section_title'},
        }},
        {title = 'CHAT', note = 'saved in UI_CONFIG.lua', rows = {
            {'//gs c ui separators ', '[on|off]', 'The ===== line'},
            {'//gs c ui sepchar ', '<chars>', 'Its character'},
            {'//gs c ui sepcolor ', '<1-255>', 'Its color'},
            {'//gs c ui chatwidth ', '<20-150>', 'Width of ===== lines'},
            {'//gs c ui jobtag ', '[on|off]', '[RDM/DRK] before messages'},
            {'//gs c ui chatcolor ', '<name> <1-255>', 'green success error...'},
        }},
    },
    notes = {'<option> reset = back to the standard value.'},
}

--- Display UI help menu.
function MessageUI.show_help()
    require('shared/utils/messages/help_screen').show(HELP)
end

--- Theme group of a preset name: dark_*, light_*, transparent_*, neon_*,
--- else medium ("black" goes with the dark ones).
local THEME_GROUPS = {'Dark', 'Light', 'Medium', 'Transparent', 'Neon'}
local function theme_group(name)
    if name == 'black' then return 'Dark' end
    local prefix = name:match('^(%a+)_')
    prefix = prefix and prefix:sub(1, 1):upper() .. prefix:sub(2)
    for _, group in ipairs(THEME_GROUPS) do
        if group == prefix then return group end
    end
    return 'Medium'
end

--- Display the background themes of UI_CONFIG.lua (background_presets),
--- grouped, a player's own themes included. A list of values to type, so
--- it has the look of the help screens (HelpScreen).
function MessageUI.show_theme_list()
    local HelpScreen = require('shared/utils/messages/help_screen')
    local by_group = {}
    for name in pairs((_G.UIConfig or {}).background_presets or {}) do
        local group = theme_group(name)
        by_group[group] = by_group[group] or {}
        table.insert(by_group[group], name)
    end
    HelpScreen.header('UI THEMES', 'background presets')
    for _, group in ipairs(THEME_GROUPS) do
        local names = by_group[group]
        if names then
            table.sort(names)
            HelpScreen.group(group:upper())
            HelpScreen.names(names)
        end
    end
    HelpScreen.notes({'//gs c ui bg <theme>, or //gs c ui bg <r> <g> <b> <a>'})
    HelpScreen.footer()
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageUI

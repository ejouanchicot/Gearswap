---============================================================================
--- UI Message Formatter - UI Control Messages (NEW SYSTEM - HYBRID)
---============================================================================
--- Handles all UI-related messages (toggle, enable/disable, save position)
--- Uses hybrid approach: Templates for simple messages, direct rendering for complex menus
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_ui.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageUI = {}
local M = require('shared/utils/messages/api/messages')
local MessageCore = require('shared/utils/messages/message_core')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local Colors = MessageCore.COLORS

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
--- COMPLEX MULTI-LINE MENUS (HYBRID RENDERING)
---============================================================================

--- Display available UI theme presets
function MessageUI.show_theme_list()
    -- Color codes (same as msgtest)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local green = string.char(0x1F, 158)
    local separator = string.rep("=", 70)

    -- Header
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Available UI Themes")
    add_to_chat(121, gray .. separator)

    -- Dark themes
    add_to_chat(121, yellow .. "DARK THEMES:")
    add_to_chat(121, gray .. "  dark_blue, dark_red, dark_green")
    add_to_chat(121, gray .. "  dark_purple, dark_cyan")
    add_to_chat(121, gray .. "  dark_orange, dark_pink, black")

    -- Light themes
    add_to_chat(121, yellow .. "LIGHT THEMES:")
    add_to_chat(121, gray .. "  light_blue, light_red, light_green")
    add_to_chat(121, gray .. "  light_purple, light_cyan")
    add_to_chat(121, gray .. "  light_orange, light_pink, light_gray")

    -- Medium themes
    add_to_chat(121, yellow .. "MEDIUM THEMES:")
    add_to_chat(121, gray .. "  blue, red, green, purple")
    add_to_chat(121, gray .. "  cyan, orange, pink, yellow")

    -- Transparent themes
    add_to_chat(121, yellow .. "TRANSPARENT THEMES:")
    add_to_chat(121, gray .. "  transparent_dark, transparent_blue")
    add_to_chat(121, gray .. "  transparent_red, transparent_green")
    add_to_chat(121, gray .. "  transparent_purple")

    -- Neon themes
    add_to_chat(121, yellow .. "NEON THEMES:")
    add_to_chat(121, gray .. "  neon_blue, neon_red, neon_green")
    add_to_chat(121, gray .. "  neon_purple, neon_pink")
    add_to_chat(121, gray .. "  neon_cyan, neon_yellow")

    -- Footer
    add_to_chat(121, gray .. separator)
    add_to_chat(121, green .. "Usage: //gs c ui theme <name>")
    add_to_chat(121, gray .. separator)
end

--- Display UI help menu
function MessageUI.show_help()
    -- Color codes (same as msgtest)
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local green = string.char(0x1F, 158)
    local separator = string.rep("=", 70)

    -- Header
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "[UI] Available Commands")
    add_to_chat(121, gray .. separator)

    -- Commands
    add_to_chat(121, green .. "//gs c ui" .. gray .. " [Toggle UI]")
    add_to_chat(121, green .. "//gs c ui h" .. gray .. " [Toggle Header - or 'header']")
    add_to_chat(121, green .. "//gs c ui l" .. gray .. " [Toggle Legend - or 'legend']")
    add_to_chat(121, green .. "//gs c ui c" .. gray .. " [Toggle Columns - or 'columns']")
    add_to_chat(121, green .. "//gs c ui f" .. gray .. " [Toggle Footer - or 'footer']")
    add_to_chat(121, green .. "//gs c ui s" .. gray .. " [Save All Settings - or 'save']")
    add_to_chat(121, green .. "//gs c ui on" .. gray .. " [Enable UI - or 'enable']")
    add_to_chat(121, green .. "//gs c ui off" .. gray .. " [Disable UI - or 'disable']")
    add_to_chat(121, green .. "//gs c ui bg <preset>" .. gray .. " [Set BG: dark/light/blue/etc]")
    add_to_chat(121, green .. "//gs c ui bg <r> <g> <b> <a>" .. gray .. " [Set custom RGBA]")
    add_to_chat(121, green .. "//gs c ui bg toggle" .. gray .. " [Toggle background visibility]")
    add_to_chat(121, green .. "//gs c ui bg list" .. gray .. " [List all available presets]")

    -- Footer
    add_to_chat(121, gray .. separator)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageUI

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
    local status_color = enabled and "{green}" or "{gray}"
    local status_text = enabled and "ON" or "OFF"

    M.send('UI', 'toggle', {
        component = component,
        status_color = status_color,
        status = status_text
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
    local cyan = MessageCore.create_color_code(205)
    local yellow = MessageCore.create_color_code(220)  -- Gold/Yellow
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local white = MessageCore.create_color_code(001)

    MessageRenderer.send(1, cyan .. "============================")
    MessageRenderer.send(1, cyan .. "Available UI Themes")
    MessageRenderer.send(1, cyan .. "============================")

    -- Dark themes
    MessageRenderer.send(1, yellow .. "DARK THEMES:")
    MessageRenderer.send(1, gray .. "  dark_blue, dark_red, dark_green")
    MessageRenderer.send(1, gray .. "  dark_purple, dark_cyan")
    MessageRenderer.send(1, gray .. "  dark_orange, dark_pink, black")

    -- Light themes
    MessageRenderer.send(1, yellow .. "LIGHT THEMES:")
    MessageRenderer.send(1, gray .. "  light_blue, light_red, light_green")
    MessageRenderer.send(1, gray .. "  light_purple, light_cyan")
    MessageRenderer.send(1, gray .. "  light_orange, light_pink, light_gray")

    -- Medium themes
    MessageRenderer.send(1, yellow .. "MEDIUM THEMES:")
    MessageRenderer.send(1, gray .. "  blue, red, green, purple")
    MessageRenderer.send(1, gray .. "  cyan, orange, pink, yellow")

    -- Transparent themes
    MessageRenderer.send(1, yellow .. "TRANSPARENT THEMES:")
    MessageRenderer.send(1, gray .. "  transparent_dark, transparent_blue")
    MessageRenderer.send(1, gray .. "  transparent_red, transparent_green")
    MessageRenderer.send(1, gray .. "  transparent_purple")

    -- Neon themes
    MessageRenderer.send(1, yellow .. "NEON THEMES:")
    MessageRenderer.send(1, gray .. "  neon_blue, neon_red, neon_green")
    MessageRenderer.send(1, gray .. "  neon_purple, neon_pink")
    MessageRenderer.send(1, gray .. "  neon_cyan, neon_yellow")

    MessageRenderer.send(1, cyan .. "============================")
    MessageRenderer.send(1, white .. "Usage: //gs c ui theme <name>")
    MessageRenderer.send(1, cyan .. "============================")
end

--- Display UI help menu
function MessageUI.show_help()
    local cyan = MessageCore.create_color_code(205)
    local green = MessageCore.create_color_code(Colors.SUCCESS)
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)

    -- Define commands with descriptions
    local commands = {
        { cmd = "//gs c ui", desc = "[Toggle UI]" },
        { cmd = "//gs c ui h", desc = "[Toggle Header - or 'header']" },
        { cmd = "//gs c ui l", desc = "[Toggle Legend - or 'legend']" },
        { cmd = "//gs c ui c", desc = "[Toggle Columns - or 'columns']" },
        { cmd = "//gs c ui f", desc = "[Toggle Footer - or 'footer']" },
        { cmd = "//gs c ui s", desc = "[Save All Settings - or 'save']" },
        { cmd = "//gs c ui on", desc = "[Enable UI - or 'enable']" },
        { cmd = "//gs c ui off", desc = "[Disable UI - or 'disable']" },
        { cmd = "//gs c ui bg <preset>", desc = "[Set BG: dark/light/blue/black/transparent]" },
        { cmd = "//gs c ui bg <r> <g> <b> <a>", desc = "[Set custom background RGBA]" },
        { cmd = "//gs c ui bg toggle", desc = "[Toggle background visibility]" }
    }

    -- Calculate max width
    local max_width = 0
    for _, line in ipairs(commands) do
        local total_length = string.len(line.cmd) + 1 + string.len(line.desc)
        max_width = math.max(max_width, total_length)
    end

    local separator = string.rep("=", max_width)

    MessageRenderer.send(1, cyan .. separator)
    for _, line in ipairs(commands) do
        MessageRenderer.send(1, green .. line.cmd .. gray .. " " .. line.desc)
    end
    MessageRenderer.send(1, cyan .. separator)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageUI

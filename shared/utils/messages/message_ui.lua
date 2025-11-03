---============================================================================
--- Message UI - UI control and status messages
---============================================================================
--- Handles all UI-related messages (toggle, enable/disable, save position)
--- with consistent formatting and color coding.
---
--- @file utils/messages/message_ui.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-02
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local Colors = MessageCore.COLORS
local MessageUI = {}

---============================================================================
--- UI TOGGLE MESSAGES
---============================================================================

--- Display UI toggle message (ON/OFF)
--- @param component string Component name (e.g., "Header", "Legend", "Column Headers", "Footer")
--- @param enabled boolean Whether component is enabled
function MessageUI.show_toggle(component, enabled)
    local status_color = MessageCore.create_color_code(enabled and Colors.SUCCESS or Colors.SEPARATOR)
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local status_text = enabled and "ON" or "OFF"

    local message = string.format("%s[UI]%s %s: %s%s",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        component,
        status_color,
        status_text)

    add_to_chat(001, message)
end

--- Display UI enabled message
function MessageUI.show_enabled()
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local status_color = MessageCore.create_color_code(Colors.SUCCESS)

    local message = string.format("%s[UI]%s UI %sEnabled",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        status_color)

    add_to_chat(001, message)
end

--- Display UI disabled message
function MessageUI.show_disabled()
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local status_color = MessageCore.create_color_code(Colors.SEPARATOR)

    local message = string.format("%s[UI]%s UI %sDisabled",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        status_color)

    add_to_chat(001, message)
end

---============================================================================
--- UI POSITION MESSAGES
---============================================================================

--- Display position saved message
--- @param x number X coordinate
--- @param y number Y coordinate
function MessageUI.show_position_saved(x, y)
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local coord_color = MessageCore.create_color_code(Colors.SUCCESS)

    local message = string.format("%s[UI]%s Settings saved: %sPosition (%d, %d) + Display states",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        coord_color,
        math.floor(x),
        math.floor(y))

    add_to_chat(001, message)
end

--- Display position save failed message
function MessageUI.show_position_save_failed()
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local message = string.format("%s[UI]%s %sFailed to save position",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        error_color)

    add_to_chat(001, message)
end

---============================================================================
--- UI ERROR MESSAGES
---============================================================================

--- Display UI error message
--- @param error_text string Error description
function MessageUI.show_error(error_text)
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local error_color = MessageCore.create_color_code(Colors.ERROR)

    local message = string.format("%s[UI ERROR]%s %s",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        error_color .. error_text)

    add_to_chat(001, message)
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
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local preset_color = MessageCore.create_color_code(Colors.SUCCESS)

    local message = string.format("%s[UI]%s Background preset: %s%s %s(RGBA: %d,%d,%d,%d)",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        preset_color,
        preset_name,
        MessageCore.create_color_code(Colors.SEPARATOR),
        r, g, b, a)

    add_to_chat(001, message)
end

--- Display custom background RGBA message
--- @param r number Red value
--- @param g number Green value
--- @param b number Blue value
--- @param a number Alpha value
function MessageUI.show_background_rgba(r, g, b, a)
    local label_color = MessageCore.create_color_code(205)  -- Cyan pour [UI]
    local rgba_color = MessageCore.create_color_code(Colors.SUCCESS)

    local message = string.format("%s[UI]%s Background set: %sRGBA(%d,%d,%d,%d)",
        label_color,
        MessageCore.create_color_code(Colors.SEPARATOR),
        rgba_color,
        r, g, b, a)

    add_to_chat(001, message)
end

--- Display available UI theme presets
function MessageUI.show_theme_list()
    local cyan = MessageCore.create_color_code(205)
    local yellow = MessageCore.create_color_code(220)  -- Gold/Yellow
    local gray = MessageCore.create_color_code(Colors.SEPARATOR)
    local white = MessageCore.create_color_code(001)

    add_to_chat(001, cyan .. "============================")
    add_to_chat(001, cyan .. "Available UI Themes")
    add_to_chat(001, cyan .. "============================")

    -- Dark themes
    add_to_chat(001, yellow .. "DARK THEMES:")
    add_to_chat(001, gray .. "  dark_blue, dark_red, dark_green")
    add_to_chat(001, gray .. "  dark_purple, dark_cyan")
    add_to_chat(001, gray .. "  dark_orange, dark_pink, black")

    -- Light themes
    add_to_chat(001, yellow .. "LIGHT THEMES:")
    add_to_chat(001, gray .. "  light_blue, light_red, light_green")
    add_to_chat(001, gray .. "  light_purple, light_cyan")
    add_to_chat(001, gray .. "  light_orange, light_pink, light_gray")

    -- Medium themes
    add_to_chat(001, yellow .. "MEDIUM THEMES:")
    add_to_chat(001, gray .. "  blue, red, green, purple")
    add_to_chat(001, gray .. "  cyan, orange, pink, yellow")

    -- Transparent themes
    add_to_chat(001, yellow .. "TRANSPARENT THEMES:")
    add_to_chat(001, gray .. "  transparent_dark, transparent_blue")
    add_to_chat(001, gray .. "  transparent_red, transparent_green")
    add_to_chat(001, gray .. "  transparent_purple")

    -- Neon themes
    add_to_chat(001, yellow .. "NEON THEMES:")
    add_to_chat(001, gray .. "  neon_blue, neon_red, neon_green")
    add_to_chat(001, gray .. "  neon_purple, neon_pink")
    add_to_chat(001, gray .. "  neon_cyan, neon_yellow")

    add_to_chat(001, cyan .. "============================")
    add_to_chat(001, white .. "Usage: //gs c ui theme <name>")
    add_to_chat(001, cyan .. "============================")
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

    add_to_chat(001, cyan .. separator)
    for _, line in ipairs(commands) do
        add_to_chat(001, green .. line.cmd .. gray .. " " .. line.desc)
    end
    add_to_chat(001, cyan .. separator)
end

return MessageUI

---============================================================================
--- UI Appearance - Background and Font Customization
---============================================================================
--- Manages UI background color (preset + custom RGBA + visibility toggle)
--- and font selection. Extracted from UI_MANAGER.lua. Each setter applies
--- the change to the live texts element (if present) and persists to
--- _G.keybind_saved_settings via KeybindSettings.save().
---
--- Reads UIConfig.background_presets / UIConfig.text from _G.UIConfig
--- (loaded by the character main file).
---
--- @file ui/ui_appearance.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local KeybindSettings = require('shared/utils/ui/UI_SETTINGS')
local MessageCore = require('shared/utils/messages/message_core')
local MessageUI = require('shared/utils/messages/formatters/ui/message_ui')

local Appearance = {}

--- Persist 4 background channels + apply to live UI element if present
--- @param r number 0-255
--- @param g number 0-255
--- @param b number 0-255
--- @param a number 0-255
local function apply_and_save_background(r, g, b, a)
    local UIConfig = _G.UIConfig or {}
    UIConfig.background = UIConfig.background or {}
    UIConfig.background.r = r
    UIConfig.background.g = g
    UIConfig.background.b = b
    UIConfig.background.a = a

    if _G.keybind_ui_display then
        _G.keybind_ui_display:bg_color(r, g, b)
        _G.keybind_ui_display:bg_alpha(a)
    end

    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.bg_r = r
        _G.keybind_saved_settings.bg_g = g
        _G.keybind_saved_settings.bg_b = b
        _G.keybind_saved_settings.bg_a = a
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Apply a named background preset (dark, light, blue, black, transparent...)
--- @param preset_name string Preset key from _G.UIConfig.background_presets
--- @return boolean True on success, false if preset missing/unknown
function Appearance.set_background_preset(preset_name)
    local UIConfig = _G.UIConfig or {}
    if not UIConfig.background_presets then
        MessageUI.show_error("Background presets not loaded")
        return false
    end

    local preset = UIConfig.background_presets[preset_name]
    if not preset then
        MessageUI.show_error("Unknown background preset: " .. preset_name)
        return false
    end

    apply_and_save_background(preset.r, preset.g, preset.b, preset.a)
    MessageUI.show_background_preset(preset_name, preset.r, preset.g, preset.b, preset.a)
    return true
end

--- Apply a custom RGBA background. Values are coerced to numbers and clamped to 0-255.
--- @param r number|string Red
--- @param g number|string Green
--- @param b number|string Blue
--- @param a number|string Alpha
--- @return boolean True on success, false on invalid input
function Appearance.set_background_rgba(r, g, b, a)
    r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

    if not r or not g or not b or not a then
        MessageUI.show_error("Invalid RGBA values. Use: //gs c ui bg <r> <g> <b> <a>")
        return false
    end

    -- Clamp values
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))
    a = math.max(0, math.min(255, a))

    apply_and_save_background(r, g, b, a)
    MessageUI.show_background_rgba(r, g, b, a)
    return true
end

--- Toggle background visibility (true/false), persisted to settings.
function Appearance.toggle_background()
    local UIConfig = _G.UIConfig or {}
    UIConfig.background = UIConfig.background or {}
    UIConfig.background.visible = not UIConfig.background.visible

    if _G.keybind_ui_display then
        _G.keybind_ui_display:bg_visible(UIConfig.background.visible)
    end

    MessageUI.show_toggle("Background", UIConfig.background.visible)

    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.bg_visible = UIConfig.background.visible
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Change the UI font. Only Consolas and Courier New are accepted.
--- @param font_name string User-supplied font name (case-insensitive)
--- @return boolean True on success, false on invalid font
function Appearance.set_font(font_name)
    local valid_fonts = {
        ["consolas"] = "Consolas",
        ["courier new"] = "Courier New",
        ["courier"] = "Courier New"  -- Redirect Courier to Courier New
    }

    local normalized = font_name:lower()
    local validated_font = valid_fonts[normalized]

    if not validated_font then
        MessageUI.show_error("Invalid font. Available: Consolas (default), Courier New")
        return false
    end

    -- Update config
    local UIConfig = _G.UIConfig or {}
    UIConfig.text = UIConfig.text or {}
    UIConfig.text.font = validated_font

    -- Apply to existing UI if active
    if _G.keybind_ui_display then
        _G.keybind_ui_display:font(validated_font)
    end

    MessageCore.show_ui_info("Font changed to: " .. validated_font)

    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.font_name = validated_font
        KeybindSettings.save(_G.keybind_saved_settings)
    end

    return true
end

return Appearance

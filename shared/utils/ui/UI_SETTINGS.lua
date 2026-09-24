---============================================================================
--- Keybind UI Settings - Persistent Settings with ui_settings.lua
---============================================================================
--- Adapter between the flat settings table used by the UI modules
--- (_G.keybind_saved_settings) and the getters/setters of
--- shared/config/ui_settings.lua, which writes the settings file.
---
--- @file shared/utils/ui/UI_SETTINGS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-03
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local UISettingsManager = require('shared/config/ui_settings')

local KeybindSettings = {}

--- Load the persisted settings into a flat table.
--- @return table Settings: pos, visible, enabled, show_* flags, bg_*, font_size, font_name
function KeybindSettings.load()
    local pos = UISettingsManager.get_position()
    local bg = UISettingsManager.get_background()
    local font = UISettingsManager.get_font()

    return {
        pos = pos,
        visible = UISettingsManager.get_enabled(),
        enabled = UISettingsManager.get_enabled(),
        show_header = UISettingsManager.get_show_header(),
        show_legend = UISettingsManager.get_show_legend(),
        show_column_headers = UISettingsManager.get_show_column_headers(),
        show_footer = UISettingsManager.get_show_footer(),
        bg_r = bg.r,
        bg_g = bg.g,
        bg_b = bg.b,
        bg_a = bg.a,
        bg_visible = bg.visible,
        font_size = font.size,
        font_name = font.name
    }
end

--- Save settings through ui_settings.lua. Only fields that are present are
--- written; each setter call may rewrite the settings file.
--- @param settings table Flat settings table (same shape as load() returns)
--- @return boolean Always true
function KeybindSettings.save(settings)
    -- Save position
    if settings.pos then
        UISettingsManager.set_position(settings.pos.x, settings.pos.y)
    end

    -- Save visibility settings
    if settings.enabled ~= nil then
        UISettingsManager.set_enabled(settings.enabled)
    end

    if settings.show_header ~= nil then
        UISettingsManager.set_show_header(settings.show_header)
    end

    if settings.show_legend ~= nil then
        UISettingsManager.set_show_legend(settings.show_legend)
    end

    if settings.show_column_headers ~= nil then
        UISettingsManager.set_show_column_headers(settings.show_column_headers)
    end

    if settings.show_footer ~= nil then
        UISettingsManager.set_show_footer(settings.show_footer)
    end

    -- Save background settings
    if settings.bg_r or settings.bg_g or settings.bg_b or settings.bg_a then
        local bg = UISettingsManager.get_background()
        UISettingsManager.set_background(
            settings.bg_r or bg.r,
            settings.bg_g or bg.g,
            settings.bg_b or bg.b,
            settings.bg_a or bg.a
        )
    end

    if settings.bg_visible ~= nil then
        UISettingsManager.set_background_visible(settings.bg_visible)
    end

    -- Save font settings
    if settings.font_name or settings.font_size then
        UISettingsManager.set_font(settings.font_name, settings.font_size)
    end

    return true
end

return KeybindSettings

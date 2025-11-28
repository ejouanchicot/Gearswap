---============================================================================
--- Keybind UI Settings - Persistent Settings with ui_settings.lua
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local UISettingsManager = require('shared/config/ui_settings')

local KeybindSettings = {}

--- Load settings from ui_settings.lua (new system)
function KeybindSettings.load()
    -- Load from new persistent settings system
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

--- Save settings to ui_settings.lua (new system)
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

---============================================================================
--- UI Settings Resolver - Build texts-library settings from UIConfig + persistence
---============================================================================
--- Resolves the various sources of UI configuration (defaults, _G.UIConfig,
--- saved position from KeybindSettings, _G.ui_display_config) into a single
--- table in the shape that the `texts` Windower library expects.
---
--- Extracted from UI_MANAGER.lua to keep that file focused on lifecycle,
--- state-change tracking and rendering.
---
--- @file shared/utils/ui/ui_settings_resolver.lua
--- @author Tetsouo
--- @date Created: 2026-05-08
---============================================================================

local UISettingsResolver = {}

local KeybindSettings = require('shared/utils/ui/UI_SETTINGS')

---============================================================================
--- POSITION OFFSET CALCULATION
---============================================================================

--- Calculate Y offset based on hidden UI elements.
--- The display has optional sections (header / column headers / legend);
--- when they're hidden the visible content moves up, and we shift Y down by
--- the equivalent number of lines so the text appears in the same screen
--- location regardless of which sections are toggled.
--- @return number Y offset (in pixels) to apply
function UISettingsResolver.calculate_y_offset()
    local offset = 0

    -- Get current font size from saved settings
    local UISettingsManager = require('shared/config/ui_settings')
    local font = UISettingsManager.get_font()
    local text_size = font.size or 10
    local line_height = text_size + 4  -- Font size + spacing

    -- Add offset for hidden header (title + separator + legend if visible)
    if not _G.ui_display_config.show_header then
        offset = offset + (line_height * 2)  -- Title + separator
        if _G.ui_display_config.show_legend then
            offset = offset + (line_height * 2)  -- Legend takes ~2 lines
        end
    end

    -- Add offset for hidden column headers
    if not _G.ui_display_config.show_column_headers then
        offset = offset + (line_height * 1)
    end

    return offset
end

---============================================================================
--- BACKGROUND SETTINGS
---============================================================================

--- Convert simplified RGBA format from persisted settings to the field names
--- that the `texts` library expects (red/green/blue/alpha/visible).
--- @return table Background settings in texts-library format
function UISettingsResolver.get_background_settings()
    local UISettingsManager = require('shared/config/ui_settings')
    local bg = UISettingsManager.get_background()

    return {
        red = bg.r,
        green = bg.g,
        blue = bg.b,
        alpha = bg.a,
        visible = bg.visible
    }
end

---============================================================================
--- FULL UI SETTINGS BUILDER
---============================================================================

--- Build the complete UI settings table for the `texts` library.
--- Always re-reads saved position via KeybindSettings.load() so the latest
--- on-disk values are picked up (relevant after the user drags the UI to a
--- new position and we persist it).
--- @return table Complete settings table {pos, text, bg, flags}
function UISettingsResolver.create_ui_settings()
    local UIConfig = _G.UIConfig or {}

    -- ALWAYS reload saved settings (picks up latest position from disk)
    local saved_settings = KeybindSettings.load()
    _G.keybind_saved_settings = saved_settings

    local saved_pos = saved_settings and saved_settings.pos or nil
    local default_x = 1600
    local default_y = 300
    local base_x = (saved_pos and saved_pos.x) or default_x
    local base_y = (saved_pos and saved_pos.y) or default_y

    return {
        pos = {
            x = base_x,
            y = base_y + (UISettingsResolver.calculate_y_offset() or 0)
        },
        text = {
            size = saved_settings.font_size or 10,
            font = saved_settings.font_name or 'Consolas',
            stroke = (UIConfig.text and UIConfig.text.stroke) or { width = 2, alpha = 200, red = 0, green = 0, blue = 0 },
            padding = 0
        },
        bg = UISettingsResolver.get_background_settings(),
        flags = UIConfig.flags or { draggable = true }
    }
end

---============================================================================
--- DEFAULT UI SETTINGS (used before saved position is loaded)
---============================================================================

--- Return a static default settings table with hardcoded fallback values.
--- Used at module-init time before the saved position file is read; init()
--- replaces it with create_ui_settings() output.
--- @return table Default settings table
function UISettingsResolver.default_ui_settings()
    return {
        pos = {
            x = 1600,
            y = 300
        },
        text = {
            size = 10,
            font = 'Consolas',
            stroke = { width = 2, alpha = 200, red = 0, green = 0, blue = 0 },
            padding = 0
        },
        bg = {
            red = 0,
            green = 0,
            blue = 0,
            alpha = 150,
            visible = true
        },
        flags = { draggable = true }
    }
end

return UISettingsResolver

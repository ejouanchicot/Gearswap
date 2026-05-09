---============================================================================
--- UI Section Toggles - Header / Legend / Column Headers / Footer
---============================================================================
--- Toggles for the four optional UI sections. Three of them (header, legend,
--- column headers) are at the TOP of the UI so toggling them shifts the Y
--- position; this module compensates by computing the Y delta and re-anchoring
--- the texts element so the visible content stays in place.
---
--- The footer is at the bottom and needs no Y adjustment.
---
--- Replaces 3x duplicated functions in UI_MANAGER.lua with one private helper.
---
--- @file ui/ui_section_toggles.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local KeybindSettings    = require('shared/utils/ui/UI_SETTINGS')
local MessageUI          = require('shared/utils/messages/formatters/ui/message_ui')
local UISettingsResolver = require('shared/utils/ui/ui_settings_resolver')
local Display            = require('shared/utils/ui/ui_display')

local SectionToggles = {}

local calculate_y_offset = UISettingsResolver.calculate_y_offset

--- Generic toggle for top-anchored sections.
--- Calculates Y offset before/after toggling the flag, then re-anchors the
--- texts element so the rest of the UI stays at the same screen position.
--- Persists the new flag value to keybind_saved_settings.
--- @param flag_key string Key in _G.ui_display_config (e.g. "show_header")
--- @param label string Display label for the toggle message (e.g. "Header")
local function toggle_top_section(flag_key, label)
    if not _G.keybind_ui_display then return end

    local old_offset = calculate_y_offset()
    _G.ui_display_config[flag_key] = not _G.ui_display_config[flag_key]
    local new_offset = calculate_y_offset()

    -- Re-anchor to keep visible content stationary
    local current_x, current_y = _G.keybind_ui_display:pos()
    local adjusted_y = current_y - (new_offset - old_offset)
    _G.keybind_ui_display:pos(current_x, adjusted_y)

    Display.update_display()
    MessageUI.show_toggle(label, _G.ui_display_config[flag_key])

    if _G.keybind_saved_settings then
        _G.keybind_saved_settings[flag_key] = _G.ui_display_config[flag_key]
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Toggle the title/header section
function SectionToggles.toggle_header()
    toggle_top_section("show_header", "Header")
end

--- Toggle the legend section
function SectionToggles.toggle_legend()
    toggle_top_section("show_legend", "Legend")
end

--- Toggle the column headers row
function SectionToggles.toggle_column_headers()
    toggle_top_section("show_column_headers", "Column Headers")
end

--- Toggle the footer (bottom-anchored, no Y adjustment needed)
function SectionToggles.toggle_footer()
    if not _G.keybind_ui_display then return end

    _G.ui_display_config.show_footer = not _G.ui_display_config.show_footer

    Display.update_display()
    MessageUI.show_toggle("Footer", _G.ui_display_config.show_footer)

    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.show_footer = _G.ui_display_config.show_footer
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

return SectionToggles

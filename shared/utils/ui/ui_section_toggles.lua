---============================================================================
--- UI Section Toggles - Header / Legend / Column Headers / Footer
---============================================================================
--- Toggles for the four optional UI sections. Three of them (header, legend,
--- column headers) are at the TOP of the UI so toggling them shifts the Y
--- position; this module compensates by computing the Y delta and re-anchoring
--- the texts element so the visible content stays in place.
--- The shift is measured, not estimated: the number of lines the toggle adds
--- or removes (margins included - some only appear when another section is
--- hidden) times the real line height, taken from the box's rendered height.
--- The new position is saved, so a reload puts the box where it is now.
---
--- The footer is at the bottom and needs no Y adjustment.
---
--- @file shared/utils/ui/ui_section_toggles.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-09
---============================================================================

local KeybindSettings    = require('shared/utils/ui/UI_SETTINGS')
local MessageUI          = require('shared/utils/messages/formatters/ui/message_ui')
local Display            = require('shared/utils/ui/ui_display')
local Trace = require('shared/utils/debug/trace_log')

local SectionToggles = {}

--- Number of displayed lines in a texts content string.
--- @param text string|nil
--- @return number
local function line_count(text)
    if not text or text == '' then return 0 end
    local _, newlines = text:gsub('\n', '')
    return newlines + (text:sub(-1) == '\n' and 0 or 1)
end

--- Line heights learned from real toggles, per font size. Kept on `windower`
--- so they survive gs reload and job changes (relearned after a restart).
--- Measured in game: 16 px per line at the default size, while the box
--- height also carries a fixed ~19 px of border, so height / lines is off.
local function learned_heights()
    windower._hud_line_height = windower._hud_line_height or {}
    return windower._hud_line_height
end

--- Pixel height of one line: the learned value when there is one, else the
--- box height divided by its lines (a few px too big: see above), else
--- font size + 4.
--- @param display table texts object
--- @param lines number Lines currently displayed
--- @return number
local function measured_line_height(display, lines)
    local learned = learned_heights()[display:size() or 10]
    if learned then return learned end
    local _, height = display:extents()
    if height and height > 0 and lines > 0 then
        return height / lines
    end
    return (display:size() or 10) + 4
end

--- Save the box position (after a toggle moved it).
--- @param x number
--- @param y number
local function save_pos(x, y)
    if not _G.keybind_saved_settings then return end
    _G.keybind_saved_settings.pos = _G.keybind_saved_settings.pos or {}
    _G.keybind_saved_settings.pos.x = x
    _G.keybind_saved_settings.pos.y = y
    KeybindSettings.save(_G.keybind_saved_settings)
end

--- Bumped by every toggle, so a late correction from an older toggle is
--- dropped when another toggle came in meanwhile.
local toggle_seq = 0

--- Delay before re-reading the box height, once the new text is drawn.
local SETTLE_DELAY = 0.15

--- Where the box would be if the screen had no top edge. Keeping the keys
--- still near the top of the screen can call for a negative Y (seen in game:
--- -35 with header and legend on); the box is drawn at 0 instead, and this
--- unclamped value is what the next toggle starts from, so hiding the header
--- again brings the keys back exactly where they were.
--- @param y number Current drawn Y
--- @return number
local function virtual_y(y)
    local v = windower._hud_virtual_y
    if y <= 0 and v and v <= 0 then return v end
    return y
end

--- Draw the box at a virtual Y (clamped to the screen) and remember it.
--- @param display table texts object
--- @param x number
--- @param vy number Virtual Y
local function place(display, x, vy)
    windower._hud_virtual_y = vy
    display:pos(x, math.max(0, vy))
end

--- Generic toggle for top-anchored sections.
--- Moves the box by the height the toggle adds or removes above the keys, so
--- the keys stay at the same screen position, then saves flag and position.
--- The height is the box's own: the difference of its rendered height before
--- and after. If Windower has not re-measured the new text yet (it had not,
--- in game), the line count gives the shift, corrected once the text has been
--- drawn - and the real line height learned then makes the next toggles exact.
--- @param flag_key string Key in _G.ui_display_config (e.g. "show_header")
--- @param label string Display label for the toggle message (e.g. "Header")
local function toggle_top_section(flag_key, label)
    local display = _G.keybind_ui_display
    if not display then return end

    local old_lines = line_count(display:text())
    local line_height = measured_line_height(display, old_lines)
    local _, old_height = display:extents()
    local x, y = display:pos()
    local vy = virtual_y(y)

    _G.ui_display_config[flag_key] = not _G.ui_display_config[flag_key]
    Display.update_display()

    -- Lines removed above the keys: move the box down by as much, so the keys
    -- stay put (and up when lines are added).
    local new_lines = line_count(display:text())
    local _, new_height = display:extents()
    local shift
    if old_height and new_height and new_height ~= old_height then
        shift = old_height - new_height
    else
        shift = math.floor((old_lines - new_lines) * line_height + 0.5)
    end
    place(display, x, vy + shift)
    Trace.log('HUD', '%s=%s lines %d->%d height %s->%s line_h %.2f shift %s virtual y %s->%s drawn %s',
        flag_key, _G.ui_display_config[flag_key], old_lines, new_lines,
        old_height, new_height, line_height, shift, vy, vy + shift, math.max(0, vy + shift))

    MessageUI.show_toggle(label, _G.ui_display_config[flag_key])
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings[flag_key] = _G.ui_display_config[flag_key]
    end
    save_pos(x, vy + shift)

    toggle_seq = toggle_seq + 1
    local my_seq = toggle_seq
    coroutine.schedule(function()
        if my_seq ~= toggle_seq or _G.keybind_ui_display ~= display or not old_height then return end
        local _, settled = display:extents()
        if not settled then return end
        if new_lines ~= old_lines and settled ~= old_height then
            local exact = (settled - old_height) / (new_lines - old_lines)
            if exact > 0 then learned_heights()[display:size() or 10] = exact end
        end
        local error_px = (old_height - settled) - shift
        Trace.log('HUD', 'settled height %s (was %s) error %s', settled, old_height, error_px)
        if error_px ~= 0 then
            place(display, x, vy + shift + error_px)
            save_pos(x, vy + shift + error_px)
        end
    end, SETTLE_DELAY)
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

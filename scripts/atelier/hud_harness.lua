---============================================================================
--- HUD harness - GearSwap's own HUD code, run outside the game
---============================================================================
--- Renders the keybind HUD the way shared/utils/ui/ui_display.lua does in game
--- (UI_DISPLAY_BUILDER + UI_SECTIONS, the player's UI_CONFIG.lua, its saved
--- ui_settings.lua, UI_COLOR_CONFIG.lua and <JOB>_HUD.lua), from the rows and
--- values of an Atelier export instead of the live game. Used by the Atelier
--- page (atelier/app/js/hud_preview.js, Lua in WebAssembly) and by
--- scripts/atelier/gen_hud_sources.py (which records the files it needs).
---
--- Globals it reads, set by the caller before dofile:
---   HUD_ROOT  the folder holding data/ (with its last slash)
---   HUD_IN    {char, job, sub, keys = {{key, desc, state, ...}}, modes = {[name] = {current, values}}}
--- It sets HUD_OUT = {text = the HUD's text, meta = {font, size, bold, stroke..., bg...},
--- sections = {{bucket, title}} in their order, rows = {{desc, state}} in their order}.
---
--- @file    scripts/atelier/hud_harness.lua
--- @author  ejouanchicot
--- @date    Created: 2026-10-30
---============================================================================

local IN = HUD_IN
-- nothing is ever written: ui_settings.lua saves its file when it lines it up with UI_CONFIG.lua, and a preview run
-- on the real folder must not touch the player's saved/ui_settings.lua
local io_open = io.open
io.open = function(path, mode)
    if mode and mode:find('[wa+]') then
        return {write = function(self) return self end, close = function() return true end, flush = function() end, lines = function() return function() end end}
    end
    return io_open(path, mode)
end
package.path = HUD_ROOT .. 'data/?.lua;' .. package.path
player = {main_job = IN.job, sub_job = IN.sub, name = IN.char}
windower = {addon_path = HUD_ROOT, ffxi = {get_player = function() return player end, get_info = function() return {} end},
    get_dir = function() return {} end, add_to_chat = function() end, send_command = function() end,
    register_event = function() return 0 end, unregister_event = function() end}
add_to_chat = function() end
send_command = function() end

-- the player's UI_CONFIG.lua, as config_loader.lua reads it (shared/utils/config/config_loader.lua)
local ok, UIConfig = pcall(dofile, HUD_ROOT .. 'data/' .. IN.char .. '/_common/display/UI_CONFIG.lua')
if not ok or type(UIConfig) ~= 'table' then UIConfig = {} end
_G.UIConfig = UIConfig
local Settings = require('shared/config/ui_settings')
_G.ui_display_config = {
    enabled             = Settings.get_enabled(),
    show_header         = Settings.get_show_header(),
    show_legend         = Settings.get_show_legend(),
    show_column_headers = Settings.get_show_column_headers(),
    show_footer         = Settings.get_show_footer(),
}

local Builder = require('shared/utils/ui/UI_DISPLAY_BUILDER')
local Sections = require('shared/utils/ui/UI_SECTIONS')
local keybinds = IN.keys
local value = function(state) local m = state and IN.modes[state] return m and tostring(m.current) or '' end
local values = function(state) local m = state and IN.modes[state] return m and m.values or {} end
local text = Sections.render_complete_ui(Builder.build_display_structure(IN.job, keybinds), keybinds, IN.job, value, values)

-- what the page needs to know what a click or a drag in the preview touches: the sections in their order with their
-- titles, the rows in their order with their labels (ui_style.lua section_order / ordered_rows)
local UIStyle, Formatter = require('shared/utils/ui/ui_style'), require('shared/utils/ui/UI_FORMATTER')
local order, rows = {}, {}
for i, bucket in ipairs(UIStyle.section_order(IN.job)) do order[i] = {bucket = bucket, title = Formatter.get_section_title(IN.job, bucket)} end
for i, bind in ipairs(UIStyle.ordered_rows(UIStyle.visible_rows(keybinds))) do rows[i] = {desc = tostring(bind.desc or ''), state = bind.state or bind.key or ''} end
local s, txt = _G.UI_SETTINGS or {}, UIConfig.text or {}
local stroke, flags = txt.stroke or {}, UIConfig.flags or {}
HUD_OUT = {text = text, meta = {
    font = s.font_name or txt.font or 'Consolas', size = s.font_size or txt.size or 10, bold = flags.bold == true,
    stroke_width = stroke.width or 0, stroke_alpha = stroke.alpha or 255,
    stroke = {stroke.red or 0, stroke.green or 0, stroke.blue or 0},
    bg = {s.bg_r or 15, s.bg_g or 15, s.bg_b or 35, s.bg_a or 180}, bg_visible = s.bg_visible ~= false,
    enabled = _G.ui_display_config.enabled ~= false,
}, sections = order, rows = rows}
-- the caller writes the answer: files can be written again once the HUD is drawn
io.open = io_open

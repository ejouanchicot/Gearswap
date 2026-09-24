---  ═══════════════════════════════════════════════════════════════════════════
---   UI Settings - Persistent Configuration Storage (Per Character)
---  ═══════════════════════════════════════════════════════════════════════════
---   Global variables + file persistence for UI display settings.
---   Settings persist within session AND across //lua reload gearswap.
---
---   Features:
---     • Per-character settings ([CharName]/config/ui_settings.lua)
---     • Global variable storage (_G.UI_SETTINGS)
---     • Auto-load from file on startup
---     • Auto-save on every setting change
---     • 19 configurable parameters (position, visibility, background, font, sections)
---
---   Architecture:
---     • File persistence via dofile() and io.open()
---     • Default settings if file doesn't exist
---     • Getter/Setter functions for all settings
---     • Automatic file generation with formatted output
---
---   Configuration Categories:
---     • Position (pos_x, pos_y)
---     • Visibility (enabled, show_header, show_legend, show_column_headers, show_footer)
---     • Background (bg_r, bg_g, bg_b, bg_a, bg_visible)
---     • Font (font_name, font_size)
---     • Sections (section_spells, section_enhancing, section_job_abilities, section_weapons, section_modes)
---
---   Settings File:
---     • [CharName]/config/ui_settings.lua (one file per character)
---
---   @file    shared/config/ui_settings.lua
---   @author  Tetsouo
---   @version 1.1 - Refactored with new header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local UISettings = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEFAULTS (single source of truth)
---  ═══════════════════════════════════════════════════════════════════════════
---   Read from _G.UIConfig if available, else hardcoded fallback. Computed once,
---   on the first require in a sandbox. ConfigLoader.load_ui_config() sets
---   _G.UIConfig right before it requires this module. Entries that require
---   UI_MANAGER before config_loader (WAR, BST, PUP) reach this file first, so
---   the fallback is used there. The fallback visibility flags match
---   UI_CONFIG.lua, but the position (1600, 300) does not.

local function compute_defaults()
    local uc  = _G.UIConfig or {}
    local pos = uc.default_position or {}
    local bg  = uc.background or {}
    local txt = uc.text or {}
    local sec = uc.sections or {}
    return {
        pos_x                 = pos.x or 1600,
        pos_y                 = pos.y or 300,
        enabled               = uc.enabled ~= false,
        show_header           = uc.show_header == true,
        show_legend           = uc.show_legend ~= false,
        show_column_headers   = uc.show_column_headers == true,
        show_footer           = uc.show_footer == true,
        bg_r                  = bg.r or 15,
        bg_g                  = bg.g or 15,
        bg_b                  = bg.b or 35,
        bg_a                  = bg.a or 180,
        bg_visible            = bg.visible ~= false,
        font_size             = txt.size or 10,
        font_name             = txt.font or 'Consolas',
        section_spells        = sec.spells ~= false,
        section_enhancing     = sec.enhancing ~= false,
        section_job_abilities = sec.job_abilities ~= false,
        section_weapons       = sec.weapons ~= false,
        section_modes         = sec.modes ~= false,
    }
end

local D = compute_defaults()

---  ═══════════════════════════════════════════════════════════════════════════
---   FILE PERSISTENCE
---  ═══════════════════════════════════════════════════════════════════════════

--- Absolute path of the per-character settings file
--- @return string Path to [CharName]/config/ui_settings.lua
local function get_settings_path()
    local char_name = player and player.name or 'Tetsouo'

    -- Save in character's own config directory (using dynamic path)
    local base_path = windower.addon_path .. 'data/'
    return base_path .. char_name .. '/config/ui_settings.lua'
end

--- Load settings from file
--- @return table|nil Loaded settings or nil if file doesn't exist
local function load_from_file()
    local file_path = get_settings_path()

    -- Use dofile() instead of loadfile() (GearSwap environment)
    local success, settings = pcall(dofile, file_path)

    if success and settings and type(settings) == 'table' then
        return settings
    end

    return nil
end

--- Save settings to file
--- @param settings table Settings to save
--- @return boolean True if the file was written
local function save_to_file(settings)
    local file_path = get_settings_path()

    local file = io.open(file_path, 'w')
    if file then
        file:write('-- UI Settings (auto-generated)\n')
        file:write('-- Character: ' .. (player and player.name or 'Unknown') .. '\n')
        file:write('-- File: ' .. file_path .. '\n')
        file:write('return {\n')
        file:write('    -- Position\n')
        file:write(string.format('    pos_x = %d,\n', settings.pos_x or D.pos_x))
        file:write(string.format('    pos_y = %d,\n', settings.pos_y or D.pos_y))
        file:write('\n')
        file:write('    -- Visibility\n')
        file:write(string.format('    enabled = %s,\n', tostring(settings.enabled ~= false)))
        file:write(string.format('    show_header = %s,\n', tostring(settings.show_header == true)))
        file:write(string.format('    show_legend = %s,\n', tostring(settings.show_legend ~= false)))
        file:write(string.format('    show_column_headers = %s,\n', tostring(settings.show_column_headers == true)))
        file:write(string.format('    show_footer = %s,\n', tostring(settings.show_footer == true)))
        file:write('\n')
        file:write('    -- Background\n')
        file:write(string.format('    bg_r = %d,\n', settings.bg_r or D.bg_r))
        file:write(string.format('    bg_g = %d,\n', settings.bg_g or D.bg_g))
        file:write(string.format('    bg_b = %d,\n', settings.bg_b or D.bg_b))
        file:write(string.format('    bg_a = %d,\n', settings.bg_a or D.bg_a))
        file:write(string.format('    bg_visible = %s,\n', tostring(settings.bg_visible ~= false)))
        file:write('\n')
        file:write('    -- Font\n')
        file:write(string.format('    font_size = %d,\n', settings.font_size or D.font_size))
        file:write(string.format('    font_name = "%s",\n', settings.font_name or D.font_name))
        file:write('\n')
        file:write('    -- Sections\n')
        file:write(string.format('    section_spells = %s,\n', tostring(settings.section_spells ~= false)))
        file:write(string.format('    section_enhancing = %s,\n', tostring(settings.section_enhancing ~= false)))
        file:write(string.format('    section_job_abilities = %s,\n', tostring(settings.section_job_abilities ~= false)))
        file:write(string.format('    section_weapons = %s,\n', tostring(settings.section_weapons ~= false)))
        file:write(string.format('    section_modes = %s\n', tostring(settings.section_modes ~= false)))
        file:write('}\n')
        file:close()
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error('[UI_SETTINGS] ERROR: Cannot write to ' .. file_path)
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL SETTINGS STORAGE
---  ═══════════════════════════════════════════════════════════════════════════

-- ALWAYS try to load from file first (even if _G.UI_SETTINGS exists)
-- This ensures settings persist across //lua reload gearswap
local loaded = load_from_file()

if loaded then
    -- File exists, use it (overwrite any existing _G.UI_SETTINGS)
    _G.UI_SETTINGS = loaded
elseif _G.UI_SETTINGS == nil then
    -- No file AND no global variable: seed from defaults (read from UIConfig).
    -- Shallow-copy D so subsequent mutations to _G.UI_SETTINGS don't leak
    -- back into the module-local defaults table.
    _G.UI_SETTINGS = {}
    for k, v in pairs(D) do _G.UI_SETTINGS[k] = v end
    save_to_file(_G.UI_SETTINGS)
end
-- If file doesn't exist but _G.UI_SETTINGS exists, keep the global (in-session changes)

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS ACCESS - Position
---  ═══════════════════════════════════════════════════════════════════════════

--- @return table {x, y} saved HUD position
function UISettings.get_position()
    return {
        x = _G.UI_SETTINGS.pos_x or D.pos_x,
        y = _G.UI_SETTINGS.pos_y or D.pos_y
    }
end

--- Save the HUD position (floored to integers)
--- @param x number
--- @param y number
function UISettings.set_position(x, y)
    _G.UI_SETTINGS.pos_x = math.floor(x)
    _G.UI_SETTINGS.pos_y = math.floor(y)
    save_to_file(_G.UI_SETTINGS)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS ACCESS - Visibility
---  ═══════════════════════════════════════════════════════════════════════════

--- @return boolean True unless the HUD was explicitly disabled
function UISettings.get_enabled()
    return _G.UI_SETTINGS.enabled ~= false
end

--- @param value boolean
function UISettings.set_enabled(value)
    _G.UI_SETTINGS.enabled = value
    save_to_file(_G.UI_SETTINGS)
end

--- @return boolean True only if explicitly enabled
function UISettings.get_show_header()
    return _G.UI_SETTINGS.show_header == true
end

--- @param value boolean
function UISettings.set_show_header(value)
    _G.UI_SETTINGS.show_header = value
    save_to_file(_G.UI_SETTINGS)
end

--- @return boolean True unless explicitly disabled
function UISettings.get_show_legend()
    return _G.UI_SETTINGS.show_legend ~= false
end

--- @param value boolean
function UISettings.set_show_legend(value)
    _G.UI_SETTINGS.show_legend = value
    save_to_file(_G.UI_SETTINGS)
end

--- @return boolean True only if explicitly enabled
function UISettings.get_show_column_headers()
    return _G.UI_SETTINGS.show_column_headers == true
end

--- @param value boolean
function UISettings.set_show_column_headers(value)
    _G.UI_SETTINGS.show_column_headers = value
    save_to_file(_G.UI_SETTINGS)
end

--- @return boolean True only if explicitly enabled
function UISettings.get_show_footer()
    return _G.UI_SETTINGS.show_footer == true
end

--- @param value boolean
function UISettings.set_show_footer(value)
    _G.UI_SETTINGS.show_footer = value
    save_to_file(_G.UI_SETTINGS)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS ACCESS - Background
---  ═══════════════════════════════════════════════════════════════════════════

--- @return table {r, g, b, a, visible}
function UISettings.get_background()
    return {
        r = _G.UI_SETTINGS.bg_r or D.bg_r,
        g = _G.UI_SETTINGS.bg_g or D.bg_g,
        b = _G.UI_SETTINGS.bg_b or D.bg_b,
        a = _G.UI_SETTINGS.bg_a or D.bg_a,
        visible = _G.UI_SETTINGS.bg_visible ~= false
    }
end

--- @param r number Red (0-255)
--- @param g number Green (0-255)
--- @param b number Blue (0-255)
--- @param a number Alpha (0-255)
function UISettings.set_background(r, g, b, a)
    _G.UI_SETTINGS.bg_r = r
    _G.UI_SETTINGS.bg_g = g
    _G.UI_SETTINGS.bg_b = b
    _G.UI_SETTINGS.bg_a = a
    save_to_file(_G.UI_SETTINGS)
end

--- @param value boolean
function UISettings.set_background_visible(value)
    _G.UI_SETTINGS.bg_visible = value
    save_to_file(_G.UI_SETTINGS)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS ACCESS - Font
---  ═══════════════════════════════════════════════════════════════════════════

--- @return table {size, name}
function UISettings.get_font()
    return {
        size = _G.UI_SETTINGS.font_size or D.font_size,
        name = _G.UI_SETTINGS.font_name or D.font_name
    }
end

--- Save font settings; a nil argument leaves that field unchanged
--- @param name string|nil Font name
--- @param size number|nil Font size
function UISettings.set_font(name, size)
    if name then
        _G.UI_SETTINGS.font_name = name
    end
    if size then
        _G.UI_SETTINGS.font_size = size
    end
    save_to_file(_G.UI_SETTINGS)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SETTINGS ACCESS - Sections
---  ═══════════════════════════════════════════════════════════════════════════

--- @return table {spells, enhancing, job_abilities, weapons, modes} booleans
function UISettings.get_sections()
    return {
        spells = _G.UI_SETTINGS.section_spells ~= false,
        enhancing = _G.UI_SETTINGS.section_enhancing ~= false,
        job_abilities = _G.UI_SETTINGS.section_job_abilities ~= false,
        weapons = _G.UI_SETTINGS.section_weapons ~= false,
        modes = _G.UI_SETTINGS.section_modes ~= false
    }
end

--- @param section_name string Suffix of a section_* key (e.g. 'spells')
--- @param value boolean
function UISettings.set_section(section_name, value)
    local key = 'section_' .. section_name
    _G.UI_SETTINGS[key] = value
    save_to_file(_G.UI_SETTINGS)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return UISettings

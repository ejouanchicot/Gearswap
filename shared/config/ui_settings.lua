---============================================================================
--- UI Settings - Persistent Configuration Storage (Per Character)
---============================================================================
--- Global variables + file persistence for UI settings.
--- Settings persist within session AND across //lua reload gearswap.
---
--- Settings File:
---   shared/config/ui_settings_<CharName>.lua (one file per character)
---
--- @file ui_settings.lua
--- @author Tetsouo
--- @version 1.0 - Initial release with per-character files
--- @date Created: 2025-11-08
---============================================================================

local UISettings = {}

---============================================================================
--- FILE PERSISTENCE
---============================================================================

-- Get absolute path to settings file (per character)
local function get_settings_path()
    -- Detect character name from player data
    local char_name = player and player.name or 'Tetsouo'

    -- Save in character's own config directory
    local base_path = 'D:/Windower Tetsouo/addons/GearSwap/data/'
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
local function save_to_file(settings)
    local file_path = get_settings_path()

    -- Write settings to file
    local file = io.open(file_path, 'w')
    if file then
        file:write('-- UI Settings (auto-generated)\n')
        file:write('-- Character: ' .. (player and player.name or 'Unknown') .. '\n')
        file:write('-- File: ' .. file_path .. '\n')
        file:write('return {\n')
        file:write('    -- Position\n')
        file:write(string.format('    pos_x = %d,\n', settings.pos_x or 1600))
        file:write(string.format('    pos_y = %d,\n', settings.pos_y or 300))
        file:write('\n')
        file:write('    -- Visibility\n')
        file:write(string.format('    enabled = %s,\n', tostring(settings.enabled ~= false)))
        file:write(string.format('    show_header = %s,\n', tostring(settings.show_header ~= false)))
        file:write(string.format('    show_legend = %s,\n', tostring(settings.show_legend ~= false)))
        file:write(string.format('    show_column_headers = %s,\n', tostring(settings.show_column_headers ~= false)))
        file:write(string.format('    show_footer = %s,\n', tostring(settings.show_footer ~= false)))
        file:write('\n')
        file:write('    -- Background\n')
        file:write(string.format('    bg_r = %d,\n', settings.bg_r or 15))
        file:write(string.format('    bg_g = %d,\n', settings.bg_g or 15))
        file:write(string.format('    bg_b = %d,\n', settings.bg_b or 35))
        file:write(string.format('    bg_a = %d,\n', settings.bg_a or 180))
        file:write(string.format('    bg_visible = %s,\n', tostring(settings.bg_visible ~= false)))
        file:write('\n')
        file:write('    -- Font\n')
        file:write(string.format('    font_size = %d,\n', settings.font_size or 10))
        file:write(string.format('    font_name = "%s",\n', settings.font_name or 'Consolas'))
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
        add_to_chat(167, '[UI_SETTINGS] ERROR: Cannot write to ' .. file_path)
        return false
    end
end

---============================================================================
--- GLOBAL SETTINGS STORAGE
---============================================================================

-- ALWAYS try to load from file first (even if _G.UI_SETTINGS exists)
-- This ensures settings persist across //lua reload gearswap
local loaded = load_from_file()

if loaded then
    -- File exists, use it (overwrite any existing _G.UI_SETTINGS)
    _G.UI_SETTINGS = loaded
elseif _G.UI_SETTINGS == nil then
    -- No file AND no global variable: create defaults
    _G.UI_SETTINGS = {
        -- Position
        pos_x = 1600,
        pos_y = 300,

        -- Visibility
        enabled = true,
        show_header = false,
        show_legend = true,
        show_column_headers = false,
        show_footer = false,

        -- Background
        bg_r = 15,
        bg_g = 15,
        bg_b = 35,
        bg_a = 180,
        bg_visible = true,

        -- Font
        font_size = 10,
        font_name = 'Consolas',

        -- Sections
        section_spells = true,
        section_enhancing = true,
        section_job_abilities = true,
        section_weapons = true,
        section_modes = true
    }
    -- Save defaults to file
    save_to_file(_G.UI_SETTINGS)
end
-- If file doesn't exist but _G.UI_SETTINGS exists, keep the global (in-session changes)

---============================================================================
--- SETTINGS ACCESS - Position
---============================================================================

function UISettings.get_position()
    return {
        x = _G.UI_SETTINGS.pos_x or 1600,
        y = _G.UI_SETTINGS.pos_y or 300
    }
end

function UISettings.set_position(x, y)
    _G.UI_SETTINGS.pos_x = math.floor(x)
    _G.UI_SETTINGS.pos_y = math.floor(y)
    save_to_file(_G.UI_SETTINGS)
end

---============================================================================
--- SETTINGS ACCESS - Visibility
---============================================================================

function UISettings.get_enabled()
    return _G.UI_SETTINGS.enabled ~= false
end

function UISettings.set_enabled(value)
    _G.UI_SETTINGS.enabled = value
    save_to_file(_G.UI_SETTINGS)
end

function UISettings.get_show_header()
    return _G.UI_SETTINGS.show_header ~= false
end

function UISettings.set_show_header(value)
    _G.UI_SETTINGS.show_header = value
    save_to_file(_G.UI_SETTINGS)
end

function UISettings.get_show_legend()
    return _G.UI_SETTINGS.show_legend ~= false
end

function UISettings.set_show_legend(value)
    _G.UI_SETTINGS.show_legend = value
    save_to_file(_G.UI_SETTINGS)
end

function UISettings.get_show_column_headers()
    return _G.UI_SETTINGS.show_column_headers ~= false
end

function UISettings.set_show_column_headers(value)
    _G.UI_SETTINGS.show_column_headers = value
    save_to_file(_G.UI_SETTINGS)
end

function UISettings.get_show_footer()
    return _G.UI_SETTINGS.show_footer ~= false
end

function UISettings.set_show_footer(value)
    _G.UI_SETTINGS.show_footer = value
    save_to_file(_G.UI_SETTINGS)
end

---============================================================================
--- SETTINGS ACCESS - Background
---============================================================================

function UISettings.get_background()
    return {
        r = _G.UI_SETTINGS.bg_r or 15,
        g = _G.UI_SETTINGS.bg_g or 15,
        b = _G.UI_SETTINGS.bg_b or 35,
        a = _G.UI_SETTINGS.bg_a or 180,
        visible = _G.UI_SETTINGS.bg_visible ~= false
    }
end

function UISettings.set_background(r, g, b, a)
    _G.UI_SETTINGS.bg_r = r
    _G.UI_SETTINGS.bg_g = g
    _G.UI_SETTINGS.bg_b = b
    _G.UI_SETTINGS.bg_a = a
    save_to_file(_G.UI_SETTINGS)
end

function UISettings.set_background_visible(value)
    _G.UI_SETTINGS.bg_visible = value
    save_to_file(_G.UI_SETTINGS)
end

---============================================================================
--- SETTINGS ACCESS - Font
---============================================================================

function UISettings.get_font()
    return {
        size = _G.UI_SETTINGS.font_size or 10,
        name = _G.UI_SETTINGS.font_name or 'Consolas'
    }
end

function UISettings.set_font(name, size)
    if name then
        _G.UI_SETTINGS.font_name = name
    end
    if size then
        _G.UI_SETTINGS.font_size = size
    end
    save_to_file(_G.UI_SETTINGS)
end

---============================================================================
--- SETTINGS ACCESS - Sections
---============================================================================

function UISettings.get_sections()
    return {
        spells = _G.UI_SETTINGS.section_spells ~= false,
        enhancing = _G.UI_SETTINGS.section_enhancing ~= false,
        job_abilities = _G.UI_SETTINGS.section_job_abilities ~= false,
        weapons = _G.UI_SETTINGS.section_weapons ~= false,
        modes = _G.UI_SETTINGS.section_modes ~= false
    }
end

function UISettings.set_section(section_name, value)
    local key = 'section_' .. section_name
    _G.UI_SETTINGS[key] = value
    save_to_file(_G.UI_SETTINGS)
end

---============================================================================
--- EXPORT
---============================================================================

return UISettings

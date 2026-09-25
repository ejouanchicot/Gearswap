---============================================================================
--- UI Configuration - Centralized UI Display Settings
---============================================================================
--- User-configurable settings for the keybind UI display system.
---
--- The position, visibility, background, font and section values below are
--- only defaults: once config/ui_settings.lua exists (it is rewritten on every
--- UI setting change and by //gs c ui save), its values take precedence.
--- init_delay, text.stroke, flags and background_presets are always read here.
---
--- @file Tetsouo/config/UI_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-01
---============================================================================
local UIConfig = {}

---============================================================================
--- DISPLAY SETTINGS
---============================================================================

-- Enable/Disable UI on startup
UIConfig.enabled = true

-- Show/Hide header section (title + legend)
UIConfig.show_header = false

-- Show/Hide legend (Ctrl/Alt/Windows/Shift symbols explanation)
UIConfig.show_legend = true

-- Show/Hide column headers (Key | Function | Current)
UIConfig.show_column_headers = false

-- Show/Hide footer (//gs c ui command)
UIConfig.show_footer = false

---============================================================================
--- POSITION SETTINGS
---============================================================================

-- Default position (X, Y), used until config/ui_settings.lua saves one
UIConfig.default_position = {
    x = 1857,
    y = -24
}

---============================================================================
--- VISUAL SETTINGS
---============================================================================

-- Text settings
UIConfig.text = {
    size = 10, -- Font size
    font = 'Consolas', -- MONOSPACE font required for column alignment! (alternatives: 'Courier New', 'Lucida Console')
    stroke = {
        width = 1, -- Outline width
        alpha = 200, -- Outline opacity (0-255)
        red = 0, -- Outline color RGB
        green = 0,
        blue = 0
    }
}

-- Background settings (simplified RGBA format)
UIConfig.background = {
    r = 15, -- Red (0-255)
    g = 15, -- Green (0-255)
    b = 35, -- Blue (0-255) - Dark blue background
    a = 180, -- Alpha/Opacity (0-255) - More opaque for better visibility
    visible = true  -- Show background
}

-- Background presets for quick switching
UIConfig.background_presets = {
    -- Dark themes
    dark_blue = {
        r = 15,
        g = 15,
        b = 35,
        a = 180
    },
    dark_red = {
        r = 35,
        g = 10,
        b = 10,
        a = 180
    },
    dark_green = {
        r = 10,
        g = 35,
        b = 10,
        a = 180
    },
    dark_purple = {
        r = 30,
        g = 10,
        b = 35,
        a = 180
    },
    dark_cyan = {
        r = 10,
        g = 30,
        b = 35,
        a = 180
    },
    dark_orange = {
        r = 35,
        g = 20,
        b = 10,
        a = 180
    },
    dark_pink = {
        r = 35,
        g = 10,
        b = 25,
        a = 180
    },
    black = {
        r = 0,
        g = 0,
        b = 0,
        a = 180
    },
    -- Light themes
    light_blue = {
        r = 150,
        g = 180,
        b = 220,
        a = 150
    },
    light_red = {
        r = 220,
        g = 150,
        b = 150,
        a = 150
    },
    light_green = {
        r = 150,
        g = 220,
        b = 150,
        a = 150
    },
    light_purple = {
        r = 200,
        g = 150,
        b = 220,
        a = 150
    },
    light_cyan = {
        r = 150,
        g = 220,
        b = 220,
        a = 150
    },
    light_orange = {
        r = 220,
        g = 180,
        b = 150,
        a = 150
    },
    light_pink = {
        r = 220,
        g = 150,
        b = 200,
        a = 150
    },
    light_gray = {
        r = 180,
        g = 180,
        b = 180,
        a = 150
    },
    -- Medium themes
    blue = {
        r = 20,
        g = 40,
        b = 80,
        a = 180
    },
    red = {
        r = 80,
        g = 20,
        b = 20,
        a = 180
    },
    green = {
        r = 20,
        g = 80,
        b = 20,
        a = 180
    },
    purple = {
        r = 60,
        g = 20,
        b = 80,
        a = 180
    },
    cyan = {
        r = 20,
        g = 70,
        b = 80,
        a = 180
    },
    orange = {
        r = 80,
        g = 40,
        b = 20,
        a = 180
    },
    pink = {
        r = 80,
        g = 20,
        b = 60,
        a = 180
    },
    yellow = {
        r = 80,
        g = 80,
        b = 20,
        a = 180
    },
    -- Transparent themes
    transparent_dark = {
        r = 0,
        g = 0,
        b = 0,
        a = 100
    },
    transparent_blue = {
        r = 10,
        g = 20,
        b = 40,
        a = 100
    },
    transparent_red = {
        r = 40,
        g = 10,
        b = 10,
        a = 100
    },
    transparent_green = {
        r = 10,
        g = 40,
        b = 10,
        a = 100
    },
    transparent_purple = {
        r = 30,
        g = 10,
        b = 40,
        a = 100
    },
    -- Vivid/Neon themes
    neon_blue = {
        r = 0,
        g = 50,
        b = 150,
        a = 200
    },
    neon_red = {
        r = 150,
        g = 0,
        b = 50,
        a = 200
    },
    neon_green = {
        r = 0,
        g = 150,
        b = 50,
        a = 200
    },
    neon_purple = {
        r = 120,
        g = 0,
        b = 150,
        a = 200
    },
    neon_pink = {
        r = 150,
        g = 0,
        b = 100,
        a = 200
    },
    neon_cyan = {
        r = 0,
        g = 150,
        b = 150,
        a = 200
    },
    neon_yellow = {
        r = 150,
        g = 150,
        b = 0,
        a = 200
    }
}

-- UI flags
UIConfig.flags = {
    draggable = true, -- Allow dragging
    bold = true -- Bold text
}

---============================================================================
--- SECTION SETTINGS
---============================================================================

-- Show/Hide specific sections
UIConfig.sections = {
    spells = true, -- Show spells/abilities section
    enhancing = true, -- Show enhancing section (RDM)
    job_abilities = true, -- Show JA section
    weapons = true, -- Show weapons section
    modes = true -- Show modes section
}

---============================================================================
--- HUD LAYOUT
---============================================================================
-- Every option below is optional: delete it or comment it out and the HUD
-- keeps its standard look. A wrong value is reported in chat when the job
-- loads, and the standard value is used instead - the HUD never breaks.
-- The values written here ARE the standard ones.

UIConfig.layout = {
    -- Order of the HUD sections. Names: 'spells', 'enhancing', 'abilities',
    -- 'weapons', 'modes'. A section missing from the list goes at the end
    -- (to hide a section, use UIConfig.sections above).
    section_order = {'spells', 'enhancing', 'abilities', 'weapons', 'modes'},

    -- true = tighter HUD: no blank line under section titles, columns
    -- closer together. The window width follows by itself.
    compact = false,

    -- Spaces between the key and the label. Leave it commented for the
    -- standard gap (4, or 2 with compact).
    -- column_gap = 3,

    -- Spaces between the label and the value (same standard as above;
    -- follows column_gap when only column_gap is set). The label column
    -- is as wide as the longest label, so short labels keep extra room.
    -- value_gap = 1,

    -- Blank lines above and below the rows (0 to 3). Standard: 1, or 0 with
    -- compact.
    -- margin_top = 0,
    -- margin_bottom = 0,

    -- Spaces left and right of the rows (0 to 3). Standard: 2, or 1 with
    -- compact.
    -- margin_side = 0,

    -- Pixels of background around the text (0 to 20), finer than a blank
    -- line. Standard: 0, or 4 with compact. Applied when the HUD is created
    -- (//lua reload gearswap).
    -- padding = 4,

    -- How keys are written: 'symbols' (^f1  !1  ~f9) or 'words'
    -- (CTRL+F1  ALT+1  SHIFT+F9). With 'words' the symbol legend is hidden.
    key_style = 'symbols',

    -- Symbol in front of each current value: a name (dot, circle, square,
    -- smallsquare, triangle, diamond, arrow, gt, dash, star, none) or the
    -- symbol itself.
    bullet = '●',

    -- Show a row in another section. Left: the state name (as written in the
    -- job's _KEYBINDS file) or the key. Right: the section name.
    move_to_section = {
        -- CombatMode = 'weapons',
    },

    -- Order of the rows inside each section: the rows named here come
    -- first, in this order, the others after them as usual. State names
    -- (as in the job's _KEYBINDS file) or keys. On ONE line (the in-game
    -- //gs c ui roworder rewrites it).
    -- row_order = {'MainWeapon', 'SubWeapon', 'CombatMode'},

    -- Rows to hide from the HUD (the key still works). State name or key.
    hide_rows = {
        -- 'Storm', '^f8',
    },

    -- Legend texts (shown with the header), two per line, up to 8.
    -- legend = {'^ = Ctrl', '! = Alt', '@ = Windows', '~ = Shift'},

    -- Rename section titles, for every job.
    section_titles = {
        -- weapons = 'Armes', modes = 'Modes', spells = 'Sorts',
    },
}

---============================================================================
--- HUD COLORS
---============================================================================
-- {red, green, blue}, each 0-255. Uncomment a line to change that color;
-- a commented line keeps the standard color shown.

UIConfig.colors = {
    -- title = {255, 255, 255},          -- job title (header)
    -- section_title = {120, 220, 255},  -- section titles
    -- key = {125, 125, 125},            -- the keys (standard: same as description)
    -- description = {180, 180, 180},   -- row labels
    -- value = {255, 255, 255},          -- current values (standard: automatic, Fire in red...)
    -- legend = {255, 215, 0},           -- the "^ = Ctrl" legend
    -- separator = {80, 160, 255},       -- ===== lines of the HUD
    -- footer = {128, 128, 128},         -- //gs c ui footer
    -- column_key = {100, 180, 255},     -- "Key" column header
    -- column_function = {120, 200, 255},-- "Function" column header
    -- column_current = {140, 220, 255}, -- "Current" column header
}

---============================================================================
--- CHAT
---============================================================================

UIConfig.chat = {
    -- The ===== line printed in chat after spells and abilities.
    separators = true,

    -- Character of that line. Plain characters only (= - * ~ #): the FFXI
    -- chat cannot show symbols such as a box-drawing line.
    separator_char = '=',

    -- Characters per ===== line, in the line above and in the framed chat
    -- blocks (help, warp, lists...). 20 to 150, standard 69.
    -- width = 69,

    -- The [RDM/DRK] in front of chat messages.
    job_tag = true,

    -- Chat colors, as FFXI chat color numbers 1-255, on ONE line (the
    -- in-game //gs c ui chatcolor rewrites this line). Two kinds of names:
    --   colors: gray green red yellow cyan lightblue white blue purple pink
    --           orange darkgray itemcolor healgreen enhancing enfeebling
    --           divine dark bluemagic (+ jobtag separatorcolor spellcolor
    --           warningcolor, which follow their color unless set)
    --   uses:   success error warning info cooldown spell ja ws debuff
    --           ready active blocked header job_tag ... (follow their color)
    -- Example: colors = {green = 204, cooldown = 167},
    -- colors = {},

    -- FFXI chat color number, 1-255 (standard: 160, grey).
    -- separator_color = 160,
}

---============================================================================
--- ADVANCED SETTINGS
---============================================================================

-- UI initialization delay (when first loading job file)
-- Delay before showing UI to ensure all systems are ready
-- Recommended: 5.0 seconds
UIConfig.init_delay = 5.0

-- The four settings below are not read by any module at present.
-- The position is saved with //gs c ui save.
UIConfig.auto_save_position = false
UIConfig.auto_save_delay = 1.5
UIConfig.debug = false
UIConfig.update_throttle = 0

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Validate configuration (no caller at present)
--- @return boolean valid True when no issue was found
--- @return table issues List of problem descriptions
function UIConfig.validate()
    local issues = {}

    -- Check required fields
    if type(UIConfig.enabled) ~= 'boolean' then
        table.insert(issues, 'enabled must be boolean')
    end

    if
        type(UIConfig.default_position) ~= 'table' or type(UIConfig.default_position.x) ~= 'number' or
            type(UIConfig.default_position.y) ~= 'number'
     then
        table.insert(issues, 'default_position must have x and y numbers')
    end

    if type(UIConfig.text.size) ~= 'number' or UIConfig.text.size < 1 then
        table.insert(issues, 'text.size must be positive number')
    end

    return #issues == 0, issues
end

return UIConfig

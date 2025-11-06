---============================================================================
--- UI Configuration - Centralized UI Display Settings
---============================================================================
--- User-configurable settings for the keybind UI display system.
--- Modify these settings to customize your UI experience.
---
--- @file config/UI_CONFIG.lua
--- @author Kaories
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

-- Default position (X, Y)
-- Will be overridden by saved position if ui_position.lua exists
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
        width = 1, -- Outline width (reduced from 2 to prevent text clipping)
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
--- COLOR CUSTOMIZATION (Optional)
---============================================================================

-- Override default colors (nil = use system defaults)
UIConfig.colors = {
    header_separator = nil, -- "\\cs(100,150,255)" format
    section_title = nil,
    key_text = nil,
    description_text = nil,
    value_text = nil
}

---============================================================================
--- ADVANCED SETTINGS
---============================================================================

-- UI initialization delay (when first loading job file)
-- Delay before showing UI to ensure all systems are ready
-- Recommended: 5.0 seconds
UIConfig.init_delay = 5.0

-- Auto-save position on drag (requires prerender event)
-- Set to false for manual save only (//gs c uisave)
UIConfig.auto_save_position = false

-- Auto-save delay in seconds (if auto_save enabled)
UIConfig.auto_save_delay = 1.5

-- Show debug messages
UIConfig.debug = false

-- Update frequency (lower = more responsive, higher = better performance)
-- 0 = update only on state change
-- 1-10 = update every N frames
UIConfig.update_throttle = 0

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Validate configuration
--- @return boolean, table valid, issues
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

--- Print current configuration (for debugging)
function UIConfig.print_config()
    add_to_chat(123, '=== UI Configuration ===')
    add_to_chat(123, 'Enabled: ' .. tostring(UIConfig.enabled))
    add_to_chat(123, 'Show Header: ' .. tostring(UIConfig.show_header))
    add_to_chat(123, 'Show Legend: ' .. tostring(UIConfig.show_legend))
    add_to_chat(123, 'Position: ' .. UIConfig.default_position.x .. ', ' .. UIConfig.default_position.y)
    add_to_chat(123, 'Font: ' .. UIConfig.text.font .. ' (' .. UIConfig.text.size .. ')')
end

return UIConfig

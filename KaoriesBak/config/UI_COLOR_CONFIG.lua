---============================================================================
--- UI Color Configuration - Centralized Color Customization
---============================================================================
--- User-configurable color settings for all UI elements across all jobs.
--- Modify RGB values to customize colors according to your preferences.
---
--- @file config/UI_COLOR_CONFIG.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-03
---
--- Color Format: { r, g, b }
---   r = Red   (0-255)
---   g = Green (0-255)
---   b = Blue  (0-255)
---============================================================================
local UIColorConfig = {}

---============================================================================
--- ELEMENT COLORS (Runes, Spells, Bar Elements)
---============================================================================

UIColorConfig.elements = {
    -- Basic Elements
    Fire = {255, 100, 100}, -- Red
    Water = {100, 150, 255}, -- Blue
    Lightning = {255, 150, 255}, -- Purple-Pink
    Ice = {150, 200, 255}, -- Light Blue
    Wind = {150, 255, 150}, -- Green
    Earth = {200, 150, 100}, -- Brown
    Light = {255, 255, 255}, -- White
    Dark = {150, 100, 200}, -- Purple

    -- Spell Name Aliases (for compatibility)
    Thunder = {255, 150, 255}, -- Lightning
    Aero = {150, 255, 150}, -- Wind
    Stone = {200, 150, 100}, -- Earth
    Blizzard = {150, 200, 255} -- Ice
}

---============================================================================
--- STAT COLORS (Etudes, Gain Spells)
---============================================================================

UIColorConfig.stats = {
    STR = {255, 100, 100}, -- Red (Fire-based)
    DEX = {255, 150, 255}, -- Purple (Lightning-based)
    VIT = {200, 150, 100}, -- Brown (Earth-based)
    AGI = {150, 255, 150}, -- Green (Wind-based)
    INT = {150, 100, 200}, -- Dark Purple (Dark-based)
    MND = {150, 200, 255}, -- Light Blue (Ice/Water-based)
    CHR = {255, 255, 255} -- White (Light-based)
}

---============================================================================
--- BAR SPELL COLORS
---============================================================================

UIColorConfig.bar_spells = {
    -- Bar Element Spells (Barfira, Barblizzara, etc.)
    element = {
        Barfira = {255, 100, 100}, -- Fire
        Barblizzara = {150, 200, 255}, -- Ice
        Baraera = {150, 255, 150}, -- Wind
        Barstonra = {200, 150, 100}, -- Earth
        Barthundra = {255, 150, 255}, -- Lightning
        Barwatera = {100, 150, 255} -- Water
    },

    -- Bar Ailment Spells (Barsilence, Barparalyze, etc.)
    ailment = {255, 200, 150} -- Light Orange (universal color)
}

---============================================================================
--- SPECIAL SPELL COLORS
---============================================================================

UIColorConfig.spells = {
    -- En Spells (Enfire, Enblizzard, etc.)
    en = {
        Enfire = {255, 100, 100}, -- Fire
        Enblizzard = {150, 200, 255}, -- Ice
        Enaero = {150, 255, 150}, -- Wind
        Enstone = {200, 150, 100}, -- Earth
        Enthunder = {255, 150, 255}, -- Lightning
        Enwater = {100, 150, 255} -- Water
    },

    -- Spike Spells
    spikes = {
        ["Blaze Spikes"] = {255, 100, 100}, -- Fire
        ["Ice Spikes"] = {150, 200, 255}, -- Ice
        ["Shock Spikes"] = {255, 150, 255} -- Lightning
    },

    -- Storm Spells (SCH)
    storms = {
        Firestorm = {255, 100, 100}, -- Fire
        Sandstorm = {200, 150, 100}, -- Earth
        Thunderstorm = {255, 150, 255}, -- Lightning
        Hailstorm = {150, 200, 255}, -- Ice
        Windstorm = {150, 255, 150}, -- Wind
        Rainstorm = {100, 150, 255}, -- Water
        Voidstorm = {150, 100, 200}, -- Dark
        Aurorastorm = {255, 255, 255} -- Light
    }
}

---============================================================================
--- JOB-SPECIFIC COLORS
---============================================================================

UIColorConfig.jobs = {
    -- COR Quick Draw Shots
    quick_draw = {
        ["Fire Shot"] = {255, 100, 100}, -- Fire
        ["Ice Shot"] = {150, 200, 255}, -- Ice
        ["Wind Shot"] = {150, 255, 150}, -- Wind
        ["Earth Shot"] = {200, 150, 100}, -- Earth
        ["Thunder Shot"] = {255, 150, 255}, -- Lightning
        ["Water Shot"] = {100, 150, 255}, -- Water
        ["Light Shot"] = {255, 255, 255}, -- Light
        ["Dark Shot"] = {150, 100, 200}, -- Dark
        ["Burning Shot"] = {255, 100, 100}, -- Fire
        ["Freezing Shot"] = {150, 200, 255}, -- Ice
        ["Flaming Shot"] = {255, 100, 100}, -- Fire
        ["Lightning Shot"] = {255, 150, 255}, -- Lightning
        ["Aqua Shot"] = {100, 150, 255}, -- Water
        ["Blast Shot"] = {150, 255, 150}, -- Wind
        ["Slug Shot"] = {200, 150, 100}, -- Earth
        ["Sniper Shot"] = {255, 255, 255}, -- Light
        ["Chaos Shot"] = {150, 100, 200}, -- Dark
        ["Fiery Shot"] = {255, 100, 100}, -- Fire
        ["Icy Shot"] = {150, 200, 255} -- Ice
    },

    -- RUN Runes (uses elements table, defined here for reference)
    runes = {
        -- Uses UIColorConfig.elements (Ignis = Fire, Gelus = Ice, etc.)
    }
}

---============================================================================
--- MODE COLORS (Combat Modes, States)
---============================================================================

UIColorConfig.modes = {
    PDT = {255, 200, 100}, -- Orange (Physical Defense)
    MDT = {150, 200, 255}, -- Light Blue (Magical Defense)
    Normal = {150, 255, 150} -- Green (Normal mode)
}

---============================================================================
--- BOOLEAN/SPECIAL VALUES
---============================================================================

UIColorConfig.special = {
    ["true"] = {150, 255, 150}, -- Green (enabled/active)
    ["false"] = {255, 100, 100}, -- Red (disabled/inactive)
    unknown = {128, 128, 128}, -- Gray (unknown/N/A)
    default = {255, 255, 255} -- White (default fallback)
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Convert RGB table to color code string
--- @param rgb table { r, g, b }
--- @return string Color code "\\cs(r,g,b)"
function UIColorConfig.rgb_to_code(rgb)
    if not rgb or #rgb < 3 then
        return "\\cs(255,255,255)" -- White fallback
    end
    return string.format("\\cs(%d,%d,%d)", rgb[1], rgb[2], rgb[3])
end

--- Get element color code
--- @param element string Element name (Fire, Ice, etc.)
--- @return string Color code
function UIColorConfig.get_element_color(element)
    local rgb = UIColorConfig.elements[element]
    if not rgb then
        return UIColorConfig.rgb_to_code(UIColorConfig.special.default)
    end
    return UIColorConfig.rgb_to_code(rgb)
end

--- Get stat color code
--- @param stat string Stat name (STR, DEX, etc.)
--- @return string Color code
function UIColorConfig.get_stat_color(stat)
    local rgb = UIColorConfig.stats[stat]
    if not rgb then
        return UIColorConfig.rgb_to_code(UIColorConfig.special.default)
    end
    return UIColorConfig.rgb_to_code(rgb)
end

--- Get bar element color code
--- @param spell string Spell name (Barfira, Barblizzara, etc.)
--- @return string Color code
function UIColorConfig.get_bar_element_color(spell)
    local rgb = UIColorConfig.bar_spells.element[spell]
    if not rgb then
        return UIColorConfig.rgb_to_code(UIColorConfig.special.default)
    end
    return UIColorConfig.rgb_to_code(rgb)
end

--- Get bar ailment color code
--- @return string Color code
function UIColorConfig.get_bar_ailment_color()
    return UIColorConfig.rgb_to_code(UIColorConfig.bar_spells.ailment)
end

--- Get mode color code
--- @param mode string Mode name (PDT, MDT, Normal)
--- @return string Color code
function UIColorConfig.get_mode_color(mode)
    local rgb = UIColorConfig.modes[mode]
    if not rgb then
        return UIColorConfig.rgb_to_code(UIColorConfig.special.default)
    end
    return UIColorConfig.rgb_to_code(rgb)
end

--- Get special value color code
--- @param value string Value (true, false, unknown)
--- @return string Color code
function UIColorConfig.get_special_color(value)
    local rgb = UIColorConfig.special[value:lower()]
    if not rgb then
        return UIColorConfig.rgb_to_code(UIColorConfig.special.default)
    end
    return UIColorConfig.rgb_to_code(rgb)
end

---============================================================================
--- VALIDATION
---============================================================================

--- Validate all color definitions
--- @return boolean, table valid, issues
function UIColorConfig.validate()
    local issues = {}

    -- Validate RGB values are in range 0-255
    local function validate_rgb(rgb, name)
        if not rgb or #rgb < 3 then
            table.insert(issues, string.format("%s: Invalid RGB format", name))
            return false
        end
        for i = 1, 3 do
            if rgb[i] < 0 or rgb[i] > 255 then
                table.insert(issues, string.format("%s: RGB value out of range (0-255)", name))
                return false
            end
        end
        return true
    end

    -- Validate elements
    for name, rgb in pairs(UIColorConfig.elements) do
        validate_rgb(rgb, "Element: " .. name)
    end

    -- Validate stats
    for name, rgb in pairs(UIColorConfig.stats) do
        validate_rgb(rgb, "Stat: " .. name)
    end

    return #issues == 0, issues
end

return UIColorConfig

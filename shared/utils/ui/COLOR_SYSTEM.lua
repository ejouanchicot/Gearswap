---============================================================================
--- Color System - Centralized Color Management for UI Elements
---============================================================================
--- Centralized color management for all UI elements across all jobs.
--- Provides consistent color coding for elements, stats, spells, and modes.
--- Supports per-character customization via config/UI_COLOR_CONFIG.lua
---
--- @file ui/COLOR_SYSTEM.lua
--- @author Tetsouo
--- @version 4.0
--- @date Updated: 2025-11-10
---============================================================================

local ColorSystem = {}

---============================================================================
--- CHARACTER-SPECIFIC COLOR LOADING
---============================================================================

-- Try to load character-specific color config (Tetsouo/Kaories)
local char_name = player and player.name or nil
local custom_colors = nil

if char_name then
    local success, UIColorConfig = pcall(require, char_name .. '/config/UI_COLOR_CONFIG')
    if success and UIColorConfig then
        custom_colors = UIColorConfig
    end
end

---============================================================================
--- STATIC COLOR DEFINITIONS (WITH CUSTOM OVERRIDE SUPPORT)
---============================================================================

-- Element colors (can be overridden by custom config)
local element_colors = {
    -- Basic elements
    Fire = "\\cs(255,100,100)",
    Water = "\\cs(100,150,255)",
    Lightning = "\\cs(255,150,255)",
    Ice = "\\cs(150,200,255)",
    Wind = "\\cs(150,255,150)",
    Earth = "\\cs(200,150,100)",
    Light = "\\cs(255,255,255)",
    Dark = "\\cs(150,100,200)",

    -- Spell name aliases
    Thunder = "\\cs(255,150,255)",
    Aero = "\\cs(150,255,150)",
    Stone = "\\cs(200,150,100)",
    Blizzard = "\\cs(150,200,255)",

    -- RUN Runes (Latin names)
    Ignis = "\\cs(255,100,100)",    -- Fire
    Gelus = "\\cs(150,200,255)",    -- Ice
    Flabra = "\\cs(150,255,150)",   -- Wind
    Tellus = "\\cs(200,150,100)",   -- Earth
    Sulpor = "\\cs(255,150,255)",   -- Lightning
    Unda = "\\cs(100,150,255)",     -- Water
    Lux = "\\cs(255,255,255)",      -- Light
    Tenebrae = "\\cs(150,100,200)", -- Dark

    -- Tier 2 spells (-ra variants)
    Thundara = "\\cs(255,150,255)",
    Aera = "\\cs(150,255,150)",       -- GEO AOE Wind
    Aerora = "\\cs(150,255,150)",
    Stonera = "\\cs(200,150,100)",
    Blizzara = "\\cs(150,200,255)",
    Fira = "\\cs(255,100,100)",
    Watera = "\\cs(100,150,255)",

    -- Tier 3 spells
    Thundaga = "\\cs(255,150,255)",
    Aeroga = "\\cs(150,255,150)",
    Stonega = "\\cs(200,150,100)",
    Blizzaga = "\\cs(150,200,255)",
    Firaga = "\\cs(255,100,100)",
    Waterga = "\\cs(100,150,255)",

    -- Tier 4 spells (Aja)
    Thundaja = "\\cs(255,150,255)",
    Aeroja = "\\cs(150,255,150)",
    Stoneja = "\\cs(200,150,100)",
    Blizzaja = "\\cs(150,200,255)",
    Firaja = "\\cs(255,100,100)",
    Waterja = "\\cs(100,150,255)",

    -- Storm variants
    Firestorm = "\\cs(255,100,100)",
    Sandstorm = "\\cs(200,150,100)",
    Thunderstorm = "\\cs(255,150,255)",
    Hailstorm = "\\cs(150,200,255)",
    Windstorm = "\\cs(150,255,150)",
    Rainstorm = "\\cs(100,150,255)",
    Voidstorm = "\\cs(150,100,200)",
    Aurorastorm = "\\cs(255,255,255)"
}

-- Stat colors (static)
local stat_colors = {
    STR = "\\cs(255,100,100)",
    DEX = "\\cs(255,150,255)",
    VIT = "\\cs(200,150,100)",
    AGI = "\\cs(150,255,150)",
    INT = "\\cs(150,100,200)",
    MND = "\\cs(150,200,255)",
    CHR = "\\cs(255,255,255)"
}

-- Special colors (static)
local special_colors = {
    PDT = "\\cs(255,200,100)",
    MDT = "\\cs(150,200,255)",
    Normal = "\\cs(255,255,255)",   -- White (default/neutral state)
    Refresh = "\\cs(150,255,150)",  -- Green (MP recovery/safe)
    Potency = "\\cs(150,255,150)",  -- Green (healing power/safe)
    SIRD = "\\cs(255,200,100)",     -- Orange like PDT (defensive/interrupt resist)
    Solace = "\\cs(150,255,150)",   -- Green (cure/healing focus)
    Misery = "\\cs(255,100,100)",   -- Red (damage/offensive focus)
    ["true"] = "\\cs(150,255,150)",
    ["false"] = "\\cs(255,100,100)",
    unknown = "\\cs(128,128,128)",
    bar_ailment = "\\cs(255,200,150)"
}

-- Spell colors (can be overridden by custom config)
local en_spell_colors = {}
local spike_colors = {}
local storm_colors = {}
local quick_draw_colors = {}

---============================================================================
--- CUSTOM COLOR OVERRIDE (Apply character-specific colors)
---============================================================================

if custom_colors then
    -- Helper to convert RGB {r,g,b} to "\\cs(r,g,b)"
    local function rgb_to_code(rgb)
        if not rgb or #rgb < 3 then return nil end
        return string.format("\\cs(%d,%d,%d)", rgb[1], rgb[2], rgb[3])
    end

    -- Override element colors
    if custom_colors.elements then
        for name, rgb in pairs(custom_colors.elements) do
            local code = rgb_to_code(rgb)
            if code then
                element_colors[name] = code
            end
        end
    end

    -- Override stat colors
    if custom_colors.stats then
        for name, rgb in pairs(custom_colors.stats) do
            local code = rgb_to_code(rgb)
            if code then
                stat_colors[name] = code
            end
        end
    end

    -- Override mode colors
    if custom_colors.modes then
        for name, rgb in pairs(custom_colors.modes) do
            local code = rgb_to_code(rgb)
            if code then
                special_colors[name] = code
            end
        end
    end

    -- Override bar ailment color
    if custom_colors.bar_spells and custom_colors.bar_spells.ailment then
        local code = rgb_to_code(custom_colors.bar_spells.ailment)
        if code then
            special_colors.bar_ailment = code
        end
    end

    -- Override special colors (true/false/unknown)
    if custom_colors.special then
        for name, rgb in pairs(custom_colors.special) do
            local code = rgb_to_code(rgb)
            if code then
                special_colors[name] = code
            end
        end
    end

    -- Override En spell colors
    if custom_colors.spells and custom_colors.spells.en then
        for spell_name, rgb in pairs(custom_colors.spells.en) do
            local code = rgb_to_code(rgb)
            if code then
                en_spell_colors[spell_name] = code
            end
        end
    end

    -- Override Spike spell colors
    if custom_colors.spells and custom_colors.spells.spikes then
        for spell_name, rgb in pairs(custom_colors.spells.spikes) do
            local code = rgb_to_code(rgb)
            if code then
                spike_colors[spell_name] = code
            end
        end
    end

    -- Override Storm spell colors
    if custom_colors.spells and custom_colors.spells.storms then
        for spell_name, rgb in pairs(custom_colors.spells.storms) do
            local code = rgb_to_code(rgb)
            if code then
                storm_colors[spell_name] = code
            end
        end
    end

    -- Override Quick Draw colors (COR)
    if custom_colors.jobs and custom_colors.jobs.quick_draw then
        for shot_name, rgb in pairs(custom_colors.jobs.quick_draw) do
            local code = rgb_to_code(rgb)
            if code then
                quick_draw_colors[shot_name] = code
            end
        end
    end
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if value matches any pattern in list
local function matches_patterns(value, patterns)
    for _, pattern in ipairs(patterns) do
        if value:find(pattern) then
            return true
        end
    end
    return false
end

--- Get color for Gain spells based on stat
local function get_gain_color(value)
    if value:find("STR") then
        return element_colors.Fire       -- Fire element
    elseif value:find("DEX") then
        return element_colors.Wind       -- Wind element (fixed: was Lightning)
    elseif value:find("VIT") then
        return element_colors.Earth      -- Earth element
    elseif value:find("AGI") then
        return element_colors.Lightning  -- Thunder/Lightning element (fixed: was Wind)
    elseif value:find("INT") then
        return element_colors.Ice        -- Ice element (fixed: was Dark)
    elseif value:find("MND") then
        return element_colors.Water      -- Water element (fixed: was Ice)
    elseif value:find("CHR") then
        return element_colors.Light      -- Light element
    end
    return "\\cs(255,100,100)" -- Fallback red
end

--- Get color for Storm spells
local function get_storm_color(value)
    -- Check custom colors first
    if storm_colors[value] then
        return storm_colors[value]
    end

    -- Fallback to element colors
    if value:find("Fire") then
        return element_colors.Fire
    elseif value:find("Sand") or value:find("Stone") then
        return element_colors.Earth
    elseif value:find("Thunder") then
        return element_colors.Lightning
    elseif value:find("Hail") or value:find("Bliz") then
        return element_colors.Ice
    elseif value:find("Rain") or value:find("Water") then
        return element_colors.Water
    elseif value:find("Wind") then
        return element_colors.Wind
    elseif value:find("Void") then
        return element_colors.Dark
    elseif value:find("Aurora") then
        return element_colors.Light
    end
    return nil
end

--- Get color for Bar element spells
local function get_bar_element_color(value)
    -- Support both old forms (Barfira) and new forms (Barfire)
    if value:find("Barfir") then  -- Matches both Barfira and Barfire
        return element_colors.Fire
    elseif value:find("Barbliz") then  -- Matches both Barblizzara and Barblizzard
        return element_colors.Ice
    elseif value:find("Baraer") then  -- Matches both Baraera and Baraero
        return element_colors.Wind
    elseif value:find("Barston") then  -- Matches both Barstonra and Barstone
        return element_colors.Earth
    elseif value:find("Barthund") then  -- Matches both Barthundra and Barthunder
        return element_colors.Lightning
    elseif value:find("Barwater") or value:find("Barwatera") then
        return element_colors.Water
    end
    return nil
end

--- Get color for Bar ailment spells (based on element association)
local function get_bar_ailment_color(value)
    -- Fire element ailments
    if value:find("Barparalyz") then  -- Barparalyze/Barparalyzra
        return element_colors.Fire
    -- Ice element ailments
    elseif value:find("Barsilence") then  -- Barsilence/Barsilencera
        return element_colors.Ice
    -- Wind element ailments
    elseif value:find("Barpetr") then  -- Barpetrify/Barpetra
        return element_colors.Wind
    -- Thunder element ailments
    elseif value:find("Barpoison") then  -- Barpoison/Barpoisonra
        return element_colors.Lightning
    -- Water element ailments
    elseif value:find("Baramnesi") or value:find("Barvir") then  -- Baramnesia/Baramnesra, Barvirus/Barvira
        return element_colors.Water
    -- Light element ailments
    elseif value:find("Barsleep") or value:find("Barblind") then  -- Barsleep/Barsleepra, Barblind/Barblindra
        return element_colors.Light
    end
    return nil
end

--- Get color for En spells
local function get_en_spell_color(value)
    -- Check custom colors first
    if en_spell_colors[value] then
        return en_spell_colors[value]
    end

    -- Fallback to element colors
    if value:find("Enfire") then
        return element_colors.Fire
    elseif value:find("Enblizzard") then
        return element_colors.Ice
    elseif value:find("Enaero") then
        return element_colors.Wind
    elseif value:find("Enstone") then
        return element_colors.Earth
    elseif value:find("Enthunder") then
        return element_colors.Lightning
    elseif value:find("Enwater") then
        return element_colors.Water
    end
    return nil
end

--- Get color for Spike spells
local function get_spike_color(value)
    -- Check custom colors first
    if spike_colors[value] then
        return spike_colors[value]
    end

    -- Fallback to element colors
    if value == "Blaze Spikes" then
        return element_colors.Fire
    elseif value == "Ice Spikes" then
        return element_colors.Ice
    elseif value == "Shock Spikes" then
        return element_colors.Lightning
    end
    return nil
end

--- Get color for Quick Draw spells (COR)
local function get_quick_draw_color(value)
    -- Check custom colors first
    if quick_draw_colors[value] then
        return quick_draw_colors[value]
    end

    -- Fallback to element colors
    if value == "Fire Shot" then
        return element_colors.Fire
    elseif value == "Ice Shot" then
        return element_colors.Blizzard
    elseif value == "Wind Shot" then
        return element_colors.Aero
    elseif value == "Earth Shot"  then
        return element_colors.Stone
    elseif value == "Thunder Shot"  then
        return element_colors.Thunder
    elseif value == "Water Shot"  then
        return element_colors.Water
    elseif value == "Light Shot"  then
        return element_colors.Light
    elseif value == "Dark Shot"  then
        return element_colors.Dark
    end
    return nil
end

---============================================================================
--- MAIN COLOR RESOLUTION
---============================================================================

local DEFAULT_COLOR = "\\cs(255,255,255)"

-- What the description says the value IS decides which palette to look it up
-- in. Order matters, and "Element" already covers GEO's "Elemental".
local DESCRIPTION_PALETTES = {
    { keyword = "Element",    palette = element_colors },
    { keyword = "AOE",        palette = element_colors },
    { keyword = "Etude",      palette = stat_colors    },
    { keyword = "Rune",       palette = element_colors },
    { keyword = "Light",      palette = element_colors },
    { keyword = "Dark",       palette = element_colors },
    { keyword = "Aja",        palette = element_colors },
    { keyword = "Storm",      palette = element_colors },
    { keyword = "Quick Draw", palette = element_colors },
}

-- Mode names that colour themselves wherever they appear in a value, checked
-- in order: a value holding both takes the first.
local MODE_SUBSTRINGS = {
    'PDT', 'MDT', 'Normal', 'Refresh', 'Potency', 'SIRD', 'Solace', 'Misery',
}

-- Each recognises one family of spell names and returns nil for the rest.
local SPELL_COLOR_PROBES = {
    get_bar_element_color,
    get_bar_ailment_color,
    get_en_spell_color,
    get_spike_color,
    get_quick_draw_color,
}

-- Literal values whose colour never depends on context.
local EXACT_VALUE_COLORS = {
    ['true']  = 'true',  ['True']  = 'true',  ['On']  = 'true',  ['on']  = 'true',
    ['false'] = 'false', ['False'] = 'false', ['Off'] = 'false', ['off'] = 'false',
    ['unknown'] = 'unknown', ['Unknown'] = 'unknown', ['N/A'] = 'unknown',
}

--- Colour the description asks for, if it names a kind this value belongs to.
--- @param value string State value
--- @param description string State description (never nil here)
--- @return string|nil Colour code, or nil to keep looking
local function color_from_description(value, description)
    for _, rule in ipairs(DESCRIPTION_PALETTES) do
        if description:find(rule.keyword) and rule.palette[value] then
            return rule.palette[value]
        end
    end

    if description:find("Storm") then
        return get_storm_color(value)
    end

    return nil
end

--- Colour the value carries on its own, whatever the description says.
--- @param value string State value
--- @return string|nil Colour code, or nil if the value is not recognised
local function color_from_value(value)
    for _, name in ipairs(MODE_SUBSTRINGS) do
        if value:find(name) then
            return special_colors[name]
        end
    end

    for _, probe in ipairs(SPELL_COLOR_PROBES) do
        local color = probe(value)
        if color then return color end
    end

    local exact = EXACT_VALUE_COLORS[value]
    return exact and special_colors[exact] or nil
end

--- Get color for a value based on context
--- @param value string State value as shown in the UI
--- @param description string|nil What kind of value it is (element, rune, etude...)
--- @return string|nil Colour code; white when nothing matches, nil for an
---         unknown Gain (get_gain_color has the last word on those)
function ColorSystem.get_value_color(value, description)
    if description and description:find("Gain") then
        return get_gain_color(value)
    end

    if description then
        local by_description = color_from_description(value, description)
        if by_description then return by_description end
    end

    -- Symbolic rather than elemental: Saber Dance is the offensive stance,
    -- Fan Dance the defensive one.
    if description and description:find("Dance") then
        if value == "Saber Dance" then
            return element_colors.Fire
        elseif value == "Fan Dance" then
            return "\\cs(150,255,150)"
        end
    end

    return color_from_value(value) or DEFAULT_COLOR
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

function ColorSystem.get_element_colors()
    return element_colors
end

function ColorSystem.get_stat_colors()
    return stat_colors
end

function ColorSystem.add_custom_color(pattern_type, pattern_name, color_code)
    if pattern_type == "element" then
        element_colors[pattern_name] = color_code
    elseif pattern_type == "stat" then
        stat_colors[pattern_name] = color_code
    elseif pattern_type == "special" then
        special_colors[pattern_name] = color_code
    end
end

return ColorSystem

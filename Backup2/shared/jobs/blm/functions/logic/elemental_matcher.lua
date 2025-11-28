---============================================================================
--- BLM Elemental Matcher - Detects elemental matches
---============================================================================
--- Checks if spell element matches with:
---   - Active storm buff (Firestorm, Hailstorm, etc.)
---   - Day of the week (Firesday, Iceday, etc.)
---   - Active weather (Heat waves, Blizzards, etc.)
---
--- @file elemental_matcher.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-25
---============================================================================

local ElementalMatcher = {}

---============================================================================
--- ELEMENT MAPPINGS
---============================================================================

--- Convert element IDs to element names
--- @type table<number, string>
local ELEMENT_NAMES = {
    [0] = 'Fire',
    [1] = 'Ice',
    [2] = 'Wind',
    [3] = 'Earth',
    [4] = 'Thunder',
    [5] = 'Water',
    [6] = 'Light',
    [7] = 'Dark'
}

--- Map storm buffs to element IDs
--- @type table<string, number>
local STORM_TO_ELEMENT = {
    ['Firestorm'] = 0,    -- Fire
    ['Hailstorm'] = 1,    -- Ice
    ['Windstorm'] = 2,    -- Wind
    ['Sandstorm'] = 3,    -- Earth
    ['Thunderstorm'] = 4, -- Thunder
    ['Rainstorm'] = 5     -- Water
}

--- Reverse mapping: element names to element IDs
--- @type table<string, number>
local ELEMENT_NAME_TO_ID = {
    ['Fire'] = 0,
    ['Ice'] = 1,
    ['Wind'] = 2,
    ['Earth'] = 3,
    ['Thunder'] = 4,
    ['Lightning'] = 4,  -- GearSwap uses both Thunder and Lightning
    ['Water'] = 5,
    ['Light'] = 6,
    ['Dark'] = 7
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Normalize spell.element to NUMBER (handles both NUMBER and STRING input)
--- @param element_value number|string Element ID (0-7) or element name ('Fire', 'Ice', etc.)
--- @return number|nil Element ID (0-7) or nil if invalid
local function normalize_element(element_value)
    -- If already a number, return as-is
    if type(element_value) == 'number' then
        return element_value
    end

    -- If string, convert to number using reverse mapping
    if type(element_value) == 'string' then
        return ELEMENT_NAME_TO_ID[element_value]
    end

    -- Invalid type
    return nil
end

--- Convert spell element ID to element name
--- @param element_id number Element ID (0-7)
--- @return string|nil Element name or nil
local function get_element_name(element_id)
    return ELEMENT_NAMES[element_id]
end

--- Check if any storm buff is active and matches spell element
--- @param spell_element_id number Spell element ID (0-7)
--- @return boolean True if matching storm is active
local function has_matching_storm(spell_element_id)
    for storm_name, storm_element_id in pairs(STORM_TO_ELEMENT) do
        if buffactive[storm_name] and storm_element_id == spell_element_id then
            return true
        end
    end
    return false
end

--- Check if day element matches spell element
--- @param spell_element_id number Spell element ID (0-7)
--- @return boolean True if day matches spell element
local function has_matching_day(spell_element_id)
    if not world or not world.day_element then
        return false
    end

    local spell_element_name = get_element_name(spell_element_id)
    return spell_element_name == world.day_element
end

--- Check if weather element matches spell element (with intensity > 0)
--- Uses world.real_weather_* to ignore SCH storms (which are checked separately)
--- @param spell_element_id number Spell element ID (0-7)
--- @return boolean True if weather matches spell element
local function has_matching_weather(spell_element_id)
    if not world or not world.real_weather_element or not world.real_weather_intensity then
        return false
    end

    -- Only consider real weather (intensity > 0)
    if world.real_weather_intensity == 0 then
        return false
    end

    local spell_element_name = get_element_name(spell_element_id)
    return spell_element_name == world.real_weather_element
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Check if spell element matches any elemental condition
--- @param spell table Spell object from GearSwap
--- @param config table Configuration options {check_storm, check_day, check_weather}
--- @return boolean True if any condition matches
--- @return string|nil Reason for match (for debug)
function ElementalMatcher.has_elemental_match(spell, config)
    if not spell or not spell.element then
        return false, nil
    end

    -- Normalize spell.element to NUMBER (handles both NUMBER and STRING)
    local spell_element_id = normalize_element(spell.element)

    if not spell_element_id then
        return false, nil
    end

    local reasons = {}

    -- Check storm
    if config.check_storm then
        if has_matching_storm(spell_element_id) then
            table.insert(reasons, 'storm')
        end
    end

    -- Check day
    if config.check_day then
        if has_matching_day(spell_element_id) then
            table.insert(reasons, 'day')
        end
    end

    -- Check weather
    if config.check_weather then
        if has_matching_weather(spell_element_id) then
            table.insert(reasons, 'weather')
        end
    end

    local has_match = #reasons > 0
    local reason = has_match and table.concat(reasons, ', ') or nil

    return has_match, reason
end

--- Get element name from spell
--- @param spell table Spell object from GearSwap
--- @return string|nil Element name
function ElementalMatcher.get_spell_element_name(spell)
    if not spell or not spell.element then
        return nil
    end
    local element_id = normalize_element(spell.element)
    return get_element_name(element_id)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return ElementalMatcher

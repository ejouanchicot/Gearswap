---============================================================================
--- Elemental Bonus - what Hachirin-no-Obi and Orpheus's Sash would add
---============================================================================
--- Both belts raise elemental damage (nukes, elemental weaponskills, Quick
--- Draw); they share the waist, so the better one should go on.
---
--- Hachirin-no-Obi makes the day and weather bonus always apply, the penalty
--- too (FFXI element wheel: Fire > Ice > Wind > Earth > Thunder > Water >
--- Fire, Light <> Dark):
---   day       +10 same element, -10 the element that beats it
---   weather   +10 / +25 (single / double, SCH storms included), same minus
--- Orpheus's Sash: +15 at 1 yalm or closer, one less per yalm, +1 from 15.
---
--- @file    shared/utils/equipment/elemental_bonus.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

local ElementalBonus = {}

--- Element that beats each element.
local BEATEN_BY = {
    Fire = 'Water', Ice = 'Fire', Wind = 'Ice', Earth = 'Wind',
    Lightning = 'Earth', Water = 'Lightning', Light = 'Dark', Dark = 'Light',
}

--- GearSwap names Thunder "Lightning" in some tables and "Thunder" in others.
local function canonical(element)
    if element == 'Thunder' then return 'Lightning' end
    return element
end

--- +value for the same element, -value for the one that beats it, else 0.
local function signed(action_element, other, value)
    other = canonical(other)
    if other == action_element then return value end
    if other ~= nil and BEATEN_BY[action_element] == other then return -value end
    return 0
end

--- Percent Hachirin-no-Obi adds to this element now (can be negative).
--- @param element string Action element ("Fire", "Lightning"...)
--- @return number
function ElementalBonus.obi(element)
    element = canonical(element)
    if not BEATEN_BY[element] or not world then return 0 end
    local total = signed(element, world.day_element, 10)
    local intensity = world.weather_intensity or 0
    if intensity > 0 then
        total = total + signed(element, world.weather_element, intensity >= 2 and 25 or 10)
    end
    return total
end

--- Percent Orpheus's Sash adds at this distance.
--- @param distance number|nil Yalms to the target (nil = unknown: 0)
--- @return number
function ElementalBonus.orpheus(distance)
    if type(distance) ~= 'number' then return 0 end
    return math.max(1, math.min(15, math.floor(16 - distance)))
end

--- Both bonuses for an action.
--- @param spell table GearSwap action (element, target.distance)
--- @return number obi, number orpheus (0, 0 when the action has no element)
function ElementalBonus.for_action(spell)
    if not spell or not BEATEN_BY[canonical(spell.element)] then return 0, 0 end
    return ElementalBonus.obi(spell.element), ElementalBonus.orpheus(spell.target and spell.target.distance)
end

return ElementalBonus

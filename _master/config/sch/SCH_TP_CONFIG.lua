---============================================================================
--- SCH TP Configuration - Weaponskill TP bonus
---============================================================================
--- pieces / weapons: TP bonus pieces the calculator may add to one of your
--- weaponskills to reach the next 1000 TP step (TPBonusCalculator, via
--- WSPrecastHandler).
---
--- Example:
---   weapons = { { name = "Musa", bonus = 500 } }
---
--- @file    config/sch/SCH_TP_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local SCHTPConfig = {
    -- Equipped only when they reach the next threshold
    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    -- Weapons with a TP bonus of their own
    weapons = {},
}

--- TP bonus of a weapon, if listed
--- @param weapon_name string Name of the weapon
--- @return number TP bonus (0 when not listed)
function SCHTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end
    for _, weapon in ipairs(SCHTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end
    return 0
end

-- Global export: the entry file also assigns it, SCH_PRECAST reads
-- _G.SCHTPConfig
_G.SCHTPConfig = SCHTPConfig

return SCHTPConfig

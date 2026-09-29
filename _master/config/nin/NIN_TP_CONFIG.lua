---============================================================================
--- NIN TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- TP bonus pieces the calculator may add to a weaponskill to reach the
--- next 1000 TP step (TPBonusCalculator, via WSPrecastHandler).
---
--- Example (a weapon with a TP bonus of its own, in either hand):
---   weapons = { { name = "<weapon name>", bonus = 500 } },
---
--- @file    config/nin/NIN_TP_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local NINTPConfig = {
    -- Equipped only when they reach the next threshold
    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    -- Weapons with a TP bonus of their own (either hand)
    weapons = {}
}

--- TP bonus of a weapon, if listed
--- @param weapon_name string Name of the weapon
--- @return number TP bonus (0 when not listed)
function NINTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end
    for _, weapon in ipairs(NINTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end
    return 0
end

-- Global export: the entry file also assigns it, NIN_PRECAST reads _G.NINTPConfig
_G.NINTPConfig = NINTPConfig

return NINTPConfig

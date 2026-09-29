---============================================================================
--- RNG TP Configuration - Weaponskill TP bonus
---============================================================================
--- pieces / weapons: TP bonus pieces the calculator may add to a weaponskill
--- to reach the next 1000 TP step (TPBonusCalculator, via WSPrecastHandler).
---
--- weapons: TP bonus of a weapon of yours, e.g.
---   { name = "Fomalhaut", bonus = 500 }
--- Caveat: the calculator reads the MAIN and SUB hands only, never the
--- range slot, so a bow or gun listed here is not counted today.
---
--- @file    config/rng/RNG_TP_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local RNGTPConfig = {
    -- Equipped only when they reach the next threshold
    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    -- Weapons with a TP bonus of their own (main / sub hand)
    weapons = {},
}

--- TP bonus of a weapon, if listed
--- @param weapon_name string Name of the weapon
--- @return number TP bonus (0 when not listed)
function RNGTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end
    for _, weapon in ipairs(RNGTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end
    return 0
end

-- Global export: the entry file also assigns it, RNG_PRECAST reads
-- _G.RNGTPConfig
_G.RNGTPConfig = RNGTPConfig

return RNGTPConfig

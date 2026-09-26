---============================================================================
--- BLU TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- TP bonus pieces the calculator may add to a weaponskill to reach the
--- next 1000 TP step (TPBonusCalculator, via WSPrecastHandler).
---
--- @file    config/blu/BLU_TP_CONFIG.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

local BLUTPConfig = {
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
function BLUTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end
    for _, weapon in ipairs(BLUTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end
    return 0
end

-- Global export: the entry file also assigns it, BLU_PRECAST reads _G.BLUTPConfig
_G.BLUTPConfig = BLUTPConfig

return BLUTPConfig

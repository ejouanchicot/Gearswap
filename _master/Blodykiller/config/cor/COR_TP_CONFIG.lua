---============================================================================
--- COR TP Bonus Configuration - Blodykiller
---============================================================================
--- Configuration for TP bonus equipment for Corsair
--- This determines which gear to equip based on current TP to reach 2000/3000 TP thresholds
---
--- Blodykiller: the template with Moonshade on ear2 (right_ear), where his
--- weaponskill sets wear it; on ear1 it would be sent to both ears.
---
--- @file config/cor/COR_TP_CONFIG.lua
--- @module COR_TP_CONFIG
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-08
---============================================================================

local CORTPConfig = {
    ---============================================================================
    --- USER CONFIG - Adjust according to your character
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- These pieces will be equipped intelligently based on TP thresholds
    -- The calculator will equip the minimum needed to reach 2000 or 3000 TP

    pieces = {
        { slot = "ear2", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Ranged Weapons with automatic TP bonus
    ---============================================================================
    -- COR uses RANGED weapons (guns) for TP bonus, not main weapons.
    -- Caveat: TPBonusHandler passes the MAIN weapon name to get_weapon_bonus(),
    -- so this list does not match anything today.

    ranged_weapons = {
        { name = "Anarchy +2", bonus = 1000 },
        { name = "Fomalhaut", bonus = 500 }     -- Aeonic gun
    }
}

---============================================================================
--- Get ranged weapon TP bonus if equipped
--- @param weapon_name string Name of the ranged weapon
--- @return number TP bonus from ranged weapon (0, 500, or 1000)
---============================================================================
function CORTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end

    for _, weapon in ipairs(CORTPConfig.ranged_weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

-- Make globally available
_G.CORTPConfig = CORTPConfig

return CORTPConfig

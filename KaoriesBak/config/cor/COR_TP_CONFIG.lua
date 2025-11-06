---============================================================================
--- COR TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for Corsair
--- This determines which gear to equip based on current TP to reach 2000/3000 TP thresholds
---
--- @file config/cor/COR_TP_CONFIG.lua
--- @module COR_TP_CONFIG
--- @author Kaories
--- @version 1.0.0
--- @date Created: 2025-10-08
---============================================================================

local CORTPConfig = {
    ---============================================================================
    --- USER CONFIG - Adjust according to your character
    ---============================================================================

    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- These pieces will be equipped intelligently based on TP thresholds
    -- The calculator will equip the minimum needed to reach 2000 or 3000 TP

    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Ranged Weapons with automatic TP bonus
    ---============================================================================
    -- COR uses RANGED weapons (guns) for TP bonus, not main weapons

    ranged_weapons = {
        { name = "Anarchy +2", bonus = 1000 },  -- Equipped permanently
        { name = "Fomalhaut", bonus = 500 }     -- REMA weapon
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

---============================================================================
--- BRD TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- Configuration for TP bonus equipment for Bard job. Determines which gear
--- to equip based on current TP to reach 2000/3000 TP thresholds for weaponskills.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring)
---   • Weapon-based TP bonus tracking (daggers with TP Bonus)
---   • Automatic TP threshold optimization (2000/3000 TP)
---   • Same dagger list as DNC/THF (each job keeps its own copy)
---   • Intelligent minimum gear selection
---
--- TP Thresholds:
---   • 2000 TP: Enhanced damage multiplier for most weaponskills
---   • 3000 TP: Maximum damage multiplier (capped)
---   • Calculator equips minimum gear needed to reach threshold
---
--- Dependencies:
---   • TPBonusCalculator (uses this configuration for dynamic gear selection)
---
--- @file    config/brd/BRD_TP_CONFIG.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local BRDTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- These pieces will be equipped intelligently based on TP thresholds
    -- The calculator will equip the minimum needed to reach 2000 or 3000 TP

    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Weapons with automatic TP bonus
    ---============================================================================
    -- TP bonus counted in either hand (main or off-hand)

    weapons = {
        { name = "Aeneas", bonus = 500 },      -- Dagger, TP Bonus +500
        { name = "Centovente", bonus = 1000 }  -- Dagger, TP Bonus +1000
    }
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0, 500, or 1000)
---============================================================================
function BRDTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end

    for _, weapon in ipairs(BRDTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

-- Make globally available
_G.BRDTPConfig = BRDTPConfig

return BRDTPConfig

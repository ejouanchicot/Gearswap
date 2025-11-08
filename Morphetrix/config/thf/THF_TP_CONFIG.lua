---============================================================================
--- THF TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- Configuration for TP bonus equipment for Thief job. Determines which gear
--- to equip based on current TP to reach 2000/3000 TP thresholds for weaponskills.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring)
---   • Weapon-based TP bonus tracking (REMA daggers)
---   • Automatic TP threshold optimization (2000/3000 TP)
---   • Shared configuration with DNC/BRD (REMA daggers)
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
--- @file    config/thf/THF_TP_CONFIG.lua
--- @author  Morphetrix
--- @version 1.0
--- @date    Created: 2025-10-08
---============================================================================

local THFTPConfig = {
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
    -- These provide TP bonus when equipped as main weapon

    weapons = {
        { name = "Aeneas", bonus = 500 },      -- REMA dagger (shared with DNC/BRD)
        { name = "Centovente", bonus = 1000 }  -- High-tier dagger (shared with DNC)
    }
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0, 500, or 1000)
---============================================================================
function THFTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end

    for _, weapon in ipairs(THFTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

-- Make globally available
_G.THFTPConfig = THFTPConfig

return THFTPConfig

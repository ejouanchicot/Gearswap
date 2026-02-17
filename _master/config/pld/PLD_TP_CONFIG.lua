---============================================================================
--- PLD TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for Paladin weaponskills.
--- Determines which gear to equip based on current TP to reach 2000/3000 TP thresholds.
---
--- Features:
---   • TP bonus equipment configuration (accessories)
---   • Weapon-based TP bonus tracking (REMA weapons)
---   • Automatic TP threshold optimization (2000/3000 TP)
---   • Shared configuration with RDM/BLU (Sequence sword)
---   • Intelligent minimum gear selection
---
--- Usage:
---   • Modify pieces table to add/remove TP bonus accessories
---   • Modify weapons table to add/remove REMA weapons with TP bonus
---   • get_weapon_bonus(weapon_name) - Get TP bonus from equipped weapon
---
--- @file    config/pld/PLD_TP_CONFIG.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-08
---============================================================================
local PLDTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- These pieces will be equipped intelligently based on TP thresholds
    -- The calculator will equip the minimum needed to reach 2000 or 3000 TP

    pieces = {{
        slot = "ear1",
        name = "Moonshade Earring",
        bonus = 250
    }},

    ---============================================================================
    --- Weapons with automatic TP bonus
    ---============================================================================
    -- These provide TP bonus when equipped as main weapon

    weapons = {{
        name = "Sequence",
        bonus = 500
    } -- REMA sword (shared with RDM/BLU)
    }
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param  weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0 or 500)
---============================================================================
function PLDTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then
        return 0
    end

    for _, weapon in ipairs(PLDTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make globally available for backward compatibility
_G.PLDTPConfig = PLDTPConfig

return PLDTPConfig

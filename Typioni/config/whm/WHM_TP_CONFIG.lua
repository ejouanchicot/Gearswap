---============================================================================
--- WHM TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for White Mage.
--- WHM primarily casts spells but may engage in melee with club builds.
---
--- Features:
---   • TP bonus equipment pieces (Moonshade Earring, etc.)
---   • Weapon TP bonus detection
---   • Automatic TP threshold calculations (2000/3000 TP)
---
--- @file    config/whm/WHM_TP_CONFIG.lua
--- @module  WHM_TP_CONFIG
--- @author  Typioni
--- @version 1.0.0
--- @date    Created: 2025-10-22
---============================================================================
local WHMTPConfig = {
    ---==========================================================================
    --- USER CONFIGURATION - Adjust According to Your Character
    ---==========================================================================

    ---==========================================================================
    --- TP BONUS EQUIPMENT PIECES
    ---==========================================================================
    --- These pieces will be equipped intelligently based on TP thresholds.
    --- The calculator will equip the minimum needed to reach 2000 or 3000 TP.

    pieces = {
        {
            slot = "ear1",
            name = "Moonshade Earring",
            bonus = 250
        }
    },

    ---==========================================================================
    --- WEAPONS WITH AUTOMATIC TP BONUS
    ---==========================================================================
    --- These provide TP bonus when equipped as main weapon.

    weapons = {
        -- Add WHM weapons with TP bonus here if any
    },
}

---============================================================================
--- CALCULATOR FUNCTIONS
---============================================================================

--- Get weapon TP bonus if equipped
--- Checks if the specified weapon provides automatic TP bonus.
---
--- @param  weapon_name string Name of the main weapon
--- @return number TP bonus from weapon
function WHMTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then
        return 0
    end

    for _, weapon in ipairs(WHMTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

---============================================================================
--- GLOBAL EXPORT & MODULE RETURN
---============================================================================

-- Make globally available for legacy code
_G.WHMTPConfig = WHMTPConfig

return WHMTPConfig

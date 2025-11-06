---============================================================================
--- SAM TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment.
--- Determines which gear to equip based on current TP to reach 2000/3000 TP thresholds.
---
--- Features:
---   • TP bonus equipment pieces (Moonshade Earring, Mpaca's Cap, etc.)
---   • Weapon TP bonus detection (Dojikiri Yasutsuna)
---   • Hagakure JP configuration (conditional TP bonus)
---   • Automatic TP threshold calculations (2000/3000 TP)
---
--- @file    config/sam/SAM_TP_CONFIG.lua
--- @module  SAM_TP_CONFIG
--- @author  Kaories
--- @version 1.0.0
--- @date    Created: 2025-10-22
---============================================================================
local SAMTPConfig = {
    ---==========================================================================
    --- USER CONFIGURATION - Adjust According to Your Character
    ---==========================================================================

    --- Hagakure Effect Job Points Gifts (0-20)
    --- Each JP Gift adds +10 TP bonus to next weapon skill during Hagakure.
    --- Base: 1000 TP | Max (20 JP): 1200 TP
    --- NOTE: This is a CONDITIONAL bonus (only active during Hagakure, consumed on WS).
    hagakure_jp_gifts = 0,

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
        },
        {
            slot = "head",
            name = "Mpaca's Cap",
            bonus = 200
        }
    },

    ---==========================================================================
    --- WEAPONS WITH AUTOMATIC TP BONUS
    ---==========================================================================
    --- These provide TP bonus when equipped as main weapon.

    weapons = {
        {
            name = "Dojikiri Yasutsuna",
            bonus = 500
        }
    },
}

---============================================================================
--- CALCULATOR FUNCTIONS
---============================================================================

--- Get weapon TP bonus if equipped
--- Checks if the specified weapon provides automatic TP bonus.
---
--- @param  weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0 or 500 for Dojikiri Yasutsuna)
function SAMTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then
        return 0
    end

    for _, weapon in ipairs(SAMTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

--- Get Hagakure TP bonus if buff is active
--- Hagakure grants 1000 base TP bonus + JP bonus to next weaponskill.
--- Formula: 1000 + (JP Gifts × 10)
---
--- @return number TP bonus from Hagakure (0 if buff not active, 1000-1200 if active)
function SAMTPConfig.get_hagakure_bonus()
    if not buffactive then
        return 0
    end

    if buffactive.Hagakure or buffactive['Hagakure'] then
        local jp_bonus = SAMTPConfig.hagakure_jp_gifts * 10
        return 1000 + jp_bonus
    end

    return 0
end


---============================================================================
--- GLOBAL EXPORT & MODULE RETURN
---============================================================================

-- Make globally available for legacy code
_G.SAMTPConfig = SAMTPConfig

return SAMTPConfig

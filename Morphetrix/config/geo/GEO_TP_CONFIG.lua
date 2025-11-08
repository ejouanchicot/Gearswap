---============================================================================
--- GEO TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- Configuration for TP bonus equipment for Geomancer job. Determines which gear
--- to equip based on current TP to reach 2000/3000 TP thresholds for weaponskills.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring - all jobs)
---   • Automatic TP threshold optimization (2000/3000 TP)
---   • Minimal configuration (GEO is primarily a mage job)
---
--- Note:
---   GEO does not use REMA weapons with TP bonus (uses clubs: Idris, Solstice, Dunna)
---   This config provides basic TP bonus support via Moonshade Earring only
---
--- TP Thresholds:
---   • 2000 TP: Enhanced damage multiplier for most weaponskills
---   • 3000 TP: Maximum damage multiplier (capped)
---   • Calculator equips minimum gear needed to reach threshold
---
--- Dependencies:
---   • TPBonusCalculator (uses this configuration for dynamic gear selection)
---
--- @file    config/geo/GEO_TP_CONFIG.lua
--- @author  Morphetrix
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local GEOTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- Moonshade Earring is the primary TP bonus source for GEO
    -- Equipped in ear1 (left ear) to preserve ear2 for magic accuracy/potency

    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Weapons with automatic TP bonus
    ---============================================================================
    -- GEO does not use weapons with TP bonus (Idris/Solstice/Dunna are clubs)

    weapons = {}
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (always 0 for GEO)
---============================================================================
function GEOTPConfig.get_weapon_bonus(weapon_name)
    -- GEO weapons (Idris, Solstice, Dunna) do not provide TP bonus
    return 0
end

-- Make globally available
_G.GEOTPConfig = GEOTPConfig

return GEOTPConfig

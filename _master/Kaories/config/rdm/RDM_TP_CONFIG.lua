---============================================================================
--- RDM TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- Configuration for TP bonus equipment for Red Mage job. Determines which gear
--- to equip based on current TP to reach 2000/3000 TP thresholds for weaponskills.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring - all jobs)
---   • Weapon-based TP bonus tracking (REMA swords)
---   • Automatic TP threshold optimization (2000/3000 TP)
---   • Intelligent minimum gear selection
---
--- Note:
---   RDM uses swords (Crocea Mors, Naegling, Almace) - check for TP bonus on REMA
---
--- TP Thresholds:
---   • 2000 TP: Enhanced damage multiplier for most weaponskills
---   • 3000 TP: Maximum damage multiplier (capped)
---   • Calculator equips minimum gear needed to reach threshold
---
--- Dependencies:
---   • TPBonusCalculator (uses this configuration for dynamic gear selection)
---
--- @file    config/rdm/RDM_TP_CONFIG.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local RDMTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- Moonshade Earring is the primary TP bonus source for RDM
    -- Equipped in ear1 (left ear) to preserve ear2 for accuracy/potency

    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Weapons with automatic TP bonus
    ---============================================================================
    -- RDM REMA swords - add if they provide TP bonus

    weapons = {
        -- Crocea Mors: Check if provides TP bonus (REMA rapier)
        -- { name = "Crocea Mors", bonus = 500 },

        -- Almace: Check if provides TP bonus (REMA sword)
        -- { name = "Almace", bonus = 500 },
    }
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0 if no TP bonus weapon)
---============================================================================
function RDMTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end

    for _, weapon in ipairs(RDMTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

-- Make globally available
_G.RDMTPConfig = RDMTPConfig

return RDMTPConfig

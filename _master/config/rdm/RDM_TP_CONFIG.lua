---============================================================================
--- RDM TP Bonus Configuration - Weaponskill TP Optimization
---============================================================================
--- Configuration for TP bonus equipment for Red Mage job. Determines which gear
--- to equip worth putting on at the current TP for weaponskills.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring - all jobs)
---   • Weapon-based TP bonus tracking (REMA swords)
---   • TP pieces put on when they add more than the set pieces they replace
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
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2025-10-14
---============================================================================

local RDMTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- Moonshade Earring is the primary TP bonus source for RDM
    -- Equipped in ear1 (left ear) to preserve ear2 for accuracy/potency

    --- What one set piece is worth, for the TP pieces below. Before a weaponskill the
    --- Atelier's table says which pieces add more than the set pieces they replace
    --- (export the job in the Atelier: it is worked out for each weaponskill set).
    --- Without that table, or once the set changed, the fTP decides: the pieces go
    --- on when they add more than `replaces` for each set piece taken off.
    --- Example: replaces = 0.03 (3 %): Moonshade alone must add 3 % or more,
    --- Moonshade + Boii Cuisses 6 % or more. Never on a weaponskill whose fTP
    --- stays the same at every TP (its TP raises only critical hit rate, accuracy
    --- or a duration). 0.05 = put them on less often, 0 = whenever they add anything.
    replaces = 0.03,

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

-- Global export: the entry file only requires this file, RDM_PRECAST reads _G.RDMTPConfig
_G.RDMTPConfig = RDMTPConfig

return RDMTPConfig

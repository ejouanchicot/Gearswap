---============================================================================
--- RUN TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for Rune Fencer weaponskills.
--- Determines which gear to equip worth putting on at the current TP.
---
--- Features:
---   • TP bonus equipment configuration (Moonshade Earring)
---   • Weapon-based TP bonus tracking (Lionheart = Aeonic Great Sword)
---   • TP pieces put on when they add more than the set pieces they replace
---   • Intelligent minimum gear selection
---
--- Usage:
---   • Modify pieces table to add/remove TP bonus accessories
---   • Modify weapons table to add/remove REMA weapons with TP bonus
---   • get_weapon_bonus(weapon_name) - Get TP bonus from equipped weapon
---
--- @file    config/run/RUN_TP_CONFIG.lua
--- @author  ejouanchicot
--- @version 2.0.0 - Updated for RUN weapons
--- @date    Created: 2025-10-08 | Updated: 2025-11-04
---============================================================================
local RUNTPConfig = {
    ---============================================================================
    --- TP Bonus Equipment Pieces
    ---============================================================================
    -- These pieces will be equipped intelligently based on TP thresholds
    -- Put on when they add more than the set pieces they replace (`replaces` below)

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

    pieces = {{
        slot = "ear1",
        name = "Moonshade Earring",
        bonus = 250
    }},

    ---============================================================================
    --- Weapons with automatic TP bonus
    ---============================================================================
    -- TP bonus counted in either hand (main or off-hand)

    weapons = {{
        name = "Lionheart",
        bonus = 500
    } -- Aeonic Great Sword (RUN)
    }
}

---============================================================================
--- Get weapon TP bonus if equipped
--- @param  weapon_name string Name of the main weapon
--- @return number TP bonus from weapon (0 or 500)
---============================================================================
function RUNTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then
        return 0
    end

    for _, weapon in ipairs(RUNTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Global export: the entry file only requires this file, RUN_PRECAST reads _G.RUNTPConfig
_G.RUNTPConfig = RUNTPConfig

return RUNTPConfig

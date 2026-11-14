---============================================================================
--- WHM TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for White Mage.
--- WHM primarily casts spells but may engage in melee with club builds.
---
--- Features:
---   • TP bonus equipment pieces (Moonshade Earring, etc.)
---   • Weapon TP bonus detection
---   • TP pieces put on when they add more than the set pieces they replace
---
--- @file    config/whm/WHM_TP_CONFIG.lua
--- @module  WHM_TP_CONFIG
--- @author  ejouanchicot
--- @version 1.0.0
--- @date    Created: 2025-10-22
---============================================================================
local WHMTPConfig = {
    ---==========================================================================
    --- TP BONUS EQUIPMENT PIECES
    ---==========================================================================
    --- Put on before a weaponskill when they are worth it (shared/utils/weaponskill/tp_piece_decision.lua).
    --- Put on when they add more than the set pieces they replace (`replaces` below).

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
        {
            slot = "ear1",
            name = "Moonshade Earring",
            bonus = 250
        }
    },

    ---==========================================================================
    --- WEAPONS WITH AUTOMATIC TP BONUS
    ---==========================================================================
    --- TP bonus counted in either hand (main or off-hand).

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

-- Global export: the entry file also assigns it, WHM_PRECAST reads _G.WHMTPConfig
_G.WHMTPConfig = WHMTPConfig

return WHMTPConfig

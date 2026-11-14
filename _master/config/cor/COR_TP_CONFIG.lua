---============================================================================
--- COR TP Bonus Configuration
---============================================================================
--- Configuration for TP bonus equipment for Corsair
--- This determines which gear to equip worth putting on at the current TP
---
--- @file config/cor/COR_TP_CONFIG.lua
--- @module COR_TP_CONFIG
--- @author ejouanchicot
--- @version 1.0.0
--- @date Created: 2025-10-08
---============================================================================

local CORTPConfig = {
    ---============================================================================
    --- USER CONFIG - Adjust according to your character
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

    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    ---============================================================================
    --- Ranged Weapons with automatic TP bonus
    ---============================================================================
    -- COR uses RANGED weapons (guns) for TP bonus, not main weapons.
    -- The gun worn counts on every weaponskill, Savage Blade included
    -- (shared/utils/weaponskill/tp_bonus_calculator.lua). A gun not listed
    -- here is read from the game and your //gs c gearscan.

    ranged_weapons = {
        { name = "Anarchy +2", bonus = 1000 },
        { name = "Fomalhaut", bonus = 500 }     -- Aeonic gun
    }
}

---============================================================================
--- Get ranged weapon TP bonus if equipped
--- @param weapon_name string Name of the ranged weapon
--- @return number TP bonus from ranged weapon (0, 500, or 1000)
---============================================================================
function CORTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end

    for _, weapon in ipairs(CORTPConfig.ranged_weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end

    return 0
end

-- Make globally available
_G.CORTPConfig = CORTPConfig

return CORTPConfig

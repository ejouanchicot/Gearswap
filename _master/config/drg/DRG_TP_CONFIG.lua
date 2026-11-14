---============================================================================
--- DRG TP Configuration - Weaponskill TP bonus and the jump order
---============================================================================
--- pieces / weapons: TP bonus pieces the calculator may add to one of your
--- weaponskills to reach the next 1000 TP step (TPBonusCalculator, via
--- WSPrecastHandler).
---
--- jumps: the order //gs c jump tries the jumps in. It uses the first one
--- you have (job, level, job points) that is off recast. Every jump except
--- Super Jump (which drops your enmity, no attack) gives TP; with the wyvern
--- out Spirit Jump gives twice and Soul Jump three times the TP of a jump
--- (BG-Wiki). Example, High Jump first to shed enmity:
---   jumps = { 'High Jump', 'Soul Jump', 'Spirit Jump', 'Jump' },
---
--- @file    config/drg/DRG_TP_CONFIG.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

local DRGTPConfig = {
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

    -- Equipped only when they reach the next threshold
    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    -- Weapons with a TP bonus of their own
    weapons = {},

    -- //gs c jump: first ready jump of this list
    jumps = { 'Soul Jump', 'Spirit Jump', 'Jump', 'High Jump' },
}

--- TP bonus of a weapon, if listed
--- @param weapon_name string Name of the weapon
--- @return number TP bonus (0 when not listed)
function DRGTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end
    for _, weapon in ipairs(DRGTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end
    return 0
end

-- Global export: the entry file also assigns it, DRG_PRECAST and
-- DRG_COMMANDS read _G.DRGTPConfig
_G.DRGTPConfig = DRGTPConfig

return DRGTPConfig

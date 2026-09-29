---============================================================================
--- PUP TP Configuration - Weaponskill TP bonus and automaton WS threshold
---============================================================================
--- pieces / weapons: TP bonus pieces the calculator may add to one of YOUR
--- weaponskills to reach the next 1000 TP step (TPBonusCalculator, via
--- WSPrecastHandler).
---
--- pet_ws_tp: automaton TP from which its weaponskill gear
--- (sets.midcast.Pet.WeaponSkill) goes on while it fights and Pet WS is On.
--- The automaton uses its weaponskill at 1000 TP; raise it if your automaton
--- holds its TP longer (a "TP hold" setup), e.g. pet_ws_tp = 1500.
---
--- @file    config/pup/PUP_TP_CONFIG.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-29
---============================================================================

local PUPTPConfig = {
    -- Equipped only when they reach the next threshold
    pieces = {
        { slot = "ear1", name = "Moonshade Earring", bonus = 250 }
    },

    -- Weapons with a TP bonus of their own
    weapons = {},

    -- Automaton TP from which its weaponskill gear goes on
    pet_ws_tp = 1000,
}

--- TP bonus of a weapon, if listed
--- @param weapon_name string Name of the weapon
--- @return number TP bonus (0 when not listed)
function PUPTPConfig.get_weapon_bonus(weapon_name)
    if not weapon_name then return 0 end
    for _, weapon in ipairs(PUPTPConfig.weapons) do
        if weapon_name == weapon.name then
            return weapon.bonus
        end
    end
    return 0
end

-- Global export: the entry file also assigns it, PUP_PRECAST and
-- logic/pet_ws.lua read _G.PUPTPConfig
_G.PUPTPConfig = PUPTPConfig

return PUPTPConfig

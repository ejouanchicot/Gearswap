---============================================================================
--- Weapon Aftermath - the engaged set of a weapon while its Aftermath is up
---============================================================================
--- Any job: sets.engaged.<Weapon>AFM3 (the weapon's name as the job's weapon
--- state knows it: LaphriaAFM3, MasamuneAFM3, LiberatorAFM3...) goes on
--- while "Aftermath: Lv.3" (272) or the plain "Aftermath" (273, the name a
--- Prime weapon's may carry) is up. A job with an AftermathSet state set to
--- FastTP keeps the weapon's TP set instead.
---
--- @file shared/utils/equipment/weapon_aftermath.lua
--- @author ejouanchicot
--- @version 1.0
--- @date Created: 2026-09-30
---============================================================================

local WeaponAftermath = {}

--- The weapon's Aftermath set, or nil (no set for it, no Aftermath up, or
--- AftermathSet = FastTP).
--- @param weapon string|nil Weapon name as the weapon state holds it
--- @return table|nil
function WeaponAftermath.set(weapon)
    if not weapon or not (sets and sets.engaged) or not buffactive then
        return nil
    end
    if state and state.AftermathSet and state.AftermathSet.value == 'FastTP' then
        return nil
    end
    local set = sets.engaged[weapon .. 'AFM3']
    if set and (buffactive[272] ~= nil or buffactive[273] ~= nil) then
        return set
    end
    return nil
end

return WeaponAftermath

---============================================================================
--- Weapon Config - how MainWeapon / SubWeapon values are equipped
---============================================================================
--- equip_without_set = false (standard): a weapon state's value equips
---   sets[value], as always. A value with no set equips nothing, so a job's
---   idle / engaged sets keep the weapon they name.
---
--- equip_without_set = true: a value with no set equips that weapon directly
---   ({main = value} / {sub = value}), so a plain weapon needs no set, and the
---   same weapon can sit in main or sub. A set is still used when it names
---   that slot; keep one for an augmented weapon (two copies with different
---   augments cannot be told apart by name).
---
--- @file config/WEAPON_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-09-25
---============================================================================

return {
    equip_without_set = false,
}

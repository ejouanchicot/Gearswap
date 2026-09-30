---============================================================================
--- PLD Weapons - the shield each weapon takes, per mode (optional)
---============================================================================
--- Every line is a comment: each mode wears the sub of its own set, and a
--- Shining (polearm) takes Alber Strap. Uncomment and adapt to force, in a
--- given HybridMode, the shield that goes with the weapon in hand.
---
--- Weapons are the names of MainWeapon (your weapon sets: sets.Burtgang...).
---
--- @file pld/combat/PLD_WEAPONS.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    -- In these modes the shield follows the weapon, over the sub of the set:
    -- shields = {
    --     Sortie  = {Burtgang = 'Aegis', Naegling = 'Blurred Shield +1'},
    --     Tanking = {Burtgang = 'Aegis', Naegling = 'Duban'},
    -- },

    -- The weapon a mode puts in hand, whatever MainWeapon says:
    -- stance_weapon = {Tanking = 'Burtgang'},

    -- Two-handed weapons and their grip (default: Shining -> Alber Strap):
    -- grips = {Shining = 'Alber Strap'},
}

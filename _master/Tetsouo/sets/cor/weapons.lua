---  ═══════════════════════════════════════════════════════════════════════════
---   COR Weapons - Main / Sub / Ranged Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main / sub / range slot only) so it
---   can be combined with engaged / WS / RA sets via set_combine.
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/cor/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/cor/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Swords (main) — Melee WS focus
Weapons['Naegling'] = {
    main = 'Naegling',
    sub  = 'Demers. Degen +1',  -- Default sub for melee
}

-- • Rostam (augmented) — Phantom Roll potency
Weapons['Rostam'] = {
    main = {name = 'Rostam', augments = {'Path: C'}},
}

-- • Ranged (Guns) — primary COR weapons
Weapons['Anarchy'] = {
    range = 'Anarchy +2',
}

Weapons['Compensator'] = {
    range = 'Compensator',
}

-- Note: Death Penalty / Fomalhaut not currently in inventory.
--       Add definitions here when acquired.

return Weapons

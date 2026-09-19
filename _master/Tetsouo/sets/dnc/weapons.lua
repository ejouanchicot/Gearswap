---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Weapons - Main / Sub Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main and/or sub slot only) so it
---   can be combined with engaged / WS sets via set_combine.
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/dnc/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/dnc/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Mpu Gandring (Magical dagger) + Centovente sub
Weapons['Mpu Gandring'] = {
    main = 'Mpu Gandring',
    sub  = 'Centovente'
}

-- • Twashtar (Empyrean dagger) + Gleti's Knife sub
Weapons['Twashtar'] = {
    main = 'Twashtar',
    sub  = "Gleti's Knife"
}

-- • Demersal Degen +1 + Blurred Knife +1 sub
Weapons['Demersal'] = {
    main = 'Demersal Degen +1',
    sub  = 'Blurred Knife +1'
}

-- • Sub Weapon Override: Blurred Knife +1 (forces sub regardless of main weapon)
Weapons['Blurred'] = {
    sub = 'Blurred Knife +1'
}

return Weapons

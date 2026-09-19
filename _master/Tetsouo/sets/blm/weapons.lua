---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Weapons - Main / Sub / Ammo Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Black Mage weapon and ammo references used across multiple sets.
---     • Mains: Bunzi's Rod, Mpaca's Staff, Daybreak, Grioavolr, Malignance Pole,
---              Rubicundity (Dark Magic club)
---     • Subs : Ammurapi Shield, Khonsu
---     • Ammo : Staunch Tathlum +1, Ghastly Tathlum +1, Sroda Tathlum, Impatiens,
---              Oshasha's Treatise
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/blm/weapons')
---     sets.midcast['Elemental Magic'] = {
---         main = Weapons.Bunzi, sub = Weapons.Ammurapi, ammo = Weapons.Ammo.Sroda
---     }
---
---   @file    Tetsouo/sets/blm/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Main-hand weapons (BLM)
Weapons.Bunzi          = "Bunzi's Rod"          -- Top nuking / enfeebles main
Weapons.Mpaca          = "Mpaca's Staff"        -- Idle (refresh / DT)
Weapons.Daybreak       = 'Daybreak'             -- Cure / enhancing main
Weapons.Grioavolr      = 'Grioavolr'            -- Fast Cast main (6% FC)
Weapons.MalignancePole = 'Malignance Pole'      -- Engaged melee
Weapons.Rubicundity    = {
    name = 'Rubicundity',
    augments = {'Mag. Acc.+6', '"Mag.Atk.Bns."+7', 'Dark magic skill +7'}
}                                                -- Dark Magic club (Drain/Aspir)

-- • Sub-hand weapons / shields
Weapons.Ammurapi = 'Ammurapi Shield'             -- Magic shield (most casts)
Weapons.Khonsu   = 'Khonsu'                      -- Idle / engaged sub

-- • Ammo
Weapons.Ammo = {
    Staunch    = 'Staunch Tathlum +1',           -- Idle / cure (resistance)
    Ghastly    = 'Ghastly Tathlum +1',           -- Engaged / dark / enfeebles
    Sroda      = 'Sroda Tathlum',                -- Elemental Magic (MAB)
    Impatiens  = 'Impatiens',                    -- Fast Cast (Quick Magic)
    Oshasha    = "Oshasha's Treatise",           -- WS
}

return Weapons

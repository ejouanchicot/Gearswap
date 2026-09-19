---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Weapons - Main / Sub Weapon Set Definitions
---  ═══════════════════════════════════════════════════════════════════════════
---   Each entry returns a partial gear set (main or sub slot only) so it can
---   be combined with engaged / WS sets via set_combine.
---
---     • Burtgang     = Relic sword (enmity tank)
---     • Naegling     = Savage Blade focus
---     • Shining One  = Polearm (uses Alber Strap grip)
---     • Malevolence  = Magic burst / FC sword
---     • Kraken Club  = Multi-attack proc focus (PLD/DNC build)
---     • BurtgangKC   = Burtgang + Kraken Club combo
---
---   Sub weapons:
---     • Duban             = PDT shield
---     • Aegis             = MDT shield
---     • Alber Strap       = Polearm grip
---     • Blurred Shield +1 = Generic shield
---
---   Usage:
---     local Weapons = require('Tetsouo/sets/pld/weapons')
---     for name, weapon_set in pairs(Weapons) do
---         sets[name] = weapon_set
---     end
---
---   @file    Tetsouo/sets/pld/weapons.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Weapons = {}

-- • Main Weapons
Weapons['Burtgang']    = {main = 'Burtgang'}
Weapons['KC']          = {main = 'Kraken Club'}
Weapons['BurtgangKC']  = {main = 'Burtgang', sub = 'Kraken Club'} -- PLD/DNC multi-attack build
Weapons['Shining']     = {main = 'Shining One'} -- Polearm (uses Alber Strap grip)
Weapons['Naegling']    = {main = 'Naegling'}
Weapons['Malevo']      = {
    main = {
        name = 'Malevolence',
        augments = {
            'INT+10',
            'Mag. Acc.+10',
            '"Mag.Atk.Bns."+8',
            '"Fast Cast"+5'
        }
    }
}

-- • Sub Weapons
Weapons['Duban']             = {sub = 'Duban'}
Weapons['Aegis']             = {sub = 'Aegis'}
Weapons['Alber']             = {sub = 'Alber Strap'}
Weapons['Blurred Shield +1'] = {sub = 'Blurred Shield +1'}

return Weapons

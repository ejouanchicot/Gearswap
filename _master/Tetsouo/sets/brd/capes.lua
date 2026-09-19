---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Capes - Intarabus's Cape Variants
---  ═══════════════════════════════════════════════════════════════════════════
---   Three augmented variants of Intarabus's Cape for different situations:
---     • fc      = Fast Cast / song precast and midcast
---     • ws_str  = STR weaponskills (Savage Blade, Rudra's Storm, etc.)
---     • stp     = Store TP / melee engaged
---
---   Usage:
---     local Capes = require('Tetsouo/sets/brd/capes')
---     sets.engaged = { back = Capes.Intarabus.stp }
---
---   @file    Tetsouo/sets/brd/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-10
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Intarabus = {
    fc = {
        name = "Intarabus's Cape",
        augments = {
            'CHR+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Fast Cast"+10',
            'Phys. dmg. taken-10%'
        }
    },
    ws_str = {
        name = "Intarabus's Cape",
        augments = {
            'STR+20',
            'Accuracy+20 Attack+20',
            'STR+6',
            'Weapon skill damage +10%',
            'Phys. dmg. taken-10%'
        }
    },
    stp = {
        name = "Intarabus's Cape",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'DEX+10',
            '"Store TP"+10',
            'Phys. dmg. taken-10%'
        }
    },
}

return Capes

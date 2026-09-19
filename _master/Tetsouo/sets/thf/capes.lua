---  ═══════════════════════════════════════════════════════════════════════════
---   THF Capes - Toutatis's Cape Variants + Canny Cape
---  ═══════════════════════════════════════════════════════════════════════════
---   Augmented Toutatis's Cape variants for different situations:
---     • STP = Store TP+10 / engaged
---     • WS1 = Crit hit rate +10 / Rudra's, Evisceration (crit WS)
---     • WS2 = Weapon skill damage +10% / standard WS variant
---
---   Plus Canny Cape (Trick Attack with Dual Wield + Crit damage).
---
---   Usage:
---     local Capes = require('Tetsouo/sets/thf/capes')
---     sets.engaged = { back = Capes.Toutatis.STP }
---
---   @file    Tetsouo/sets/thf/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Toutatis = {
    STP = {
        name = "Toutatis's Cape",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'DEX+10',
            '"Store TP"+10',
            'Phys. dmg. taken-10%'
        }
    },
    WS1 = {
        name = "Toutatis's Cape",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'DEX+10',
            'Crit.hit rate+10',
            'Phys. dmg. taken-10%'
        }
    },
    WS2 = {
        name = "Toutatis's Cape",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'DEX+10',
            'Weapon skill damage +10%',
            'Phys. dmg. taken-10%'
        }
    },
}

-- Canny Cape — used on Trick Attack set (Dual Wield + Crit damage)
Capes.Canny = {
    name = 'Canny Cape',
    augments = {'DEX+1', 'AGI+2', '"Dual Wield"+3', 'Crit. hit damage +3%'}
}

return Capes

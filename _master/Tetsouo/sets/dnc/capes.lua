---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Capes - Senuna's Mantle + Toetapper Mantle
---  ═══════════════════════════════════════════════════════════════════════════
---   Augmented cape variants for different situations:
---     • Senuna.TP        = TP / DT (DEX+20, Acc/Atk+20, DEX+10, DA+10, PDT-10%)
---     • Senuna.WS        = WS (DEX+20, Acc/Atk+20, DEX+10, WSD+10%)
---     • Toetapper        = Step / Waltz utility cape (no augments)
---     • Earthcry         = Provoke / Animated Flourish
---     • Toetapper plain  = Reverse Flourish, Waltz
---
---   Usage:
---     local Capes = require('Tetsouo/sets/dnc/capes')
---     sets.engaged.Normal = { back = Capes.Senuna.TP }
---
---   @file    Tetsouo/sets/dnc/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Senuna = {
    TP = {
        name = "Senuna's Mantle",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'DEX+10',
            '"Dbl.Atk."+10',
            'Phys. dmg. taken-10%'
        }
    },
    WS = {
        name = "Senuna's Mantle",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'DEX+10',
            'Weapon skill damage +10%'
        }
    },
    plain = "Senuna's Mantle",
}

-- • Toetapper Mantle (Step / Waltz / Flourish utility)
Capes.Toetapper = 'Toetapper Mantle'

-- • Earthcry Mantle (Provoke / Animated Flourish)
Capes.Earthcry = 'Earthcry Mantle'

return Capes

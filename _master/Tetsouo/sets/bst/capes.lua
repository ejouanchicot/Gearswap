---  ═══════════════════════════════════════════════════════════════════════════
---   BST Capes - Artio's Mantle Variants + Pastoralist's Mantle
---  ═══════════════════════════════════════════════════════════════════════════
---   Augmented BST capes for different situations:
---     • Artio.STP      = Master Store TP / engaged
---     • Artio.WS1      = STR weaponskills (Decimation, Calamity, Primal Rend, etc.)
---     • Artio.PETSTP   = Pet Store TP / Ready moves
---     • Artio.PETMB    = Pet Magic Burst / nukes
---     • Pastoralist.petDT = Defensive pet tanking
---
---   Usage:
---     local Capes = require('Tetsouo/sets/bst/capes')
---     sets.engaged = { back = Capes.Artio.STP }
---
---   @file    Tetsouo/sets/bst/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Artio = {
    STP = {
        name = "Artio's Mantle",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'Accuracy+10',
            '"Store TP"+10',
            'Damage taken-5%',
        },
    },
    WS1 = {
        name = "Artio's Mantle",
        augments = {
            'STR+20',
            'Accuracy+20 Attack+20',
            'STR+10',
            'Weapon skill damage +10%',
            'Damage taken-5%',
        },
    },
    PETSTP = {
        name = "Artio's Mantle",
        augments = {
            'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20',
            'Accuracy+20 Attack+20',
            'Pet: Accuracy+10 Pet: Rng. Acc.+10',
            'Pet: Haste+10',
            'Pet: Damage taken -5%',
        },
    },
    PETMB = {
        name = "Artio's Mantle",
        augments = {
            'Pet: M.Acc.+20 Pet: M.Dmg.+20',
            'Eva.+20 /Mag. Eva.+20',
            'Pet: Magic Damage+10',
            'Pet: "Regen"+10',
            'Pet: Damage taken -5%',
        },
    },
}

Capes.Pastoralist = {
    petDT = {
        name = "Pastoralist's Mantle",
        augments = {
            'STR+3 DEX+3',
            'Pet: Accuracy+18 Pet: Rng. Acc.+18',
            'Pet: Damage taken -4%',
        },
    },
}

return Capes

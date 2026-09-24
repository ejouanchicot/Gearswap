---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Capes - Cichol's Mantle Variants
---  ═══════════════════════════════════════════════════════════════════════════
---   Four augmented variants of Cichol's Mantle for different situations:
---     • da         = Double Attack / engaged base
---     • stp        = Store TP / Kraken Club multi-attack
---     • ws1        = STR weaponskills (Ukko's Fury, Upheaval, Savage Blade, etc.)
---     • LessEnmity = Magic Eva / Enmity-10 (JA precast: Berserk, Warcry, etc.)
---
---   Usage:
---     local Capes = require('Tetsouo/sets/war/capes')
---     sets.engaged = { back = Capes.Cichol.da }
---
---   @file    Tetsouo/sets/war/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Cichol = {
    da = {
        name = "Cichol's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%'}
    },
    stp = {
        name = "Cichol's Mantle",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    },
    ws1 = {
        name = "Cichol's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
    },
    LessEnmity = {
        name = "Cichol's Mantle",
        augments = {'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity-10', 'Phys. dmg. taken-10%'}
    },
}

return Capes

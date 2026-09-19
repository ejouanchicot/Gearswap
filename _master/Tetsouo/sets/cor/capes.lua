---  ═══════════════════════════════════════════════════════════════════════════
---   COR Capes - Camulus's Mantle Variants
---  ═══════════════════════════════════════════════════════════════════════════
---   Variants of Camulus's Mantle for different situations:
---     • plain   = Unaugmented (idle / engaged / RA fallback)
---     • ws_str  = STR weaponskills (Savage Blade)
---
---   Usage:
---     local Capes = require('Tetsouo/sets/cor/capes')
---     sets.precast.WS = { back = Capes.Camulus.ws_str }
---
---   @file    Tetsouo/sets/cor/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Camulus = {
    plain = "Camulus's Mantle",
    ws_str = {
        name = "Camulus's Mantle",
        augments = {
            'STR+20',
            'Accuracy+20 Attack+20',
            'STR+10',
            'Weapon skill damage +10%',
            'Phys. dmg. taken-10%'
        }
    },
}

return Capes

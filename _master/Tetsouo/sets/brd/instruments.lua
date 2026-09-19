---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Instruments - Ranged Slot Items
---  ═══════════════════════════════════════════════════════════════════════════
---   Bard instruments grouped by family:
---     • Linos       — Augmented ranged for TP / WS
---     • Strings     — Carnwenhan, Daurdabla (song slot)
---     • Wind        — Gjallarhorn, Marsyas (Honor March), Loughnashade (Aria of Passion)
---
---   Usage:
---     local Instr = require('Tetsouo/sets/brd/instruments')
---     sets.engaged = { ranged = Instr.Linos.tp }
---     sets.precast['Honor March'] = { range = Instr.Marsyas }
---
---   @file    Tetsouo/sets/brd/instruments.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-10
---  ═══════════════════════════════════════════════════════════════════════════

local Instruments = {}

-- • Linos — Augmented Ranged
Instruments.Linos = {
    tp = {name = 'Linos', augments = {'Accuracy+15 Attack+15', '"Store TP"+4', 'Quadruple Attack +3'}},
    ws = {name = 'Linos', augments = {'Attack+20', 'Weapon skill damage +3%', 'STR+8'}},
}

-- • Wind Instruments
Instruments.Gjallarhorn  = 'Gjallarhorn'    -- Standard buff songs
Instruments.Marsyas      = 'Marsyas'        -- Honor March (CRITICAL)
Instruments.Loughnashade = 'Loughnashade'   -- Aria of Passion (CRITICAL)

-- • String Instruments
Instruments.Daurdabla    = 'Daurdabla'      -- Dummy songs (+2 slots)
Instruments.Carnwenhan   = 'Carnwenhan'     -- Mythic dagger (used as ranged-substitute or main)

return Instruments

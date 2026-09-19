---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Capes - Taranus's Cape Variants
---  ═══════════════════════════════════════════════════════════════════════════
---   Augmented variants of Taranus's Cape used by BLM:
---     • mab  = MAB / INT (elemental nuking, WS, dark magic)
---
---   Also exposes simpler capes referenced as plain strings.
---
---   Usage:
---     local Capes = require('Tetsouo/sets/blm/capes')
---     sets.midcast['Elemental Magic'] = { back = Capes.Taranus.mab }
---
---   @file    Tetsouo/sets/blm/capes.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

-- • Taranus's Cape — MAB / INT for nuking, WS, dark magic
Capes.Taranus = {
    mab = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'INT+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    },
    -- Plain name reference (idle/engaged use the same item without augment-specific reference)
    plain = "Taranus's Cape",
}

-- • Plain capes used as-is by BLM
Capes.SolemnityCape = 'Solemnity Cape'
Capes.PerimedeCape  = 'Perimede Cape'
Capes.FiFolletCape  = 'Fi Follet Cape +1'
Capes.AuristCape    = "Aurist's Cape +1"

return Capes

---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Capes - Rudianos's Mantle Variants
---  ═══════════════════════════════════════════════════════════════════════════
---   Six augmented variants of Rudianos's Mantle for the PLD tanking rotation.
---   Each variant has a documented "priority" used by HP-delta optimization
---   (gear equip order) — do NOT alter the priority values without recomputing.
---
---     • tank        = VIT/Eva/MEva/Enmity/PDT (idle, engaged, JA base)
---     • FCSIRD      = HP/FC/SIRD (precast FC, equip early — delta idle = +80)
---     • STP         = DEX/Acc/Atk/STP (every TP build: Sortie, DPS,
---                     Hoxne, BurtgangKC)
---     • WS          = STR/Acc/Atk/WSD/PDT (physical WS)
---     • cure        = MND/Eva/MEva/Cure potency/PDT (CureOther, equip late)
---     • EnmitySIRD  = VIT/Eva/MEva/Enmity/SIRD (SIRDEnmity midcast)
---
---   Usage:
---     local Capes = require('Tetsouo/sets/pld/capes')
---     sets.idle = { back = Capes.Rudianos.tank }
---
---   @file    Tetsouo/sets/pld/capes.lua
---   @author  Tetsouo
---   @version 1.1
---   @date    Created: 2026-05-11 | Updated: 2026-09-21
---  ═══════════════════════════════════════════════════════════════════════════

local Capes = {}

Capes.Rudianos = {
    tank = {
        name = "Rudianos's Mantle",
        priority = 3,
        augments = {
            'VIT+20',
            'Eva.+20 /Mag. Eva.+20',
            'Mag. Evasion+10',
            'Enmity+10',
            'Phys. dmg. taken-10%'
        }
    },
    FCSIRD = {
        name = "Rudianos's Mantle",
        priority = 12, -- Used in precast.FC (delta idle=+80 GAIN, equip early)
        augments = {
            'HP+60',
            'HP+20',
            '"Fast Cast"+10',
            'Spell interruption rate down-10%'
        }
    },
    STP = {
        name = "Rudianos's Mantle",
        priority = 0,
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'Accuracy+10',
            '"Store TP"+10',
            'Occ. inc. resist. to stat. ailments+10'
        }
    },
    WS = {
        name = "Rudianos's Mantle",
        priority = 0,
        augments = {
            'STR+20',
            'Accuracy+20 Attack+20',
            'STR+10',
            'Weapon skill damage +10%',
            'Phys. dmg. taken-10%'
        }
    },
    cure = {
        name = "Rudianos's Mantle",
        priority = 3, -- Used in CureOther (delta FC=-80, equip late to delay HP loss)
        augments = {
            'MND+20',
            'Eva.+20 /Mag. Eva.+20',
            'MND+10',
            '"Cure" potency +10%',
            'Phys. dmg. taken-10%'
        }
    },
    EnmitySIRD = {
        name = "Rudianos's Mantle",
        priority = 3, -- Used in SIRDEnmity (delta FC=-80, equip late to delay HP loss)
        augments = {
            'VIT+20',
            'Eva.+20 /Mag. Eva.+20',
            'VIT+10',
            'Enmity+10',
            'Spell interruption rate down-10%'
        }
    }
}

return Capes

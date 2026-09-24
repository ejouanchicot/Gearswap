---  ═══════════════════════════════════════════════════════════════════════════
---   COR Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All COR-specific armor pieces grouped by set:
---     • Lanun     = Relic +3/+4 (Phantom Roll, Wild Card, Random Deal, Fold)
---     • Chasseur  = Empyrean +1/+2/+3 (specific roll bonuses, melee accuracy)
---     • Laksamana = Artifact +4 (Snapshot / RA body)
---     • Malignance = Magic damage / PDT / Quick Draw
---     • Nyame     = WS armor (Path B)
---     • Misc      = Carmine Cuisses +1, Adamantite Armor, Councilor's Garb
---
---   Usage:
---     local Armor = require('Tetsouo/sets/cor/armor')
---     sets.idle.Normal = { head = Armor.Lanun.head, ... }
---
---   @file    Tetsouo/sets/cor/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Relic +3/+4 (Lanun) — Phantom Roll / Wild Card / Random Deal / Fold
Armor.Lanun = {
    head  = 'Lanun Tricorne +4',  -- Roll duration / potency
    body  = 'Lanun Frac +4',      -- Random Deal
    hands = 'Lanun Gants +4',     -- Fold
    legs  = 'Lanun Trews +3',     -- Snake Eye
    feet  = 'Lanun Bottes +4',    -- Wild Card
}

-- • Empyrean +1/+2/+3 (Chasseur) — Specific Roll Bonuses / Melee
Armor.Chasseur = {
    head_t2     = 'Chass. Tricorne +2',          -- Blitzer's Roll
    body_f2     = "Chasseur's Frac +2",          -- Tactician's Roll
    hands_g3    = "Chasseur's Gants +3",         -- Allies' Roll / melee
    legs_c3     = 'Chas. Culottes +3',           -- Caster's Roll / engaged
    feet_b1     = "Chasseur's Bottes +1",        -- Courser's Roll
    earring_e1  = {
        name = 'Chas. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
}

-- • Artifact +4 (Laksamana) — Snapshot / RA body
Armor.Laksamana = {
    body = 'Laksa. frac +4',  -- RA / WS
}

-- • Malignance — PDT / Quick Draw / RA
Armor.Malignance = {
    head  = 'Malignance Chapeau',
    body  = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs  = 'Malignance Tights',
    feet  = 'Malignance Boots',
}

-- • Nyame (WS / Damage Taken) — Path B
Armor.Nyame = {
    head_b  = {name = 'Nyame Helm', augments = {'Path: B'}},
    body_b  = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands_b = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs_b  = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet_b  = {name = 'Nyame Sollerets', augments = {'Path: B'}},
}

-- • Misc reusable pieces
Armor.Misc = {
    CarmineCuisses = {
        name = 'Carmine Cuisses +1',
        augments = {'MP+80', 'INT+12', 'MND+12'}
    },
    AdamantiteArmor = 'Adamantite Armor',
    CouncilorsGarb  = "Councilor's Garb",
}

return Armor

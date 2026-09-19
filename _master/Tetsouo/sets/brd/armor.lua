---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All BRD-specific armor pieces grouped by set:
---     • Fili    = Empyrean +3 (song potency / TP / movement)
---     • Bihu    = Relic +3/+4 (JA augments: Nightingale, Troubadour, Soul Voice)
---     • Brioso  = Artifact +3/+4 (song accuracy / FC body)
---     • Mousai  = Mythic Reforged (specific song bonuses)
---     • Nyame   = WS armor (Path B)
---     • Revel.  = Engaged base
---     • Inyanga = SIRD legs
---
---   Usage:
---     local Armor = require('Tetsouo/sets/brd/armor')
---     sets.idle = set_combine(sets.idle, { head = Armor.Fili.head })
---
---   @file    Tetsouo/sets/brd/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-10
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Empyrean +3 (Fili) — Song / Refresh / Movement
Armor.Fili = {
    head  = 'Fili Calot +3',       -- Madrigal, FC, refresh
    body  = 'Fili Hongreline +3',  -- Minuet
    hands = 'Fili Manchettes +3',  -- March
    legs  = 'Fili Rhingrave +3',   -- Ballad
    feet  = 'Fili Cothurnes +3',   -- Scherzo, movement speed
}

-- • Relic +3/+4 (Bihu) — Job Abilities
-- body_aug = augmented for Troubadour JA (different gear config, kept separate)
Armor.Bihu = {
    body     = 'Bihu Justaucorps +4',
    body_aug = {name = 'Bihu Justaucorps +4', augments = {'Enhances "Troubadour" effect'}},
    legs     = 'Bihu Cannions +3',                -- Soul Voice
    feet     = 'Bihu Slippers +3',                -- Nightingale
}

-- • AF +3/+4 (Brioso) — Magic Accuracy / Debuff Songs
Armor.Brioso = {
    head = 'Brioso Roundlet +4',  -- Debuff songs (Lullaby, Elegy, Paeon)
    body = 'Brioso Justau. +3',   -- Fast Cast body
    feet = 'Brioso Slippers +4',  -- Debuff songs feet
}

-- • Mythic Reforged (Mousai) — Specific Song Bonuses
Armor.Mousai = {
    head = 'Mousai Turban +1',      -- Etude
    body = 'Mousai Manteel +1',     -- Threnody
    legs = 'Mousai Seraweels +1',   -- Minne
}

-- • Nyame (WS / Damage Taken)
Armor.Nyame = {
    head  = 'Nyame Helm',
    body  = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs  = 'Nyame Flanchard',
    feet  = 'Nyame Sollerets',
    -- Path B variants (WS)
    head_b  = {name = 'Nyame Helm', augments = {'Path: B'}},
    body_b  = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands_b = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs_b  = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet_b  = {name = 'Nyame Sollerets', augments = {'Path: B'}},
}

-- • Revelation (Engaged base)
Armor.Revelation = {
    head  = 'Revelation Masque',
    body  = 'Revelation Platemail',
    legs  = 'Revelation Brais',
    feet  = 'Revelation Sabatons',
}

-- • Misc reusable pieces
Armor.Misc = {
    InyangaLegs       = 'Inyanga Shalwar +2',
    BlisteringSallet  = 'Blistering Sallet +1',
    LustraLeggings    = 'Lustra. Leggings +1',
    AdamantiteArmor   = 'Adamantite Armor',
    LeylineGloves     = {name = 'Leyline Gloves', augments = {'Accuracy+15', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15', '"Fast Cast"+3'}},
}

return Armor

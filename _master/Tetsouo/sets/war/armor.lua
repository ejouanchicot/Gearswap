---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All WAR-specific armor pieces grouped by set:
---     • Boii     = Empyrean +3 (DPS / TP / WS)
---     • Agoge    = Relic +3/+4 (JA enhancers: Berserk, Warcry, Aggressor)
---     • Pummeler = Artifact +3/+4 (TP / Aggressor duration)
---     • Sakpata  = DT / hybrid DPS armor
---     • Nyame    = Magic DT / hybrid WS
---     • Tatena.  = Multi-attack Kraken Club synergy
---     • Hjarrandi= Empyrean-tier head/body alternative (DT/STP)
---     • Dagon    = Subtle Blow body
---     • Souveran = Tank / enmity set
---     • Misc     = Reusable misc pieces (ammo, town, Adoulin body, etc.)
---
---   Usage:
---     local Armor = require('Tetsouo/sets/war/armor')
---     sets.engaged = { head = Armor.Hjarrandi.head, body = Armor.Boii.body }
---
---   @file    Tetsouo/sets/war/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Empyrean +3 (Boii) — DPS / WS / Multi-attack
Armor.Boii = {
    head     = 'Boii Mask +3',
    body     = 'Boii Lorica +3',
    hands    = 'Boii Mufflers +3',
    legs     = 'Boii Cuisses +3',
    feet     = 'Boii Calligae +3',
    earring  = 'Boii Earring +1',
}

-- • Relic +3/+4 (Agoge) — JA Duration Enhancers
Armor.Agoge = {
    head  = 'Agoge Mask +4',         -- Warcry TP bonus (Savagery merits) / Savage Blade
    body  = 'Agoge Lorica +3',       -- Aggressor duration +30s
    hands = 'Agoge Mufflers +3',     -- Defender enhancement
    feet  = 'Agoge Calligae +4',     -- Berserk duration +30s / Tomahawk
}

-- • Artifact +3/+4 (Pummeler) — Engaged / JA Duration
Armor.Pummeler = {
    head  = "pummeler's Mask +4",    -- Aggressor duration / Kraken Club
    body  = 'Pumm. Lorica +3',       -- Berserk duration +18s
    legs  = 'Pumm. Cuisses +4',
    feet  = 'Pumm. Calligae +4',
}

-- • Sakpata's (DT / Hybrid)
Armor.Sakpata = {
    head  = "Sakpata's Helm",
    body  = "Sakpata's Plate",
    hands = "Sakpata's Gauntlets",
    legs  = "Sakpata's Cuisses",
    feet  = "Sakpata's Leggings",
}

-- • Nyame (Magic DT / WS)
Armor.Nyame = {
    head  = 'Nyame Helm',
    body  = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs  = 'Nyame Flanchard',
    feet  = 'Nyame Sollerets',
    -- Path B variants (used in Judgment WS)
    legs_b = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet_b = {name = 'Nyame Sollerets', augments = {'Path: B'}},
}

-- • Tatenashi (Kraken Club multi-attack synergy)
Armor.Tatenashi = {
    hands = 'Tatena. Gote +1',
    legs  = 'Tatena. Haidate +1',
}

-- • Hjarrandi (alternative head/body for DT/STP)
Armor.Hjarrandi = {
    head = 'Hjarrandi Helm',
}

-- • Dagon (Subtle Blow body)
Armor.Dagon = {
    body = 'Dagon Breast.',
}

-- • Souveran +1 (Tank / Enmity)
Armor.Souveran = {
    head  = {
        name = 'Souv. Schaller +1',
        priority = 24,
        augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
    },
    body  = {
        name = 'Souv. Cuirass +1',
        priority = 3,
        augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
    },
    hands = {
        name = 'Souv. Handsch. +1',
        priority = 23,
        augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
    },
    legs  = {
        name = 'Souv. Diechlings +1',
        priority = 16,
        augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
    },
    feet  = {
        name = 'Souveran Schuhs +1',
        priority = 22,
        augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
    },
}

-- • Misc reusable pieces
Armor.Misc = {
    CoisteBodhar      = 'Coiste Bodhar',
    Knobkierrie       = 'Knobkierrie',
    CrepuscularPebble = 'Crepuscular Pebble',
    AurgelmirOrb      = 'Aurgelmir Orb +1',
    YetshilaPlus1     = 'Yetshila +1',
    ThrowingTomahawk  = 'Thr. Tomahawk',
    SapienceOrb       = 'Sapience Orb',
    Psilomene         = 'Psilomene',
    HermesSandals     = "Hermes' Sandals",
    CouncilorsGarb    = "Councilor's Garb",
}

return Armor

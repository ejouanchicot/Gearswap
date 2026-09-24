---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All WAR-specific armor pieces grouped by set:
---     • Boii      = Empyrean +3 (DPS / TP / WS)
---     • Agoge     = Relic +3/+4 (JA enhancers: Berserk, Warcry, Aggressor)
---     • Pummeler  = Artifact +3/+4 (TP / Aggressor duration)
---     • Sakpata   = DT / hybrid DPS armor
---     • Nyame     = Magic DT / hybrid WS
---     • Tatenashi = Multi-attack Kraken Club synergy
---     • Hjarrandi = Head alternative (DT / STP)
---     • Dagon     = Subtle Blow body
---     • Sulevia   = Hoxne stance head
---     • Souveran  = Tank / enmity set (Path C on every piece)
---     • Acc       = Accessories that carry HP (neck, ears, rings, back, waist)
---     • Misc      = Reusable misc pieces (ammo, town, Adoulin body, etc.)
---
---   HP PRIORITY: every piece that gives HP carries `priority = <its HP>`,
---   augments and Unity bonus included. GearSwap equips the highest priority
---   first and pieces without priority (0 HP) last, so HP-giving pieces go on
---   before HP-less ones come off and max HP does not dip during a swap.
---   Values come from Windower res/item_descriptions.lua (game data).
---   Pieces with no HP stay plain strings.
---
---   Usage:
---     local Armor = require('Tetsouo/sets/war/armor')
---     sets.engaged = { head = Armor.Hjarrandi.head, body = Armor.Boii.body }
---
---   @file    Tetsouo/sets/war/armor.lua
---   @author  Tetsouo
---   @version 1.1 - HP priorities
---   @date    Created: 2026-05-11 | Updated: 2026-09-23
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Empyrean +3 (Boii) — DPS / WS / Multi-attack
Armor.Boii = {
    head    = {name = 'Boii Mask +3',     priority = 73},
    body    = {name = 'Boii Lorica +3',   priority = 96},
    hands   = {name = 'Boii Mufflers +3', priority = 57},
    legs    = {name = 'Boii Cuisses +3',  priority = 80},
    feet    = {name = 'Boii Calligae +3', priority = 45},
    earring = 'Boii Earring +1',
}

-- • Relic +3/+4 (Agoge) — JA Duration Enhancers
Armor.Agoge = {
    head  = {name = 'Agoge Mask +4',     priority = 68},  -- Warcry TP bonus (Savagery merits) / Savage Blade
    body  = {name = 'Agoge Lorica +3',   priority = 81},  -- Aggressor duration +30s
    hands = {name = 'Agoge Mufflers +3', priority = 70},  -- Defender enhancement
    feet  = {name = 'Agoge Calligae +4', priority = 45},  -- Berserk duration +30s / Tomahawk
}

-- • Artifact +3/+4 (Pummeler) — Engaged / JA Duration
Armor.Pummeler = {
    head  = {name = "Pummeler's Mask +4", priority = 77},  -- Aggressor duration / Kraken Club
    body  = {name = 'Pumm. Lorica +3',    priority = 101}, -- Berserk duration +18s
    legs  = {name = 'Pumm. Cuisses +4',   priority = 95},
    feet  = {name = 'Pumm. Calligae +4',  priority = 65},
}

-- • Sakpata's (DT / Hybrid)
Armor.Sakpata = {
    head  = {name = "Sakpata's Helm",      priority = 91},
    body  = {name = "Sakpata's Plate",     priority = 136},
    hands = {name = "Sakpata's Gauntlets", priority = 91},
    legs  = {name = "Sakpata's Cuisses",   priority = 114},
    feet  = {name = "Sakpata's Leggings",  priority = 68},
}

-- • Nyame (Magic DT / WS) - Path B adds no HP
Armor.Nyame = {
    head   = {name = 'Nyame Helm',      priority = 91},
    body   = {name = 'Nyame Mail',      priority = 136},
    hands  = {name = 'Nyame Gauntlets', priority = 91},
    legs   = {name = 'Nyame Flanchard', priority = 114},
    feet   = {name = 'Nyame Sollerets', priority = 68},
    legs_b = {name = 'Nyame Flanchard', augments = {'Path: B'}, priority = 114},  -- Judgment
    feet_b = {name = 'Nyame Sollerets', augments = {'Path: B'}, priority = 68},   -- Judgment
}

-- • Tatenashi (Kraken Club multi-attack synergy)
Armor.Tatenashi = {
    hands = {name = 'Tatena. Gote +1',    priority = 27},
    legs  = {name = 'Tatena. Haidate +1', priority = 50},
    feet  = {name = 'Tatena. Sune. +1',   priority = 15},
}

-- • Hjarrandi (head alternative for DT/STP)
Armor.Hjarrandi = {
    head = {name = 'Hjarrandi Helm', priority = 114},
}

-- • Dagon (Subtle Blow body)
Armor.Dagon = {
    body = {name = 'Dagon Breast.', priority = 136},
}

-- • Sulevia's +2 (Hoxne stance head)
Armor.Sulevia = {
    head = {name = "Sulevia's Mask +2", priority = 40},
}

-- • Souveran +1 (Tank / Enmity) - Path C: base HP + 105
local SOUVERAN_PATH_C = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
Armor.Souveran = {
    head  = {name = 'Souv. Schaller +1',   augments = SOUVERAN_PATH_C, priority = 280},
    body  = {name = 'Souv. Cuirass +1',    augments = SOUVERAN_PATH_C, priority = 171},
    hands = {name = 'Souv. Handsch. +1',   augments = SOUVERAN_PATH_C, priority = 239},
    legs  = {name = 'Souv. Diechlings +1', augments = SOUVERAN_PATH_C, priority = 162},
    feet  = {name = 'Souveran Schuhs +1',  augments = SOUVERAN_PATH_C, priority = 227},
}

-- • Accessories that carry HP
--   Moonlight rings stay pinned to a wardrobe (same pins as common/rings.lua)
--   because GearSwap cannot tell two identical unaugmented rings apart.
--   A single Moonlight always goes in ring2 as MoonlightRing2, so every set
--   wears the same physical ring and a set change never swaps it.
Armor.Acc = {
    NullLoop        = {name = 'Null Loop',          priority = 50},
    CrypticEarring  = {name = 'Cryptic Earring',    priority = 40},
    OdnowaEarring   = {name = 'Odnowa Earring +1',  priority = 110}, -- converts 110 MP to HP
    MoonlightRing1  = {name = 'Moonlight Ring', bag = 'wardrobe 1', priority = 110},
    MoonlightRing2  = {name = 'Moonlight Ring', bag = 'wardrobe 2', priority = 110},
    GelatinousRing  = {name = 'Gelatinous Ring +1', priority = 35},  -- Unity rank 1 bonus
    SupershearRing  = {name = 'Supershear Ring',    priority = 30},
    MoonlightCape   = {name = 'Moonlight Cape',     priority = 275},
    EarthcryMantle  = {name = 'Earthcry Mantle',    priority = 30},
    TranceBelt      = {name = 'Trance Belt',        priority = 14},
}

-- • Misc reusable pieces
Armor.Misc = {
    CoisteBodhar      = 'Coiste Bodhar',
    Knobkierrie       = 'Knobkierrie',
    CrepuscularPebble = 'Crepuscular Pebble',
    SeethingBomblet   = 'Seeth. Bomblet +1',
    AurgelmirOrb      = 'Aurgelmir Orb +1',
    YetshilaPlus1     = 'Yetshila +1',
    ThrowingTomahawk  = 'Thr. Tomahawk',
    SapienceOrb       = 'Sapience Orb',
    HoxneAmpulla      = 'Hoxne Ampulla',     -- Sortie: Double Attack +100% on use
    Psilomene         = {name = 'Psilomene',        priority = 15},
    HermesSandals     = {name = "Hermes' Sandals", priority = 12},
    CouncilorsGarb    = "Councilor's Garb",
}

return Armor

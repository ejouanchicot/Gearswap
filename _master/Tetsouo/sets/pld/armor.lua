---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Armor - AF / Relic / Empyrean + Tank Sets
---  ═══════════════════════════════════════════════════════════════════════════
---   All PLD-specific armor pieces grouped by set:
---     • Chev        = Empyrean +3 (Chev. Armet/Cuirass/Gauntlets/Cuisses/Sabatons)
---                     Highest tier tank gear (DT, HP, enmity)
---     • Reverence   = Artifact +4 (Surcoat = FC body)
---     • Caballarius = Relic +3/+4 (Coronet, Gauntlets, Surcoat, Breeches, Leggings)
---                     JA enhancement bodies
---     • Souveran    = Souv. Schaller/Cuirass/Handsch./Schuhs (extra HP)
---     • Sakpata     = MDT set + magical accuracy WS pieces (Path A / no aug)
---     • Nyame       = Magic WS armor (Sanguine, Aeolian, Circle Blade, Savage)
---     • Adamantite  = Adamantite Armor (idle body, biggest HP gain)
---
---   Augmented pieces (Odyssean, Jumalik, etc.) are kept here too.
---
---   IMPORTANT: Many of these tables include `priority` fields tied to HP
---   delta calculations — preserve them when copying into sets.
---
---   Usage:
---     local Armor = require('Tetsouo/sets/pld/armor')
---     sets.idle = { head = Armor.Chev.head, body = Armor.Misc.Adamantite }
---
---   @file    Tetsouo/sets/pld/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Empyrean +3 (Chev.) — DT / HP / Enmity tank cornerstone
Armor.Chev = {
    head  = {name = 'Chev. Armet +3',     priority = 12}, -- delta Phx=+145 (idle)
    body  = {name = 'Chev. Cuirass +3',   priority = 16},
    hands = {name = 'Chev. Gauntlets +3', priority = 2},  -- delta Phx=-175 (idle, equip late)
    legs  = {name = 'Chev. Cuisses +3',   priority = 9},  -- delta Phx=+13
    feet  = {name = 'Chev. Sabatons +3',  priority = 1},  -- delta Phx=-175 (idle, equip last)
}

-- • Artifact +4 (Reverence) — FC body + JA
Armor.Reverence = {
    surcoat = {name = 'Reverence Surcoat +4', priority = 13}, -- precast.FC delta idle=+82
    feet    = {name = 'Rev. Leggings +4'},                    -- Holy Circle
}

-- • Relic +3/+4 (Caballarius) — Job Ability enhancements
Armor.Caballarius = {
    coronet   = {name = 'Cab. Coronet +4'},                            -- Rampart
    gauntlets = {name = 'Cab. Gauntlets +4'},                          -- Shield Bash
    surcoat   = {name = 'Cab. Surcoat +3'},                            -- Fealty
    breeches  = {name = 'Cab. Breeches +4', priority = 2},             -- Invincible / FullEnmity delta FC=-82
    leggings  = {name = 'Cab. Leggings +4'},                           -- Sentinel
}

-- • Souveran +1 — Extra HP set (Enmity body, FC hands, Cure base, Phalanx feet)
Armor.Souveran = {
    head    = {name = 'Souv. Schaller +1', priority = 8},
    cuirass      = {name = 'Souv. Cuirass +1',     priority = 1}, -- FullEnmity delta FC=-93
    cuirass_cure = {name = 'Souveran Cuirass +1',  priority = 2}, -- CureSelf/Other delta FC=-93 (different priority for cure context)
    handsch = {                                                  -- FullEnmity / SIRDEnmity / Phalanx delta FC=+214 (biggest GAIN)
        name = 'Souv. Handsch. +1',
        priority = 13
    },
    handsch_cure = {                                             -- SIRDEnmity variant w/ cure aug
        name = 'Souv. Handsch. +1',
        augments = {
            'HP+105',
            'Enmity+9',
            'Potency of "Cure" effect received +15%'
        },
        priority = 13 -- delta FC=+214 (biggest GAIN, equip FIRST)
    },
    schuhs  = {name = 'Souveran Schuhs +1', priority = 12}, -- PhalanxPotency delta FC=+175 GAIN
}

-- • Sakpata's (MDT + magical accuracy WS) — Path A
Armor.Sakpata = {
    head  = {name = "Sakpata's Helm",      augments = {'Path: A'}},
    body  = {name = "Sakpata's Plate",     augments = {'Path: A'}},
    hands = {name = "Sakpata's Gauntlets", augments = {'Path: A'}},
    legs  = {name = "Sakpata's Cuisses",   augments = {'Path: A'}},
    feet  = {name = "Sakpata's Leggings",  augments = {'Path: A'}},
    -- Plain variants (no aug) used in WS base set
    head_plain  = "Sakpata's Helm",
    body_plain  = "Sakpata's Plate",
    hands_plain = "Sakpata's Gauntlets",
    legs_plain  = {name = "Sakpata's Cuisses", priority = 3}, -- PhalanxPotency delta FC=-50
    legs_plain_b = "Sakpata's Cuisses",
}

-- • Nyame (Magic WS armor)
Armor.Nyame = {
    head  = {name = 'Nyame Helm'},
    body  = {name = 'Nyame Mail'},
    hands = {name = 'Nyame Gauntlets'},
    legs  = {name = 'Nyame Flanchard'},
    feet  = {name = 'Nyame Sollerets'},
}

-- • Loess Barbuta +1 (Enmity head — FullEnmity / SIRDEnmity)
Armor.LoessBarbuta = {
    plain = {name = 'Loess Barbuta +1', priority = 11}, -- FullEnmity delta FC=+67
    path_a = {name = 'Loess Barbuta +1', augments = {'Path: A'}, priority = 9}, -- SIRDEnmity
}

-- • Odyssean Augmented Pieces
Armor.Odyssean = {
    -- CureSelf body (FC+7 aug)
    chestplate_fc = {
        name = 'Odyss. Chestplate',
        augments = {
            'DEX+3',
            'Magic Damage +2',
            '"Fast Cast"+7',
            'Accuracy+13 Attack+13',
            'Mag. Acc.+1 "Mag.Atk.Bns."+1'
        }
    },
    -- PhalanxPotency body
    chestplate_phalanx = {
        name = 'Odyss. Chestplate',
        augments = {
            'Pet: Mag. Acc.+27',
            'Rng.Atk.+3',
            'Phalanx +5',
            'Accuracy+1 Attack+1',
            'Mag. Acc.+4 "Mag.Atk.Bns."+4'
        },
        priority = 1 -- delta FC=-264 (biggest LOSS, equip LAST)
    },
    -- PhalanxPotency head
    helm_phalanx = {
        name = 'Odyssean Helm',
        augments = {
            'AGI+11',
            'Accuracy+18',
            'Phalanx +5',
            'Mag. Acc.+17 "Mag.Atk.Bns."+17'
        },
        priority = 4 -- delta FC=-38
    },
    -- SIRDEnmity feet
    greaves_sird = {
        name = 'Odyssean Greaves',
        augments = {'Attack+19', 'Enmity+8', 'Accuracy+8'},
        priority = 4 -- delta FC=-32
    },
    -- SIRDPhalanx feet
    greaves_phalanx = {
        name = 'Odyssean Greaves',
        augments = {
            '"Fast Cast"+2',
            'STR+7',
            'Phalanx +5',
            'Accuracy+14 Attack+14',
            'Mag. Acc.+10 "Mag.Atk.Bns."+10'
        }
    },
    -- Cure / generic Odyssean greaves
    greaves_cure = {name = 'Odyssean Greaves', priority = 5},
}

-- • Jumalik Gear (Refresh head/body)
Armor.Jumalik = {
    head = {
        name = 'Jumalik Helm',
        priority = 0,
        augments = {
            'MND+10',
            '"Mag.Atk.Bns."+15',
            'Magic burst dmg.+10%',
            '"Refresh"+1'
        }
    },
    body = {
        name = 'Jumalik Mail',
        priority = 0,
        augments = {'HP+50', 'Attack+15', 'Enmity+9', '"Refresh"+2'}
    }
}

-- • Weard Mantle (PhalanxPotency back / SIRDPhalanx back)
Armor.Weard = {
    plain = {name = 'Weard Mantle', priority = 2}, -- PhalanxPotency delta FC=-80
    phalanx = {
        name = 'Weard Mantle',
        priority = 0,
        augments = {'VIT+4', 'Phalanx +5'}
    }
}

-- • Misc reusable pieces (singletons used across many sets)
Armor.Misc = {
    Adamantite       = {name = 'Adamantite Armor', priority = 13}, -- idle body, delta Phx=+182
    AdamantiteEng    = {name = 'Adamantite Armor', priority = 15}, -- idleNormal body
    StaunchTathlum   = {name = 'Staunch Tathlum +1', priority = 8},
    SapienceOrb      = {name = 'Sapience Orb', priority = 10},
    SworneBrais      = {name = 'Sworn Brais', priority = 11},
    EnifCosciales    = {name = 'Enif Cosciales', priority = 9},
    FoundersHose     = {name = "Founder's Hose", priority = 0},
    FoundersHoseCure = {name = "Founder's Hose", priority = 1},
    -- priority 7 is for the fast-cast sets; sets.idleRegen uses a plain
    -- reference instead, the set it lands on carrying no priorities.
    RegalGauntlets   = {name = 'Regal Gauntlets', priority = 7},
    -- Regen+13, HP+182. Worn by sets.idleRegen, which only ever lands on
    -- sets.idle.MDT - a set that carries no priorities at all, so this one
    -- takes none either rather than being the single ranked piece in it.
    SacroBreastplate = {name = 'Sacro Breastplate'},
    CarmineMask      = {name = 'Carmine Mask +1', priority = 3},
    LeylineGloves    = {name = 'Leyline Gloves', priority = 6},
    EschiteGauntlets = {name = 'Eschite Gauntlets'},
    ShabtiCuirass    = {name = 'Shabti Cuirass', priority = 1},
    HjarrandiBreast  = 'Hjarrandi Breast.',
    SuleviasMask     = "Sulevia's Mask +2",
    SuleviasLeggings = "Sulevia's Leggings +2",
    CarmineCuisses   = 'Carmine Cuisses +1',
    CouncilorsGarb   = "Councilor's Garb",
    -- Chev. variants used in engaged (different priorities than idle)
    ChevHandsEng   = {name = 'Chev. Gauntlets +3', priority = 8},
    ChevHandsCure  = {name = "Chevalier's Gauntlets +3", priority = 11},
    ChevLegsEng    = {name = 'Chev. Cuisses +3', priority = 10},
    ChevLegsNormal = {name = 'Chev. Cuisses +3', priority = 16},
    ChevFeetEng    = {name = 'Chev. Sabatons +3', priority = 6},
    ChevFeetPlain  = {name = "Chevalier's Sabatons +3", priority = 9},
    ChevFeetFC     = {name = "Chevalier's Sabatons +3", priority = 4}, -- FullEnmity delta FC=0
    ChevFeetBare   = {name = "Chevalier's Sabatons +3"},               -- Divine Emblem
    ChevBodySird   = {name = 'Chev. Cuirass +3', priority = 1},        -- SIRDEnmity delta FC=-113
    ChevBodySirdPlain = {name = "Chevalier's Cuirass +3"},
    ChevEarringPlus = {name = 'Chev. Earring +1', priority = 0},
    SouvSchallerPlain = {name = 'Souveran Schaller +1'},
    MoonlightCapeCure = {name = 'Moonlight Cape', priority = 13}, -- CureSelf delta FC=+195
    MoonlightCapeBase = {name = 'Moonlight Cape', priority = 12}, -- Cure base
    MoonlightCapeEnlight = {name = 'Moonlight Cape', priority = 16},
}

return Armor

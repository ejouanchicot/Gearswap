---  ═══════════════════════════════════════════════════════════════════════════
---   BST Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All BST-specific armor pieces grouped by set, plus common BST gear and
---   BST-only ring extensions not covered by the shared common/rings module.
---
---     • Ankusa   = Relic +3 (pet status / Reward)
---     • Totemic  = Artifact +3 (master / pet; body_fh is an Ankusa Jackcoat)
---     • Anwig    = Anwig Salade (pet DT head)
---     • Nukumi   = Empyrean +3 (pet acc/atk, master)
---     • Mavi     = (legacy support)
---     • Ferine   = (legacy support)
---     • Nyame    = WS / DT armor
---     • Malignance = Master defensive set
---     • Gleti    = Pet engaged / WS pieces
---     • Emicho   = Pet ready / WS
---     • Valorous = Augmented pet phys/MAB
---     • Jumalik  = Refresh body / head
---     • Rings    = BST-specific rings (extensions of common/rings)
---     • Earrings = Common BST earrings
---     • Necks    = Common BST necks
---
---   Usage:
---     local Armor = require('Tetsouo/sets/bst/armor')
---     sets.idle = { head = Armor.Malignance.head }
---
---   @file    Tetsouo/sets/bst/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- ARMOR SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Malignance (Master Defensive)
Armor.Malignance = {
    head  = 'Malignance Chapeau',
    body  = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs  = 'Malignance Tights',
    feet  = 'Malignance Boots',
}

-- • Nyame (WS / Damage Taken)
Armor.Nyame = {
    head  = 'Nyame Helm',
    body  = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs  = 'Nyame Flanchard',
    feet  = 'Nyame Sollerets',
}

-- • Nukumi (Empyrean +3 - Pet acc/atk, Master defense)
Armor.Nukumi = {
    head  = 'Nuk. Cabasset +3',
    body  = 'Nukumi Gausape +3',
    hands = 'Nukumi Manoplas +3',
    legs  = 'Nukumi Quijotes +3',
    feet  = 'Nukumi Ocreae +3',
}

-- • Ankusa (Relic +3 - Pet status / Beast Affinity / Healer)
Armor.Ankusa = {
    head  = 'Ankusa Helm +3',
    gloves_ba = {name = 'Ankusa Gloves +3', augments = {'Enhances "Beast Affinity" effect'}},
    gloves    = 'Ankusa Gloves +3',
    trousers_fam = {name = 'Ankusa Trousers +3', augments = {'Enhances "Familiar" effect'}},
    gaiters_healer = {name = 'Ankusa Gaiters +3', augments = {'Enhances "Beast Healer" effect'}},
    gaiters   = 'Ankusa Gaiters +3',
}

-- • Totemic (Artifact +3) - body_fh is the Relic Ankusa Jackcoat (Feral Howl)
Armor.Totemic = {
    body_fh = {name = 'An. Jackcoat +3', augments = {'Enhances "Feral Howl" effect'}},
    body    = 'Tot. Jackcoat +3',
}

-- • Gleti's (Pet engaged / WS)
Armor.Gleti = {
    body     = "Gleti's Cuirass",
    hands    = "Gleti's Gauntlets",
    breeches = "Gleti's Breeches",  -- Ready Recast -5s
    boots    = "Gleti's Boots",
}

-- • Emicho (Pet WS / engaged)
Armor.Emicho = {
    head = 'Emicho Coronet',
}

-- • Anwig (Pet DT head)
Armor.Anwig = {
    head = {
        name = 'Anwig Salade',
        augments = {
            'CHR+4',
            '"Waltz" ability delay -2',
            'Attack+3',
            'Pet: Damage taken -10%',
        },
    },
}

-- • Khimaira (Reward potency)
Armor.Khimaira = {
    head = 'Khimaira Bonnet',
}

-- • Jumalik (Refresh head / body)
Armor.Jumalik = {
    head = {
        name = 'Jumalik Helm',
        augments = {
            'MND+10',
            '"Mag.Atk.Bns."+15',
            'Magic burst dmg.+10%',
            '"Refresh"+1',
        },
    },
    body = {
        name = 'Jumalik Mail',
        augments = {
            'HP+50',
            'Attack+15',
            'Enmity+9',
            '"Refresh"+2',
        },
    },
}

-- • Valorous / Emicho augmented (PhysMulti pet gear)
Armor.PhysMultiGear = {
    head = {name = 'Valorous Mask', augments = {'Pet: "Dbl. Atk."+5', 'Pet: STR+6', 'Pet: Attack+15 Pet: Rng.Atk.+15'}},
    body = {
        name = 'Valorous Mail',
        augments = {
            'Pet: "Dbl. Atk."+5',
            'Pet: STR+7',
            'Pet: Accuracy+11 Pet: Rng. Acc.+11',
            'Pet: Attack+8 Pet: Rng.Atk.+8',
        },
    },
    hands = {name = 'Valorous Mitts', augments = {'Pet: Attack+15 Pet: Rng.Atk.+15', 'Pet: "Dbl. Atk."+5'}},
    legs  = {name = 'Emicho Hose',    augments = {'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3'}},
    feet  = {name = "Gleti's Boots"},
}

-- • Valorous augmented (MAB pet gear)
Armor.MabGear = {
    head = {
        name = 'Valorous Mask',
        augments = {'Pet: "Mag.Atk.Bns."+28', 'Pet: INT+12', 'Pet: Attack+6 Pet: Rng.Atk.+6'},
    },
    body = {name = 'Valorous Mail', augments = {'Pet: "Mag.Atk.Bns."+27', '"Dbl.Atk."+1', 'Pet: INT+13'}},
    hands = {
        name = 'Valorous Mitts',
        augments = {
            'Pet: "Mag.Atk.Bns."+30',
            '"Store TP"+5',
            'Pet: INT+14',
            'Pet: Accuracy+14 Pet: Rng. Acc.+14',
            'Pet: Attack+2 Pet: Rng.Atk.+2',
        },
    },
    legs = {name = 'Valorous Hose', augments = {'Pet: "Mag.Atk.Bns."+27', 'Pet: "Subtle Blow"+7', 'Pet: INT+8'}},
    feet = {
        name = 'Valorous Greaves',
        augments = {'Pet: "Mag.Atk.Bns."+29', 'Pet: INT+15', 'Pet: Accuracy+13 Pet: Rng. Acc.+13'},
    },
}

-- • Miscellaneous reusable pieces
Armor.Misc = {
    AcroHelm        = 'Acro Helm',
    AcroBreeches    = 'Acro Breeches',
    MirkeWardecors  = 'Mirke Wardecors',
    AdamanSollerets = 'Adaman Sollerets',
    SkdJambeaux     = 'Skd. Jambeaux +1',
}

-- ═══════════════════════════════════════════════════════════════════════════
-- BST-SPECIFIC RING EXTENSIONS (common/rings.lua covers the wardrobe rings)
-- ═══════════════════════════════════════════════════════════════════════════

Armor.Rings = {
    Varar2    = 'Varar Ring +1',
    Murky     = 'Murky Ring',
    CPalug    = 'C. Palug Ring',
    Gere      = 'Gere Ring',
    Hetairoi  = 'Hetairoi Ring',
    Cornelia  = "Cornelia's Ring",
    Metamorph = 'Metamor. Ring +1',
    Purity    = 'Purity Ring',
    Tali      = "Tali'ah Ring",
    Sroda     = 'Sroda Ring',
    Blenmot   = "Blenmot's Ring +1",
    Ilabrat   = 'Ilabrat Ring',
}

-- ═══════════════════════════════════════════════════════════════════════════
-- COMMON BST EARRINGS
-- ═══════════════════════════════════════════════════════════════════════════

Armor.Earrings = {
    Odnowa     = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
    Nukumi     = {
        name = 'Nukumi Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Pet: "Dbl. Atk."+6'},
    },
    Telos      = 'Telos Earring',
    Enmerkar   = 'Enmerkar Earring',
    Sroda      = 'Sroda Earring',
    Ferine     = 'Ferine Earring',
    Thrud      = 'Thrud Earring',
    Sortiarius = 'Sortiarius Earring',
    Friomisi   = 'Friomisi Earring',
    Hija       = 'Hija Earring',
    Sherida    = 'Sherida Earring',
}

-- ═══════════════════════════════════════════════════════════════════════════
-- COMMON BST NECKS
-- ═══════════════════════════════════════════════════════════════════════════

Armor.Necks = {
    BstCollar    = {name = 'Bst. Collar +2', augments = {'Path: A'}},
    EliteRoyal   = 'Elite Royal Collar',
    Adad         = 'Adad Amulet',
    Sibyl        = 'Sibyl Scarf',
    Nicander     = "Nicander's Necklace",
    Shulmanu     = 'Shulmanu Collar',
}

return Armor

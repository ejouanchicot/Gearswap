---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All DNC-specific armor pieces grouped by set:
---     • Etoile     = JSE neck +2 (Etoile Gorget only)
---     • Maculele   = Empyrean +3 (Tiara, Casaque, Bangles, Tights, Toe Sh.)
---     • Maxixi     = Artifact +3/+4 (Tiara, Bangles, Casaque, Toe Shoes)
---     • Horos      = Relic +3/+4 (Casaque, Bangles, Tights, Tiara, Shoes)
---     • Nyame      = WS armor (Path A baseline)
---     • Malignance = DT / accuracy hybrid
---     • Adhemar    = Multi-attack body / hands / head
---     • Gleti      = HP / DT armor
---     • Meghanada  = WS support (Cuirie/Gloves/Chausses)
---     • Mummu      = Magic JA precast (Violent Flourish)
---
---   Usage:
---     local Armor = require('Tetsouo/sets/dnc/armor')
---     sets.engaged.Normal = { head = Armor.Maculele.head }
---
---   @file    Tetsouo/sets/dnc/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • JSE neck +2 (Etoile Gorget) — TP / Skillchain support
Armor.Etoile = {
    gorget    = 'Etoile Gorget +2',
    gorget_a  = {name = 'Etoile Gorget +2', augments = {'Path: A'}},
}

-- • Empyrean +3 (Maculele) — TP / WS / Step
Armor.Maculele = {
    head    = 'Maculele Tiara +3',
    body    = 'Macu. Casaque +3',
    hands   = 'Macu. Bangles +3',
    legs    = 'Maculele Tights +3',
    feet    = 'Macu. Toe Sh. +3',
    earring = 'Macu. Earring +1',
}

-- • Artifact +3/+4 (Maxixi) — Waltz / Step potency upgrades
Armor.Maxixi = {
    head  = 'Maxixi Tiara +4',
    body  = 'Maxixi Casaque +3',
    hands = 'Maxixi Bangles +4',
    feet  = 'Maxixi Toe Shoes +4',
}

-- • Relic +3/+4 (Horos) — Job Ability / Saber Dance
Armor.Horos = {
    head  = 'Horos Tiara +3',
    body  = 'Horos Casaque +3',
    hands = 'Horos Bangles +3',
    legs  = 'Horos Tights +4',
    feet  = 'Horos T. Shoes +3',
}

-- • Nyame (WS / Damage Taken — Path A baseline)
Armor.Nyame = {
    head  = 'Nyame Helm',
    body  = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs  = 'Nyame Flanchard',
    feet  = 'Nyame Sollerets',
}

-- • Malignance (DT / Accuracy hybrid)
Armor.Malignance = {
    head  = 'Malignance Chapeau',
    body  = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs  = 'Malignance Tights',
    feet  = 'Malignance Boots',
}

-- • Adhemar (Multi-attack)
Armor.Adhemar = {
    bonnet_p1 = {name = 'Adhemar Bonnet +1', augments = {'STR+12', 'DEX+12', 'Attack+20'}},
    wrist_p1  = 'Adhemar Wrist. +1',
}

-- • Gleti's (HP / DT body chain)
Armor.Gleti = {
    head    = "Gleti's Mask",
    body    = "Gleti's Cuirass",
    hands   = "Gleti's Gauntlets",
    legs    = "Gleti's Breeches",
    feet    = "Gleti's Boots",
    knife   = "Gleti's Knife",
}

-- • Meghanada (WS support pieces)
Armor.Meghanada = {
    cuirie_p2   = 'Meg. Cuirie +2',
    gloves_p2   = 'Meg. Gloves +2',
    chausses_p2 = 'Meg. Chausses +2',
}

-- • Misc reusable pieces (cross-set)
Armor.Misc = {
    BlisteringSallet  = 'Blistering Sallet +1',
    LustraLeggings    = {name = 'Lustra. Leggings +1', augments = {'HP+65', 'STR+15', 'DEX+15'}},
    LustraSubligar    = 'Lustr. Subligar +1',
    HerculeanHelmTH   = {name = 'Herculean Helm', augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}},
    HerculeanTrousersTH = {name = 'Herculean Trousers', augments = {'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6'}},
    LeylineGloves     = 'Leyline Gloves',
    SamnuhaTights     = 'Samnuha Tights',
    LimboTrousers     = 'Limbo Trousers',
    SkadiBoots        = "Skadi's Jambeaux +1",
    DashingSubligar   = 'Dashing Subligar',
    AnwigSalade       = 'Anwig Salade',
    EmetHarness       = 'Emet Harness +1',
    CouncilorsGarb    = "Councilor's Garb",
}

return Armor

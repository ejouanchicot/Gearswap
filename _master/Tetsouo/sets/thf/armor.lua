---  ═══════════════════════════════════════════════════════════════════════════
---   THF Armor - AF / Relic / Empyrean and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All THF-specific armor pieces grouped by set:
---     • Plunderer = AF +3/+4 (Ambush body, Feint legs, Perfect Dodge hands)
---     • Pillager  = Relic +3/+4 (Flee feet, Steal-related, WS-friendly)
---     • Skulker   = Empyrean +3 (Treasure Hunter, TA support)
---     • Adhemar   = Mythic Reforged (DEX/STR augments, melee/WS)
---     • Mummu     = Crit-focused mid-tier
---     • Nyame     = Magic WS / DT (Path B)
---     • Malignance= DT engaged base
---     • Gleti's   = Multi-attack idle/engaged
---     • Meghanada = Regen idle / Exenterator
---
---   Usage:
---     local Armor = require('Tetsouo/sets/thf/armor')
---     sets.idle = { head = Armor.Gleti.head, ... }
---
---   @file    Tetsouo/sets/thf/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Empyrean +3 (Skulker) — Treasure Hunter / TA
Armor.Skulker = {
    head    = "Skulker's Bonnet +3",
    body    = "Skulker's Vest +3",
    hands   = 'Skulk. Armlets +3',
    legs    = 'Skulk. Culottes +3',
    feet    = 'Skulk. Poulaines +3',     -- TH+4 cornerstone
    earring = 'Skulk. Earring +1',
}

-- • Relic +3/+4 (Pillager) — WS / Steal / Flee
-- body_ambush = augmented for Ambush JA (different gear config, kept separate)
Armor.Pillager = {
    head        = 'Pill. Bonnet +4',
    body        = 'Pill. Vest +4',
    body_ambush = {name = "Plunderer's Vest +4", augments = {'Enhances "Ambush" effect'}},
    hands       = 'Pill. Armlets +4',
    legs        = 'Pill. Culottes +4',
    feet        = 'Pill. Poulaines +4',
}

-- • AF +3/+4 (Plunderer) — Ambush / Feint / Perfect Dodge / Crit
Armor.Plunderer = {
    body              = "Plunderer's Vest +4",
    body_ambush       = {name = "Plunderer's Vest +4", augments = {'Enhances "Ambush" effect'}},
    hands             = 'Plun. Armlets +4',
    hands_perfect_dodge = {name = 'Plun. Armlets +4', augments = {'Enhances "Perfect Dodge" effect'}},
    legs              = 'Plun. Culottes +4',
    legs_feint        = {name = 'Plun. Culottes +4', augments = {'Enhances "Feint" effect'}},
    feet_ac           = {name = 'Plun. Poulaines +3', augments = {"Enhances \"Assassin's Charge\" effect"}},
}

-- • Mythic Reforged (Adhemar) — DEX / STR melee+WS
Armor.Adhemar = {
    head  = {name = 'Adhemar Bonnet +1', augments = {'STR+12', 'DEX+12', 'Attack+20'}},
    hands = {name = 'Adhemar Wrist. +1', augments = {'STR+12', 'DEX+12', 'Attack+20'}},
    hands_plain = 'Adhemar Wrist. +1',
}

-- • Nyame (Magic WS / Damage Taken)
Armor.Nyame = {
    head  = 'Nyame Helm',
    body  = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs  = 'Nyame Flanchard',
    feet  = 'Nyame Sollerets',
}

-- • Malignance (DT Engaged / Step)
Armor.Malignance = {
    head  = 'Malignance Chapeau',
    body  = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs  = 'Malignance Tights',
    feet  = 'Malignance Boots',
}

-- • Gleti's (Multi-attack idle/engaged)
Armor.Gleti = {
    head  = "Gleti's Mask",
    body  = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs  = "Gleti's Breeches",
    feet  = "Gleti's Boots",
}

-- • Meghanada +2 (Regen idle / Exenterator)
Armor.Meghanada = {
    head  = 'Meghanada Visor +2',
    body  = 'Meg. Cuirie +2',
    hands = 'Meg. Gloves +2',
    legs  = 'Meg. Chausses +2',
    feet  = 'Meg. Jam. +2',
}

-- • Mummu (Crit / Waltz)
Armor.Mummu = {
    head = 'Mummu Bonnet +2',
}

-- • Misc reusable pieces
Armor.Misc = {
    LeylineGloves      = 'Leyline Gloves',
    HerculeanHelmTH    = {name = 'Herculean Helm', augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}},
    LustraLeggings     = {name = 'Lustra. Leggings +1', augments = {'HP+65', 'STR+15', 'DEX+15'}},
    LustrSubligar      = 'Lustr. Subligar +1',
    DreadJupon         = 'Dread Jupon',
    EnifCosciales      = 'Enif Cosciales',
    TurmsHarness       = 'Turms Harness',
    SlitherGloves      = 'Slither Gloves +1',
    DashingSubligar    = 'Dashing Subligar',
    SamnuhaTights      = 'Samnuha Tights',
    CouncilorsGarb     = "Councilor's Garb",
    ThiefsKote         = "Thief's Kote",
    AssassinsCulottes  = "Assassin's Culottes",
}

return Armor

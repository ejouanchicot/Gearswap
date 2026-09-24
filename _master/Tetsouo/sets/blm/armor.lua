---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Armor - AF / Relic / Empyrean / Mythic and Other Job Armor
---  ═══════════════════════════════════════════════════════════════════════════
---   All BLM-specific armor pieces grouped by set:
---     • Wicce      = Empyrean +3 (elemental magic / enfeebles)
---     • Spaekona   = Artifact +4 (MP conservation / DoT body)
---     • Archmage   = Relic +1/+3 (Manafont body, Aspir feet, debuff legs)
---     • Nyame      = WS armor (staff WS)
---     • Merlinic   = Augmented (Fast Cast set + Drain/Aspir set)
---     • Telchine   = Enhancing Magic duration +10 set
---     • Agwu       = Magic Burst pieces
---     • Ea         = Magic Burst head
---     • Amalric    = Aquaveil head
---
---   Usage:
---     local Armor = require('Tetsouo/sets/blm/armor')
---     sets.idle = { head = Armor.Wicce.head, ... }
---
---   @file    Tetsouo/sets/blm/armor.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local Armor = {}

-- • Empyrean +3 (Wicce) — Elemental Magic / Enfeebles
Armor.Wicce = {
    head  = 'Wicce Petasos +3',
    body  = 'Wicce Coat +3',
    hands = 'Wicce Gloves +3',
    legs  = 'Wicce Chausses +3',
    feet  = 'Wicce Sabots +3',
}

-- • Artifact +4 (Spaekona) — MP Conservation / DoT
Armor.Spaekona = {
    body = "Spaekona's Coat +4",
}

-- • Relic +1/+3 (Archmage) — Manafont / Aspir / Debuff potency
Armor.Archmage = {
    body   = "Archmage's Coat +1",
    legs   = {
        name = 'Arch. Tonban +3',
        augments = {'Increases Elemental Magic debuff time and potency'}
    },
    feet   = {
        name = 'Arch. Sabots +3',
        augments = {'Increases Aspir absorption amount'}
    },
}

-- • Nyame (WS armor)
Armor.Nyame = {
    head  = 'Nyame Helm',
    body  = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs  = 'Nyame Flanchard',
    feet  = 'Nyame Sollerets',
}

-- • Agwu — Magic Burst / Dark Magic
Armor.Agwu = {
    hands = "Agwu's Gages",
    feet  = "Agwu's Pigaches",
}

-- • Ea — Magic Burst head
Armor.Ea = {
    head = 'Ea Hat +1',
}

-- • Amalric — Aquaveil head
Armor.Amalric = {
    head = 'Amalric Coif +1',
}

-- • Merlinic Fast Cast Set (80% FC Augments)
Armor.MerlinicFC = {
    head  = {
        name = 'Merlinic Hood',
        augments = {'Attack+14', '"Fast Cast"+7', 'MND+3'}
    },
    body  = {
        name = 'Merlinic Jubbah',
        augments = {'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3'}
    },
    hands = {
        name = 'Merlinic Dastanas',
        augments = {'"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4'}
    },
    legs  = {
        name = 'Merlinic Shalwar',
        augments = {'"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11'}
    },
    feet  = {
        name = 'Merlinic Crackows',
        augments = {'"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10'}
    },
}

-- • Merlinic Drain/Aspir Set (Potency Augments)
Armor.MerlinicDrain = {
    head  = {
        name = 'Merlinic Hood',
        augments = {'Mag. Acc.+6', '"Drain" and "Aspir" potency +10', 'INT+6', '"Mag.Atk.Bns."+2'}
    },
    body  = {
        name = 'Merlinic Jubbah',
        augments = {'"Mag.Atk.Bns."+30', '"Drain" and "Aspir" potency +11', 'INT+3', 'Mag. Acc.+4'}
    },
    hands = {
        name = 'Merlinic Dastanas',
        augments = {'"Drain" and "Aspir" potency +10', '"Mag.Atk.Bns."+14'}
    },
}

-- • Telchine Enhancing Duration Set (+10 Duration)
Armor.Telchine = {
    head  = {name = 'Telchine Cap',      augments = {'Enh. Mag. eff. dur. +10'}},
    body  = {name = 'Telchine Chas.',    augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves',   augments = {'Enh. Mag. eff. dur. +10'}},
    legs  = {name = 'Telchine Braconi',  augments = {'Enh. Mag. eff. dur. +10'}},
    feet  = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
}

-- • Misc reusable pieces
Armor.Misc = {
    VolteGloves    = 'Volte Gloves',
    TwilightCloak  = 'Twilight Cloak',
    UmuthiHat      = 'Umuthi Hat',
    DoyenPants     = 'Doyen Pants',
    ShedirSerawels = 'Shedir Seraweels',
    HeraldGaiters  = "Herald's Gaiters",
    CouncilorGarb  = "Councilor's Garb",
}

return Armor

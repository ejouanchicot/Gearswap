---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Equipment Sets - Dark Knight DPS Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Complete equipment configuration for Dark Knight DPS role with optimized
---   offensive gear and Aftermath Lv.3 support.
---   Features:
---     • Aftermath Lv.3 detection (Liberator mythic weapon)
---     • Store TP optimization for fast TP gain
---     • Weaponskill optimization (Torcleaver, Entropy, Resolution, Cross Reaper)
---     • Dark Magic effectiveness (Drain, Aspir, Absorb spells)
---     • Last Resort enhancement
---     • Physical and Magical damage mitigation (PDT/MDT modes)
---    Architecture:
---     • Equipment definitions (Ankou's Capes, rings, weapons)
---     • Weapon sets (Liberator, Caladbolg, Apocalypse, Naegling, etc.)
---     • Idle sets (Normal, PDT, Town)
---     • Engaged sets (Base DPS, PDT, Aftermath Lv.3)
---     • Precast sets (Job abilities, Fast Cast, Weaponskills)
---     • Midcast sets (Dark Magic, Absorb spells, Dread Spikes, Drain/Aspir)
---     • Movement sets (Base speed, Adoulin)
---   @file    sets/drk_sets.lua
---   @author  Tetsouo
---   @version 3.0 - Simplified Engaged Structure + AM3 Support
---   @date    Updated: 2025-11-10
---  ═════════════════════════════════════════════════════════════════════════

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Ankou's Capes (Multiple variants)
Ankou = {
    -- STP/DA Cape (DEX+20, Acc+20 Atk+20, Acc+10, DA+10%, DT-5%)
    STP = {
        name = "Ankou's Mantle",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%'}
    },
    -- WS VIT Cape (VIT+20, Acc+20 Atk+20, VIT+10, WSD+10%)
    WS_VIT = {
        name = "Ankou's Mantle",
        augments = {'VIT+20', 'Accuracy+20 Attack+20', 'VIT+10', 'Weapon skill damage +10%'}
    },
    -- WS STR Cape (STR+20, Acc+20 Atk+20, STR+10, WSD+10%)
    WS_STR = {
        name = "Ankou's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%'}
    },
    -- WS MND Cape (MND+20, Acc+20 Atk+20, MND+10, WSD+10%, DT-5%)
    WS_MND = {
        name = "Ankou's Mantle",
        augments = {'MND+20', 'Accuracy+20 Attack+20', 'MND+10', 'Weapon skill damage +10%', 'Damage taken-5%'}
    },
    -- Magic Cape (INT+20, Mag.Acc+20/Mag.Dmg+20, Mag.Acc+10, FC+10%, SIRD-10%)
    MAGIC = {
        name = "Ankou's Mantle",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'Mag. Acc.+10',
            '"Fast Cast"+10',
            'Spell interruption rate down-10%'
        }
    },
    -- Drain/Aspir Cape
    DRAIN = {
        name = 'Niht Mantle',
        augments = {'Attack+6', 'Dark magic skill +2', '"Drain" and "Aspir" potency +25', 'Weapon skill damage +3%'}
    }
}

-- • Rings (Wardrobe-specific)
ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe 7'}
ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 8'}
Moonlight1 = {name = 'Moonlight Ring', bag = 'wardrobe 2'}
Moonlight2 = {name = 'Moonlight Ring', bag = 'wardrobe 4'}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Scythe weapons (Two-handed with Utu Grip)
sets['Caladbolg'] = {main = 'Caladbolg', sub = 'Utu Grip'}
sets['Liberator'] = {main = 'Liberator', sub = 'Utu Grip'}
sets['Apocalypse'] = {main = 'Apocalypse', sub = 'Utu Grip'}
sets['Redemption'] = {main = 'Redemption', sub = 'Utu Grip'}

-- • Great Axe weapons (Two-handed with Utu Grip)
sets['Foenaria'] = {main = 'Foenaria', sub = 'Utu Grip'}
sets['Tokko'] = {main = 'Tokko chopper', sub = 'Utu Grip'}
sets['Lycurgos'] = {main = 'Lycurgos', sub = 'Utu Grip'}

-- • Sword/Club weapons (One-handed with Blurred Shield +1)
sets['Naegling'] = {main = 'Naegling', sub = 'Blurred Shield +1'}
sets['Loxotic'] = {main = 'Loxotic Mace +1', sub = 'Blurred Shield +1'}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle Set (Refresh/Regen focus)
--   NOTE: main/sub will be applied by customize_idle_set based on state.MainWeapon
sets.idle = {
    ammo = {name = 'Seeth. Bomblet +1', augments = {'Path: A'}},
    head = "Sakpata's Helm",
    body = 'Heath. Cuirass +3',
    hands = 'Nyame Gauntlets',
    legs = {name = 'Carmine Cuisses +1', augments = {'Accuracy+20', 'Attack+12', '"Dual Wield"+6'}},
    feet = 'Nyame Sollerets',
    neck = 'Coatl Gorget +1',
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
    right_ear = 'Eabani Earring',
    left_ring = 'Stikini Ring +1',
    right_ring = 'Defending Ring',
    back = Ankou.STP
}

-- • PDT Idle (Physical Defense) - Full Heathen's Armor +3
sets.idle.PDT =
    set_combine(
    sets.idle,
    {
        ammo = {name = 'Seeth. Bomblet +1', augments = {'Path: A'}},
        head = 'Heath. Bur. +3',
        body = 'Heath. Cuirass +3',
        hands = 'Heath. Gauntlets +3',
        legs = 'Heath. Flanchard +3',
        feet = 'Heath. Sollerets +3',
        neck = 'Coatl Gorget +1',
        waist = 'Plat. Mog. Belt',
        left_ear = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
        right_ear = 'Eabani Earring',
        left_ring = 'Stikini Ring +1',
        right_ring = 'Defending Ring',
        back = Ankou.STP
    }
)

-- • Normal Idle
sets.idle.Normal = sets.idle

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base engaged (DPS mode)
sets.engaged = {
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = 'Flam. Zucchetto +2',
    body = {name = "Sakpata's Plate", augments = {'Path: A'}},
    hands = {name = "Sakpata's Gauntlets", augments = {'Path: A'}},
    legs = 'Ig. Flanchard +3',
    feet = {name = "Sakpata's Leggings", augments = {'Path: A'}},
    neck = 'Null Loop',
    waist = 'Ioskeha Belt +1',
    left_ear = {name = 'Schere Earring', augments = {'Path: A'}},
    right_ear = {
        name = 'Heath. Earring +2',
        augments = {
            'System: 1 ID: 1676 Val: 0',
            'Accuracy+17',
            'Mag. Acc.+17',
            'Weapon skill damage +4%',
            'STR+9 INT+9'
        }
    },
    left_ring = Moonlight1,
    right_ring = Moonlight2,
    back = Ankou.STP
}

-- • PDT mode (Physical defense)
sets.engaged.PDT = set_combine(sets.engaged, {
    ammo = {name = 'Seeth. Bomblet +1', augments = {'Path: A'}},
    body = 'Heath. Cuirass +3',
    hands = {name = "Sakpata's Gauntlets", augments = {'Path: A'}},
    legs = 'Heath. Flanchard +3',
    feet = {name = "Sakpata's Leggings", augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ring = 'Niqmaddu Ring',
    right_ring = ChirichRing2
})

-- • Aftermath Lv.3 (Liberator mythic)
sets.engaged.AM3 = set_combine(sets.engaged, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • Jump (DRG subjob)
sets.precast.JA['Jump'] = set_combine(sets.engaged)
sets.precast.JA['High Jump'] = set_combine(sets.engaged)

-- • DRK Job Abilities
sets.precast.JA['Diabolic Eye'] = {hands = 'Fall. Fin. Gaunt. +3'}
sets.precast.JA['Arcane Circle'] = {feet = 'Ignominy Sollerets +2'}
sets.precast.JA['Nether Void'] = {legs = 'Heath. Flanchard +3'}
sets.precast.JA['Souleater'] = {head = 'Ignominy Burgeonet +2'}
sets.precast.JA['Last Resort'] = {
    feet = "Fallen's Sollerets +3",
    back = Ankou.STP
}
sets.precast.JA['Weapon Bash'] = {hands = 'Ig. Gauntlets +3'}
sets.precast.JA['Blood Weapon'] = {body = "Fallen's Cuirass +3"}
sets.precast.JA['Dark Seal'] = {head = "Fallen's Burgeonet +3"}

-- • Fast Cast
sets.precast.FC = {
    ammo = 'Sapience Orb',
    head = {name = 'Carmine Mask +1', augments = {'Accuracy+20', 'Mag. Acc.+12', '"Fast Cast"+4'}},
    body = {
        name = 'Odyss. Chestplate',
        augments = {'DEX+3', '"Fast Cast"+6', '"Store TP"+2', 'Accuracy+9 Attack+9', 'Mag. Acc.+2 "Mag.Atk.Bns."+2'}
    },
    hands = {name = 'Leyline Gloves', augments = {'Accuracy+1', 'Mag. Acc.+5', '"Mag.Atk.Bns."+5', '"Fast Cast"+1'}},
    legs = 'Enif Cosciales',
    feet = {
        name = 'Odyssean Greaves',
        augments = {'"Store TP"+5', 'Attack+7', '"Fast Cast"+6', 'Accuracy+19 Attack+19'}
    },
    neck = 'Voltsurge Torque',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Malignance Earring',
    right_ear = 'Loquac. Earring',
    left_ring = 'Kishar Ring',
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = Ankou.MAGIC
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • Dark Magic (Base)
sets.midcast['Dark Magic'] = {
    ammo = 'Pemphredo Tathlum',
    head = 'Heath. Bur. +3',
    body = 'Heath. Cuirass +3',
    hands = 'Heath. Gauntlets +3',
    legs = 'Heath. Flanchard +3',
    feet = 'Heath. Sollerets +3',
    neck = 'Erra Pendant',
    waist = 'Null Belt',
    left_ear = 'Malignance Earring',
    right_ear = 'Mani Earring',
    left_ring = 'Stikini Ring +1',
    right_ring = 'Evanescence Ring',
    back = Ankou.MAGIC
}

-- • Enfeebling Magic
sets.midcast['Enfeebling Magic'] =
    set_combine(
    sets.midcast['Dark Magic'],
    {
        neck = 'Null Loop',
        body = 'Ignominy Cuirass +3'
    }
)

-- • Dread Spikes (HP-based)
sets.midcast['Dread Spikes'] =
set_combine(
    sets.midcast['Dark Magic'],
    {
        ammo = 'Aqreqaq Bomblet',
        head = 'Hjarrandi Helm',
        body = 'Heath. Cuirass +3',
        hands = 'Nyame Gauntlets',
        legs = 'Ratri Cuisses',
        feet = 'Rat. Sollerets +1',
        neck = 'Null Loop',
        waist = 'Plat. Mog. Belt',
        left_ear = 'Odnowa Earring +1',
        right_ear = 'Mani Earring',
        left_ring = 'Moonlight Ring',
        right_ring = 'Gelatinous Ring +1',
        back = {
            name = "Ankou's Mantle",
            augments = {
                'INT+20',
                'Mag. Acc+20 /Mag. Dmg.+20',
                'Mag. Acc.+10',
                '"Fast Cast"+10',
                'Spell interruption rate down-10%'
            }
        }
    }
)

-- • Absorb Spells
sets.midcast.Absorb =
    set_combine(
    sets.midcast['Dark Magic'],
    {
        hands = 'Heath. Gauntlets +3',
        feet = 'Rat. Sollerets +1'
    }
)

-- • Individual Absorb spells
sets.midcast['Absorb-MND'] = sets.midcast.Absorb
sets.midcast['Absorb-CHR'] = sets.midcast.Absorb
sets.midcast['Absorb-VIT'] = sets.midcast.Absorb
sets.midcast['Absorb-AGI'] = sets.midcast.Absorb
sets.midcast['Absorb-INT'] = sets.midcast.Absorb
sets.midcast['Absorb-DEX'] = sets.midcast.Absorb
sets.midcast['Absorb-STR'] = sets.midcast.Absorb
sets.midcast['Absorb-TP'] = sets.midcast.Absorb
sets.midcast['Absorb-ACC'] = sets.midcast.Absorb
sets.midcast['Absorb-Attri'] = sets.midcast.Absorb

-- • Drain/Aspir (Potency focus)
sets.midcast.Drain =
    set_combine(
    sets.midcast['Dark Magic'],
    {
        head = {name = 'Fall. Burgeonet +3', augments = {'Enhances "Dark Seal" effect'}},
        hands = {name = 'Fall. Fin. Gaunt. +3', augments = {'Enhances "Diabolic Eye" effect'}},
        feet = 'Rat. Sollerets +1',
        left_ring = 'Evanescence Ring',
        back = Ankou.DRAIN
    }
)

sets.midcast['Drain III'] = sets.midcast.Drain
sets.midcast.Aspir = sets.midcast.Drain

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.WS = {}

-- • Default WS (VIT-based)
sets.precast.WS['default'] = {
    ammo = 'Knobkierrie',
    head = 'Heath. Bur. +3',
    body = 'Ignominy Cuirass +3',
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Fall. Flanchard +3', augments = {'Enhances "Muted Soul" effect'}},
    feet = 'Heath. Sollerets +3',
    neck = {name = 'Abyssal Beads +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    right_ear = {
        name = 'Heath. Earring +2',
        augments = {
            'System: 1 ID: 1676 Val: 0',
            'Accuracy+17',
            'Mag. Acc.+17',
            'Weapon skill damage +4%',
            'STR+9 INT+9'
        }
    },
    left_ear = 'Thrud Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Karieyh Ring',
    back = Ankou.WS_VIT
}

-- • Accuracy WS
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

-- • Entropy (STR 80% VIT 80%)
sets.precast.WS['Entropy'] =
    set_combine(
    sets.precast.WS,
    {
        back = Ankou.WS_STR
    }
)

-- • Origin (STR 85% VIT 85%)
sets.precast.WS['Origin'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Knobkierrie',
        head = 'Heath. Bur. +3',
        body = {name = 'Nyame Mail', augments = {'Path: B'}},
        hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
        legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
        feet = 'Heath. Sollerets +3',
        neck = {name = 'Abyssal Beads +2', augments = {'Path: A'}},
        waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
        left_ear = 'Thrud Earring',
        right_ear = {
            name = 'Heath. Earring +2',
            augments = {
                'System: 1 ID: 1676 Val: 0',
                'Accuracy+17',
                'Mag. Acc.+17',
                'Weapon skill damage +4%',
                'STR+9 INT+9'
            }
        },
        left_ring = {name = 'Beithir Ring', augments = {'Path: A'}},
        right_ring = "Cornelia's Ring",
        back = Ankou.WS_STR
    }
)

-- • Resolution (STR 85% - Multihit)
sets.precast.WS['Resolution'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Knobkierrie',
        head = 'Heath. Bur. +3',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = "Sakpata's Leggings",
        neck = {name = 'Abyssal Beads +2', augments = {'Path: A'}},
        waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
        right_ear = {
            name = 'Heath. Earring +2',
            augments = {
                'System: 1 ID: 1676 Val: 0',
                'Accuracy+17',
                'Mag. Acc.+17',
                'Weapon skill damage +4%',
                'STR+9 INT+9'
            }
        },
        left_ear = {name = 'Schere Earring', augments = {'Path: A'}},
        left_ring = "Cornelia's Ring",
        right_ring = 'Karieyh Ring',
        back = Ankou.WS_STR
    }
)

-- • Torcleaver (VIT 80%)
sets.precast.WS['Torcleaver'] = {
    ammo = 'Knobkierrie',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = 'Ignominy Cuirass +3',
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Fall. Flanchard +3', augments = {'Enhances "Muted Soul" effect'}},
    feet = 'Heath. Sollerets +3',
    neck = {name = 'Abyssal Beads +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Thrud Earring',
    right_ear = {
        name = 'Heath. Earring +2',
        augments = {
            'System: 1 ID: 1676 Val: 0',
            'Accuracy+17',
            'Mag. Acc.+17',
            'Weapon skill damage +4%',
            'STR+9 INT+9'
        }
    },
    left_ring = "Cornelia's Ring",
    right_ring = 'Karieyh Ring',
    back = Ankou.WS_VIT
}

-- • Quietus (STR 60% INT 60%)
sets.precast.WS['Quietus'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Knobkierrie',
        head = 'Heath. Bur. +3',
        body = {name = 'Nyame Mail', augments = {'Path: B'}},
        hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
        legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
        feet = 'Heath. Sollerets +3',
        neck = {name = 'Abyssal Beads +2', augments = {'Path: A'}},
        waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
        left_ear = 'Thrud Earring',
        right_ear = {
            name = 'Heath. Earring +2',
            augments = {
                'System: 1 ID: 1676 Val: 0',
                'Accuracy+17',
                'Mag. Acc.+17',
                'Weapon skill damage +4%',
                'STR+9 INT+9'
            }
        },
        left_ring = {name = 'Beithir Ring', augments = {'Path: A'}},
        right_ring = "Cornelia's Ring",
        back = Ankou.WS_STR
    }
)

-- • Judgment (MND 75% STR 75%)
sets.precast.WS['Judgment'] =
    set_combine(
    sets.precast.WS,
    {
        back = Ankou.WS_MND
    }
)

-- • Savage Blade (STR 50% MND 50%)
sets.precast.WS['Savage Blade'] = {
    ammo = 'Crepuscular Pebble',
    head = 'Heath. Bur. +3',
    body = {name = "Sakpata's Plate", augments = {'Path: A'}},
    hands = {name = "Sakpata's Gauntlets", augments = {'Path: A'}},
    legs = {name = "Sakpata's Cuisses", augments = {'Path: A'}},
    feet = 'Heath. Sollerets +3',
    neck = {name = 'Abyssal Beads +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = {name = 'Moonshade Earring', augments = {'Attack+4', 'TP Bonus +250'}},
    right_ear = {
        name = 'Heath. Earring +2',
        augments = {
            'System: 1 ID: 1676 Val: 0',
            'Accuracy+17',
            'Mag. Acc.+17',
            'Weapon skill damage +4%',
            'STR+9 INT+9'
        }
    },
    left_ring = "Cornelia's Ring",
    right_ring = 'Defending Ring',
    back = Ankou.WS_STR
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    legs = 'Carmine Cuisses +1'
}

-- • Town Idle (Movement speed)
sets.idle.Town = sets.MoveSpeed

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

-- • Doom Resistance
sets.buff.Doom = {
    right_ring = 'Purity Ring'
}

-- • Dark Seal (Buff ID 345)
--   Equip during Dark Magic midcast when Dark Seal buff is active
--   Effect: Dark Magic duration +10% per merit level
--   Affects: Dread Spikes, Absorb spells, Drain III
sets.buff['Dark Seal'] = {
    head = "Fallen's Burgeonet +3"
}

-- • Nether Void (Buff ID 439)
--   Equip during Absorb/Drain midcast when Nether Void buff is active
--   Effect: Nether Void bonus +45% (total 95% absorption potency)
--   Affects: Absorb spells, Drain spells (not Absorb-TP)
sets.buff['Nether Void'] = {
    legs = "Heathen's Flanchards +3"
}

print('[DRK] Equipment sets loaded successfully (Typioni STP Build)')

---============================================================================
--- SAM Equipment Sets - Complete Gear Configuration
---============================================================================
--- @file sam_sets.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-21
---============================================================================

---============================================================================
--- WEAPON SETS (State-based)
---============================================================================

sets['Masamune'] = {main = 'Masamune', sub = 'Utu Grip'}
sets['Kusanagi'] = {main = 'Kusanagi-no-Tsurugi'}
sets['Shining'] = {main = 'Shining One'}
sets['Dojikiri'] = {main = 'Dojikiri Yasutsuna'}
sets['Malevolence'] = {main = 'Malevolence'}
sets['Soboro'] = {main = 'Soboro Sukehiro'}
sets['Norifusa'] = {main = 'Norifusa +1'}
sets['Onion'] = {main = 'Onion Sword III'}
sets['Utu'] = {sub = 'Utu Grip'}

---============================================================================
--- JSE CAPE (Smertrios's Mantle)
---============================================================================

Smertrios = {}
Smertrios.ACC = {
    name = "Smertrios's Mantle",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Dbl.Atk."+10', 'Damage taken-5%'}
}
Smertrios.WS = {
    name = "Smertrios's Mantle",
    augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Damage taken-5%'}
}
Smertrios.WSMG = {
    name = "Smertrios's Mantle",
    augments = {'STR+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Magic Damage +9', 'Weapon skill damage +10%', 'Damage taken-5%'}
}
Smertrios.TP = {
    name = "Smertrios's Mantle",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
}
Smertrios.FC = {name = "Smertrios's Mantle", augments = {'"Fast Cast"+10'}}

---============================================================================
--- IDLE SETS
---============================================================================

sets.idle = {}

sets.idle.Normal = {
    sub = 'Utu Grip',
    ammo = 'Fly Lure',
    head = 'Wakido Kabuto +4',
    body = 'Chozor. Coselete',
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = 'Kasuga Haidate +3',
    feet = {name = 'Nyame Sollerets', augments = {'Path: B'}},
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Plat. Mog. Belt',
    left_ear = 'Etiolation Earring',
    right_ear = 'Odnowa Earring',
    left_ring = 'Stikini Ring +1',
    right_ring = 'Chirich Ring +1',
    back = Smertrios.ACC
}

sets.idle.Regen = set_combine(sets.idle.Normal, {
    ammo = 'Crepuscular Pebble',
    head = 'Kasuga Kabuto +3',
    body = 'Hiza. Haramaki +2',
    hands = {name = 'Sakonji Kote +3', augments = {'Enhances "Blade Bash" effect'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Danzo Sune-Ate',
    neck = 'Sanctity Necklace',
    waist = 'Plat. Mog. Belt',
    right_ear = 'Telos Earring',
    back = Smertrios.ACC
})

sets.idle.Weak = set_combine(sets.idle.Normal, {
    head = 'Twilight Helm',
    body = 'Twilight Mail'
})

sets.idle.PDT = set_combine(sets.idle.Normal, {
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = {name = 'Nyame Sollerets', augments = {'Path: B'}},
    neck = 'Loricate Torque +1',
    left_ring = 'Defending Ring'
})

---============================================================================
--- DEFENSE SETS
---============================================================================

sets.defense = {}

sets.defense.PDT = {
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Nyame Sollerets',
    neck = 'Loricate Torque +1',
    left_ring = 'Defending Ring'
}

sets.defense.MDT = set_combine(sets.defense.PDT, {
    sub = 'Utu Grip',
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = 'Kasuga Kabuto +3',
    body = 'Kasuga Domaru +3',
    hands = {name = 'Tatena. Gote +1', augments = {'Path: A'}},
    legs = 'Kasuga Haidate +3',
    feet = {name = 'Tatena. Sune. +1', augments = {'Path: A'}},
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = 'Ioskeha Belt +1',
    left_ear = 'Telos Earring',
    right_ear = 'Kasuga Earring +1',
    left_ring = 'Chirich Ring +1',
    right_ring = 'Niqmaddu Ring',
    back = Smertrios.ACC
})

---============================================================================
--- ENGAGED SETS
---============================================================================

sets.engaged = {}

sets.engaged.Normal = {
    sub = 'Utu Grip',
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = 'Kasuga Kabuto +3',
    body = 'Kasuga Domaru +3',
    hands = {name = 'Tatena. Gote +1', augments = {'Path: A'}},
    legs = 'Kasuga Haidate +3',
    feet = {name = 'Tatena. Sune. +1', augments = {'Path: A'}},
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = 'Ioskeha Belt +1',
    left_ear = 'Schere Earring',
    right_ear = 'Kasuga Earring +1',
    left_ring = 'Chirich Ring +1',
    right_ring = 'Niqmaddu Ring',
    back = Smertrios.ACC
}

sets.engaged.Mid = set_combine(sets.engaged.Normal, {
    head = 'Kasuga Kabuto +3',
    body = 'Kasuga Domaru +3'
})

sets.engaged.Acc = set_combine(sets.engaged.Mid, {
    hands = {name = 'Tatena. Gote +1', augments = {'Path: A'}},
    legs = 'Kasuga Haidate +3',
    left_ear = 'Telos Earring'
})

sets.engaged.PDT = set_combine(sets.engaged.Normal, {
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = {name = 'Nyame Sollerets', augments = {'Path: B'}},
    neck = 'Loricate Torque +1',
    left_ring = 'Defending Ring'
})

sets.engaged.Acc.PDT = set_combine(sets.engaged.Acc, {
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Nyame Sollerets',
    neck = 'Loricate Torque +1',
    left_ring = 'Defending Ring'
})

sets.engaged.MDT = {
    sub = 'Utu Grip',
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = 'Kasuga Kabuto +3',
    body = 'Kasuga Domaru +3',
    hands = {name = 'Tatena. Gote +1', augments = {'Path: A'}},
    legs = 'Kasuga Haidate +3',
    feet = {name = 'Tatena. Sune. +1', augments = {'Path: A'}},
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = 'Ioskeha Belt +1',
    left_ear = 'Schere Earring',
    right_ear = 'Kasuga Earring +1',
    left_ring = 'Chirich Ring +1',
    right_ring = 'Niqmaddu Ring',
    back = Smertrios.ACC
}

sets.engaged.SuBlow = {
    sub = 'Utu Grip',
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = 'Kasuga Kabuto +3',
    body = 'Flamma Korazin +2',
    hands = {name = 'Tatena. Gote +1', augments = {'Path: A'}},
    legs = "Mpaca's Hose",
    feet = {name = 'Tatena. Sune. +1', augments = {'Path: A'}},
    neck = 'Bathy Choker +1',
    waist = 'Ioskeha Belt +1',
    left_ear = 'Schere Earring',
    right_ear = 'Kasuga Earring +1',
    left_ring = 'Chirich Ring +1',
    right_ring = 'Chirich Ring +1',
    back = Smertrios.ACC
}

---============================================================================
--- PRECAST - JOB ABILITIES
---============================================================================

sets.precast = {}
sets.precast.JA = {}

sets.precast.JA['Meditate'] = {
    head = 'Wakido Kabuto +4',
    hands = 'Sakonji Kote +3'
}

sets.precast.JA['Hasso'] = {
    hands = 'Wakido Kote +3',
    feet = 'Wakido Sune. +2'
}

sets.precast.JA['Seigan'] = {
    head = 'Unkai Kabuto +3'
}

sets.precast.JA['Warding Circle'] = {
    head = 'Wakido Kabuto +4'
}

sets.precast.JA['Third Eye'] = {
    legs = 'Saotome Haidate'
}

sets.precast.JA['Blade Bash'] = {
    hands = 'Sakonji Kote +3'
}

---============================================================================
--- PRECAST - FAST CAST
---============================================================================

sets.precast.FC = {
    ammo = 'Impatiens',
    head = 'Kasuga Kabuto +3',
    body = 'Kasuga Domaru +3',
    hands = {name = 'Leyline Gloves', augments = {'Accuracy+14', 'Mag. Acc.+13', '"Mag.Atk.Bns."+13', '"Fast Cast"+2'}},
    legs = 'Kasuga Haidate +3',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = 'Ioskeha Belt +1',
    left_ear = 'Loquac. Earring',
    right_ear = 'Telos Earring',
    left_ring = "Naji's Loop",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.FC
}

sets.precast.FC.Utsusemi = {
    ammo = 'Impatiens',
    head = 'Kasuga Kabuto +3',
    body = 'Kasuga Domaru +3',
    hands = {name = 'Leyline Gloves', augments = {'Accuracy+14', 'Mag. Acc.+13', '"Mag.Atk.Bns."+13', '"Fast Cast"+2'}},
    legs = 'Kasuga Haidate +3',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = 'Ioskeha Belt +1',
    left_ear = 'Loquac. Earring',
    right_ear = 'Telos Earring',
    left_ring = "Naji's Loop",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.FC
}

---============================================================================
--- PRECAST - WEAPONSKILLS
---============================================================================

sets.precast.WS = {}

-- Default WS set
sets.precast.WS = {
    sub = 'Utu Grip',
    ammo = 'Knobkierrie',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Sakonji Domaru +4', augments = {'Enhances "Overwhelm" effect'}},
    hands = 'Kasuga Kote +3',
    legs = 'Wakido Haidate +4',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = {name = 'Kentarch Belt +1', augments = {'Path: A'}},
    left_ear = 'Thrud Earring',
    right_ear = {
        name = 'Kasuga Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+11', 'Mag. Acc.+11', 'Weapon skill damage +2%'}
    },
    left_ring = "Ephramad's Ring",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.WS
}

-- Tachi: Fudo (main WS)
sets.precast.WS['Tachi: Fudo'] = {
    sub = 'Utu Grip',
    ammo = 'Knobkierrie',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Sakonji Domaru +4', augments = {'Enhances "Overwhelm" effect'}},
    hands = 'Kasuga Kote +3',
    legs = 'Wakido Haidate +4',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Thrud Earring',
    right_ear = {
        name = 'Kasuga Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+11', 'Mag. Acc.+11', 'Weapon skill damage +2%'}
    },
    left_ring = "Ephramad's Ring",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.WS
}

-- Tachi: Shoha (light skillchain)
sets.precast.WS['Tachi: Shoha'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Tachi: Shoha'].Mid = set_combine(sets.precast.WS, {})
sets.precast.WS['Tachi: Shoha'].Acc = set_combine(sets.precast.WS['Tachi: Shoha'].Mid, {})

-- Tachi: Mumei (magic-based)
sets.precast.WS['Tachi: Mumei'] = {
    sub = 'Utu Grip',
    ammo = 'Knobkierrie',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Sakonji Domaru +4', augments = {'Enhances "Overwhelm" effect'}},
    hands = 'Kasuga Kote +3',
    legs = 'Wakido Haidate +4',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Thrud Earring',
    right_ear = {
        name = 'Kasuga Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+11', 'Mag. Acc.+11', 'Weapon skill damage +2%'}
    },
    left_ring = "Ephramad's Ring",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.WS
}

-- Aeolian Edge (magical WS)
sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {
    ammo = 'Knobkierrie',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Nyame Sollerets',
    neck = 'Fotia Gorget',
    waist = 'Eschan Stone',
    left_ear = 'Friomisi Earring',
    right_ear = {
        name = 'Kasuga Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+11', 'Mag. Acc.+11', 'Weapon skill damage +2%'}
    },
    left_ring = "Ephramad's Ring",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.WSMG
})

-- Tachi: Jinpu (magic-based)
sets.precast.WS['Tachi: Jinpu'] = {
    ammo = 'Knobkierrie',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Nyame Sollerets',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = "Orpheus's Sash",
    left_ear = 'Schere Earring',
    right_ear = 'Kasuga Earring +1',
    left_ring = "Ephramad's Ring",
    right_ring = 'Niqmaddu Ring',
    back = Smertrios.WSMG
}

-- Tachi: Goten (magic-based)
sets.precast.WS['Tachi: Goten'] = set_combine(sets.precast.WS['Tachi: Jinpu'], {})

-- Tachi: Kagero (magic-based)
sets.precast.WS['Tachi: Kagero'] = set_combine(sets.precast.WS['Tachi: Jinpu'], {})

-- Tachi: Koki (darkness skillchain)
sets.precast.WS['Tachi: Koki'] = set_combine(sets.precast.WS['Tachi: Jinpu'], {})

-- Tachi: Rana
sets.precast.WS['Tachi: Rana'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Tachi: Rana'].Mid = set_combine(sets.precast.WS['Tachi: Rana'], {})
sets.precast.WS['Tachi: Rana'].Acc = set_combine(sets.precast.WS, {})

-- Impulse Drive
sets.precast.WS['Impulse Drive'] = {
    sub = 'Utu Grip',
    ammo = 'Knobkierrie',
    head = {name = 'Blistering Sallet +1', augments = {'Path: A'}},
    body = {name = 'Sakonji Domaru +4', augments = {'Enhances "Overwhelm" effect'}},
    hands = 'Kasuga Kote +3',
    legs = 'Wakido Haidate +4',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Thrud Earring',
    right_ear = {
        name = 'Kasuga Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+11', 'Mag. Acc.+11', 'Weapon skill damage +2%'}
    },
    left_ring = "Ephramad's Ring",
    right_ring = 'Niqmaddu Ring',
    back = Smertrios.WS
}

-- Tachi: Ageha
sets.precast.WS['Tachi: Ageha'] = set_combine(sets.precast.WS, {
    ammo = 'Knobkierrie',
    head = 'Kasuga Kabuto +3',
    body = {name = 'Sakonji Domaru +4', augments = {'Enhances "Overwhelm" effect'}},
    hands = 'Kasuga Kote +3',
    legs = 'Wakido Haidate +4',
    feet = 'Kas. Sune-Ate +3',
    neck = {name = 'Sam. Nodowa +2', augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Crep. Earring',
    right_ear = 'Kasuga Earring +1',
    left_ring = "Ephramad's Ring",
    right_ring = "Epaminondas's Ring",
    back = Smertrios.WS
})

---============================================================================
--- MIDCAST
---============================================================================

sets.midcast = {}

sets.midcast['Phalanx'] = {
    head = 'Valorous Mask',
    body = 'Valorous Mail',
    legs = 'Valorous Hose',
    neck = 'Loricate Torque +1',
    left_ring = 'Defending Ring'
}

---============================================================================
--- BUFF SETS
---============================================================================

sets.buff = {}

sets.buff.Sekkanoki = {hands = 'Kasuga Kote +3'}
sets.buff.Sengikori = {feet = 'Kas. Sune-Ate +3'}
sets.buff['Meikyo Shisui'] = {feet = 'Sakonji Sune-Ate +1'}

sets.thirdeye = {
    head = 'Unkai Kabuto +2',
    legs = 'Sakonji Haidate'
}

---============================================================================
--- MOVEMENT
---============================================================================

sets.MoveSpeed = {
    body = 'Adamantite Armor',
    right_ring = 'Shneddick Ring'
}

---============================================================================
--- DOOM RESISTANCE (added to existing buff sets)
---============================================================================

-- Doom resistance gear (Nicander's Necklace removes Doom)
sets.buff.Doom = {
    neck = "Nicander's Necklace",  -- Removes Doom (10/10 procs)
    ring1 = "Purity Ring",         -- Doom resistance
    ring2 = "Blenmot's Ring +1",   -- Doom resistance
    waist = "Gishdubar Sash"       -- Doom resistance
}

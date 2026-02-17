---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Equipment Sets - Complete Dancer Gear Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Comprehensive equipment configurations for Dancer job covering all combat
---   scenarios, weaponskills, job abilities, and defensive situations.
---   Features:
---     • Weapon sets (Mpu Gandring/Centovente, Demersal/Blurred)
---     • Idle sets (Normal, PDT, Town with movement speed)
---     • Engaged sets (Normal, PDT with 50% DT, FanDance with 30% DT, SaberDance variants)
---     • Step sets (Feather/Quick/Box with accuracy/macc optimization)
---     • Flourish sets (Violent, Animated, Desperate, Reverse)
---     • Waltz sets (healing potency optimization)
---     • Samba/Jig sets (duration and potency)
---     • Weaponskills with buff variants (Ruthless, Rudra's, Shark Bite)
---     • WS variant system (FanDance.Clim > FanDance > Clim > Base)
---     • Fast Cast sets (spell casting optimization)
---     • Jump sets (DRG subjob integration)
---     • Movement speed sets (Adoulin city-specific)
---     • Buff-specific sets (Saber Dance, Climactic Flourish)
---     • Treasure Hunter utility sets
---    Architecture:
---     • Cape augments (TP: DA+10/PDT-10%, WS: WSD+10%)
---     • Dual Chirich Rings (wardrobe 1/2 for haste/store TP)
---     • Dual Moonlight Rings (wardrobe 2/4 for HP/status resist)
---     • Fan Dance integration (20% buff + 30% gear = 50% DT cap)
---     • TP bonus automation (Moonshade handled by TPBonusCalculator)
---     • Set priority variants (4 tiers per major WS)
---    Dependencies:
---     • Mote-Include (set_combine for set inheritance)
---     • TPBonusCalculator (dynamic Moonshade at 1750-1999 TP)
---     • ws_variant_selector (buff-based WS set selection logic)
---     • set_builder (dynamic idle/engaged set construction)
---   @file    jobs/dnc/sets/dnc_sets.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Updated: 2025-11-10
---  ═════════════════════════════════════════════════════════════════════════
sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Chirich Rings (wardrobe management)
ChirichRing1 = {
    name = 'Chirich Ring +1',
    priority = 0,
    bag = 'wardrobe 1'
}
ChirichRing2 = {
    name = 'Chirich Ring +1',
    priority = 0,
    bag = 'wardrobe 2'
}

-- • Moonlight Rings (wardrobe management)
Moonlight1 = {
    name = 'Moonlight Ring',
    priority = 13,
    bag = 'wardrobe 2'
}
Moonlight2 = {
    name = 'Moonlight Ring',
    priority = 12,
    bag = 'wardrobe 4'
}

-- • Senuna's Mantle (TP and WS augments)
Senuna = {}
Senuna.TP = {
    name = "Senuna's Mantle",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%'}
}
Senuna.WS = {
    name = "Senuna's Mantle",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%'}
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Mpu Gandring >> Centovente
sets['Mpu Gandring'] = {
    main = 'Mpu Gandring',
    sub = 'Centovente'
}

-- • Mpu Gandring >> Centovente
sets['Twashtar'] = {
    main = 'Twashtar',
    sub = "Gleti's Knife"
}

-- • Demersal Degen +1 >> Blurred Knife +1
sets['Demersal'] = {
    main = 'Demersal Degen +1',
    sub = 'Blurred Knife +1'
}

-- • Sub Weapon Override: Blurred Knife +1 (forces sub regardless of main weapon)
sets['Blurred'] = {
    sub = 'Blurred Knife +1'
}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle
sets.idle = {
    ammo = 'Coiste Bodhar',
    head = "Gleti's Mask",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = "Gleti's Boots",
    neck = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Macu. Earring +1',
    ring1 = ChirichRing1, -- wardrobe 1
    ring2 = ChirichRing2, -- wardrobe 2
    back = Senuna.TP
}

-- • PDT Idle (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle, {
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Loricate Torque +1',
    waist = 'Flume Belt +1',
    ring2 = 'Defending Ring'
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Engaged
sets.engaged = {}

-- • Standard Normal Engaged
sets.engaged.Normal = {
    ammo = 'Coiste Bodhar',
    head = 'Maculele Tiara +3',
    body = 'Malignance Tabard',
    hands = 'Adhemar Wrist. +1',
    legs = 'Meg. Chausses +2',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Windbuffet Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Telos Earring',
    ring1 = 'Gere Ring',
    ring2 = Moonlight1, -- wardrobe 2
    back = Senuna.TP
}

-- • No Fan Dance: 50 equipment DT = 50 PDT (Base PDT set)
sets.engaged.PDT = {
    ammo = "Coiste Bodhar",
    head = "Blistering Sallet +1",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = "Gleti's Boots",
    neck = "Etoile Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Macu. Earring +1",
    ring1 = "Chirich Ring +1",
    ring2 = "Defending Ring",
    back = Senuna.TP
}

-- • Fan Dance: Minimum 20 DT + 30 equipment PDT = 50 PDT (With Fan Dance buff active)
sets.engaged.FanDance = {
    ammo = "Coiste Bodhar",
    head = "Blistering Sallet +1",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Macu. Toe Sh. +3",
    neck = "Etoile Gorget +2",
    waist = "Windbuffet Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Macu. Earring +1",
    ring1 = "Moonlight Ring",
    ring2 = "Moonlight Ring",
    back = Senuna.TP
}

-- • Saber Dance: Dual Wield -50%, optimize for Haste/STP/Multi-Attack instead of DW
sets.engaged.SaberDance = {
    ammo = 'Coiste Bodhar',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Samnuha Tights',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Windbuffet Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Dedition Earring',
    ring1 = 'Gere Ring',
    ring2 = 'Defending Ring',
    back = Senuna.TP
}

-- • Saber Dance + PDT: Hybrid defensive set with Saber Dance active
sets.engaged.SaberDance.PDT = {
    ammo = 'Coiste Bodhar',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Adhemar Wrist. +1',
    legs = 'Malignance Tights',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Windbuffet Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = Moonlight1, -- wardrobe 2
    ring2 = Moonlight2, -- wardrobe 4
    back = Senuna.TP
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • Steps (Base set)
sets.precast.Step = {
    ammo = 'Ginsen',
    head = 'Maxixi Tiara +4',
    body = 'Macu. Casaque +3',
    hands = 'maxixi bangles +4',
    legs = 'Maculele Tights +3',
    feet = 'Horos T. Shoes +3',
    neck = 'Sanctity Necklace',
    waist = 'Kentarch Belt +1',
    ear1 = 'Mache Earring +1',
    ear2 = 'Crep. Earring',
    ring1 = 'Asklepian Ring',
    ring2 = "Valseur's Ring",
    back = 'Toetapper Mantle'
}

sets.precast.Step['Feather Step'] = set_combine(sets.precast.Step, {
    feet = 'Macu. Toe Sh. +3'
})

sets.precast.Step['Quick Step'] = set_combine(sets.precast.Step, {
    feet = 'Macu. Toe Sh. +3'
})

sets.precast.Step['Box Step'] = set_combine(sets.precast.Step, {
    feet = 'Macu. Toe Sh. +3'
})

-- • Flourishes (Flourish1 & Flourish2)
sets.precast.Flourish1 = {}

sets.precast.Flourish1['Violent Flourish'] = {
    head = 'Maculele Tiara +3',
    body = 'Horos Casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Voltsurge Torque',
    waist = 'Skrymir Cord',
    ear1 = 'Enchntr. Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Mummu Ring',
    ring2 = 'Crepuscular Ring'
}

sets.precast.Flourish1['Animated Flourish'] = {
    ammo = 'Sapience Orb',
    body = 'Emet Harness +1',
    hands = 'Horos Bangles +3',
    neck = 'Unmoving Collar +1',
    waist = 'Trance Belt',
    ear1 = 'Friomisi Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back = 'Earthcry Mantle'
}

sets.precast.Flourish1['Desperate Flourish'] = {
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Sanctity Necklace',
    waist = 'Kentarch Belt +1',
    ear1 = 'Mache Earring +1',
    ear2 = 'Crep. Earring',
    ring1 = ChirichRing1, -- wardrobe 1
    ring2 = ChirichRing2, -- wardrobe 2
    back = 'Toetapper Mantle'
}

sets.precast.Flourish2 = {}

sets.precast.Flourish2['Reverse Flourish'] = {
    hands = 'Maculele Bangles +3',
    back = 'Toetapper Mantle'
}

-- • Waltzes (Healing potency optimization)
sets.precast.Waltz = {
    ammo = 'Staunch Tathlum +1',
    head = 'Anwig Salade',
    body = 'Maxixi Casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Dashing Subligar',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Loricate Torque +1',
    waist = 'Plat. Mog. Belt',
    ear1 = 'Cryptic Earring',
    ear2 = 'Enchntr. Earring +1',
    ring1 = 'Asklepian Ring',
    ring2 = 'Defending Ring',
    back = 'Toetapper Mantle'
}

sets.precast.Waltz['Healing Waltz'] = set_combine(sets.precast.Waltz, {})

-- • Sambas / Jigs (Duration and potency)
sets.precast.Samba = {
    head = 'Maxixi Tiara +4',
    back = Senuna.TP
}

sets.precast.Jig = {
    legs = 'Horos Tights +4',
    feet = 'Maxixi Toe Shoes +3'
}

-- • Other Job Abilities (No Foot Rise, Trance, Provoke, Fan Dance, Jumps)
sets.precast.JA['No Foot Rise'] = {
    body = 'Horos Casaque +3'
}

sets.precast.JA['Trance'] = {
    head = 'Horos Tiara +3'
}

sets.precast.JA['Provoke'] = {
    ammo = 'Sapience Orb',
    body = 'Emet Harness +1',
    hands = 'Horos Bangles +3',
    neck = 'Unmoving Collar +1',
    waist = 'Trance Belt',
    ear1 = 'Friomisi Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back = 'Earthcry Mantle'
}

sets.precast.JA['Fan Dance'] = {
    hands = 'Horos Bangles +3'
}

sets.precast.JA['Jump'] = {
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = {
        name = 'Etoile Gorget +2',
        augments = {'Path: A'}
    },
    waist = {
        name = 'Kentarch Belt +1',
        augments = {'Path: A'}
    },
    ear1 = 'Sherida Earring',
    ear2 = 'Dedition Earring',
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Senuna.TP
}

sets.precast.JA['High Jump'] = {
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = {
        name = 'Etoile Gorget +2',
        augments = {'Path: A'}
    },
    waist = {
        name = 'Kentarch Belt +1',
        augments = {'Path: A'}
    },
    ear1 = 'Sherida Earring',
    ear2 = 'Dedition Earring',
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Senuna.TP
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

-- • Fast Cast (spell casting optimization)
sets.precast.FC = {
    ammo = 'Sapience Orb',
    head = {
        name = 'Herculean Helm',
        augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}
    },
    body = 'Macu. Casaque +3',
    hands = 'Leyline Gloves',
    legs = 'Limbo Trousers',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Voltsurge Torque',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Loquac. Earring',
    ear2 = 'Enchntr. Earring +1',
    ring1 = 'Prolix Ring',
    ring2 = 'Defending Ring',
    back = Senuna.TP
}

sets.precast.FC.Utsusemi = sets.precast.FC

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Weaponskill
--   NOTE: Moonshade Earring is managed dynamically by TPBonusCalculator
--   It will equip automatically at 1750-1999 TP to reach 2000 TP threshold
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = {
        name = 'Adhemar Bonnet +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    body = 'Meg. Cuirie +2',
    hands = 'Meg. Gloves +2',
    legs = 'Horos Tights +4',
    feet = {
        name = 'Lustra. Leggings +1',
        augments = {'HP+65', 'STR+15', 'DEX+15'}
    },
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = 'Odr Earring',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Regal Ring',
    ring2 = "Cornelia's Ring",
    back = Senuna.WS
}

-- • Ruthless Stroke (4 variants: base, Clim, FanDance, FanDance.Clim, SaberDance, SaberDance.Clim)
--   No Fan Dance (50 equipment DT)
sets.precast.WS['Ruthless Stroke'] = {
    ammo = 'C. Palug Stone',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Nyame Flanchard',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Null Loop',
    waist = 'Kentarch Belt +1',
    ear1 = 'Odnowa Earring +1',
    ear2 = 'Domin. Earring +1',
    ring1 = 'Regal Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

--   Climactic Flourish (50 equipment DT)
sets.precast.WS['Ruthless Stroke'].Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Malignance Tabard',
    hands = 'Maxixi Bangles +4',
    legs = 'Nyame Flanchard',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Odnowa Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = "Cornelia's ring",
    ring2 = 'Defending Ring',
    back = Senuna.WS
}

--   Fan Dance (30 equipment DT)
sets.precast.WS['Ruthless Stroke'].FanDance = {
    ammo = 'C. Palug Stone',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Horos Tights +4',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Grunfeld Rope',
    ear1 = 'Odr Earring',
    ear2 = 'Domin. Earring +1',
    ring1 = "Cornelia's ring",
    ring2 = 'Regal Ring',
    back = Senuna.WS
}

--   Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS['Ruthless Stroke'].FanDance.Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Maxixi Bangles +4',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = "Epaminondas's Ring",
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

--   Saber Dance (High Haste/STP build, no DW needed)
sets.precast.WS['Ruthless Stroke'].SaberDance = {
    ammo = 'Coiste Bodhar',
    head = 'Maculele Tiara +3',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Ishvara Earring',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

--   Saber Dance + Climactic Flourish (Crit-focused with Haste)
sets.precast.WS['Ruthless Stroke'].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Ishvara Earring',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- • Dancing Edge (6 variants)
--   No Fan Dance (50 equipment DT)
sets.precast.WS['Dancing Edge'] = {
    ammo = 'Coiste Bodhar',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = 'Moonlight Ring',
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Climactic Flourish (50 equipment DT)
sets.precast.WS['Dancing Edge'].Clim = {
    ammo = 'Coiste Bodhar',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = 'Moonlight Ring',
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Fan Dance (30 equipment DT)
sets.precast.WS['Dancing Edge'].FanDance = {
    ammo = 'Coiste Bodhar',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = 'Moonlight Ring',
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS['Dancing Edge'].FanDance.Clim = {
    ammo = 'Coiste Bodhar',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Macu. Bangles +3',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = 'Moonlight Ring',
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Saber Dance (High Haste/STP build, no DW needed)
sets.precast.WS['Dancing Edge'].SaberDance = {
    ammo = 'Coiste Bodhar',
    head = 'Maculele Tiara +3',
    body = 'Horos Casaque +3',
    hands = 'Macu. Bangles +3',
    legs = 'Nyame Flanchard',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Mache Earring +1',
    ring1 = 'Regal Ring',
    ring2 = Moonlight2, -- wardrobe 4
    back = Senuna.TP
}

-- Dancing Edge: Saber Dance + Climactic Flourish (Crit-focused with Haste)
sets.precast.WS['Dancing Edge'].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = "Gleti's Cuirass",
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Mache Earring +1',
    ring1 = 'Defending Ring',
    ring2 = 'Regal Ring',
    back = Senuna.WS
}

-- • Rudra's Storm (6 variants)
--   No Fan Dance (50 equipment DT)
sets.precast.WS["Rudra's Storm"] = {
    ammo = 'Aurgelmir Orb +1',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Odnowa Earring +1',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- Rudra's Storm: Climactic Flourish (50 equipment DT)
sets.precast.WS["Rudra's Storm"].Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- Rudra's Storm: Fan Dance (30 equipment DT)
sets.precast.WS["Rudra's Storm"].FanDance = {
    ammo = "Coiste Bodhar",
    head = "Maculele Tiara +3",
    body = "Nyame Mail",
    hands = "Maxixi Bangles +4",
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
    neck = "Etoile Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Domin. Earring +1",
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Senuna.WS
}

-- Rudra's Storm: Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS["Rudra's Storm"].FanDance.Clim = {
    ammo = "Charis Feather",
    head = "Maculele Tiara +3",
    body = "Meg. Cuirie +2",
    hands = "Maxixi Bangles +4",
    legs = "Nyame Flanchard",
    feet = "Nyame Sollerets",
    neck = "Etoile Gorget +2",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Macu. Earring +1",
    ring1 = "Epaminondas's Ring",
    ring2 = "Cornelia's ring",
    back = "Senuna's Mantle"
}

-- Rudra's Storm: Saber Dance (DEX/Attack/WSD optimized, no DW needed)
sets.precast.WS["Rudra's Storm"].SaberDance = {
    ammo = 'Coiste Bodhar',
    head = 'Maculele Tiara +3',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Odr Earring',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- Rudra's Storm: Saber Dance + Climactic Flourish (Crit DEX/WSD hybrid)
sets.precast.WS["Rudra's Storm"].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Domin. Earring +1',
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- • Shark Bite (6 variants)
--   No Fan Dance (50 equipment DT)
sets.precast.WS['Shark Bite'] = {
    ammo = 'C. Palug Stone',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Nyame Flanchard',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Null Loop',
    waist = 'Sailfi Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Odnowa Earring +1',
    ring1 = "Cornelia's ring",
    ring2 = 'Regal Ring',
    back = Senuna.WS
}

-- Shark Bite: Climactic Flourish (50 equipment DT)
sets.precast.WS['Shark Bite'].Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = "Gleti's Gauntlets",
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- Shark Bite: Fan Dance (30 equipment DT)
sets.precast.WS['Shark Bite'].FanDance = {
    ammo = 'C. Palug Stone',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Horos Tights +4',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Odr Earring',
    ring1 = "Cornelia's ring",
    ring2 = 'Regal Ring',
    back = Senuna.WS
}

-- Shark Bite: Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS['Shark Bite'].FanDance.Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Maxixi Bangles +4',
    legs = 'Maculele Tights +3',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Moonlight Ring',
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- Shark Bite: Saber Dance (AGI/DEX hybrid, no DW needed)
sets.precast.WS['Shark Bite'].SaberDance = {
    ammo = 'C. Palug Stone',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Maxixi Bangles +4',
    legs = 'Samnuha Tights',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Gere Ring',
    ring2 = 'Regal Ring',
    back = Senuna.WS
}

-- Shark Bite: Saber Dance + Climactic Flourish (Crit AGI/DEX hybrid)
sets.precast.WS['Shark Bite'].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Meg. Cuirie +2',
    hands = 'Maxixi Bangles +4',
    legs = 'Samnuha Tights',
    feet = 'Nyame Sollerets',
    neck = 'Etoile Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Macu. Earring +1',
    ring1 = "Epaminondas's Ring",
    ring2 = "Cornelia's ring",
    back = Senuna.WS
}

-- • Other Weaponskills (Pyrrhic Kleos, Evisceration, Exenterator, Aeolian Edge)
sets.precast.WS['Pyrrhic Kleos'] = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Fotia Belt',
    ear1 = 'Sherida Earring',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Regal Ring',
    ring2 = 'Gere Ring',
    back = Senuna.WS
}

sets.precast.WS['Evisceration'] = {
    ammo = 'Charis Feather',
    head = 'Maculele Tiara +3',
    body = "Gleti's Cuirass",
    hands = 'Malignance Gloves',
    legs = 'Lustr. Subligar +1',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Etoile Gorget +2',
    waist = 'Fotia Belt',
    ear1 = 'Odr Earring',
    ear2 = 'Macu. Earring +1',
    ring1 = 'Regal Ring',
    ring2 = 'Ilabrat Ring',
    back = Senuna.WS
}

sets.precast.WS['Exenterator'] = {
    ammo = 'C. Palug Stone',
    head = 'Maculele Tiara +3',
    body = 'Macu. Casaque +3',
    hands = 'Maxixi Bangles +4',
    legs = 'Maculele Tights +3',
    feet = 'Macu. Toe Sh. +3',
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = 'Mache Earring +1',
    ear2 = 'Macu. Earring +1',
    ring1 = "Cornelia's ring",
    ring2 = 'Regal Ring',
    back = Senuna.WS
}

sets.precast.WS['Aeolian Edge'] = {
    ammo = 'Ghastly Tathlum +1',
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Sibyl Scarf',
    waist = "Orpheus's Sash",
    ear1 = 'Friomisi Earring',
    ear2 = 'Crematio Earring',
    ring1 = "Cornelia's ring",
    ring2 = "Epaminondas's Ring",
    back = Senuna.WS
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Fast Recast
sets.midcast = {}
sets.midcast.FastRecast = {}
sets.midcast.Utsusemi = set_combine(sets.precast.FC, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    feet = "Skadi's Jambeaux +1",
    ring2 = 'Defending Ring'
}

-- • Town Idle (Movement Speed)
sets.idle.Town = sets.MoveSpeed

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb"
})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

sets.buff['Saber Dance'] = {
    legs = 'Horos Tights +4'
}

sets.buff['Climactic Flourish'] = {
    head = 'Maculele Tiara +3'
}

sets.buff.Doom = {
    neck = {
        name = "Nicander's Necklace"
    }, -- Reduces Doom effects
    left_ring = {
        name = 'Purity Ring'
    }, -- Additional Doom resistance
    waist = {
        name = 'Gishdubar Sash'
    } -- Enhances Doom recovery effects
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Treasure Hunter
sets.TreasureHunter = {
    head = {
        name = 'Herculean Helm',
        augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}
    },
    legs = {
        name = 'Herculean Trousers',
        augments = {'Rng.Acc.+13', 'Attack+9', '"Treasure Hunter"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6'}
    }
}

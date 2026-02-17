---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Equipment Sets - Ultimate Bard Song Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Complete equipment configuration for Bard support role with optimized
---   song performance and survivability across all situations.
---   Features:
---     • Song potency maximization (Fili +3, Bihu +3, Brioso +3 sets)
---     • Instrument swapping (Gjallarhorn, Marsyas, Daurdabla, Carnwenhan)
---     • Honor March protection system (Marsyas lock throughout cast)
---     • Dummy song preparation (Daurdabla +2 song slots)
---     • Debuff song accuracy (Lullaby, Elegy, Requiem with Magic Acc)
---     • Melee TP generation (Ayanmo +2, Store TP focus)
---     • Weaponskill optimization (Savage Blade, Mordant Rime, Rudra's Storm)
---     • Movement speed optimization (Fili Cothurnes +3)
---     • Intarabus capes for all situations (Fast Cast, STP, WS)
---    Architecture:
---     • Equipment definitions (Intarabus capes, Linos, wardrobe rings)
---     • Weapon sets (main weapons + subs)
---     • Idle sets (Refresh, DT, Regen, Town)
---     • Engaged sets (Normal, PDT, Accuracy, Kraken Club)
---     • Precast sets (Fast Cast, Job Abilities)
---     • Weaponskill sets (Savage Blade, Rudra's Storm, Mordant Rime)
---     • Midcast sets (Songs by instrument, Debuff songs, Dummy songs)
---     • Movement & Buff sets (Speed optimization, Doom resistance)
---   @file    jobs/brd/sets/brd_sets.lua
---   @author  Tetsouo
---   @version 3.2 - Reorganized Priority Order
---   @date    Updated: 2025-11-10
---  ═════════════════════════════════════════════════════════════════════════

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • RINGS (Wardrobe Management)
local StikiRing1 = {name = 'Stikini Ring +1', bag = 'wardrobe 6'}
local StikiRing2 = {name = 'Stikini Ring +1', bag = 'wardrobe 7'}
local MoonlightRing1 = {name = 'Moonlight Ring', bag = 'wardrobe 2'}
local MoonlightRing2 = {name = 'Moonlight Ring', bag = 'wardrobe 4'}
local ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe'}
local ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 2'}

-- • INSTRUMENTS (Linos for TP/WS)
local LinosTP = {name = 'Linos', augments = {'Accuracy+15 Attack+15', '"Store TP"+4', 'Quadruple Attack +3'}}
local LinosWS = {name = 'Linos', augments = {'Attack+20', 'Weapon skill damage +3%', 'STR+8'}}

-- ═══════════════════════════════════════════════════════════════════════════
-- AUGMENTED EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • INTARABUS CAPES (FC / WS STR / Store TP)
local Intarabus = {
    fc = {
        name = "Intarabus's Cape",
        augments = {'CHR+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Fast Cast"+10', 'Phys. dmg. taken-10%'}
    },
    ws_str = {
        name = "Intarabus's Cape",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+6', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
    },
    stp = {
        name = "Intarabus's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • DAGGERS
sets['Carnwenhan'] = {main = 'Carnwenhan'}
sets['Twashtar'] = {main = 'Twashtar'}
sets['Mpu Gandring'] = {main = 'Mpu Gandring'}
sets['Centovente'] = {sub = 'Centovente'}

-- • SWORDS
sets['Naegling'] = {main = 'Naegling'}
sets['Demersal'] = {sub = 'Demers. Degen +1'}

-- • CLUBS
sets['Kraken'] = {sub = 'Kraken Club'}

-- • SHIELDS
sets['Genmei'] = {sub = 'Genmei Shield'}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE IDLE (Refresh Mode - MP Regen Focus)
sets.idle = {
    head = 'Fili Calot +3',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Fili Cothurnes +3',
    neck = 'Lissome Necklace',
    waist = 'Null Belt',
    left_ear = 'Infused Earring',
    right_ear = 'Eabani Earring',
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Intarabus.stp
}

-- • REFRESH MODE (Default Idle Set)
sets.idle.Refresh = set_combine(sets.idle, {})

-- • DT Mode (Damage Taken Reduction - Nyame)
sets.idle.DT = set_combine(sets.idle, {
    head="Nyame Helm",
    body="Adamantite Armor",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
    neck="Unmoving Collar +1",
    waist="Trance Belt",
    left_ear="Trux Earring",
    right_ear="Cryptic Earring",
    left_ring= "Provocare Ring",
    right_ring="SuperShear Ring",
    back = Intarabus.stp
})

-- • Regen Mode (HP Recovery - Nyame)
sets.idle.Regen = set_combine(sets.idle, {
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets'
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE ENGAGED (Fallback)
sets.engaged = {
    ranged = LinosTP,
    head="Fili Calot +3",
    body="Fili Hongreline +3",
    hands="Fili Manchettes +3",
    legs="Fili Rhingrave +3",
    feet="Fili Cothurnes +3",
    neck="Bard's Charm +2",
    waist="Null Belt",
    left_ear="Domin. Earring +1",
    right_ear="Telos Earring",
    left_ring= ChirichRing1,
    right_ring=MoonlightRing2,
    back = Intarabus.stp
}

-- • STORE TP MODE (TP Generation Focus)
sets.engaged.STP = set_combine(sets.engaged, {})

-- • ACCURACY MODE (For High Evasion Targets)
sets.engaged.Acc = set_combine(sets.engaged, {})

-- • SUBTLE BLOW MODE (Reduce Enemy TP Gain)
sets.engaged.SB = set_combine(sets.engaged, {})

-- • KRAKEN CLUB SPECIALIZED (Multi-Attack Focus)
--   Automatically selected when Kraken Club is equipped in sub-weapon slot
--   Reduces Store TP to leverage Kraken Club's multi-attack proc rate
--   See: set_builder.lua select_engaged_base()
sets.engaged.PDTKC = set_combine(sets.engaged, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • FAST CAST
sets.precast.FC = {
    head = 'Fili Calot +3',
    body = 'Brioso Justau. +3',
    hands = {name = 'Leyline Gloves', augments = {'Accuracy+15', 'Mag. Acc.+15', '"Mag.Atk.Bns."+15', '"Fast Cast"+3'}},
    legs = 'Fili Rhingrave +3',
    feet = 'Bihu Slippers +3',
    neck = "Orunmila's Torque",
    waist = 'Witful Belt',
    left_ear = 'Enchntr. Earring +1',
    right_ear = 'Loquac. Earring',
    ring1 = 'Prolix Ring',
    ring2 = 'Defending Ring',
    back = Intarabus.fc
}

sets.precast.BardSong = sets.precast.FC

-- • Honor March precast (CRITICAL - MUST have Marsyas)
sets.precast['Honor March'] = set_combine(sets.precast.FC, {range = 'Marsyas'})

-- • Aria of Passion precast (CRITICAL - MUST have Loughnashade)
sets.precast['Aria of Passion'] = set_combine(sets.precast.FC, {range = 'Loughnashade'})

-- • JOB ABILITIES
-- • Nightingale (Extend song duration) - Bihu Slippers +3
sets.precast.JA.Nightingale = {feet = 'Bihu Slippers +3'}

-- • Troubadour (Enhance song effects) - Bihu Justaucorps +3
sets.precast.JA.Troubadour = {body = 'Bihu Justaucorps +3'}

-- • Troubadour (Enhance song effects) - Bihu Justaucorps +3
sets.precast.JA['Soul Voice'] = {legs = 'Bihu cannions +3'}


-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • GENERIC WEAPONSKILL (Fallback)
sets.precast.WS = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Sailfi Belt +1',
    ear1 = 'Ishvara Earring',
    ear2 = 'Domin. Earring +1',
    ring1 = MoonlightRing1,
    ring2 = "Cornelia's Ring",
    back = Intarabus.ws_str
}

-- • DAGGER WEAPONSKILLS
-- • Evisceration (Dagger: Multi-hit DEX Crit)
sets.precast.WS['Evisceration'] = {
    ranged = LinosWS,
    head = 'Blistering Sallet +1',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Lustra. Leggings +1',
    neck = "Bard's Charm +2",
    waist = 'Fotia Belt',
    ear1 = 'Odnowa Earring +1',
    ear2 = 'Domin. Earring +1',
    ring1 = 'Defending Ring',
    ring2 = MoonlightRing2,
    back = "Intarabus's Cape"
}

-- • Rudra's Storm (Dagger: Single-hit DEX)
sets.precast.WS["Rudra's Storm"] = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Kentarch Belt +1',
    ear1 = 'Mache Earring +1',
    ear2 = 'Domin. Earring +1',
    ring1 = "Cornelia's Ring",
    ring2 = MoonlightRing2,
    back = Intarabus.ws_str
}

-- • Mordant Rime (Dagger: Magical CHR/DEX)
sets.precast.WS['Mordant Rime'] = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Sailfi Belt +1',
    ear1 = 'Ishvara Earring',
    ear2 = 'Regal Earring',
    ring1 = "Cornelia's ring",
    ring2 = 'Metamor. Ring +1',
    back = Intarabus.ws_str
}

-- • Ruthless Stroke (Sword: Single-hit STR Crit)
sets.precast.WS['Ruthless Stroke'] = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Kentarch Belt +1',
    ear1 = 'Ishvara Earring',
    ear2 = 'Domin. Earring +1',
    ring1 = "Epaminondas's Ring",
    ring2 = 'Moonlight Ring',
    back = Intarabus.ws_str
}

-- • SWORD WEAPONSKILLS
-- • Savage Blade (Sword: Single-hit STR/MND)
sets.precast.WS['Savage Blade'] = {
    ranged = LinosWS,
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Bihu Justaucorps +3', augments = {'Enhances "Troubadour" effect'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = {name = 'Nyame Sollerets', augments = {'Path: B'}},
    neck = {name = "Bard's Charm +2", augments = {'Path: A'}},
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    ear1 = 'Ishvara Earring',
    ear2 = 'Crep. Earring',
    ring1 = MoonlightRing1,
    ring2 = "Cornelia's Ring",
    back = Intarabus.ws_str
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}
sets.midcast['Enhancing Magic'] = {}

-- • BASE BARD SONG SETS
sets.midcast.BardSong = {
    main = 'Carnwenhan',
    sub = 'Kali',
    range = 'Gjallarhorn',
    head = 'Fili Calot +3',
    neck = 'Mnbw. Whistle +1',
    ear1 = 'Musical Earring',
    ear2 = 'Fili Earring +1',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    ring1 = StikiRing1,
    ring2 = StikiRing2,
    back = Intarabus.fc,
    waist = 'Flume Belt +1',
    legs = 'Inyanga Shalwar +2',
    feet = 'Brioso Slippers +4'
}

-- • Instrument variations
sets.midcast.Songs = {}
sets.midcast.Songs.Gjallarhorn = set_combine(sets.midcast.BardSong, {range = 'Gjallarhorn'})
sets.midcast.Songs.Marsyas = set_combine(sets.midcast.BardSong, {range = 'Marsyas'})
sets.midcast.Songs.Daurdabla = set_combine(sets.midcast.BardSong, {range = 'Daurdabla'})

-- • SPECIAL SONGS (Instrument Required)

-- • Honor March (CRITICAL - requires Marsyas throughout cast)
sets.midcast.HonorMarch = set_combine(sets.midcast.BardSong, {range = 'Marsyas'})

-- • Aria of Passion (CRITICAL - requires Loughnashade throughout cast)
sets.midcast.AriaPassion = set_combine(sets.midcast.BardSong, {range = 'Loughnashade'})

-- • BUFF SONGS (Relic/Empyrean/AF Enhancements)

-- • Ballad (MP regen) - Fili Rhingrave +3
sets.midcast.Ballad = set_combine(sets.midcast.BardSong, {legs = 'Fili Rhingrave +3'})

-- • Madrigal (Accuracy/Ranged Accuracy) - Fili Calot +3
sets.midcast.Madrigal = set_combine(sets.midcast.BardSong, {head = 'Fili Calot +3'})

-- • Minuet (Attack/Ranged Attack) - Fili Hongreline +3
sets.midcast.Minuet = set_combine(sets.midcast.BardSong, {body = 'Fili Hongreline +3'})

-- • Minne (Defense) - Mousai Seraweels +1
sets.midcast.Minne = set_combine(sets.midcast.BardSong, {legs = 'Mousai Seraweels +1'})

-- • Etude (Stat Boost) - Mousai Turban +1
sets.midcast.Etude = set_combine(sets.midcast.BardSong, {head = 'Mousai Turban +1'})

-- • March 
sets.midcast.March = set_combine(sets.midcast.BardSong, {hands = 'Fili manchettes +3'})

-- • Paeon 
sets.midcast["Army's Paeon"] = set_combine(sets.midcast.BardSong, {head = 'Brioso Roundlet +4'})
sets.midcast.Dirge = set_combine(sets.midcast.BardSong, {head = 'Brioso Roundlet +4'})
sets.midcast.Paeon = set_combine(sets.midcast.BardSong, {head = 'Brioso Roundlet +4'})

-- • Scherzo (Damage Reduction) - Fili Cothurnes +3
sets.midcast.Scherzo = set_combine(sets.midcast.BardSong, {feet = 'Fili Cothurnes +3'})
sets.midcast["Sentinel's Scherzo"] = sets.midcast.Scherzo

-- • Carol (Elemental Resistance)
sets.midcast.Carol = set_combine(sets.midcast.BardSong, {})

-- • Mambo (Evasion)
sets.midcast.Mambo = set_combine(sets.midcast.BardSong, {})

-- • DUMMY SONGS (Daurdabla +2 Song Slots)
sets.midcast.DummySong = {
    range = 'Daurdabla',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = 'Adamantite Armor',
    hands = 'Fili Manchettes +3',
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Nyame Sollerets',
    neck = 'Null Loop',
    waist = 'Null Belt',
    left_ear = 'Infused Earring',
    right_ear = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = 'Solemnity Cape'
}

sets.midcast['Gold Capriccio'] = sets.midcast.DummySong
sets.midcast['Goblin Gavotte'] = sets.midcast.DummySong
sets.midcast['Fowl Aubade'] = sets.midcast.DummySong
sets.midcast['Herb Pastoral'] = sets.midcast.DummySong

-- • DEBUFF SONGS (Magic Accuracy Focus)

-- • Lullaby (Sleep) - NO weapon swap to avoid waking targets
sets.midcast.Lullaby = {
    -- NO main/sub - DO NOT change weapons for Lullaby!
    range = 'Daurdabla',
    head = 'Brioso Roundlet +4',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Brioso Slippers +4',
    neck = 'Mnbw. Whistle +1',
    ear1 = 'Regal Earring',
    ear2 = 'Crepuscular Earring',
    ring1 = StikiRing1,
    ring2 = StikiRing2,
    waist = 'Acuity Belt +1',
    back = Intarabus.fc
}

sets.midcast['Horde Lullaby'] = sets.midcast.Lullaby
sets.midcast['Horde Lullaby II'] = sets.midcast.Lullaby
sets.midcast['Foe Lullaby'] = sets.midcast.Lullaby
sets.midcast['Foe Lullaby II'] = sets.midcast.Lullaby

-- • Base Debuff Song (Elegy, Requiem, Finale, etc.)
sets.midcast.DebuffSong = {
    range = 'Gjallarhorn',
    head = 'Brioso Roundlet +4',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Brioso Slippers +4',
    neck = 'Mnbw. Whistle +1',
    ear1 = 'Regal Earring',
    ear2 = 'Crepuscular Earring',
    ring1 = StikiRing1,
    ring2 = 'Metamor. Ring +1',
    waist = 'Acuity Belt +1',
    back = Intarabus.fc
}

sets.midcast['Pining Nocturne'] = set_combine(sets.midcast.DebuffSong, {})

-- • Magic Finale (Dispel)
sets.midcast['Magic Finale'] = sets.midcast.DebuffSong

-- • Elegy (Slow)
sets.midcast['Battlefield Elegy'] = sets.midcast.DebuffSong
sets.midcast['Carnage Elegy'] = sets.midcast.DebuffSong

-- • Requiem (DoT)
sets.midcast['Foe Requiem VII'] = sets.midcast.DebuffSong

-- • Other Debuffs
sets.midcast["Maiden's Virelai"] = sets.midcast.DebuffSong

-- • Threnody (Elemental Resistance Down) - Mousai Manteel +1
sets.midcast.Threnody = set_combine(sets.midcast.DebuffSong, {body = 'Mousai Manteel +1'})

-- ═══════════════════════════════════════════════════════════════════════════
-- SPECIAL SETS (Movement & Buffs)
-- ═══════════════════════════════════════════════════════════════════════════

-- • MOVEMENT SPEED
sets.MoveSpeed = {feet = 'Fili Cothurnes +3'}

-- • TOWN IDLE (Movement Speed Priority)
sets.idle.Town = sets.MoveSpeed

-- • ADOULIN MOVEMENT (City-Specific Speed Boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {body = "Councilor's Garb"})

-- • BUFF SETS
sets.buff = {}

-- • DOOM RESISTANCE
sets.buff.Doom = {
    neck = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    waist = 'Gishdubar Sash'
}

print('[BRD] Equipment sets loaded successfully')

---============================================================================
--- BRD Equipment Sets - Ultimate Bard Song Configuration
---============================================================================
--- Complete equipment configuration for Bard support role with optimized
--- song performance and survivability across all situations.
---
--- Features:
---   • Song potency maximization (Fili +3, Bihu +3, Brioso +3 sets)
---   • Instrument swapping (Gjallarhorn, Marsyas, Daurdabla, Carnwenhan)
---   • Honor March protection system (Marsyas lock throughout cast)
---   • Dummy song preparation (Daurdabla +2 song slots)
---   • Debuff song accuracy (Lullaby, Elegy, Requiem with Magic Acc)
---   • Melee TP generation (Ayanmo +2, Store TP focus)
---   • Weaponskill optimization (Savage Blade, Mordant Rime, Rudra's Storm)
---   • Movement speed optimization (Fili Cothurnes +3)
---   • Intarabus capes for all situations (Fast Cast, STP, WS)
---
--- Architecture:
---   • Equipment definitions (Intarabus capes, Linos, wardrobe rings)
---   • Weapon sets (main weapons + subs)
---   • Precast sets (Fast Cast, Job Abilities, Weaponskills)
---   • Midcast sets (Songs by instrument, Debuff songs, Dummy songs)
---   • Idle sets (Refresh, DT, Regen, Town)
---   • Engaged sets (Normal, PDT, Accuracy)
---   • Movement sets (Base speed, Kiting)
---   • Buff sets (Doom resistance)
---
--- @file    jobs/brd/sets/brd_sets.lua
--- @author  Kaories
--- @version 3.0 - Standardized Organization
--- @date    Updated: 2025-10-15
---============================================================================

sets = {}

--============================================================--

--                  EQUIPMENT DEFINITIONS                     --
--============================================================--

local StikiRing1 = {name = 'Stikini Ring +1', bag = 'wardrobe 6'}
local StikiRing2 = {name = 'Stikini Ring +1', bag = 'wardrobe 7'}
local MoonlightRing1 = {name = 'Moonlight Ring', bag = 'wardrobe 2'}
local MoonlightRing2 = {name = 'Moonlight Ring', bag = 'wardrobe 4'}
local ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe'}
local ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 2'}
local LinosTP = {name = 'Linos', bag = 'wardrobe 7'}
local LinosWS = {name = 'Linos', bag = 'wardrobe 6'}

--============================================================--
--            AUGMENTED EQUIPMENT DEFINITIONS                --
--============================================================--

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

--============================================================--

--                      WEAPON SETS                          --
--============================================================--

sets['Twashtar'] = {main = 'Twashtar'}
sets['Carnwenhan'] = {main = 'Carnwenhan'}
sets['Naegling'] = {main = 'Naegling'}
sets['Mpu Gandring'] = {main = 'Mpu Gandring'}
sets['Kraken'] = {sub = 'Kraken Club'}
sets['Genmei'] = {sub = 'Genmei Shield'}
sets['Demersal'] = {sub = 'Demers. Degen +1'}
sets['Centovente'] = {sub = 'Centovente'}

--============================================================--

--                     PRECAST SETS                          --
--============================================================--

sets.precast = {}

--- Fast Cast set
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

--- Song-specific precast
sets.precast.BardSong = sets.precast.FC

--- Honor March precast (MUST have Marsyas)
sets.precast['Honor March'] =
    set_combine(
    sets.precast.FC,
    {
        range = 'Marsyas'
    }
)

sets.precast.JA = {}

--- Nightingale precast
sets.precast.JA.Nightingale = {
    feet = 'Bihu Slippers +3'
}

--- Troubadour precast
sets.precast.JA.Troubadour = {
    body = 'Bihu Justaucorps +3'
}

--- Marcato precast
sets.precast.JA.Marcato = {
    head = 'Fili Calot +3'
}

--============================================================--

--                     MIDCAST SETS                          --
--============================================================--

sets.midcast = {}

--- Base Bard Song midcast
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
    feet = 'Brioso Slippers +3'
}

--- Instrument-specific song sets
sets.midcast.Songs = {}

sets.midcast.Songs.Gjallarhorn =
    set_combine(
    sets.midcast.BardSong,
    {
        range = 'Gjallarhorn'
    }
)

sets.midcast.Songs.Marsyas =
    set_combine(
    sets.midcast.BardSong,
    {
        range = 'Marsyas'
    }
)

sets.midcast.Songs.Daurdabla =
    set_combine(
    sets.midcast.BardSong,
    {
        range = 'Daurdabla'
    }
)

--- Honor March specific (critical - requires Marsyas throughout cast)
sets.midcast.HonorMarch =
    set_combine(
    sets.midcast.BardSong,
    {
        range = 'Marsyas'
    }
)
sets.midcast['Honor March'] = sets.midcast.HonorMarch

--- Song-specific sets
sets.midcast.Ballad =
    set_combine(
    sets.midcast.BardSong,
    {
        legs = 'Fili Rhingrave +3'
    }
)

sets.midcast.Madrigal =
    set_combine(
    sets.midcast.BardSong,
    {
        head = 'Fili Calot +3'
    }
)

sets.midcast.Minuet =
    set_combine(
    sets.midcast.BardSong,
    {
        body = 'Fili Hongreline +3'
    }
)

sets.midcast.Minne =
    set_combine(
    sets.midcast.BardSong,
    {
        legs = 'Mousai Seraweels +1'
    }
)

sets.midcast.Etude =
    set_combine(
    sets.midcast.BardSong,
    {
        head = 'Mousai Turban +1'
    }
)

sets.midcast.Carol = set_combine(sets.midcast.BardSong, {})

sets.midcast.Scherzo =
    set_combine(
    sets.midcast.BardSong,
    {
        feet = 'Fili Cothurnes +3'
    }
)

sets.midcast["Sentinel's Scherzo"] = sets.midcast.Scherzo

sets.midcast.Mambo = set_combine(sets.midcast.BardSong, {})

--- Dummy song set (for slot preparation)
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

--- Lullaby set (Magic Accuracy focus)
--- NOTE: NO main/sub defined - keeps current equipped weapons
sets.midcast.Lullaby = {
    -- NO main/sub - DO NOT change weapons for Lullaby!
    range = 'Daurdabla',
    head = 'Brioso Roundlet +3',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Brioso Slippers +3',
    neck = 'Mnbw. Whistle +1',
    ear1 = 'Regal Earring',
    ear2 = 'Crepuscular Earring',
    ring1 = StikiRing1,
    ring2 = StikiRing2,
    waist = 'Acuity Belt +1',
    back = Intarabus.fc
}

--- Debuff song set (Elegy, Requiem, etc.)
sets.midcast.DebuffSong = {
    range = 'Gjallarhorn',
    head = 'Brioso Roundlet +3',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Brioso Slippers +3',
    neck = 'Mnbw. Whistle +1',
    ear1 = 'Regal Earring',
    ear2 = 'Crepuscular Earring',
    ring1 = StikiRing1,
    ring2 = 'Metamor. Ring +1',
    waist = 'Acuity Belt +1',
    back = Intarabus.fc
}

sets.midcast['Magic Finale'] = sets.midcast.DebuffSong
sets.midcast['Battlefield Elegy'] = sets.midcast.DebuffSong
sets.midcast['Carnage Elegy'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem II'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem III'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem IV'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem V'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem VI'] = sets.midcast.DebuffSong
sets.midcast['Foe Requiem VII'] = sets.midcast.DebuffSong
sets.midcast["Maiden's Virelai"] = sets.midcast.DebuffSong
sets.midcast['Pining Nocturne'] = sets.midcast.DebuffSong

--- Lullaby spells (AOE and single-target)
sets.midcast['Horde Lullaby'] = sets.midcast.Lullaby
sets.midcast['Horde Lullaby II'] = sets.midcast.Lullaby
sets.midcast['Foe Lullaby'] = sets.midcast.Lullaby
sets.midcast['Foe Lullaby II'] = sets.midcast.Lullaby

sets.midcast.Threnody =
    set_combine(
    sets.midcast.DebuffSong,
    {
        body = 'Mousai Manteel +1'
    }
)

--============================================================--
--                 IDLE AND ENGAGED SETS                     --
--============================================================--

-- Base idle set = Refresh mode (MP regen focus - default mode)
sets.idle = {
    head = 'Fili Calot +3',
    body = 'Fili Hongreline +3',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Nyame Sollerets',
    neck = 'Lissome Necklace',
    waist = 'Null Belt',
    left_ear = 'Infused Earring',
    right_ear = 'Eabani Earring',
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Intarabus.stp
}

-- IdleMode: Refresh (same as base - no need to duplicate)
sets.idle.Refresh = sets.idle

-- IdleMode: DT (Damage Taken reduction - Nyame)
sets.idle.DT =
    set_combine(
    sets.idle,
    {
        head = 'nyame helm',
        body = 'nyame mail',
        hands = 'nyame gauntlets',
        legs = 'nyame flanchard',
        feet = 'nyame sollerets'
    }
)

-- IdleMode: Regen (HP regen focus - Nyame for now)
sets.idle.Regen =
    set_combine(
    sets.idle,
    {
        head = 'nyame helm',
        body = 'nyame mail',
        hands = 'nyame gauntlets',
        legs = 'nyame flanchard',
        feet = 'nyame sollerets'
    }
)

-- Town set (highest priority - overrides all modes)
sets.idle.Town =
    set_combine(
    sets.idle,
    {
        body = "Councilor's Garb",
        feet = 'Fili Cothurnes +3'
    }
)

--- Melee TP set
sets.engaged = {}

sets.engaged.Normal = {
    ranged = LinosTP,
    head = 'Fili Calot +3',
    body = 'Ayanmo Corazza +2',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Fili Cothurnes +3',
    neck = "Bard's Charm +2",
    waist = 'Sailfi Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Telos Earring',
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Intarabus.stp
}

--- Accuracy melee set
sets.engaged.Acc =
    set_combine(
    sets.engaged.Normal,
    {
        ranged = LinosTP,
        head = 'Fili Calot +3',
        body = 'Ayanmo Corazza +2',
        hands = 'Fili Manchettes +3',
        legs = 'Fili Rhingrave +3',
        feet = 'Fili Cothurnes +3',
        neck = "Bard's Charm +2",
        waist = 'Sailfi Belt +1',
        ear1 = 'Domin. Earring +1',
        ear2 = 'Telos Earring',
        ring1 = ChirichRing1,
        ring2 = ChirichRing2,
        back = Intarabus.stp
    }
)

--- PDT engaged set
sets.engaged.PDT = {
    ranged = LinosTP,
    head = 'Fili Calot +3',
    body = 'Ayanmo Corazza +2',
    hands = 'Fili Manchettes +3',
    legs = 'Fili Rhingrave +3',
    feet = 'Fili Cothurnes +3',
    neck = "Bard's Charm +2",
    waist = 'Sailfi Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Telos Earring',
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Intarabus.stp
}

--- Kraken Club Specialized (Used when Kraken Club is in sub-weapon)
--- Automatically selected when Kraken Club is equipped in sub-weapon slot.
--- Reduces Store TP to leverage Kraken Club's multi-attack proc rate.
--- See: set_builder.lua select_engaged_base()
sets.engaged.PDTKC =
    set_combine(
    sets.engaged.PDT,
    {
        ranged = LinosTP,
        head = 'Fili Calot +3',
        body = 'Ayanmo Corazza +2',
        hands = 'Fili Manchettes +3',
        legs = 'Fili Rhingrave +3',
        feet = 'Fili Cothurnes +3',
        neck = "Bard's Charm +2",
        waist = 'Sailfi Belt +1',
        ear1 = 'Domin. Earring +1',
        ear2 = 'Telos Earring',
        ring1 = ChirichRing1,
        ring2 = ChirichRing2,
        back = Intarabus.stp
    }
)

--============================================================--

--                   WEAPON SKILL SETS                       --
--============================================================--

sets.precast.WS = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Sailfi Belt +1',
    ear1 = 'Moonshade Earring',
    ear2 = 'Ishvara Earring',
    ring1 = MoonlightRing1,
    ring2 = "Cornelia's Ring",
    back = Intarabus.ws_str
}

--- Savage Blade
sets.precast.WS['Savage Blade'] = {
    ranged = LinosWS,
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Bihu Jstcorps. +3', augments = {'Enhances "Troubadour" effect'}},
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

--- Mordant Rime
sets.precast.WS['Mordant Rime'] = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Sailfi Belt +1',
    ear1 = 'Regal Earring',
    ear2 = 'Ishvara Earring',
    ring1 = "Cornelia's ring",
    ring2 = 'Metamor. Ring +1',
    back = Intarabus.ws_str
}

--- Rudra's Storm
sets.precast.WS["Rudra's Storm"] = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Jstcorps. +3',
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

--- Ruthless Stroke
sets.precast.WS['Ruthless Stroke'] = {
    ranged = LinosWS,
    head = 'Nyame Helm',
    body = 'Bihu Justaucorps +3',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = "Bard's Charm +2",
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Ishvara Earring',
    ring1 = "Epaminondas's Ring",
    ring2 = 'Moonlight Ring',
    back = Intarabus.ws_str
}

--- Evisceration
sets.precast.WS['Evisceration'] = {
    ranged = LinosWS,
    head = 'Blistering Sallet +1',
    body = 'Bihu Jstcorps. +3',
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

--============================================================--
--                    DEFENSIVE SETS                         --
--============================================================--

sets.defense = {}
sets.defense.PDT = sets.engaged.PDT

sets.defense.MDT = {
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

--- Hybrid sets
sets.engaged.Hybrid = {}
sets.engaged.Hybrid.PDT = sets.engaged.PDT
sets.engaged.Hybrid.MDT = set_combine(sets.engaged.Normal, sets.defense.MDT)

--============================================================--

--                     MOVEMENT SETS                         --
--============================================================--

sets.MoveSpeed =
    set_combine(
    sets.idle,
    {
        feet = 'Fili Cothurnes +3'
    }
)
-- Adoulin Movement (City-specific speed boost)
sets.Adoulin =
    set_combine(
    sets.MoveSpeed,
    {
        body = "Councilor's Garb" -- Speed bonus in Adoulin city
    }
)
sets.Kiting = sets.MoveSpeed

print('[BRD] Equipment sets loaded successfully')

--                       BUFF SETS                           --
--============================================================--

sets.buff = {}
sets.buff.Doom = {
    neck = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    waist = 'Gishdubar Sash'
}

--============================================================--

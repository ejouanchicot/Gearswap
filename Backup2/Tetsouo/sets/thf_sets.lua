---============================================================================
--- THF Equipment Sets - Complete Thief Gear Configuration
---============================================================================
--- Comprehensive equipment configurations for Thief job covering all combat
--- scenarios, weaponskills, job abilities, and treasure hunter optimization.
---
--- Features:
---   • Weapon sets (Main: Vajra/Twashtar/Tauret/Naegling, Sub: Centovente/Gleti)
---   • Abyssea proc sets (7 weapon types for /WAR subjob)
---   • Idle sets (Normal, Town, Regen, PDT, Weak)
---   • Engaged sets (Normal, Acc, PDT, PDTAFM3 with Aftermath Lv.3)
---   • Job ability sets (SA/TA/Hide/Flee/Perfect Dodge/Conspirator)
---   • Weaponskills with SA/TA variants (Rudra's, Evisceration, Shark Bite, etc.)
---   • WS variant system (SATA > SA > TA > Base)
---   • Fast Cast sets (subjob spell casting)
---   • Ranged attack sets (with TH variant)
---   • Movement speed sets (Adoulin city-specific)
---   • Buff-specific sets (Sneak Attack, Trick Attack, Doom)
---   • Treasure Hunter sets (Tag/SATA combinations)
---
--- Architecture:
---   • Cape augments (STP: Store TP+10/PDT-10%, WS1: Crit+10%, WS2: WSD+10%)
---   • Dual Chirich Rings (wardrobe 1/2 for haste/store TP)
---   • Moonshade Earring (TP Bonus +250 - dynamic via TPBonusCalculator)
---   • Aftermath Lv.3 support (PDTAFM3 set for Vajra)
---   • SA/TA variant priority (SATA > SA > TA > Base for all WS)
---   • Treasure Hunter integration (TH+4 on feet, combined with SA/TA sets)
---
--- Dependencies:
---   • Mote-Include (set_combine for set inheritance)
---   • TPBonusCalculator (dynamic Moonshade at 1750-1999 TP)
---   • sa_ta_manager (buff-based WS set selection logic)
---   • set_builder (dynamic idle/engaged set construction)
---
--- @file    jobs/thf/sets/thf_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================
-- ============================================================--
--                  EQUIPMENT DEFINITIONS                     --
-- ============================================================--
local Toutatis = {}
Toutatis.STP = {
    name = "Toutatis's Cape",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
}
Toutatis.WS1 = {
    name = "Toutatis's Cape",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Crit.hit rate+10', 'Phys. dmg. taken-10%'}
}
Toutatis.WS2 = {
    name = "Toutatis's Cape",
    augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
}

local ChirichRing1 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 1'
}
local ChirichRing2 = {
    name = 'Chirich Ring +1',
    bag = 'wardrobe 2'
}
local MoonlightRing1 = {
    name = 'Moonlight Ring',
    bag = 'wardrobe 2'
}
local MoonlightRing2 = {
    name = 'Moonlight Ring',
    bag = 'wardrobe 4'
}

local MoonShadeEarring = {
    name = 'Moonshade Earring',
    augments = {'Accuracy+4', 'TP Bonus +250'}
}

-- ============================================================--

--                      WEAPON SETS                           --
-- ============================================================--

-- Main Weapons
sets.TwashtarM = {
    main = 'Twashtar'
}
sets['Mpu Gandring'] = {
    main = 'Mpu Gandring'
}
sets.Vajra = {
    main = 'Vajra'
}
sets.Tauret = {
    main = 'Tauret'
}
sets.Malevolence = {
    main = 'Malevolence'
}
sets.Dagger = {
    main = 'Qutrub Knife'
}
sets.Naegling = {
    main = 'Naegling'
}

-- Sub Weapons / Off-hand
sets.Tanmogayi = {
    sub = 'Tanmogayi +1'
}
sets.TwashtarS = {
    sub = 'Twashtar'
}
sets.Jugo = {
    sub = 'Jugo Kukri +1'
}
sets.Crepu = {
    sub = 'Crepuscular Knife'
}
sets.Centovente = {
    sub = 'Centovente'
}
sets.Blurred = {
    sub = 'Blurred Knife +1'
}
sets.Gleti = {
    sub = "Gleti's Knife"
}
sets.Kraken = {
    sub = "Kraken Club"
}

-- Abyssea Proc Weapons (1-handed with dagger sub for DW)
sets.Sword = {
    main = 'Excalipoor',
    sub = 'Qutrub Knife'
}
sets.Club = {
    main = 'Chac-Chacs',
    sub = 'Qutrub Knife'
}
sets.Dagger2 = {
    main = 'Qutrub Knife',
    sub = 'Chac-Chacs'
}

-- Abyssea Proc Weapons (2-handed with Alber Strap)
sets['Great Sword'] = {
    main = 'Lament',
    sub = 'Alber Strap'
}
sets.Polearm = {
    main = 'Iapetus',
    sub = 'Alber Strap'
}
sets.Staff = {
    main = 'Ram staff',
    sub = 'Alber Strap'
}
sets.Scythe = {
    main = 'Lost Sickle',
    sub = 'Alber Strap'
}
sets.Alber = {
    sub = 'Alber Strap'
}

-- ============================================================--

--                      IDLE SETS                             --
-- ============================================================--

-- Base Idle (Refresh/Regen focus)
sets.idle = {
    ammo = 'Aurgelmir Orb +1',
    head = "Gleti's Mask",
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = "Gleti's Boots",
    neck = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Eabani Earring',
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = 'Solemnity Cape'
}

-- Town Idle (Movement speed)
sets.idle.Town = set_combine(sets.idle, {
    feet = 'Pill. Poulaines +4'
})

-- Regen Idle (HP regeneration focus)
sets.idle.Regen = set_combine(sets.idle, {
    head = 'Meghanada Visor +2',
    body = 'Meg. Cuirie +2',
    hands = 'Meg. Gloves +2',
    legs = 'Meg. Chausses +2',
    feet = 'Meg. Jam. +2',
    ear1 = 'Dawn Earring',
    ear2 = 'Infused Earring'
})

-- PDT Idle (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle, {
    ring2 = 'Defending Ring'
})

-- Weak Idle (Low HP)
sets.idle.Weak = sets.idle

-- ============================================================--

--                      ENGAGED SETS                          --
-- ============================================================--

-- Base Engaged (DPS focus)
sets.engaged = {
    ammo = "Coiste Bodhar",
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Samnuha Tights",
    feet = "Skulk. Poulaines +3",
    neck = "Iskur Gorget",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Toutatis.STP
}

-- PDT Engaged (Defense while engaged)
sets.engaged.PDT = {
    ammo = "Coiste Bodhar",
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Samnuha Tights",
    feet = "Skulk. Poulaines +3",
    neck = "Iskur Gorget",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Toutatis.STP
}

-- PDT + Aftermath Lv.3 (For mythic/empyrean weapons with Aftermath)
sets.engaged.PDTAFM3 = {
    ammo = "Aurgelmir Orb +1",
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Adhemar Wrist. +1",
    legs = "Malignance Tights",
    feet = "Skulk. Poulaines +3",
    neck = "Iskur Gorget",
    waist = "Windbuffet Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = MoonlightRing1,
    ring2 = MoonlightRing2,
    back = Toutatis.STP
}

-- ============================================================--
--                   PRECAST: JOB ABILITIES                   --
-- ============================================================--

sets.precast = {}
sets.precast.JA = {}

-- Sneak Attack
sets.precast.JA['Sneak Attack'] = {
    ammo = 'Yetshila +1',
    head = {
        name = 'Adhemar Bonnet +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    body = "Pillager's Vest +4",
    hands = "Skulker's Armlets +3",
    legs = 'Lustr. Subligar +1',
    feet = "Skulker's Poulaines +3",
    neck = 'Asn. Gorget +2',
    waist = 'Kentarch belt +1',
    ear1 = 'Mache Earring +1',
    ear2 = 'Odr Earring',
    ring1 = 'Regal Ring',
    ring2 = 'Ilabrat Ring',
    back = Toutatis.STP
}

-- Trick Attack
sets.precast.JA['Trick Attack'] = {
    ammo = 'Yetshila +1',
    head = "Skulker's Bonnet +3",
    body = {
        name = "Plunderer's Vest +4",
        augments = {'Enhances "Ambush" effect'}
    },
    hands = 'Pill. Armlets +4',
    legs = "Pillager's Culottes +4",
    feet = "Skulker's Poulaines +3",
    neck = 'Asn. Gorget +2',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Dawn Earring',
    ear2 = 'Infused Earring',
    ring1 = 'Regal Ring',
    ring2 = 'Ilabrat Ring',
    back = {
        name = 'Canny Cape',
        augments = {'DEX+1', 'AGI+2', '"Dual Wield"+3', 'Crit. hit damage +3%'}
    }
}

-- Hide
sets.precast.JA.Hide = {
    body = 'Pill. Vest +4'
}

-- Flee
sets.precast.JA['Flee'] = {
    feet = 'Pill. Poulaines +4'
}

-- Perfect Dodge
sets.precast.JA['Perfect Dodge'] = {
    hands = {
        name = 'Plun. Armlets +3',
        augments = {'Enhances "Perfect Dodge" effect'}
    }
}

-- Feint
sets.precast.JA['Feint'] = {
    legs = {
        name = 'Plun. Culottes +4',
        augments = {'Enhances "Feint" effect'}
    }
}

-- Steal
sets.precast.JA['Steal'] = {
    neck = 'Pentalagus Charm',
    hands = "Thief's Kote",
    legs = "Assassin's Culottes",
    feet = 'Pill. Poulaines +4'
}

-- Despoil
sets.precast.JA['Despoil'] = {
    legs = "Skulker's culottes +3",
    feet = "Skulker's poulaines +3"
}

-- Collaborator / Accomplice
sets.precast.JA['Collaborator'] = {
    head = "Skulker's bonnet +3",
    body = "Plunderer's Vest +4",
    hands = 'Plun. Armlets +3',
    ear1 = 'Friomisi Earring',
    ring1 = 'Cacoethic Ring'
}
sets.precast.JA['Accomplice'] = sets.precast.JA['Collaborator']

-- Conspirator
sets.precast.JA['Conspirator'] = {
    body = "skulker's Vest +3"
}

-- Animated Flourish / Provoke
sets.precast.JA['Animated Flourish'] = {
    ammo = 'Sapience Orb',
    head = "Skulker's Bonnet +3",
    body = "Plunderer's Vest +4",
    hands = "Skulker's Armlets +3",
    legs = "Skulker's culottes +3",
    feet = "Skulker's Poulaines +3",
    neck = 'Unmoving Collar +1',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Friomisi Earring',
    ear2 = 'Eabani Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back = 'Solemnity Cape'
}
sets.precast.JA.Provoke = sets.precast.JA['Animated Flourish']

-- Waltz
sets.precast.Waltz = {
    ammo = 'Staunch Tathlum +1',
    head = 'Mummu Bonnet +2',
    body = 'Turms Harness',
    hands = 'Slither Gloves +1',
    legs = 'Dashing Subligar',
    feet = 'Meg. Jam. +2',
    neck = 'Elite Royal Collar',
    waist = 'Flume Belt',
    ear1 = 'Delta Earring',
    ear2 = "Handler's Earring",
    ring1 = 'Asklepian Ring',
    ring2 = "Valseur's Ring",
    back = 'Solemnity Cape'
}

-- Step
sets.precast.Step = {
    ammo = 'Aurgelmir Orb +1',
    head = 'Malignance Chapeau',
    body = "Pillager's Vest +4",
    hands = 'Meg. Gloves +2',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Asn. Gorget +2',
    waist = 'Kentarch belt +1',
    ear1 = 'Crepuscular Earring',
    ear2 = "Skulker's Earring +1",
    ring1 = ChirichRing1,
    ring2 = ChirichRing2,
    back = Toutatis.STP
}

sets.precast.Flourish1 = sets.precast.JA.Provoke

-- ============================================================--
--                   PRECAST: FAST CAST                       --
-- ============================================================--

sets.precast.FC = {
    ammo = 'Sapience Orb',
    head = {
        name = 'Herculean Helm',
        augments = {'MND+1', 'Attack+23', '"Treasure Hunter"+2'}
    },
    body = 'Dread Jupon',
    hands = 'Leyline Gloves',
    legs = 'Enif Cosciales',
    neck = 'Voltsurge Torque',
    ear1 = 'Enchntr. Earring +1',
    ear2 = 'Loquac. Earring',
    ring2 = 'Prolix Ring'
}

sets.precast.FC.Utsusemi = sets.precast.FC

-- ============================================================--
--                   PRECAST: WEAPONSKILLS                    --
-- ============================================================--

sets.precast.WS = {}

-- Base WS Set
sets.precast.WS = {
    ammo = 'Yetshila +1',
    head = {
        name = 'Adhemar Bonnet +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    body = "Plunderer's Vest +4",
    hands = {
        name = 'Adhemar Wrist. +1',
        augments = {'STR+12', 'DEX+12', 'Attack+20'}
    },
    legs = "Pillager's culottes +4",
    feet = {
        name = 'Lustra. Leggings +1',
        augments = {'HP+65', 'STR+15', 'DEX+15'}
    },
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = MoonShadeEarring,
    ear2 = 'Odr Earring',
    ring1 = 'Regal Ring',
    ring2 = "Cornelia's Ring",
    back = Toutatis.WS2
}

-- Rudra's Storm (Main THF WS - DEX - Crit damage) --
sets.precast.WS["Rudra's Storm"] = {
    ammo = "Aurgelmir Orb +1",
    head = "Nyame Helm",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Plun. Culottes +4",
    feet = "Nyame Sollerets",
    neck = "Loricate Torque +1",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Domin. Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring",
    back = Toutatis.WS2
}

sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    legs = "Skulk. Culottes +3",
    feet = "Nyame Sollerets",
    neck = "Asn. Gorget +2"
})

sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    feet = "Skulk. Poulaines +3",
    ear1 = "Odnowa Earring +1"
})

sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    legs = "Skulk. Culottes +3",
    ear1 = "Odnowa Earring +1",
    ear2 = "Domin. Earring +1",
    ring1 = "Regal Ring",
    ring2 = "Cornelia's ring",
})

-- Evisceration (Multi-hit crit WS) --
sets.precast.WS['Evisceration'] = {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    body = "Plunderer's Vest +4",
    hands = "Skulk. Armlets +3",
    legs = "Skulk. Culottes +3",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring1 = "Regal Ring",
    ring2 = "Moonlight Ring",
    back = Toutatis.WS2
}

sets.precast.WS['Evisceration'].SA = set_combine(sets.precast.WS['Evisceration'], {
    waist = "Kentarch Belt +1",
    ear2 = "Domin. Earring +1"
})

sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'], {
    legs = "Pill. Culottes +4",
    ear1 = "Odnowa Earring +1",
    ear2 = "Odr Earring",
    ring1 = "Defending Ring",
    ring2 = "Moonlight Ring"
})

sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'], {
    waist = "Kentarch Belt +1",
    ear2 = "Domin. Earring +1"
})

-- Exenterator (Multi-hit AGI WS) --
sets.precast.WS['Exenterator'] = {
    ammo = "Coiste Bodhar",
    head = "Skulker's Bonnet +3",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Meg. Chausses +2",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    waist = "Sailfi Belt +1",
    ear1 = "Odnowa Earring +1",
    ear2 = "Skulk. Earring +1",
    ring1 = "Regal Ring",
    ring2 = "Defending Ring",
    back = Toutatis.WS2
}

sets.precast.WS['Exenterator'].SA = set_combine(sets.precast.WS['Exenterator'], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    legs = "Skulk. Culottes +3",
    ear1 = "Sherida Earring",
    ear2 = "Skulk. Earring +1",
    ring2 = "Moonlight Ring"
})

sets.precast.WS['Exenterator'].TA = set_combine(sets.precast.WS['Exenterator'], {
    ammo = "Crepuscular Pebble",
    head = "Pill. Bonnet +4",
    hands = "Pill. Armlets +4",
    legs = "Skulk. Culottes +3"
})

sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    body = "Plunderer's Vest +4",
    legs = "Skulk. Culottes +3",
    ear1 = "Sherida Earring",
    ear2 = "Odr Earring",
    ring2 = "Moonlight Ring"
})

-- Savage Blade (STR/MND WS for Naegling) --

sets.precast.WS['Savage Blade'] = {
    ammo = "Seeth. Bomblet +1",
    head = "Plun. Bonnet +4",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Plun. Culottes +4",
    feet = "Skulk. Poulaines +3",
    neck = "Loricate Torque +1",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Odnowa Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring",
    back = Toutatis.WS2
}

sets.precast.WS['Savage Blade'].SA = set_combine(sets.precast.WS['Savage Blade'], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    legs = "Skulk. Culottes +3",
    neck = "Null Loop",
    ear1 = "Sherida Earring",
    ear2 = "Ishvara Earring",
    ring1 = "Regal Ring"
})

sets.precast.WS['Savage Blade'].TA = set_combine(sets.precast.WS['Savage Blade'], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    neck = "Null Loop",
    ear1 = "Ishvara Earring"
})

sets.precast.WS['Savage Blade'].SATA = set_combine(sets.precast.WS['Savage Blade'], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    ear1 = "Ishvara Earring",
    ear2 = "Odnowa Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring"
})

-- Shark Bite (DEX/MND WS) --

sets.precast.WS['Shark Bite'] = {
    ammo = "Coiste Bodhar",
    head = "Pill. Bonnet +4",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Plun. Culottes +4",
    feet = "Skulk. Poulaines +3",
    neck = "Loricate Torque +1",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Odnowa Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring",
    back = Toutatis.WS2
}

sets.precast.WS['Shark Bite'].SA = set_combine(sets.precast.WS['Shark Bite'], {
    ammo = "Yetshila +1",
    waist = "Kentarch Belt +1",
    ear1 = "Ishvara Earring"
})

sets.precast.WS['Shark Bite'].TA = set_combine(sets.precast.WS['Shark Bite'], {
    ammo = "Yetshila +1",
    ear1 = "Ishvara Earring",
    ear2 = "Odnowa Earring +1"
})

sets.precast.WS['Shark Bite'].SATA = set_combine(sets.precast.WS['Shark Bite'], {
    ammo = "Yetshila +1",
    waist = "Kentarch Belt +1",
    ear1 = "Ishvara Earring",
    ear2 = "Odnowa Earring +1"
})

-- Mandalic Stab (DEX WS)
sets.precast.WS['Mandalic Stab'] = {
    ammo = "Coiste Bodhar",
    head = "Nyame Helm",
    body = "Skulker's Vest +3",
    hands = "Skulk. Armlets +3",
    legs = "Plun. Culottes +4",
    feet = "Skulk. Poulaines +3",
    neck = "Asn. Gorget +2",
    waist = "Sailfi Belt +1",
    ear1 = "Sherida Earring",
    ear2 = "Odnowa Earring +1",
    ring1 = "Defending Ring",
    ring2 = "Cornelia's ring",
    back = Toutatis.WS2
}

-- Mandalic Stab SA
sets.precast.WS['Mandalic Stab'].SA = set_combine(sets.precast.WS['Mandalic Stab'], {
    ammo = "Crepuscular Pebble",
    head = "Pill. Bonnet +4",
    feet = "Nyame Sollerets",
    neck = "Loricate Torque +1",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Odnowa Earring +1"
})

-- Mandalic Stab TA
sets.precast.WS['Mandalic Stab'].TA = set_combine(sets.precast.WS['Mandalic Stab'], {
    ammo = "Yetshila +1",
    head = "Pill. Bonnet +4",
    legs = "Gleti's Breeches",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Domin. Earring +1"
})

-- Mandalic Stab SATA
sets.precast.WS['Mandalic Stab'].SATA = set_combine(sets.precast.WS['Mandalic Stab'], {
    ammo = "Crepuscular Pebble",
    head = "Pill. Bonnet +4",
    body = "Gleti's Cuirass",
    feet = "Nyame Sollerets",
    waist = "Kentarch Belt +1",
    ear1 = "Odr Earring",
    ear2 = "Domin. Earring +1"
})

-- Aeolian Edge (Magical WS) --
sets.precast.WS['Aeolian Edge'] = {
    ammo = "Seeth. Bomblet +1",
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Sibyl Scarf',
    waist = "Orpheus's Sash",
    ear1 = 'Sortiarius Earring',
    ear2 = 'Friomisi Earring',
    ring1 = "Epaminondas's Ring",
    ring2 = "Cornelia's Ring",
    back = Toutatis.WS2
}

-- Dancing Edge (DEX WS) --

sets.precast.WS['Dancing Edge'] = sets.precast.WS

sets.precast.WS['Dancing Edge'].SA = set_combine(sets.precast.WS['Dancing Edge'], {
    hands = "Skulker's Armlets +3"
})

sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'], {
    hands = 'Pill. Armlets +4'
})

sets.precast.WS['Dancing Edge'].SATA = sets.precast.WS['Dancing Edge'].TA

-- Circle Blade (STR/DEX WS) --

sets.precast.WS['Circle Blade'] = {
    ammo = "Oshasha's Treatise",
    head = "skulker's Bonnet +3",
    body = "skulker's Vest +3",
    hands = "Skulker's Armlets +3",
    legs = 'Pill. Culottes +3',
    feet = {
        name = 'Plun. Poulaines +3',
        augments = {"Enhances \"Assassin's Charge\" effect"}
    },
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = 'Ishvara Earring',
    ear2 = "Skulker's Earring +1",
    ring1 = 'Ilabrat Ring',
    ring2 = 'Mummu Ring',
    back = Toutatis.WS2
}

-- ============================================================--
--                   PRECAST: RANGED ATTACK                   --
-- ============================================================--

sets.precast.RA = {
    range = 'Exalted Crossbow',
    ammo = 'Acid Bolt',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Null Loop',
    waist = 'Yemaya Belt',
    ear1 = 'Crepuscular Earring',
    ear2 = 'Telos Earring',
    ring1 = 'Cacoethic Ring',
    ring2 = 'Crepuscular Ring',
    back = 'Sacro mantle'
}

sets.precast.RATH = set_combine(sets.precast.RA, {
    feet = "Skulker's Poulaines +3"
})

-- ============================================================--

--                      MIDCAST SETS                          --
-- ============================================================--

sets.midcast = {}

-- Ranged Midcast
sets.midcast.RA = sets.precast.RA
sets.midcast.RA.Acc = sets.midcast.RA

-- Cure Midcast (for /WHM subjob)
sets.midcast.Cure = {}

-- Enhancing Magic
sets.midcast.EnhancingMagic = {}

-- Fast Recast
sets.midcast.FastRecast = {
    ammo = 'Aurgelmir Orb +1',
    head = "skulker's Bonnet +3",
    body = 'Nyame Mail',
    hands = "Skulker's Armlets +3",
    legs = "Skulker's culottes +3",
    feet = "Skulker's Poulaines +3",
    neck = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Eabani Earring',
    ring1 = ChirichRing2,
    ring2 = 'Defending Ring',
    back = 'Solemnity Cape'
}

sets.midcast.Utsusemi = sets.midcast.FastRecast

-- ============================================================--

--                      MOVEMENT SETS                         --
-- ============================================================--

-- Base Movement Speed
sets.MoveSpeed = {
    feet = 'Pill. Poulaines +4',
    ring1 = 'Defending Ring'
}

-- Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb"
})

-- ============================================================--

--                      BUFF SETS                             --
-- ============================================================--

sets.buff = {}
sets.buff['Sneak Attack'] = sets.precast.JA['Sneak Attack']
sets.buff['Trick Attack'] = sets.precast.JA['Trick Attack']

-- Doom Resistance
sets.buff.Doom = {
    neck = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    ring2 = "Blenmot's Ring +1",
    waist = 'Gishdubar Sash'
}

-- ============================================================--
--                   TREASURE HUNTER SETS                     --
-- ============================================================--

-- Base TreasureHunter
sets.TreasureHunter = {
    feet = "Skulker's Poulaines +3"
}

-- TH with SA/TA (Combined sets)
sets.TreasureHunterSA = set_combine(sets.TreasureHunter, sets.precast.JA['Sneak Attack'])
sets.TreasureHunterTA = set_combine(sets.TreasureHunter, sets.precast.JA['Trick Attack'])
sets.TreasureHunterSATA = set_combine(sets.TreasureHunter, sets.precast.JA['Sneak Attack'],
    sets.precast.JA['Trick Attack'])

-- TH Ranged
sets.TreasureHunterRA = set_combine(sets.precast.RA, {
    feet = "Skulker's Poulaines +3"
})

sets.midcast.RA.TH = set_combine(sets.precast.RA, {
    feet = "Skulker's Poulaines +3"
})

-- Aeolian Edge TH
sets.AeolianTH = set_combine(sets.precast.WS['Aeolian Edge'], {
    feet = "Skulker's Poulaines +3"
})

-- Engaged with TH
sets.engaged.TH = set_combine(sets.engaged, sets.TreasureHunter)

---============================================================================
--- INITIALIZATION MESSAGE
---============================================================================

print('[THF] Equipment sets loaded successfully')

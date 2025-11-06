---============================================================================
--- WAR Equipment Sets - Complete Gear Configuration
---============================================================================
--- Equipment configurations for Warrior job.
---
--- Contains:
---   • Equipment definitions (Souverain set, Cichol capes)
---   • Weapon sets (Great Axes, Polearms, Swords, Axes, Maces)
---   • Idle sets (Base, PDT, Town)
---   • Engaged sets (Base, PDTTP, Normal, AM3)
---   • Precast JA sets (Berserk, Warcry, Aggressor, etc.)
---   • Precast WS sets (Ukko's Fury, Upheaval, Savage Blade, etc.)
---   • Movement sets (Base speed, Adoulin)
---   • Buff sets (Doom resistance)
---
--- @file    jobs/war/sets/war_sets.lua
--- @author  Kaories
--- @version 2.0
---============================================================================
--============================================================--

--                  EQUIPMENT DEFINITIONS                     --
--============================================================--
SouvHead = {
    name = 'Souv. Schaller +1',
    priority = 24,
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
}
SouvBody = {
    name = 'Souv. Cuirass +1',
    priority = 3,
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
}
SouvHands = {
    name = 'Souv. Handsch. +1',
    priority = 23,
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
}
SouvLegs = {
    name = 'Souv. Diechlings +1',
    priority = 16,
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
}
SouvFeet = {
    name = 'Souveran Schuhs +1',
    priority = 22,
    augments = {'HP+105', 'Enmity+9', 'Potency of "Cure" effect received +15%'}
}

Cichol = {
    stp = {
        name = "Cichol's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', '"Dbl.Atk."+10', 'Phys. dmg. taken-10%'}
    },
    ws1 = {
        name = "Cichol's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
    }
}

local MoonlightRing1 = {name = 'Moonlight Ring', bag = 'wardrobe 2'}
local MoonlightRing2 = {name = 'Moonlight Ring', bag = 'wardrobe 4'}

--============================================================--

--                      WEAPON SETS                          --
--============================================================--

--- Great Axes (Two-Handed)
sets['Ukonvasara'] = {
    main = 'Ukonvasara',
    sub = 'Utu Grip'
} -- Relic (AM3 TP reduction)
sets['Chango'] = {
    main = 'Chango',
    sub = 'Utu Grip'
} -- Empyrean (+500 TP bonus)
sets['Lycurgos'] = {
    main = 'Lycurgos',
    sub = 'Utu Grip'
} -- Mythic

--- Polearms (Two-Handed)
sets['Shining'] = {
    main = 'Shining One',
    sub = 'Utu Grip'
} -- Great Sword

--- Axes (One-Handed, Fencer-compatible with shield)
sets['Ikenga'] = {
    main = "Ikenga's Axe",
    sub = 'Blurred Shield +1'
}

--- Swords (One-Handed, Fencer-compatible with shield)
sets['Naegling'] = {
    main = 'Naegling',
    sub = 'Blurred Shield +1'
} -- Savage Blade (Fencer build with shield)

sets['NaeglingKC'] = {
    main = 'Naegling',
    sub = 'Kraken Club'
} -- Naegling + Kraken Club (multi-attack focus)

--- Maces (One-Handed, Fencer-compatible with shield)
sets['Loxotic'] = {
    main = 'Loxotic Mace +1',
    sub = 'Blurred Shield +1'
}

--- Utilities (Sub-slot only)
sets['Blurred Shield +1'] = {
    sub = 'Blurred Shield +1'
}
sets['Utu Grip'] = {
    sub = 'Utu Grip'
}
sets['Alber Strap'] = {
    sub = 'Alber Strap'
}
sets['Aurgelmir Orb +1'] = {
    ammo = 'Aurgelmir Orb +1'
}

--============================================================--

--                      IDLE SETS                            --
--============================================================--

--- Base Idle (Balanced TP gain + defensive stats)
sets.idle = {
    ammo = 'Coiste Bodhar',
    head = 'Hjarrandi Helm',
    body = 'Boii Lorica +3',
    hands = "Sakpata's Gauntlets",
    legs = 'Pumm. Cuisses +4',
    feet = 'Pumm. Calligae +4',
    neck = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Dedition Earring',
    ear2 = 'Boii Earring +1',
    ring1 = 'Niqmaddu Ring',
    ring2 = MoonlightRing2,
    back = Cichol.stp
}

--- PDT Idle (Physical damage reduction)
--- Used when HybridMode is set to PDT while idle.
sets.idle.PDT =
    set_combine(
    sets.idle,
    {
        head = "Sakpata's Helm",
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = "Sakpata's Leggings",
        ring1 = 'Defending Ring',
        ring2 = 'Gelatinous Ring +1',
        back = 'Moonlight Cape'
    }
)

--- Town Idle (Movement speed + aesthetics)
--- Applied when in safe city zones (not Dynamis).
sets.idle.Town =
    set_combine(
    sets.idle,
    {
        neck = 'Elite Royal Collar',
        feet = "Hermes' Sandals"
    }
)

--============================================================--

--                     ENGAGED SETS                          --
--============================================================--

--- Base Engaged (Balanced TP gain + multi-attack)
sets.engaged = {
    ammo = 'Coiste Bodhar',
    head = 'Hjarrandi Helm',
    body = 'Boii Lorica +3',
    hands = "Sakpata's Gauntlets",
    legs = 'Pumm. Cuisses +4',
    feet = 'Pumm. Calligae +4',
    neck = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Dedition Earring',
    ear2 = 'Boii Earring +1',
    ring1 = 'Niqmaddu Ring',
    ring2 = 'Moonlight Ring',
    back = Cichol.stp
}

--- PDTTP Engaged (Balanced PDT + TP for survivability)
--- Used as base for PDT mode and AM3 engaged set.
sets.engaged.PDTTP =
    set_combine(
    sets.engaged,
    {
        ammo = 'Coiste Bodhar',
        head = 'Hjarrandi Helm',
        body = 'Boii Lorica +3',
        hands = "Sakpata's Gauntlets",
        legs = 'Pumm. Cuisses +4',
        feet = 'Pumm. Calligae +4',
        neck = 'War. Beads +2',
        waist = 'Sailfi Belt +1',
        ear1 = 'Dedition Earring',
        ear2 = 'Boii Earring +1',
        ring1 = 'Niqmaddu Ring',
        ring2 = 'Moonlight Ring',
        back = Cichol.stp
    }
)

--- HybridMode: PDT (Uses PDTTP for maximum survivability)
--- Activated when HybridMode is set to PDT.
sets.engaged.PDT = sets.engaged.PDTTP

--- HybridMode: Normal (Pure DPS focused)
--- Activated when HybridMode is set to Normal.
sets.engaged.Normal =
    set_combine(
    sets.engaged,
    {
        ammo = 'Coiste Bodhar',
        head = 'Hjarrandi Helm',
        body = 'Boii Lorica +3',
        hands = "Sakpata's Gauntlets",
        legs = 'Pumm. Cuisses +4',
        feet = 'Pumm. Calligae +4',
        neck = 'War. Beads +2',
        waist = 'Sailfi Belt +1',
        ear1 = 'Dedition Earring',
        ear2 = 'Boii Earring +1',
        ring1 = 'Niqmaddu Ring',
        ring2 = 'Moonlight Ring',
        back = Cichol.stp
    }
)

--- Aftermath Level 3 Specialized (Used with Ukonvasara)
--- Automatically selected when Aftermath Lv.3 (buff ID 272) is active.
--- See: set_builder.lua select_engaged_base()
sets.engaged.PDTAFM3 =
    set_combine(
    sets.engaged.PDTTP,
    {
        ammo = 'Crepuscular Pebble',
        head = "Sakpata's Helm",
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = 'Boii Cuisses +3',
        feet = 'Boii Calligae +3',
        neck = 'War. Beads +2',
        waist = 'Ioskeha Belt +1',
        ear1 = 'Schere Earring',
        ear2 = 'Boii Earring +1',
        ring1 = 'Niqmaddu Ring',
        ring2 = 'Moonlight Ring',
        back = Cichol.stp
    }
)

--- Kraken Club Specialized (Used when Kraken Club is in sub-weapon)
--- Automatically selected when Kraken Club is equipped in sub-weapon slot.
--- Focuses on Store TP reduction to leverage Kraken Club's multi-attack proc rate.
--- See: set_builder.lua select_engaged_base()
sets.engaged.PDTKC =
    set_combine(
    sets.engaged.PDTTP,
    {
        ammo = 'Aurgelmir Orb +1',
        head = 'Boii Mask +3',
        body = 'Boii Lorica +3',
        hands = 'Tatena. Gote +1',
        legs = 'Tatena. Haidate +1',
        feet = 'Tatena. Sune. +1',
        neck = "Combatant's Torque",
        waist = 'Kentarch Belt +1',
        ear1 = 'Dedition Earring',
        ear2 = 'Crep. Earring',
        ring1 = 'Defending Ring',
        ring2 = MoonlightRing2,
        back = Cichol.stp
    }
)

--============================================================--
--                  PRECAST: JOB ABILITIES                   --
--============================================================--

sets.precast.JA = {}

--- Enmity Set (Maximizes enmity generation for tanking)
--- Used for Provoke and any enmity-focused situations.
sets.FullEnmity = {
    ammo = 'Sapience Orb',
    head = SouvHead,
    body = SouvBody,
    hands = SouvHands,
    legs = SouvLegs,
    feet = SouvFeet,
    neck = 'Moonlight Necklace',
    waist = 'Trance Belt',
    ear1 = 'Cryptic Earring',
    ear2 = 'Friomisi Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back = 'Earthcry Mantle'
}

--- Provoke (Enmity generation)
sets.precast.JA['Provoke'] = sets.FullEnmity

--- Jump Abilities (DRG subjob)
sets.precast.JA['Jump'] = sets.engaged.PDTTP
sets.precast.JA['High Jump'] = sets.engaged.PDTTP

--- Berserk (Enhances attack power + extends duration)
sets.precast.JA['Berserk'] =
    set_combine(
    sets.engaged,
    {
        body = 'Pumm. Lorica +3', -- Duration +18 seconds
        feet = 'Agoge Calligae +4' -- Duration +30 seconds
    }
)

--- Defender (Increases defense)
sets.precast.JA['Defender'] =
    set_combine(
    sets.engaged,
    {
        hands = 'Agoge Mufflers +3'
    }
)

--- Warcry (Boosts party attack + TP bonus from Savagery merits)
sets.precast.JA['Warcry'] =
    set_combine(
    sets.engaged,
    {
        head = 'Agoge Mask +4' -- Increases TP bonus (requires Savagery merits)
    }
)

--- Aggressor (Increases accuracy and attack speed + extends duration)
sets.precast.JA['Aggressor'] =
    set_combine(
    sets.engaged,
    {
        head = "Pummeler's Mask +3", -- Duration +18 seconds
        body = 'Agoge Lorica +3' -- Duration +30 seconds
    }
)

--- Blood Rage (Enhances critical hit rate)
sets.precast.JA['Blood Rage'] =
    set_combine(
    sets.engaged,
    {
        body = 'Boii Lorica +3'
    }
)

--- Tomahawk (Ranged attack)
sets.precast.JA['Tomahawk'] = {
    ammo = 'Thr. Tomahawk',
    feet = 'Agoge Calligae +4'
}

--============================================================--
--                  PRECAST: WEAPONSKILLS                    --
--============================================================--

--- Base Weaponskill (Used as foundation for all WS)
sets.precast.WS = {
    ammo = 'Knobkierrie',
    head = "Sakpata's Helm",
    body = "Sakpata's Plate",
    hands = 'Boii Mufflers +3',
    legs = 'Boii Cuisses +3',
    feet = "Sakpata's Leggings",
    neck = 'War. Beads +2',
    waist = 'Ioskeha Belt +1',
    ear1 = 'Thrud Earring',
    ear2 = 'Boii Earring +1',
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back = Cichol.ws1
}

-- Great Axe Weaponskills

--- Armor Break (Defense down)
sets.precast.WS['Armor Break'] =
    set_combine(
    sets.precast.WS,
    {
        neck = 'Fotia Gorget',
        waist = 'Fotia Belt'
    }
)

--- Ukko's Fury (Critical hit weaponskill)
sets.precast.WS["Ukko's Fury"] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Crepuscular Pebble',
        head = 'Boii Mask +3',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = 'Boii Cuisses +3',
        feet = 'Boii Calligae +3',
        neck = 'War. Beads +2',
        waist = 'Sailfi Belt +1',
        ear1 = 'Schere Earring',
        ear2 = 'Boii Earring +1',
        ring1 = 'Niqmaddu Ring',
        ring2 = "Cornelia's Ring",
        back = Cichol.ws1
    }
)

sets.precast.WS['Upheaval'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Knobkierrie',
        head = 'Boii Mask +3',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = 'Boii Cuisses +3',
        feet = "Sakpata's Leggings",
        neck = 'Null Loop',
        waist = 'Ioskeha Belt +1',
        ear1 = 'Schere Earring',
        ear2 = 'Thrud Earring',
        ring1 = 'Niqmaddu Ring',
        ring2 = "Cornelia's Ring",
        back = Cichol.ws1
    }
)

sets.precast.WS['Fell Cleave'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Crepuscular Pebble',
        head = 'Boii Mask +3',
        body = "Sakpata's Plate",
        hands = 'Boii Mufflers +3',
        legs = 'Boii Cuisses +3',
        feet = 'Nyame Sollerets',
        neck = 'War. Beads +2',
        waist = 'Fotia Belt',
        ear2 = 'Thrud Earring',
        ear1 = 'Schere Earring',
        ring1 = 'Defending Ring',
        ring2 = "Cornelia's Ring",
        back = Cichol.ws1
    }
)

sets.precast.WS["King's Justice"] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Crepuscular Pebble',
        head = 'Boii Mask +3',
        body = "Sakpata's Plate",
        hands = 'Boii Mufflers +3',
        legs = 'Boii Cuisses +3',
        feet = "Sakpata's Leggings",
        neck = 'War. Beads +2',
        waist = 'Sailfi Belt +1',
        ear1 = 'Schere Earring',
        ear2 = 'Boii Earring +1',
        ring1 = 'Defending Ring',
        ring2 = "Cornelia's Ring",
        back = Cichol.ws1
    }
)

-- Polearm Weaponskills

--- Impulse Drive (Multi-hit physical)
sets.precast.WS['Impulse Drive'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Yetshila +1',
        head = 'Boii Mask +3',
        neck = 'War. Beads +2',
        ear1 = 'Thrud Earring',
        ear2 = 'Boii Earring +1',
        body = "Sakpata's Plate",
        hands = 'Boii Mufflers +3',
        ring1 = 'Defending Ring',
        ring2 = "Cornelia's Ring",
        waist = 'Sailfi Belt +1',
        legs = 'Boii Cuisses +3',
        feet = 'Boii Calligae +3',
        back = Cichol.ws1
    }
)

sets.precast.WS['Stardiver'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Crepuscular Pebble',
        head = 'Boii Mask +3',
        neck = 'War. Beads +2',
        ear1 = 'Schere Earring',
        ear2 = 'Boii Earring +1',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        ring1 = 'Niqmaddu Ring',
        ring2 = "Cornelia's Ring",
        waist = 'Fotia Belt',
        legs = 'Boii Cuisses +3',
        feet = 'Boii Calligae +3',
        back = Cichol.ws1
    }
)

-- Sword Weaponskills

--- Savage Blade (STR+MND physical + magical hybrid)
sets.precast.WS['Savage Blade'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Crepuscular Pebble',
        head = 'Agoge Mask +4',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = 'Nyame Sollerets',
        neck = 'War. Beads +2',
        waist = 'Sailfi Belt +1',
        ear1 = 'Thrud Earring',
        ear2 = 'Odnowa Earring +1',
        ring1 = 'Sroda Ring',
        ring2 = "Cornelia's ring"
    }
)

-- Axe Weaponskills

--- Calamity (STR physical weaponskill)
sets.precast.WS['Calamity'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Crepuscular Pebble',
        head = 'Agoge Mask +4',
        body = "Sakpata's Plate",
        hands = "Sakpata's Gauntlets",
        legs = "Sakpata's Cuisses",
        feet = 'Nyame Sollerets',
        neck = 'War. Beads +2',
        waist = 'Sailfi Belt +1',
        ear1 = 'Thrud Earring',
        ear2 = 'Odnowa Earring +1',
        ring1 = 'Sroda Ring',
        ring2 = "Cornelia's ring"
    }
)

-- Club/Mace Weaponskills

--- Judgment (MND magical weaponskill)
sets.precast.WS['Judgment'] =
    set_combine(
    sets.precast.WS,
    {
        legs = {
            name = 'Nyame Flanchard',
            augments = {'Path: B'}
        },
        feet = {
            name = 'Nyame Sollerets',
            augments = {'Path: B'}
        },
        ring2 = 'Defending Ring'
    }
)

--============================================================--

--                     MOVEMENT SETS                         --
--============================================================--

--- Base Movement Speed (+12% from Hermes' Sandals)
--- Applied when moving in idle state only (never in combat).
sets.MoveSpeed = {
    feet = "Hermes' Sandals"
}

--- Adoulin Movement (City-specific speed boost)
--- Applied when in Western/Eastern Adoulin zones.
sets.Adoulin =
    set_combine(
    sets.MoveSpeed,
    {
        body = "Councilor's Garb"
    }
)

--============================================================--

--                       BUFF SETS                           --
--============================================================--

sets.buff = {}

--- Doom Resistance (Removes Doom status effect)
--- Equip when afflicted with Doom to cure it faster.
sets.buff.Doom = {
    neck = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    ring2 = "Blenmot's Ring +1",
    waist = 'Gishdubar Sash'
}

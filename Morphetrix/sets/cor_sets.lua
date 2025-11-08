---============================================================================
--- COR Equipment Sets - Ultimate Corsair Gunslinger Configuration
---============================================================================
--- Complete equipment configuration for Corsair support/DPS hybrid role with
--- optimized buff support and ranged damage across all situations.
---
--- Features:
---   • Phantom Roll optimization (Lanun +3, Chasseur +3, Rostam augmented)
---   • Quick Draw magic damage (Malignance set, Magic Attack Bonus)
---   • Ranged attack excellence (Snapshot, Rapid Shot, Store TP)
---   • Melee DPS capability (Dual Wield support, Malignance hybrid)
---   • Savage Blade weaponskill (Nyame +2, Camulus WSD cape)
---   • Roll-specific gear (Caster's, Courser's, Blitzer's, Tactician's, Allies')
---   • Movement speed optimization (Carmine Cuisses +1)
---   • Hybrid survivability (PDT sets with Malignance)
---
--- Architecture:
---   • Equipment definitions (Chirich rings, wardrobe management)
---   • Weapon sets (Naegling, Anarchy, Compensator, Rostam)
---   • Idle sets (Refresh, PDT, Regen)
---   • Engaged sets (Normal, PDT, Dual Wield variants)
---   • Precast sets (Job Abilities, Weaponskills, Ranged Attack)
---   • Midcast sets (Ranged Attack continuation)
---   • Movement sets (Base speed, Adoulin)
---   • Buff sets (Doom resistance)
---
--- @file    jobs/cor/sets/cor_sets.lua
--- @author  Morphetrix
--- @version 3.0 - Standardized Organization
--- @date    Updated: 2025-10-15
---============================================================================
--============================================================--

--                  EQUIPMENT DEFINITIONS                     --
--============================================================--
-- Chirich Rings in different wardrobes (prevents "already equipped" errors)
ChirichRing1 = {
    name = "Chirich Ring +1",
    bag = "wardrobe 1"
}
ChirichRing2 = {
    name = "Chirich Ring +1",
    bag = "wardrobe 2"
}

--============================================================--

--                      WEAPON SETS                          --
--============================================================--

-- Main + Sub Weapon Sets (combined like DNC/WAR for automatic equip)
sets['Naegling'] = {
    main = "Naegling",
    sub = "Demers. Degen +1"  -- Default sub for melee
}

-- Range Weapon Sets (separate since COR has ranged focus)
sets['Anarchy'] = {
    range = "Anarchy +2"
}

sets['Compensator'] = {
    range = "Compensator"
}

--============================================================--

--                      IDLE SETS                            --
--============================================================--

-- Base Idle
sets.idle = {}
sets.idle.Normal = {
    -- Weapons applied by SetBuilder based on subjob (DW for NIN/DNC, single for others)
    ammo = "Bronze Bullet",
    head = "Lanun Tricorne +3",
    body = "Adamantite Armor",
    hands = "Chasseur's Gants +3",
    legs = {
        name = "Carmine Cuisses +1",
        augments = {'MP+80', 'INT+12', 'MND+12'}
    },
    feet = "Lanun bottes +3",
    neck = "Regal Necklace",
    waist = "Plat. Mog. Belt",
    left_ear = "Ethereal Earring",
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Luzaf's Ring",
    right_ring = "Woltaris Ring",
    back = "Camulus's Mantle"
}

-- PDT Idle (Physical Damage Taken -)
sets.idle.PDT = set_combine(sets.idle.Normal, {
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    feet = "Malignance Boots",
    left_ring = "Defending Ring",
    right_ring = ChirichRing1
})

-- Refresh Idle (MP recovery)
sets.idle.Refresh = set_combine(sets.idle.Normal, {
    -- Refresh gear
})

--============================================================--

--                     ENGAGED SETS                          --
--============================================================--

-- Base Engaged
sets.engaged = {}

sets.engaged.Normal = {
    -- Weapons applied by SetBuilder based on subjob (DW for NIN/DNC, single for others)
    ammo = "Bronze Bullet",
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Chas. Culottes +3",
    feet = "Malignance Boots",
    neck = "Iskur Gorget",
    waist = {
        name = "Sailfi Belt +1",
        augments = {'Path: A'}
    },
    left_ear = "Dedition Earring",
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Defending Ring",
    right_ring = "Chirich Ring +1",
    back = "Camulus's Mantle"
}

-- PDT Melee (Hybrid)
sets.engaged.PDT = set_combine(sets.engaged.Normal, {
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    feet = "Malignance Boots",
    left_ear = "Crepuscular Earring",
    left_ring = "Defending Ring",
    waist = "Kentarch Belt +1",
    back = "Null Shawl"
})

-- Dual Wield Engaged
sets.engaged.DW = set_combine(sets.engaged.Normal, {
    -- Dual Wield gear (for /NIN)
    -- ear1 = "Suppanomimi",
    -- ear2 = "Eabani Earring",
})

sets.engaged.DW.PDT = set_combine(sets.engaged.DW, {
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    feet = "Malignance Boots",
    left_ring = "Defending Ring",
    back = "Null Shawl"
})

--============================================================--
--                  PRECAST: JOB ABILITIES                   --
--============================================================--

sets.precast = {}
sets.precast.JA = {}

-- Phantom Roll (Base set for all rolls)
-- Mote looks for sets.precast.CorsairRoll when spell.type == 'CorsairRoll'
sets.precast.CorsairRoll = {
    main = {
        name = "Rostam",
        augments = {'Path: C'}
    },
    range = "Compensator",
    head = "Lanun Tricorne +3",
    body = "Adamantite Armor",
    hands = "Chasseur's Gants +3",
    legs = {
        name = "Carmine Cuisses +1",
        augments = {'MP+80', 'INT+12', 'MND+12'}
    },
    feet = "Lanun bottes +3",
    neck = "Regal Necklace",
    waist = "Plat. Mog. Belt",
    left_ear = "Ethereal Earring",
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Luzaf's Ring",
    right_ring = "Kuchekula Ring",
    back = "Camulus's Mantle"
}

-- Double-Up is handled dynamically in COR_PRECAST.lua
-- It equips the same set as the last roll used (including specific roll gear)

-- Specific roll overrides (gear that enhances specific rolls)
sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {
    legs = "Chas. Culottes +3"
})

sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {
    feet = "Chasseur's Bottes +1"
})

sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {
    head = "Chass. Tricorne +2"
})

sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {
    body = "Chasseur's Frac +2"
})

sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {
    hands = "Chasseur's Gants +3"
})

-- Quick Draw (CorsairShot - magic damage JA)
-- Mote looks for sets.precast.CorsairShot when spell.type == 'CorsairShot'
sets.precast.CorsairShot = {
    -- Magic Attack Bonus + Magic Accuracy for Quick Draw shots
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Malignance Boots"
}

-- Quick Draw element variants (optional - enhance specific shots)
-- sets.precast.CorsairShot['Fire Shot'] = set_combine(sets.precast.CorsairShot, {})
-- sets.precast.CorsairShot['Ice Shot'] = set_combine(sets.precast.CorsairShot, {})
-- etc.

-- Snake Eye (guarantees lucky number on next roll)
sets.precast.JA['Snake Eye'] = {
    legs = "Lanun Trews +3"
}

-- Fold (restores 1 roll charge)
sets.precast.JA['Fold'] = {
    hands = "Lanun Gants +3"
}

-- Wild Card (resets all roll timers)
sets.precast.JA['Wild Card'] = {
    feet = "Lanun Bottes +3"
}

-- Random Deal (resets all COR JA timers)
sets.precast.JA['Random Deal'] = {
    body = "Lanun Frac +3"
}

-- Ranged Attack Precast (Snapshot/Rapid Shot)
sets.precast.RA = {
    -- Snapshot + Rapid Shot gear
    head = "Malignance Chapeau",
    body = "Laksa. frac +4",
    hands = "Chasseur's Gants +3",
    legs = {
        name = "Carmine Cuisses +1",
        augments = {'MP+80', 'INT+12', 'MND+12'}
    },
    feet = "Malignance Boots",
    neck = "Iskur Gorget",
    waist = {
        name = "Sailfi Belt +1",
        augments = {'Path: A'}
    },
    left_ear = "Dedition Earring",
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Defending Ring",
    right_ring = "Chirich Ring +1",
    back = "Camulus's Mantle"
}

--============================================================--
--                  PRECAST: WEAPONSKILLS                    --
--============================================================--

sets.precast.WS = {}

-- Generic weaponskill set (used as base for all WSs)
sets.precast.WS = {
    head = {
        name = "Nyame Helm",
        augments = {'Path: B'}
    },
    body = "Laksa. frac +4",
    hands = "Chasseur's Gants +3",
    legs = {
        name = "Nyame Flanchard",
        augments = {'Path: B'}
    },
    feet = {
        name = "Nyame Sollerets",
        augments = {'Path: B'}
    },
    neck = "Rep. Plat. Medal",
    waist = {
        name = "Sailfi Belt +1",
        augments = {'Path: A'}
    },
    left_ear = {
        name = "Moonshade Earring",
        augments = {'Mag. Acc.+4', 'TP Bonus +250'}
    },
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Defending Ring",
    right_ring = "Chirich Ring +1",
    back = {
        name = "Camulus's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
    }
}

-- Savage Blade (Melee WS)
sets.precast.WS['Savage Blade'] = {
    head = {
        name = "Nyame Helm",
        augments = {'Path: B'}
    },
    body = "Laksa. frac +4",
    hands = "Chasseur's Gants +3",
    legs = {
        name = "Nyame Flanchard",
        augments = {'Path: B'}
    },
    feet = {
        name = "Nyame Sollerets",
        augments = {'Path: B'}
    },
    neck = "Rep. Plat. Medal",
    waist = {
        name = "Sailfi Belt +1",
        augments = {'Path: A'}
    },
    left_ear = {
        name = "Moonshade Earring",
        augments = {'Mag. Acc.+4', 'TP Bonus +250'}
    },
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Defending Ring",
    right_ring = "Chirich Ring +1",
    back = {
        name = "Camulus's Mantle",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%', 'Phys. dmg. taken-10%'}
    }
}

--============================================================--

--                     MIDCAST SETS                          --
--============================================================--

sets.midcast = {}

-- Ranged Attack (bullet flight time - RA gear)
sets.midcast.RA = {
    -- Ranged Attack gear (R.Acc, R.Atk, Store TP)
    head = "Malignance Chapeau",
    body = "Malignance Tabard",
    hands = "Malignance Gloves",
    legs = "Malignance Tights",
    feet = "Malignance Boots",
    neck = "Iskur Gorget",
    waist = {
        name = "Sailfi Belt +1",
        augments = {'Path: A'}
    },
    left_ear = "Dedition Earring",
    right_ear = {
        name = "Chas. Earring +1",
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+15', 'Mag. Acc.+15', 'Crit.hit rate+5'}
    },
    left_ring = "Defending Ring",
    right_ring = "Chirich Ring +1",
    back = "Camulus's Mantle"
}

-- Note: Phantom Rolls and Quick Draw are JA (instantaneous)
-- They have NO midcast phase - handled in precast.JA only

--============================================================--

--                     MOVEMENT SETS                         --
--============================================================--

-- Base Movement Speed
sets.MoveSpeed = {
    legs = "Carmine Cuisses +1" -- Movement +18%
}

-- Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb"
})

--============================================================--

--                       BUFF SETS                           --
--============================================================--

sets.buff = {}

-- Doom removal
sets.buff.Doom = {
    -- neck = "Nicander's Necklace",
    -- ring1 = "Purity Ring",
    -- ring2 = "Blenmot's Ring +1",
    -- waist = "Gishdubar Sash",
}

print('[COR] Equipment sets loaded')

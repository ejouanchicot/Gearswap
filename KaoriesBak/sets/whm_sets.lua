---============================================================================
--- WHM Equipment Sets - Complete Gear Configuration
---============================================================================
--- Complete equipment configuration for White Mage healer/support role.
---
--- Features:
---   • Cure optimization (Potency vs SIRD modes via CureMode state)
---   • Enhancing Magic duration maximization (Telchine full set)
---   • Status removal optimization (Cursna skill, Yagrush)
---   • Fast Cast maximization (48%+ Fast Cast for all spells)
---   • Idle modes (PDT defensive vs Refresh MP recovery)
---   • Divine Magic support (Banish, Holy for solo content)
---   • Weaponskill sets (Flash Nova, Mystic Boon for club)
---
--- Architecture:
---   • Idle sets (PDT, Refresh, Town)
---   • Engaged sets (Normal, PDT for rare melee situations)
---   • Precast sets (Job abilities, Fast Cast, Weaponskills)
---   • Midcast sets (Cure, Enhancing, Divine, Enfeebling, Status Removal)
---   • Movement sets (Kiting speed)
---   • Buff sets (Divine Caress status removal enhancement)
---
--- @file    sets/whm_sets.lua
--- @author  Kaories
--- @version 2.0 - Reorganized to standard order
--- @date    Updated: 2025-10-21
--- @source  Timara WHM.lua (equipment data)
---============================================================================

--============================================================--

--                      IDLE SETS                             --
--============================================================--

sets.idle = {}

-- PDT idle (defense priority - DEFAULT for safety)
sets.idle.PDT = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Ebers Duckbills +3',
    neck = 'Loricate Torque +1',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Etiolation Earring',
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = 'Defending Ring',
    right_ring = 'Stikini Ring +1',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- Refresh idle (MP recovery priority - for safe areas)
sets.idle.Refresh = {
    ammo = 'Homiliary',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = 'Adamantite Armor',
    hands = {
        name = 'Chironic Gloves',
        augments = {'AGI+12', 'Accuracy+2', '"Refresh"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6'}
    },
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = {
        name = 'Chironic Slippers',
        augments = {'Mag. Acc.+12', 'DEX+8', '"Refresh"+2', 'Mag. Acc.+3 "Mag.Atk.Bns."+3'}
    },
    neck = {name = 'Loricate Torque +1', augments = {'Path: A'}},
    waist = 'Plat. Mog. Belt',
    left_ear = 'Etiolation Earring',
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = 'Defending Ring',
    right_ring = 'Stikini Ring +1',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- Town idle (Refresh gear)
sets.idle.Town = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = {name = 'Chironic Hat', augments = {'Accuracy+18', 'Pet: INT+5', '"Refresh"+2'}},
    body = 'Ebers Bliaut +3',
    hands = {
        name = 'Chironic Gloves',
        augments = {'AGI+12', 'Accuracy+2', '"Refresh"+2', 'Mag. Acc.+6 "Mag.Atk.Bns."+6'}
    },
    legs = 'Assid. Pants +1',
    feet = {
        name = 'Chironic Slippers',
        augments = {'Mag. Acc.+12', 'DEX+8', '"Refresh"+2', 'Mag. Acc.+3 "Mag.Atk.Bns."+3'}
    },
    neck = 'Loricate Torque +1',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Etiolation Earring',
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = 'Defending Ring',
    right_ring = 'Stikini Ring +1',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- Latent refresh gear (MP < 51%)
sets.latent_refresh = {}

--============================================================--

--                     ENGAGED SETS                           --
--============================================================--

sets.engaged = {}

-- Melee set (rare for WHM but available)
sets.engaged.Normal = {
    main = 'Maxentius',
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = 'Aya. Zucchetto +2',
    body = 'Ayanmo Corazza +2',
    hands = 'Aya. Manopolas +2',
    legs = 'Aya. Cosciales +2',
    feet = 'Aya. Gambieras +2',
    neck = 'Null Loop',
    waist = 'Null Belt',
    left_ear = 'Telos Earring',
    right_ear = 'Mache Earring +1',
    left_ring = 'Rajas Ring',
    right_ring = 'Ilabrat Ring',
    back = 'Null Shawl'
}

-- Melee PDT (defensive melee)
sets.engaged.PDT = {
    main = 'Maxentius',
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = 'Aya. Zucchetto +2',
    body = 'Ayanmo Corazza +2',
    hands = 'Aya. Manopolas +2',
    legs = 'Aya. Cosciales +2',
    feet = 'Aya. Gambieras +2',
    neck = 'Null Loop',
    waist = 'Null Belt',
    left_ear = 'Telos Earring',
    right_ear = 'Mache Earring +1',
    left_ring = 'Rajas Ring',
    right_ring = 'Ilabrat Ring',
    back = 'Null Shawl'
}

--============================================================--
--                   PRECAST: JOB ABILITIES                   --
--============================================================--

sets.precast = {}
sets.precast.JA = {}

-- Benediction (WHM 1hr)
sets.precast.JA['Benediction'] = {
    body = 'Piety Briault' -- Enhances Benediction effect
}

-- Devotion (MP transfer - maximize HP for more MP transferred)
-- Formula: MP transferred = HP * 0.425 (with 5 merits + Piety Cap +3)
sets.precast.JA['Devotion'] = {
    -- Maximize HP in all other slots for bigger MP transfer
    main = 'Septoptic',
    sub = 'Culminus',
    ammo = 'Ombre Tathlum +1',
    head = 'Piety Cap +3', -- +50% MP transferred (10% per merit level, 5 merits max)
    body = 'Adamantite Armor',
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Theo. Duckbills +3',
    neck = 'Null Loop',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Etiolation Earring',
    right_ear = 'Odnowa Earring',
    left_ring = {name = 'Gelatinous Ring +1', augments = {'Path: A'}},
    right_ring = "K'ayres Ring",
    back = 'Moonbeam Cape'
}

-- Martyr (HP transfer - maximize HP for more HP restored)
-- Formula: HP restored = HP * 0.75 (with 5 merits + Piety Mitts +3)
-- HP sacrificed = HP * 0.25 (always, mitigated by Stoneskin)
sets.precast.JA['Martyr'] = {
    -- Maximize HP in all slots for bigger HP transfer
    main = 'Septoptic',
    sub = 'Culminus',
    ammo = 'Ombre Tathlum +1',
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = 'Adamantite Armor',
    hands = 'Piety Mitts +3', -- +50% HP restored (10% per merit level, 5 merits max)
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Theo. Duckbills +3',
    neck = 'Null Loop',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Etiolation Earring',
    right_ear = 'Odnowa Earring',
    left_ring = {name = 'Gelatinous Ring +1', augments = {'Path: A'}},
    right_ring = "K'ayres Ring",
    back = 'Moonbeam Cape'
}

-- Afflatus Solace (Cure-focused stance)
-- Effects: Stoneskin on Cure spells, Bar-spell MDB+, Sacrifice removes 7 effects
-- Note: Ebers Bliaut +3 equipped in midcast for Cure/Barspell bonuses
sets.precast.JA['Afflatus Solace'] = {}

-- Afflatus Misery (Damage-focused stance)
-- Effects: Cura potency boost, Banish damage boost, Esuna removes 2 effects, Auspice grants Enlight
sets.precast.JA['Afflatus Misery'] = {}

--============================================================--
--                    PRECAST: FAST CAST                      --
--============================================================--

sets.precast.FC = {}

-- Generic Fast Cast (all spells - 48% Fast Cast)
sets.precast.FC = {
    main = 'C. Palug Hammer',
    sub = "Chanter's Shield",
    ammo = 'Impatiens',
    head = 'Ebers cap +3',
    body = 'Inyanga Jubbah +2',
    hands = {
        name = 'Fanatic Gloves',
        augments = {'MP+40', 'Healing magic skill +4', '"Conserve MP"+3', '"Fast Cast"+4'}
    },
    legs = {name = 'Lengo Pants', augments = {'INT+5', 'Mag. Acc.+4', '"Mag.Atk.Bns."+1', '"Refresh"+1'}},
    feet = 'Regal Pumps +1',
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Witful Belt',
    left_ear = 'Loquac. Earring',
    right_ear = 'Malignance Earring',
    left_ring = "Naji's Loop",
    right_ring = 'Kishar Ring',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- Healing Magic Fast Cast
sets.precast.FC['Healing Magic'] =
    set_combine(
    sets.precast.FC,
    {
        legs = 'Ebers Pant. +3'
    }
)

-- Cure Fast Cast
sets.precast.FC.Cure = set_combine(sets.precast.FC['Healing Magic'], {})
sets.precast.FC.Curaga = sets.precast.FC.Cure
sets.precast.FC.CureSolace = sets.precast.FC.Cure

-- Status Removal Fast Cast
sets.precast.FC.StatusRemoval = set_combine(sets.precast.FC['Healing Magic'], {})

-- Enhancing Magic Fast Cast
sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {})

-- Stoneskin Fast Cast (special gear)
sets.precast.FC['Stoneskin'] =
    set_combine(
    sets.precast.FC['Enhancing Magic'],
    {
        waist = 'Siegel Sash',
        right_ear = 'Earthcry Earring'
    }
)

--============================================================--
--                   PRECAST: WEAPONSKILLS                    --
--============================================================--

sets.precast.WS = {}

-- Default weaponskill set
sets.precast.WS = {
    sub = 'Ammurapi Shield',
    ammo = "Oshasha's Treatise",
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = {name = 'Nyame Sollerets', augments = {'Path: B'}},
    neck = 'Fotia Gorget',
    waist = 'Snow Belt',
    left_ear = {name = 'Moonshade Earring', augments = {'Attack+4', 'TP Bonus +250'}},
    right_ear = 'Mache Earring +1',
    left_ring = 'Karieyh Ring',
    right_ring = 'Ilabrat Ring',
    back = 'Aptitude Mantle +1'
}

-- Mystic Boon (club WS)
sets.precast.WS['Mystic Boon'] =
    set_combine(
    sets.precast.WS,
    {
        neck = 'Fotia Gorget'
    }
)

-- Flash Nova (magical WS)
sets.precast.WS['Flash Nova'] = {
    head = 'Nahtirah Hat',
    neck = 'Stoicheion Medal',
    ear1 = 'Friomisi Earring',
    ear2 = "Hecate's Earring",
    body = 'Vanir Cotehardie',
    hands = 'Yaoyotl Gloves',
    ring1 = "Naji's loop",
    ring2 = 'Strendu Ring',
    back = 'Toro Cape',
    waist = 'Thunder Belt',
    legs = 'Gendewitha Spats',
    feet = 'Gendewitha Galoshes'
}

-- Waltz set (placeholder)
sets.precast.Waltz = {}

--============================================================--

--                      MIDCAST SETS                          --
--============================================================--

sets.midcast = {}

-- Fast recast (interruptible spells)
sets.midcast.FastRecast = {}

-- ==========================================================================
-- CURE SETS
-- ==========================================================================

-- CureSolace (Afflatus Solace active - always SIRD)
-- Afflatus Solace already provides +cure potency, so prioritize SIRD
sets.midcast.CureSolace = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    ammo = 'Ombre Tathlum +1',
    head = 'Kaykaus Mitra +1',
    body = 'Ebers Bliaut +3',
    hands = 'Theophany Mitts +3',
    legs = 'Ebers Pant. +3',
    feet = 'Kaykaus Boots +1',
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Eschan Stone',
    left_ear = 'Nourish. Earring +1',
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = "Naji's Loop",
    right_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}},
    back = {
        name = "Alaunus's Cape",
        augments = {'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%'}
    }
}

-- CureSIRD (SIRD mode - for casting under attack, non-Solace)
-- Same as CureSolace but available without Afflatus Solace active
sets.midcast.CureSIRD = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    sub = 'Culminus',
    ammo = 'Staunch Tathlum +1',
    head = {
        name = 'Kaykaus Mitra +1',
        augments = {'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%'}
    },
    body = 'Adamantite Armor',
    hands = 'Theophany Mitts +3',
    legs = 'Ebers Pant. +3',
    feet = {
        name = 'Kaykaus Boots +1',
        augments = {'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%'}
    },
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Emphatikos Rope',
    left_ear = {name = 'Nourish. Earring +1', augments = {'Path: A'}},
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = {name = 'Gelatinous Ring +1', augments = {'Path: A'}},
    right_ring = 'Evanescence Ring',
    back = {
        name = "Alaunus's Cape",
        augments = {'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%'}
    }
}

-- Cure (Potency mode - party/alliance cures - maximum cure potency)
sets.midcast.Cure = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    }, --Cure potency II -> 2
    sub = 'Ammurapi Shield', --Cure potency II -> 0
    ammo = 'Ombre Tathlum +1', --Cure potency II -> 0
    head = 'Kaykaus Mitra +1', --Cure potency II -> 2 ensemble
    body = 'Theo. Bliaut +3', --Cure potency II -> 6
    hands = 'Theophany Mitts +3', --Cure potency II -> 4
    legs = 'Ebers Pant. +3', --Cure potency II -> 0
    feet = 'Kaykaus Boots +1', --Cure potency II -> 0
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}}, --Cure potency II -> 0
    waist = 'Eschan Stone', --Cure potency II -> 0
    left_ear = 'Nourish. Earring +1', --Cure potency II -> 0
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    }, --Cure potency II -> 0
    left_ring = "Naji's Loop", --Cure potency II -> 1
    right_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}}, --Cure potency II -> 0
    back = {
        name = "Alaunus's Cape",
        augments = {'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%'}
    } --Cure potency II -> 0
} -- TOTAL Cure Potency II: 15

-- Curaga (SIRD-focused for AOE healing - different from Cure!)
-- Reference file uses SIRD gear for Curaga (Adamantite, Culminus, etc.)
sets.midcast.Curaga = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    ammo = 'Ombre Tathlum +1',
    head = 'Kaykaus Mitra +1',
    body = 'Theo. Bliaut +3',
    hands = 'Theophany Mitts +3',
    legs = 'Ebers Pant. +3',
    feet = 'Kaykaus Boots +1',
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Eschan Stone',
    left_ear = 'Nourish. Earring +1',
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damagetaken-6%', 'STR+9 MND+9'}
    },
    left_ring = "Naji's Loop",
    right_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}},
    back = {
        name = "Alaunus's Cape",
        augments = {'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%'}
    }
}

-- CuragaSIRD (SIRD mode - for casting Curaga under attack)
sets.midcast.CuragaSIRD = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    sub = 'Culminus',
    ammo = 'Staunch Tathlum +1',
    head = {
        name = 'Kaykaus Mitra +1',
        augments = {'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%'}
    },
    body = 'Adamantite Armor',
    hands = 'Theophany Mitts +3',
    legs = 'Ebers Pant. +3',
    feet = {
        name = 'Kaykaus Boots +1',
        augments = {'MP+80', 'Spell interruption rate down +12%', '"Cure" spellcasting time -7%'}
    },
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Emphatikos Rope',
    left_ear = {name = 'Nourish. Earring +1', augments = {'Path: A'}},
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = 'Evanescence Ring',
    right_ring = {name = 'Gelatinous Ring +1', augments = {'Path: A'}},
    back = {
        name = "Alaunus's Cape",
        augments = {'MND+20', 'Eva.+20 /Mag. Eva.+20', 'MND+10', '"Cure" potency +10%', 'Damage taken-5%'}
    }
}

-- CureMelee (placeholder - rarely used for WHM)
sets.midcast.CureMelee = {}

-- ==========================================================================
-- STATUS REMOVAL
-- ==========================================================================

-- Cursna (Cursna skill priority - specific set overrides StatusRemoval)
sets.midcast['Cursna'] = {
    main = 'Yagrush', -- Best Cursna tool
    ammo = 'Staunch Tathlum +1',
    head = 'Hyksos Khat',
    body = 'Ebers Bliaut +3',
    hands = {
        name = 'Fanatic Gloves',
        augments = {'MP+40', 'Healing magic skill +4', '"Conserve MP"+3', '"Fast Cast"+4'}
    },
    legs = 'Th. Pant. +3',
    feet = {name = 'Vanya Clogs', augments = {'"Cure" potency +5%', '"Cure" spellcasting time -15%', '"Conserve MP"+6'}},
    neck = 'Debilis Medallion',
    waist = 'Embla Sash',
    left_ear = {name = 'Nourish. Earring +1', augments = {'Path: A'}},
    right_ear = {
        name = 'Ebers Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+17', 'Mag. Acc.+17', 'Damage taken-6%', 'STR+9 MND+9'}
    },
    left_ring = "Haoma's Ring",
    right_ring = 'Ephedra Ring',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- StatusRemoval (Paralyna, Erase, etc.)
sets.midcast.StatusRemoval = {
    main = 'Yagrush',
    head = 'Ebers cap +3',
    legs = 'Orison Pantaloons +2'
}

-- ==========================================================================
-- ENHANCING MAGIC
-- ==========================================================================

-- Generic Enhancing Magic (duration gear)
sets.midcast['Enhancing Magic'] = {
    main = 'Gada',
    sub = 'Ammurapi Shield',
    head = {name = 'Telchine Cap', augments = {'"Fast Cast"+3', 'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +9'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = 'Theo. Duckbills +3',
    neck = 'Melic Torque',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    left_ring = 'Stikini Ring +1',
    back = 'Veela Cape'
}

-- Haste (duration)
sets.midcast['Haste'] = set_combine(sets.midcast['Enhancing Magic'], {})

-- Sneak (duration)
sets.midcast['Sneak'] = set_combine(sets.midcast['Enhancing Magic'], {})

-- Invisible (duration)
sets.midcast['Invisible'] = set_combine(sets.midcast['Enhancing Magic'], {})

-- Stoneskin (special gear)
sets.midcast['Stoneskin'] = {
    main = {name = 'Gada', augments = {'Enh. Mag. eff. dur. +6', 'CHR+3', 'Mag. Acc.+12', 'DMG:+2'}},
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = {name = 'Telchine Cap', augments = {'"Fast Cast"+3', 'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +9'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = 'Shedir Seraweels',
    feet = 'Theo. Duckbills +3',
    neck = 'Nodens Gorget',
    waist = 'Siegel Sash',
    left_ear = 'Regal Earring',
    right_ear = 'Earthcry Earring',
    right_ring = "Naji's Loop",
    left_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}},
    back = 'Veela Cape'
}

-- Aquaveil (spell interruption reduction)
sets.midcast['Aquaveil'] = {
    main = 'Vadose Rod',
    sub = 'Ammurapi Shield',
    head = 'Chironic Hat',
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +9'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = 'Shedir Seraweels',
    feet = 'Theo. Duckbills +3',
    neck = 'Melic Torque',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    left_ring = 'Stikini Ring +1',
    back = 'Veela Cape'
}

-- Refresh (duration)
sets.midcast['Refresh'] = set_combine(sets.midcast['Enhancing Magic'], {})

-- Bar-Element spells (WHM specialty)
sets.midcast.BarElement = {
    main = 'Gada',
    sub = 'Ammurapi Shield',
    head = 'Ebers Cap +3',
    body = 'Ebers Bliaut +3',
    hands = 'Ebers Mitts +3',
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = 'Ebers Duckbills +3',
    neck = 'Melic Torque',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    left_ring = 'Stikini Ring +1',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- Auspice (WHM-specific buff)
sets.midcast['Auspice'] = {
    main = 'Gada',
    sub = 'Ammurapi Shield',
    head = {name = 'Telchine Cap', augments = {'"Fast Cast"+3', 'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +9'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = 'Ebers Duckbills +3',
    neck = 'Melic Torque',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    left_ring = 'Stikini Ring +1'
}

-- Regen (potency and duration)
sets.midcast['Regen'] = {
    main = 'Bolelabunga',
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = {name = 'Telchine Cap', augments = {'"Fast Cast"+3', 'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Piety Bliaut +3', augments = {'Enhances "Benediction" effect'}},
    hands = 'Ebers mitts +3',
    legs = 'Th. Pant. +3',
    feet = 'Theo. Duckbills +3',
    neck = 'Melic Torque',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = 'Nourish. Earring +1',
    left_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}},
    right_ring = 'Stikini Ring +1',
    back = 'Veela Cape'
}

-- Reraise (support magic)
sets.midcast['Reraise'] = {
    main = {
        name = 'Queller Rod',
        augments = {'Healing magic skill +15', '"Cure" potency +10%', '"Cure" spellcasting time -7%'}
    },
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = 'Ebers cap +3',
    body = {name = 'Witching Robe', augments = {'MP+45', 'Mag. Acc.+14', '"Mag.Atk.Bns."+14'}},
    hands = {
        name = 'Fanatic Gloves',
        augments = {'MP+40', 'Healing magic skill +4', '"Conserve MP"+3', '"Fast Cast"+4'}
    },
    legs = {name = 'Lengo Pants', augments = {'INT+5', 'Mag. Acc.+4', '"Mag.Atk.Bns."+1', '"Refresh"+1'}},
    feet = {name = 'Vanya Clogs', augments = {'"Cure" potency +5%', '"Cure" spellcasting time -15%', '"Conserve MP"+6'}},
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Embla Sash',
    left_ear = 'Loquac. Earring',
    right_ear = 'Regal Earring',
    left_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}},
    right_ring = 'Stikini Ring +1',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- Arise (resurrection spell)
sets.midcast['Arise'] = set_combine(sets.midcast['Reraise'], {})

-- Raise (resurrection spell)
sets.midcast['Raise'] = set_combine(sets.midcast['Reraise'], {})

-- ==========================================================================
-- OFFENSIVE MAGIC
-- ==========================================================================

-- Divine Magic (Banish, Holy, Repose)
sets.midcast['Divine Magic'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    body = {name = 'Cohort Cloak +1', augments = {'Path: A'}},
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Sanctity Necklace',
    waist = 'Eschan Stone',
    left_ear = "Hecate's Earring",
    right_ear = 'Strophadic Earring',
    left_ring = {name = "Mephitas's Ring +1", augments = {'Path: A'}},
    right_ring = 'Stikini Ring +1',
    back = 'Refraction Cape'
}

-- Holy (WHM nuke - enhanced by Afflatus Solace)
-- Piety Duckbills +3 gives +MAB per merit when Afflatus Solace is active
sets.midcast['Holy'] =
    set_combine(
    sets.midcast['Divine Magic'],
    {
        feet = 'Piety Duckbills +3' -- +MAB per merit with Afflatus Solace
    }
)

-- Holy II (WHM high-tier nuke - enhanced by Afflatus Solace)
sets.midcast['Holy II'] =
    set_combine(
    sets.midcast['Divine Magic'],
    {
        feet = 'Piety Duckbills +3' -- +MAB per merit with Afflatus Solace
    }
)

-- Dark Magic (rare for WHM)
sets.midcast['Dark Magic'] = set_combine(sets.midcast['Divine Magic'], {})

-- Elemental Magic (rare for WHM)
sets.midcast['Elemental Magic'] = set_combine(sets.midcast['Divine Magic'], {})

-- ==========================================================================
-- ENFEEBLING MAGIC
-- ==========================================================================

-- Repose (WHM-specific sleep)
sets.midcast['Repose'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Homiliary',
    head = 'Nyame Helm',
    body = 'Theo. Bliaut +3',
    hands = 'Nyame Gauntlets',
    legs = 'Chironic Hose',
    feet = 'Theo. Duckbills +3',
    neck = {name = 'Clr. Torque +1', augments = {'Path: A'}},
    waist = 'Eschan Stone',
    left_ear = 'Malignance Earring',
    right_ear = 'Malignance Earring',
    right_ring = 'Stikini Ring +1',
    left_ring = 'Kishar Ring',
    back = {name = "Alaunus's Cape", augments = {'MND+18', '"Fast Cast"+10', 'Occ. inc. resist. to stat. ailments+10'}}
}

-- MND-based enfeebles (Slow, Paralyze, Silence, etc.)
sets.midcast.MndEnfeebles = set_combine(sets.midcast['Repose'], {})

-- INT-based enfeebles (rare for WHM)
sets.midcast.IntEnfeebles = set_combine(sets.midcast['Repose'], {})

--============================================================--

--                     MOVEMENT SETS                          --
--============================================================--

-- Kiting set
sets.Kiting = {
    feet = "Herald's Gaiters"
}

-- Movement speed gear
sets.MoveSpeed = {
    right_ring = 'Shneddick ring'
}

--============================================================--

--                      BUFF SETS                             --
--============================================================--

sets.buff = {}

-- Divine Caress buff (enhances status removal)
-- Gear must be worn during MIDCAST of status removal spell (Paralyna, Silena, etc.)
-- NOT during JA activation
sets.buff['Divine Caress'] = {}

-- Afflatus Solace buff (enhances Cure/Barspell when active)
-- Cure: Ebers Bliaut +3 (+18% HP as Stoneskin) + Alaunus's Cape (+10% HP as Stoneskin) = +28% total
-- Barspell: Ebers Bliaut +3 (+18 MDB) + Alaunus's Cape (+10 MDB) = +28 MDB total
-- Sacrifice: Removes 7 status effects instead of 1 (Ebers Bliaut +3 enhances)
-- Worn during MIDCAST of Cure/Curaga/Barspells when Afflatus Solace is active
sets.buff['Afflatus Solace'] = {
    body = 'Ebers Bliaut +3',
    back = "Alaunus's Cape" -- +10% Cure Stoneskin, +10 MDB to Barspells
}

--============================================================--
--                     RESTING SETS                           --
--============================================================--

sets.resting = {}

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

print('[WHM] Equipment sets loaded successfully')

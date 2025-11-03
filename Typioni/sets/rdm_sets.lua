---============================================================================
--- RDM Equipment Sets - Ultimate Red Mage Spellblade Configuration
---============================================================================
--- Complete equipment configuration for Red Mage hybrid DPS/support role with
--- optimized enfeebling, enhancing, and melee capabilities.
---
--- Features:
---   • Enfeebling Magic mastery (Vitiation +4, Lethargy +3, Magic Accuracy focus)
---   • Enhancing Magic duration (Telchine, Atrophy Gloves +4, Ghostfyre cape)
---   • Elemental Magic nuking (Ea Hat +1, Lethargy full set, Magic Burst)
---   • Cure support (Kaykaus set, Cure Potency)
---   • Melee DPS capability (Malignance hybrid, Store TP, Coiste Bodhar)
---   • Fast Cast optimization (Atrophy Chapeau +3, Bunzi's set)
---   • Saboteur enhancement (extended enfeeble duration)
---   • Movement speed optimization (Carmine Cuisses +1)
---
--- Architecture:
---   • Equipment definitions (Chirich rings, wardrobe management)
---   • Precast sets (Fast Cast, Job Abilities, Weaponskills)
---   • Midcast sets (Elemental, Enfeebling, Enhancing, Cure, Dark Magic)
---   • Idle sets (DT, Refresh, Regain, Town)
---   • Engaged sets (DT, Enspell, Refresh, TP, Dual Wield)
---   • Weapon sets (Crocea Mors, Naegling, Daybreak / Colada, Tauret, Shields)
---   • Movement sets (Base speed)
---
--- @file    jobs/rdm/sets/rdm_sets.lua
--- @author  Kaories
--- @version 3.0 - Standardized Organization with Real Equipment
--- @date    Updated: 2025-10-24
---============================================================================

--============================================================--

--                  EQUIPMENT DEFINITIONS                     --
--============================================================--

local ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe 1'}
local ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 2'}

-- Sucellos's Cape Variants
local Sucellos = {
    FC = {
        name = "Sucellos's Cape",
        augments = {'MND+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'MND+10', '"Fast Cast"+10', 'Damage taken-5%'}
    },
    STP = {name = "Sucellos's Cape", augments = {'DEX+20', 'Accuracy+20 Attack+20', 'DEX+9', '"Store TP"+10'}},
    WSD = {
        name = "Sucellos's Cape",
        augments = {'STR+20', 'Accuracy+20 Attack+20', 'STR+10', 'Weapon skill damage +10%'}
    },
    INT = {
        name = "Sucellos's Cape",
        augments = {'INT+20', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Mag.Atk.Bns."+10', 'Damage taken-5%'}
    },
    Cure = {name = "Sucellos's Cape", augments = {'MND+20', 'MND+10', '"Cure" potency +10%'}}
}

-- Ghostfyre Cape
local Ghostfyre = {
    name = 'Ghostfyre Cape',
    augments = {'Enfb.mag. skill +2', 'Enha.mag. skill +3', 'Mag. Acc.+6', 'Enh. Mag. eff. dur. +20'}
}

-- Lethargy Earring +1
local LethEarring = {
    name = 'Leth. Earring +1',
    augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+14', 'Mag. Acc.+14', '"Dbl.Atk."+5'}
}

--============================================================--

--                      WEAPON SETS                          --
--============================================================--

-- Main Weapons (cycle via state.MainWeapon)
sets['Crocea Mors'] = {main = 'Crocea Mors'}
sets['Naegling'] = {main = 'Naegling'}
sets['Maxentius'] = {main = 'Maxentius'}
sets['Daybreak'] = {main = 'Daybreak'}
sets["Bunzi's Rod"] = {main = "Bunzi's Rod"}
sets['Colada'] = {main = 'Colada'}

-- Sub Weapons (cycle via state.SubWeapon)
sets['Ammurapi Shield'] = {sub = 'Ammurapi Shield'}
sets['Genmei Shield'] = {sub = 'Genmei Shield'}

-- Note: Weapons can be cycled via state.MainWeapon
-- Equipment will automatically swap based on selection

--============================================================--

--                      IDLE SETS                            --
--============================================================--

sets.idle = {}

-- DT Idle (Physical Damage Taken -, cap 50%)
sets.idle.DT = {
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = {name = 'Dls. Torque +2', augments = {'Path: A'}},
    waist = {name = 'Acuity Belt +1', augments = {'Path: A'}},
    left_ear = 'Malignance Earring',
    right_ear = LethEarring,
    left_ring = 'Stikini Ring +1',
    right_ring = 'Karieyh Ring',
    back = Sucellos.FC
}

-- Refresh Idle (maximize Refresh+)
sets.idle.Refresh =
    set_combine(
    sets.idle.DT,
    {
        body = 'Lethargy Sayon +3',
        legs = 'Leth. Fuseau +3'
    }
)

-- Regain Idle (Store TP+, Regain+)
sets.idle.Regain = set_combine(sets.idle.DT, {})

-- Evasion Idle (maximize Evasion)
sets.idle.Evasion = set_combine(sets.idle.DT, {})

-- Town Idle
sets.idle.Town =
    set_combine(
    sets.idle.DT,
    {
        legs = 'Carmine Cuisses +1'
    }
)

-- Legacy PDT (for compatibility)
sets.idle.PDT = sets.idle.DT
sets.idle.Normal = sets.idle.Refresh

--============================================================--

--                     ENGAGED SETS                          --
--============================================================--

sets.engaged = {}

-- DT Engaged (defensive melee - Physical Damage Taken -)
sets.engaged.DT = {
    ammo = {name = 'Coiste Bodhar', augments = {'Path: A'}},
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Anu Torque',
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Sherida Earring',
    right_ear = 'Telos Earring',
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = Sucellos.STP
}

-- Enspell Engaged (enspell bonus)
sets.engaged.Enspell = set_combine(sets.engaged.DT, {})

-- Refresh Engaged (MP refresh while engaged)
sets.engaged.Refresh =
    set_combine(
    sets.engaged.DT,
    {
        body = 'Lethargy Sayon +3'
    }
)

-- TP Engaged (maximize Store TP, TP gain)
sets.engaged.TP = sets.engaged.DT

-- Dualwield Engaged (NIN subjob)
sets.engaged.DW = set_combine(sets.engaged.TP, {})

-- Legacy PDT (for compatibility)
sets.engaged.PDT = sets.engaged.DT
sets.engaged.Normal = sets.engaged.TP

--============================================================--

--                     PRECAST SETS                          --
--============================================================--

sets.precast.WS = {}

-- Job Abilities
sets.precast.JA['Chainspell'] = {}
sets.precast.JA['Convert'] = {}
sets.precast.JA['Saboteur'] = {}
sets.precast.JA['Composure'] = {}

-- Fast Cast Sets (Cap: 80% Fast Cast)
sets.precast.FC = {
    ammo = 'Regal Gem',
    head = 'Atrophy Chapeau +3',
    body = {name = 'Viti. Tabard +3', augments = {'Enhances "Chainspell" effect'}},
    hands = 'Leth. Ganth. +3',
    legs = "Bunzi's Pants",
    feet = "Bunzi's Sabots",
    neck = {name = 'Dls. Torque +2', augments = {'Path: A'}},
    waist = {name = 'Acuity Belt +1', augments = {'Path: A'}},
    left_ear = 'Loquac. Earring',
    right_ear = LethEarring,
    left_ring = 'Kishar Ring',
    right_ring = 'Defending Ring',
    back = Sucellos.FC
}

-- Enhancing Magic Fast Cast
sets.precast.FC['Enhancing Magic'] =
    set_combine(
    sets.precast.FC,
    {
        waist = 'Siegel Sash'
    }
)

-- Stoneskin Fast Cast
sets.precast.FC.Stoneskin =
    set_combine(
    sets.precast.FC['Enhancing Magic'],
    {
        legs = 'Siegel Sash'
    }
)

-- Cure Fast Cast
sets.precast.FC.Cure =
    set_combine(
    sets.precast.FC,
    {
        ear1 = 'Mendi. Earring'
    }
)

sets.precast.FC.Curaga = sets.precast.FC.Cure
sets.precast.FC['Healing Magic'] = sets.precast.FC.Cure

-- Elemental Magic Fast Cast
sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {})

-- Impact Fast Cast
sets.precast.FC.Impact = set_combine(sets.precast.FC['Elemental Magic'], {})

-- Utsusemi Fast Cast
sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})

-- Storm Fast Cast
sets.precast.FC.Storm = set_combine(sets.precast.FC, {})

--============================================================--
--                     MIDCAST SETS                          --
--============================================================--

sets.midcast = {}

-- Elemental Magic (Nuking) - Base Set
sets.midcast['Elemental Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = {name = 'Ghastly Tathlum +1', augments = {'Path: A'}},
    head = 'Ea Hat +1',
    body = 'Lethargy Sayon +3',
    hands = "Bunzi's Gloves",
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Sibyl Scarf',
    waist = 'Refoccilation Stone',
    left_ear = 'Regal Earring',
    right_ear = 'Malignance Earring',
    left_ring = 'Jhakri Ring',
    right_ring = 'Mujin Band',
    back = Sucellos.INT
}

-- Elemental Magic - Nuke Mode Sets
sets.midcast['Elemental Magic'].FreeNuke = sets.midcast['Elemental Magic']

sets.midcast['Elemental Magic'].AccuNuke =
    set_combine(
    sets.midcast['Elemental Magic'],
    {
        neck = 'Erra Pendant'
    }
)

sets.midcast['Elemental Magic'].MB =
    set_combine(
    sets.midcast['Elemental Magic'],
    {
        head = 'Ea Hat +1',
        body = 'Ea Houppe. +1',
        hands = {name = 'Amalric Gages +1', augments = {'INT+12', 'Mag. Acc.+20', '"Mag.Atk.Bns."+20'}},
        left_ring = 'Freke Ring',
        right_ring = 'Locus Ring'
    }
)

sets.midcast['Elemental Magic'].MBAcc =
    set_combine(
    sets.midcast['Elemental Magic'].MB,
    {
        neck = 'Erra Pendant'
    }
)

-- Healing Magic (Cures)
sets.midcast.Cure = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = {name = 'Kaykaus Cuffs +1', augments = {'MP+80', 'MND+12', 'Mag. Acc.+20'}},
    legs = {name = 'Kaykaus Tights +1', augments = {'MP+80', 'MND+12', 'Mag. Acc.+20'}},
    feet = {name = 'Kaykaus Boots +1', augments = {'MP+80', 'MND+12', 'Mag. Acc.+20'}},
    neck = "Incanter's Torque",
    waist = 'Rumination Sash',
    left_ear = 'Regal Earring',
    right_ear = 'Saxnot Earring',
    left_ring = 'Stikini Ring +1',
    right_ring = "Sirona's Ring",
    back = Sucellos.Cure
}

sets.midcast.Curaga = sets.midcast.Cure
sets.midcast.CureSelf = {
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = {name = 'Kaykaus Cuffs +1', augments = {'MP+80', 'MND+12', 'Mag. Acc.+20'}},
    legs = {name = 'Kaykaus Tights +1', augments = {'MP+80', 'MND+12', 'Mag. Acc.+20'}},
    feet = {name = 'Kaykaus Boots +1', augments = {'MP+80', 'MND+12', 'Mag. Acc.+20'}},
    neck = "Incanter's Torque",
    left_ear = 'Regal Earring',
    right_ear = 'Saxnot Earring',
    left_ring = 'Kunaji Ring',
    right_ring = "Sirona's Ring",
    back = Sucellos.Cure,
    waist = 'Gishdubar Sash'
}

-- Enfeebling Magic (Debuffs) - Base Set
sets.midcast['Enfeebling Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    range = 'Ullr',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Leth. Fuseau +3',
    feet = {name = 'Vitiation Boots +3', augments = {'Immunobreak Chance'}},
    neck = {name = 'Dls. Torque +2', augments = {'Path: A'}},
    waist = {name = 'Acuity Belt +1', augments = {'Path: A'}},
    left_ear = 'Malignance Earring',
    right_ear = 'Snotra Earring',
    left_ring = 'Metamorph ring +1',
    right_ring = 'Kishar Ring',
    back = Sucellos.FC
}

-- Enfeebling Type Sets (Auto-selected based on spell from RDM_SPELL_DATABASE)
sets.midcast['Enfeebling Magic'].macc = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].mnd_potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].int_potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].skill_potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].skill_mnd_potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].duration = sets.midcast['Enfeebling Magic']

-- Enfeebling Mode Sets (selected via EnfeebleMode state)
sets.midcast['Enfeebling Magic'].Potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].Mixed = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].Acc =
    set_combine(
    sets.midcast['Enfeebling Magic'],
    {
        neck = 'Erra Pendant'
    }
)

-- Enfeebling with Saboteur active
sets.midcast['Enfeebling Magic'].Saboteur = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Enhancing Magic (Buffs) - Base Set
sets.midcast['Enhancing Magic'] = {}

-- Enhancing on Self (or no Composure active)
sets.midcast['Enhancing Magic'].self = {
    main = 'Colada',
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +9'}},
    body = 'Viti. Tabard +3',
    hands = 'Atrophy Gloves +4',
    legs = {name = 'Telchine Braconi', augments = {'Mag. Evasion+21', '"Conserve MP"+4', 'Enh. Mag. eff. dur. +9'}},
    feet = 'Leth. Houseaux +3',
    neck = {name = 'Dls. Torque +2', augments = {'Path: A'}},
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = LethEarring,
    left_ring = 'Kishar Ring',
    right_ring = 'Defending Ring',
    back = Ghostfyre
}

-- Enhancing on Others (with Composure - duration bonus)
sets.midcast['Enhancing Magic'].others = {
    main = {name = 'Colada', augments = {'Enh. Mag. eff. dur. +4', 'STR+6', 'Mag. Acc.+11', 'DMG:+6'}},
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Viti. Tabard +3',
    hands = 'Atrophy Gloves +4',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = {name = 'Dls. Torque +2', augments = {'Path: A'}},
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = 'Leth. Earring +1',
    left_ring = 'Kishar Ring',
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = Ghostfyre
}

-- Enhancing with Composure active (compatibility with old naming)
sets.midcast['Enhancing Magic'].Composure = sets.midcast['Enhancing Magic'].others

-- Stoneskin
sets.midcast.Stoneskin =
    set_combine(
    sets.midcast['Enhancing Magic'].self,
    {
        hands = 'Stone Mufflers',
        legs = 'Shedir Seraweels',
        left_ear = 'Earthcry Earring',
        neck = 'Nodens Gorget',
        waist = 'Siegel Sash'
    }
)

-- Regen
sets.midcast.Regen = {
    -- main = 'Bolelabunga',
    body = {name = 'Telchine Chas.', augments = {'"Conserve MP"+5', '"Regen" potency+3'}}
}

-- Refresh
sets.midcast.Refresh = {
    body = 'Atrophy Tabard +4',
    legs = 'Leth. Fuseau +3'
}

-- Enspells
sets.midcast.Enspell = {}

-- Phalanx
sets.midcast.Phalanx = {
    head = {name = 'Taeon Chapeau', augments = {'Mag. Evasion+20', 'Phalanx +3'}},
    body = {name = 'Taeon Tabard', augments = {'Mag. Evasion+14', '"Conserve MP"+5', 'Phalanx +3'}},
    hands = {name = 'Taeon Gloves', augments = {'Phalanx +3'}},
    legs = {name = 'Taeon Tights', augments = {'Mag. Evasion+19', '"Conserve MP"+5', 'Phalanx +3'}},
    feet = {name = 'Taeon Boots', augments = {'Mag. Evasion+16', '"Conserve MP"+4', 'Phalanx +3'}}
}

-- Haste/Flurry
sets.midcast.Haste = set_combine(sets.midcast.EnhancingMagic, {})

-- Dark Magic
sets.midcast['Dark Magic'] = {
    ammo = 'Pemphredo Tathlum',
    head = 'Carmine Mask +1',
    neck = 'Erra Pendant',
    --left_ear = 'Gwati Earring',
    --right_ear = 'Lempo Earring',
    --body = 'Psycloth Vest',
    hands = 'Leyline Gloves',
    left_ring = 'Stikini Ring +1',
    right_ring = 'Evanescence Ring',
    back = Sucellos.INT
    -- waist = 'Tengu-No-Obi',
    --[[ legs = {
        name = 'Merlinic Shalwar',
        augments = {
            'Mag. Acc.+22 "Mag.Atk.Bns."+22',
            'Magic burst mdg.+10%',
            'CHR+8',
            'Mag. Acc.+7',
            '"Mag.Atk.Bns."+1'
        }
    }, ]]
    --feet = 'Jhakri Pigaches +2'
}

sets.midcast.Impact = sets.midcast['Elemental Magic']
sets.midcast.Stun = sets.midcast['Dark Magic']
sets.midcast.Drain =
    set_combine(
    sets.midcast['Dark Magic'],
    {
        --head = 'Pixie Hairpin +1',
        feet = {
            name = 'Merlinic Crackows',
            augments = {'Mag. Acc.+21 "Mag.Atk.Bns."+21', 'Magic burst dmg.+9%', 'INT+14'}
        }
        -- waist = 'Fucho-No-Obi',
        -- right_ring = 'Archon Ring'
    }
)
sets.midcast.Aspir = sets.midcast.Drain

--============================================================--

--============================================================--
--                  WEAPONSKILL SETS                        --
--============================================================--

sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Leth. Houseaux +3',
    neck = 'Null Loop',
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = {name = 'Moonshade Earring', augments = {'Attack+4', 'TP Bonus +250'}},
    right_ear = LethEarring,
    left_ring = 'Karieyh Ring',
    right_ring = "Cornelia's Ring",
    back = Sucellos.WSD
}

-- Chant du Cygne (DEX, Crit)
sets.precast.WS['Chant du Cygne'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = 'Yetshila +1',
        head = 'Malignance Chapeau',
        body = 'Ayanmo Corazza +2',
        hands = 'Malignance Gloves',
        legs = 'Jhakri Slops',
        feet = 'Aya. Gambieras +1',
        neck = 'Fotia Gorget',
        waist = 'Fotia Belt',
        left_ear = 'Sherida Earring',
        right_ear = {name = 'Moonshade Earring', augments = {'Accuracy+4', 'TP Bonus +250'}},
        left_ring = 'Ilabrat Ring',
        right_ring = 'Karieyh Ring',
        back = {name = 'Mecisto. Mantle', augments = {'Cap. Point+49%', 'MND+3', '"Mag.Atk.Bns."+2', 'DEF+6'}}
    }
)

-- Savage Blade (STR/MND)
sets.precast.WS['Savage Blade'] =
    set_combine(
    sets.precast.WS,
    {
        ammo = "Oshasha's Treatise",
        head = {name = 'Nyame Helm', augments = {'Path: B'}},
        body = {name = 'Nyame Mail', augments = {'Path: B'}},
        hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
        legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
        feet = 'Leth. Houseaux +3',
        neck = 'Rep. Plat. Medal',
        waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
        left_ear = {name = 'Moonshade Earring', augments = {'Attack+4', 'TP Bonus +250'}},
        right_ear = LethEarring,
        left_ring = 'Karieyh Ring',
        right_ring = "Cornelia's Ring",
        back = Sucellos.WSD
    }
)

-- Requiescat (MND)
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})

-- Sanguine Blade (Magic WS - Dark)
sets.precast.WS['Sanguine Blade'] = {
    ammo = 'Pemphredo Tathlum',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Mizu. Kubikazari',
    waist = 'Refoccilation Stone',
    left_ear = 'Regal Earring',
    right_ear = 'Malignance Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Karieyh Ring',
    back = Sucellos.WSD
}

-- Seraph Blade (Magic WS - Light)
sets.precast.WS['Seraph Blade'] = {
    ammo = 'Pemphredo Tathlum',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Mizu. Kubikazari',
    waist = 'Refoccilation Stone',
    left_ear = 'Regal Earring',
    right_ear = 'Malignance Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Karieyh Ring',
    back = {name = "Sucellos's Cape", augments = {'STR+20', 'Accuracy+20 Attack+20', 'Weapon skill damage +6%'}}
}

-- Black Halo (MND)
sets.precast.WS['Black Halo'] = {
    ammo = 'Crepuscular Pebble',
    head = {name = 'Viti. Chapeau +4', augments = {'Enfeebling Magic duration', 'Magic Accuracy'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = 'Atrophy Gloves +4',
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Leth. Houseaux +3',
    neck = 'Null Loop',
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = 'Sherida Earring',
    right_ear = 'Regal Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Karieyh Ring',
    back = Sucellos.WSD
}

--============================================================--

--                     MOVEMENT SETS                         --
--============================================================--

sets.MoveSpeed = {
    legs = 'Carmine Cuisses +1'
}

-- Adoulin Movement (City-specific speed boost)
sets.Adoulin =
    set_combine(
    sets.MoveSpeed,
    {
        body = "Councilor's Garb" -- Speed bonus in Adoulin city
    }
)

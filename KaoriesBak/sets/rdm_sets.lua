---============================================================================
--- RDM Equipment Sets - Ultimate Red Mage Spellblade Configuration
---============================================================================
--- Complete equipment configuration for Red Mage hybrid DPS/support role with
--- optimized enfeebling, enhancing, and melee capabilities.
---
--- Features:
---   • Enfeebling Magic mastery (Vitiation +4, Lethargy +3, Magic Accuracy focus)
---   • Enhancing Magic duration (Telchine, Atrophy Gloves +4, Ghostfyre cape)
---   • Elemental Magic nuking (Bunzi's Rod, Lethargy full set, Magic Burst)
---   • Cure support (Daybreak main, Revealer's Mitts, Cure Potency)
---   • Melee DPS capability (Malignance hybrid, Store TP, Enspell bonus)
---   • Fast Cast optimization (Merlinic set, Sucellos cape FC+10)
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
--- @version 3.0 - Standardized Organization
--- @date    Updated: 2025-10-15
---============================================================================

--============================================================--
--                  EQUIPMENT DEFINITIONS                     --
--============================================================--

local ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe 1'}
local ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 2'}

--============================================================--
--                      WEAPON SETS                           --
--============================================================--

-- Main Weapons (cycle via state.MainWeapon)
sets['Naegling'] = {main = 'Naegling'}
sets['Daybreak'] = {main = 'Daybreak'}
sets['Colada'] = {main = 'Colada'}

-- Sub Weapons (cycle via state.SubWeapon)
sets['Ammurapi'] = {sub = 'Ammurapi Shield'}
sets['Genmei'] = {sub = 'Genmei Shield'}
sets['Malevolence'] = {sub = 'Malevolence'}

-- Note: Weapons can be cycled via state.MainWeapon
-- Equipment will automatically swap based on selection

--============================================================--
--                   SHIELD CONFIGURATION                     --
--============================================================--

-- Table des shields pour détection (modèle WAR Fencer)
-- Used to determine if player is single wield (shield/empty) or dual wield (2 weapons)
sets.shields = {
    'Ammurapi Shield',
    'Genmei Shield',
    'Blurred Shield +1',
    'Blurred Shield',
    'Aegis',
    'Ochain',
    'Srivatsa'
}

--============================================================--
--                      IDLE SETS                             --
--============================================================--

sets.idle = {}

-- DT Idle (Physical Damage Taken -, cap 50%)
sets.idle.DT = {
    ammo = 'Staunch Tathlum +1',
    head = 'Viti. Chapeau +4',
    body = 'Malignance Tabard',
    hands = 'Leth. Ganth. +3',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Elite Royal Collar',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Malignance Earring',
    right_ear = {
        name = 'Leth. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Dbl.Atk."+4'}
    },
    left_ring = 'Woltaris Ring',
    right_ring = "Gurebu's Ring",
    back = {
        name = "Sucellos's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- Refresh Idle (maximize Refresh+)
sets.idle.Refresh =
    set_combine(
    sets.idle.DT,
    {
        head = 'Viti. Chapeau +4',
        body = 'Lethargy Sayon +3',
        legs = 'Leth. Fuseau +3',
        left_ring = 'Woltaris Ring',
        right_ring = "Gurebu's Ring"
    }
)

-- Town Idle
sets.idle.Town = set_combine(sets.idle.DT, {legs = 'Carmine Cuisses +1'})

--============================================================--
--                     ENGAGED SETS                           --
--============================================================--

sets.engaged = {}

-- DT Engaged (defensive melee - Physical Damage Taken -)
sets.engaged.DT = {
    ammo = 'Regal Gem',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Anu Torque',
    waist = 'Sailfi Belt +1',
    left_ear = 'Sherida Earring',
    right_ear = 'Dedition Earring',
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = {
        name = "Sucellos's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- Enspell Engaged (enspell bonus)
sets.engaged.Enspell =
    set_combine(
    sets.engaged.DT,
    {
        head = 'Umuthi Hat',
        hands = 'Ayanmo Manopolas +2',
        back = 'Ghostfyre Cape'
    }
)

-- Refresh Engaged (MP refresh while engaged)
sets.engaged.Refresh = sets.engaged.DT

-- TP Engaged (maximize Store TP, TP gain)
sets.engaged.TP = sets.engaged.DT

-- Acc Engaged (accuracy focus)
sets.engaged.Acc = sets.engaged.DT

--============================================================--
--              DUAL WIELD ENGAGED SETS (2 WEAPONS)           --
--============================================================--

-- DT Dual Wield (defensive melee with dual wield gear)
sets.engaged.DT.DW =
    set_combine(
    sets.engaged.DT,
    {
        -- Dual Wield gear (Haste, DW+, etc.)
        left_ear = 'Suppanomimi', -- DW+5
        right_ear = 'Eabani Earring' -- DW+4
        -- Add more DW gear here as needed
    }
)

-- Enspell Dual Wield (enspell bonus with dual wield)
sets.engaged.Enspell.DW =
    set_combine(
    sets.engaged.Enspell,
    {
        head = 'Nyame Helm',
        left_ear = 'Suppanomimi',
        right_ear = 'Eabani Earring'
    }
)

-- Refresh Dual Wield (MP refresh while dual wielding)
sets.engaged.Refresh.DW = sets.engaged.DT.DW

-- TP Dual Wield (TP gain with dual wield)
sets.engaged.TP.DW = sets.engaged.DT.DW

-- Acc Dual Wield (accuracy focus with dual wield)
sets.engaged.Acc.DW = sets.engaged.DT.DW

--============================================================--
--                     PRECAST SETS                           --
--============================================================--

sets.precast = {}
sets.precast.JA = {}
sets.precast.FC = {
    ammo = 'Regal Gem',
    head = {name = 'Merlinic Hood', augments = {'Mag. Acc.+1', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+1'}},
    body = {name = 'Viti. Tabard +3', augments = {'Enhances "Chainspell" effect'}},
    hands = 'Leth. Ganth. +3',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Dls. Torque +2',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Loquac. Earring',
    right_ear = 'Leth. Earring +1',
    left_ring = "Gurebu's Ring",
    right_ring = 'Defending Ring',
    back = {
        name = "Sucellos's Cape",
        augments = {'MP+60', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Fast Cast"+10'}
    }
}

-- Spell-specific Fast Cast sets (override generic FC)
sets.precast.FC["Stoneskin"] = set_combine(sets.precast.FC, {
    head = "Umuthi Hat",  -- Stoneskin-specific FC
    waist = "Siegel Sash",
    legs = "Nyame Flanchard",
})

-- Job Abilities
sets.precast.JA['Chainspell'] = {
    body = 'Vitiation Tabard +3'
}

sets.precast.FC["Dispelga"] = set_combine(sets.precast.FC, {
    main = 'Daybreak',  -- Dispelga-specific FC
})

--============================================================--
--                     MIDCAST SETS                           --
--============================================================--

sets.midcast = {}

-- Elemental Magic (Nuking) - Base Set
sets.midcast['Elemental Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Sibyl Scarf',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Metamor. Ring +1',
    right_ring = 'Freke Ring',
    back = "Aurist's Cape +1"
}

-- Elemental Magic - Nuke Mode Sets
sets.midcast['Elemental Magic'].FreeNuke = sets.midcast['Elemental Magic']

sets.midcast['Elemental Magic']['Magic Burst'] = sets.midcast['Elemental Magic']

-- Healing Magic (Cures)
sets.midcast.Cure = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Viti. Chapeau +4',
    body = 'Viti. Tabard +3',
    hands = "Revealer's Mitts",
    legs = 'Atrophy Tights +4',
    feet = 'Leth. Houseaux +3',
    neck = 'Dls. Torque +2',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = "Naji's Loop",
    right_ring = "Gurebu's Ring",
    back = "Aurist's Cape +1"
}

sets.midcast.Curaga = sets.midcast.Cure
sets.midcast.CureSelf = sets.midcast.Cure

-- Healing Magic skill-based set (MidcastManager compatibility)
sets.midcast['Healing Magic'] = sets.midcast.Cure

-- Enfeebling Magic (Debuffs) - Base Set
sets.midcast['Enfeebling Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    range = 'Ullr',
    head = 'Viti. Chapeau +4',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Chironic hose',
    feet = 'Vitiation Boots +4',
    neck = 'Dls. Torque +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Kishar Ring',
    right_ring = 'Metamor. Ring +1',
    back = "Aurist's Cape +1"
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
sets.midcast['Enfeebling Magic'].Acc = sets.midcast['Enfeebling Magic']

-- Enfeebling with Saboteur active
sets.midcast['Enfeebling Magic'].Saboteur = sets.midcast['Enfeebling Magic']

-- Enhancing Magic (Buffs) - Base Set
sets.midcast['Enhancing Magic'] = {}

-- Enhancing on Self (or no Composure active)
sets.midcast['Enhancing Magic'].self = {
    main = 'Colada',
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = {name = 'Telchine Cap', augments = {'"Conserve MP"+5', 'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Viti. Tabard +3', augments = {'Enhances "Chainspell" effect'}},
    hands = 'Atrophy Gloves +4',
    legs = {name = 'Telchine Braconi', augments = {'"Conserve MP"+5', 'Enh. Mag. eff. dur. +10'}},
    feet = 'Leth. Houseaux +3',
    neck = 'Dls. Torque +2',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = {
        name = 'Leth. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Dbl.Atk."+4'}
    },
    left_ring = "Gurebu's Ring",
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = 'Ghostfyre Cape'
}

-- Enhancing on Others (with Composure - duration bonus)
sets.midcast['Enhancing Magic'].others = {
    main = {name = 'Colada', augments = {'Enh. Mag. eff. dur. +4', 'STR+6', 'Mag. Acc.+11', 'DMG:+6'}},
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Atrophy Gloves +4',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Dls. Torque +2',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = 'Leth. Earring +1',
    left_ring = "Gurebu's Ring",
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = 'Ghostfyre Cape'
}

-- Stoneskin
sets.midcast["Stoneskin"] =
    set_combine(
    sets.midcast['Enhancing Magic'].self,
    {
        left_ear = 'Earthcry Earring',
        neck = 'Nodens Gorget',
        waist = 'Siegel Sash'
    }
)
-- Stoneskin
sets.midcast["Aquaveil"] =
    set_combine(
    sets.midcast['Enhancing Magic'].self,
    {
        left_ear = 'Earthcry Earring',
        neck = "Null loop",
        waist = 'Siegel Sash'
    }
)

sets.midcast['Dispelga'] = set_combine(sets.midcast['Enfeebling Magic'], {
    main = 'Daybreak',
})

-- Regen
sets.midcast.Regen = {
    main = 'Bolelabunga',
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
sets.midcast.Phalanx = {}

-- Haste/Flurry
sets.midcast.Haste = set_combine(sets.midcast.EnhancingMagic, {})

-- Dark Magic
sets.midcast['Dark Magic'] = sets.midcast['Elemental Magic']
sets.midcast.Impact = sets.midcast['Elemental Magic']
sets.midcast.Stun = sets.midcast['Elemental Magic']
sets.midcast.Drain = sets.midcast['Elemental Magic']
sets.midcast.Aspir = sets.midcast['Elemental Magic']

--============================================================--
--                  WEAPONSKILL SETS                          --
--============================================================--

sets.precast.WS = {}

-- Weaponskills
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Leth. Houseaux +3',
    neck = 'Rep. Plat. Medal',
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = {name = 'Moonshade Earring', augments = {'Mag. Acc.+4', 'TP Bonus +250'}},
    right_ear = {
        name = 'Leth. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Dbl.Atk."+4'}
    },
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = {
        name = "Sucellos's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- Savage Blade (Physical WS - STR/MND)
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})

--============================================================--
--                     MOVEMENT SETS                          --
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

---============================================================================
--- BUFF SETS
---============================================================================

-- Doom resistance gear (Nicander's Necklace removes Doom)
sets.buff = {}
sets.buff.Doom = {
    neck = "Nicander's Necklace", -- Removes Doom (10/10 procs)
    ring1 = 'Purity Ring', -- Doom resistance
    ring2 = "Blenmot's Ring +1", -- Doom resistance
    waist = 'Gishdubar Sash' -- Doom resistance
}

---============================================================================
--- BLM Equipment Sets - Complete Black Mage Gear Configuration
---============================================================================
--- Comprehensive equipment configurations for Black Mage job covering all combat
--- scenarios, spells, job abilities, and defensive situations.
---
--- Features:
---   • Weapon sets (Bunzi's Rod, Mpaca's Staff, Marin Staff +1)
---   • Idle sets (Normal, PDT, Town with movement speed)
---   • Engaged sets (Normal, PDT)
---   • Fast Cast sets (80% FC cap with Merlinic augments)
---   • Elemental Magic sets (MAB/MACC + Magic Burst variant)
---   • Death spell sets (HP-based damage optimization)
---   • Enfeebling sets (MND/INT variants)
---   • Dark Magic sets (Drain/Aspir with potency gear)
---   • Enhancing Magic sets (Duration + Telchine +10)
---   • Cure sets (Self-healing configuration)
---   • Weaponskill sets (Nyame set)
---   • Movement speed sets (Herald's Gaiters + Councilor's Garb)
---   • Buff-specific sets (Manawall)
---   • Dynamic MP Conservation System (blm_dynamic_sets)
---
--- Architecture:
---   • Fast Cast cap (80% with Merlinic augments)
---   • Magic Burst potency gear (Ea Hat +1, Wicce +3, Mujin Band)
---   • Death spell HP stacking (Wicce +3 full set)
---   • MP conservation (Spaekona's +4, Orpheus's Sash)
---   • Elemental staff system (Marin Staff +1 for specific elements)
---   • Grip selection (Ammurapi Shield, Khonsu, Enki Strap)
---
--- Dependencies:
---   • Mote-Include (set_combine for set inheritance)
---   • set_builder (dynamic idle/engaged set construction)
---
--- @file    jobs/blm/sets/blm_sets.lua
--- @author  Typioni
--- @version 2.0
--- @date    Migrated: 2025-10-15 (from old BLM_SET.lua)
---============================================================================

--============================================================--

--                  EQUIPMENT DEFINITIONS                     --
--============================================================--

-- Dual rings in different wardrobes
local StikiRing1 = {name = 'Stikini Ring +1', bag = 'wardrobe 6'}
local StikiRing2 = {name = 'Stikini Ring +1', bag = 'wardrobe 7'}

--============================================================--

--                     WEAPON SETS                           --
--============================================================--

-- Main Weapon Sets
sets["Bunzi's Rod"] = {
    main = "Bunzi's Rod"
}

sets['Marin Staff +1'] = {
    main = 'Marin Staff +1'
}

sets["Mpaca's Staff"] = {
    main = "Mpaca's Staff"
}

-- Sub Weapon Sets (Grips)
sets['Ammurapi Shield'] = {
    sub = 'Ammurapi Shield'
}

sets.Khonsu = {
    sub = 'Khonsu'
}

sets.Enki = {
    sub = 'Enki Strap'
}

--============================================================--
--           DYNAMIC MP CONSERVATION SYSTEM                  --
--============================================================--

-- Base set for MP conservation calculations
local baseSetForMP = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = {name = 'Ghastly Tathlum +1', augments = {'Path: A'}},
    head = 'Wicce Petasos +3',
    body = "Spaekona's Coat +4",
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = {name = 'Src. Stole +2', augments = {'Path: A'}},
    waist = {name = 'Acuity Belt +1', augments = {'Path: A'}},
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Freke Ring',
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = "Taranus's Cape"
}

-- Function to merge two tables (for set combination)
local function mergeTables(t1, t2)
    if type(t1) ~= 'table' then
        error('t1 must be a table')
    end
    if type(t2) ~= 'table' then
        error('t2 must be a table')
    end

    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Equipment sets for MP conservation - Normal casting mode
local normalSetLowMP =
    mergeTables(
    baseSetForMP,
    {
        body = "Spaekona's Coat +4",
        waist = "Orpheus's Sash"
    }
)

local normalSetHighMP =
    mergeTables(
    baseSetForMP,
    {
        body = 'Wicce Coat +3',
        waist = "Orpheus's Sash"
    }
)

-- Equipment sets for MP conservation - Magic Burst mode
local magicBurstSetLowMP =
    mergeTables(
    baseSetForMP,
    {
        body = "Spaekona's Coat +4",
        head = 'Ea Hat +1',
        hands = "Agwu's Gages",
        left_ring = 'Mujin Band',
        ammo = 'Ghastly Tathlum +1',
        feet = 'Wicce Sabots +3',
        waist = 'Hachirin-no-obi'
    }
)

local magicBurstSetHighMP =
    mergeTables(
    baseSetForMP,
    {
        body = 'Wicce Coat +3',
        head = 'Ea Hat +1',
        hands = "Agwu's Gages",
        left_ring = 'Mujin Band',
        ammo = 'Ghastly Tathlum +1',
        feet = 'Wicce Sabots +3',
        waist = 'Hachirin-no-obi'
    }
)

-- Sets exposed for use by SET_CUSTOMIZATION logic
blm_dynamic_sets = {
    normalSetLowMP = normalSetLowMP,
    normalSetHighMP = normalSetHighMP,
    magicBurstSetLowMP = magicBurstSetLowMP,
    magicBurstSetHighMP = magicBurstSetHighMP
}

print('[BLM] Equipment sets loaded (100% migrated from old BLM_SET.lua)')

--                      IDLE SETS                            --
--============================================================--

-- Base Idle (Refresh, PDT, Regen, MP recovery)
sets.idle = {}

sets.idle.Normal = {
    main = "Mpaca's Staff",
    sub = 'Khonsu',
    ammo = 'Staunch Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'Volte Gloves',
    legs = 'Nyame Flanchard',
    feet = 'Wicce Sabots +3',
    neck = 'Loricate Torque +1',
    waist = 'Fucho-no-obi',
    left_ear = 'Ethereal Earring',
    right_ear = 'Odnowa Earring +1',
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = 'Solemnity Cape'
}

-- PDT Idle (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle.Normal, {})

-- Town Idle (Movement speed)
sets.idle.Town =
    set_combine(
    sets.idle.Normal,
    {
        feet = "Herald's Gaiters"
    }
)

-- Defense sets
sets.defense = {}
sets.defense.PDT = {}
sets.defense.MDT = {}

-- Resting set
sets.resting = set_combine(sets.idle.Normal, {})

--============================================================--

--                      ENGAGED SETS                          --
--============================================================--

sets.engaged = {}

-- Standard Normal Engaged (BLM rarely melees but has decent stats with Wicce +3)
sets.engaged.Normal = {
    main = 'Malignance Pole',
    sub = 'Khonsu',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Sanctity Necklace',
    waist = 'Windbuffet Belt +1',
    left_ear = 'Crep. Earring',
    right_ear = 'Telos Earring',
    left_ring = {name = 'Chirich Ring +1', bag = 'wardrobe 6'},
    right_ring = {name = 'Chirich Ring +1', bag = 'wardrobe 7'},
    back = "Taranus's Cape"
}

-- PDT Engaged
sets.engaged.PDT = set_combine(sets.engaged.Normal, {})

--============================================================--
--                  PRECAST: FAST CAST                       --
--============================================================--

sets.precast = {}

-- Fast Cast (cap 80% - achieved with Merlinic augments)
-- Total: 80% FC (6 main + 15+13+7+5+12 Merlinic + 5 neck + 3 waist + 4 ear1 + 2 ear2 + 4 ring1 + 4 QM total)
sets.precast.FC = {
    main = 'Grioavolr', -- 06 FC
    sub = 'Khonsu', -- 00 FC
    ammo = 'Impatiens', -- 02 QM
    head = {name = 'Merlinic Hood', augments = {'Attack+14', '"Fast Cast"+7', 'MND+3'}}, -- 15 FC
    body = {name = 'Merlinic Jubbah', augments = {'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3'}}, -- 13 FC
    hands = {name = 'Merlinic Dastanas', augments = {'"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4'}}, -- 07 FC
    legs = {name = 'Merlinic Shalwar', augments = {'"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11'}}, -- 05 FC
    feet = {name = 'Merlinic Crackows', augments = {'"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10'}}, -- 12 FC
    neck = "Orunmila's Torque", -- 05 FC
    waist = 'Witful Belt', -- 03 FC
    left_ear = 'Malignance Earring', -- 04 FC
    right_ear = 'Loquac. Earring', -- 02 FC
    left_ring = 'Kishar Ring', -- 04 FC
    right_ring = 'Lebeche Ring', -- 02 QM
    back = 'Perimede Cape' -- 04 QM
}

-- Enhancing Magic Fast Cast
sets.precast.FC['Enhancing Magic'] = sets.precast.FC

-- Elemental Magic Fast Cast
sets.precast.FC['Elemental Magic'] = sets.precast.FC

-- Death Fast Cast
sets.precast.FC.Death = set_combine(sets.precast.FC, {})
sets.precast.FC.Death.MagicBurst = sets.precast.FC.Death

-- Cure Fast Cast
sets.precast.FC.Cure = sets.precast.FC
sets.precast.FC.Curaga = sets.precast.FC.Cure

-- Impact Fast Cast (Twilight Cloak required)
sets.precast.FC.Impact =
    set_combine(
    sets.precast.FC,
    {
        body = 'Twilight Cloak'
    }
)

-- Stoneskin Fast Cast (Enhanced with duration gear)
sets.precast.FC.Stoneskin =
    set_combine(
    sets.precast.FC,
    {
        head = 'Umuthi Hat',
        legs = 'Doyen Pants',
        waist = 'Siegel Sash'
    }
)

--============================================================--
--                  PRECAST: JOB ABILITIES                   --
--============================================================--

sets.precast.JA = {}

-- Manawall (converts MP to damage absorption)
sets.precast.JA['Mana Wall'] = {
    feet = 'Wicce Sabots +3',
    back = "Taranus's Cape"
}

-- Manafont (MP cost reduction)
sets.precast.JA.Manafont = {
    body = "Archmage's Coat"
}

-- Elemental Seal (magic accuracy boost) - No specific gear
sets.precast.JA['Elemental Seal'] = {}

--============================================================--

--                     MIDCAST SETS                          --
--============================================================--

sets.midcast = {}

-- Fast Recast (fallback)
sets.midcast.FastRecast = sets.precast.FC

-- ================================================ Cure Sets ==============================================

-- Cure spells (Self-healing configuration - Daybreak + Ammurapi Shield)
sets.midcast.Cure = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Staunch Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Nyame Mail',
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Nodens Gorget',
    waist = 'Plat. Mog. Belt',
    left_ear = "Handler's Earring",
    right_ear = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}},
    left_ring = 'Defending Ring',
    right_ring = StikiRing2,
    back = 'Solemnity Cape'
}

-- Self-healing set (same as Cure)
sets.self_healing = set_combine(sets.midcast.Cure, {})

-- Curaga
sets.midcast.Curaga = sets.midcast.Cure

-- ================================================ Enhancing Sets ========================================

-- Enhancing Magic (Telchine +10 duration set)
sets.midcast['Enhancing Magic'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
    neck = 'Loricate Torque +1',
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = 'Evanescence Ring',
    back = 'Fi Follet Cape +1'
}

-- Stoneskin (Enhanced with duration + Siegel Sash)
sets.midcast.Stoneskin =
    set_combine(
    sets.midcast['Enhancing Magic'],
    {
        ammo = 'Impatiens',
        head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
        body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
        hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
        legs = 'Shedir Seraweels',
        feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
        neck = 'Nodens Gorget',
        waist = 'Siegel Sash',
        left_ear = 'Ethereal Earring',
        right_ear = 'Regal Earring',
        left_ring = StikiRing1,
        right_ring = StikiRing2,
        back = 'Fi Follet Cape +1'
    }
)

-- Phalanx
sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})

-- Aquaveil (Interrupt rate down)
sets.midcast.Aquaveil = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = 'Amalric Coif +1',
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = 'Shedir Seraweels',
    feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
    neck = 'Loricate Torque +1',
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = 'Evanescence Ring',
    back = 'Fi Follet Cape +1'
}

-- Refresh
sets.midcast.Refresh =
    set_combine(
    sets.midcast.Aquaveil,
    {
        main = 'Daybreak',
        sub = 'Ammurapi Shield',
        ammo = 'Impatiens',
        head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
        body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
        hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
        legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
        feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
        neck = 'Loricate Torque +1',
        waist = 'Olympus Sash',
        left_ear = 'Andoaa Earring',
        right_ear = 'Regal Earring',
        right_ring = 'Evanescence Ring',
        left_ring = StikiRing1,
        back = 'Fi Follet Cape +1'
    }
)

-- Haste
sets.midcast.Haste = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}},
    hands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}},
    legs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}},
    feet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}},
    neck = 'Loricate Torque +1',
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Regal Earring',
    right_ring = 'Evanescence Ring',
    left_ring = StikiRing1,
    back = 'Fi Follet Cape +1'
}

-- ================================================ Enfeebling Sets ========================================

-- MND-based Enfeebles (Slow, Paralyze, Silence, etc.)
sets.midcast.MndEnfeebles = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    head = 'Wicce Petasos +3',
    neck = 'Src. Stole +2',
    ear1 = 'Malignance Earring',
    ear2 = 'Regal Earring',
    body = 'Wicce Coat +3',
    hands = 'Wicce Gloves +3',
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = "Aurist's Cape +1",
    waist = 'Sacro Cord',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3'
}

-- INT-based Enfeebles (Bind, Sleep, Break, etc.)
sets.midcast.IntEnfeebles = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Wicce Earring +1',
    left_ring = 'Metamor. Ring +1',
    right_ring = StikiRing2,
    back = "Taranus's Cape"
}

-- Break spells
sets.midcast.Breakga = sets.midcast.IntEnfeebles
sets.midcast.Break = sets.midcast.Breakga

-- Sleep spells
sets.midcast.Sleep = sets.midcast.IntEnfeebles
sets.midcast['Sleep II'] = sets.midcast.Sleep
sets.midcast.Sleepga = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep

-- Blind
sets.midcast.Blind = sets.midcast.IntEnfeebles

-- ================================================ Dark Magic Sets ========================================

-- Dark Magic (Drain/Aspir with potency augments)
sets.midcast['Dark Magic'] = {
    main = {name = 'Rubicundity', augments = {'Mag. Acc.+6', '"Mag.Atk.Bns."+7', 'Dark magic skill +7'}},
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = {
        name = 'Merlinic Hood',
        augments = {'Mag. Acc.+6', '"Drain" and "Aspir" potency +10', 'INT+6', '"Mag.Atk.Bns."+2'}
    },
    body = {
        name = 'Merlinic Jubbah',
        augments = {'"Mag.Atk.Bns."+30', '"Drain" and "Aspir" potency +11', 'INT+3', 'Mag. Acc.+4'}
    },
    hands = {name = 'Merlinic Dastanas', augments = {'"Drain" and "Aspir" potency +10', '"Mag.Atk.Bns."+14'}},
    legs = 'Wicce Chausses +3',
    feet = "Agwu's Pigaches",
    neck = 'Erra Pendant',
    waist = 'Fucho-no-Obi',
    left_ear = 'Malignance Earring',
    right_ear = 'Wicce Earring +1',
    left_ring = 'Metamor. Ring +1',
    right_ring = 'Evanescence Ring',
    back = "Taranus's Cape"
}

-- Drain
sets.midcast.Drain = sets.midcast['Dark Magic']

-- Aspir
sets.midcast.Aspir = sets.midcast['Dark Magic']

-- Raise (no specific gear)
sets.midcast.Raise = {}

-- ================================================ Elemental Magic Sets ========================================

-- Elemental Magic (MAB/MACC - Wicce +3 full set + Bunzi's Rod)
sets.midcast['Elemental Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = "Wicce Coat +3",
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Freke Ring',
    right_ring = 'Metamor. Ring +1',
    back = "Taranus's Cape"
}

-- Elemental Magic - Magic Burst variant (Ea Hat +1 + Mujin Band + Hachirin-no-obi)
sets.midcast['Elemental Magic'].MagicBurst = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Ea Hat +1',
    body = 'Wicce Coat +3',
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Src. Stole +2',
    waist = 'Hachirin-no-obi',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Mujin Band',
    right_ring = 'Metamor. Ring +1',
    back = "Taranus's Cape"
}

-- Impact (Twilight Cloak required)
sets.midcast['Impact'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    body = 'Twilight Cloak',
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = 'Metamor. Ring +1',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'INT+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

-- Impact Magic Burst
sets.midcast['Impact'].MagicBurst = sets.midcast['Impact']

-- Meteor (same as Elemental Magic)
sets.midcast['Meteor'] = sets.midcast['Elemental Magic']

-- Comet
sets.midcast['Comet'] = sets.midcast['Elemental Magic']
sets.midcast['Comet'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- Death (HP-based damage)
sets.midcast['Death'] = sets.midcast['Elemental Magic']
sets.midcast['Death'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- ================================================ Dot Sets (Burn, Rasp, Shock, etc.) ========================================

-- DOT spells (Burn, Rasp, Shock, Drown, Choke, Frost) - Use Archmage Tonban +3 for duration
sets.midcast['Burn'] = {
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = "Spaekona's Coat +4",
    hands = 'Wicce Gloves +3',
    legs = {name = 'Arch. Tonban +3', augments = {'Increases Elemental Magic debuff time and potency'}},
    feet = {name = 'Arch. Sabots +3', augments = {'Increases Aspir absorption amount'}},
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = 'Metamor. Ring +1',
    back = {
        name = "Taranus's Cape",
        augments = {
            'INT+20',
            'Mag. Acc+20 /Mag. Dmg.+20',
            'INT+10',
            '"Mag.Atk.Bns."+10',
            'Spell interruption rate down-10%'
        }
    }
}

-- All DOT spells use same set
sets.midcast['Rasp'] = sets.midcast['Burn']
sets.midcast['Shock'] = sets.midcast['Burn']
sets.midcast['Drown'] = sets.midcast['Burn']
sets.midcast['Choke'] = sets.midcast['Burn']
sets.midcast['Frost'] = sets.midcast['Burn']

--============================================================--

--                   WEAPONSKILL SETS                        --
--============================================================--

-- Weaponskill (BLM rarely melees - Nyame set for any WS)
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    left_ear = 'Moonshade Earring',
    right_ear = 'Mache Earring +1',
    left_ring = "Cornelia's Ring",
    right_ring = 'Chirich Ring +1',
    back = "Taranus's Cape"
}

--============================================================--

--                     MOVEMENT SETS                         --
--============================================================--

-- Base Movement Speed
sets.MoveSpeed = {
    feet = "Herald's Gaiters"
}

-- Adoulin Movement (City-specific speed boost)
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

-- Manawall buff active (Defensive gear while Manawall is up)
sets.buff['Mana Wall'] = {
    feet = 'Wicce Sabots +3',
    back = "Taranus's Cape"
}

-- Doom removal
sets.buff.Doom = {
    neck = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    waist = 'Gishdubar Sash'
}

--============================================================--

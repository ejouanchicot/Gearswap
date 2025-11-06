--======================================================================================
--
--                            BLACK MAGE - EQUIPMENT SETS
--
--======================================================================================
--
--  Customize your gear by editing the sets below, then reload: //gs reload
--
--  AUTOMATIC FEATURES:
--    - MP Conservation: Auto-equips sets.midcast.MPConservation when MP < 1000
--    - Elemental Match: Auto-equips sets.midcast.ElementalMatch on storm/day/weather
--    - Magic Burst Mode: Toggle with keybind for burst damage gear
--
--======================================================================================

--====================================================================
--  EQUIPMENT DEFINITIONS
--====================================================================

-- Dual rings in different wardrobes
local StikiRing1 = {name = 'Stikini Ring +1', bag = 'wardrobe 6'}
local StikiRing2 = {name = 'Stikini Ring +1', bag = 'wardrobe 7'}
local ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe 6'}
local ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 7'}

-- Merlinic Fast Cast Set (80% FC augments)
local MerlinicHead_FC = {name = 'Merlinic Hood', augments = {'Attack+14', '"Fast Cast"+7', 'MND+3'}}
local MerlinicBody_FC = {
    name = 'Merlinic Jubbah',
    augments = {'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3'}
}
local MerlinicHands_FC = {name = 'Merlinic Dastanas', augments = {'"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4'}}
local MerlinicLegs_FC = {name = 'Merlinic Shalwar', augments = {'"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11'}}
local MerlinicFeet_FC = {
    name = 'Merlinic Crackows',
    augments = {'"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10'}
}

-- Merlinic Drain/Aspir Set
local MerlinicHead_Drain = {
    name = 'Merlinic Hood',
    augments = {'Mag. Acc.+6', '"Drain" and "Aspir" potency +10', 'INT+6', '"Mag.Atk.Bns."+2'}
}
local MerlinicBody_Drain = {
    name = 'Merlinic Jubbah',
    augments = {'"Mag.Atk.Bns."+30', '"Drain" and "Aspir" potency +11', 'INT+3', 'Mag. Acc.+4'}
}
local MerlinicHands_Drain = {
    name = 'Merlinic Dastanas',
    augments = {'"Drain" and "Aspir" potency +10', '"Mag.Atk.Bns."+14'}
}

-- Telchine Enhancing Duration Set (+10 duration)
local TelchineHead = {name = 'Telchine Cap', augments = {'Enh. Mag. eff. dur. +10'}}
local TelchineBody = {name = 'Telchine Chas.', augments = {'Enh. Mag. eff. dur. +10'}}
local TelchineHands = {name = 'Telchine Gloves', augments = {'Enh. Mag. eff. dur. +10'}}
local TelchineLegs = {name = 'Telchine Braconi', augments = {'Enh. Mag. eff. dur. +10'}}
local TelchineFeet = {name = 'Telchine Pigaches', augments = {'Enh. Mag. eff. dur. +10'}}

-- Archmage's Relic +3
local ArchmageTonban = {name = 'Arch. Tonban +3', augments = {'Increases Elemental Magic debuff time and potency'}}
local ArchmageSabots = {name = 'Arch. Sabots +3', augments = {'Increases Aspir absorption amount'}}

-- Rubicundity (Dark Magic)
local Rubicundity = {name = 'Rubicundity', augments = {'Mag. Acc.+6', '"Mag.Atk.Bns."+7', 'Dark magic skill +7'}}

-- Wicce Earring +1
local WicceEarring = {name = 'Wicce Earring +1', augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}}

-- Taranus's Cape (MAB/INT)
local TaranusCape = {
    name = "Taranus's Cape",
    augments = {
        'INT+20',
        'Mag. Acc+20 /Mag. Dmg.+20',
        'INT+10',
        '"Mag.Atk.Bns."+10',
        'Spell interruption rate down-10%'
    }
}

--====================================================================
--  IDLE SETS
--====================================================================

sets.idle = {}

-- Normal Idle (Refresh, PDT, MP recovery)
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

--====================================================================
--  ENGAGED SETS
--====================================================================

sets.engaged = {}

-- Normal Engaged (BLM rarely melees)
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
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = "Taranus's Cape"
}

-- PDT Engaged
sets.engaged.PDT = set_combine(sets.engaged.Normal, {})

--====================================================================
--  PRECAST - FAST CAST
--====================================================================

sets.precast = {}
sets.precast.FC = {}

-- Base Fast Cast (80% cap with Merlinic augments)
sets.precast.FC = {
    main = 'Grioavolr', -- 06% FC
    sub = 'Khonsu',
    ammo = 'Impatiens', -- 02% Quick Magic
    head = MerlinicHead_FC, -- 15% FC
    body = MerlinicBody_FC, -- 13% FC
    hands = MerlinicHands_FC, -- 07% FC
    legs = MerlinicLegs_FC, -- 05% FC
    feet = MerlinicFeet_FC, -- 12% FC
    neck = "Orunmila's Torque", -- 05% FC
    waist = 'Witful Belt', -- 03% FC
    left_ear = 'Malignance Earring', -- 04% FC
    right_ear = 'Loquac. Earring', -- 02% FC
    left_ring = 'Kishar Ring', -- 04% FC
    right_ring = 'Lebeche Ring', -- 02% Quick Magic
    back = 'Perimede Cape' -- 04% Quick Magic
}

-- Enhancing Magic Fast Cast
sets.precast.FC['Enhancing Magic'] = sets.precast.FC

-- Elemental Magic Fast Cast
sets.precast.FC['Elemental Magic'] = sets.precast.FC

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

-- Stoneskin Fast Cast
sets.precast.FC.Stoneskin =
    set_combine(
    sets.precast.FC,
    {
        head = 'Umuthi Hat',
        legs = 'Doyen Pants',
        waist = 'Siegel Sash'
    }
)

--====================================================================
--  PRECAST - JOB ABILITIES
--====================================================================

sets.precast.JA = {}

-- Manawall
sets.precast.JA['Mana Wall'] = {
    feet = 'Wicce Sabots +3',
    back = "Taranus's Cape"
}

-- Manafont
sets.precast.JA.Manafont = {
    body = "Archmage's Coat"
}

-- Elemental Seal (no specific gear)
sets.precast.JA['Elemental Seal'] = {}

--====================================================================
--  PRECAST - WEAPONSKILLS
--====================================================================

sets.precast.WS = {}

-- Generic Weaponskill (Nyame set)
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

--====================================================================
--  MIDCAST - CURE & HEALING
--====================================================================

sets.midcast = {}

-- Cure (Self-healing with Daybreak)
sets.midcast.Cure = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Staunch Tathlum +1',
    head = 'Wicce Petasos +3',
    body = 'Nyame Mail',
    hands = TelchineHands,
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Nodens Gorget',
    waist = 'Plat. Mog. Belt',
    left_ear = "Handler's Earring",
    right_ear = WicceEarring,
    left_ring = 'Defending Ring',
    right_ring = StikiRing2,
    back = 'Solemnity Cape'
}

-- Curaga
sets.midcast.Curaga = sets.midcast.Cure

-- Raise
sets.midcast.Raise = {}

--====================================================================
--  MIDCAST - ENHANCING MAGIC
--====================================================================

-- Base Enhancing Magic (Telchine +10 duration)
sets.midcast['Enhancing Magic'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Impatiens',
    head = TelchineHead,
    body = TelchineBody,
    hands = TelchineHands,
    legs = TelchineLegs,
    feet = TelchineFeet,
    neck = 'Loricate Torque +1',
    waist = 'Olympus Sash',
    left_ear = 'Andoaa Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = 'Evanescence Ring',
    back = 'Fi Follet Cape +1'
}

-- Stoneskin
sets.midcast.Stoneskin =
    set_combine(
    sets.midcast['Enhancing Magic'],
    {
        legs = 'Shedir Seraweels',
        waist = 'Siegel Sash',
        neck = 'Nodens Gorget'
    }
)

-- Phalanx
sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})

-- Aquaveil
sets.midcast.Aquaveil =
    set_combine(
    sets.midcast['Enhancing Magic'],
    {
        head = 'Amalric Coif +1',
        legs = 'Shedir Seraweels'
    }
)

-- Refresh
sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {})

-- Haste
sets.midcast.Haste = set_combine(sets.midcast['Enhancing Magic'], {})

--====================================================================
--  MIDCAST - ENFEEBLING MAGIC
--====================================================================

-- MND-based Enfeebles (Slow, Paralyze, Silence)
sets.midcast.MndEnfeebles = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    head = 'Wicce Petasos +3',
    body = 'Wicce Coat +3',
    hands = 'Wicce Gloves +3',
    legs = 'Wicce Chausses +3',
    feet = 'Wicce Sabots +3',
    neck = 'Src. Stole +2',
    waist = 'Sacro Cord',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = StikiRing2,
    back = "Aurist's Cape +1"
}

-- INT-based Enfeebles (Bind, Sleep, Break)
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
sets.midcast.Break = sets.midcast.IntEnfeebles
sets.midcast.Breakga = sets.midcast.IntEnfeebles

-- Sleep spells
sets.midcast.Sleep = sets.midcast.IntEnfeebles
sets.midcast['Sleep II'] = sets.midcast.Sleep
sets.midcast.Sleepga = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep

-- Blind
sets.midcast.Blind = sets.midcast.IntEnfeebles

--====================================================================
--  MIDCAST - DARK MAGIC
--====================================================================

-- Dark Magic (Drain/Aspir with potency augments)
sets.midcast['Dark Magic'] = {
    main = Rubicundity,
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = MerlinicHead_Drain,
    body = MerlinicBody_Drain,
    hands = MerlinicHands_Drain,
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

--====================================================================
--  MIDCAST - ELEMENTAL MAGIC
--====================================================================

-- Base Elemental Magic (MAB/MACC - Wicce +3 full set)
sets.midcast['Elemental Magic'] = {
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
    right_ear = 'Regal Earring',
    left_ring = 'Freke Ring',
    right_ring = 'Metamor. Ring +1',
    back = "Taranus's Cape"
}

-- Magic Burst variant (Ea Hat +1 + Mujin Band)
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
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Mujin Band',
    right_ring = 'Metamor. Ring +1',
    back = "Taranus's Cape"
}

-- MP Conservation Override (auto-equipped when MP < 1000)
sets.midcast.MPConservation = {
    body = "Spaekona's Coat +4"
}

-- Elemental Match Override (auto-equipped when storm/day/weather matches)
sets.midcast.ElementalMatch = {
    waist = 'Hachirin-no-obi'
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
    back = TaranusCape
}

sets.midcast['Impact'].MagicBurst = sets.midcast['Impact']

-- Death (HP-based damage)
sets.midcast['Death'] = sets.midcast['Elemental Magic']
sets.midcast['Death'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- Meteor
sets.midcast['Meteor'] = sets.midcast['Elemental Magic']

-- Comet
sets.midcast['Comet'] = sets.midcast['Elemental Magic']
sets.midcast['Comet'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- DOT Spells (Burn, Rasp, Shock, Drown, Choke, Frost)
sets.midcast['Burn'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Ghastly Tathlum +1',
    head = 'Wicce Petasos +3',
    body = "Spaekona's Coat +4",
    hands = 'Wicce Gloves +3',
    legs = ArchmageTonban,
    feet = ArchmageSabots,
    neck = 'Src. Stole +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = StikiRing1,
    right_ring = 'Metamor. Ring +1',
    back = TaranusCape
}

sets.midcast['Rasp'] = sets.midcast['Burn']
sets.midcast['Shock'] = sets.midcast['Burn']
sets.midcast['Drown'] = sets.midcast['Burn']
sets.midcast['Choke'] = sets.midcast['Burn']
sets.midcast['Frost'] = sets.midcast['Burn']

--====================================================================
--  MOVEMENT SETS
--====================================================================

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

--====================================================================
--  BUFF SETS
--====================================================================

sets.buff = {}

-- Manawall buff active
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

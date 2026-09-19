---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Equipment Sets - Black Mage Nuker Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua  -- Cross-job wardrobe rings
---     • Tetsouo/sets/blm/armor.lua     -- AF / Relic / Empyrean / Merlinic / Telchine / Nyame
---     • Tetsouo/sets/blm/capes.lua     -- Taranus's Cape variants + plain capes
---     • Tetsouo/sets/blm/weapons.lua   -- Mains / subs / ammo references
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   Features:
---     • Elemental Magic mastery (Wicce +3 full set, Magic Burst capability)
---     • Fast Cast optimization (Merlinic augments, 80% FC cap)
---     • Dark Magic (Drain/Aspir potency augments)
---     • MP Conservation (Auto-equips when MP < 1000)
---     • Elemental Match (Auto-equips with storm/day/weather match)
---     • Magic Burst Mode (Toggle for burst damage gear)
---
---   @file    Tetsouo/sets/blm/blm_sets.lua
---   @author  Tetsouo
---   @version 4.0 - Modularized
---   @date    Updated: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/blm/armor')
local Capes   = require('Tetsouo/sets/blm/capes')
local Weapons = require('Tetsouo/sets/blm/weapons')

-- Local aliases for readability
local Wicce         = Armor.Wicce
local Spaekona      = Armor.Spaekona
local Archmage      = Armor.Archmage
local Nyame         = Armor.Nyame
local Agwu          = Armor.Agwu
local Ea            = Armor.Ea
local Amalric       = Armor.Amalric
local MerlinicFC    = Armor.MerlinicFC
local MerlinicDrain = Armor.MerlinicDrain
local Telchine      = Armor.Telchine
local Taranus       = Capes.Taranus
local Ammo          = Weapons.Ammo

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • NORMAL MODE (Refresh, PDT, MP Recovery)
sets.idle.Normal = {
    main      = Weapons.Mpaca,
    sub       = Weapons.Khonsu,
    ammo      = Ammo.Staunch,
    head      = Wicce.head,
    body      = Wicce.body,
    hands     = Armor.Misc.VolteGloves,
    legs      = Nyame.legs,
    feet      = Wicce.feet,
    neck      = 'Loricate Torque +1',
    waist     = 'Fucho-no-obi',
    left_ear  = 'Ethereal Earring',
    right_ear = 'Odnowa Earring +1',
    left_ring = Rings.Stikini1,
    right_ring = Rings.Stikini2,
    back      = Capes.SolemnityCape
}

-- • PDT MODE (Physical Damage Reduction)
sets.idle.PDT = set_combine(sets.idle.Normal, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • NORMAL MODE (BLM Rarely Melees)
sets.engaged.Normal = {
    main       = Weapons.MalignancePole,
    sub        = Weapons.Khonsu,
    ammo       = Ammo.Ghastly,
    head       = Wicce.head,
    body       = Wicce.body,
    hands      = Wicce.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = 'Sanctity Necklace',
    waist      = 'Windbuffet Belt +1',
    left_ear   = 'Crep. Earring',
    right_ear  = 'Telos Earring',
    left_ring  = Rings.Chirich1,
    right_ring = Rings.Chirich2,
    back       = Taranus.plain
}

-- • PDT MODE (Physical Damage Reduction)
sets.engaged.PDT = set_combine(sets.engaged.Normal, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST - FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.FC = {}

-- • BASE FAST CAST (80% Cap with Merlinic Augments)
sets.precast.FC = {
    main       = Weapons.Grioavolr,    -- 06% FC
    sub        = Weapons.Khonsu,
    ammo       = Ammo.Impatiens,        -- 02% Quick Magic
    head       = MerlinicFC.head,       -- 15% FC
    body       = MerlinicFC.body,       -- 13% FC
    hands      = MerlinicFC.hands,      -- 07% FC
    legs       = MerlinicFC.legs,       -- 05% FC
    feet       = MerlinicFC.feet,       -- 12% FC
    neck       = "Orunmila's Torque",   -- 05% FC
    waist      = 'Witful Belt',         -- 03% FC
    left_ear   = 'Malignance Earring',  -- 04% FC
    right_ear  = 'Loquac. Earring',     -- 02% FC
    left_ring  = 'Kishar Ring',         -- 04% FC
    right_ring = 'Lebeche Ring',        -- 02% Quick Magic
    back       = Capes.PerimedeCape     -- 04% Quick Magic
}

-- • Enhancing Magic Fast Cast
sets.precast.FC['Enhancing Magic'] = sets.precast.FC

-- • Elemental Magic Fast Cast
sets.precast.FC['Elemental Magic'] = sets.precast.FC

-- • Cure Fast Cast
sets.precast.FC.Cure   = sets.precast.FC
sets.precast.FC.Curaga = sets.precast.FC.Cure

-- • Impact Fast Cast (Twilight Cloak Required)
sets.precast.FC.Impact = set_combine(sets.precast.FC, {
    body = Armor.Misc.TwilightCloak
})

-- • Stoneskin Fast Cast
sets.precast.FC.Stoneskin = set_combine(sets.precast.FC, {
    head  = Armor.Misc.UmuthiHat,
    legs  = Armor.Misc.DoyenPants,
    waist = 'Siegel Sash'
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST - JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.JA = {}

-- • Mana Wall (Duration Extension)
sets.precast.JA['Mana Wall'] = {
    feet = Wicce.feet,
    back = Taranus.plain
}

-- • Manafont (MP Boost)
sets.precast.JA.Manafont = {
    body = Archmage.body
}

-- • Elemental Seal (No Specific Gear)
sets.precast.JA['Elemental Seal'] = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.WS = {}

-- • GENERIC WEAPONSKILL (Staff: Nyame Set)
sets.precast.WS = {
    ammo       = Ammo.Oshasha,
    head       = Nyame.head,
    body       = Nyame.body,
    hands      = Nyame.hands,
    legs       = Nyame.legs,
    feet       = Nyame.feet,
    neck       = 'Fotia Gorget',
    waist      = 'Fotia Belt',
    left_ear   = 'Moonshade Earring',
    right_ear  = 'Mache Earring +1',
    left_ring  = "Cornelia's Ring",
    right_ring = 'Chirich Ring +1',
    back       = Taranus.plain
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • CURE (Self-Healing with Daybreak)
sets.midcast.Cure = {
    main       = Weapons.Daybreak,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Staunch,
    head       = Wicce.head,
    body       = Nyame.body,
    hands      = Telchine.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = 'Nodens Gorget',
    waist      = 'Plat. Mog. Belt',
    left_ear   = "Handler's Earring",
    right_ear  = {
        name = 'Wicce Earring +2',
        augments = {'System: 1 ID: 1676 Val: 0', 'Mag. Acc.+14', 'Enmity-4'}
    },
    left_ring  = 'Murky Ring',
    right_ring = Rings.Stikini2,
    back       = Capes.SolemnityCape
}

-- • Curaga
sets.midcast.Curaga = sets.midcast.Cure

-- • Raise
sets.midcast.Raise = {}

-- • ENHANCING MAGIC (Telchine +10 Duration)
sets.midcast['Enhancing Magic'] = {
    main       = Weapons.Daybreak,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Impatiens,
    head       = Telchine.head,
    body       = Telchine.body,
    hands      = Telchine.hands,
    legs       = Telchine.legs,
    feet       = Telchine.feet,
    neck       = 'Loricate Torque +1',
    waist      = 'Olympus Sash',
    left_ear   = 'Andoaa Earring',
    right_ear  = 'Regal Earring',
    left_ring  = Rings.Stikini1,
    right_ring = 'Evanescence Ring',
    back       = Capes.FiFolletCape
}

-- • Stoneskin (HP Boost)
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
    legs  = Armor.Misc.ShedirSerawels,
    waist = 'Siegel Sash',
    neck  = 'Nodens Gorget'
})

-- • Phalanx (Damage Reduction)
sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})

-- • Aquaveil (Interrupt Prevention)
sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {
    head = Amalric.head,
    legs = Armor.Misc.ShedirSerawels
})

-- • Refresh (MP Regeneration)
sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {})

-- • Haste (Cast Speed)
sets.midcast.Haste = set_combine(sets.midcast['Enhancing Magic'], {})

-- • ENFEEBLING MAGIC (MND-Based: Slow, Paralyze, Silence)
sets.midcast.MndEnfeebles = {
    main       = Weapons.Daybreak,
    sub        = Weapons.Ammurapi,
    head       = Wicce.head,
    body       = Wicce.body,
    hands      = Wicce.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = 'Src. Stole +2',
    waist      = 'Sacro Cord',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Regal Earring',
    left_ring  = Rings.Stikini1,
    right_ring = Rings.Stikini2,
    back       = Capes.AuristCape
}

-- • INT-BASED ENFEEBLES (Bind, Sleep, Break)
sets.midcast.IntEnfeebles = {
    main       = Weapons.Bunzi,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Ghastly,
    head       = Wicce.head,
    body       = Wicce.body,
    hands      = Wicce.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = 'Src. Stole +2',
    waist      = 'Acuity Belt +1',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Wicce Earring +2',
    left_ring  = 'Metamor. Ring +1',
    right_ring = Rings.Stikini2,
    back       = Taranus.plain
}

-- • Break Spells
sets.midcast.Break   = sets.midcast.IntEnfeebles
sets.midcast.Breakga = sets.midcast.IntEnfeebles

-- • Sleep Spells
sets.midcast.Sleep         = sets.midcast.IntEnfeebles
sets.midcast['Sleep II']   = sets.midcast.Sleep
sets.midcast.Sleepga       = sets.midcast.Sleep
sets.midcast['Sleepga II'] = sets.midcast.Sleep

-- • Blind
sets.midcast.Blind = sets.midcast.IntEnfeebles

-- • DARK MAGIC (Drain/Aspir with Potency Augments)
sets.midcast['Dark Magic'] = {
    main       = Weapons.Rubicundity,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Ghastly,
    head       = MerlinicDrain.head,
    body       = MerlinicDrain.body,
    hands      = MerlinicDrain.hands,
    legs       = Wicce.legs,
    feet       = Agwu.feet,
    neck       = 'Erra Pendant',
    waist      = 'Fucho-no-Obi',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Wicce Earring +2',
    left_ring  = 'Metamor. Ring +1',
    right_ring = 'Evanescence Ring',
    back       = Taranus.plain
}

-- • Drain
sets.midcast.Drain = sets.midcast['Dark Magic']

-- • Aspir
sets.midcast.Aspir = sets.midcast['Dark Magic']

-- • ELEMENTAL MAGIC (MAB/MACC - Wicce +3 Full Set)
sets.midcast['Elemental Magic'] = {
    main       = Weapons.Bunzi,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Sroda,
    head       = Wicce.head,
    body       = Wicce.body,
    hands      = Wicce.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = "Sorcerer's Stole +2",
    waist      = 'Sacro Cord',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Regal Earring',
    left_ring  = 'Freke Ring',
    right_ring = 'Metamor. Ring +1',
    back       = Taranus.plain
}

-- • Magic Burst Variant (Ea Hat +1 + Mujin Band)
sets.midcast['Elemental Magic'].MagicBurst = {
    main       = Weapons.Bunzi,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Sroda,
    head       = Ea.head,
    body       = Wicce.body,
    hands      = Agwu.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = "Sorcerer's Stole +2",
    waist      = 'Sacro Cord',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Regal Earring',
    left_ring  = 'Freke Ring',
    right_ring = 'Mujin Band',
    back       = Taranus.plain
}

-- • Magic Burst Accuracy Variant (MagicBurstMode: Acc - trades potency for Mag.Acc)
sets.midcast['Elemental Magic'].MagicBurst.acc = set_combine(sets.midcast['Elemental Magic'].MagicBurst, {
    ammo       = Ammo.Ghastly,
    head       = Wicce.head,
    hands      = Wicce.hands,
    neck       = "Sorcerer's Stole +2",
    waist      = 'Hachirin-no-Obi',
    right_ear  = 'Wicce Earring +2',
    right_ring = 'Metamor. Ring +1',
    back       = Taranus.mab
})

-- • MP Conservation Override (Auto-equipped when MP < 1000)
sets.midcast.MPConservation = {
    body = Spaekona.body
}

-- • Elemental Match Override (Auto-equipped when Storm/Day/Weather matches)
sets.midcast.ElementalMatch = {
    waist = 'Hachirin-no-obi'
}

-- • Stone-Line Override (Quanpur Necklace - Stone/Stoneja/Stonera only)
sets.midcast.QuanpurStone = {
    neck = 'Quanpur Necklace'
}

-- • Impact (Twilight Cloak Required)
sets.midcast['Impact'] = {
    main       = Weapons.Bunzi,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Ghastly,
    body       = Armor.Misc.TwilightCloak,
    hands      = Wicce.hands,
    legs       = Wicce.legs,
    feet       = Wicce.feet,
    neck       = 'Src. Stole +2',
    waist      = 'Acuity Belt +1',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Regal Earring',
    left_ring  = Rings.Stikini1,
    right_ring = 'Metamor. Ring +1',
    back       = Taranus.mab
}

sets.midcast['Impact'].MagicBurst = sets.midcast['Impact']

-- • Death (HP-Based Damage)
sets.midcast['Death']            = sets.midcast['Elemental Magic']
sets.midcast['Death'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- • Meteor
sets.midcast['Meteor'] = sets.midcast['Elemental Magic']

-- • Comet
sets.midcast['Comet']            = sets.midcast['Elemental Magic']
sets.midcast['Comet'].MagicBurst = sets.midcast['Elemental Magic'].MagicBurst

-- • DOT SPELLS (Burn, Rasp, Shock, Drown, Choke, Frost)
sets.midcast['Burn'] = {
    main       = Weapons.Bunzi,
    sub        = Weapons.Ammurapi,
    ammo       = Ammo.Ghastly,
    head       = Wicce.head,
    body       = Spaekona.body,
    hands      = Wicce.hands,
    legs       = Archmage.legs,
    feet       = Archmage.feet,
    neck       = 'Src. Stole +2',
    waist      = 'Acuity Belt +1',
    left_ear   = 'Malignance Earring',
    right_ear  = 'Regal Earring',
    left_ring  = Rings.Stikini1,
    right_ring = 'Metamor. Ring +1',
    back       = Taranus.mab
}

sets.midcast['Rasp']  = sets.midcast['Burn']
sets.midcast['Shock'] = sets.midcast['Burn']
sets.midcast['Drown'] = sets.midcast['Burn']
sets.midcast['Choke'] = sets.midcast['Burn']
sets.midcast['Frost'] = sets.midcast['Burn']

-- ═══════════════════════════════════════════════════════════════════════════
-- SPECIAL SETS (Movement & Buffs)
-- ═══════════════════════════════════════════════════════════════════════════

-- • MOVEMENT SPEED
sets.MoveSpeed = {
    feet = Armor.Misc.HeraldGaiters
}

-- • TOWN MODE (Movement Speed)
sets.idle.Town = set_combine(sets.idle.PDT, sets.MoveSpeed)

-- • ADOULIN MOVEMENT (City-Specific Speed Boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = Armor.Misc.CouncilorGarb
})

-- • BUFF SETS
sets.buff = {}

-- • MANA WALL ACTIVE
sets.buff['Mana Wall'] = {
    feet = Wicce.feet,
    back = Taranus.plain
}

-- • DOOM RESISTANCE
sets.buff.Doom = {
    neck  = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    waist = 'Gishdubar Sash'
}

print('[BLM] Equipment sets loaded successfully (modular v4.0)')

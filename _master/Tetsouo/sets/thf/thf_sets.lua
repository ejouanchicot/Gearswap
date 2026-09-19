---  ═══════════════════════════════════════════════════════════════════════════
---   THF Equipment Sets - Ultimate Thief Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua  -- Cross-job wardrobe rings
---     • Tetsouo/sets/thf/armor.lua     -- Plunderer / Pillager / Skulker / Nyame / Malignance / etc.
---     • Tetsouo/sets/thf/capes.lua     -- Toutatis's Cape variants (STP / WS1 / WS2) + Canny
---     • Tetsouo/sets/thf/weapons.lua   -- Daggers / Swords / Abyssea proc weapons
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   Features:
---     • Weapon sets (Main: Vajra/Twashtar/Tauret/Naegling, Sub: Centovente/Gleti)
---     • Abyssea proc sets (7 weapon types for /WAR subjob)
---     • Idle / Engaged / PDT / PDTAFM3 sets
---     • Job ability sets (SA/TA/Hide/Flee/Perfect Dodge/Conspirator)
---     • Weaponskills with SA/TA/SATA variants (Rudra's, Evisceration, Shark Bite, etc.)
---     • Treasure Hunter sets (Tag/SATA combinations)
---
---   @file    Tetsouo/sets/thf/thf_sets.lua
---   @author  Tetsouo
---   @version 4.0 - Modularized
---   @date    Updated: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/thf/armor')
local Capes   = require('Tetsouo/sets/thf/capes')
local Weapons = require('Tetsouo/sets/thf/weapons')

-- Local aliases for readability
local Skulker    = Armor.Skulker
local Pillager   = Armor.Pillager
local Plunderer  = Armor.Plunderer
local Adhemar    = Armor.Adhemar
local Nyame      = Armor.Nyame
local Malignance = Armor.Malignance
local Gleti      = Armor.Gleti
local Meghanada  = Armor.Meghanada
local Mummu      = Armor.Mummu
local Toutatis   = Capes.Toutatis

-- Local augmented earring (THF-specific TP-bonus Moonshade)
local MoonShadeEarring = {
    name = 'Moonshade Earring',
    augments = {'Accuracy+4', 'TP Bonus +250'}
}

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from thf/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE IDLE (Refresh/Regen focus - Gleti's set)
sets.idle = {
    ammo  = 'Aurgelmir Orb +1',
    head  = Gleti.head,
    body  = Gleti.body,
    hands = Gleti.hands,
    legs  = Gleti.legs,
    feet  = Gleti.feet,
    neck  = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    ear1  = 'Sherida Earring',
    ear2  = 'Eabani Earring',
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back  = 'Solemnity Cape'
}

-- • REGEN IDLE (HP regeneration focus - Meghanada)
sets.idle.Regen = set_combine(sets.idle, {
    head  = Meghanada.head,
    body  = Meghanada.body,
    hands = Meghanada.hands,
    legs  = Meghanada.legs,
    feet  = Meghanada.feet,
    ear1  = 'Dawn Earring',
    ear2  = 'Infused Earring'
})

-- • PDT IDLE (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle, {
    ring2 = 'Murky Ring'
})

-- • WEAK IDLE (Low HP)
sets.idle.Weak = sets.idle

-- • TOWN IDLE (Movement speed)
sets.idle.Town = set_combine(sets.idle.PDT, {feet = Pillager.feet})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE ENGAGED (DPS focus)
sets.engaged = {
    ammo  = 'Coiste Bodhar',
    head  = Malignance.head,
    body  = Malignance.body,
    hands = Malignance.hands,
    legs  = Malignance.legs,
    feet  = Skulker.feet,
    neck  = 'Iskur Gorget',
    waist = 'Sailfi Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = Skulker.earring,
    ring1 = Rings.Moonlight1,
    ring2 = "Hoxne Ring",
    back  = Toutatis.STP
}

-- • PDT ENGAGED (Defense while engaged)
sets.engaged.PDT = {
    ammo  = 'Coiste Bodhar',
    head  = Malignance.head,
    body  = Malignance.body,
    hands = Malignance.hands,
    legs  = Malignance.legs,
    feet  = Skulker.feet,
    neck  = 'Iskur Gorget',
    waist = 'Sailfi Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = Skulker.earring,
    ring1 = Rings.Moonlight1,
    ring2 = "Hoxne Ring",
    back  = Toutatis.STP
}

-- • PDT + Aftermath Lv.3 (For mythic/empyrean weapons with Aftermath)
sets.engaged.PDTAFM3 = {
    ammo  = 'Aurgelmir Orb +1',
    head  = Malignance.head,
    body  = Malignance.body,
    hands = Adhemar.hands_plain,
    legs  = Malignance.legs,
    feet  = Skulker.feet,
    neck  = 'Iskur Gorget',
    waist = 'Windbuffet Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = Skulker.earring,
    ring1 = Rings.Moonlight1,
    ring2 = "Hoxne Ring",
    back  = Toutatis.STP
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • Sneak Attack
sets.precast.JA['Sneak Attack'] = {
    ammo  = 'Yetshila +1',
    head  = Adhemar.head,
    body  = Pillager.body,
    hands = Skulker.hands,
    legs  = Armor.Misc.LustrSubligar,
    feet  = Skulker.feet,
    neck  = 'Asn. Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1  = 'Mache Earring +1',
    ear2  = 'Odr Earring',
    ring1 = 'Regal Ring',
    ring2 = 'Ilabrat Ring',
    back  = Toutatis.STP
}

-- • Trick Attack
sets.precast.JA['Trick Attack'] = {
    ammo  = 'Yetshila +1',
    head  = Skulker.head,
    body  = Plunderer.body_ambush,
    hands = Pillager.hands,
    legs  = Pillager.legs,
    feet  = Skulker.feet,
    neck  = 'Asn. Gorget +2',
    waist = 'Svelt. Gouriz +1',
    ear1  = 'Dawn Earring',
    ear2  = 'Infused Earring',
    ring1 = 'Regal Ring',
    ring2 = 'Ilabrat Ring',
    back  = Capes.Canny
}

-- • Hide
sets.precast.JA.Hide = {body = Pillager.body}

-- • Flee
sets.precast.JA['Flee'] = {feet = Pillager.feet}

-- • Perfect Dodge
sets.precast.JA['Perfect Dodge'] = {hands = Plunderer.hands_perfect_dodge}

-- • Feint
sets.precast.JA['Feint'] = {legs = Plunderer.legs_feint}

-- • Steal
sets.precast.JA['Steal'] = {
    neck  = 'Pentalagus Charm',
    hands = Armor.Misc.ThiefsKote,
    legs  = Armor.Misc.AssassinsCulottes,
    feet  = Pillager.feet
}

-- • Despoil
sets.precast.JA['Despoil'] = {
    legs = Skulker.legs,
    feet = Skulker.feet
}

-- • Collaborator / Accomplice
sets.precast.JA['Collaborator'] = {
    head  = Skulker.head,
    body  = Plunderer.body,
    hands = Plunderer.hands,
    ear1  = 'Friomisi Earring',
    ring1 = 'Cacoethic Ring'
}
sets.precast.JA['Accomplice'] = sets.precast.JA['Collaborator']

-- • Conspirator
sets.precast.JA['Conspirator'] = {body = Skulker.body}

-- • Animated Flourish / Provoke
sets.precast.JA['Animated Flourish'] = {
    ammo  = 'Sapience Orb',
    head  = Skulker.head,
    body  = Plunderer.body,
    hands = Skulker.hands,
    legs  = Skulker.legs,
    feet  = Skulker.feet,
    neck  = 'Unmoving Collar +1',
    waist = 'Svelt. Gouriz +1',
    ear1  = 'Friomisi Earring',
    ear2  = 'Eabani Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back  = 'Solemnity Cape'
}
sets.precast.JA.Provoke = sets.precast.JA['Animated Flourish']

-- • Waltz (Curing Waltz, etc.)
sets.precast.Waltz = {
    ammo  = 'Staunch Tathlum +1',
    head  = Mummu.head,
    body  = Armor.Misc.TurmsHarness,
    hands = Armor.Misc.SlitherGloves,
    legs  = Armor.Misc.DashingSubligar,
    feet  = Meghanada.feet,
    neck  = 'Elite Royal Collar',
    waist = 'Flume Belt +1',
    ear1  = 'Delta Earring',
    ear2  = "Handler's Earring",
    ring1 = 'Asklepian Ring',
    ring2 = "Valseur's Ring",
    back  = 'Solemnity Cape'
}

-- • Step
sets.precast.Step = {
    ammo  = 'Aurgelmir Orb +1',
    head  = Malignance.head,
    body  = Pillager.body,
    hands = Meghanada.hands,
    legs  = Malignance.legs,
    feet  = Malignance.feet,
    neck  = 'Asn. Gorget +2',
    waist = 'Kentarch Belt +1',
    ear1  = 'Crepuscular Earring',
    ear2  = Skulker.earring,
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back  = Toutatis.STP
}

sets.precast.Flourish1 = sets.precast.JA.Provoke

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.FC = {
    ammo  = 'Sapience Orb',
    head  = Armor.Misc.HerculeanHelmTH,
    body  = Armor.Misc.DreadJupon,
    hands = Armor.Misc.LeylineGloves,
    legs  = Armor.Misc.EnifCosciales,
    neck  = 'Voltsurge Torque',
    ear1  = 'Enchntr. Earring +1',
    ear2  = 'Loquac. Earring',
    ring2 = 'Prolix Ring'
}

sets.precast.FC.Utsusemi = sets.precast.FC

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base WS Set (fallback)
sets.precast.WS = {
    ammo  = 'Yetshila +1',
    head  = Adhemar.head,
    body  = Plunderer.body,
    hands = Adhemar.hands,
    legs  = Pillager.legs,
    feet  = Armor.Misc.LustraLeggings,
    neck  = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1  = MoonShadeEarring,
    ear2  = 'Odr Earring',
    ring1 = 'Regal Ring',
    ring2 = "Cornelia's Ring",
    back  = Toutatis.WS2
}

-- • Rudra's Storm (Main THF WS - DEX - Crit damage)
sets.precast.WS["Rudra's Storm"] = {
    ammo  = 'Aurgelmir Orb +1',
    head  = Nyame.head,
    body  = Skulker.body,
    hands = Skulker.hands,
    legs  = Plunderer.legs,
    feet  = Nyame.feet,
    neck  = 'Loricate Torque +1',
    waist = 'Kentarch Belt +1',
    ear1  = 'Odr Earring',
    ear2  = 'Domin. Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Toutatis.WS2
}

sets.precast.WS["Rudra's Storm"].SA = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo = 'Yetshila +1',
    head = Pillager.head,
    legs = Skulker.legs,
    feet = Nyame.feet,
    neck = 'Asn. Gorget +2'
})

sets.precast.WS["Rudra's Storm"].TA = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo = 'Yetshila +1',
    head = Pillager.head,
    feet = Skulker.feet,
    ear1 = 'Odnowa Earring +1'
})

sets.precast.WS["Rudra's Storm"].SATA = set_combine(sets.precast.WS["Rudra's Storm"], {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    legs  = Skulker.legs,
    ear1  = 'Odnowa Earring +1',
    ear2  = 'Domin. Earring +1',
    ring1 = 'Regal Ring',
    ring2 = "Cornelia's Ring"
})

-- • Evisceration (Multi-hit crit WS)
sets.precast.WS['Evisceration'] = {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    body  = Plunderer.body,
    hands = Skulker.hands,
    legs  = Skulker.legs,
    feet  = Skulker.feet,
    neck  = 'Asn. Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = Skulker.earring,
    ring1 = 'Regal Ring',
    ring2 = 'Moonlight Ring',
    back  = Toutatis.WS2
}

sets.precast.WS['Evisceration'].SA = set_combine(sets.precast.WS['Evisceration'], {
    waist = 'Kentarch Belt +1',
    ear2  = 'Domin. Earring +1'
})

sets.precast.WS['Evisceration'].TA = set_combine(sets.precast.WS['Evisceration'], {
    legs  = Pillager.legs,
    ear1  = 'Odnowa Earring +1',
    ear2  = 'Odr Earring',
    ring1 = 'Murky Ring',
    ring2 = 'Moonlight Ring'
})

sets.precast.WS['Evisceration'].SATA = set_combine(sets.precast.WS['Evisceration'], {
    waist = 'Kentarch Belt +1',
    ear2  = 'Domin. Earring +1'
})

-- • Exenterator (Multi-hit AGI WS)
sets.precast.WS['Exenterator'] = {
    ammo  = 'Coiste Bodhar',
    head  = Skulker.head,
    body  = Skulker.body,
    hands = Skulker.hands,
    legs  = Meghanada.legs,
    feet  = Skulker.feet,
    neck  = 'Asn. Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Odnowa Earring +1',
    ear2  = Skulker.earring,
    ring1 = 'Regal Ring',
    ring2 = 'Murky Ring',
    back  = Toutatis.WS2
}

sets.precast.WS['Exenterator'].SA = set_combine(sets.precast.WS['Exenterator'], {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    legs  = Skulker.legs,
    ear1  = 'Sherida Earring',
    ear2  = Skulker.earring,
    ring2 = 'Moonlight Ring'
})

sets.precast.WS['Exenterator'].TA = set_combine(sets.precast.WS['Exenterator'], {
    ammo  = 'Crepuscular Pebble',
    head  = Pillager.head,
    hands = Pillager.hands,
    legs  = Skulker.legs
})

sets.precast.WS['Exenterator'].SATA = set_combine(sets.precast.WS['Exenterator'], {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    body  = Plunderer.body,
    legs  = Skulker.legs,
    ear1  = 'Sherida Earring',
    ear2  = 'Odr Earring',
    ring2 = 'Moonlight Ring'
})

-- • Savage Blade (STR/MND WS for Naegling)
sets.precast.WS['Savage Blade'] = {
    ammo  = 'Seeth. Bomblet +1',
    head  = Pillager.head,
    body  = Skulker.body,
    hands = Skulker.hands,
    legs  = Plunderer.legs,
    feet  = Skulker.feet,
    neck  = 'Loricate Torque +1',
    waist = 'Sailfi Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = 'Odnowa Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Toutatis.WS2
}

sets.precast.WS['Savage Blade'].SA = set_combine(sets.precast.WS['Savage Blade'], {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    legs  = Skulker.legs,
    neck  = 'Null Loop',
    ear1  = 'Sherida Earring',
    ear2  = 'Ishvara Earring',
    ring1 = 'Regal Ring'
})

sets.precast.WS['Savage Blade'].TA = set_combine(sets.precast.WS['Savage Blade'], {
    ammo = 'Yetshila +1',
    head = Pillager.head,
    neck = 'Null Loop',
    ear1 = 'Ishvara Earring'
})

sets.precast.WS['Savage Blade'].SATA = set_combine(sets.precast.WS['Savage Blade'], {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    ear1  = 'Ishvara Earring',
    ear2  = 'Odnowa Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring"
})

-- • Shark Bite (DEX/MND WS)
sets.precast.WS['Shark Bite'] = {
    ammo  = 'Coiste Bodhar',
    head  = Pillager.head,
    body  = Skulker.body,
    hands = Skulker.hands,
    legs  = Plunderer.legs,
    feet  = Skulker.feet,
    neck  = 'Loricate Torque +1',
    waist = 'Sailfi Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = 'Odnowa Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Toutatis.WS2
}

sets.precast.WS['Shark Bite'].SA = set_combine(sets.precast.WS['Shark Bite'], {
    ammo  = 'Yetshila +1',
    waist = 'Kentarch Belt +1',
    ear1  = 'Ishvara Earring'
})

sets.precast.WS['Shark Bite'].TA = set_combine(sets.precast.WS['Shark Bite'], {
    ammo = 'Yetshila +1',
    ear1 = 'Ishvara Earring',
    ear2 = 'Odnowa Earring +1'
})

sets.precast.WS['Shark Bite'].SATA = set_combine(sets.precast.WS['Shark Bite'], {
    ammo  = 'Yetshila +1',
    waist = 'Kentarch Belt +1',
    ear1  = 'Ishvara Earring',
    ear2  = 'Odnowa Earring +1'
})

-- • Mandalic Stab (DEX WS)
sets.precast.WS['Mandalic Stab'] = {
    ammo  = 'Coiste Bodhar',
    head  = Nyame.head,
    body  = Skulker.body,
    hands = Skulker.hands,
    legs  = Plunderer.legs,
    feet  = Skulker.feet,
    neck  = 'Asn. Gorget +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Sherida Earring',
    ear2  = 'Odnowa Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Toutatis.WS2
}

sets.precast.WS['Mandalic Stab'].SA = set_combine(sets.precast.WS['Mandalic Stab'], {
    ammo  = 'Crepuscular Pebble',
    head  = Pillager.head,
    feet  = Nyame.feet,
    neck  = 'Loricate Torque +1',
    waist = 'Kentarch Belt +1',
    ear1  = 'Odr Earring',
    ear2  = 'Odnowa Earring +1'
})

sets.precast.WS['Mandalic Stab'].TA = set_combine(sets.precast.WS['Mandalic Stab'], {
    ammo  = 'Yetshila +1',
    head  = Pillager.head,
    legs  = Gleti.legs,
    waist = 'Kentarch Belt +1',
    ear1  = 'Odr Earring',
    ear2  = 'Domin. Earring +1'
})

sets.precast.WS['Mandalic Stab'].SATA = set_combine(sets.precast.WS['Mandalic Stab'], {
    ammo  = 'Crepuscular Pebble',
    head  = Pillager.head,
    body  = Gleti.body,
    feet  = Nyame.feet,
    waist = 'Kentarch Belt +1',
    ear1  = 'Odr Earring',
    ear2  = 'Domin. Earring +1'
})

-- • Aeolian Edge (Magical WS)
sets.precast.WS['Aeolian Edge'] = {
    ammo  = 'Seeth. Bomblet +1',
    head  = Nyame.head,
    body  = Nyame.body,
    hands = Nyame.hands,
    legs  = Nyame.legs,
    feet  = Skulker.feet,
    neck  = 'Sibyl Scarf',
    waist = "Orpheus's Sash",
    ear1  = 'Sortiarius Earring',
    ear2  = 'Friomisi Earring',
    ring1 = "Epaminondas's Ring",
    ring2 = "Hoxne Ring",
    back  = Toutatis.WS2
}

-- • Dancing Edge (DEX WS)
sets.precast.WS['Dancing Edge'] = set_combine(sets.precast.WS, {})

sets.precast.WS['Dancing Edge'].SA = set_combine(sets.precast.WS['Dancing Edge'], {
    hands = Skulker.hands
})

sets.precast.WS['Dancing Edge'].TA = set_combine(sets.precast.WS['Dancing Edge'], {
    hands = Pillager.hands
})

sets.precast.WS['Dancing Edge'].SATA = sets.precast.WS['Dancing Edge'].TA

-- • Circle Blade (STR/DEX WS)
sets.precast.WS['Circle Blade'] = {
    ammo  = "Oshasha's Treatise",
    head  = Skulker.head,
    body  = Skulker.body,
    hands = Skulker.hands,
    legs  = Pillager.legs,
    feet  = Plunderer.feet_ac,
    neck  = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1  = 'Ishvara Earring',
    ear2  = Skulker.earring,
    ring1 = 'Ilabrat Ring',
    ring2 = 'Mummu Ring',
    back  = Toutatis.WS2
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: RANGED ATTACK
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.RA = {
    range = 'Exalted Crossbow',
    ammo  = 'Acid Bolt',
    head  = Malignance.head,
    body  = Malignance.body,
    hands = Malignance.hands,
    legs  = Malignance.legs,
    feet  = Skulker.feet,
    neck  = 'Null Loop',
    waist = 'Yemaya Belt',
    ear1  = 'Crepuscular Earring',
    ear2  = 'Telos Earring',
    ring1 = 'Cacoethic Ring',
    ring2 = "Hoxne Ring",
    back  = 'Sacro Mantle'
}

sets.precast.RATH = set_combine(sets.precast.RA, {feet = Skulker.feet})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • Ranged Midcast
sets.midcast.RA = sets.precast.RA
sets.midcast.RA.Acc = sets.midcast.RA

-- • Cure Midcast (for /WHM subjob)
sets.midcast.Cure = {}

-- • Enhancing Magic
sets.midcast.EnhancingMagic = {}

-- • Fast Recast
sets.midcast.FastRecast = {
    ammo  = 'Aurgelmir Orb +1',
    head  = Skulker.head,
    body  = Nyame.body,
    hands = Skulker.hands,
    legs  = Skulker.legs,
    feet  = Skulker.feet,
    neck  = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    ear1  = 'Sherida Earring',
    ear2  = 'Eabani Earring',
    ring1 = Rings.Chirich2,
    ring2 = 'Murky Ring',
    back  = 'Solemnity Cape'
}

sets.midcast.Utsusemi = sets.midcast.FastRecast

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    feet  = Pillager.feet,
    ring1 = 'Murky Ring'
}

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {body = Armor.Misc.CouncilorsGarb})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}
sets.buff['Sneak Attack'] = sets.precast.JA['Sneak Attack']
sets.buff['Trick Attack'] = sets.precast.JA['Trick Attack']

-- • Doom Resistance
sets.buff.Doom = {
    neck  = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    ring2 = "Blenmot's Ring +1",
    waist = 'Gishdubar Sash'
}

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base TreasureHunter (Skulker feet provide TH+4)
sets.TreasureHunter = {
    feet = Skulker.feet,
    ring2 = "Hoxne Ring"
}

-- • TH with SA/TA (Combined sets)
sets.TreasureHunterSA   = set_combine(sets.TreasureHunter, sets.precast.JA['Sneak Attack'])
sets.TreasureHunterTA   = set_combine(sets.TreasureHunter, sets.precast.JA['Trick Attack'])
sets.TreasureHunterSATA = set_combine(sets.TreasureHunter, sets.precast.JA['Sneak Attack'], sets.precast.JA['Trick Attack'])

-- • TH Ranged
sets.TreasureHunterRA = set_combine(sets.precast.RA, {feet = Skulker.feet})

sets.midcast.RA.TH = set_combine(sets.precast.RA, {})

-- • Aeolian Edge TH
sets.AeolianTH = set_combine(sets.precast.WS['Aeolian Edge'], {feet = Skulker.feet})

-- • Engaged with TH
sets.engaged.TH = set_combine(sets.engaged, sets.TreasureHunter)

---============================================================================
--- INITIALIZATION MESSAGE
---============================================================================

print('[THF] Equipment sets loaded successfully')

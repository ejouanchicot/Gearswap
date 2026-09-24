---  ═══════════════════════════════════════════════════════════════════════════
---   COR Equipment Sets - Ultimate Corsair Gunslinger Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua  -- Cross-job wardrobe rings
---     • Tetsouo/sets/cor/armor.lua     -- Lanun / Chasseur / Laksamana / Malignance / Nyame
---     • Tetsouo/sets/cor/capes.lua     -- Camulus's Mantle variants
---     • Tetsouo/sets/cor/weapons.lua   -- Naegling / Rostam / Anarchy / Compensator
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   Features:
---     • Phantom Roll optimization (Lanun +4, Chasseur +3, Rostam augmented)
---     • Quick Draw magic damage (Malignance set, Magic Attack Bonus)
---     • Ranged attack excellence (Snapshot, Rapid Shot, Store TP)
---     • Melee DPS capability (Dual Wield support, Malignance hybrid)
---     • Savage Blade weaponskill (Nyame Path B, Camulus WSD cape)
---     • Roll-specific gear (Caster's, Courser's, Blitzer's, Tactician's, Allies')
---     • Movement speed optimization (Carmine Cuisses +1)
---     • Hybrid survivability (PDT sets with Malignance)
---
---   @file    Tetsouo/sets/cor/cor_sets.lua
---   @author  Tetsouo
---   @version 4.0 - Modularized
---   @date    Created: 2026-05-11 (modular split)
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/cor/armor')
local Capes   = require('Tetsouo/sets/cor/capes')
local Weapons = require('Tetsouo/sets/cor/weapons')

-- Local aliases for readability
local Lanun       = Armor.Lanun
local Chasseur    = Armor.Chasseur
local Laksamana   = Armor.Laksamana
local Malignance  = Armor.Malignance
local Nyame       = Armor.Nyame
local Camulus     = Capes.Camulus

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from cor/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle
sets.idle = {}
sets.idle.Normal = {
    -- Weapons applied by SetBuilder based on subjob (DW for NIN/DNC, single for others)
    ammo       = 'Bronze Bullet',
    head       = Lanun.head,
    body       = Armor.Misc.AdamantiteArmor,
    hands      = Chasseur.hands_g3,
    legs       = Armor.Misc.CarmineCuisses,
    feet       = Lanun.feet,
    neck       = 'Regal Necklace',
    waist      = 'Plat. Mog. Belt',
    left_ear   = 'Ethereal Earring',
    right_ear  = Chasseur.earring_e1,
    left_ring  = "Luzaf's Ring",
    right_ring = 'Woltaris Ring',
    back       = Camulus.plain
}

-- • PDT Idle (Physical Damage Taken -)
sets.idle.PDT = set_combine(sets.idle.Normal, {
    head       = Malignance.head,
    body       = Malignance.body,
    hands      = Malignance.hands,
    feet       = Malignance.feet,
    left_ring  = 'Murky Ring',
    right_ring = Rings.Chirich1
})

-- • Refresh Idle (MP recovery)
sets.idle.Refresh = set_combine(sets.idle.Normal, {
    -- Refresh gear
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Engaged
sets.engaged = {}

sets.engaged.Normal = {
    -- Weapons applied by SetBuilder based on subjob (DW for NIN/DNC, single for others)
    ammo       = 'Bronze Bullet',
    head       = Malignance.head,
    body       = Malignance.body,
    hands      = Malignance.hands,
    legs       = Chasseur.legs_c3,
    feet       = Malignance.feet,
    neck       = 'Iskur Gorget',
    waist      = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear   = 'Dedition Earring',
    right_ear  = Chasseur.earring_e1,
    left_ring  = 'Murky Ring',
    right_ring = 'Chirich Ring +1',
    back       = Camulus.plain
}

-- • PDT Melee (Hybrid)
sets.engaged.PDT = set_combine(sets.engaged.Normal, {
    head      = Malignance.head,
    body      = Malignance.body,
    hands     = Malignance.hands,
    feet      = Malignance.feet,
    left_ear  = 'Crepuscular Earring',
    left_ring = 'Murky Ring',
    waist     = 'Kentarch Belt +1',
    back      = 'Null Shawl'
})

-- • Dual Wield Engaged
sets.engaged.DW = set_combine(sets.engaged.Normal, {
    -- Dual Wield gear (for /NIN)
    -- ear1 = "Suppanomimi",
    -- ear2 = "Eabani Earring",
})

sets.engaged.DW.PDT = set_combine(sets.engaged.DW, {
    head      = Malignance.head,
    body      = Malignance.body,
    hands     = Malignance.hands,
    feet      = Malignance.feet,
    left_ring = 'Murky Ring',
    back      = 'Null Shawl'
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • Phantom Roll (Base set for all rolls)
--   Mote looks for sets.precast.CorsairRoll when spell.type == 'CorsairRoll'
sets.precast.CorsairRoll = {
    main       = {name = 'Rostam', augments = {'Path: C'}},
    range      = 'Compensator',
    head       = Lanun.head,
    body       = Armor.Misc.AdamantiteArmor,
    hands      = Chasseur.hands_g3,
    legs       = Armor.Misc.CarmineCuisses,
    feet       = Lanun.feet,
    neck       = 'Regal Necklace',
    waist      = 'Plat. Mog. Belt',
    left_ear   = 'Ethereal Earring',
    right_ear  = Chasseur.earring_e1,
    left_ring  = "Luzaf's Ring",
    right_ring = 'Kuchekula Ring',
    back       = Camulus.plain
}

-- • Double-Up (handled dynamically in COR_PRECAST.lua)
--   Equips the same set as the last roll used (including specific roll gear)

-- • Specific roll overrides (gear that enhances specific rolls)
sets.precast.CorsairRoll["Caster's Roll"] = set_combine(sets.precast.CorsairRoll, {
    legs = Chasseur.legs_c3
})

sets.precast.CorsairRoll["Courser's Roll"] = set_combine(sets.precast.CorsairRoll, {
    feet = Chasseur.feet_b1
})

sets.precast.CorsairRoll["Blitzer's Roll"] = set_combine(sets.precast.CorsairRoll, {
    head = Chasseur.head_t2
})

sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {
    body = Chasseur.body_f2
})

sets.precast.CorsairRoll["Allies' Roll"] = set_combine(sets.precast.CorsairRoll, {
    hands = Chasseur.hands_g3
})

-- • Quick Draw (CorsairShot - magic damage JA)
--   Mote looks for sets.precast.CorsairShot when spell.type == 'CorsairShot'
--   Base set: 5-piece Malignance (Magic Attack Bonus + Magic Accuracy)
sets.precast.CorsairShot = {
    head  = Malignance.head,
    body  = Malignance.body,
    hands = Malignance.hands,
    legs  = Malignance.legs,
    feet  = Malignance.feet
}

-- • Quick Draw element variants (optional - enhance specific shots)
--   sets.precast.CorsairShot['Fire Shot'] = set_combine(sets.precast.CorsairShot, {})
--   sets.precast.CorsairShot['Ice Shot']  = set_combine(sets.precast.CorsairShot, {})
--   etc.

-- • Snake Eye (guarantees lucky number on next roll)
sets.precast.JA['Snake Eye'] = {legs = Lanun.legs}

-- • Fold (restores 1 roll charge)
sets.precast.JA['Fold'] = {hands = Lanun.hands}

-- • Wild Card (resets all roll timers)
sets.precast.JA['Wild Card'] = {feet = Lanun.feet}

-- • Random Deal (resets all COR JA timers)
sets.precast.JA['Random Deal'] = {body = Lanun.body}

-- • Ranged Attack Precast (Snapshot/Rapid Shot)
sets.precast.RA = {
    head       = Malignance.head,
    body       = Laksamana.body,
    hands      = Chasseur.hands_g3,
    legs       = Armor.Misc.CarmineCuisses,
    feet       = Malignance.feet,
    neck       = 'Iskur Gorget',
    waist      = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear   = 'Dedition Earring',
    right_ear  = Chasseur.earring_e1,
    left_ring  = 'Murky Ring',
    right_ring = 'Chirich Ring +1',
    back       = Camulus.plain
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Generic weaponskill set (used as base for all WSs)
sets.precast.WS = {
    head       = Nyame.head_b,
    body       = Laksamana.body,
    hands      = Chasseur.hands_g3,
    legs       = Nyame.legs_b,
    feet       = Nyame.feet_b,
    neck       = 'Rep. Plat. Medal',
    waist      = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear   = {name = 'Moonshade Earring', augments = {'Mag. Acc.+4', 'TP Bonus +250'}},
    right_ear  = Chasseur.earring_e1,
    left_ring  = 'Murky Ring',
    right_ring = 'Chirich Ring +1',
    back       = Camulus.ws_str
}

-- • Savage Blade (Melee WS)
sets.precast.WS['Savage Blade'] = {
    head       = Nyame.head_b,
    body       = Laksamana.body,
    hands      = Chasseur.hands_g3,
    legs       = Nyame.legs_b,
    feet       = Nyame.feet_b,
    neck       = 'Rep. Plat. Medal',
    waist      = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear   = {name = 'Moonshade Earring', augments = {'Mag. Acc.+4', 'TP Bonus +250'}},
    right_ear  = Chasseur.earring_e1,
    left_ring  = 'Murky Ring',
    right_ring = 'Chirich Ring +1',
    back       = Camulus.ws_str
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • Ranged Attack (bullet flight time - RA gear)
sets.midcast.RA = {
    head       = Malignance.head,
    body       = Malignance.body,
    hands      = Malignance.hands,
    legs       = Malignance.legs,
    feet       = Malignance.feet,
    neck       = 'Iskur Gorget',
    waist      = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear   = 'Dedition Earring',
    right_ear  = Chasseur.earring_e1,
    left_ring  = 'Murky Ring',
    right_ring = 'Chirich Ring +1',
    back       = Camulus.plain
}

-- • Note: Phantom Rolls and Quick Draw are JA (instantaneous)
--   They have NO midcast phase - handled in precast.JA only

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {legs = 'Carmine Cuisses +1'} -- Movement +18%

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {body = Armor.Misc.CouncilorsGarb})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

-- • Doom removal
sets.buff.Doom = {
    -- neck  = "Nicander's Necklace",
    -- ring1 = "Purity Ring",
    -- ring2 = "Blenmot's Ring +1",
    -- waist = "Gishdubar Sash",
}

print('[COR] Equipment sets loaded successfully (modular v4.0)')

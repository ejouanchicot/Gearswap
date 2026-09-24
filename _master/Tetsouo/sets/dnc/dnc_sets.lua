---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Equipment Sets - Complete Dancer Gear Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua    -- Cross-job wardrobe rings
---     • Tetsouo/sets/dnc/armor.lua       -- AF / Relic / Empyrean + Nyame / Malignance / Adhemar / etc.
---     • Tetsouo/sets/dnc/capes.lua       -- Senuna's Mantle variants + Toetapper + Earthcry
---     • Tetsouo/sets/dnc/weapons.lua     -- Weapon set definitions
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   Features (preserved from monolithic v1.0):
---     • Weapon sets (Mpu Gandring/Centovente, Twashtar/Gleti, Demersal/Blurred)
---     • Idle sets (Normal, PDT, Town with movement speed)
---     • Engaged sets (Normal, PDT 50% DT, FanDance 30% DT, SaberDance variants)
---     • Step sets (Feather/Quick/Box) and Flourishes (Violent/Animated/Desperate/Reverse)
---     • Waltz sets (healing potency optimization)
---     • Samba/Jig sets (duration and potency)
---     • Weaponskills with 6-tier variants (base / Clim / FanDance / FanDance.Clim / SaberDance / SaberDance.Clim)
---     • Fast Cast sets, Jump sets (DRG sub), Movement speed sets
---     • Buff-specific sets (Saber Dance, Climactic Flourish, Doom)
---     • Treasure Hunter utility set
---
---   @file    Tetsouo/sets/dnc/dnc_sets.lua
---   @author  Tetsouo
---   @version 2.0 - Modularized
---   @date    Created: 2026-05-11 (modular split)
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/dnc/armor')
local Capes   = require('Tetsouo/sets/dnc/capes')
local Weapons = require('Tetsouo/sets/dnc/weapons')

-- Local aliases for readability
local Etoile     = Armor.Etoile
local Maculele   = Armor.Maculele
local Maxixi     = Armor.Maxixi
local Horos      = Armor.Horos
local Nyame      = Armor.Nyame
local Malig      = Armor.Malignance
local Adhemar    = Armor.Adhemar
local Gleti      = Armor.Gleti
local Meg        = Armor.Meghanada
local Misc       = Armor.Misc
local Senuna     = Capes.Senuna
local Toetapper  = Capes.Toetapper
local Earthcry   = Capes.Earthcry

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from dnc/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle
sets.idle = {
    ammo = 'Coiste Bodhar',
    head = Gleti.head,
    body = Gleti.body,
    hands = Gleti.hands,
    legs = Gleti.legs,
    feet = Gleti.feet,
    neck = 'Elite Royal Collar',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- • PDT Idle (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle, {
    neck = 'Loricate Torque +1',
    waist = 'Flume Belt +1',
    ring1 = 'Murky Ring'
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Engaged
sets.engaged = {}

-- • Standard Normal Engaged
sets.engaged.Normal = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Malig.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = Rings.Moonlight1,
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- • No Fan Dance: 50 equipment DT = 50 PDT (Base PDT set)
sets.engaged.PDT = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Malig.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = Rings.Moonlight1,
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- • Fan Dance: Minimum 20 DT + 30 equipment PDT = 50 PDT (With Fan Dance buff active)
sets.engaged.FanDance = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Maculele.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Ilabrat Ring',
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- • Saber Dance: Dual Wield -50%, optimize for Haste/STP/Multi-Attack instead of DW
sets.engaged.SaberDance = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Maculele.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Ilabrat Ring',
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- • Saber Dance + PDT: Hybrid defensive set with Saber Dance active
sets.engaged.SaberDance.PDT = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Maculele.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Ilabrat Ring',
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • Steps (Base set)
sets.precast.Step = {
    ammo = 'Ginsen',
    head = Maxixi.head,
    body = Maculele.body,
    hands = Maxixi.hands,
    legs = Maculele.legs,
    feet = Horos.feet,
    neck = 'Sanctity Necklace',
    waist = 'Kentarch Belt +1',
    ear1 = 'Mache Earring +1',
    ear2 = 'Crep. Earring',
    ring1 = "Valseur's Ring",
    ring2 = 'Asklepian Ring',
    back = Toetapper
}

sets.precast.Step['Feather Step'] = set_combine(sets.precast.Step, {
    feet = Maculele.feet
})

sets.precast.Step['Quickstep'] = set_combine(sets.precast.Step, {
    feet = Maculele.feet
})

sets.precast.Step['Box Step'] = set_combine(sets.precast.Step, {
    feet = Maculele.feet
})

-- • Flourishes (Flourish1 & Flourish2)
sets.precast.Flourish1 = {}

sets.precast.Flourish1['Violent Flourish'] = {
    head = Maculele.head,
    body = Horos.body,
    hands = Maculele.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = 'Voltsurge Torque',
    waist = 'Skrymir Cord',
    ear1 = 'Enchntr. Earring +1',
    ear2 = Maculele.earring,
    ring1 = 'Mummu Ring',
    ring2 = 'Crepuscular Ring'
}

sets.precast.Flourish1['Animated Flourish'] = {
    ammo = 'Sapience Orb',
    body = Misc.EmetHarness,
    hands = Horos.hands,
    neck = 'Unmoving Collar +1',
    waist = 'Trance Belt',
    ear1 = 'Friomisi Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back = Earthcry
}

sets.precast.Flourish1['Desperate Flourish'] = {
    head = Maculele.head,
    body = Maculele.body,
    hands = Maculele.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = 'Sanctity Necklace',
    waist = 'Kentarch Belt +1',
    ear1 = 'Mache Earring +1',
    ear2 = 'Crep. Earring',
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back = Toetapper
}

sets.precast.Flourish2 = {}

sets.precast.Flourish2['Reverse Flourish'] = {
    hands = Maculele.hands,
    back = Toetapper
}

-- • Waltzes (Healing potency optimization)
sets.precast.Waltz = {
    ammo = 'Staunch Tathlum +1',
    head = Misc.AnwigSalade,
    body = Maxixi.body,
    hands = Maculele.hands,
    legs = Misc.DashingSubligar,
    feet = Maculele.feet,
    neck = 'Loricate Torque +1',
    waist = 'Plat. Mog. Belt',
    ear1 = 'Cryptic Earring',
    ear2 = 'Enchntr. Earring +1',
    ring1 = 'Murky Ring',
    ring2 = 'Asklepian Ring',
    back = Toetapper
}

sets.precast.Waltz['Healing Waltz'] = set_combine(sets.precast.Waltz, {})

-- • Sambas / Jigs (Duration and potency)
sets.precast.Samba = {
    head = Maxixi.head,
    back = Senuna.TP
}

sets.precast.Jig = {
    legs = Horos.legs,
    feet = Maxixi.feet
}

-- • Other Job Abilities (No Foot Rise, Trance, Provoke, Fan Dance, Jumps)
sets.precast.JA['No Foot Rise'] = {
    body = Horos.body
}

sets.precast.JA['Trance'] = {
    head = Horos.head
}

sets.precast.JA['Provoke'] = {
    ammo = 'Sapience Orb',
    body = Misc.EmetHarness,
    hands = Horos.hands,
    neck = 'Unmoving Collar +1',
    waist = 'Trance Belt',
    ear1 = 'Friomisi Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back = Earthcry
}

sets.precast.JA['Fan Dance'] = {
    hands = Horos.hands
}

sets.precast.JA['Jump'] = {
    head = Malig.head,
    body = Malig.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Malig.feet,
    neck = Etoile.gorget_a,
    waist = {
        name = 'Kentarch Belt +1',
        augments = {'Path: A'}
    },
    ear1 = 'Sherida Earring',
    ear2 = 'Dedition Earring',
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

sets.precast.JA['High Jump'] = {
    head = Malig.head,
    body = Malig.body,
    hands = Malig.hands,
    legs = Malig.legs,
    feet = Malig.feet,
    neck = Etoile.gorget_a,
    waist = {
        name = 'Kentarch Belt +1',
        augments = {'Path: A'}
    },
    ear1 = 'Sherida Earring',
    ear2 = 'Dedition Earring',
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back = Senuna.TP
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

-- • Fast Cast (spell casting optimization)
sets.precast.FC = {
    ammo = 'Sapience Orb',
    head = Misc.HerculeanHelmTH,
    body = Maculele.body,
    hands = Misc.LeylineGloves,
    legs = Misc.LimboTrousers,
    feet = Maculele.feet,
    neck = 'Voltsurge Torque',
    waist = 'Svelt. Gouriz +1',
    ear1 = 'Loquac. Earring',
    ear2 = 'Enchntr. Earring +1',
    ring1 = 'Murky Ring',
    ring2 = 'Prolix Ring',
    back = Senuna.TP
}

sets.precast.FC.Utsusemi = sets.precast.FC

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Weaponskill
--   NOTE: Moonshade Earring is added at WS time by TPBonusCalculator, only
--   when it closes the gap to the next TP threshold (2000 or 3000)
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = Adhemar.bonnet_p1,
    body = Meg.cuirie_p2,
    hands = Meg.gloves_p2,
    legs = Horos.legs,
    feet = Misc.LustraLeggings,
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = 'Odr Earring',
    ear2 = Maculele.earring,
    ring1 = 'Regal Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- • Ruthless Stroke (6 variants: base, Clim, FanDance, FanDance.Clim, SaberDance, SaberDance.Clim)
--   No Fan Dance (50 equipment DT)
sets.precast.WS['Ruthless Stroke'] = {
    ammo = 'Crepuscular Pebble',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Odnowa Earring +1',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

--   Climactic Flourish (50 equipment DT)
sets.precast.WS['Ruthless Stroke'].Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

--   Fan Dance (30 equipment DT)
sets.precast.WS['Ruthless Stroke'].FanDance = {
    ammo = 'Crepuscular Pebble',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Odnowa Earring +1',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

--   Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS['Ruthless Stroke'].FanDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

--   Saber Dance (High Haste/STP build, no DW needed)
sets.precast.WS['Ruthless Stroke'].SaberDance = {
    ammo = 'Crepuscular Pebble',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Odnowa Earring +1',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

--   Saber Dance + Climactic Flourish (Crit-focused with Haste)
sets.precast.WS['Ruthless Stroke'].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- • Dancing Edge (6 variants)
--   No Fan Dance (50 equipment DT)
sets.precast.WS['Dancing Edge'] = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Malig.body,
    hands = Maculele.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = Rings.Moonlight1,
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Climactic Flourish (50 equipment DT)
sets.precast.WS['Dancing Edge'].Clim = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Malig.body,
    hands = Maculele.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = Rings.Moonlight1,
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Fan Dance (30 equipment DT)
sets.precast.WS['Dancing Edge'].FanDance = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Malig.body,
    hands = Maculele.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = Rings.Moonlight1,
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS['Dancing Edge'].FanDance.Clim = {
    ammo = 'Coiste Bodhar',
    head = Malig.head,
    body = Malig.body,
    hands = Maculele.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Cessance Earring',
    ring1 = Rings.Moonlight1,
    ring2 = 'Gere Ring',
    back = Senuna.TP
}

-- Dancing Edge: Saber Dance (High Haste/STP build, no DW needed)
sets.precast.WS['Dancing Edge'].SaberDance = {
    ammo = 'Coiste Bodhar',
    head = Maculele.head,
    body = Horos.body,
    hands = Maculele.hands,
    legs = Nyame.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Mache Earring +1',
    ring1 = 'Regal Ring',
    ring2 = Rings.Moonlight2,
    back = Senuna.TP
}

-- Dancing Edge: Saber Dance + Climactic Flourish (Crit-focused with Haste)
sets.precast.WS['Dancing Edge'].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Gleti.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Mache Earring +1',
    ring1 = 'Regal Ring',
    ring2 = 'Gere Ring',
    back = Senuna.WS
}

-- • Rudra's Storm (6 variants)
--   No Fan Dance (50 equipment DT)
sets.precast.WS["Rudra's Storm"] = {
    ammo = 'Crepuscular Pebble',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Rudra's Storm: Climactic Flourish (50 equipment DT)
sets.precast.WS["Rudra's Storm"].Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Rudra's Storm: Fan Dance (30 equipment DT)
sets.precast.WS["Rudra's Storm"].FanDance = {
    ammo = 'Crepuscular Pebble',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Rudra's Storm: Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS["Rudra's Storm"].FanDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Rudra's Storm: Saber Dance (DEX/Attack/WSD optimized, no DW needed)
sets.precast.WS["Rudra's Storm"].SaberDance = {
    ammo = 'Crepuscular Pebble',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Rudra's Storm: Saber Dance + Climactic Flourish (Crit DEX/WSD hybrid)
sets.precast.WS["Rudra's Storm"].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Maculele Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- • Shark Bite (6 variants)
--   No Fan Dance (50 equipment DT)
sets.precast.WS['Shark Bite'] = {
    ammo = 'C. Palug Stone',
    head = Maculele.head,
    body = Maculele.body,
    hands = Maxixi.hands,
    legs = Nyame.legs,
    feet = Maculele.feet,
    neck = 'Null Loop',
    waist = 'Sailfi Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Odnowa Earring +1',
    ring1 = 'Regal Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Shark Bite: Climactic Flourish (50 equipment DT)
sets.precast.WS['Shark Bite'].Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Meg.cuirie_p2,
    hands = Gleti.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = Maculele.earring,
    ring1 = 'Murky Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Shark Bite: Fan Dance (30 equipment DT)
sets.precast.WS['Shark Bite'].FanDance = {
    ammo = 'C. Palug Stone',
    head = Maculele.head,
    body = Maculele.body,
    hands = Maxixi.hands,
    legs = Horos.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = 'Odr Earring',
    ring1 = 'Regal Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Shark Bite: Fan Dance + Climactic Flourish (30 equipment DT)
sets.precast.WS['Shark Bite'].FanDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Meg.cuirie_p2,
    hands = Maxixi.hands,
    legs = Maculele.legs,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Domin. Earring +1',
    ear2 = Maculele.earring,
    ring1 = Rings.Moonlight1,
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- Shark Bite: Saber Dance (AGI/DEX hybrid, no DW needed)
sets.precast.WS['Shark Bite'].SaberDance = {
    ammo = 'C. Palug Stone',
    head = Maculele.head,
    body = Meg.cuirie_p2,
    hands = Maxixi.hands,
    legs = Misc.SamnuhaTights,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = 'Regal Ring',
    ring2 = 'Gere Ring',
    back = Senuna.WS
}

-- Shark Bite: Saber Dance + Climactic Flourish (Crit AGI/DEX hybrid)
sets.precast.WS['Shark Bite'].SaberDance.Clim = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Meg.cuirie_p2,
    hands = Maxixi.hands,
    legs = Misc.SamnuhaTights,
    feet = Nyame.feet,
    neck = Etoile.gorget,
    waist = 'Kentarch Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = "Epaminondas's Ring",
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- • Other Weaponskills (Pyrrhic Kleos, Evisceration, Exenterator, Aeolian Edge)
sets.precast.WS['Pyrrhic Kleos'] = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Maculele.body,
    hands = Maxixi.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Fotia Belt',
    ear1 = 'Sherida Earring',
    ear2 = Maculele.earring,
    ring1 = 'Regal Ring',
    ring2 = 'Gere Ring',
    back = Senuna.WS
}

sets.precast.WS['Evisceration'] = {
    ammo = 'Charis Feather',
    head = Maculele.head,
    body = Gleti.body,
    hands = Malig.hands,
    legs = Misc.LustraSubligar,
    feet = Maculele.feet,
    neck = Etoile.gorget,
    waist = 'Fotia Belt',
    ear1 = 'Odr Earring',
    ear2 = Maculele.earring,
    ring1 = 'Regal Ring',
    ring2 = 'Ilabrat Ring',
    back = Senuna.WS
}

sets.precast.WS['Exenterator'] = {
    ammo = 'C. Palug Stone',
    head = Maculele.head,
    body = Maculele.body,
    hands = Maxixi.hands,
    legs = Maculele.legs,
    feet = Maculele.feet,
    neck = 'Fotia Gorget',
    waist = 'Fotia Belt',
    ear1 = 'Mache Earring +1',
    ear2 = Maculele.earring,
    ring1 = 'Regal Ring',
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

sets.precast.WS['Aeolian Edge'] = {
    ammo = 'Ghastly Tathlum +1',
    head = Nyame.head,
    body = Nyame.body,
    hands = Nyame.hands,
    legs = Nyame.legs,
    feet = Nyame.feet,
    neck = 'Sibyl Scarf',
    waist = "Orpheus's Sash",
    ear1 = 'Friomisi Earring',
    ear2 = 'Crematio Earring',
    ring1 = "Epaminondas's Ring",
    ring2 = "Ephramad's Ring",
    back = Senuna.WS
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Fast Recast
sets.midcast = {}
sets.midcast.FastRecast = {}
sets.midcast.Utsusemi = set_combine(sets.precast.FC, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    feet = Misc.SkadiBoots,
    ring1 = 'Murky Ring'
}

-- • Town Idle (Movement Speed)
sets.idle.Town = set_combine(sets.idle.PDT, sets.MoveSpeed)

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = Misc.CouncilorsGarb
})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

sets.buff['Saber Dance'] = {
    legs = Horos.legs
}

sets.buff['Climactic Flourish'] = {
    head = Maculele.head
}

sets.buff.Doom = {
    neck = {
        name = "Nicander's Necklace"
    }, -- Reduces Doom effects
    left_ring = {
        name = 'Purity Ring'
    }, -- Additional Doom resistance
    waist = {
        name = 'Gishdubar Sash'
    } -- Enhances Doom recovery effects
}

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Treasure Hunter
sets.TreasureHunter = {
    head = Misc.HerculeanHelmTH,
    legs = Misc.HerculeanTrousersTH
}

print('[DNC] Equipment sets loaded successfully (modular v2.0)')

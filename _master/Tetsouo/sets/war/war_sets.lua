---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Equipment Sets - Complete Gear Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua  -- Cross-job wardrobe rings
---     • Tetsouo/sets/war/armor.lua     -- AF / Relic / Empyrean + Sakpata / Nyame / etc.
---     • Tetsouo/sets/war/capes.lua     -- Cichol's Mantle variants
---     • Tetsouo/sets/war/weapons.lua   -- Weapon set definitions
---
---   This file only declares the SET COMPOSITIONS using the imports above.
---
---   Contains:
---     • Weapon sets (Great Axes, Polearms, Swords, Axes, Maces)
---     • Idle sets (Base, PDT, Town)
---     • Engaged sets (Base, PDTTP, Normal, AM3, SubtleBlow, KrakenClub)
---     • Precast JA sets (Berserk, Warcry, Aggressor, etc.)
---     • Precast WS sets (Ukko's Fury, Upheaval, Savage Blade, etc.)
---     • Movement sets (Base speed, Adoulin)
---     • Buff sets (Doom resistance)
---
---   @file    Tetsouo/sets/war/war_sets.lua
---   @author  Tetsouo
---   @version 3.0 - Modularized
---   @date    Updated: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/war/armor')
local Capes   = require('Tetsouo/sets/war/capes')
local Weapons = require('Tetsouo/sets/war/weapons')

-- Local aliases for readability
local Boii      = Armor.Boii
local Agoge     = Armor.Agoge
local Pummeler  = Armor.Pummeler
local Sakpata   = Armor.Sakpata
local Nyame     = Armor.Nyame
local Tatenashi = Armor.Tatenashi
local Hjarrandi = Armor.Hjarrandi
local Dagon     = Armor.Dagon
local Souveran  = Armor.Souveran
local Misc      = Armor.Misc
local Cichol    = Capes.Cichol

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from war/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle (Balanced TP gain + defensive stats)
sets.idle = {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    body  = Boii.body,
    hands = Sakpata.hands,
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Dedition Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = Rings.Moonlight2,
    back  = Cichol.da
}

-- • PDT Idle (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle, {
    head  = Sakpata.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    legs  = Sakpata.legs,
    feet  = Sakpata.feet,
    ring1 = 'Murky Ring',
    ring2 = 'Gelatinous Ring +1',
    back  = 'Moonlight Cape'
})

-- • Town Idle (Movement speed + aesthetics)
sets.idle.Town = set_combine(sets.idle.PDT, {
    neck = 'Elite Royal Collar',
    feet = Misc.HermesSandals
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Engaged (Balanced TP gain + multi-attack)
sets.engaged = {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    body  = Boii.body,
    hands = Sakpata.hands,
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Dedition Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = 'Moonlight Ring',
    back  = Cichol.da
}

-- • PDTTP Engaged (Balanced PDT + TP for survivability)
sets.engaged.PDTTP = set_combine(sets.engaged, {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    body  = Boii.body,
    hands = Sakpata.hands,
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Dedition Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = 'Moonlight Ring',
    back  = Cichol.da
})

-- • HybridMode: PDT (Uses PDTTP for maximum survivability)
sets.engaged.PDT = sets.engaged.PDTTP

-- • HybridMode: Normal (Pure DPS focused)
sets.engaged.Normal = set_combine(sets.engaged, {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    body  = Boii.body,
    hands = Sakpata.hands,
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Dedition Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = 'Moonlight Ring',
    back  = Cichol.da
})

-- • Aftermath Level 3 Specialized (Used with Ukonvasara)
sets.engaged.PDTAFM3 = set_combine(sets.engaged.PDTTP, {
    ammo  = Misc.CrepuscularPebble,
    head  = Sakpata.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    legs  = Sakpata.legs,
    feet  = Sakpata.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = 'Sroda Ring',
    back  = Cichol.da
})

-- • Subtle Blow (Reduces TP fed to mob — toggled via state.SubtleBlow)
sets.engaged.SubtleBlow = set_combine(sets.engaged, {
    ammo       = Misc.CoisteBodhar,
    head       = Hjarrandi.head,
    body       = Dagon.body,
    hands      = Sakpata.hands,
    legs       = Pummeler.legs,
    feet       = Pummeler.feet,
    neck       = 'War. Beads +2',
    waist      = 'Sailfi Belt +1',
    left_ear   = 'Schere Earring',
    right_ear  = Boii.earring,
    left_ring  = Rings.Chirich1,
    right_ring = Rings.Chirich2,
    back       = Cichol.da
})

-- • Kraken Club Specialized (Used when Kraken Club is in sub-weapon)
sets.engaged.PDTKC = set_combine(sets.engaged.PDTTP, {
    ammo       = Misc.AurgelmirOrb,
    head       = Pummeler.head,
    body       = Boii.body,
    hands      = Tatenashi.hands,
    legs       = Tatenashi.legs,
    feet       = Boii.feet,
    neck       = 'Null Loop',
    waist      = 'Null Belt',
    left_ear   = 'Dedition Earring',
    right_ear  = 'Crep. Earring',
    left_ring  = Rings.Moonlight1,
    right_ring = Rings.Moonlight2,
    back       = Cichol.stp
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.JA = {}

sets.LessEnmity = {
    ammo  = Misc.Psilomene,
    neck  = "Orunmila's Torque",
    waist = "Acerbic Sash +1",
    ear1  = "Sortiarius Earring",
    ring1 = "Cacoethic Ring",
    ring2 = "Prolix Ring",
    back  = Cichol.LessEnmnity
}

-- • Full Enmity (Maximizes enmity generation for tanking)
sets.FullEnmity = {
    ammo  = Misc.SapienceOrb,
    head  = Souveran.head,
    body  = Souveran.body,
    hands = Souveran.hands,
    legs  = Souveran.legs,
    feet  = Souveran.feet,
    neck  = 'Moonlight Necklace',
    waist = 'Trance Belt',
    ear1  = 'Cryptic Earring',
    ear2  = 'Friomisi Earring',
    ring1 = 'Provocare Ring',
    ring2 = 'Supershear Ring',
    back  = 'Earthcry Mantle'
}

-- • Provoke (Enmity generation)
sets.precast.JA['Provoke'] = sets.FullEnmity

-- • Jump Abilities (DRG subjob)
sets.precast.JA['Jump']      = sets.engaged.PDTTP
sets.precast.JA['High Jump'] = sets.engaged.PDTTP

-- • Berserk (Enhances attack power + extends duration)
sets.precast.JA['Berserk'] = set_combine(sets.LessEnmity, {
    body = Pummeler.body,    -- Duration +18 seconds
    feet = Agoge.feet        -- Duration +30 seconds
})

-- • Defender (Increases defense)
sets.precast.JA['Defender'] = set_combine(sets.engaged, {
    hands = Agoge.hands
})

-- • Warcry (Boosts party attack + TP bonus from Savagery merits)
sets.precast.JA['Warcry'] = set_combine(sets.LessEnmity, {
    head = Agoge.head        -- Increases TP bonus (requires Savagery merits)
})

-- • Aggressor (Increases accuracy and attack speed + extends duration)
sets.precast.JA['Aggressor'] = set_combine(sets.LessEnmity, {
    head = Pummeler.head,    -- Duration +18 seconds
    body = Agoge.body        -- Duration +30 seconds
})

-- • Blood Rage (Enhances critical hit rate)
sets.precast.JA['Blood Rage'] = set_combine(sets.LessEnmity, {
    body = Boii.body
})

-- • Tomahawk (Ranged attack)
sets.precast.JA['Tomahawk'] = set_combine(sets.LessEnmity, {
    ammo = Misc.ThrowingTomahawk,
    feet = Agoge.feet
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Weaponskill (foundation for all WS)
sets.precast.WS = {
    ammo  = Misc.Knobkierrie,
    head  = Sakpata.head,
    body  = Sakpata.body,
    hands = Boii.hands,
    legs  = Boii.legs,
    feet  = Sakpata.feet,
    neck  = 'War. Beads +2',
    waist = 'Ioskeha Belt +1',
    ear1  = 'Thrud Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1
}

-- ── Great Axe Weaponskills ──────────────────────────────────────────────────

-- • Armor Break (Defense down)
sets.precast.WS['Armor Break'] = set_combine(sets.precast.WS, {
    neck  = 'Fotia Gorget',
    waist = 'Fotia Belt'
})

-- • Ukko's Fury (Critical hit weaponskill)
sets.precast.WS["Ukko's Fury"] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    legs  = Boii.legs,
    feet  = Boii.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1
})

-- • Upheaval (STR/VIT physical)
sets.precast.WS['Upheaval'] = set_combine(sets.precast.WS, {
    ammo  = Misc.Knobkierrie,
    head  = Boii.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    legs  = Boii.legs,
    feet  = Sakpata.feet,
    neck  = 'Null Loop',
    waist = 'Ioskeha Belt +1',
    ear1  = 'Schere Earring',
    ear2  = 'Thrud Earring',
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1
})

-- • Fell Cleave (STR physical)
sets.precast.WS['Fell Cleave'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    body  = Sakpata.body,
    hands = Boii.hands,
    legs  = Boii.legs,
    feet  = Nyame.feet,
    neck  = 'War. Beads +2',
    waist = 'Fotia Belt',
    ear2  = 'Thrud Earring',
    ear1  = 'Schere Earring',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1
})

-- • King's Justice (STR physical)
sets.precast.WS["King's Justice"] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    body  = Sakpata.body,
    hands = Boii.hands,
    legs  = Boii.legs,
    feet  = Sakpata.feet,
    neck  = 'War. Beads +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1
})

-- ── Polearm Weaponskills ────────────────────────────────────────────────────

-- • Impulse Drive (Multi-hit physical)
sets.precast.WS['Impulse Drive'] = set_combine(sets.precast.WS, {
    ammo  = Misc.YetshilaPlus1,
    head  = Boii.head,
    neck  = 'War. Beads +2',
    ear1  = 'Thrud Earring',
    ear2  = Boii.earring,
    body  = Sakpata.body,
    hands = Boii.hands,
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    waist = 'Sailfi Belt +1',
    legs  = Boii.legs,
    feet  = Boii.feet,
    back  = Cichol.ws1
})

-- • Stardiver (STR physical)
sets.precast.WS['Stardiver'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    waist = 'Fotia Belt',
    legs  = Boii.legs,
    feet  = Boii.feet,
    back  = Cichol.ws1
})

-- ── Sword Weaponskills ──────────────────────────────────────────────────────

-- • Savage Blade (STR+MND physical + magical hybrid)
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Agoge.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    legs  = Sakpata.legs,
    feet  = Nyame.feet,
    neck  = "War. Beads +2",
    waist = "Kentarch Belt +1",
    ear1  = "Thrud Earring",
    ear2  = "Odnowa Earring +1",
    ring1 = "Cornelia's Ring",
    ring2 = "Sroda Ring",
    back  = Cichol.ws1
})

-- ── Axe Weaponskills ────────────────────────────────────────────────────────

-- • Calamity (STR physical)
sets.precast.WS['Calamity'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Agoge.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    legs  = Sakpata.legs,
    feet  = Nyame.feet,
    neck  = "War. Beads +2",
    waist = "Sailfi Belt +1",
    ear1  = "Thrud Earring",
    ear2  = "Odnowa Earring +1",
    ring1 = "Cornelia's Ring",
    ring2 = "Sroda Ring",
    back  = Cichol.ws1
})

-- ── Club / Mace Weaponskills ────────────────────────────────────────────────

-- • Judgment (MND magical)
sets.precast.WS['Judgment'] = set_combine(sets.precast.WS, {
    legs  = Nyame.legs_b,
    feet  = Nyame.feet_b,
    ring2 = 'Murky Ring'
})

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed (+12% from Hermes' Sandals)
sets.MoveSpeed = {
    feet = Misc.HermesSandals
}

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = Misc.CouncilorsGarb
})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

-- • Doom Resistance (Removes Doom status effect)
sets.buff.Doom = {
    neck  = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    ring2 = "Blenmot's Ring +1",
    waist = 'Gishdubar Sash'
}

print('[WAR] Equipment sets loaded successfully (modular v3.0)')

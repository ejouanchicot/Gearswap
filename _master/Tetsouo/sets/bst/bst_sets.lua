---  ═══════════════════════════════════════════════════════════════════════════
---   BST Equipment Sets - Complete Gear Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua    -- Cross-job wardrobe rings
---     • Tetsouo/sets/bst/armor.lua       -- AF / Relic / Empyrean / Nyame / Misc
---     • Tetsouo/sets/bst/capes.lua       -- Artio / Pastoralist mantle variants
---     • Tetsouo/sets/bst/weapons.lua     -- Main / sub weapon sets
---     • Tetsouo/sets/bst/pets.lua        -- 25 jug pet broth sets
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   @file    Tetsouo/sets/bst/bst_sets.lua
---   @author  Tetsouo
---   @version 3.0 - Modularized
---   @date    Created: 2026-05-11 (modular split)
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/bst/armor')
local Capes   = require('Tetsouo/sets/bst/capes')
local Weapons = require('Tetsouo/sets/bst/weapons')
local Pets    = require('Tetsouo/sets/bst/pets')

-- Local aliases for readability
local Malignance   = Armor.Malignance
local Nyame        = Armor.Nyame
local Nukumi       = Armor.Nukumi
local Ankusa       = Armor.Ankusa
local Totemic      = Armor.Totemic
local Gleti        = Armor.Gleti
local Emicho       = Armor.Emicho
local Anwig        = Armor.Anwig
local Khimaira     = Armor.Khimaira
local Jumalik      = Armor.Jumalik
local PhysMultiGear = Armor.PhysMultiGear
local MabGear      = Armor.MabGear
local Misc         = Armor.Misc
local BSTRings     = Armor.Rings
local Earrings     = Armor.Earrings
local Necks        = Armor.Necks
local Artio        = Capes.Artio
local Pastoralist  = Capes.Pastoralist

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from bst/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- JUG PET BROTH SETS (loaded from bst/pets.lua - matches BST_PET_DATA.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, pet_set in pairs(Pets) do
    sets[name] = pet_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- PET READY MOVE CATEGORY TABLES (globals used by ready_move_categorizer)
-- ═══════════════════════════════════════════════════════════════════════════

-- Single-hit physical moves
petPhysicalMoves = S {
    'Foot Kick', 'Whirl Claws', 'Sheep Charge', 'Lamb Chop', 'Head Butt',
    'Leaf Dagger', 'Claw Cyclone', 'Razor Fang', 'Nimble Snap', 'Cyclotail',
    'Rhino Attack', 'Power Attack', 'Mandibular Bite', 'Big Scissors',
    'Grapple', 'Spinning Top', 'Double Claw', 'Frogkick', 'Blockhead',
    'Brain Crush', 'Tail Blow', '??? Needles', 'Needleshot', 'Scythe Tail',
    'Ripper Fang', 'Recoil Dive', 'Sudden Lunge', 'Spiral Spin', 'Beak Lunge',
    'Suction', 'Back Heel', 'Choke Breath', 'Fantod', 'Tortoise Stomp',
    'Sensilla Blades', 'Tegmina Buffet', 'Swooping Frenzy', 'Zealous Snort',
    'Somersault', 'Sickle Slash', 'Crossthrash',
}

-- Multi-hit physical moves
petPhysicalMultiMoves = S {
    'Sweeping Gouge', 'Tickling Tendrils', 'Chomp Rush', 'Pentapeck',
    'Wing Slap', 'Pecking Flurry',
}

-- Magical nukes / damage-based spells
petMagicAtkMoves = S {
    'Cursed Sphere', 'Venom', 'Toxic Spit', 'Bubble Shower', 'Drainkiss',
    'Fireball', 'Snow Cloud', 'Charged Whisker', 'Purulent Ooze',
    'Corrosive Ooze', 'Aqua Breath', 'Choke Breath', 'Stink Bomb',
    'Nectarous Deluge', 'Nepenthic Plunge', 'Pestilent Plume', 'Foul Waters',
    'Acid Spray',
}

-- Magical accuracy-based moves (debuffs, status effects, buffs)
petMagicAccMoves = S {
    -- Debuffs
    'Sheep Song', 'Scream', 'Dream Flower', 'Roar', 'Gloeosuccus',
    'Palsy Pollen', 'Soporific', 'Geist Wall', 'Numbing Noise', 'Spoil',
    'Hi-Freq Field', 'Sandpit', 'Sandblast', 'Venom Spray', 'Filamented Hold',
    'Queasyshroom', 'Numbshroom', 'Spore', 'Shakeshroom', 'Infrasonics',
    'Chaotic Eye', 'Blaster', 'Intimidate', 'Noisome Powder', 'Acid Mist',
    'TP Drainkiss', 'Jettatura', 'Nihility Song', 'Molting Plumage',
    'Spider Web', 'Digest', 'Silence Gas', 'Dark Spore', 'Predatory Glare',
    -- Healing/regen moves
    'Wild Carrot', 'Wild Oats',
    -- Defensive buffs
    'Bubble Curtain', 'Scissor Guard', 'Metallic Body', 'Rhino Guard',
    'Water Wall', 'Harden Shell',
    -- Status enhancement
    'Secretion', 'Rage',
}

-- ═══════════════════════════════════════════════════════════════════════════
-- BASE GEARSETS & TEMPLATES
-- ═══════════════════════════════════════════════════════════════════════════

-- Initialize base tables
sets.me  = sets.me  or {}
sets.pet = sets.pet or {}

-- Standard pet defensive core gear (reused in multiple sets)
local petDTCore = {
    head  = Anwig.head,
    body  = Totemic.body,
    hands = Ankusa.gloves_ba,
}

-- Base idle set used by both player and pet
local baseIdleSet = set_combine(
    Malignance,
    {
        ammo       = 'Hesperiidae',
        neck       = Necks.BstCollar,
        waist      = 'Flume Belt +1',
        left_ear   = Earrings.Odnowa,
        right_ear  = Earrings.Nukumi,
        left_ring  = BSTRings.Murky,
        right_ring = 'Chirich Ring +1',
        back       = Artio.STP,
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE & DEFENSIVE GEARSETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.idle        = set_combine({}, baseIdleSet)
sets.me.idle     = set_combine({}, baseIdleSet)
sets.me.idle.PDT = set_combine(sets.me.idle, {})
sets.me.idle.Town = set_combine(sets.me.idle, {
    feet = Misc.SkdJambeaux,
})

-- Pet idle set (regen/defense focus)
sets.pet.idle = {
    head       = Nukumi.head,
    body       = Gleti.body,
    hands      = Nukumi.hands,
    legs       = Nukumi.legs,
    feet       = Ankusa.gaiters,
    neck       = Necks.BstCollar,
    waist      = 'Isa Belt',
    left_ear   = Earrings.Enmerkar,
    right_ear  = Earrings.Nukumi,
    left_ring  = BSTRings.Varar2,
    right_ring = BSTRings.CPalug,
    back       = Artio.PETMB,
}

-- Pet PDT idle set (defensive variant)
sets.pet.idle.PDT = set_combine(
    sets.pet.idle,
    petDTCore,
    {
        neck       = Necks.BstCollar,
        right_ear  = Earrings.Nukumi,
        left_ring  = BSTRings.Varar2,
        right_ring = BSTRings.CPalug,
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED (MELEE COMBAT) SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- Master engaged set (balanced ACC/DT hybrid)
sets.me.engaged = set_combine(
    Malignance,
    {
        neck       = Necks.BstCollar,
        waist      = 'Kentarch Belt +1',
        left_ear   = Earrings.Telos,
        right_ear  = Earrings.Nukumi,
        left_ring  = Rings.Chirich1,
        right_ring = Rings.Chirich2,
        back       = Artio.STP,
    }
)

-- Master engaged PDT variant (tankier)
sets.me.engaged.PDT = set_combine(
    sets.me.engaged,
    {
        head  = Nukumi.head,
        hands = Nukumi.hands,
        legs  = Nukumi.legs,
        back  = Pastoralist.petDT,
    }
)

-- Base engaged set (used by Mote-Include - customized by SetBuilder)
sets.engaged = set_combine(sets.me.engaged, {})

-- Pet engaged set (offensive focus)
sets.pet.engaged = {
    ammo       = 'Hesperiidae',
    head       = Emicho.head,
    body       = PhysMultiGear.body,
    hands      = Nukumi.hands,
    legs       = PhysMultiGear.legs,
    feet       = Gleti.boots,
    neck       = Necks.Shulmanu,
    waist      = 'Incarnation Sash',
    left_ear   = Earrings.Sroda,
    right_ear  = Earrings.Nukumi,
    left_ring  = BSTRings.Varar2,
    right_ring = BSTRings.CPalug,
    back       = Artio.PETSTP,
}

-- Pet engaged PDT set (defensive variant)
sets.pet.engaged.PDT = set_combine(
    sets.pet.idle,
    {
        neck       = Necks.BstCollar,
        right_ear  = Earrings.Nukumi,
        left_ring  = BSTRings.Varar2,
        right_ring = BSTRings.CPalug,
    }
)

-- Master + pet engaged set (used in synced combat - balanced hybrid)
sets.pet.engagedBoth = set_combine(sets.me.engaged.PDT, {})

-- Master + pet engaged PDT set (defensive variant for both engaged)
sets.pet.engagedBoth.PDT = set_combine(sets.pet.engagedBoth, {
    head       = Malignance.head,
    body       = Malignance.body,
    hands      = Malignance.hands,
    legs       = Malignance.legs,
    feet       = Malignance.feet,
    back       = Artio.STP,
    left_ear   = Earrings.Telos,
    left_ring  = Rings.Moonlight1,
    right_ring = Rings.Moonlight2,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST JOB ABILITY SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast    = sets.precast    or {}
sets.precast.JA = sets.precast.JA or {}

-- Call Beast / Bestial Loyalty (pet summoning)
local summonSet = {
    head  = Misc.AcroHelm,
    body  = Misc.MirkeWardecors,
    hands = Ankusa.gloves,
    ear2  = Earrings.Nukumi,
    legs  = Misc.AcroBreeches,
    feet  = Misc.AdamanSollerets,
}

-- Sic/Ready set (Gleti's Breeches for Ready Recast -5s)
sets.precast.JA['Sic'] = {
    hands = Nukumi.hands,        -- Pet: Store TP +12
    legs  = Gleti.breeches,      -- Ready Recast -5s
}

sets.precast.JA['Ready']           = sets.precast.JA['Sic']
sets.precast.JA['Call Beast']      = summonSet
sets.precast.JA['Bestial Loyalty'] = summonSet

-- Reward (pet heal)
sets.precast.JA['Reward'] = {
    ammo       = 'Pet Food Theta',
    head       = Khimaira.head,
    body       = Totemic.body_fh,
    hands      = Malignance.hands,
    legs       = Ankusa.trousers_fam,
    feet       = Ankusa.gaiters_healer,
    neck       = Necks.Adad,
    waist      = 'Isa Belt',
    left_ear   = Earrings.Enmerkar,
    right_ear  = Earrings.Odnowa,
    left_ring  = Rings.Stikini1,
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back       = Artio.PETMB,
}

-- Killer Instinct (buff)
sets.precast.JA['Killer Instinct'] = {
    sub  = 'Diamond Aspis',
    head = Ankusa.head,
    body = Nukumi.body,
}

-- Spur (pet TP gain)
sets.precast.JA['Spur'] = {
    feet = Nukumi.feet,
    back = Artio.PETSTP,
}

-- Default/fallback precast sets
sets.precast.JA['Misc Idle'] = {
    hands = Ankusa.gloves,
    legs  = Gleti.breeches,
}
sets.precast.JA['Default'] = sets.precast.JA['Misc Idle']

-- ═══════════════════════════════════════════════════════════════════════════
-- PET READY MOVE GEAR SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = sets.midcast or {}

-- Single-hit physical Ready moves
sets.midcast.pet_physical_moves = {
    ammo       = 'Hesperiidae',
    head       = Emicho.head,
    body       = PhysMultiGear.body,
    hands      = Nukumi.hands,
    legs       = PhysMultiGear.legs,
    feet       = Gleti.boots,
    neck       = Necks.Shulmanu,
    waist      = 'Incarnation Sash',
    left_ear   = Earrings.Sroda,
    right_ear  = Earrings.Nukumi,
    left_ring  = BSTRings.Varar2,
    right_ring = BSTRings.CPalug,
    back       = Artio.PETSTP,
}

-- Multi-hit physical Ready moves
sets.midcast.pet_physicalMulti_moves = set_combine(
    sets.midcast.pet_physical_moves,
    {
        head  = PhysMultiGear.head,
        hands = PhysMultiGear.hands,
        legs  = PhysMultiGear.legs,
        feet  = PhysMultiGear.feet,
        neck  = Necks.BstCollar,
        back  = Artio.PETSTP,
    }
)

-- Magical attack Ready moves
sets.midcast.pet_magicAtk_moves = {
    ammo       = 'Hesperiidae',
    head       = MabGear.head,
    body       = MabGear.body,
    hands      = MabGear.hands,
    legs       = MabGear.legs,
    feet       = MabGear.feet,
    neck       = Necks.Adad,
    waist      = 'Incarnation Sash',
    left_ear   = Earrings.Hija,
    right_ear  = Earrings.Nukumi,
    left_ring  = BSTRings.Tali,
    right_ring = BSTRings.CPalug,
    back       = Artio.PETMB,
}

-- Magical accuracy Ready moves (debuffs, buffs)
sets.midcast.pet_magicAcc_moves = set_combine(sets.midcast.pet_magicAtk_moves, {})

-- Weapon-wielding variants
sets.midcast.pet_physical_moves_ww      = sets.midcast.pet_physical_moves
sets.midcast.pet_physicalMulti_moves_ww = sets.midcast.pet_physicalMulti_moves
sets.midcast.pet_magicAtk_moves_ww      = sets.midcast.pet_magicAtk_moves
sets.midcast.pet_magicAcc_moves_ww      = sets.midcast.pet_magicAcc_moves

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- Default WS set (STR/DEX hybrid)
sets.precast.WS = {
    ammo       = "Oshasha's Treatise",
    head       = Ankusa.head,
    body       = Gleti.body,
    hands      = Gleti.hands,
    legs       = Gleti.breeches,
    feet       = Nukumi.feet,
    neck       = Necks.BstCollar,
    waist      = 'Fotia Belt',
    left_ear   = Earrings.Sroda,
    right_ear  = Earrings.Nukumi,
    left_ring  = BSTRings.Gere,
    right_ring = BSTRings.Hetairoi,
    back       = Artio.WS1,
}

-- Primal Rend (MAB WS)
sets.precast.WS['Primal Rend'] = {
    ammo       = 'Ghastly Tathlum +1',
    head       = Nyame.head,
    body       = Nyame.body,
    hands      = Nyame.hands,
    legs       = Nyame.legs,
    feet       = Nyame.feet,
    neck       = Necks.Sibyl,
    waist      = "Orpheus's Sash",
    left_ear   = Earrings.Sortiarius,
    right_ear  = Earrings.Friomisi,
    left_ring  = BSTRings.Cornelia,
    right_ring = BSTRings.Metamorph,
    back       = Artio.WS1,
}

-- Decimation (Multi-hit physical)
sets.precast.WS['Decimation'] = {
    ammo  = 'Coiste Bodhar',
    head  = Nukumi.head,
    body  = Gleti.body,
    hands = Gleti.hands,
    legs  = Nukumi.legs,
    feet  = Nukumi.feet,
    neck  = 'Bst. Collar +2',
    waist = 'Sailfi Belt +1',
    ear1  = Earrings.Sherida,
    ear2  = 'Nukumi Earring +1',
    ring1 = BSTRings.Sroda,
    ring2 = BSTRings.Gere,
    back  = Artio.WS1,
}

-- Bora Axe (Single-hit physical)
sets.precast.WS['Bora Axe'] = {
    ammo  = 'Crepuscular Pebble',
    head  = Ankusa.head,
    body  = Gleti.body,
    hands = Nyame.hands,
    legs  = Nyame.legs,
    feet  = Nukumi.feet,
    neck  = 'Bst. Collar +2',
    waist = 'Sailfi Belt +1',
    ear1  = 'Odnowa Earring +1',
    ear2  = 'Nukumi Earring +1',
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Artio.WS1,
}

-- Calamity (physical WS)
sets.precast.WS['Calamity'] = {
    ammo       = 'Crepuscular Pebble',
    head       = Nyame.head,
    body       = Gleti.body,
    hands      = Nyame.hands,
    legs       = Nyame.legs,
    feet       = Nukumi.feet,
    neck       = Necks.BstCollar,
    waist      = 'Sailfi Belt +1',
    left_ear   = Earrings.Thrud,
    right_ear  = Earrings.Nukumi,
    left_ring  = BSTRings.Cornelia,
    right_ring = BSTRings.Murky,
    back       = Artio.WS1,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- TPBonus Sets (Moonshade)
-- ═══════════════════════════════════════════════════════════════════════════

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    left_ear = 'Moonshade Earring',   -- TP Bonus +250
}

-- TPBonus variants for weapon skills
sets.precast.WS['Primal Rend'].TPBonus = set_combine(sets.precast.WS['Primal Rend'], sets.precast.WS.TPBonus)
sets.precast.WS['Decimation'].TPBonus  = set_combine(sets.precast.WS['Decimation'],  sets.precast.WS.TPBonus)
sets.precast.WS['Bora Axe'].TPBonus    = set_combine(sets.precast.WS['Bora Axe'],    sets.precast.WS.TPBonus)
sets.precast.WS['Calamity'].TPBonus    = set_combine(sets.precast.WS['Calamity'],    sets.precast.WS.TPBonus)

-- ═══════════════════════════════════════════════════════════════════════════
-- UTILITY GEARSETS
-- ═══════════════════════════════════════════════════════════════════════════

-- Movement speed set
sets.MoveSpeed = {
    feet = Misc.SkdJambeaux,
}

-- Doom resistance set
sets.buff      = sets.buff or {}
sets.buff.Doom = {
    neck  = Necks.Nicander,
    ring1 = BSTRings.Purity,
    ring2 = BSTRings.Blenmot,
    waist = 'Gishdubar Sash',
}

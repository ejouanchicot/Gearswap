---  ═══════════════════════════════════════════════════════════════════════════
---   BRD Equipment Sets - Ultimate Bard Song Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua    -- Cross-job wardrobe rings
---     • Tetsouo/sets/brd/armor.lua       -- AF / Relic / Empyrean + Nyame / Mousai
---     • Tetsouo/sets/brd/capes.lua       -- Intarabus variants (fc / ws_str / stp)
---     • Tetsouo/sets/brd/instruments.lua -- Linos + all instruments
---     • Tetsouo/sets/brd/weapons.lua     -- Weapon set definitions
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   @file    Tetsouo/sets/brd/brd_sets.lua
---   @author  Tetsouo
---   @version 4.0 - Modularized
---   @date    Created: 2026-05-10 (modular split)
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings       = require('Tetsouo/sets/common/rings')
local Armor       = require('Tetsouo/sets/brd/armor')
local Capes       = require('Tetsouo/sets/brd/capes')
local Instruments = require('Tetsouo/sets/brd/instruments')
local Weapons     = require('Tetsouo/sets/brd/weapons')

-- Local aliases for readability
local Fili      = Armor.Fili
local Bihu      = Armor.Bihu
local Brioso    = Armor.Brioso
local Mousai    = Armor.Mousai
local Nyame     = Armor.Nyame
local Revel     = Armor.Revelation
local Linos     = Instruments.Linos
local Intarabus = Capes.Intarabus

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from brd/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE IDLE (Refresh Mode - MP Regen Focus)
sets.idle = {
    head      = Fili.head,
    body      = Fili.body,
    hands     = Fili.hands,
    legs      = Fili.legs,
    feet      = Fili.feet,
    neck      = 'Null Loop',
    waist     = 'Null Belt',
    left_ear  = 'Infused Earring',
    right_ear = 'Eabani Earring',
    ring1     = Rings.Moonlight1,
    ring2     = Rings.Moonlight2,
    back      = Intarabus.stp
}

-- • REFRESH MODE (Default Idle Set)
sets.idle.Refresh = set_combine(sets.idle, {})

-- • DT Mode (Damage Taken Reduction - Nyame)
sets.idle.DT = set_combine(sets.idle, {
    head       = Nyame.head,
    body       = Armor.Misc.AdamantiteArmor,
    hands      = Nyame.hands,
    legs       = Nyame.legs,
    feet       = Nyame.feet,
    neck       = 'Null Loop',
    waist      = 'Null Belt',
    left_ear   = 'Trux Earring',
    right_ear  = 'Cryptic Earring',
    left_ring  = 'Provocare Ring',
    right_ring = 'SuperShear Ring',
    back       = Intarabus.stp
})

-- • Regen Mode (HP Recovery - Nyame)
sets.idle.Regen = set_combine(sets.idle, {
    head  = Nyame.head,
    body  = Nyame.body,
    hands = Nyame.hands,
    legs  = Nyame.legs,
    feet  = Nyame.feet
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE ENGAGED (Fallback)
sets.engaged = {
    ranged     = Linos.tp,
    head       = Revel.head,
    body       = Revel.body,
    hands      = Fili.hands,
    legs       = Revel.legs,
    feet       = Revel.feet,
    neck       = "Bard's Charm +2",
    waist      = 'Kentarch Belt +1',
    left_ear   = 'Telos Earring',
    right_ear  = 'Crepuscular Earring',
    left_ring  = Rings.Chirich1,
    right_ring = Rings.Moonlight2,
    back       = Intarabus.stp
}

sets.engaged.STP   = set_combine(sets.engaged, {})
sets.engaged.Acc   = set_combine(sets.engaged, {})
sets.engaged.SB    = set_combine(sets.engaged, {})
sets.engaged.PDTKC = set_combine(sets.engaged, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • FAST CAST
sets.precast.FC = {
    head      = Fili.head,
    body      = Brioso.body,
    hands     = Armor.Misc.LeylineGloves,
    legs      = Fili.legs,
    feet      = Bihu.feet,
    neck      = "Orunmila's Torque",
    waist     = 'Witful Belt',
    left_ear  = 'Enchntr. Earring +1',
    right_ear = 'Loquac. Earring',
    ring1     = 'Prolix Ring',
    ring2     = 'Murky Ring',
    back      = Intarabus.fc
}

sets.precast.BardSong = sets.precast.FC

-- • Special precasts (instrument required)
sets.precast['Honor March']    = set_combine(sets.precast.FC, {range = Instruments.Marsyas})
sets.precast['Aria of Passion'] = set_combine(sets.precast.FC, {range = Instruments.Loughnashade})

-- • JOB ABILITIES
sets.precast.JA.Nightingale  = {feet = Bihu.feet}
sets.precast.JA.Troubadour   = {body = Bihu.body}
sets.precast.JA['Soul Voice'] = {legs = Bihu.legs}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • GENERIC WEAPONSKILL (Fallback)
sets.precast.WS = {
    ranged = Linos.ws,
    head   = Nyame.head,
    body   = Bihu.body,
    hands  = Nyame.hands,
    legs   = Nyame.legs,
    feet   = Nyame.feet,
    neck   = "Bard's Charm +2",
    waist  = 'Sailfi Belt +1',
    ear1   = 'Ishvara Earring',
    ear2   = 'Domin. Earring +1',
    ring1  = Rings.Moonlight1,
    ring2  = "Cornelia's Ring",
    back   = Intarabus.ws_str
}

-- • DAGGER WEAPONSKILLS

-- Evisceration (Dagger: Multi-hit DEX Crit)
sets.precast.WS['Evisceration'] = {
    ranged = Linos.ws,
    head   = Armor.Misc.BlisteringSallet,
    body   = Bihu.body,
    hands  = Nyame.hands,
    legs   = Nyame.legs,
    feet   = Armor.Misc.LustraLeggings,
    neck   = "Bard's Charm +2",
    waist  = 'Fotia Belt',
    ear1   = 'Odnowa Earring +1',
    ear2   = 'Domin. Earring +1',
    ring1  = 'Murky Ring',
    ring2  = Rings.Moonlight2,
    back   = "Intarabus's Cape"
}

-- Rudra's Storm (Dagger: Single-hit DEX)
sets.precast.WS["Rudra's Storm"] = {
    ranged = Linos.ws,
    head   = Nyame.head,
    body   = Bihu.body,
    hands  = Nyame.hands,
    legs   = Nyame.legs,
    feet   = Nyame.feet,
    neck   = "Bard's Charm +2",
    waist  = 'Kentarch Belt +1',
    ear1   = 'Mache Earring +1',
    ear2   = 'Domin. Earring +1',
    ring1  = "Cornelia's Ring",
    ring2  = Rings.Moonlight2,
    back   = Intarabus.ws_str
}

-- Mordant Rime (Dagger: Magical CHR/DEX)
sets.precast.WS['Mordant Rime'] = {
    ranged = Linos.ws,
    head   = Nyame.head,
    body   = Bihu.body,
    hands  = Nyame.hands,
    legs   = Nyame.legs,
    feet   = Nyame.feet,
    neck   = "Bard's Charm +2",
    waist  = 'Sailfi Belt +1',
    ear1   = 'Ishvara Earring',
    ear2   = 'Regal Earring',
    ring1  = "Cornelia's Ring",
    ring2  = 'Metamor. Ring +1',
    back   = Intarabus.ws_str
}

-- Ruthless Stroke (Sword: Single-hit STR Crit)
sets.precast.WS['Ruthless Stroke'] = {
    ranged = Linos.ws,
    head   = Nyame.head,
    body   = Bihu.body,
    hands  = Nyame.hands,
    legs   = Nyame.legs,
    feet   = Nyame.feet,
    neck   = "Null Loop",
    waist  = 'Sailfi Belt +1',
    ear1   = 'Ishvara Earring',
    ear2   = 'Domin. Earring +1',
    ring1  = "Cornelia's Ring",
    ring2  = 'Ilabrat Ring',
    back   = Intarabus.ws_str
}

-- • SWORD WEAPONSKILLS

-- Savage Blade (Sword: Single-hit STR/MND)
sets.precast.WS['Savage Blade'] = {
    ranged = Linos.ws,
    head   = Nyame.head_b,
    body   = Bihu.body_aug,
    hands  = Nyame.hands_b,
    legs   = Nyame.legs_b,
    feet   = Nyame.feet_b,
    neck   = "Null Loop",
    waist  = "Sailfi Belt +1",
    ear1   = 'Ishvara Earring',
    ear2   = 'Regal Earring',
    ring1  = "Sroda Ring",
    ring2  = "Cornelia's Ring",
    back   = Intarabus.ws_str
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}
sets.midcast['Enhancing Magic'] = {}

-- • BASE BARD SONG SETS
sets.midcast.BardSong = {
    main  = Instruments.Carnwenhan,
    sub   = 'Kali',
    range = Instruments.Gjallarhorn,
    head  = Fili.head,
    neck  = 'Mnbw. Whistle +1',
    ear1  = 'Musical Earring',
    ear2  = 'Fili Earring +1',
    body  = Fili.body,
    hands = Fili.hands,
    ring1 = Rings.Stikini1,
    ring2 = Rings.Stikini2,
    back  = Intarabus.fc,
    waist = {name = 'Platinum Moogle Belt', priority = 1},
    legs  = Armor.Misc.InyangaLegs,
    feet  = Brioso.feet
}

-- • Instrument variations
sets.midcast.Songs = {}
sets.midcast.Songs.Gjallarhorn = set_combine(sets.midcast.BardSong, {range = Instruments.Gjallarhorn})
sets.midcast.Songs.Marsyas     = set_combine(sets.midcast.BardSong, {range = Instruments.Marsyas})
sets.midcast.Songs.Daurdabla   = set_combine(sets.midcast.BardSong, {range = Instruments.Daurdabla})

-- • SPECIAL SONGS (Instrument Required)
sets.midcast.HonorMarch  = set_combine(sets.midcast.BardSong, {range = Instruments.Marsyas})
sets.midcast.AriaPassion = set_combine(sets.midcast.BardSong, {range = Instruments.Loughnashade})

-- • BUFF SONGS (Relic/Empyrean/AF Enhancements)
sets.midcast.Ballad   = set_combine(sets.midcast.BardSong, {legs = Fili.legs})
sets.midcast.Madrigal = set_combine(sets.midcast.BardSong, {head = Fili.head})
sets.midcast.Minuet   = set_combine(sets.midcast.BardSong, {body = Fili.body})
sets.midcast.Minne    = set_combine(sets.midcast.BardSong, {legs = Mousai.legs})
sets.midcast.Etude    = set_combine(sets.midcast.BardSong, {head = Mousai.head})
sets.midcast.March    = set_combine(sets.midcast.BardSong, {hands = Fili.hands})

sets.midcast["Army's Paeon"] = set_combine(sets.midcast.BardSong, {head = Brioso.head})
sets.midcast.Dirge           = set_combine(sets.midcast.BardSong, {head = Brioso.head})
sets.midcast.Paeon           = set_combine(sets.midcast.BardSong, {head = Brioso.head})

sets.midcast.Scherzo              = set_combine(sets.midcast.BardSong, {feet = Fili.feet})
sets.midcast["Sentinel's Scherzo"] = sets.midcast.Scherzo

sets.midcast.Carol = set_combine(sets.midcast.BardSong, {})
sets.midcast.Mambo = set_combine(sets.midcast.BardSong, {})

-- • DUMMY SONGS (Daurdabla +2 Song Slots)
sets.midcast.DummySong = {
    range     = Instruments.Daurdabla,
    head      = Nyame.head_b,
    body      = Armor.Misc.AdamantiteArmor,
    hands     = Fili.hands,
    legs      = Nyame.legs_b,
    feet      = Nyame.feet,
    neck      = 'Null Loop',
    waist     = 'Null Belt',
    left_ear  = 'Infused Earring',
    right_ear = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
    ring1     = Rings.Moonlight1,
    ring2     = Rings.Moonlight2,
    back      = 'Solemnity Cape'
}

sets.midcast['Gold Capriccio'] = sets.midcast.DummySong
sets.midcast['Goblin Gavotte'] = sets.midcast.DummySong
sets.midcast['Fowl Aubade']    = sets.midcast.DummySong
sets.midcast['Herb Pastoral']  = sets.midcast.DummySong

-- • DEBUFF SONGS (Magic Accuracy Focus)

-- Lullaby (Sleep) - NO weapon swap
sets.midcast.Lullaby = {
    range = Instruments.Daurdabla,
    head  = Brioso.head,
    body  = Fili.body,
    hands = Fili.hands,
    legs  = Fili.legs,
    feet  = Brioso.feet,
    neck  = 'Mnbw. Whistle +1',
    ear1  = 'Regal Earring',
    ear2  = 'Crepuscular Earring',
    ring1 = Rings.Stikini1,
    ring2 = Rings.Stikini2,
    waist = 'Acuity Belt +1',
    back  = Intarabus.fc
}

sets.midcast['Horde Lullaby']    = sets.midcast.Lullaby
sets.midcast['Horde Lullaby II'] = sets.midcast.Lullaby
sets.midcast['Foe Lullaby']      = sets.midcast.Lullaby
sets.midcast['Foe Lullaby II']   = sets.midcast.Lullaby

-- Base Debuff Song (Elegy, Requiem, Finale, etc.)
sets.midcast.DebuffSong = {
    range = Instruments.Gjallarhorn,
    head  = Brioso.head,
    body  = Fili.body,
    hands = Fili.hands,
    legs  = Fili.legs,
    feet  = Brioso.feet,
    neck  = 'Mnbw. Whistle +1',
    ear1  = 'Regal Earring',
    ear2  = 'Crepuscular Earring',
    ring1 = Rings.Stikini1,
    ring2 = 'Metamor. Ring +1',
    waist = 'Acuity Belt +1',
    back  = Intarabus.fc
}

sets.midcast['Pining Nocturne']     = set_combine(sets.midcast.DebuffSong, {})
sets.midcast['Magic Finale']        = sets.midcast.DebuffSong
sets.midcast['Battlefield Elegy']   = sets.midcast.DebuffSong
sets.midcast['Carnage Elegy']       = sets.midcast.DebuffSong
sets.midcast['Foe Requiem VII']     = sets.midcast.DebuffSong
sets.midcast["Maiden's Virelai"]    = sets.midcast.DebuffSong
sets.midcast.Threnody               = set_combine(sets.midcast.DebuffSong, {body = Mousai.body})

-- ═══════════════════════════════════════════════════════════════════════════
-- SPECIAL SETS (Movement & Buffs)
-- ═══════════════════════════════════════════════════════════════════════════

-- • MOVEMENT SPEED
sets.MoveSpeed = {feet = Fili.feet}

-- • TOWN IDLE (Movement Speed Priority)
sets.idle.Town = set_combine(sets.idle.DT, sets.MoveSpeed)

-- • ADOULIN MOVEMENT (City-Specific Speed Boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {body = "Councilor's Garb"})

-- • BUFF SETS
sets.buff = {}

-- • DOOM RESISTANCE
sets.buff.Doom = {
    neck  = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    waist = 'Gishdubar Sash'
}

print('[BRD] Equipment sets loaded successfully (modular v4.0)')

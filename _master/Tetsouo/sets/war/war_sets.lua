---  ═══════════════════════════════════════════════════════════════════════════
---   WAR Equipment Sets - Complete Gear Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua  -- Cross-job wardrobe rings
---     • Tetsouo/sets/war/armor.lua     -- AF / Relic / Empyrean + Sakpata / Nyame / etc.
---     • Tetsouo/sets/war/capes.lua     -- Cichol's Mantle variants
---     • Tetsouo/sets/war/weapons.lua   -- Weapon set definitions
---
---   This file only declares the SET COMPOSITIONS using the imports above.
---   Slots follow the in-game equipment screen order (ammo, head, neck, ears,
---   body, hands, rings, back, waist, legs, feet), the same order as a
---   //gs export, so an exported set can be compared line by line.
---
---   EAR / RING SIDES - each piece always sits on the same side, so moving
---   between sets never swaps a piece from one ear/hand to the other (a swap
---   unequips it, which also drops the HP of Moonlight pieces):
---     ear1  (left)  : Schere, Hoxne Earring, Dedition, Thrud, Sortiarius,
---                     Cryptic
---     ear2  (right) : Boii Earring +1 (its bonus is right-ear only), Odnowa,
---                     Crep., Friomisi
---     ring1 (left)  : Niqmaddu, Murky, Defending, Sroda, Chirich (1st),
---                     Moonlight (1st, only when both are worn), Provocare,
---                     Purity
---     ring2 (right) : Moonlight (wardrobe 2), Cornelia, Cacoethic +1, Gelatinous, Chirich
---                     (2nd), Prolix, Supershear, Blenmot's
---   When two left-side pieces meet, the more common one keeps the left and
---   the line is commented ("right: X holds the left").
---
---   Contents:
---     • Weapon sets    (loaded from weapons.lua)
---     • Idle sets      (Base, PDT, Town)
---     • Engaged sets   (Base, PDTTP/PDT, Normal, SubtleBlow)
---                      + weapon/buff specific (PDTAFM3, Ukonvasara, PDTKC, Naegling)
---                      + Hoxne stance (idle, engaged, engaged with AM3)
---     • Precast JA     (enmity bases, Provoke, Berserk, Warcry, Aggressor, etc.)
---     • Precast WS     (Great Axe, Polearm, Sword, Axe, Club)
---     • Movement sets  (Base speed, Adoulin)
---     • Buff sets      (Doom)
---
---   @file    Tetsouo/sets/war/war_sets.lua
---   @author  Tetsouo
---   @version 3.1 - Reorganized (equipment screen slot order, no duplicate sets)
---   @date    Updated: 2026-09-23
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings   = require('Tetsouo/sets/common/rings')
local Armor   = require('Tetsouo/sets/war/armor')
local Capes   = require('Tetsouo/sets/war/capes')
local Weapons = require('Tetsouo/sets/war/weapons')

local Boii      = Armor.Boii
local Agoge     = Armor.Agoge
local Pummeler  = Armor.Pummeler
local Sakpata   = Armor.Sakpata
local Nyame     = Armor.Nyame
local Tatenashi = Armor.Tatenashi
local Hjarrandi = Armor.Hjarrandi
local Dagon     = Armor.Dagon
local Sulevia   = Armor.Sulevia
local Souveran  = Armor.Souveran
local Acc       = Armor.Acc
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
    neck  = 'War. Beads +2',
    ear1  = 'Dedition Earring',
    ear2  = Boii.earring,
    body  = Boii.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.da,
    waist = 'Sailfi Belt +1',
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
}

-- • PDT Idle (Physical damage reduction)
sets.idle.PDT = set_combine(sets.idle, {
    head  = Sakpata.head,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    ring1 = 'Murky Ring',
    ring2 = Acc.GelatinousRing,
    back  = Acc.MoonlightCape,
    legs  = Sakpata.legs,
    feet  = Sakpata.feet,
})

-- • Town Idle (Movement speed + aesthetics)
sets.idle.Town = set_combine(sets.idle.PDT, {
    neck = 'Elite Royal Collar',
    feet = Misc.HermesSandals,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- Selection (shared/jobs/war/functions/logic/set_builder.lua), first match wins:
--   1. Kraken Club in sub           >> sets.engaged.PDTKC
--   2. Stance (SubtleBlow / Hoxne)  >> sets.engaged[HybridMode], or its
--                                      <mode>AFM3 variant under Aftermath Lv.3
--                                      with Ukonvasara (HoxneAFM3)
--   3. Aftermath Lv.3 + Ukonvasara  >> sets.engaged.PDTAFM3
--   4. Set named after the weapon   >> sets.engaged[MainWeapon] (Naegling, Ukonvasara)
--   5. HybridMode                   >> sets.engaged.PDT / .Normal

-- • Base Engaged (Balanced TP gain + multi-attack)
sets.engaged = {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    neck  = 'War. Beads +2',
    ear1  = 'Dedition Earring',
    ear2  = Boii.earring,
    body  = Boii.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.da,
    waist = 'Sailfi Belt +1',
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
}

-- ── HybridMode sets ─────────────────────────────────────────────────────────

-- • PDT (HybridMode 'PDT') - currently identical to the base set;
--   add the pieces that should differ inside the braces.
sets.engaged.PDTTP = set_combine(sets.engaged, {})
sets.engaged.PDT   = sets.engaged.PDTTP

-- • Normal (HybridMode 'Normal') - currently identical to the base set
sets.engaged.Normal = set_combine(sets.engaged, {})

-- • Subtle Blow (HybridMode 'SubtleBlow') - reduces TP fed to the mob
sets.engaged.SubtleBlow = set_combine(sets.engaged, {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Dagon.body,
    hands = Sakpata.hands,
    ring1 = Rings.Chirich1,
    ring2 = Rings.Chirich2,
    back  = Cichol.da,
    waist = 'Sailfi Belt +1',
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
})

-- ── Weapon / buff specific sets ─────────────────────────────────────────────

-- • Ukonvasara with Aftermath Lv.3 (DPS)
sets.engaged.PDTAFM3 = set_combine(sets.engaged.PDTTP, {
    ammo  = Misc.SeethingBomblet,
    head  = Sakpata.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.da,
    waist = 'Ioskeha Belt +1',
    legs  = Boii.legs,
    feet  = Boii.feet,
})

-- • Ukonvasara without Aftermath Lv.3 (grip comes from sets.Ukonvasara)
sets.engaged.Ukonvasara = set_combine(sets.engaged, {
    ammo  = Misc.CoisteBodhar,
    head  = Hjarrandi.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Boii.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.stp,
    waist = 'Sailfi Belt +1',
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
})

-- • Kraken Club in sub (multi-attack)
sets.engaged.PDTKC = set_combine(sets.engaged.PDTTP, {
    ammo  = Misc.AurgelmirOrb,
    head  = Pummeler.head,
    neck  = Acc.NullLoop,
    ear1  = 'Dedition Earring',
    ear2  = 'Crep. Earring',
    body  = Boii.body,
    hands = Tatenashi.hands,
    ring1 = Acc.MoonlightRing1,
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.stp,
    waist = 'Null Belt',
    legs  = Tatenashi.legs,
    feet  = Boii.feet,
})

-- • Naegling (MainWeapon 'Naegling', sword + shield)
sets.engaged.Naegling = set_combine(sets.engaged, {
    ammo  = Misc.CoisteBodhar,
    head  = Boii.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Boii.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.da,
    waist = 'Ioskeha Belt +1',
    legs  = Pummeler.legs,
    feet  = Pummeler.feet,
})

-- ── Hoxne stance (HybridMode 'Hoxne') ───────────────────────────────────────
-- The Hoxne Ampulla stays locked in the ammo slot for the whole stance
-- (shared/utils/equipment/ampulla_lock.lua); the weapon comes from MainWeapon
-- (Ukonvasara + Telopanos Grip).

-- • Idle while in the stance: PDT idle, holding the Ampulla
sets.idle.Hoxne = set_combine(sets.idle.PDT, {
    ammo = Misc.HoxneAmpulla,
})

-- • Engaged (TP build under the Ampulla's Double Attack)
sets.engaged.Hoxne = set_combine(sets.engaged, {
    ammo  = Misc.HoxneAmpulla,
    head  = Sulevia.head,
    neck  = Acc.NullLoop,
    ear1  = 'Schere Earring',
    ear2  = 'Dedition Earring',   -- right: Schere holds the left
    body  = Boii.body,
    hands = Tatenashi.hands,
    ring1 = 'Murky Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.stp,
    waist = 'Sailfi Belt +1',
    legs  = Tatenashi.legs,
    feet  = Tatenashi.feet,
})

-- • Engaged with Aftermath Lv.3 (Ukonvasara)
sets.engaged.HoxneAFM3 = set_combine(sets.engaged, {
    ammo  = Misc.HoxneAmpulla,
    head  = Sakpata.head,
    neck  = Acc.NullLoop,
    ear1  = 'Hoxne Earring',
    ear2  = Boii.earring,
    body  = Boii.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = 'Cacoethic Ring +1',
    back  = Cichol.stp,
    waist = 'Sailfi Belt +1',
    legs  = Boii.legs,
    feet  = Boii.feet,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.JA = {}

-- ── Enmity bases (shared by the JA sets below) ──────────────────────────────

-- • Less Enmity (self-buffs without pulling hate)
sets.LessEnmity = {
    ammo  = Misc.Psilomene,
    neck  = "Orunmila's Torque",
    ear1  = 'Sortiarius Earring',
    ring1 = 'Prolix Ring',          -- left: Cacoethic +1 holds the right
    ring2 = 'Cacoethic Ring +1',
    back  = Cichol.LessEnmity,
    waist = 'Acerbic Sash +1',
}

-- • Full Enmity (maximizes enmity generation for tanking)
sets.FullEnmity = {
    ammo  = Misc.SapienceOrb,
    head  = Souveran.head,
    neck  = 'Moonlight Necklace',
    ear1  = Acc.CrypticEarring,
    ear2  = 'Friomisi Earring',
    body  = Souveran.body,
    hands = Souveran.hands,
    ring1 = 'Provocare Ring',
    ring2 = Acc.SupershearRing,
    back  = Acc.EarthcryMantle,
    waist = Acc.TranceBelt,
    legs  = Souveran.legs,
    feet  = Souveran.feet,
}

-- ── Job abilities ───────────────────────────────────────────────────────────

-- • Provoke (Enmity generation)
sets.precast.JA['Provoke'] = sets.FullEnmity

-- • Berserk (Attack up)
sets.precast.JA['Berserk'] = set_combine(sets.LessEnmity, {
    body = Pummeler.body,    -- Duration +18 seconds
    feet = Agoge.feet,       -- Duration +30 seconds
})

-- • Warcry (Party attack up + TP bonus from Savagery merits)
sets.precast.JA['Warcry'] = set_combine(sets.LessEnmity, {
    head = Agoge.head,       -- TP bonus (requires Savagery merits)
})

-- • Aggressor (Accuracy up)
sets.precast.JA['Aggressor'] = set_combine(sets.LessEnmity, {
    head = Pummeler.head,    -- Duration +18 seconds
    body = Agoge.body,       -- Duration +30 seconds
})

-- • Defender (Defense up)
sets.precast.JA['Defender'] = set_combine(sets.engaged, {
    hands = Agoge.hands,
})

-- • Blood Rage (Party critical hit rate up)
sets.precast.JA['Blood Rage'] = set_combine(sets.LessEnmity, {
    body = Boii.body,
})

-- • Tomahawk (Ranged attack)
sets.precast.JA['Tomahawk'] = set_combine(sets.LessEnmity, {
    ammo = Misc.ThrowingTomahawk,
    feet = Agoge.feet,
})

-- • Jump / High Jump (/DRG subjob) - stay in TP gear
sets.precast.JA['Jump']      = sets.engaged.PDTTP
sets.precast.JA['High Jump'] = sets.engaged.PDTTP

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Weaponskill (fallback for any WS without its own set)
sets.precast.WS = {
    ammo  = Misc.Knobkierrie,
    head  = Sakpata.head,
    neck  = 'War. Beads +2',
    ear1  = 'Thrud Earring',
    ear2  = Boii.earring,
    body  = Sakpata.body,
    hands = Boii.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1,
    waist = 'Ioskeha Belt +1',
    legs  = Boii.legs,
    feet  = Sakpata.feet,
}

-- ── Great Axe ───────────────────────────────────────────────────────────────

-- • Armor Break (Defense down)
sets.precast.WS['Armor Break'] = set_combine(sets.precast.WS, {
    neck  = 'Fotia Gorget',
    waist = 'Fotia Belt',
})

-- • Ukko's Fury (Critical hit)
sets.precast.WS["Ukko's Fury"] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1,
    waist = 'Sailfi Belt +1',
    legs  = Boii.legs,
    feet  = Boii.feet,
})

-- • Upheaval (VIT physical)
sets.precast.WS['Upheaval'] = set_combine(sets.precast.WS, {
    ammo  = Misc.Knobkierrie,
    head  = Boii.head,
    neck  = Acc.NullLoop,
    ear1  = 'Schere Earring',
    ear2  = 'Thrud Earring',   -- right: Schere holds the left
    body  = Sakpata.body,
    hands = Sakpata.hands,
    ring1 = 'Niqmaddu Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1,
    waist = 'Ioskeha Belt +1',
    legs  = Boii.legs,
    feet  = Sakpata.feet,
})

-- • Fell Cleave (STR physical, AoE)
sets.precast.WS['Fell Cleave'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = 'Thrud Earring',   -- right: Schere holds the left
    body  = Sakpata.body,
    hands = Boii.hands,
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1,
    waist = 'Fotia Belt',
    legs  = Boii.legs,
    feet  = Nyame.feet,
})

-- • King's Justice (STR physical)
sets.precast.WS["King's Justice"] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Boii.head,
    neck  = 'War. Beads +2',
    ear1  = 'Schere Earring',
    ear2  = Boii.earring,
    body  = Sakpata.body,
    hands = Boii.hands,
    ring1 = 'Murky Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1,
    waist = 'Sailfi Belt +1',
    legs  = Boii.legs,
    feet  = Sakpata.feet,
})

-- ── Polearm ─────────────────────────────────────────────────────────────────

-- • Impulse Drive (STR physical, two hits)
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
    back  = Cichol.ws1,
    waist = 'Sailfi Belt +1',
    legs  = Boii.legs,
    feet  = Boii.feet,
})

-- • Stardiver (STR physical, four hits)
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
    back  = Cichol.ws1,
    waist = 'Fotia Belt',
    legs  = Boii.legs,
    feet  = Boii.feet,
})

-- ── Sword ───────────────────────────────────────────────────────────────────

-- • Savage Blade (STR/MND physical)
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Agoge.head,
    neck  = Acc.NullLoop,
    ear1  = 'Hoxne Earring',
    ear2  = 'Thrud Earring',   -- right: Hoxne holds the left
    body  = Sakpata.body,
    hands = Boii.hands,
    ring1 = 'Defending Ring',
    ring2 = Acc.MoonlightRing2,
    back  = Cichol.ws1,
    waist = 'Kentarch Belt +1',
    legs  = Boii.legs,
    feet  = Nyame.feet,
})

-- ── Axe ─────────────────────────────────────────────────────────────────────

-- • Calamity (STR/VIT physical)
sets.precast.WS['Calamity'] = set_combine(sets.precast.WS, {
    ammo  = Misc.CrepuscularPebble,
    head  = Agoge.head,
    neck  = 'War. Beads +2',
    ear1  = 'Thrud Earring',
    ear2  = Acc.OdnowaEarring,
    body  = Sakpata.body,
    hands = Sakpata.hands,
    ring1 = 'Sroda Ring',
    ring2 = "Cornelia's Ring",
    back  = Cichol.ws1,
    waist = 'Sailfi Belt +1',
    legs  = Sakpata.legs,
    feet  = Nyame.feet,
})

-- ── Club ────────────────────────────────────────────────────────────────────

-- • Judgment (STR/MND physical)
sets.precast.WS['Judgment'] = set_combine(sets.precast.WS, {
    ring2 = 'Murky Ring',   -- right: Niqmaddu (from the base WS set) holds the left
    legs  = Nyame.legs_b,
    feet  = Nyame.feet_b,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed (Hermes' Sandals)
sets.MoveSpeed = {
    feet = Misc.HermesSandals,
}

-- • Adoulin Movement (city-specific speed body)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = Misc.CouncilorsGarb,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.buff = {}

-- • Doom (worn while doomed)
sets.buff.Doom = {
    neck  = "Nicander's Necklace",
    ring1 = 'Purity Ring',
    ring2 = "Blenmot's Ring +1",
    waist = 'Gishdubar Sash',
}

print('[WAR] Equipment sets loaded successfully (modular v3.1)')

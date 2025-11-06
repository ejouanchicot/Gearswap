---============================================================================
--- RUN Equipment Sets - Ultimate Tanking Configuration
---============================================================================
--- Complete equipment configuration for Rune Fencer tank role with optimized
--- defensive and enmity gear across all combat situations.
---
--- @file    jobs/run/sets/run_sets.lua
--- @author  Kaories
--- @version 3.1 - Standardized Organization
--- @date    Updated: 2025-11-04
---============================================================================

--[[
    EQUIPMENT FORMAT EXAMPLE:

    -- For augmented gear with priority:
    Ogma = {
        tank = {
            name = "Ogma's Cape",
            priority = 1,
            augments = {'VIT+20', 'Eva.+20 /Mag. Eva.+20', 'Mag. Evasion+10', 'Enmity+10', 'Phys. dmg. taken-10%'}
        },
        FCSIRD = {
            name = "Ogma's Cape",
            priority = 12,
            augments = {'HP+60', 'HP+20', '"Fast Cast"+10', 'Spell interruption rate down-10%'}
        }
    }

    -- For simple gear:
    sets.idle = {
        head = "Turms Cap +1",
        body = "Runeist's Coat +3",
        hands = "Turms Mittens +1"
    }
]]

--============================================================--
--                  EQUIPMENT DEFINITIONS                     --
--============================================================--

-- Ogma's Capes
Ogma = {
    tank = {},
    FCSIRD = {},
    STP = {},
    WS = {}
}

-- Rings (Wardrobe-specific)
ChirichRing1 = {}
ChirichRing2 = {}
StikiRing1 = {}
StikiRing2 = {}
Moonlight1 = {}
Moonlight2 = {}

--============================================================--
--                      WEAPON SETS                           --
--============================================================--

sets.Epeolatry = {main="Epeolatry"}
sets.Lionheart = {main="Lionheart"}
sets.Aettir = {main="Aettir"}

-- Sub Weapons (Grips for Great Swords)
sets.Utu = {sub="Utu Grip"}
sets.Refined = {sub="Refined Grip +1"}

--============================================================--
--                      IDLE SETS                             --
--============================================================--

sets.idle = {}
sets.idle.PDT = {}
sets.idle.MDT = {}
sets.idle.Town = {}

--============================================================--
--                     ENGAGED SETS                           --
--============================================================--

sets.engaged = {}
sets.engaged.PDT = {}
sets.engaged.MDT = {}

--============================================================--
--                      MIDCAST SETS                          --
--        (Defined early for use in precast set_combine)     --
--============================================================--

sets.midcast = {}
sets.midcast.Enmity = {}
sets.midcast.SIRDEnmity = {}

--============================================================--
--                   PRECAST: JOB ABILITIES                   --
--============================================================--

sets.FullEnmity = {}

-- Runes Set (shared by all 8 elemental runes)
sets.Runes = {}

sets.precast.JA = {}

-- Elemental Runes (Lv5) - 8 runes total (all use sets.Runes)
sets.precast.JA['Ignis'] = sets.Runes       -- Fire rune, resist ice
sets.precast.JA['Gelus'] = sets.Runes       -- Ice rune, resist fire
sets.precast.JA['Flabra'] = sets.Runes      -- Wind rune, resist earth
sets.precast.JA['Tellus'] = sets.Runes      -- Earth rune, resist wind
sets.precast.JA['Sulpor'] = sets.Runes      -- Thunder rune, resist water
sets.precast.JA['Unda'] = sets.Runes        -- Water rune, resist thunder
sets.precast.JA['Lux'] = sets.Runes         -- Light rune, resist dark
sets.precast.JA['Tenebrae'] = sets.Runes    -- Dark rune, resist light

-- Subjob Accessible Abilities (each with individual set_combine)
sets.precast.JA['Vallation'] = set_combine(sets.FullEnmity, {})   -- Reduce elemental damage by runes
sets.precast.JA['Swordplay'] = set_combine(sets.FullEnmity, {})   -- ACC/EVA boost (stacking)
sets.precast.JA['Swipe'] = set_combine(sets.FullEnmity, {})       -- Single-target damage (1 rune)
sets.precast.JA['Lunge'] = set_combine(sets.FullEnmity, {})       -- Single-target damage (all runes)
sets.precast.JA['Pflug'] = set_combine(sets.FullEnmity, {})       -- Enhance elemental status resistance
sets.precast.JA['Valiance'] = set_combine(sets.FullEnmity, {})    -- Party elemental damage reduction

-- Main Job Only Abilities (each with individual set_combine)
sets.precast.JA['Embolden'] = set_combine(sets.FullEnmity, {})    -- Next enhancing +50% potency, -50% duration
sets.precast.JA['Vivacious Pulse'] = set_combine(sets.FullEnmity, {})  -- Restore HP based on runes
sets.precast.JA['Gambit'] = set_combine(sets.FullEnmity, {})      -- Reduce enemy elemental defense (all runes)
sets.precast.JA['Battuta'] = set_combine(sets.FullEnmity, {})     -- Parry rate +40%, counter damage
sets.precast.JA['Rayke'] = set_combine(sets.FullEnmity, {})       -- Reduce enemy elemental resistance
sets.precast.JA['Liement'] = set_combine(sets.FullEnmity, {})     -- Absorb elemental damage (10s)
sets.precast.JA['One for All'] = set_combine(sets.FullEnmity, {}) -- Party Magic Shield (HP × 0.2)

-- SP Abilities (each with individual set_combine)
sets.precast.JA['Elemental Sforzo'] = set_combine(sets.FullEnmity, {})     -- Immune to all magic attacks (30s)
sets.precast.JA['Odyllic Subterfuge'] = set_combine(sets.FullEnmity, {})   -- Enemy MACC -40 (30s)

--============================================================--
--                    PRECAST: FAST CAST                      --
--============================================================--

sets.precast.FC = {}
sets.precast.FC['Enhancing Magic'] = {}
sets.precast.FC['Phalanx'] = {}
sets.precast.FC['Stoneskin'] = {}
sets.precast.FC['Foil'] = {}
sets.precast.FC['Flash'] = {}
sets.precast.FC['Cocoon'] = {}
sets.precast.FC['Crusade'] = {}

--============================================================--
--                   PRECAST: WEAPONSKILLS                    --
--============================================================--

sets.precast.WS = {}
sets.precast.WS['Resolution'] = {}
sets.precast.WS['Dimidiation'] = {}
sets.precast.WS['Herculean Slash'] = {}
sets.precast.WS['Spinning Slash'] = {}
sets.precast.WS['Ground Strike'] = {}

-- Note: TPBonus handled automatically by TPBonusHandler system
-- No need for manual .TPBonus sets

--============================================================--
--                      MIDCAST SETS                          --
--============================================================--

sets.midcast.Enmity = sets.FullEnmity
sets.midcast.SIRDEnmity = {}
sets.midcast.PhalanxPotency = {}
sets.midcast.SIRDPhalanx = {}
sets.midcast['Enhancing Magic'] = {}
sets.midcast['Stoneskin'] = {}
sets.midcast['Regen'] = {}

-- Specific Midcast Spells
sets.midcast['Flash'] = sets.midcast.Enmity
sets.midcast['Foil'] = sets.midcast.Enmity
sets.midcast['Phalanx'] = {}
sets.midcast['Cocoon'] = {}
sets.midcast['Crusade'] = {}
sets.midcast['Reprisal'] = {}
sets.midcast['Aquaveil'] = {}
sets.midcast['Refresh'] = {}
sets.midcast['Haste'] = {}
sets.midcast['Protect'] = {}
sets.midcast['Shell'] = {}

--============================================================--
--                     MOVEMENT SETS                          --
--============================================================--

sets.MoveSpeed = {}
sets.Adoulin = {}

--============================================================--
--                      BUFF SETS                             --
--============================================================--

sets.buff.Doom = {}

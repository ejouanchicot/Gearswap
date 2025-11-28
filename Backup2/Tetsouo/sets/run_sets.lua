---  ═══════════════════════════════════════════════════════════════════════════
---   RUN Equipment Sets - Ultimate Tank Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Complete equipment configuration for Rune Fencer tank role with optimized
---   defensive and enmity gear across all combat situations.
---
---   Features:
---     • Tank optimization (Erilaz +3, Turms +1, Futhark +3)
---     • Enmity maximization (Full Enmity sets for all JAs)
---     • Rune system (No gear swap - maintains tank set)
---     • Spell Interruption Rate Down (SIRD for Phalanx, Enhancing)
---     • HybridMode support (PDT/MDT switching)
---     • Weapon switching (Epeolatry, Lycurgos with auto-grip management)
---     • Movement speed optimization (Carmine Cuisses +1)
---     • Weaponskill optimization (Nyame, Herculean augments)
---
---   Architecture:
---     • Equipment definitions (Ogma capes, wardrobe rings)
---     • Weapon sets (Epeolatry, Lycurgos + grips)
---     • Idle sets (Base, PDT, MDT, Town)
---     • Engaged sets (Base, PDT, MDT)
---     • Precast sets (Job Abilities, Fast Cast)
---     • Weaponskill sets (Resolution, Dimidiation, Armor Break)
---     • Midcast sets (Enmity, SIRD, Enhancing Magic, Phalanx)
---     • Movement & Buff sets (Speed, Doom, Adoulin)
---
---   @file    jobs/run/sets/run_sets.lua
---   @author  Tetsouo
---   @version 3.2 - Reorganized to BRD format
---   @date    Updated: 2025-11-11
---  ═══════════════════════════════════════════════════════════════════════════

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • RINGS (Wardrobe Management)
ChirichRing1 = {}
ChirichRing2 = {}
StikiRing1 = {}
StikiRing2 = {}
Moonlight1 = {}
Moonlight2 = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- AUGMENTED EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

-- • OGMA'S CAPES (Tank / FC+SIRD / Store TP / WS)
Ogma = {
    tank = {},
    FCSIRD = {},
    STP = {},
    WS = {}
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • GREAT SWORDS
sets.Epeolatry = {main = "Epeolatry"}

-- • GREAT AXES
sets.Lycurgos = {main = "Lycurgos"}

-- • GRIPS (Great Swords only - skipped for Lycurgos)
sets.Utu = {sub = "Utu Grip"}
sets.Refined = {sub = "Refined Grip +1"}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE IDLE (Defensive with Regen)
sets.idle = {
    ammo="Staunch Tathlum",
    head="Nyame Helm",
    body="Runeist Coat +3",
    hands="Turms Mittens +1",
    legs="Carmine Cuisses +1",
    feet="Erilaz Greaves +3",
    neck="Rep. Plat. Medal",
    waist="Engraved Belt",
    left_ear="Tuisto Earring",
    right_ear="Odnowa Earring +1",
    left_ring="Karieyh Ring",
    right_ring="Moonlight Ring",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},}

-- • PDT MODE (Physical Damage Taken -50%)
sets.idle.PDT = set_combine(sets.idle, {})

-- • MDT MODE (Magic Damage Taken -50%)
sets.idle.MDT = set_combine(sets.idle, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE ENGAGED (Defensive Melee)
sets.engaged = {
    ammo="Staunch Tathlum",
    head="Nyame Helm",
    body="Adamantite Armor",
    hands="Turms Mittens +1",
    legs="Eri. Leg Guards +3",
    feet="Erilaz Greaves +3",
    neck="Warder's Charm +1",
    waist="Engraved Belt",
    left_ear="Tuisto Earring",
    right_ear="Odnowa Earring +1",
    left_ring="Shadow Ring",
    right_ring="Moonlight Ring",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},
}

-- • PDT MODE (Physical Damage Taken -50%)
sets.engaged.PDT = set_combine(sets.engaged, {})

-- • MDT MODE (Magic Damage Taken -50%)
sets.engaged.MDT = set_combine(sets.engaged, {
    ammo="Yamarang",
    head="Erilaz Galea +3",
    body="Erilaz Surcoat +3",
    hands="Erilaz Gauntlets +3",
    legs="Eri. Leg Guards +3",
    feet="Erilaz Greaves +3",
    neck="Warder's Charm +1",
    waist="Engraved Belt",
    left_ear="Tuisto Earring",
    right_ear="Odnowa Earring +1",
    left_ring="Shadow Ring",
    right_ring="Moonlight Ring",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • FULL ENMITY BASE (Used by all JAs below)
sets.FullEnmity = {
    ammo="Sapience Orb",
    head="Halitus Helm",
    body="Emet Harness +1",
    hands="Kurys Gloves",
    legs="Eri. Leg Guards +3",
    feet="Erilaz Greaves +3",
    neck="Moonlight Necklace",
    waist="Kasiri Belt",
    left_ear="Friomisi Earring",
    right_ear="Cryptic Earring",
    left_ring="Eihwaz Ring",
    right_ring="Vexer Ring +1",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},
}

-- • RUNES (NO GEAR SWAP - Maintains current idle/engaged set)
--   Ignis, Gelus, Flabra, Tellus, Sulpor, Unda, Lux, Tenebrae
--   Strategy: No set defined = no equipment change = keep tank gear

-- • SUBJOB ACCESSIBLE ABILITIES
sets.precast.JA['Vallation'] = set_combine(sets.FullEnmity, {
body="Runeist Coat +3",})   -- Reduce elemental damage by runes

-- • ACC/EVA boost (stacking)
sets.precast.JA['Swordplay'] = set_combine(sets.FullEnmity, {
    hands = "Futhark Mitons +3"
})

-- • Single-target damage (1 rune)
sets.precast.JA['Swipe'] = set_combine(sets.FullEnmity, {})

-- • Single-target damage (all runes)
sets.precast.JA['Lunge'] = set_combine(sets.FullEnmity, {})

-- • Enhance elemental status resistance
sets.precast.JA['Pflug'] = set_combine(sets.FullEnmity, {})

sets.precast.JA['Valiance'] = set_combine(sets.FullEnmity, {
body="Runeist Coat +3",})    -- Party elemental damage reduction

-- • MAIN JOB ONLY ABILITIES
sets.precast.JA['Embolden'] = set_combine(sets.FullEnmity, {back = "Evasionist's Cape"}) -- Next enhancing +50% potency, -50% duration
sets.precast.JA['Vivacious Pulse'] = set_combine(sets.FullEnmity, {
head="Erilaz Galea +3",})  -- Restore HP based on runes
sets.precast.JA['Gambit'] = set_combine(sets.FullEnmity, {
hands="Runeist Mitons +3",})      -- Reduce enemy elemental defense (all runes)
sets.precast.JA['Battuta'] = set_combine(sets.FullEnmity, {
    head="Fu. Bandeau +3",})     -- Parry rate +40%, counter damage
sets.precast.JA['Rayke'] = set_combine(sets.FullEnmity, {
feet="Futhark Boots +3",})       -- Reduce enemy elemental resistance
sets.precast.JA['Liement'] = set_combine(sets.FullEnmity, {
body="Futhark Coat +3",})     -- Absorb elemental damage (10s)
sets.precast.JA['One for All'] = set_combine(sets.FullEnmity, {}) -- Party Magic Shield (HP × 0.2)

-- • SP ABILITIES
sets.precast.JA['Elemental Sforzo'] = set_combine(sets.FullEnmity, {
body="Futhark Coat +3",})     -- Immune to all magic attacks (30s)
sets.precast.JA['Odyllic Subterfuge'] = set_combine(sets.FullEnmity, {})   -- Enemy MACC -40 (30s)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

-- • BASE FAST CAST (Used for ALL spells via Mote-Include fallback)
--   Mote-Include automatic fallback hierarchy:
--     1. Spell-specific: sets.precast.FC.Blink or sets.precast.FC['Blink']
--     2. Skill-specific: sets.precast.FC['Enhancing Magic']
--     3. Base fallback:  sets.precast.FC (this set)
--
--   Both notations are equivalent in Lua:
--     sets.precast.FC.Blink         = {...}  (dot notation - cleaner)
--     sets.precast.FC['Blink']      = {...}  (bracket notation - for spaces/special chars)
--     sets.precast.FC['Blue Magic'] = {...}  (bracket required for spaces)
--
--   Examples:
--     sets.precast.FC.Blink = set_combine(sets.precast.FC, {head="Nyame Helm"})
--     sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist="Siegel Sash"})
--
sets.precast.FC = {
    ammo="Sapience Orb",
    head={ name="Carmine Mask +1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4',}},
    body="Erilaz Surcoat +3",
    hands="Agwu's Gages",
    legs="Agwu's Slops",
    feet={ name="Carmine Greaves +1", augments={'Accuracy+11','DEX+11','MND+18',}},
    neck="Baetyl Pendant",
    waist="Sailfi Belt +1",
    left_ear="Enchntr. Earring +1",
    right_ear="Loquac. Earring",
    left_ring="Naji's Loop",
    right_ring="Kishar Ring",
    back={ name="Ogma's Cape", augments={'"Fast Cast"+10','Spell interruption rate down-10%',}},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • GENERIC WEAPONSKILL (Fallback)
sets.precast.WS = {
    ammo="Knobkierrie",
    head="Nyame Helm",
    body="Nyame Mail",
    hands="Nyame Gauntlets",
    legs="Nyame Flanchard",
    feet="Nyame Sollerets",
    neck="Null Loop",
    waist="Sailfi Belt +1",
    left_ear="Moonshade Earring",
    right_ear="Sherida Earring",
    left_ring="Cornelia's Ring",
    right_ring="Karieyh Ring",
    back={ name="Ogma's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+5','"Dbl.Atk."+10','Damage taken-5%',}},
}

-- • GREAT SWORD WEAPONSKILLS
sets.precast.WS['Resolution'] = {}
sets.precast.WS['Dimidiation'] = {}
sets.precast.WS['Herculean Slash'] = {}
sets.precast.WS['Spinning Slash'] = {}
sets.precast.WS['Ground Strike'] = {}

-- • DEBUFF WEAPONSKILLS
sets.precast.WS['Armor Break'] = {
    ammo="Yamarang",
    head="Erilaz Galea +3",
    body="Nyame Mail",
    hands="Erilaz Gauntlets +3",
    legs="Eri. Leg Guards +3",
    feet="Erilaz Greaves +3",
    neck="Null Loop",
    waist="Null Belt",
    left_ear="Hermetic Earring",
    right_ear="Gwati Earring",
    left_ring="Metamor. Ring +1",
    right_ring="Cornelia's Ring",
    back={ name="Ogma's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+5','"Dbl.Atk."+10','Damage taken-5%',}},
}

-- Note: TPBonus handled automatically by TPBonusHandler system
-- No need for manual .TPBonus sets

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • ENMITY SPELLS (Flash, Foil)
sets.midcast.Enmity = sets.FullEnmity

-- • SIRD ENMITY (Flash with Spell Interruption Rate Down)
sets.midcast.SIRDEnmity = {
    ammo="Staunch Tathlum",
    head={ name="Taeon Chapeau", augments={'Spell interruption rate down -10%','Phalanx +3',}},
    body="Adamantite Armor",
    hands="Rawhide Gloves",
    legs="Carmine Cuisses +1",
    feet="Erilaz Greaves +3",
    neck="Moonlight Necklace",
    waist="Audumbla Sash",
    left_ear="Odnowa Earring +1",
    right_ear="Cryptic Earring",
    left_ring="Evanescence Ring",
    right_ring="Murky Ring",
    back={ name="Ogma's Cape", augments={'"Fast Cast"+10','Spell interruption rate down-10%',}},
}

-- • ENHANCING MAGIC BASE (Used for ALL Enhancing Magic via MidcastManager fallback)
--   SIRD priority for tank - prevents interruption during combat
sets.midcast['Enhancing Magic'] = {
    ammo="Staunch Tathlum",
    head="Erilaz Galea +3",
    body="Adamantite Armor",
    hands="Runeist Mitons +3",
    legs="Futhark Trousers +3",
    feet="Erilaz Greaves +3",
    neck="Incanter's Torque",
    waist="Engraved Belt",
    left_ear="Tuisto Earring",
    right_ear="Odnowa Earring +1",
    left_ring="Shadow Ring",
    right_ring="Moonlight Ring",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},
}

-- • SPECIFIC ENHANCING SPELLS
sets.midcast['Regen'] = {
    ammo="Staunch Tathlum",
    head="Rune. Bandeau +2",
    body="Adamantite Armor",
    hands="Runeist Mitons +3",
    legs="Futhark Trousers +3",
    feet="Erilaz Greaves +3",
    neck="Incanter's Torque",
    waist="Sroda Belt",
    left_ear="Tuisto Earring",
    right_ear="Odnowa Earring +1",
    left_ring="Shadow Ring",
    right_ring="Moonlight Ring",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},
}

-- • ENMITY SPELLS WITH SIRD
sets.midcast['Flash'] = sets.midcast.SIRDEnmity
sets.midcast['Foil'] = sets.midcast.SIRDEnmity
sets.midcast['Crusade'] = sets.midcast.SIRDEnmity

-- • PHALANX (SIRD + Phalanx+ augments)
--   RUN tank priority: SIRD to prevent interrupt
sets.midcast['Phalanx'] = {
    ammo="Staunch Tathlum",
    head="Fu. Bandeau +3",
    body={ name="Herculean Vest", augments={'"Rapid Shot"+4','DEX+4','Phalanx +5','Accuracy+1 Attack+1',}},
    hands={ name="Herculean Gloves", augments={'Crit. hit damage +1%','Pet: "Dbl. Atk."+1','Phalanx +4','Mag. Acc.+4 "Mag.Atk.Bns."+4',}},
    legs={ name="Herculean Trousers", augments={'"Cure" potency +1%','Pet: "Dbl. Atk."+3','Phalanx +4',}},
    feet={ name="Herculean Boots", augments={'Accuracy+18 Attack+18','Pet: Accuracy+28 Pet: Rng. Acc.+28','Phalanx +5',}},
    neck="Warder's Charm +1",
    waist="Flume Belt +1",
    left_ear="Tuisto Earring",
    right_ear="Odnowa Earring +1",
    left_ring="Shadow Ring",
    right_ring="Moonlight Ring",
    back={ name="Ogma's Cape", augments={'HP+60','Eva.+20 /Mag. Eva.+20','Mag. Evasion+10','Enmity+10','Parrying rate+5%',}},
}

-- • BLUE MAGIC (RUN/BLU subjob - ALL spells use this set)
--   Includes: Cocoon, Sudden Lunge, Head Butt, etc.
sets.midcast['Blue Magic'] = sets.midcast.SIRDEnmity

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • MOVEMENT SPEED (Applied when moving)
sets.MoveSpeed = {
    legs = "Carmine Cuisses +1"
}

-- • TOWN IDLE (Movement speed in towns)
sets.idle.Town = sets.MoveSpeed

-- • ADOULIN SPEED (Councilor's Garb bonus)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb"})

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}

-- • DOOM (Cursna Received +10)
sets.buff.Doom = {}

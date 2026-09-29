---============================================================================
--- DRG Equipment Sets - Dragoon Gear Configuration (template)
---============================================================================
--- Every set the DRG code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads. The commented
--- lines are examples of the kind of piece that goes there, not advice.
---
--- How the DRG code picks them (shared/jobs/drg):
---   • Idle: sets.idle (sets.idle.DT under Hybrid Mode DT), sets.idle.Town /
---     sets.Adoulin on top in a city; outside a city, while the wyvern is
---     out, sets.idle.Pet on top (sets.idle.Pet.DT under Hybrid Mode DT when
---     defined); then MainWeapon / SubWeapon, and sets.MoveSpeed while
---     moving outside a city.
---   • Engaged: sets.engaged, then [OffenseMode] (Acc), then .DT under
---     Hybrid Mode DT; sets.buff['Spirit Surge'] on top while Spirit Surge is
---     up; then MainWeapon / SubWeapon.
---   • Job abilities (Mote): sets.precast.JA[name], jumps included.
---   • Weaponskills (Mote): sets.precast.WS[name], then [WeaponskillMode].
---     Moonshade Earring is added when it reaches the next TP step
---     (config/drg/DRG_TP_CONFIG.lua).
---   • Midcast: sets.midcast.FastRecast first (Mote-Globals), then the
---     spell's own set (sets.midcast['Blue Magic'] on /BLU...).
---   • Healing Breath trigger: sets.midcast.HealingBreathTrigger on top of
---     any spell you cast while the wyvern is out and your HP is under the
---     trigger line of your subjob (see the set below).
---   • Wyvern breaths: sets.midcast.HealingBreath / ElementalBreath when
---     GearSwap reports the wyvern's breath (pet_midcast).
---
--- @file    sets/drg_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per MainWeapon / SubWeapon value of config/drg/DRG_STATES.lua, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on. Examples:
--   sets['Trishula'] = {main = "Trishula", sub = "Utu Grip"}
--   sets['Utu Grip'] = {sub = "Utu Grip"}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT AND TOWN
-- ═══════════════════════════════════════════════════════════════════════════
sets.MoveSpeed = {}        -- while moving, idle, outside a city
sets.Kiting = {}           -- Mote's Kiting toggle (Alt+F10), on top of idle and engaged
-- sets.Adoulin = {}       -- in Western / Eastern Adoulin, on top of idle (before sets.idle.Town)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff['Spirit Surge'] = {}  -- on top of engaged while Spirit Surge is up
sets.buff.Doom = {}             -- while doomed (shared Doom handling)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}

-- Jumps: attacks, worn as the jump lands. Each one starts as a copy of
-- sets.precast.JA.Jump: fill Jump first, then add what differs.
sets.precast.JA['Jump'] = {}                                                 -- Jump
sets.precast.JA['High Jump'] = set_combine(sets.precast.JA['Jump'], {})      -- High Jump
sets.precast.JA['Spirit Jump'] = set_combine(sets.precast.JA['Jump'], {})    -- Spirit Jump
sets.precast.JA['Soul Jump'] = set_combine(sets.precast.JA['Jump'], {})      -- Soul Jump
sets.precast.JA['Super Jump'] = {}                                           -- Super Jump (enmity drop, no attack)

sets.precast.JA['Call Wyvern'] = {}       -- Call Wyvern (e.g. wyvern HP pieces)
sets.precast.JA['Spirit Link'] = {}       -- Spirit Link
sets.precast.JA['Spirit Surge'] = {}      -- Spirit Surge (e.g. a Spirit Surge duration body)
sets.precast.JA['Angon'] = {}             -- Angon (e.g. an Angon ammo / hands)
sets.precast.JA['Ancient Circle'] = {}    -- Ancient Circle
sets.precast.JA['Deep Breathing'] = {}    -- Deep Breathing
sets.precast.JA['Dragon Breaker'] = {}    -- Dragon Breaker
sets.precast.JA['Fly High'] = {}          -- Fly High
sets.precast.JA['Spirit Bond'] = {}       -- Spirit Bond

-- Wyvern orders (pet commands): worn as you give the order.
sets.precast.JA['Restoring Breath'] = {}  -- Restoring Breath (the wyvern's Healing Breath follows)
sets.precast.JA['Smiting Breath'] = {}    -- Smiting Breath (an elemental breath follows)
-- No Steady Wing set on purpose: its barrier counts the wyvern HP gear worn
-- a tick BEFORE the order, a swap at the order does nothing (BG-Wiki).
-- Keep wyvern HP pieces in sets.idle.Pet / sets.engaged instead.

sets.precast.Waltz = {}                   -- Curing Waltz (/DNC)
sets.precast.Waltz['Healing Waltz'] = {}  -- Healing Waltz (/DNC)

sets.precast.FC = {}                      -- any spell's cast start

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}                                                     -- any weaponskill without its own set
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})                   -- WS Mode Acc (or Offense Mode Acc)
sets.precast.WS['Stardiver'] = set_combine(sets.precast.WS, {})
sets.precast.WS["Camlann's Torment"] = set_combine(sets.precast.WS, {})
sets.precast.WS['Drakesbane'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Impulse Drive'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Geirskogul'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Sonic Thrust'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
-- sets.precast.WS['Stardiver'].Acc = set_combine(sets.precast.WS['Stardiver'], {})  -- one WS, WS Mode Acc

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST (your spells: subjob magic)
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.FastRecast = {}   -- first, under every spell's set
-- sets.midcast['Blue Magic'] = set_combine(sets.midcast.FastRecast, {})  -- /BLU spells
-- sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})       -- Utsusemi (/NIN)

-- Healing Breath trigger: on top of any spell you cast while the wyvern is
-- out and your HP% is under the line of your subjob. The wyvern cures when
-- your HP at the END of the cast is under its line: 33.3% (defensive
-- wyvern: /WHM /BLM /RDM /SMN /BLU /SCH /GEO) or 25% (hybrid: /PLD /DRK
-- /BRD /NIN /RUN), raised to 50% / 33.3% by the Dragoon artifact head
-- (BG-Wiki "Healing Breath"). The job lays this set under 50% / 33.3%, so
-- put the artifact head here; other subjobs never trigger it.
sets.midcast.HealingBreathTrigger = {}
-- sets.midcast.HealingBreathTrigger = { head = "Vishap Armet +3" }

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST: THE WYVERN'S BREATHS
-- ═══════════════════════════════════════════════════════════════════════════
-- Worn when GearSwap reports the breath (pet_midcast): "Enhances Breath"
-- gear counts only if worn as the breath goes off.
sets.midcast.HealingBreath = {}     -- Healing Breath I-IV
sets.midcast.ElementalBreath = {}   -- Flame, Frost, Gust, Sand, Lightning, Hydro Breath

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}                             -- /heal

sets.idle = {}                                -- idle (under the wyvern layer)
sets.idle.DT = set_combine(sets.idle, {})     -- Hybrid Mode DT
sets.idle.Town = set_combine(sets.idle, {})   -- in a city, on top of the idle set

sets.idle.Pet = {}                            -- wyvern out, outside a city: on top of idle
sets.idle.Pet.DT = set_combine(sets.idle.Pet, {})  -- same, Hybrid Mode DT

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}                                  -- you fight
sets.engaged.Acc = set_combine(sets.engaged, {})   -- Offense Mode Acc
sets.engaged.DT = set_combine(sets.engaged, {})    -- Hybrid Mode DT
-- sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})  -- Acc and DT together

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Only for the shared Treasure Mode (//gs c th show): without this set it
-- puts on nothing.
-- sets.TreasureHunter = {}

---============================================================================
--- MNK Equipment Sets - Monk Gear Configuration (template)
---============================================================================
--- Every set the MNK code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads. The commented
--- lines are examples of the kind of piece that goes there, not advice.
---
--- How the MNK code picks them (shared/jobs/mnk):
---   • Idle: sets.idle (sets.idle.DT under Hybrid Mode DT), sets.idle.Town /
---     sets.Adoulin on top in a city; then MainWeapon, and sets.MoveSpeed
---     while moving outside a city.
---   • Engaged: sets.engaged, then [OffenseMode] (Acc), then [HybridMode]
---     (DT, Counter) from that level, else from sets.engaged. Then, on top,
---     for each buff that is up (later wins a shared slot):
---       sets.buff.Counterstance, sets.buff.Footwork, sets.buff.Impetus,
---       sets.buff['Hundred Fists']
---     A buff set may hold a child per Hybrid Mode value, worn instead of it
---     in that mode (sets.buff.Impetus.DT). Then MainWeapon.
---   • Weaponskills (Mote): sets.precast.WS[name], then [WeaponskillMode].
---     Then, on top:
---       Impetus up          sets.buff.Impetus, then sets.precast.WS[name].Impetus
---       Footwork up, on
---       Dragon Kick /
---       Tornado Kick        sets.buff.Footwork, then sets.precast.WS[name].Footwork
---     These two .Impetus / .Footwork children are LAYERS: only the pieces
---     that change. Moonshade Earring is added when it reaches the next TP
---     step (config/mnk/MNK_TP_CONFIG.lua).
---   • Job abilities (Mote): sets.precast.JA[name].
---   • Midcast: sets.midcast.FastRecast first (Mote-Globals), then the
---     spell's own set (sets.midcast.Utsusemi...).
---
--- @file    sets/mnk_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per MainWeapon value of config/mnk/MNK_STATES.lua, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on. Example:
--   sets['Godhands'] = {main = "Godhands"}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT AND TOWN
-- ═══════════════════════════════════════════════════════════════════════════
sets.MoveSpeed = {}        -- while moving, idle, outside a city
sets.Kiting = {}           -- Mote's Kiting toggle (Alt+F10), on top of idle and engaged
-- sets.Adoulin = {}       -- in Western / Eastern Adoulin, on top of idle (before sets.idle.Town)
-- sets.CombatMode = {}    -- put on when Combat Mode is turned On (weapon lock)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS (on top of the engaged set while the buff is up)
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff.Counterstance = {}       -- Counterstance up: counter gear (engaged)
sets.buff.Footwork = {}            -- Footwork up: kick gear (engaged, and Dragon / Tornado Kick)
sets.buff.Impetus = {}             -- Impetus up: e.g. the Bhikku Cyclas body (engaged, every weaponskill)
sets.buff['Hundred Fists'] = {}    -- Hundred Fists up (engaged)
-- sets.buff.Impetus.DT = {}       -- Impetus up, Hybrid Mode DT: worn INSTEAD of sets.buff.Impetus
sets.buff.Doom = {}                -- while doomed (shared Doom handling)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES, WALTZ, FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}
sets.precast.JA['Hundred Fists'] = {}     -- Hundred Fists (e.g. duration hose)
sets.precast.JA['Boost'] = {}             -- Boost
sets.precast.JA['Dodge'] = {}             -- Dodge
sets.precast.JA['Focus'] = {}             -- Focus
sets.precast.JA['Chakra'] = {}            -- Chakra: VIT and Chakra potency
sets.precast.JA['Chi Blast'] = {}         -- Chi Blast
sets.precast.JA['Counterstance'] = {}     -- Counterstance: counter-rate feet count when it is used
sets.precast.JA['Footwork'] = {}          -- Footwork
sets.precast.JA['Mantra'] = {}            -- Mantra
sets.precast.JA['Formless Strikes'] = {}  -- Formless Strikes
sets.precast.JA['Perfect Counter'] = {}   -- Perfect Counter
sets.precast.JA['Impetus'] = {}           -- Impetus
sets.precast.JA['Inner Strength'] = {}    -- Inner Strength

sets.precast.Waltz = {}                   -- Curing Waltz (/DNC)
sets.precast.Waltz['Healing Waltz'] = {}  -- Healing Waltz (/DNC)

sets.precast.FC = {}                                             -- any spell's cast start
sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})      -- Utsusemi (/NIN)

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}                                                  -- any weaponskill without its own set
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})                -- WS Mode Acc (or Offense Mode Acc)
sets.precast.WS['Victory Smite'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Shijin Spiral'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Asuran Fists'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Raging Fists'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Howling Fist'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Tornado Kick'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Dragon Kick'] = set_combine(sets.precast.WS, {})
sets.precast.WS["Ascetic's Fury"] = set_combine(sets.precast.WS, {})
sets.precast.WS['Final Heaven'] = set_combine(sets.precast.WS, {})

-- Buff layers on one weaponskill (only the pieces that change, see the header)
sets.precast.WS['Victory Smite'].Impetus = {}     -- Victory Smite with Impetus up
sets.precast.WS["Ascetic's Fury"].Impetus = {}    -- Ascetic's Fury with Impetus up
sets.precast.WS['Tornado Kick'].Footwork = {}     -- Tornado Kick with Footwork up
sets.precast.WS['Dragon Kick'].Footwork = {}      -- Dragon Kick with Footwork up

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST (subjob magic)
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.FastRecast = {}                                          -- first, under every spell's set
sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})      -- Utsusemi (/NIN)

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}                            -- /heal

sets.idle = {}                               -- standing, not fighting
sets.idle.DT = set_combine(sets.idle, {})    -- Hybrid Mode DT
sets.idle.Town = set_combine(sets.idle, {})  -- in a city, on top of the idle set

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}                                    -- fighting
sets.engaged.Acc = set_combine(sets.engaged, {})     -- Offense Mode Acc
sets.engaged.DT = set_combine(sets.engaged, {})      -- Hybrid Mode DT
sets.engaged.Counter = set_combine(sets.engaged, {}) -- Hybrid Mode Counter (counter rate, some DT)
-- sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})  -- Offense Mode Acc + Hybrid Mode DT

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Only for the shared Treasure Mode (//gs c th show): without this set it
-- puts on nothing.
-- sets.TreasureHunter = {}

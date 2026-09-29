---============================================================================
--- RNG Equipment Sets - Ranger Gear Configuration (template)
---============================================================================
--- Every set the RNG code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads. The commented
--- lines are examples of the kind of piece that goes there, not advice.
---
--- How the RNG code picks them (shared/jobs/rng):
---   • Ranged attack, aim (precast): sets.precast.RA (Snapshot / Rapid
---     Shot), then [RangedMode] (Acc), then .Flurry1 / .Flurry2 while that
---     Flurry is up on you; then sets.buff['Velocity Shot'] on top while
---     Velocity Shot is up.
---   • Ranged attack, shot (midcast): sets.midcast.RA, or
---     sets.midcast.RA[RangedMode]; then on top, each while its buff is up:
---     sets.buff['Velocity Shot'], ['Hover Shot'], ['Decoy Shot'],
---     ['Unlimited Shot'], ['Double Shot'], ['Barrage'] (the later wins a
---     slot two of them name).
---   • Weapons: sets['<value>'] of RangeWeapon (the range weapon AND its
---     ammo), MainWeapon, SubWeapon, on top of idle and engaged.
---   • Idle: sets.idle (sets.idle.DT under Hybrid Mode DT), sets.idle.Town /
---     sets.Adoulin on top in a city; weapons; sets.MoveSpeed while moving
---     outside a city.
---   • Engaged: sets.engaged, then [OffenseMode] (Acc), then .DT under Hybrid
---     Mode DT (from that level, else sets.engaged.DT); weapons.
---   • Job abilities (Mote): sets.precast.JA[name].
---   • Weaponskills (Mote): sets.precast.WS[name], then [WeaponskillMode]
---     (Archery / Marksmanship ones also follow Ranged Mode Acc, melee ones
---     Offense Mode Acc). Hachirin-no-Obi / Orpheus's Sash go on by
---     themselves for Trueflight and Wildfire (shared ElementalBelt).
---     Moonshade Earring is added when it reaches the next TP step
---     (config/rng/RNG_TP_CONFIG.lua).
---   • Midcast (subjob magic): sets.midcast.FastRecast first (Mote-Globals),
---     then the spell's own set (sets.midcast.Utsusemi...).
---
--- The ranged sets should not name range or ammo: the RangeWeapon set
--- holds them, and a ranged set that names an ammo changes what you shoot.
---
--- @file    sets/rng_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per value of RangeWeapon, MainWeapon and SubWeapon in
-- config/rng/RNG_STATES.lua, named exactly like the value, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on (a plain weapon then
-- needs no set, but brings no ammo). Examples:
--   sets['Fomalhaut']    = {range = "Fomalhaut", ammo = "Chrono Bullet"}
--   sets['Gastraphetes'] = {range = "Gastraphetes", ammo = "Quelling Bolt"}
--   sets['Naegling']     = {main = "Naegling"}
--   sets['Gleti\'s Knife'] = {sub = "Gleti's Knife"}

-- Off hand when Dual Wield is not there (RNG has none of its own: only
-- /NIN or /DNC give it): replaces the off-hand weapon of the weapon sets.
-- Without it the off hand is left as it is. Example:
-- sets.SingleWield = {sub = "Nusku Shield"}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT AND TOWN
-- ═══════════════════════════════════════════════════════════════════════════
sets.MoveSpeed = {}        -- while moving, idle, outside a city
sets.Kiting = {}           -- Mote's Kiting toggle (Alt+F10), on top of idle and engaged
-- sets.Adoulin = {}       -- in Western / Eastern Adoulin, on top of idle (before sets.idle.Town)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS (ranged attack layers, see the header)
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff['Velocity Shot'] = {}   -- on the aim and the shot while Velocity Shot is up (e.g. its body / back)
sets.buff['Hover Shot'] = {}      -- on the shot while Hover Shot is up
sets.buff['Decoy Shot'] = {}      -- on the shot while Decoy Shot is up
sets.buff['Unlimited Shot'] = {}  -- on the shot while Unlimited Shot is up (e.g. its feet)
sets.buff['Double Shot'] = {}     -- on the shot while Double Shot is up (Double Shot damage / rate)
sets.buff.Barrage = {}            -- on the shot while Barrage is up (e.g. Barrage hands)
sets.buff.Doom = {}               -- while doomed (shared Doom handling)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: RANGED ATTACK (the aim)
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.RA = {}                                         -- Snapshot / Rapid Shot, no Flurry
sets.precast.RA.Flurry1 = set_combine(sets.precast.RA, {})   -- Flurry I on you (less Snapshot needed)
sets.precast.RA.Flurry2 = set_combine(sets.precast.RA, {})   -- Flurry II on you
-- sets.precast.RA.Acc = set_combine(sets.precast.RA, {})    -- Ranged Mode Acc (then .Flurry1 / .Flurry2 under it)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES, WALTZ, FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.JA = {}
sets.precast.JA['Eagle Eye Shot'] = {}   -- Eagle Eye Shot (the ability is the shot: ranged damage gear)
sets.precast.JA['Bounty Shot'] = {}      -- Bounty Shot
sets.precast.JA['Scavenge'] = {}         -- Scavenge
sets.precast.JA['Camouflage'] = {}       -- Camouflage
sets.precast.JA['Shadowbind'] = {}       -- Shadowbind
sets.precast.JA['Sharpshot'] = {}        -- Sharpshot

sets.precast.Waltz = {}                  -- Curing Waltz (/DNC)
sets.precast.Waltz['Healing Waltz'] = {} -- Healing Waltz (/DNC)

sets.precast.FC = {}                                             -- any spell's cast start
sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})      -- Utsusemi (/NIN)

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}                                                  -- any weaponskill without its own set
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})                -- WS Mode Acc (or Ranged / Offense Mode Acc)
sets.precast.WS['Last Stand'] = set_combine(sets.precast.WS, {})      -- Marksmanship
sets.precast.WS['Wildfire'] = set_combine(sets.precast.WS, {})        -- Marksmanship, magical
sets.precast.WS['Trueflight'] = set_combine(sets.precast.WS, {})      -- Marksmanship, magical
sets.precast.WS['Coronach'] = set_combine(sets.precast.WS, {})        -- Marksmanship
sets.precast.WS["Jishnu's Radiance"] = set_combine(sets.precast.WS, {})  -- Archery
sets.precast.WS['Empyreal Arrow'] = set_combine(sets.precast.WS, {})  -- Archery
sets.precast.WS['Apex Arrow'] = set_combine(sets.precast.WS, {})      -- Archery
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})    -- Sword
sets.precast.WS['Evisceration'] = set_combine(sets.precast.WS, {})    -- Dagger

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST: RANGED ATTACK (the shot)
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.RA = {}                                    -- every shot (ranged attack, damage / Store TP)
sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {})  -- Ranged Mode Acc (^numpad3)

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST: SUBJOB MAGIC
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast.FastRecast = {}                                          -- first, under every spell's set
sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})      -- Utsusemi (/NIN)

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}                            -- /heal

sets.idle = {}                               -- standing, not fighting
sets.idle.DT = set_combine(sets.idle, {})    -- Hybrid Mode DT (^numpad9), outside a city
sets.idle.Town = set_combine(sets.idle, {})  -- in a city, on top of the idle set

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}                                    -- fighting
sets.engaged.Acc = set_combine(sets.engaged, {})     -- Offense Mode Acc
sets.engaged.DT = set_combine(sets.engaged, {})      -- Hybrid Mode DT (also under Acc without sets.engaged.Acc.DT)

-- ═══════════════════════════════════════════════════════════════════════════
-- DUAL WIELD TIERS (optional, see config/DW_CONFIG.lua and //gs c dw)
-- ═══════════════════════════════════════════════════════════════════════════
-- While two weapons are held (/NIN, /DNC) and engaged, the pieces of one tier
-- go on top of the engaged set, chosen by your magic haste. A tier left out
-- uses the one below. Uncomment and fill with your own gear:
--
-- sets.DW = {}
-- sets.DW.NoHaste  = {}   -- magic haste under 15 %
-- sets.DW.Haste    = {}   -- 15 %
-- sets.DW.HasteII  = {}   -- 30 %
-- sets.DW.MaxHaste = {}   -- cap

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Only for the shared Treasure Mode (//gs c th show): without this set it
-- puts on nothing.
-- sets.TreasureHunter = {}

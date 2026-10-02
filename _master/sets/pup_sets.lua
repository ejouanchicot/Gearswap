---============================================================================
--- PUP Equipment Sets - Puppetmaster Gear Configuration (template)
---============================================================================
--- Every set the PUP code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads. The commented
--- lines are examples of the kind of piece that goes there, not advice.
---
--- How the PUP code picks them (shared/jobs/pup):
---   • Idle: sets.idle (sets.idle.DT under Hybrid Mode DT), sets.idle.Town /
---     sets.Adoulin on top in a city; then the automaton layer on top:
---       out and fighting  sets.idle.Pet.Engaged[PetMode], else
---                         sets.idle.Pet.Engaged
---       out, not fighting sets.idle.Pet
---     then sets.buff.Overdrive, the automaton WS set (below), MainWeapon,
---     and sets.MoveSpeed while moving outside a city.
---   • Engaged: sets.engaged, or sets.engaged.Pet while the automaton fights
---     too; then [OffenseMode] (Acc); then .DT under Hybrid Mode DT; then
---     sets.buff.Overdrive, the automaton WS set, MainWeapon.
---   • Automaton WS: sets.midcast.Pet.WeaponSkill[PetMode], else
---     sets.midcast.Pet.WeaponSkill, laid on top of idle / engaged while
---     Pet WS is On, the automaton fights and its TP is at least pet_ws_tp
---     (config/pup/PUP_TP_CONFIG.lua, 1000).
---   • Automaton spells (Mote): sets.midcast.Pet[spell name], [spell map]
---     (Cure...), [skill] ('Elemental Magic'...).
---   • PetMode values: Melee, Tank, Ranged, Magic, Heal, Nuke (set from the
---     automaton's head).
---   • Job abilities (Mote): sets.precast.JA[name]; every maneuver wears
---     sets.precast.JA.Maneuver.
---   • Weaponskills (Mote): sets.precast.WS[name], then [WeaponskillMode].
---     Moonshade Earring is added when it reaches the next TP step
---     (config/pup/PUP_TP_CONFIG.lua).
---   • Midcast: sets.midcast.FastRecast first (Mote-Globals), then the
---     spell's own set (sets.midcast.Utsusemi...).
---
--- @file    sets/pup_sets.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2026-09-29
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per MainWeapon value of config/pup/PUP_STATES.lua, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on. Example:
--   sets['Xiucoatl'] = {main = "Xiucoatl"}

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
sets.buff.Overdrive = {}   -- on top of idle and engaged while Overdrive is up
sets.buff.Doom = {}        -- while doomed (shared Doom handling)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES, WALTZ, FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}
sets.precast.JA['Activate'] = {}          -- Activate
sets.precast.JA['Deus Ex Automata'] = {}  -- Deus Ex Automata
sets.precast.JA['Repair'] = {}            -- Repair (e.g. an oil-boosting ear / feet)
sets.precast.JA['Maintenance'] = {}       -- Maintenance
sets.precast.JA['Overdrive'] = {}         -- Overdrive
sets.precast.JA['Tactical Switch'] = {}   -- Tactical Switch
sets.precast.JA['Ventriloquy'] = {}       -- Ventriloquy
sets.precast.JA['Role Reversal'] = {}     -- Role Reversal
sets.precast.JA['Cooldown'] = {}          -- Cooldown
sets.precast.JA.Maneuver = {}             -- every <Element> Maneuver

sets.precast.Waltz = {}                   -- Curing Waltz (/DNC)
sets.precast.Waltz['Healing Waltz'] = {}  -- Healing Waltz (/DNC)

sets.precast.FC = {}                                             -- any spell's cast start
sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})      -- Utsusemi (/NIN)

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS (yours)
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}                                                  -- any weaponskill without its own set
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})                -- WS Mode Acc (or Offense Mode Acc)
sets.precast.WS['Victory Smite'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Shijin Spiral'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Stringing Pummel'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Howling Fist'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Asuran Fists'] = set_combine(sets.precast.WS, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST (yours: subjob magic)
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.FastRecast = {}                                          -- first, under every spell's set
sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})      -- Utsusemi (/NIN)

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST: THE AUTOMATON'S ACTIONS
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast.Pet = {}

-- Automaton weaponskills: laid BEFORE the weaponskill (see the header), one
-- per PetMode when you want (a mode with no set uses .WeaponSkill itself).
sets.midcast.Pet.WeaponSkill = {}
sets.midcast.Pet.WeaponSkill.Melee = set_combine(sets.midcast.Pet.WeaponSkill, {})
sets.midcast.Pet.WeaponSkill.Tank = set_combine(sets.midcast.Pet.WeaponSkill, {})
-- Ranged mode: RangedPet, never .Ranged (GearSwap would read it as the range slot)
sets.midcast.Pet.WeaponSkill.RangedPet = set_combine(sets.midcast.Pet.WeaponSkill, {})
-- sets.midcast.Pet['Arcuballista'] = {}  -- one weaponskill by name, when it goes off

-- Automaton spells, when it starts casting
sets.midcast.Pet.Cure = {}                  -- Cure I-VI (Soulsoother, Stormwaker)
sets.midcast.Pet['Elemental Magic'] = {}    -- nukes (Spiritreaver, Stormwaker)
sets.midcast.Pet['Enfeebling Magic'] = {}   -- enfeebles

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}                            -- /heal

sets.idle = {}                               -- no automaton out
sets.idle.DT = set_combine(sets.idle, {})    -- no automaton out, Hybrid Mode DT
sets.idle.Town = set_combine(sets.idle, {})  -- in a city, on top of the idle set

sets.idle.Pet = {}                           -- automaton out, not fighting
sets.idle.Pet.Engaged = {}                   -- automaton fighting, you are not
sets.idle.Pet.Engaged.Melee = set_combine(sets.idle.Pet.Engaged, {})
sets.idle.Pet.Engaged.Tank = set_combine(sets.idle.Pet.Engaged, {})
sets.idle.Pet.Engaged.RangedPet = set_combine(sets.idle.Pet.Engaged, {})  -- Ranged mode (see above)
sets.idle.Pet.Engaged.Magic = set_combine(sets.idle.Pet.Engaged, {})
sets.idle.Pet.Engaged.Heal = set_combine(sets.idle.Pet.Engaged, {})
sets.idle.Pet.Engaged.Nuke = set_combine(sets.idle.Pet.Engaged, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}                                    -- you fight (automaton not fighting)
sets.engaged.Acc = set_combine(sets.engaged, {})     -- Offense Mode Acc
sets.engaged.DT = set_combine(sets.engaged, {})      -- Hybrid Mode DT

sets.engaged.Pet = {}                                -- you and the automaton both fight
sets.engaged.Pet.DT = set_combine(sets.engaged.Pet, {})  -- both fight, Hybrid Mode DT

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Only for the shared Treasure Mode (//gs c th show): without this set it
-- puts on nothing.
-- sets.TreasureHunter = {}

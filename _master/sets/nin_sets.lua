---============================================================================
--- NIN Equipment Sets - Ninja Gear Configuration (template)
---============================================================================
--- Every set the NIN code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads. The commented
--- lines are examples of the kind of piece that goes there, not advice.
---
--- How the NIN code picks them (shared/jobs/nin):
---   • Idle: sets.idle.Town / sets.Adoulin on top of the idle in a city;
---     outside a city sets.idle.DT under Hybrid Mode DT, else sets.idle.
---     Then MainWeapon / SubWeapon, and while moving outside a city
---     sets.MoveSpeed.Night from dusk to dawn (17:00-7:00 Vana'diel time),
---     sets.MoveSpeed the rest of the day.
---   • Engaged: sets.engaged, then [OffenseMode] (Acc), then .DT under
---     Hybrid Mode DT (sets.engaged.Acc.DT if you make one, else
---     sets.engaged.DT); then one layer per buff up: sets.buff.Yonin,
---     sets.buff.Innin, sets.buff.Sange, sets.buff.Issekigan; then the
---     weapons; then the Dual Wield tier pieces (sets.DW, below).
---   • Ninjutsu (midcast): sets.midcast.Utsusemi, sets.midcast.Migawari,
---     sets.midcast.Ninjutsu.Elemental (Katon..Doton; .MagicBurst under
---     Magic Burst On), .Enfeebling (Kurayami, Hojo, Jubaku, Aisha, Yurin,
---     Dokumori), .Enhancing (Tonko, Monomi, Myoshu, Kakka, Gekka, Yain),
---     sets.midcast.Ninjutsu for anything else. A spell's own set
---     (sets.midcast['Katon: San']) wins over them. sets.buff.Futae goes on
---     top of an elemental ninjutsu while Futae is up. Obi / Orpheus: the
---     shared ElementalBelt.
---   • Job abilities (Mote): sets.precast.JA[name].
---   • Weaponskills (Mote): sets.precast.WS[name], then [WeaponskillMode].
---     Moonshade Earring is added when it reaches the next TP step
---     (config/nin/NIN_TP_CONFIG.lua).
---   • Ranged attack (shuriken, Mote): sets.precast.RA, sets.midcast.RA.
---   • Midcast: sets.midcast.FastRecast first (Mote-Globals), then the sets
---     above.
---
--- @file    sets/nin_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per MainWeapon / SubWeapon value of config/nin/NIN_STATES.lua, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on. Examples:
--   sets['Heishi Shorinken'] = {main = "Heishi Shorinken"}
--   sets['Kunimitsu'] = {sub = "Kunimitsu"}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT AND TOWN
-- ═══════════════════════════════════════════════════════════════════════════
sets.MoveSpeed = {}                                    -- while moving, idle, outside a city
sets.MoveSpeed.Night = set_combine(sets.MoveSpeed, {}) -- the same from 17:00 to 7:00 (Vana'diel)
-- Dusk-to-dawn feet (e.g. Ninja Kyahan +1 or better, Hachiya Kyahan) give
-- their speed from 17:00 to 7:00; plain Ninja Kyahan only from 18:00 to 6:00.
sets.Kiting = {}           -- Mote's Kiting toggle (Alt+F10), on top of idle and engaged
-- sets.Adoulin = {}       -- in Western / Eastern Adoulin, on top of idle (before sets.idle.Town)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff.Yonin = {}       -- on top of engaged while Yonin is up (e.g. Yonin counter legs)
sets.buff.Innin = {}       -- on top of engaged while Innin is up (e.g. Innin head)
sets.buff.Sange = {}       -- on top of engaged while Sange is up (every round throws a shuriken)
sets.buff.Issekigan = {}   -- on top of engaged while Issekigan is up (parry / enmity)
sets.buff.Futae = {}       -- on top of an elemental ninjutsu cast under Futae (e.g. Futae hands)
sets.buff.Doom = {}        -- while doomed (shared Doom handling)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES, WALTZ, FAST CAST, RANGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}
sets.precast.JA['Mijin Gakure'] = {}  -- Mijin Gakure
sets.precast.JA['Yonin'] = {}         -- Yonin
sets.precast.JA['Innin'] = {}         -- Innin
sets.precast.JA['Futae'] = {}         -- Futae
sets.precast.JA['Sange'] = {}         -- Sange (gear that enhances it counts when it is used)
sets.precast.JA['Issekigan'] = {}     -- Issekigan
sets.precast.JA['Mikage'] = {}        -- Mikage
sets.precast.JA['Provoke'] = {}       -- Provoke (/WAR): enmity

sets.precast.Waltz = {}                   -- Curing Waltz (/DNC)
sets.precast.Waltz['Healing Waltz'] = {}  -- Healing Waltz (/DNC)
sets.precast.Step = {}                    -- steps (/DNC): accuracy

sets.precast.FC = {}                                          -- any spell's cast start
sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {})   -- Utsusemi's cast start

sets.precast.RA = {}       -- shuriken throw start (Snapshot)

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}                                                  -- any weaponskill without its own set
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})                -- WS Mode Acc (or Offense Mode Acc)
sets.precast.WS['Blade: Hi'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Blade: Shun'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Blade: Metsu'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Blade: Ku'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Blade: Ten'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Blade: Chi'] = set_combine(sets.precast.WS, {})     -- hybrid (earth)
sets.precast.WS['Blade: Teki'] = set_combine(sets.precast.WS, {})    -- hybrid (water)
sets.precast.WS['Blade: To'] = set_combine(sets.precast.WS, {})      -- hybrid (ice)
sets.precast.WS['Blade: Ei'] = set_combine(sets.precast.WS, {})      -- magical (dark)
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {})   -- magical (wind)
-- A WS Mode Acc version of one weaponskill:
-- sets.precast.WS['Blade: Hi'].Acc = set_combine(sets.precast.WS['Blade: Hi'], {})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.FastRecast = {}                                         -- first, under every spell's set
sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {})     -- Utsusemi: Ichi / Ni / San
sets.midcast.Migawari = set_combine(sets.midcast.FastRecast, {})     -- Migawari: Ichi

sets.midcast.Ninjutsu = {}                                           -- any other ninjutsu
sets.midcast.Ninjutsu.Elemental = {}                                 -- Katon..Doton (damage)
sets.midcast.Ninjutsu.Elemental.MagicBurst = set_combine(sets.midcast.Ninjutsu.Elemental, {})  -- Magic Burst On
sets.midcast.Ninjutsu.Enfeebling = {}                                -- Kurayami, Hojo, Jubaku...: magic accuracy
sets.midcast.Ninjutsu.Enhancing = set_combine(sets.midcast.FastRecast, {})  -- Tonko, Monomi, Myoshu, Kakka, Gekka, Yain

sets.midcast.RA = {}       -- shuriken throw (ranged accuracy / attack)

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}                            -- /heal

sets.idle = {}                               -- idle
sets.idle.DT = set_combine(sets.idle, {})    -- idle outside a city, Hybrid Mode DT
sets.idle.Town = set_combine(sets.idle, {})  -- in a city, on top of the idle set

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}                                    -- fighting
sets.engaged.Acc = set_combine(sets.engaged, {})     -- Offense Mode Acc
sets.engaged.DT = set_combine(sets.engaged, {})      -- Hybrid Mode DT (any Offense Mode without its own .DT)
-- sets.engaged.Acc.DT = set_combine(sets.engaged.Acc, {})  -- Offense Mode Acc + Hybrid Mode DT

-- ═══════════════════════════════════════════════════════════════════════════
-- DUAL WIELD TIERS (optional, see config/DW_CONFIG.lua and //gs c dw)
-- ═══════════════════════════════════════════════════════════════════════════
-- While two weapons are held and engaged, the pieces of one tier go on top of
-- the engaged set, chosen by your magic haste. Ninja has Dual Wield V of its
-- own, so it needs fewer pieces than a /NIN or /DNC job at each tier. Only
-- the Dual Wield pieces you still need at that haste; a tier left out uses
-- the one below. Uncomment and fill with your own gear:
--
-- sets.DW = {}
-- sets.DW.NoHaste  = { waist = "Reiki Yotai" }   -- no haste
-- sets.DW.Haste    = { waist = "Reiki Yotai" }   -- 15 %
-- sets.DW.HasteII  = {}                          -- 30 %
-- sets.DW.MaxHaste = {}                          -- cap

-- ═══════════════════════════════════════════════════════════════════════════
-- COMBAT MODE (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Put on when Combat Mode is turned On, before the weapons are locked.
-- sets.CombatMode = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Only for the shared Treasure Mode (//gs c th show): without this set it
-- puts on nothing.
-- sets.TreasureHunter = {}

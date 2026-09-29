---============================================================================
--- SCH Equipment Sets - Scholar Gear Configuration (template)
---============================================================================
--- Every set the SCH code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads. The commented
--- lines are examples of the kind of piece that goes there, not advice.
---
--- How the SCH code picks them (shared/jobs/sch):
---   • Idle: sets.idle.Town / sets.Adoulin on top of the idle in a city,
---     else sets.idle.DT under Hybrid Mode DT, else sets.idle; then
---     sets.buff.Sublimation while Sublimation charges, the weapons, and
---     sets.MoveSpeed while moving outside a city.
---   • Engaged: sets.engaged, then [OffenseMode] (Acc), then .DT under
---     Hybrid Mode DT; then the weapons.
---   • Precast (Mote): sets.precast.FC[spell name / map / skill], then on
---     top sets.precast.FC.Grimoire when the spell is of the Arts in force
---     (white magic + Light Arts / Addendum: White, black magic + Dark Arts
---     / Addendum: Black), sets.buff.Celerity (white) / sets.buff.Alacrity
---     (black) while that stratagem is up.
---   • Midcast (MidcastManager, first found): sets.midcast[spell name], the
---     name without tier (sets.midcast.Aspir for Aspir II), the database
---     family (sets.midcast.Regen, sets.midcast.Storm), the Mote map
---     (sets.midcast.Cure, .StatusRemoval), the skill's set. Nukes wear
---     .MagicBurst under Magic Burst On; helices wear sets.midcast.Helix
---     (.Dark for Noctohelix, .Light for Luminohelix, .MagicBurst);
---     Kaustra sets.midcast.Kaustra(.MagicBurst). Then on top, while the
---     stratagem is up: Perpetuance (enhancing), Rapture (white magic),
---     Ebullience (black magic), Immanence (elemental), Klimaform
---     (elemental of the weather's element), Celerity / Alacrity again.
---     Hachirin-no-Obi / Orpheus's Sash go on by themselves (ElementalBelt).
---   • Job abilities (Mote): sets.precast.JA[name].
---   • Weaponskills (Mote): sets.precast.WS[name]. Moonshade Earring is
---     added when it reaches the next TP step (config/sch/SCH_TP_CONFIG.lua).
---
--- @file    sets/sch_sets.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-09-29
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per MainWeapon / SubWeapon value of config/sch/SCH_STATES.lua, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on. Example:
--   sets['Musa'] = {main = "Musa", sub = "Khonsu"}
-- sets.CombatMode = {}   -- put on when Combat Mode turns On, then locked

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT AND TOWN
-- ═══════════════════════════════════════════════════════════════════════════
sets.MoveSpeed = {}        -- while moving, idle, outside a city
sets.Kiting = {}           -- Mote's Kiting toggle (Alt+F10), on top of idle and engaged
-- sets.Adoulin = {}       -- in Western / Eastern Adoulin, on top of idle (before sets.idle.Town)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS (grimoire and stratagems)
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff.Sublimation = {}   -- idle, while Sublimation charges (e.g. Pedagogy Gown, Embla Sash)
sets.buff.Perpetuance = {}   -- midcast, Enhancing Magic under Perpetuance (e.g. Arbatel Bracers)
sets.buff.Rapture = {}       -- midcast, white magic under Rapture (e.g. Arbatel Bonnet)
sets.buff.Ebullience = {}    -- midcast, black magic under Ebullience (e.g. Arbatel Bonnet)
sets.buff.Immanence = {}     -- midcast, Elemental Magic under Immanence (e.g. Arbatel Bracers)
sets.buff.Klimaform = {}     -- midcast, Elemental Magic of the weather's element under Klimaform (e.g. Arbatel Loafers)
sets.buff.Celerity = {}      -- precast and midcast, white magic under Celerity (e.g. Pedagogy Loafers)
sets.buff.Alacrity = {}      -- precast and midcast, black magic under Alacrity (e.g. Pedagogy Loafers)
sets.buff.Doom = {}          -- while doomed (shared Doom handling)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES, WALTZ, FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}
sets.precast.JA['Tabula Rasa'] = {}     -- Tabula Rasa
sets.precast.JA['Enlightenment'] = {}   -- Enlightenment

sets.precast.Waltz = {}                   -- Curing Waltz (/DNC)
sets.precast.Waltz['Healing Waltz'] = {}  -- Healing Waltz (/DNC)

sets.precast.FC = {}                                                   -- any spell's cast start
sets.precast.FC.Grimoire = {}                                          -- on top: spell of the Arts in force ("Grimoire: spellcasting time")
sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {})  -- enhancing spells
sets.precast.FC['Elemental Magic'] = set_combine(sets.precast.FC, {})  -- nukes and helices
sets.precast.FC.Cure = set_combine(sets.precast.FC, {})                -- Cure I-IV (Mote map)

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}                                                  -- any weaponskill without its own set
sets.precast.WS['Myrkr'] = set_combine(sets.precast.WS, {})           -- MP
sets.precast.WS['Omniscience'] = set_combine(sets.precast.WS, {})     -- magical
sets.precast.WS['Cataclysm'] = set_combine(sets.precast.WS, {})       -- magical
sets.precast.WS['Shattersoul'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Black Halo'] = set_combine(sets.precast.WS, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.FastRecast = {}                                          -- first, under every spell's set

-- Elemental Magic
sets.midcast['Elemental Magic'] = {}                                  -- nukes
sets.midcast['Elemental Magic'].MagicBurst = set_combine(sets.midcast['Elemental Magic'], {})  -- nukes, Magic Burst On
sets.midcast.Helix = set_combine(sets.midcast['Elemental Magic'], {})  -- helices (Pyrohelix...)
sets.midcast.Helix.MagicBurst = set_combine(sets.midcast.Helix, {})   -- helices, Magic Burst On
sets.midcast.Helix.Dark = set_combine(sets.midcast.Helix, {})         -- Noctohelix (e.g. Pixie Hairpin +1, Archon Ring)
sets.midcast.Helix.Light = set_combine(sets.midcast.Helix, {})        -- Luminohelix (e.g. Weatherspoon Ring)

-- Dark Magic
sets.midcast['Dark Magic'] = {}                                       -- other Dark Magic
sets.midcast.Kaustra = set_combine(sets.midcast['Dark Magic'], {})    -- Kaustra
sets.midcast.Kaustra.MagicBurst = set_combine(sets.midcast.Kaustra, {})  -- Kaustra, Magic Burst On
sets.midcast.Drain = set_combine(sets.midcast['Dark Magic'], {})      -- Drain
sets.midcast.Aspir = set_combine(sets.midcast['Dark Magic'], {})      -- Aspir I-II

-- Enhancing Magic
sets.midcast['Enhancing Magic'] = {}                                  -- other enhancing spells (duration)
sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {})  -- Regen I-V (potency / duration)
sets.midcast.Storm = set_combine(sets.midcast['Enhancing Magic'], {})  -- storms I-II
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {})

-- Enfeebling Magic
sets.midcast['Enfeebling Magic'] = {}                                 -- used when the two below are missing
sets.midcast.MndEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})  -- white enfeebles (Paralyze, Slow, Silence...)
sets.midcast.IntEnfeebles = set_combine(sets.midcast['Enfeebling Magic'], {})  -- black enfeebles (Sleep, Blind, Break, Dispel...)

-- Healing Magic
sets.midcast['Healing Magic'] = {}                                    -- other Healing Magic (Raise...)
sets.midcast.Cure = {}                                                -- Cure I-IV (Mote map)
sets.midcast.Curaga = set_combine(sets.midcast.Cure, {})              -- Curaga (/WHM)
sets.midcast.StatusRemoval = {}                                       -- -na spells, Erase (Mote map)
sets.midcast.Cursna = set_combine(sets.midcast.StatusRemoval, {})     -- Cursna

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}                            -- /heal

sets.idle = {}                               -- idle
sets.idle.DT = set_combine(sets.idle, {})    -- Hybrid Mode DT, outside a city
sets.idle.Town = set_combine(sets.idle, {})  -- in a city, on top of the idle set

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}                                    -- fighting
sets.engaged.Acc = set_combine(sets.engaged, {})     -- Offense Mode Acc
sets.engaged.DT = set_combine(sets.engaged, {})      -- Hybrid Mode DT

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER (optional)
-- ═══════════════════════════════════════════════════════════════════════════
-- Only for the shared Treasure Mode (//gs c th show): without this set it
-- puts on nothing.
-- sets.TreasureHunter = {}

---============================================================================
--- BLU Equipment Sets - Blue Mage Gear Configuration (template)
---============================================================================
--- Every set the BLU code reads, EMPTY: fill in your own pieces. An empty set
--- changes nothing, so the job works as soon as it loads.
---
--- How the BLU code picks them (shared/jobs/blu):
---   • Idle: sets.idle[IdleMode] (Normal = sets.idle), sets.idle.Town in a
---     city when defined, then MainWeapon / SubWeapon, then sets.MoveSpeed
---     while moving outside a city.
---   • Engaged: sets.engaged, then .SW when single wielding (nothing, a
---     shield or a grip in the off hand), then [OffenseMode] when that level
---     has it; then the weapons.
---   • Weaponskills (Mote): sets.precast.WS[name], then [WeaponskillMode]
---     (Acc...). Moonshade Earring is added when it reaches the next TP step
---     (config/blu/BLU_TP_CONFIG.lua).
---   • Fast Cast (Mote): sets.precast.FC['Blue Magic'] for Blue Magic,
---     sets.precast.FC otherwise.
---   • Midcast: sets.midcast.FastRecast first (Mote), then:
---       Blue Magic: sets.midcast[spell name] if it exists, else
---         sets.midcast['Blue Magic'][category][CastingMode],
---         sets.midcast['Blue Magic'][category], sets.midcast['Blue Magic'].
---         The category of each spell: config/blu/BLU_SPELL_MAP.lua. Do not
---         name a set at the root of sets.midcast after a category.
---       Then sets.buff['Chain Affinity'] (etc.) while that buff is up, and
---       sets.self_healing for a Healing spell on yourself.
---       Other magic (subjob): sets.midcast[spell name], [skill], or
---       [spell type] ('WhiteMagic' for a WHM/RDM spell with no skill set).
---
--- @file    sets/blu_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- One per MainWeapon / SubWeapon value of config/blu/BLU_STATES.lua, unless
-- config/WEAPON_CONFIG.lua turns equip_without_set on (then a plain weapon
-- needs no set). Examples:
--   sets['Naegling'] = {main = "Naegling"}
--   sets['Thibron']  = {sub = "Thibron"}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT
-- ═══════════════════════════════════════════════════════════════════════════
sets.MoveSpeed = {}        -- while moving, idle, outside a city
sets.Kiting = {}           -- Mote's Kiting toggle (Alt+F10)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS (on top of Blue Magic while the buff is up)
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff['Burst Affinity'] = {}
sets.buff['Chain Affinity'] = {}
sets.buff.Convergence = {}
sets.buff.Diffusion = {}
sets.buff.Efflux = {}
sets.buff.Doom = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES, WALTZ, FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}
sets.precast.JA['Azure Lore'] = {}

sets.precast.Waltz = {}
sets.precast.Waltz['Healing Waltz'] = {}

sets.precast.FC = {}
sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast.WS = {}
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

sets.precast.WS['Expiacion'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})
sets.precast.WS['Sanguine Blade'] = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}
sets.midcast.FastRecast = {}

sets.midcast['Blue Magic'] = {}

-- • Physical
sets.midcast['Blue Magic'].Physical = {}
sets.midcast['Blue Magic'].PhysicalAcc = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalStr = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalDex = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalVit = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalAgi = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalInt = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalMnd = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalChr = set_combine(sets.midcast['Blue Magic'].Physical, {})
sets.midcast['Blue Magic'].PhysicalHP = set_combine(sets.midcast['Blue Magic'].Physical, {})

-- • Magical (.Resistant = CastingMode Resistant)
sets.midcast['Blue Magic'].Magical = {}
sets.midcast['Blue Magic'].Magical.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {})
sets.midcast['Blue Magic'].MagicalEarth = set_combine(sets.midcast['Blue Magic'].Magical, {})
sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})
sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})
sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})
sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})

-- • Magic accuracy, enmity, breath, stun
sets.midcast['Blue Magic'].MagicAccuracy = {}
sets.midcast['Blue Magic'].TPRemoval = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
sets.midcast['Blue Magic'].Enmity = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
sets.midcast['Blue Magic'].Breath = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
sets.midcast['Blue Magic'].Stun = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})

-- • Healing and buffs
sets.midcast['Blue Magic'].Healing = {}
sets.self_healing = set_combine(sets.midcast['Blue Magic'].Healing, {})     -- Healing spell on yourself
sets.midcast['Blue Magic'].SkillBasedBuff = set_combine(sets.midcast.FastRecast, {})
sets.midcast['Blue Magic'].Buff = set_combine(sets.midcast.FastRecast, {})

-- • Spells with their own set
sets.midcast['Sound Blast'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
sets.midcast['Restoral'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
sets.midcast['White Wind'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})

-- • Subjob magic
sets.midcast['WhiteMagic'] = set_combine(sets.midcast['Blue Magic'].Healing, {})   -- WHM/RDM spells (Mote: spell type)
sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
sets.midcast['Phalanx'] = set_combine(sets.midcast['Blue Magic'].Buff, {})
sets.midcast.Refresh = set_combine(sets.midcast['WhiteMagic'], sets.midcast['Blue Magic'].Buff, {})

-- • Blue Magic skill (spell learning), worn by hand: //gs equip sets.Learning
sets.Learning = set_combine(sets.midcast['Blue Magic'].SkillBasedBuff, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE
-- ═══════════════════════════════════════════════════════════════════════════
sets.resting = {}

sets.idle = {}
sets.idle.Evasion = {}
sets.idle.DT = set_combine(sets.idle, {})
sets.idle.Regain = set_combine(sets.idle, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}
sets.engaged.Acc = set_combine(sets.engaged, {})
sets.engaged.DT = set_combine(sets.engaged, {})
sets.engaged['Subtle Blow'] = set_combine(sets.engaged, {})
sets.engaged.Refresh = set_combine(sets.engaged, {})

-- Single wield (nothing, a shield or a grip in the off hand). An OffenseMode
-- with no .SW version here uses sets.engaged.SW itself.
sets.engaged.SW = set_combine(sets.engaged, {})
sets.engaged.SW.Acc = set_combine(sets.engaged.Acc, {})
sets.engaged.SW.Refresh = set_combine(sets.engaged, {})

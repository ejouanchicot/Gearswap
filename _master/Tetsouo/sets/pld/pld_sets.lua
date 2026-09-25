---  ═══════════════════════════════════════════════════════════════════════════
---   PLD Equipment Sets - Ultimate Tanking Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Modularized version - equipment definitions live in companion files:
---     • Tetsouo/sets/common/rings.lua  -- Cross-job wardrobe rings
---     • Tetsouo/sets/pld/armor.lua     -- AF / Relic / Empyrean / Sakpata / Nyame / Odyssean / Jumalik
---     • Tetsouo/sets/pld/capes.lua     -- Rudianos's Mantle variants (tank/FCSIRD/STP/WS/cure/EnmitySIRD)
---     • Tetsouo/sets/pld/weapons.lua   -- Weapon set definitions
---
---   This file only declares the SET COMPOSITIONS using imports above.
---
---   PLD relies heavily on `priority = N` fields: GearSwap equips in
---   descending priority, so ranking a set's slots by the HP each piece gains
---   over the set being left keeps the HP pool from dipping mid-swap. The rank
---   belongs to the set, not to the piece - the same item outranks itself in
---   another context, which is what the local prio() helper below expresses.
---   See armor.lua / capes.lua for the ranks carried by the lookups.
---
---   HybridMode picks the engaged set. PDT / MDT / Sortie on most subjobs;
---   under /SCH, three stances of their own:
---     • DPS     -> sets.engaged.DPS     Sakpata's, Coiste Bodhar
---     • Tanking -> sets.engaged.MDT     mitigation, Burtgang + Aegis
---     • Hoxne   -> sets.engaged.Hoxne   Hoxne Ampulla, ammo slot frozen
---   The mapping itself lives in logic/set_builder.lua.
---
---   @file    Tetsouo/sets/pld/pld_sets.lua
---   @author  Tetsouo
---   @version 4.1
---   @date    Created: 2026-05-11 (modular split) | Updated: 2026-09-21
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- MODULE IMPORTS
-- ═══════════════════════════════════════════════════════════════════════════

local Rings = require('Tetsouo/sets/common/rings')
local Armor = require('Tetsouo/sets/pld/armor')
local Capes = require('Tetsouo/sets/pld/capes')
local Weapons = require('Tetsouo/sets/pld/weapons')

-- Local aliases for readability
local Chev = Armor.Chev
local Reverence = Armor.Reverence
local Caballarius = Armor.Caballarius
local Souveran = Armor.Souveran
local Sakpata = Armor.Sakpata
local Nyame = Armor.Nyame
local Loess = Armor.LoessBarbuta
local Odyssean = Armor.Odyssean
local Jumalik = Armor.Jumalik
local Weard = Armor.Weard
local Misc = Armor.Misc
local Rudianos = Capes.Rudianos

-- PLD-specific Moonlight rings (priorities matter for HP delta optimization).
-- These have explicit priorities that the shared common/rings.lua doesn't carry.
local Moonlight1 = {name = 'Moonlight Ring', priority = 13, bag = 'wardrobe 1'}
local Moonlight2 = {name = 'Moonlight Ring', priority = 12, bag = 'wardrobe 2'}

-- Priority ranks the slots of ONE set swap: GearSwap equips in descending
-- priority (helper_functions.lua, priority_list:it takes the maximum each
-- pass), so a piece needs its own rank per set it appears in. Copying the
-- definition keeps the name and the augments declared in a single place -
-- retyping them is how a set ends up wearing the wrong item.
--- @param item table|string Equipment definition to copy
--- @param priority number Rank within the set this copy is used in
--- @return table Copy carrying the new priority
local function prio(item, priority)
    if type(item) == 'string' then
        return {name = item, priority = priority}
    end

    local copy = {priority = priority}
    for key, value in pairs(item) do
        if key ~= 'priority' then
            copy[key] = value
        end
    end
    return copy
end

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS (loaded from pld/weapons.lua)
-- ═══════════════════════════════════════════════════════════════════════════

for name, weapon_set in pairs(Weapons) do
    sets[name] = weapon_set
end

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Idle Set (Foundation for all idle variants)
-- Held in a local, and copied into sets.idle rather than being it. Every
-- variant below attaches itself as a key on sets.idle (sets.idle.PDT, .MDT,
-- .Town), and set_combine copies every key of its source - so deriving from
-- sets.idle would carry those variants into the derived set as slots that are
-- not slots. GearSwap ignores them, but they read as intentional and follow
-- the chain all the way down (idleNormal -> engaged -> engaged.DPS -> ...).
local IdleBase = {
    ammo = Misc.StaunchTathlum, -- delta Phx=0
    head = Chev.head, -- delta Phx=+145
    body = Misc.Adamantite, -- delta Phx=+182 (biggest GAIN, equip FIRST)
    hands = Chev.hands, -- delta Phx=-175 (LOSS, equip late)
    legs = Chev.legs, -- delta Phx=+13
    feet = Chev.feet, -- delta Phx=-175 (biggest LOSS, equip LAST)
    neck = {name = 'Kgt. Beads +2', priority = 10},
    -- delta Phx=+60
    waist = {name = 'Flume Belt +1', priority = 7}, -- delta Phx=0
    left_ear = {name = 'Tuisto Earring', priority = 6},
    -- delta Phx=0 (same item)
    right_ear = {name = 'Odnowa Earring +1', priority = 11}, -- delta Phx=+110
    left_ring = {name = 'Fortified Ring', priority = 5}, -- delta Phx=0
    right_ring = {name = 'Gelatinous Ring +1', priority = 4},
    -- delta Phx=0 (same item)
    back = Rudianos.tank -- delta Phx=0, priority via def (3)
}

sets.idle = set_combine(IdleBase, {})

-- • PDT Idle (Physical Defense)
sets.idle.PDT =
    set_combine(
    IdleBase,
    {
        sub = 'Duban' -- PDT shield
    }
)

-- • MDT Idle (Magical Defense)
sets.idle.MDT = {
    ammo = 'Staunch Tathlum +1',
    head = Sakpata.head,
    body = Sakpata.body,
    hands = Sakpata.hands,
    legs = Sakpata.legs,
    feet = Sakpata.feet,
    neck = 'Moonlight Necklace',
    waist = "Carrier's Sash",
    left_ear = 'Tuisto Earring',
    right_ear = 'Eabani Earring',
    left_ring = 'Purity Ring',
    right_ring = {name = 'Gelatinous Ring +1', augments = {'Path: A'}},
    back = Rudianos.tank,
    sub = 'Aegis' -- MDT shield
}

-- • Normal Idle (Balanced)
sets.idleNormal =
    set_combine(
    IdleBase,
    {
        head = {name = 'Chev. Armet +3', priority = 14},
        body = Misc.AdamantiteEng,
        legs = Misc.ChevLegsNormal,
        neck = {name = 'Kgt. Beads +2', priority = 17},
        waist = {name = 'Creed Baudrier', priority = 18},
        left_ring = Moonlight1,
        right_ring = Moonlight2
    }
)

-- • XP Idle (Experience points focus)
sets.idleXp =
    set_combine(
    IdleBase,
    {
        main = 'Burtgang',
        sub = 'Duban',
        body = {name = 'Chev. Cuirass +3', priority = 16}
    }
)

--- Regen overlay, /SCH only. Two slots rather than a whole set: it rides on
--- top of the idle set the stance already chose, so DPS, Tanking and Hoxne
--- each keep their own mitigation and only the body and hands change.
---
--- All three /SCH stances idle in sets.idle.MDT (set_builder IDLE_SET_BY_MODE),
--- and that set carries no priorities: out of combat an HP dip mid-swap costs
--- nothing, which is why it was never ranked. So neither piece is ranked here.
--- Misc.RegalGauntlets is deliberately not reused - its priority 7 belongs to
--- the fast-cast sets, and would make the hands equip first here for no reason.
--- Regen+34 between the seven, plus Refresh+1 from the hands.
--- The two Chirich are the same item in both ring slots, so they come from
--- common/rings.lua where each is pinned to its own wardrobe - GearSwap
--- cannot tell two copies apart otherwise and would equip one twice.
--- Infused takes the right ear, the one sets.idle.MDT fills with Eabani:
--- both are evasion earrings, so Regen+1 costs 5 evasion there, where the
--- left ear holds Tuisto and its ~150 HP.
sets.idleRegen = {
    body       = Misc.SacroBreastplate,  -- Regen+13, HP+182
    hands      = 'Regal Gauntlets',      -- Regen+10, HP+205, Refresh+1
    neck       = 'Bathy Choker +1',      -- Regen+3, HP+35
    right_ear  = 'Infused Earring',      -- Regen+1, Evasion+10
    waist      = 'Null Belt',            -- Regen+3
    left_ring  = Rings.Chirich1,         -- Regen+2
    right_ring = Rings.Chirich2          -- Regen+2
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Engaged Set
-- Local for the same reason IdleBase is: the stances below hang off
-- sets.engaged, and deriving from it would hand each of them the ones
-- declared before it.
local EngagedBase =
    set_combine(
    sets.idleNormal,
    {
        ammo = {name = 'Staunch Tathlum +1', priority = 0}, -- DT -3%, Status resistance +11, SIRD -11%
        head = Chev.head, -- HP+145, DT -11%, Converts 8% phys to MP
        body = Misc.Adamantite, -- HP+182, DT -20%, Very high DEF
        hands = Misc.ChevHandsEng, -- HP+64, DT -11%, Shield block bonus
        legs = Misc.ChevLegsEng, -- HP+127, DT -13%, Enmity+14
        feet = Misc.ChevFeetEng, -- HP+52, completes set bonus
        neck = {name = 'Kgt. Beads +2', priority = 7}, -- HP+60, DT -7%, Enmity+10
        waist = {name = 'Null Belt', priority = 0}, -- MDB, no HP gain
        left_ear = {name = 'Odnowa Earring +1', priority = 9}, -- HP+110, DT -3%, MDT -2%
        right_ear = {name = 'Chev. Earring +1', priority = 0}, -- DT -4%, Cure potency +11%
        left_ring = {name = 'Fortified Ring', priority = 5}, -- MDT -5%, reduces enemy crit rate
        right_ring = {name = 'Gelatinous Ring +1', priority = 11}, -- HP+100, PDT -7%, VIT+15
        back = Rudianos.tank -- PDT -10%, VIT+20, Enmity+10
    }
)

sets.engaged = set_combine(EngagedBase, {})

-- • PDT Engaged
sets.engaged.PDT =
    set_combine(
    EngagedBase,
    {
        sub = 'Duban' -- PDT shield for engaged
    }
)

-- • MDT Engaged (HybridMode 'MDT', and the 'Tanking' stance under /SCH)
-- The idle mitigation set doubles as the engaged one: holding hate does not
-- ask for different gear, only for the shield it already carries.
sets.engaged.MDT = sets.idle.MDT -- Already has Aegis shield

-- • Sortie (HybridMode 'Sortie', subjobs other than /SCH)
-- Mitigation body/head/legs kept, accessories traded for Store TP: the mode is
-- meant to hold hate while still feeding weaponskills.
-- The sub below is only a default. SetBuilder overrides it from the weapon in
-- Sortie (Burtgang > Aegis, Naegling > Blurred Shield +1), so it stands for
-- the case where the weapon names no shield of its own.
sets.engaged.TP =
    set_combine(
    EngagedBase,
    {
        sub = 'Blurred Shield +1',
        ammo = 'Coiste Bodhar',
        head = 'Hjarrandi Helm',
        body = Misc.HjarrandiBreast,
        hands = Sakpata.hands_plain,
        legs = Sakpata.legs_plain_b,
        feet = "Sakpata's Leggings",
        neck = 'Null Loop',
        waist = 'Sailfi Belt +1',
        left_ear = 'Dedition Earring',
        right_ear = 'Cessance Earring',
        left_ring = Moonlight1,
        right_ring = Moonlight2,
        back = Rudianos.STP
    }
)

-- • DPS (HybridMode 'DPS', /SCH only)
-- The damage stance: full Sakpata's for the damage taken floor, every
-- accessory traded for Store TP. Tanking is what holds hate; this one is
-- what spends the TP.
--
-- Priorities rank the slots by the HP each piece carries, highest first, so
-- that swapping into this set raises the HP pool before it touches the slots
-- that add none. 770 HP across eight pieces; the other five carry none.
--
-- No sub slot on purpose: the stance names its shield (Duban), applied by
-- SetBuilder alongside the weapon.
sets.engaged.DPS =
    set_combine(
    EngagedBase,
    {
        body = prio(Sakpata.body, 16), -- HP+136, biggest gain, equip FIRST
        legs = prio(Sakpata.legs, 15), -- HP+114
        left_ring = prio(Moonlight1, 14), -- HP+110
        right_ring = prio(Moonlight2, 13), -- HP+110
        head = prio(Sakpata.head, 12), -- HP+91
        hands = prio(Sakpata.hands, 11), -- HP+91
        feet = prio(Sakpata.feet, 10), -- HP+68
        neck = {name = 'Null Loop', priority = 9}, -- HP+50
        ammo = 'Coiste Bodhar', -- HP+0
        waist = 'Sailfi Belt +1', -- HP+0
        left_ear = 'Crep. Earring', -- HP+0
        right_ear = 'Dedition Earring', -- HP+0
        back = Rudianos.STP -- HP+0, priority 0
    }
)

-- • Hoxne (HybridMode 'Hoxne', /SCH only)
-- The Ampulla stance: Double Attack comes from the ammo's charge, so the
-- build spends its slots on Store TP and haste instead of chasing DA.
--
-- Priorities rank the slots by the HP each piece carries, highest first, so
-- that swapping into this set raises the HP pool before it touches the slots
-- that add none. A tank that equips its empty slots first spends the swap at
-- a lower maximum HP than either end of it intends.
--
-- No sub slot on purpose: the stance names its shield (Duban), applied by
-- SetBuilder alongside the weapon, which also holds the ammo on the Ampulla.
sets.engaged.Hoxne =
    set_combine(
    EngagedBase,
    {
        ammo = 'Hoxne Ampulla', -- HP+0, DA+100% on charge
        body = prio(Misc.HjarrandiBreast, 16), -- HP+228, biggest gain, equip FIRST
        head = prio(Chev.head, 15), -- HP+145
        left_ring = prio(Moonlight1, 14), -- HP+110
        right_ring = prio(Moonlight2, 13), -- HP+110
        legs = {name = 'Flamma Dirs +2', priority = 12}, -- HP+100
        hands = prio(Sakpata.hands, 11), -- HP+91
        feet = {name = 'Flam. Gambieras +2', priority = 10}, -- HP+40
        neck = 'Lissome Necklace', -- HP+0
        waist = 'Sailfi Belt +1', -- HP+0
        left_ear = 'Dedition Earring', -- HP+0
        right_ear = 'Telos Earring', -- HP+0
        back = Rudianos.STP -- HP+0, priority 0
    }
)

-- • Kraken Club Specialized (PLD/DNC multi-attack build)
-- Used when BurtgangKC weapon set is active
-- Focuses on Store TP reduction to leverage Kraken Club's multi-attack proc rate
sets.engaged.BurtgangKC =
    set_combine(
    EngagedBase,
    {
        ammo = 'Aurgelmir Orb +1',
        head = Misc.SuleviasMask,
        body = Misc.HjarrandiBreast,
        hands = Sakpata.hands_plain,
        legs = 'Chev. Cuisses +3',
        feet = 'Chev. Sabatons +3',
        neck = 'Null Loop',
        waist = 'Null Belt',
        left_ear = 'Crep. Earring',
        right_ear = 'Dedition Earring',
        left_ring = Rings.Chirich1,
        right_ring = Rings.Chirich2,
        back = Rudianos.STP
    }
)

-- • Melee XP
sets.meleeXp =
    set_combine(
    sets.idleXp,
    {
        main = {
            name = 'Malevolence',
            augments = {
                'INT+10',
                'Mag. Acc.+10',
                '"Mag.Atk.Bns."+8',
                '"Fast Cast"+5'
            }
        }
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}

-- • Full Enmity Set (Base for all enmity JAs)
sets.FullEnmity = {
    ammo = {name = 'Iron Gobbet', priority = 8}, -- delta FC=0
    head = Loess.plain, -- delta FC=+67
    neck = {name = 'Moonlight Necklace', priority = 7}, -- delta FC=0
    left_ear = {name = 'Trux Earring', priority = 10}, -- delta FC=+40
    right_ear = {name = 'Odnowa Earring +1', priority = 12}, -- delta FC=+110
    body = Souveran.cuirass, -- delta FC=-93 (biggest LOSS)
    hands = Souveran.handsch, -- delta FC=+214 (biggest GAIN)
    left_ring = {name = 'Apeile Ring +1', priority = 6}, -- delta FC=0
    right_ring = {name = 'Apeile Ring', priority = 5}, -- delta FC=0
    back = Rudianos.tank, -- delta FC=-80, priority via def (3)
    waist = {name = 'Creed Baudrier', priority = 9}, -- delta FC=+40
    legs = Caballarius.breeches, -- delta FC=-82
    feet = Misc.ChevFeetFC -- delta FC=0
    -- Gear Enmity 155
    -- Crusade Enmity 185
}

-- • Sortie Enmity (HybridMode 'Sortie' - the JAs and spells that wore FullEnmity)
-- FullEnmity plus the shield: in Sortie the sub is part of the enmity build.
-- No main slot on purpose: a main hand change zeroes TP, and Sortie is a mode
-- that builds it. Only the shield moves.
sets.EnmityMax = set_combine(sets.FullEnmity, {sub = 'Srivatsa'})

-- • Job Abilities
sets.precast.JA = set_combine(sets.FullEnmity, {})
sets.precast.JA['Divine Emblem'] =
    set_combine(
    sets.FullEnmity,
    {
        feet = Misc.ChevFeetBare
    }
)
sets.precast.JA['Palisade'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Cover'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Provoke'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Majesty'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Chivalry'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Vallation'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Valiance'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Pflug'] = set_combine(sets.FullEnmity, {})
sets.precast.JA['Fealty'] = set_combine(sets.FullEnmity, {body = Caballarius.surcoat})
sets.precast.JA['Invincible'] =
    set_combine(
    sets.FullEnmity,
    {
        legs = {name = 'Caballarius Breeches +4'}
    }
)
sets.precast.JA['Holy Circle'] = set_combine(sets.FullEnmity, {feet = Reverence.feet})
sets.precast.JA['Shield Bash'] = set_combine(sets.FullEnmity, {hands = Caballarius.gauntlets})
sets.precast.JA['Sentinel'] = set_combine(sets.FullEnmity, {feet = Caballarius.leggings})
sets.precast.JA['Rampart'] = set_combine(sets.FullEnmity, {head = Caballarius.coronet})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.FC = {
    ammo = 'Impatiens', -- delta idle=0
    head = Misc.CarmineMask, -- delta idle=-107 LOSS
    neck = {name = "Orunmila's Torque", priority = 5}, -- delta idle=-60
    left_ear = {name = "Enchanter's Earring +1", priority = 1},
    -- delta idle=-150 (biggest LOSS)
    right_ear = {name = 'Loquac. Earring', priority = 2}, -- delta idle=-110
    body = Odyssean.chestplate_fc,
    hands = Misc.LeylineGloves, -- delta idle=-39
    left_ring = {name = 'Kishar Ring', priority = 7}, -- delta idle=0
    right_ring = {name = 'Prolix Ring', priority = 4}, -- delta idle=-100
    back = Rudianos.FCSIRD, -- delta idle=+80 GAIN, priority via def (12)
    waist = {name = 'Platinum Moogle Belt', priority = 8}, -- delta idle=0
    legs = Misc.SworneBrais, -- delta idle=+37 GAIN
    feet = Misc.ChevFeetPlain -- delta idle=0
}

-- • Cure Self FC (Cure III/IV self-target only - low HP to avoid overcure waste)
sets.precast.FC.CureSelf =
    set_combine(
    sets.precast.FC,
    {
        body = Odyssean.chestplate_fc,
        legs = Misc.EnifCosciales -- gap idle=87 vs Chev. Cuisses HP+127
    }
)

sets.precast.FC['Healing Magic'] = sets.precast.FC
sets.precast.FC['Enhancing Magic'] = sets.precast.FC
sets.precast.FC['Phalanx'] = sets.precast.FC
sets.precast.FC['Crusade'] = sets.precast.FC
sets.precast.FC['Cocoon'] = sets.precast.FC
sets.precast.FC['Flash'] = sets.precast.FC
sets.precast.FC['Banish'] = sets.precast.FC
sets.precast.FC['Banishga'] = sets.precast.FC
sets.precast.FC['Blank Gaze'] = sets.precast.FC
sets.precast.FC['Jettatura'] = sets.precast.FC
sets.precast.FC['Sheep Song'] = sets.precast.FC
sets.precast.FC['Geist Wall'] = sets.precast.FC
sets.precast.FC['Cold Wave'] = sets.precast.FC
sets.precast.FC['Stinking Gas'] = sets.precast.FC
sets.precast.FC['Frightful Roar'] = sets.precast.FC
sets.precast.FC['Metallic Body'] = sets.precast.FC
sets.precast.FC['Foil'] = sets.precast.FC

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- Physical Weaponskills
-- ───────────────────────────────────────────────────────────────────────────

-- • Base Weaponskill Set
-- Held in a local for the same reason IdleBase and EngagedBase are: every
-- named weaponskill below attaches itself as a key on sets.precast.WS, and
-- set_combine copies every key of its source. Deriving from sets.precast.WS
-- would hand each weaponskill the ones declared before it as slots that are
-- not slots - Aeolian Edge carried Knights of Round, which carried Savage
-- Blade, which carried its own TPBonus.
local WSBase = {
    ammo = 'Crepuscular Pebble',
    head = Sakpata.head_plain,
    body = Sakpata.body_plain,
    hands = Sakpata.hands_plain,
    legs = Sakpata.legs_plain_b,
    feet = Misc.SuleviasLeggings,
    neck = "Knight's Bead Necklace +2",
    waist = {name = 'Sailfi Belt +1', priority = 3},
    left_ear = 'Ishvara Earring',
    right_ear = 'Thrud Earring',
    left_ring = "Cornelia's Ring",
    right_ring = 'Sroda Ring',
    back = Rudianos.WS
}

-- • Requiescat
sets.precast.WS = set_combine(WSBase, {})

sets.precast.WS['Requiescat'] = set_combine(WSBase, {})

-- • Chant du Cygne
sets.precast.WS['Chant du Cygne'] = set_combine(WSBase, {})

-- • Atonement (Enmity WS)
sets.precast.WS['Atonement'] = sets.FullEnmity

-- • Savage Blade
sets.precast.WS['Savage Blade'] =
    set_combine(
    WSBase,
    {
        ammo = {name = "Oshasha's Treatise"},
        head = Nyame.head,
        body = Nyame.body,
        hands = Nyame.hands,
        legs = Nyame.legs,
        feet = Nyame.feet,
        neck = {name = "Knight's Bead Necklace +2"},
        waist = {name = 'Sailfi Belt +1'},
        left_ear = {name = 'Tuisto Earring'},
        right_ear = {name = 'Thrud Earring'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Regal Ring'},
        back = Rudianos.WS
    }
)
sets.precast.WS['Knights of Round'] =
    set_combine(
    WSBase,
    {
        ammo = {name = "Oshasha's Treatise"},
        head = Nyame.head,
        body = Nyame.body,
        hands = Nyame.hands,
        legs = Nyame.legs,
        feet = Nyame.feet,
        neck = {name = "Knight's Bead Necklace +2"},
        waist = {name = 'Sailfi Belt +1'},
        left_ear = {name = 'Tuisto Earring'},
        right_ear = {name = 'Thrud Earring'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Regal Ring'},
        back = Rudianos.WS
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- Magic Weaponskills
-- ───────────────────────────────────────────────────────────────────────────

-- • Sanguine Blade (Dark Magic WS)
sets.precast.WS['Sanguine Blade'] =
    set_combine(
    WSBase,
    {
        head = Nyame.head,
        body = Nyame.body,
        hands = Nyame.hands,
        legs = Nyame.legs,
        feet = Nyame.feet,
        neck = {name = 'Sanctity Necklace'},
        waist = {name = "Orpheus's Sash"},
        left_ear = {name = 'Friomisi Earring'},
        right_ring = {name = 'Regal Ring'},
        back = {name = 'Toro Cape'}
    }
)

-- • Aeolian Edge (Wind Magic WS)
sets.precast.WS['Aeolian Edge'] =
    set_combine(
    WSBase,
    {
        ammo = {name = "Oshasha's Treatise"},
        head = Nyame.head,
        body = Nyame.body,
        hands = Nyame.hands,
        legs = Nyame.legs,
        feet = Nyame.feet,
        neck = {name = 'Baetyl Pendant'},
        waist = {name = "Orpheus's Sash"},
        left_ear = {name = 'Crematio Earring'},
        right_ear = {name = 'Friomisi Earring'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Murky Ring'},
        back = {name = 'Moonlight Cape'}
    }
)

-- • Circle Blade (Magic WS)
sets.precast.WS['Circle Blade'] =
    set_combine(
    WSBase,
    {
        ammo = {name = 'Staunch Tathlum +1'},
        head = Nyame.head,
        body = Nyame.body,
        hands = Nyame.hands,
        legs = Nyame.legs,
        feet = Nyame.feet,
        neck = {name = 'Sibyl Scarf'},
        waist = {name = "Orpheus's Sash"},
        left_ear = {name = 'Sortiarius Earring'},
        right_ear = {name = 'Chev. Earring +1'},
        left_ring = {name = "Cornelia's Ring"},
        right_ring = {name = 'Regal Ring'},
        back = {name = 'Toro Cape'}
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- TP Bonus Adjustments
-- ───────────────────────────────────────────────────────────────────────────

-- • TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    left_ear = 'Moonshade Earring' -- TP Bonus +250
}

-- • TPBonus Variants
sets.precast.WS['Savage Blade'].TPBonus = set_combine(sets.precast.WS['Savage Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Sanguine Blade'].TPBonus = set_combine(sets.precast.WS['Sanguine Blade'], sets.precast.WS.TPBonus)
sets.precast.WS['Aeolian Edge'].TPBonus = set_combine(sets.precast.WS['Aeolian Edge'], sets.precast.WS.TPBonus)
sets.precast.WS['Circle Blade'].TPBonus = set_combine(sets.precast.WS['Circle Blade'], sets.precast.WS.TPBonus)

-- ───────────────────────────────────────────────────────────────────────────
-- Weaponskills specific to the /SCH setup
-- ───────────────────────────────────────────────────────────────────────────
-- PLD/SCH is played for Sortie alone, where the weaponskill is fed by the
-- DPS and Hoxne stances rather than the tanking build, so it trades the
-- survivability accessories for damage. The armor is the same Nyame set;
-- only what is listed below differs.
-- Equipped over the standard set by PLD_PRECAST, under /SCH only.
-- Safe to attach here: the weaponskills above derive from WSBase, not from
-- sets.precast.WS, so a sub-table on the latter reaches none of them.
sets.precast.WS.SCH = {}

sets.precast.WS.SCH['Knights of Round'] =
    set_combine(
    sets.precast.WS['Knights of Round'],
    {
        ammo = 'Crepuscular Pebble',
        neck = 'Fotia Gorget',
        left_ear = 'Hoxne Earring',
        left_ring = 'Sroda Ring',
        right_ring = "Ephramad's Ring"
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- Enmity Sets
-- ───────────────────────────────────────────────────────────────────────────

sets.midcast = {}

-- • Enmity Midcast
sets.midcast.Enmity = sets.FullEnmity

-- • SIRD + Enmity Midcast (Spell Interruption Rate Down)
sets.midcast.SIRDEnmity = {
    ammo = {name = 'Staunch Tathlum +1', priority = 8}, -- delta FC=0
    head = Loess.path_a, -- delta FC=+67
    body = Misc.ChevBodySird, -- delta FC=-113 (biggest LOSS, equip LAST)
    hands = Souveran.handsch_cure, -- delta FC=+214 (biggest GAIN, equip FIRST)
    legs = Caballarius.breeches, -- delta FC=-82
    feet = Odyssean.greaves_sird, -- delta FC=-32
    neck = {name = 'Moonlight Necklace', priority = 7}, -- delta FC=0
    waist = {name = 'Audumbla Sash', priority = 6}, -- delta FC=0
    left_ear = {name = 'Alabaster Earring', priority = 11}, -- delta FC=+100
    right_ear = {name = 'Odnowa Earring +1', priority = 12}, -- delta FC=+110
    left_ring = {name = 'Apeile Ring +1', priority = 5}, -- delta FC=0
    right_ring = {name = 'Gelatinous Ring +1', priority = 10},
    -- delta FC=+100
    back = Rudianos.EnmitySIRD -- delta FC=-80, priority via def (3)
}
-- Gear Enmity 123
-- Crusade Enmity 153
-- SIRD 106%

-- ───────────────────────────────────────────────────────────────────────────
-- Phalanx Sets
-- ───────────────────────────────────────────────────────────────────────────

-- • Phalanx Potency Set
sets.midcast.PhalanxPotency = {
    --[[ main = {name = "Sakpata's Sword"},
    sub = 'Priwen', ]]
    ammo = {name = 'Aurgelmir Orb +1', priority = 9}, -- delta FC=0
    head = Odyssean.helm_phalanx, -- delta FC=-38
    neck = {name = 'Melic Torque', priority = 8}, -- delta FC=0
    left_ear = {name = 'Mimir Earring', priority = 11}, -- delta FC=+150
    right_ear = {name = "Chevalier's Earring +1", priority = 6}, -- delta FC=0
    body = Odyssean.chestplate_phalanx, -- delta FC=-264 (biggest LOSS, equip LAST)
    hands = Souveran.handsch, -- delta FC=+214 (biggest GAIN, equip FIRST)
    left_ring = {name = 'Murky Ring', priority = 5}, -- delta FC=0
    right_ring = {name = 'Gelatinous Ring +1', priority = 10}, -- delta FC=+100
    back = Weard.plain, -- delta FC=-80
    waist = {name = 'Flume Belt +1', priority = 7}, -- delta FC=0
    legs = Sakpata.legs_plain, -- delta FC=-50
    feet = Souveran.schuhs -- delta FC=+175 GAIN
}

-- • SIRD Phalanx
sets.midcast.SIRDPhalanx = {
    --[[ main = {name = "Sakpata's Sword"},
    sub = 'Priwen', ]]
    ammo = {name = 'Staunch Tathlum +1'},
    head = Misc.SouvSchallerPlain,
    body = Misc.ChevBodySirdPlain,
    hands = {name = 'Souv. Handsch. +1'},
    legs = Sakpata.legs_plain_b,
    feet = Odyssean.greaves_phalanx,
    neck = {name = 'Moonlight Necklace'},
    waist = {name = 'Audumbla Sash'},
    left_ear = {name = 'Mimir Earring'},
    right_ear = {name = 'Tuisto Earring'},
    left_ring = {name = 'Gelatinous Ring +1'},
    right_ring = Rings.Stikini1,
    back = Weard.phalanx
}

-- ───────────────────────────────────────────────────────────────────────────
-- Enhancing Magic
-- ───────────────────────────────────────────────────────────────────────────

-- • Enlight
sets.midcast['Enlight'] =
    set_combine(
    sets.midcast.SIRDEnmity,
    {
        head = Jumalik.head, -- Refresh 1
        body = Reverence.surcoat,
        hands = Misc.EschiteGauntlets,
        waist = {name = 'Asklepian Belt'},
        back = Misc.MoonlightCapeEnlight,
        left_ear = {name = "Knight's Earring"}
    }
)

-- • Enhancing Magic
sets.midcast['Enhancing Magic'] =
    set_combine(
    sets.midcast.SIRDEnmity,
    {
        body = Misc.ShabtiCuirass
    }
)

-- • Stoneskin Magic
-- Deltas are HP against precast.FC, the set this one replaces. feet keeps the
-- idle priority: Chev. Sabatons +3 sits in both sets, so that slot never moves.
-- Gains go on first and the heaviest loss last, so the swap never dips below
-- the HP either set holds. Keep the ranks in step with the deltas beside them:
-- the hands carried priority 1 against a +180 gain, the largest of the set,
-- and so went on last alongside the largest loss.
sets.midcast['Stoneskin'] =
    set_combine(
    IdleBase,
    {
        head = {name = 'Chev. Armet +3', priority = 12}, -- delta FC=+107
        body = {name = 'Adamantite Armor', priority = 11}, -- delta FC=+102
        hands = {name = 'Stone Mufflers', priority = 13}, -- delta FC=+180 (biggest GAIN, equip FIRST)
        left_ear = {name = 'Alabaster Earring', priority = 10}, -- delta FC=+100
        right_ring = {name = 'Gelatinous Ring +1', priority = 9}, -- delta FC=+100
        ammo = {name = 'Impatiens', priority = 8}, -- delta FC=0
        neck = {name = 'Stone Gorget', priority = 7}, -- delta FC=0
        waist = {name = 'Siegel Sash', priority = 6}, -- delta FC=0
        right_ear = {name = 'Earthcry Earring', priority = 5}, -- delta FC=0
        left_ring = {name = 'Murky Ring', priority = 4}, -- delta FC=0
        back = Rudianos.tank, -- delta FC=-80, priority via def (3)
        legs = {name = 'Haven Hose', priority = 1}
    } -- delta FC=-164 (biggest LOSS, equip LAST)
)
-- ───────────────────────────────────────────────────────────────────────────
-- Healing Magic (Cure Sets)
-- ───────────────────────────────────────────────────────────────────────────

-- • Cure Base Set
sets.Cure = {
    ammo = {name = 'Staunch Tathlum +1', priority = 1},
    head = Souveran.head,
    left_ear = {name = 'Tuisto Earring', priority = 10},
    right_ear = Misc.ChevEarringPlus, -- MUST be right_ear
    hands = Misc.RegalGauntlets,
    back = Misc.MoonlightCapeBase,
    legs = Misc.FoundersHose,
    feet = Odyssean.greaves_cure
}

-- • Cure Self (PDT/Survivability focused)
-- Entered from sets.precast.FC.CureSelf, which is deliberately low on HP so a
-- self cure does not overheal (PLD_PRECAST equips it over Mote's FC set). The
-- midcast then puts the HP back on, and the priorities rank the slots by how
-- much each one gains against that precast - the file's usual "delta FC".
--
-- Only the slots that differ from sets.Cure are listed; ammo, head and hands
-- are inherited from it unchanged. The left ear is the same piece but outranks
-- what it holds there, so it is re-ranked rather than retyped.
sets.midcast.CureSelf =
    set_combine(
    sets.Cure,
    {
        neck = {name = 'Unmoving Collar +1', priority = 14}, -- +200 vs Orunmila's Torque, biggest gain
        back = Misc.MoonlightCapeCure, -- +195, priority 13
        left_ear = prio(sets.Cure.left_ear, 12), -- +150: Tuisto converts 150 MP to HP,
        -- the precast's Enchanter's Earring +1 gives none
        right_ring = {name = 'Gelatinous Ring +1', priority = 11}, -- +110 vs Prolix Ring
        feet = Odyssean.greaves_sird, -- priority 4
        body = Souveran.cuirass_cure, -- priority 2
        legs = Misc.FoundersHoseCure, -- priority 1
        waist = {name = 'Platinum Moogle Belt'}, -- HP+10%, same piece as the precast: no swap
        right_ear = 'Trux Earring', -- delta 0
        left_ring = 'Apeile Ring +1' -- delta 0
    }
)

-- • Cure Other (Cure Potency focused)
sets.midcast.CureOther =
    set_combine(
    sets.Cure,
    {
        head = {name = 'Souv. Schaller +1', priority = 12}, -- delta FC=+40
        body = Souveran.cuirass_cure, -- delta FC=-93
        left_ear = {name = 'Tuisto Earring', priority = 13}, -- delta FC=+150 (biggest GAIN)
        hands = Misc.ChevHandsCure, -- delta FC=+39
        legs = Misc.FoundersHoseCure, -- delta FC=-142 (biggest LOSS)
        neck = {name = 'Sacro Gorget', priority = 9}, -- delta FC=0
        feet = {name = 'Odyssean Greaves', priority = 4}, -- delta FC=-32
        waist = {name = 'Audumbla Sash', priority = 8}, -- delta FC=0
        ammo = {name = 'Staunch Tathlum +1', priority = 10}, -- delta FC=0
        right_ear = {name = 'Chev. Earring +1', priority = 7}, -- MUST be right_ear, delta FC=0
        right_ring = {name = 'Apeile Ring +1', priority = 5}, -- delta FC=0
        left_ring = {name = 'Apeile Ring +1', priority = 6}, -- delta FC=0
        back = Rudianos.cure -- delta FC=-80, priority via def (3)
    }
)

-- ───────────────────────────────────────────────────────────────────────────
-- Blue Magic (Subjob spells)
-- ───────────────────────────────────────────────────────────────────────────

-- • Blue Magic Spells
sets.midcast['Cocoon'] = sets.midcast.SIRDEnmity
sets.midcast['Jettatura'] = sets.FullEnmity
sets.midcast['Geist Wall'] = sets.midcast.SIRDEnmity
sets.midcast['Sheep Song'] = sets.midcast.SIRDEnmity
sets.midcast['Frightful Roar'] = sets.midcast.SIRDEnmity
sets.midcast['Cold Wave'] = sets.midcast.SIRDEnmity
sets.midcast['Stinking Gas'] = sets.midcast.SIRDEnmity
sets.midcast['Blank Gaze'] = sets.midcast.SIRDEnmity

-- ───────────────────────────────────────────────────────────────────────────
-- PLD Specific Spells (Divine & Enhancing)
-- ───────────────────────────────────────────────────────────────────────────

-- • Divine Magic
sets.midcast['Flash'] = sets.FullEnmity
sets.midcast['Banishga'] = sets.midcast.SIRDEnmity

-- • PLD Enhancing Magic
sets.midcast['Phalanx'] = sets.midcast.PhalanxPotency
sets.midcast['Crusade'] = sets.FullEnmity
sets.midcast['Reprisal'] = sets.midcast['Enhancing Magic']
sets.midcast['Protect'] = sets.midcast['Enhancing Magic']
sets.midcast['Shell'] = sets.midcast['Enhancing Magic']
sets.midcast['Refresh'] = sets.midcast.SIRDEnmity
sets.midcast['Haste'] = sets.midcast.SIRDEnmity

-- ───────────────────────────────────────────────────────────────────────────
-- RUN Subjob Spells
-- ───────────────────────────────────────────────────────────────────────────

-- • RUN Enhancing Magic
sets.midcast['Foil'] = sets.midcast.SIRDEnmity

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Base Movement Speed
sets.MoveSpeed = {
    legs = Misc.CarmineCuisses -- Common item for speed
}

-- • Town Idle (Movement speed)
sets.idle.Town = set_combine(sets.idle.PDT, sets.MoveSpeed)

-- • Adoulin Movement (City-specific speed boost)
sets.Adoulin =
    set_combine(
    sets.MoveSpeed,
    {
        body = Misc.CouncilorsGarb -- Speed bonus in Adoulin city
    }
)

-- ═══════════════════════════════════════════════════════════════════════════
-- BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.buff = {}
sets.buff.Doom = {
    neck = {name = "Nicander's Necklace"}, -- Reduces Doom effects
    left_ring = {name = 'Purity Ring'}, -- Additional Doom resistance
    waist = {name = 'Gishdubar Sash'} -- Enhances Doom recovery effects
}

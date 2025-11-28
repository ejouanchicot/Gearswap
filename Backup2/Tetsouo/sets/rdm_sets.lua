---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Equipment Sets - Ultimate Red Mage Spellblade Configuration
---  ═══════════════════════════════════════════════════════════════════════════
---   Complete equipment configuration for Red Mage hybrid DPS/support role with
---   optimized enfeebling, enhancing, and melee capabilities.
---   Features:
---     • Enfeebling Magic mastery (Vitiation +4, Lethargy +3, Magic Accuracy)
---     • Enhancing Magic duration (Telchine, Atrophy Gloves +4, Ghostfyre cape)
---     • Elemental Magic nuking (Bunzi's Rod, Lethargy full set, Magic Burst)
---     • Cure support (Daybreak main, Revealer's Mitts, Cure Potency)
---     • Melee DPS capability (Malignance hybrid, Store TP, Enspell bonus)
---     • Fast Cast optimization (Merlinic set, Sucellos cape FC+10)
---     • Movement speed optimization (Carmine Cuisses +1)
---   Architecture:
---     • Equipment definitions (Chirich rings, wardrobe management)
---     • Precast sets (Fast Cast, Job Abilities, Weaponskills)
---     • Midcast sets (Elemental, Enfeebling, Enhancing, Cure, Dark Magic)
---     • Navigation tables (self/others path helpers for MidcastManager)
---     • Idle sets (DT, Refresh, Town)
---     • Engaged sets (DT, Enspell, Refresh, TP, Acc, Dual Wield)
---     • Weapon sets (Naegling, Daybreak, Colada, Malevolence, Shields)
---     • Movement sets (Base speed, Adoulin)
---   @file    jobs/rdm/sets/rdm_sets.lua
---   @author  Tetsouo
---   @version 3.1 - Standardized Organization
---   @date    Updated: 2025-11-10
---  ═════════════════════════════════════════════════════════════════════════

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- EQUIPMENT DEFINITIONS
-- ═══════════════════════════════════════════════════════════════════════════

local ChirichRing1 = {name = 'Chirich Ring +1', bag = 'wardrobe 1'}
local ChirichRing2 = {name = 'Chirich Ring +1', bag = 'wardrobe 2'}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Main Weapons (cycle via state.MainWeapon)
sets['Naegling'] = {main = 'Naegling'}
sets['Daybreak'] = {main = 'Daybreak'}
sets['Colada'] = {main = 'Colada'}

-- • Sub Weapons (cycle via state.SubWeapon)
sets['Ammurapi'] = {sub = 'Ammurapi Shield'}
sets['Genmei'] = {sub = 'Genmei Shield'}
sets['Malevolence'] = {sub = 'Malevolence'}

-- • Shield Configuration List
sets.shields = {
    'Ammurapi',            -- Short name
    'Ammurapi Shield',     -- Full name (FFXI uses both formats!)
    'Genmei',              -- Short name
    'Genmei Shield',       -- Full name
    'Blurred Shield +1',
    'Blurred Shield',
    'Aegis',
    'Ochain',
    'Srivatsa'
}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.idle = {}

-- • DT Idle (Physical Damage Taken -, cap 50%)
sets.idle.DT = {
    ammo = 'Staunch Tathlum +1',
    head = 'Viti. Chapeau +4',
    body = 'Malignance Tabard',
    hands = 'Leth. Ganth. +3',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Elite Royal Collar',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Malignance Earring',
    right_ear = {
        name = 'Leth. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Dbl.Atk."+4'}
    },
    left_ring = 'Woltaris Ring',
    right_ring = "Gurebu's Ring",
    back = {
        name = "Sucellos's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- • Refresh Idle (maximize Refresh+)
sets.idle.Refresh = set_combine(sets.idle.DT, {
    head = 'Viti. Chapeau +4',
    body = 'Lethargy Sayon +3',
    legs = 'Leth. Fuseau +3',
    left_ring = 'Woltaris Ring',
    right_ring = "Gurebu's Ring"
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}

-- • DT Engaged (defensive melee - Physical Damage Taken -)
sets.engaged.DT = {
    ammo = 'Regal Gem',
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots',
    neck = 'Anu Torque',
    waist = 'Sailfi Belt +1',
    left_ear = 'Sherida Earring',
    right_ear = 'Dedition Earring',
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = {
        name = "Sucellos's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- • Enspell Engaged (enspell bonus)
sets.engaged.Enspell = set_combine(sets.engaged.DT, {
    head = 'Umuthi Hat',
    hands = 'Ayanmo Manopolas +2',
    back = 'Ghostfyre Cape'
})

-- • Refresh Engaged (MP refresh while engaged - add Refresh+ gear if needed)
sets.engaged.Refresh = set_combine(sets.engaged.DT, {})

-- • TP Engaged (maximize Store TP, TP gain - add extra Store TP gear if needed)
sets.engaged.TP = set_combine(sets.engaged.DT, {})

-- • Acc Engaged (accuracy focus - add Accuracy+ gear for high evasion mobs)
sets.engaged.Acc = set_combine(sets.engaged.DT, {})

-- ───────────────────────────────────────────────────────────────────────────
-- Dual Wield Variants (2 weapons equipped)
-- ───────────────────────────────────────────────────────────────────────────

-- • DT Dual Wield (defensive melee with dual wield gear)
sets.engaged.DT.DW = set_combine(sets.engaged.DT, {
    -- left_ear = 'Suppanomimi',    -- DW+5
    -- right_ear = 'Eabani Earring' -- DW+4
})

-- • Enspell Dual Wield (enspell bonus with dual wield)
sets.engaged.Enspell.DW = set_combine(sets.engaged.Enspell, {
    head = "Nyame Helm",
    -- left_ear = 'Suppanomimi',
    -- right_ear = 'Eabani Earring'
})

-- • Refresh Dual Wield (MP refresh while dual wielding - add Refresh+ gear if needed)
sets.engaged.Refresh.DW = set_combine(sets.engaged.DT.DW, {})

-- • TP Dual Wield (TP gain with dual wield - maximize Store TP)
sets.engaged.TP.DW = set_combine(sets.engaged.DT.DW, {})

-- • Acc Dual Wield (accuracy focus with dual wield - add Accuracy+ for high evasion)
sets.engaged.Acc.DW = set_combine(sets.engaged.DT.DW, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- • Precast table initialization (REQUIRED - do not remove)
sets.precast = {}
sets.precast.JA = {}  -- Job Abilities sub-table

-- • Fast Cast (generic - maximize Fast Cast % for all spells)
-- Target: 80% Fast Cast cap (RDM gets 30% from job traits = need 50% from gear)
sets.precast.FC = {
    ammo = 'Regal Gem',
    head = {name = 'Merlinic Hood', augments = {'Mag. Acc.+1', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+1'}},
    body = {name = 'Viti. Tabard +3', augments = {'Enhances "Chainspell" effect'}},
    hands = 'Leth. Ganth. +3',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = 'Dls. Torque +2',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Loquac. Earring',
    right_ear = 'Leth. Earring +1',
    left_ring = "Gurebu's Ring",
    right_ring = 'Defending Ring',
    back = {
        name = "Sucellos's Cape",
        augments = {'MP+60', 'Mag. Acc+20 /Mag. Dmg.+20', 'Mag. Acc.+10', '"Fast Cast"+10'}
    }
}

-- • Stoneskin Fast Cast (Stoneskin Casting Time-, add if casting Stoneskin often)
sets.precast.FC["Stoneskin"] = set_combine(sets.precast.FC, {
    head = "Umuthi Hat",       -- Stoneskin Casting Time-
    waist = "Siegel Sash",     -- Stoneskin Casting Time-
    legs = "Nyame Flanchard"   -- Defensive
})

-- ───────────────────────────────────────────────────────────────────────────
-- Job Abilities
-- ───────────────────────────────────────────────────────────────────────────

-- • Chainspell (2-hour ability - instant cast magic for 1 minute)
-- Vitiation Tabard +3 enhances Chainspell effect (doubles duration to 2 minutes)
sets.precast.JA['Chainspell'] = {
    body = 'Vitiation Tabard +4'  -- Extends Chainspell duration 100% (1min >> 2min)
}

-- • Convert (swaps HP and MP values - useful for emergency MP recovery)
-- Murgleis (Mythic) reduces Convert recast time (10min >> 5min)
sets.precast.JA['Convert'] = {
    -- main = "Murgleis",  -- Uncomment if you have Murgleis (Mythic RDM sword)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- ───────────────────────────────────────────────────────────────────────────
-- Elemental Magic (Nuking)
-- ───────────────────────────────────────────────────────────────────────────
sets.midcast = {}

sets.midcast['Elemental Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Sibyl Scarf',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Metamor. Ring +1',
    right_ring = 'Freke Ring',
    back = "Aurist's Cape +1"
}

-- • Elemental Magic - Nuke Mode Sets (selected via NukeMode state)
-- FreeNuke mode (standard nuking - no Magic Burst timing required)
sets.midcast['Elemental Magic'].FreeNuke = set_combine(sets.midcast['Elemental Magic'], {})

-- Magic Burst mode (Magic Burst Window - add Magic Burst Damage+ gear here)
sets.midcast['Elemental Magic']['Magic Burst'] = set_combine(sets.midcast['Elemental Magic'], {})

-- ───────────────────────────────────────────────────────────────────────────
-- Healing Magic (Cures)
-- ───────────────────────────────────────────────────────────────────────────

sets.midcast['Healing Magic'] = {
    main = 'Daybreak',
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Viti. Chapeau +4',
    body = 'Viti. Tabard +3',
    hands = "Revealer's Mitts",
    legs = 'Atrophy Tights +4',
    feet = 'Leth. Houseaux +3',
    neck = 'Dls. Torque +2',
    waist = 'Plat. Mog. Belt',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = "Naji's Loop",
    right_ring = "Gurebu's Ring",
    back = "Aurist's Cape +1"
}

-- • Cure (single target healing - Cure Potency+, Cure Cast Time-)
sets.midcast.Cure = set_combine(sets.midcast['Healing Magic'], {})

-- • Curaga (AoE healing - inherits from Cure)
sets.midcast.Curaga = set_combine(sets.midcast['Healing Magic'], {})

-- Cure Self (self-target cure - can add defensive gear here)
sets.midcast.CureSelf = set_combine(sets.midcast['Healing Magic'], {})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ ENFEEBLING MAGIC (DEBUFFS)                                                   │
--╰──────────────────────────────────────────────────────────────────────────────╯

sets.midcast['Enfeebling Magic'] = {
    main = "Bunzi's Rod",
    sub = 'Ammurapi Shield',
    range = 'Ullr',
    head = 'Viti. Chapeau +4',
    body = 'Lethargy Sayon +3',
    hands = 'Leth. Ganth. +3',
    legs = 'Chironic hose',
    feet = 'Vitiation Boots +4',
    neck = 'Dls. Torque +2',
    waist = 'Acuity Belt +1',
    left_ear = 'Malignance Earring',
    right_ear = 'Regal Earring',
    left_ring = 'Kishar Ring',
    right_ring = 'Metamor. Ring +1',
    back = "Aurist's Cape +1"
}

-- Enfeebling Type Sets (Auto-selected based on spell from RDM_SPELL_DATABASE)
-- Magic Accuracy focus (Dia, Paralyze, Slow, etc.)
sets.midcast['Enfeebling Magic'].macc = set_combine(sets.midcast['Enfeebling Magic'], {})

-- MND Potency (Slow II, Paralyze II - scale with MND)
sets.midcast['Enfeebling Magic'].mnd_potency = set_combine(sets.midcast['Enfeebling Magic'], {})

-- INT Potency (Poison II, Burn, etc. - scale with INT)
sets.midcast['Enfeebling Magic'].int_potency = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Enfeebling Skill Potency (Frazzle, Distract - scale with Enfeebling Skill)
sets.midcast['Enfeebling Magic'].skill_potency = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Enfeebling Skill + MND Potency (Addle - hybrid scaling)
sets.midcast['Enfeebling Magic'].skill_mnd_potency = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Generic Potency (mixed potency enfeebles)
sets.midcast['Enfeebling Magic'].potency = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Duration focus (maximize duration - composure, relic, etc.)
sets.midcast['Enfeebling Magic'].duration = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Enfeebling Mode Sets (selected via EnfeebleMode state)
-- Potency mode (maximize enfeeble potency over landing rate)
sets.midcast['Enfeebling Magic'].Potency = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Mixed mode (balance between potency and magic accuracy)
sets.midcast['Enfeebling Magic'].Mixed = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Accuracy mode (maximize magic accuracy for resistant targets)
sets.midcast['Enfeebling Magic'].Acc = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Enfeebling with Saboteur active (2x duration - can swap to potency gear)
sets.midcast['Enfeebling Magic'].Saboteur = set_combine(sets.midcast['Enfeebling Magic'], {
    hands = "Leth. Ganth. +3",
})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ ENHANCING MAGIC (BUFFS)                                                      │
--╰──────────────────────────────────────────────────────────────────────────────╯

sets.midcast['Enhancing Magic'] = {
    main = 'Colada',
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = {name = 'Telchine Cap', augments = {'"Conserve MP"+5', 'Enh. Mag. eff. dur. +10'}},
    body = {name = 'Viti. Tabard +3', augments = {'Enhances "Chainspell" effect'}},
    hands = 'Atrophy Gloves +4',
    legs = {name = 'Telchine Braconi', augments = {'"Conserve MP"+5', 'Enh. Mag. eff. dur. +10'}},
    feet = 'Leth. Houseaux +3',
    neck = 'Dls. Torque +2',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = {
        name = 'Leth. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Dbl.Atk."+4'}
    },
    left_ring = "Gurebu's Ring",
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = 'Ghostfyre Cape'}

-- Enhancing with Composure (on others - duration bonus)
sets.midcast['Enhancing Magic'].Composure = {
    main = {name = 'Colada', augments = {'Enh. Mag. eff. dur. +4', 'STR+6', 'Mag. Acc.+11', 'DMG:+6'}},
    sub = 'Ammurapi Shield',
    ammo = 'Regal Gem',
    head = 'Leth. Chappel +3',
    body = 'Lethargy Sayon +3',
    hands = 'Atrophy Gloves +4',
    legs = 'Leth. Fuseau +3',
    feet = 'Leth. Houseaux +3',
    neck = 'Dls. Torque +2',
    waist = 'Embla Sash',
    left_ear = 'Regal Earring',
    right_ear = 'Leth. Earring +1',
    left_ring = "Gurebu's Ring",
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = 'Ghostfyre Cape'
}

-- Refresh (base - potency)
sets.midcast.Refresh = {
    body = 'Atrophy Tabard +4',
    legs = 'Leth. Fuseau +3'
}

-- Refresh with Composure (on others - Empyrean bonus)
sets.midcast.Refresh.Composure = set_combine(sets.midcast['Enhancing Magic'].Composure, {
    body = 'Atrophy Tabard +4',
    legs = 'Leth. Fuseau +3'
})

-- Regen (base - HP regen potency)
sets.midcast.Regen = {
    main = 'Bolelabunga',
    body = {name = 'Telchine Chas.', augments = {'"Conserve MP"+5', '"Regen" potency+3'}}
}

-- Regen with Composure (on others - duration + potency)
sets.midcast.Regen.Composure = set_combine(sets.midcast['Enhancing Magic'].Composure, {
    main = 'Bolelabunga',
    body = {name = 'Telchine Chas.', augments = {'"Conserve MP"+5', '"Regen" potency+3'}}
})

-- Phalanx (base - Damage Taken -)
sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {})

-- Phalanx with Composure (on others - duration)
sets.midcast.Phalanx.Composure = set_combine(sets.midcast['Enhancing Magic'].Composure, {})

-- Stoneskin
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
    left_ear = 'Earthcry Earring',
    neck = 'Nodens Gorget',
    waist = 'Siegel Sash'
})

-- Spell Family Sets (Root-level sets for MidcastManager v2.0 PRIORITY 6)
-- These sets use spell_family from ENHANCING_MAGIC_DATABASE
sets.midcast.Enspell = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.Gain = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.BarElement = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.BarAilment = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.Spikes = set_combine(sets.midcast['Enhancing Magic'], {})
sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'], {})
-- Note: Phalanx already defined above (line 419) as PRIORITY 1 spell name set

-- Spell Name Sets (Root-level sets for MidcastManager v2.0 PRIORITY 1)
-- These sets use base spell name matching (no spell_family in database)
sets.midcast.Temper = set_combine(sets.midcast['Enhancing Magic'], {})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ DARK MAGIC                                                                   │
--╰──────────────────────────────────────────────────────────────────────────────╯

-- Generic Dark Magic (Magic Accuracy focus, uses Elemental Magic base)
sets.midcast['Dark Magic'] = set_combine(sets.midcast['Elemental Magic'], {})

-- Impact (AoE Magic Defense Down - uses full Elemental Magic set)
-- Note: Must wear Twilight Cloak in body slot for Impact
sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {})

-- Stun (interrupt spell - fast cast + magic accuracy, add if needed)
sets.midcast.Stun = set_combine(sets.midcast['Elemental Magic'], {})

-- Drain (HP absorption - Dark Magic Skill+, add Aspir/Drain+ gear if available)
sets.midcast.Drain = set_combine(sets.midcast['Elemental Magic'], {})

-- Aspir (MP absorption - Dark Magic Skill+, add Aspir/Drain+ gear if available)
sets.midcast.Aspir = set_combine(sets.midcast['Elemental Magic'], {})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ WEAPONSKILL SETS                                                             │
--╰──────────────────────────────────────────────────────────────────────────────╯

-- Generic Weaponskill (Nyame R25 Path B focus - WSD+, Attack+, Accuracy+)
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = {name = 'Nyame Helm', augments = {'Path: B'}},
    body = {name = 'Nyame Mail', augments = {'Path: B'}},
    hands = {name = 'Nyame Gauntlets', augments = {'Path: B'}},
    legs = {name = 'Nyame Flanchard', augments = {'Path: B'}},
    feet = 'Leth. Houseaux +3',
    neck = 'Rep. Plat. Medal',
    waist = {name = 'Sailfi Belt +1', augments = {'Path: A'}},
    left_ear = {name = 'Moonshade Earring', augments = {'Mag. Acc.+4', 'TP Bonus +250'}},
    right_ear = {
        name = 'Leth. Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', '"Dbl.Atk."+4'}
    },
    left_ring = ChirichRing1,
    right_ring = ChirichRing2,
    back = {
        name = "Sucellos's Cape",
        augments = {'DEX+20', 'Accuracy+20 Attack+20', 'Accuracy+10', '"Store TP"+10', 'Phys. dmg. taken-10%'}
    }
}

-- Savage Blade (Physical WS - 50% STR / 50% MND, 4-hit, Light SC)
-- Main WS for Naegling - high damage single target
sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {})

-- Sanguine Blade (Magical WS - 50% MND / 50% STR, Dark damage, Distortion/Fragmentation SC)
-- Used with Daybreak for magical damage option
sets.precast.WS['Sanguine Blade'] = set_combine(sets.midcast['Elemental Magic'], {})

-- Seraph Blade (Magical WS - 40% STR / 40% MND, Light damage, Fusion/Reverberation SC)
-- Alternative magical WS option
sets.precast.WS['Seraph Blade'] = set_combine(sets.midcast['Elemental Magic'], {})

-- Chant du Cygne (Physical WS - 80% DEX, 5-hit crit-focused, Distortion/Fusion SC)
-- Alternative physical WS for Colada/Tauret
sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {})

-- Requiescat (Physical WS - 73% MND, 5-hit light SC, Gravitation SC)
-- MND-based physical option
sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ MOVEMENT SETS                                                                │
--╰──────────────────────────────────────────────────────────────────────────────╯

sets.MoveSpeed = {
    legs = 'Carmine Cuisses +1'
}

-- Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {
    body = "Councilor's Garb" -- Speed bonus in Adoulin city
})

-- Town Idle
sets.idle.Town = set_combine(sets.idle.DT, sets.MoveSpeed, {
    body = "Councilor's Garb" -- Speed bonus in Adoulin city
})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ BUFF SETS                                                                    │
--╰──────────────────────────────────────────────────────────────────────────────╯
sets.buff = {}

-- Doom (Deadly status - gradually reduces HP to 0, can wipe)
-- Priority: Equip Nicander's Necklace immediately when Doom detected
-- Nicander's has 100% Doom removal rate (10/10 procs)
sets.buff.Doom = {
    -- neck = "Nicander's Necklace",  -- Removes Doom (10/10 procs) - PRIORITY ITEM
    ring1 = "Purity Ring",         -- Doom resistance (reduces application chance)
    ring2 = "Blenmot's Ring +1",   -- Doom resistance (reduces application chance)
    waist = "Gishdubar Sash"       -- Doom resistance (reduces application chance)
}

---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Equipment Sets - Complete Gear Configuration (SKELETON)
---  ═══════════════════════════════════════════════════════════════════════════
---   All sets declared with empty 16-slot skeletons. Fill slot-by-slot.
---
---   Set categories:
---     • Master idle / engaged
---     • Precast (Fast Cast generic + per-skill FC)
---     • Midcast magic (Summoning, Cure, Enhancing, Stoneskin, Phalanx, Refresh, Haste)
---     • Pet midcast (Blood Pact Rage Physical/Magical/Hybrid/AstralFlow + Ward Buff/Debuff/Heal)
---     • Job Abilities (Astral Flow, Astral Conduit, Apogee, Elemental Siphon, Mana Cede,
---                      Avatar's Favor, Release)
---     • Pet engaged (avatar auto-attack)
---
---   @file    Tetsouo/sets/smn/smn_sets.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

---@diagnostic disable: lowercase-global

-- ═══════════════════════════════════════════════════════════════════════════
-- EMPTY SLOT TEMPLATE
-- Every set below uses this skeleton. Fill in slots as you gear up.
-- ═══════════════════════════════════════════════════════════════════════════

local function empty_set()
    return {
        main = "", sub = "", range = "", ammo = "",
        head = "", neck = "", left_ear = "", right_ear = "",
        body = "", hands = "", left_ring = "", right_ring = "",
        back = "", waist = "", legs = "", feet = ""
    }
end

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SET (referenced by other sets)
-- ═══════════════════════════════════════════════════════════════════════════

sets.weapons = {
    main = "Grioavolr",
    sub  = ""
}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.idle = {}
sets.idle.Normal = empty_set()
sets.idle.DT     = empty_set()
sets.idle.Avatar = empty_set()   -- Avatar's Favor active

sets.idle.Town = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED (master melee - rarely used)
-- ═══════════════════════════════════════════════════════════════════════════

sets.engaged = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- RESTING
-- ═══════════════════════════════════════════════════════════════════════════

sets.resting = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST - FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}

-- Generic Fast Cast (base)
sets.precast.FC = {
    main  = { name = "Grioavolr",          augments = { '"Fast Cast"+6', '"Mag.Atk.Bns."+6' } },
    sub   = "Alber Strap",
    ammo  = "Ghastly Tathlum +1",
    head  = { name = "Merlinic Hood",      augments = { 'Attack+14', '"Fast Cast"+7', 'MND+3' } },
    body  = { name = "Merlinic Jubbah",    augments = { 'Mag. Acc.+24', '"Fast Cast"+7', 'CHR+2', '"Mag.Atk.Bns."+3' } },
    hands = { name = "Merlinic Dastanas",  augments = { '"Fast Cast"+7', 'Mag. Acc.+5', '"Mag.Atk.Bns."+4' } },
    legs  = { name = "Merlinic Shalwar",   augments = { '"Mag.Atk.Bns."+5', '"Fast Cast"+5', 'Mag. Acc.+11' } },
    feet  = { name = "Merlinic Crackows",  augments = { '"Mag.Atk.Bns."+1', '"Fast Cast"+7', 'STR+9', 'Mag. Acc.+10' } },
    neck      = "Orunmila's Torque",
    waist     = "Witful Belt",
    left_ear  = "Loquac. Earring",
    right_ear = "Malignance Earring",
    left_ring = "Kishar Ring",
    right_ring = "Jubilee Ring",
    back  = "Perimede Cape",
}

-- Skill-specific FC overlays inherit from the base
sets.precast.FC['Summoning Magic'] = set_combine(sets.precast.FC, {})
sets.precast.FC['Healing Magic']   = set_combine(sets.precast.FC, {})
sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {})

-- Weaponskill (master rarely WS but slot exists)
sets.precast.WS = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST - JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.JA = {}
sets.precast.JA['Astral Flow']     = empty_set()
sets.precast.JA['Astral Conduit']  = empty_set()
sets.precast.JA['Apogee']          = empty_set()
sets.precast.JA['Elemental Siphon'] = empty_set()
sets.precast.JA['Mana Cede']       = empty_set()
sets.precast.JA["Avatar's Favor"]  = empty_set()
sets.precast.JA['Release']         = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST - MASTER MAGIC
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- Summoning Magic (avatar summon - reduces Pact Delay)
sets.midcast['Summoning Magic'] = empty_set()

-- Elemental Siphon (separate from generic Summoning Magic)
sets.midcast['Elemental Siphon'] = empty_set()

-- Subjob healing/enhancing
sets.midcast.Cure              = empty_set()
sets.midcast.Curaga            = empty_set()
sets.midcast['Healing Magic']  = empty_set()
sets.midcast['Enhancing Magic'] = empty_set()
sets.midcast.Stoneskin         = empty_set()
sets.midcast.Phalanx           = empty_set()
sets.midcast.Refresh           = empty_set()
sets.midcast.Haste             = empty_set()
sets.midcast['Divine Magic']   = empty_set()
sets.midcast['Dark Magic']     = empty_set()
sets.midcast['Elemental Magic'] = empty_set()
sets.midcast['Enfeebling Magic'] = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- PET MIDCAST - BLOOD PACTS
-- Routed by shared/jobs/smn/functions/logic/blood_pact_classifier.lua
-- ═══════════════════════════════════════════════════════════════════════════

sets.pet_midcast = {}

-- Blood Pact: Rage
sets.pet_midcast.BPRage = {}
sets.pet_midcast.BPRage.Physical   = empty_set()
sets.pet_midcast.BPRage.Magical    = empty_set()
sets.pet_midcast.BPRage.Hybrid     = empty_set()
sets.pet_midcast.BPRage.AstralFlow = empty_set()

-- Blood Pact: Ward
sets.pet_midcast.BPWard = {}
sets.pet_midcast.BPWard.Buff   = empty_set()
sets.pet_midcast.BPWard.Debuff = empty_set()
sets.pet_midcast.BPWard.Heal   = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- PET ENGAGED (avatar auto-attack)
-- ═══════════════════════════════════════════════════════════════════════════

sets.pet = {}
sets.pet.Engaged = empty_set()

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT
-- ═══════════════════════════════════════════════════════════════════════════

sets.MoveSpeed = empty_set()

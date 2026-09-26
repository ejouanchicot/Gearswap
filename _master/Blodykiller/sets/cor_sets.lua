---============================================================================
--- COR Equipment Sets - Blodykiller
---============================================================================
--- Blody's COR gear (from his Blodykiller_COR.lua) under the set names our
--- COR code reads. His gear tables (AF, RELIC, EMPY, CORCape, HERC, CARM,
--- MEGH) come from sets/0_AugGear_Blodykiller.lua, under his own names.
---
--- How our COR picks these sets (docs/dev/jobs/cor.md):
---   * Idle: sets.idle[IdleMode], then sets[MainWeapon] (its sub only on
---     /NIN or /DNC) and sets[RangeWeapon], then sets.idle.PDT when
---     HybridMode is PDT, sets.idle.Refresh under 50% MP, sets.MoveSpeed.
---   * Engaged: sets.engaged[OffenseMode], sets.engaged.PDT on top when
---     HybridMode is PDT, then the weapon sets.
---   * Phantom Roll: sets.precast.CorsairRoll, then its sub-set by roll name;
---     Double-Up wears the set of the roll it doubles; Luzaf's Ring goes on
---     left_ring by itself (LuzafRing state).
---   * Quick Draw: sets.precast.CorsairShot, then its sub-set by shot name
---     (a Job Ability: the gear is sent before it goes off, not in midcast).
---   * /ra: sets.precast.RA, then sets.midcast.RA.
---
--- His bullets (gear.RAbullet / WSbullet / QDbullet...) were all
--- "Chrono Bullet"; they are written out below.
---
--- @file    sets/cor_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

include('sets/0_AugGear_Blodykiller.lua')

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- Main weapons: their sub goes on only on /NIN or /DNC. His SubSet state
-- was separate (Nusku Shield, Gleti's Knife, Qutrub Knife); our COR has no
-- sub weapon state, so the off-hand dagger is his first knife, Gleti's Knife.
sets['Naegling']    = {main = "Naegling",   sub = "Gleti's Knife"}
sets['Wind Knife']  = {main = "Wind Knife", sub = "Gleti's Knife"}

-- Guns: our COR equips sets[RangeWeapon] as is (no plain-weapon fallback
-- for the range slot), so each gun needs its set.
sets['Anarchy +2']  = {range = "Anarchy +2"}
sets['Fomalhaut']   = {range = "Fomalhaut"}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.idle = {}

-- His idle (Regain > DT > Meva). sub: his default SubSet / DefaultShield;
-- on /NIN or /DNC the weapon set's dagger replaces it.
sets.idle.Normal = {
    sub         =   "Nusku Shield",
    ammo        =   "Chrono Bullet",
    head        =   "Nyame Helm",           -- DT- 7%
    body        =   "Nyame Mail",
    hands       =   "Nyame Gauntlets",      -- DT- 7%
    legs        =   CARM.Legs.HQ.D,         -- Mov Speed
    feet        =   "Nyame Sollerets",      -- DT- 7%
    neck        =   "Rep. Plat. Medal",     -- Regain+ 2
    waist       =   "Null Belt",
    left_ear    =   "Alabaster Earring",
    right_ear   =   "Genmei Earring",
    left_ring   =   "Murky Ring",           -- DT-10%
    right_ring  =   "Warden's Ring",
    back        =   CORCape.TP,
}                                           -- Total: DT-46%

-- His IdleMode 'Regen'.
sets.idle.Regen = set_combine(sets.idle.Normal, {
    head        =   MEGH.Head,              -- Regen+ 2
    body        =   MEGH.Body,              -- Regen+ 2
    hands       =   MEGH.Hands,             -- Regen+ 2
    legs        =   MEGH.Legs,              -- Regen+ 2
    feet        =   MEGH.Feet,              -- Regen+ 2
    neck        =   "Bathy Choker +1",      -- Regen+ 3
    waist       =   "Null Belt",            -- Regen+ 3
    left_ear    =   "Infused Earring",      -- Regen+ 1
    left_ring   =   "Meghanada Ring",       -- Regen+ 2
})

-- No idle DT set in his file (sets.defense.PDT pointed at sets.idle.DT, never
-- defined): derived from his base idle, which is already his DT idle.
sets.idle.PDT = set_combine(sets.idle.Normal, {})

-- No refresh piece in his file. Empty on purpose: this set is laid on top
-- under 50% MP, so a copy of the idle would undo his Regen idle.
sets.idle.Refresh = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.engaged = {}

-- His OffenseMode 'Normal'. sub: see sets.idle.Normal.
sets.engaged.Normal = {
    sub         =   "Nusku Shield",
    ammo        =   "Chrono Bullet",
    head        =   "Malignance Chapeau",
    body        =   "Nyame Mail",
    hands       =   "Malignance Gloves",
    legs        =   "Samnuha Tights",
    feet        =   "Malignance Boots",
    neck        =   "Regal Necklace",
    waist       =   "Sailfi Belt +1",
    left_ear    =   "Cessance Earring",
    right_ear   =   "Crep. Earring",
    left_ring   =   "Epona's Ring",
    right_ring  =   "Petrov Ring",
    back        =   CORCape.TP,
}

-- His default OffenseMode.
sets.engaged['Subtle Blow'] = set_combine(sets.engaged.Normal, {
    head        =   "Malignance Chapeau",   -- DT- 6
    body        =   "Nyame Mail",           -- DT- 9
    hands       =   AF.Hands,               --          SB+10
    legs        =   EMPY.Legs,              -- DT-12
    feet        =   "Mummu Gamash. +2",     --          SB+ 9
    neck        =   "Clotharius Torque",    --          SB+ 4
    waist       =   "Sailfi Belt +1",
    left_ear    =   "Digni. Earring",       --          SB+ 5
    right_ear   =   "Crep. Earring",
    left_ring   =   "Murky Ring",           -- DT-10
    right_ring  =   "Rajas Ring",           --          SB+ 5
    back        =   CORCape.TP,
})                                          -- DT-47    SB+33

-- His sets.engaged.DT (his HybridMode only had 'Normal', so he never reached
-- it). Pieces only: our HybridMode PDT lays this on top of the offense set.
sets.engaged.PDT = {
    head        =   "Malignance Chapeau",   -- DT- 6
    body        =   "Malignance Tabard",    -- DT- 9
    hands       =   "Malignance Gloves",    -- DT- 5
    legs        =   "Malignance Tights",    -- DT- 7
    feet        =   "Nyame Sollerets",      -- DT- 7
    waist       =   "Reiki Yotai",          --          STP+ 4  DW+ 7
    right_ear   =   "Suppanomimi",          --                  DW+ 5
}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: JOB ABILITIES
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

sets.precast.JA['Snake Eye']    = {legs = RELIC.Legs}
sets.precast.JA['Wild Card']    = {feet = RELIC.Feet}
sets.precast.JA['Random Deal']  = {body = RELIC.Body}
-- His FoldDoubleBust: he wore it only with two Busts up; here on every Fold.
sets.precast.JA['Fold']         = {hands = RELIC.Hands}

-- • Phantom Roll (duration / DT)
-- His back was CORCape.RA, never defined for him: it equipped nothing.
-- right_ring: Luzaf's Ring goes on left_ring by itself (LuzafRing state).
sets.precast.CorsairRoll = {
    head        =   RELIC.Head,             -- Duration +50
    body        =   "Malignance Tabard",    --              DT- 9
    hands       =   EMPY.Hands,             -- Duration +50
    legs        =   "Nyame Flanchard",
    feet        =   "Nyame Sollerets",
    neck        =   "Regal Necklace",       -- Duration +20
    waist       =   "Null Belt",
    left_ear    =   "Alabaster Earring",    --              DT- 5
    right_ear   =   "Genmei Earring",
    left_ring   =   "Murky Ring",           --              DT-10
    right_ring  =   "Warden's Ring",
}

-- LuzafRing ON (16 yalms): Luzaf's Ring on the right ring, over Warden's Ring;
-- OFF keeps Warden's Ring (his BindManager-era sets.precast.LuzafRing)
sets.precast.LuzafRing = {right_ring = "Luzaf's Ring"}

sets.precast.CorsairRoll["Caster's Roll"]    = set_combine(sets.precast.CorsairRoll, {legs = EMPY.Legs})
sets.precast.CorsairRoll["Courser's Roll"]   = set_combine(sets.precast.CorsairRoll, {feet = EMPY.Feet})
sets.precast.CorsairRoll["Blitzer's Roll"]   = set_combine(sets.precast.CorsairRoll, {head = EMPY.Head})
sets.precast.CorsairRoll["Tactician's Roll"] = set_combine(sets.precast.CorsairRoll, {body = EMPY.Body})
sets.precast.CorsairRoll["Allies' Roll"]     = set_combine(sets.precast.CorsairRoll, {hands = EMPY.Hands})

-- • Quick Draw (his sets.midcast.CorsairShot: our COR reads it in precast)
sets.precast.CorsairShot = {
    ammo        =   "Chrono Bullet",
    head        =   AF.Head,
    body        =   RELIC.Body,
    hands       =   "Carmine Fin. Ga. +1",
    feet        =   EMPY.Feet,
    neck        =   "Baetyl Pendant",
    left_ear    =   "Gwati Earring",
    right_ear   =   "Friomisi Earring",
    left_ring   =   "Dingir Ring",
    waist       =   "Eschan Stone",
}

-- Light / Dark Shot: accuracy, not damage.
sets.precast.CorsairShot['Light Shot'] = {
    ammo        =   "Chrono Bullet",
    head        =   AF.Head,
    body        =   "Malignance Tabard",
    hands       =   AF.Hands,
    feet        =   AF.Feet,
    left_ring   =   "Regal Ring",
}
sets.precast.CorsairShot['Dark Shot'] = sets.precast.CorsairShot['Light Shot']

-- • Waltz
sets.precast.Waltz = {body = "Passion Jacket"}

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: FAST CAST
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.FC = {
    head        =   HERC.Head.FC,           -- FC+12%
    hands       =   "Leyline Gloves",       -- FC+ 7%
    feet        =   HERC.Feet.FC,           -- FC+ 5%
    left_ring   =   "Kishar Ring",          -- FC+ 4%
    right_ring  =   "Naji's Loop",          -- FC+ 1%
}

sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {body = "Passion Jacket"})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: RANGED ATTACK
-- ═══════════════════════════════════════════════════════════════════════════

-- Snapshot +59 (cap 60, +10 from JP). His back was CORCape.PreRA, never
-- defined for him: it equipped nothing.
sets.precast.RA = {
    ammo        =   "Chrono Bullet",
    head        =   "Taeon Chapeau",        -- Snapshot+10
    body        =   "Pursuer's Doublet",    -- Snapshot+ 6
    hands       =   CARM.Hands.HQ.D,        -- Snapshot+ 8  Rapid Shot+11
    legs        =   "Adhemar Kecks +1",     -- Snapshot+ 9  Rapid Shot+10
    feet        =   MEGH.Feet,              -- Snapshot+10
    waist       =   "Impulse Belt",         -- Snapshot+ 3
    left_ring   =   "Crepuscular Ring",     -- Snapshot+ 3
}

-- Under Flurry / Flurry II (his sets, read through classes.CustomRangedGroups:
-- shared/utils/precast/flurry_tracker.lua)
sets.precast.RA.Flurry1 = set_combine(sets.precast.RA, {
    body        =   AF.Body,
})                                          -- Snapshot+46
sets.precast.RA.Flurry2 = set_combine(sets.precast.RA.Flurry1, {
    head        =   EMPY.Head,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST: WEAPONSKILLS
-- ═══════════════════════════════════════════════════════════════════════════

-- back: his file wore CORCape.WS, the cape table itself (no item name), next
-- to "--WSD+10"; his only WSD cape is CORCape.WS.STR, used here.
-- Moonshade on right_ear: COR_TP_CONFIG lists it on ear2 to match.
sets.precast.WS = {
    ammo        =   "Chrono Bullet",
    head        =   "Nyame Helm",           -- WSD+ 6
    body        =   "Nyame Mail",           -- WSD+ 8
    hands       =   "Nyame Gauntlets",      -- WSD+ 8
    legs        =   "Nyame Flanchard",      -- WSD+ 9
    feet        =   "Nyame Sollerets",      -- WSD+ 6
    neck        =   "Fotia Gorget",
    waist       =   "Fotia Belt",
    left_ear    =   "Ishvara Earring",      -- WSD+ 2
    right_ear   =   "Moonshade Earring",
    left_ring   =   "Regal Ring",
    right_ring  =   "Epaminondas's Ring",   -- WSD+ 5
    back        =   CORCape.WS.STR,         -- WSD+10
}

sets.precast.WS['Savage Blade']  = set_combine(sets.precast.WS, {})
sets.precast.WS['Evisceration']  = set_combine(sets.precast.WS, {})

-- back: same CORCape.WS line as the base set.
sets.precast.WS['Last Stand'] = set_combine(sets.precast.WS, {
    head        =   "Alhazen Hat +1",
    body        =   "Nyame Mail",
    hands       =   "Malignance Gloves",
    legs        =   "Malignance Tights",
    feet        =   "Malignance Boots",
    neck        =   "Sanctity Necklace",
    waist       =   "Null Belt",
    left_ear    =   "Alabaster Earring",
    right_ear   =   "Crep. Earring",
    left_ring   =   "Murky Ring",
    right_ring  =   "Crepuscular Ring",
})

-- His back was CORCape.WS.AGI, never defined for him: the base set's cape stays.
sets.precast.WS['Leaden Salute'] = set_combine(sets.precast.WS, {
    head        =   "Pixie Hairpin +1",
    body        =   RELIC.Body,
    legs        =   "Nyame Flanchard",
    feet        =   RELIC.Feet,
    waist       =   "Orpheus's Sash",
    left_ear    =   "Friomisi Earring",
    left_ring   =   "Dingir Ring",
    right_ring  =   "Archon Ring",
})
sets.precast.WS['Wildfire'] = sets.precast.WS['Leaden Salute']
sets.precast.WS['Hot Shot'] = sets.precast.WS['Leaden Salute']

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- His SpellInterrupt set.
local SpellInterrupt = {
    legs        =   "Carmine Cuisses +1",   -- SIRD 20
    ring1       =   "Evanescence Ring",     -- SIRD  5
}

sets.midcast.Utsusemi = SpellInterrupt
-- His HERC.*.Phalanx pieces were never defined for him: SIRD pieces only.
sets.midcast.Phalanx = set_combine(SpellInterrupt, {})

sets.midcast.Cure = {
    neck        =   "Incanter's Torque",
    ear1        =   "Roundel Earring",
    ear2        =   "Mendi. Earring",
    waist       =   "Bishop's Sash",
}

-- • Ranged Attack
sets.midcast.RA = {
    ammo        =   "Chrono Bullet",
    head        =   "Nyame Helm",
    body        =   "Nyame Mail",
    hands       =   "Malignance Gloves",
    legs        =   "Malignance Tights",
    feet        =   "Malignance Boots",
    neck        =   "Sanctity Necklace",
    waist       =   "Eschan Stone",
    left_ear    =   "Alabaster Earring",
    right_ear   =   "Crepuscular Earring",
    left_ring   =   "Murky Ring",
    right_ring  =   "Crepuscular Ring",
    back        =   CORCape.TP,
}

-- RangedMode variants (his sets; his old RangedMode only had 'Normal', so
-- they were never used before). ring1 / ring2 of his file written as
-- left_ring / right_ring for readability only (set_combine already maps
-- ring1 / ring2 onto left_ring / right_ring).
sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
    ammo        =   "Chrono Bullet",        -- his gear.RAccbullet
    body        =   "Malignance Tabard",
    left_ear    =   "Volley Earring",
    left_ring   =   "Cacoethic Ring +1",
    right_ring  =   "Longshot Ring",
})
sets.midcast.RA.HighAcc = set_combine(sets.midcast.RA.Acc, {
    legs        =   AF.Legs,
    left_ring   =   "Regal Ring",
})
sets.midcast.RA.Critical = set_combine(sets.midcast.RA, {
    head        =   MEGH.Head,
    legs        =   "Mummu Kecks +2",       -- his MUMM.Legs (0_AugGear_Blodykiller.lua line 62)
    left_ring   =   "Begrudging Ring",
    right_ring  =   "Mummu Ring",
})
sets.midcast.RA.STP = set_combine(sets.midcast.RA, {})
-- Under Triple Shot, on top of the set above: empty in his file ("--27")
sets.midcast.RA.TripleShot = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT & BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- His Kiting set.
sets.MoveSpeed = {legs = "Carmine Cuisses +1"}

sets.buff = {}
-- Empty in his file.
sets.buff.Doom = {}

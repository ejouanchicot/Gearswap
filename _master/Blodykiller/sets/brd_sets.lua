---============================================================================
--- BRD Equipment Sets - Blodykiller
---============================================================================
--- Blody's BRD gear (from his Blodykiller_BRD.lua) under the set names our
--- BRD code reads. His gear tables (AF, RELIC, EMPY, BRDCape, LINOS, ...) come
--- from sets/0_AugGear_Blodykiller.lua, under his own names.
---
--- How our BRD picks these sets (docs/dev/jobs/brd.md):
---   * Buff songs: Mote equips its default first, then MidcastManager's
---     Singing chain (exact name > tier-less name > family > first word)
---     REPLACES it, so every family set is a full set built on BardSong.
---     The range slot is then set from sets.midcast.Songs[MainInstrument],
---     except for Honor March / Aria of Passion (locked instruments).
---   * Dummy songs (BRD_SONG_CONFIG DUMMY_SONGS): sets.midcast.DummySong.
---   * Debuff songs: only Mote's default (name, then spell map), so each one
---     needs a full set with no main/sub.
---
--- @file    sets/brd_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

include('sets/0_AugGear_Blodykiller.lua')

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- Daybreak, Naegling, Carnwenhan and Fusetto +2 need no set
-- (equip_without_set). A shield is not a weapon in the game's item list,
-- so the resolver cannot equip Ammurapi Shield without this set.
sets['Ammurapi Shield'] = {sub = "Ammurapi Shield"}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- His default idle (IdleMode 'Normal'): refresh pieces.
-- range: his RangedSet state defaulted to Terpander, which his code kept on.
sets.idle = {
    range       =   "Terpander",
    head        =   EMPY.Head,          --DT-10%
    body        =   "Bunzi's Robe",     --DT-10%
    hands       =   { name="Chironic Gloves", augments={'"Cure" potency +4%','Rng.Atk.+15','"Refresh"+2',}},
    legs        =   CHIR.Legs.Refresh,  --          Refresh +2
    feet        =   EMPY.Feet,          --          18% Mov Speed
    neck        =   "Loricate Torque +1",--DT-6%
    waist       =   "Fucho-no-Obi",     --          Latent Refresh +
    back        =   BRDCape.Macc,       --DT- 5%
    left_ear    =   "Alabaster Earring",--DT- 5%
    right_ear   =   "Genmei Earring",   --PDT-2%
    left_ring   =   "Murky Ring",       --DT-10%
    right_ring  =   "Warden's Ring",    --PDT-3%
}

sets.idle.Refresh = set_combine(sets.idle, {})

sets.idle.DT = set_combine(sets.idle, {
    range       =   "Terpander",        --DT- 3%
    head        =   EMPY.Head,          --DT-10%
    body        =   "Bunzi's Robe",     --DT-10%
    hands       =   "Bunzi's Gloves",   --DT- 8%
    legs        =   EMPY.Legs,          --DT-12%
    feet        =   RELIC.Feet,         --Meva
    neck        =   "Loricate Torque +1",
    waist       =   "Kasiri Belt",      --Eva+13
    back        =   BRDCape.Macc,       --DT- 5%
    left_ear    =   "Etiolation Earring",
    right_ear   =   "Odnowa Earring +1",
    left_ring   =   "Stikini Ring +1",
    right_ring  =   "Stikini Ring +1",
})

-- No Regen idle in his file: derived from his base idle.
sets.idle.Regen = set_combine(sets.idle, {})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.engaged = {
    range       =   LINOS.TP,           --Acc+10 Atk+10
    head        =   AYAN.Head,
    body        =   AYAN.Body,
    hands       =   "Bunzi's Gloves",
    legs        =   RELIC.Legs,
    feet        =   RELIC.Feet,
    neck        =   "Bard's Charm +1",
    waist       =   "Anguinus Belt",
    left_ear    =   "Suppanomimi",
    right_ear   =   "Cessance Earring",
    left_ring   =   "Hetairoi Ring",
    right_ring  =   "Petrov Ring",
    back        =   BRDCape.TP,
}

-- EngagedMode STP / Acc / SB: no equivalent in his file, derived from his base engaged.
sets.engaged.STP = set_combine(sets.engaged, {})
sets.engaged.Acc = set_combine(sets.engaged, {})
sets.engaged.SB = set_combine(sets.engaged, {})

-- His HybridMode 'DT' engaged set.
sets.engaged.DT = set_combine(sets.engaged, {
    head        =   "Nyame Helm",
    body        =   "Nyame Mail",
    legs        =   "Nyame Flanchard",
    feet        =   "Nyame Sollerets",
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • FAST CAST (FC cap 80%)
sets.precast.FC = {
    head        =   "Telchine Cap",     --FC+ 5%
    body        =   INYA.Body,          --FC+14%
    hands       =   "Gende. Gages +1",  --FC+ 7%    SST- 5%
    legs        =   AYAN.Legs,          --FC+ 6%
    feet        =   EMPY.Feet,          --FC+10%
    waist       =   "Embla Sash",       --FC+ 5%
    left_ring   =   "Weatherspoon Ring",--FC+ 5%
    right_ring  =   "Kishar Ring",      --FC+ 4%
    back        =   BRDCape.Macc,       --FC+10%
}                                       --Total:FC+70%

sets.precast.FC.BardSong = set_combine(sets.precast.FC, {
    head        =   EMPY.Head,          --          SST-14%
    hands       =   "Gende. Gages +1",  --FC+ 7%    SST- 5%
    feet        =   "Telchine Pigaches",--FC+ 5%    SST- 6%
})

sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {waist = "Siegel Sash"})
sets.precast.FC.Stoneskin = set_combine(sets.precast.FC, {})
sets.precast.FC.Cure = set_combine(sets.precast.FC, {})

sets.precast.FC['Honor March'] = set_combine(sets.precast.FC.BardSong, {range = "Marsyas"})
-- Not in his file: our Aria of Passion locks Loughnashade (which he owns), derived like his Honor March.
sets.precast.FC['Aria of Passion'] = set_combine(sets.precast.FC.BardSong, {range = "Loughnashade"})

-- Read only by //gs c debugprecast (Mote reads sets.precast.FC.BardSong).
sets.precast.BardSong = sets.precast.FC.BardSong

-- • JOB ABILITIES
sets.precast.JA.Nightingale     = {feet = RELIC.Feet}
sets.precast.JA.Troubadour      = {body = RELIC.Body}
sets.precast.JA['Soul Voice']   = {legs = RELIC.Legs}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast.WS = {
    range       =   LINOS.WS,           --WSD+ 3% (his file had it in ammo, where Linos cannot go)
    head        =   "Nyame Helm",
    body        =   RELIC.Body,         --WSD+12%
    hands       =   "Nyame Gauntlets",
    legs        =   "Nyame Flanchard",
    feet        =   "Nyame Sollerets",
    neck        =   "Rep. Plat. Medal",
    waist       =   "Sailfi Belt +1",
    left_ear    =   "Moonshade Earring",
    right_ear   =   "Ishvara Earring",
    left_ring   =   "Cornelia's Ring",
    right_ring  =   "Epaminondas's Ring",
    back        =   BRDCape.WS.STR,
}

-- His file put RELIC.Head in the body slot here; that line is left out, so
-- the body stays the base WS body (RELIC.Body).
sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {
    head        =   "Nyame Helm",
    hands       =   "Bunzi's Gloves",
    legs        =   { name="Chironic Hose", augments={'Weapon skill damage +2%','Pet: "Dbl.Atk."+1 Pet: Crit.hit rate +1','Accuracy+1 Attack+1','Mag. Acc.+10 "Mag.Atk.Bns."+10',}},
    feet        =   "Brioso Slippers +3",
    neck        =   "Mizu. Kubikazari",
    waist       =   "Anguinus Belt",
    left_ear    =   "Friomisi Earring",
    right_ear   =   "Ishvara Earring",
    left_ring   =   "Apate Ring",
    right_ring  =   "Vertigo Ring",
    back        =   BRDCape.WS.STR,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS - BUFF SONGS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- • BASE SONG SET (his SongEffect: duration and AF3 set bonus)
sets.midcast.BardSong = {
    main        =   "Carnwenhan",           --Duration +50%
    sub         =   "Kali",                 --Duration + 5%
    range       =   "Gjallarhorn",          --All Songs +4
    head        =   EMPY.Head,
    body        =   EMPY.Body,              --Duration +12%
    hands       =   EMPY.Hands,
    legs        =   INYA.Legs,              --Duration +17%
    feet        =   AF.Feet,                --Duration +15%
    neck        =   "Mnbw. Whistle +1",     --All Songs +3
    waist       =   "Kobo Obi",
    back        =   BRDCape.Macc,
    right_ear   =   "Loquacious Earring",
    right_ring  =   "Prolix Ring",
    left_ring   =   "Etana Ring",
}

-- • Instruments. Range only: the chain lays the whole set on top of the song
--   set (Honor March / Aria of Passion) and MainInstrument takes only .range,
--   so any other slot here would undo the family piece.
sets.midcast.Songs = {}
sets.midcast.Songs.Gjallarhorn      = {range = "Gjallarhorn"}
sets.midcast.Songs.Daurdabla        = {range = "Daurdabla"}       -- his ExtraSongsMode 'FullLength'
sets.midcast.Songs.Marsyas          = {range = "Marsyas"}
sets.midcast.Songs.Loughnashade     = {range = "Loughnashade"}
sets.midcast.Songs['Miracle Cheer'] = {range = "Miracle Cheer"}   -- his MiracleCheer toggle

-- • Families (his overlays on SongEffect)
sets.midcast.Ballad     = set_combine(sets.midcast.BardSong, {range = "Blurred Harp +1"})
sets.midcast.Madrigal   = set_combine(sets.midcast.BardSong, {head = EMPY.Head, back = BRDCape.Macc})  --Madrigal +2
sets.midcast.Mambo      = set_combine(sets.midcast.BardSong, {feet = "Mousai Crackows"})              --Mambo +1
sets.midcast.March      = set_combine(sets.midcast.BardSong, {hands = EMPY.Hands})                    --March +1
sets.midcast.Minuet     = set_combine(sets.midcast.BardSong, {body = EMPY.Body})                      --Minuet +1
sets.midcast.Minne      = set_combine(sets.midcast.BardSong, {legs = "Mousai Seraweels"})             --Minne +1
sets.midcast.Paeon      = set_combine(sets.midcast.BardSong, {head = AF.Head})                        --Paeon +2
sets.midcast["Sentinel's Scherzo"] = set_combine(sets.midcast.BardSong, {feet = EMPY.Feet})           --Scherzo +1

-- • Locked instruments
sets.midcast.HonorMarch = set_combine(sets.midcast.March, {range = "Marsyas"})
-- Not in his file: derived from his base song set with the Loughnashade he owns.
sets.midcast['Aria of Passion'] = set_combine(sets.midcast.BardSong, {range = "Loughnashade"})

-- • Songs only affected by duration
sets.midcast["Goddess's Hymnus"] = set_combine(sets.midcast.BardSong, {range = "Miracle Cheer"})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS - DUMMY SONGS
-- ═══════════════════════════════════════════════════════════════════════════

-- His DaurdablaDummy: minimum duration so the fake is easy to overwrite.
sets.midcast.DummySong = {
    range       =   "Daurdabla",
    head        =   AYAN.Head,
    body        =   AYAN.Body,
    hands       =   AYAN.Hands,
    legs        =   AYAN.Legs,
    feet        =   AYAN.Feet,
    neck        =   "Loricate Torque +1",
    waist       =   "Embla Sash",
    left_ear    =   "Etiolation Earring",
    right_ear   =   "Loquac. Earring",
    left_ring   =   "Stikini Ring +1",
    right_ring  =   "Stikini Ring +1",
}

-- His dummy songs (dummy_map), by name so Mote's default never lays a family
-- set (with its main/sub) under the dummy set.
sets.midcast['Fowl Aubade']      = sets.midcast.DummySong
sets.midcast["Army's Paeon"]     = sets.midcast.DummySong
sets.midcast["Knight's Minne"]   = sets.midcast.DummySong
sets.midcast['Enchanting Etude'] = sets.midcast.DummySong
sets.midcast['Shining Fantasia'] = sets.midcast.DummySong

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS - DEBUFF SONGS (no main/sub: weapons are not swapped)
-- ═══════════════════════════════════════════════════════════════════════════

-- His SongDebuff (ResistantSongDebuff was identical).
-- His back slot was BRDCape.Mid, which he never defined: it equipped nothing.
sets.midcast.DebuffSong = {
    range       =   "Gjallarhorn",
    head        =   AF.Head,
    body        =   EMPY.Body,
    hands       =   EMPY.Hands,
    legs        =   INYA.Legs,
    feet        =   AF.Feet,
    neck        =   "Mnbw. Whistle +1",
    waist       =   "Luminary Sash",
    left_ear    =   "Regal Earring",
    right_ear   =   "Gwati Earring",
    left_ring   =   "Murky Ring",
    right_ring  =   "Crepuscular Ring",
}

sets.midcast['Magic Finale']        = set_combine(sets.midcast.DebuffSong, {legs = EMPY.Legs})
sets.midcast.Threnody               = set_combine(sets.midcast.DebuffSong, {})
sets.midcast.Elegy                  = set_combine(sets.midcast.DebuffSong, {})
sets.midcast.Requiem                = set_combine(sets.midcast.DebuffSong, {})
sets.midcast['Pining Nocturne']     = set_combine(sets.midcast.DebuffSong, {})
sets.midcast["Maiden's Virelai"]    = set_combine(sets.midcast.DebuffSong, {})

-- Lullaby: strings give a wider range (Horde I is 8', Horde II depends on skill).
sets.midcast.Lullaby = set_combine(sets.midcast.DebuffSong, {hands = AF.Hands})
sets.midcast['Horde Lullaby'] = set_combine(sets.midcast.Lullaby, {range = "Daurdabla"})
sets.midcast['Horde Lullaby II'] = set_combine(sets.midcast.Lullaby, {
    range       =   "Daurdabla",        -- Skill+20
    body        =   AF.Body,            -- Skill+14
    hands       =   EMPY.Hands,         -- Skill+22
    feet        =   RELIC.Feet,         -- Skill+15
    neck        =   "Mnbw. Whistle +1", -- Songs+ 3
    waist       =   "Harfner's Sash",   -- Skill+ 5
    left_ear    =   "Regal Earring",
    right_ear   =   "Gersemi Earring",  -- Skill+10
})

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS - OTHER MAGIC
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast.Cure = {
    main        =   "Daybreak",             --Cure Potency +30%
    sub         =   "Ammurapi Shield",
    head        =   EMPY.Head,
    body        =   "Bunzi's Robe",         --Cure Potency +15%
    hands       =   "Bunzi's Gloves",
    legs        =   EMPY.Legs,
    feet        =   RELIC.Feet,
    neck        =   "Loricate's Torque +1",
    waist       =   "Luminary Sash",
    back        =   "Solemnity Cape",       --Cure Potency + 7%
    left_ear    =   "Gifted Earring",
    right_ear   =   "Fili Earring",
    left_ring   =   "Sirona's Ring",
    right_ring  =   "Menelaus's Ring",      --Cure Potency + 5%
}
sets.midcast.Curaga = sets.midcast.Cure

sets.midcast.Cursna = {
    neck        =   "Nicander's Necklace",  --Cursna +20
    right_ring  =   "Menelaus's Ring",      --Cursna +20
}

sets.midcast['Enhancing Magic'] = {
    main        =   "Pukulatmuj +1",        --Skill +11
    sub         =   "Ammurapi Shield",      --Duration +10%
    range       =   "Terpander",
    head        =   "Telchine Cap",         --Duration + 9%
    body        =   "Telchine Chas.",       --Duration +10%
    hands       =   "Telchine Gloves",      --Duration + 9%
    legs        =   "Telchine Braconi",     --Duration + 8%
    feet        =   "Telchine Pigaches",    --Duration + 8%
    neck        =   "Loricate Torque +1",
    waist       =   "Embla Sash",           --Duration +10%
    back        =   "Fi Follet Cape",       --Skill + 8
}
sets.midcast.Haste = sets.midcast['Enhancing Magic']
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {})

sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast.DebuffSong, {
    range       =   "Gjallarhorn",
    head        =   "Brioso Roundlet +3",
    body        =   "Brioso Justau. +3",
    hands       =   "Fili Manchettes +3",
    legs        =   CHIR.Legs.Refresh,
    feet        =   "Fili Cothurnes +2",
    neck        =   "Mnbw. Whistle +1",
    waist       =   "Luminary Sash",
    left_ear    =   "Regal Earring",
    right_ear   =   { name="Fili Earring", augments={'System: 1 ID: 1676 Val: 0','Accuracy+9','Mag. Acc.+9',}},
    left_ring   =   "Weather. Ring",
    right_ring  =   "Crepuscular Ring",
    back        =   BRDCape.Macc,
})

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT & BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════

-- His Kiting set.
sets.MoveSpeed = {feet = EMPY.Feet}

sets.buff = {}
-- No Doom set in his file: derived from the Cursna-received neck of his Cursna set.
sets.buff.Doom = {neck = "Nicander's Necklace"}

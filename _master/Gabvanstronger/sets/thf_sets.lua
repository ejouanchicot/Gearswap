---============================================================================
--- THF Equipment Sets - Gabvanstronger
---============================================================================
--- Gab's THF gear (from init_gear_sets of his Gabvanstronger/THF.lua, the
--- file his GearSwap loaded) under the set names our THF code reads. His
--- gear tables (AF, RELIC, EMPY, THFCape, HERC, MEGH, MUMM, STIK, ...) come
--- from sets/0_AugGear_Gabvanstronger.lua, under his own names.
---
--- How our THF picks these sets (docs/dev/jobs/thf.md):
---   * Idle: sets.idle[IdleMode] (Normal = sets.idle), sets.idle.Town in a
---     city, sets.idle.Weak under weakness, then the MainWeapon / SubWeapon,
---     then sets.MoveSpeed while moving (not in town).
---   * Engaged: sets.engaged[HybridMode] (his OffenseMode: Normal / DT),
---     weapons (or the AbyWeapon pair while AbyProc is on), the Sneak Attack /
---     Trick Attack overlay, then sets.TreasureHunter per TreasureMode.
---   * Weaponskills: sets.precast.WS[name], then its .SA / .TA / .SATA while
---     the buff is up (sa_ta_manager.lua).
---   * Weapons: equip_without_set (config/WEAPON_CONFIG.lua) equips a plain
---     weapon without a set.
---
--- His conditional gear (TH on Aeolian Edge, TH on weaponskills and SA/TA in
--- SATA/Full, extra regen under 80% HP, CP cape, the Pull ranged weapon) is
--- in config/thf/THF_CUSTOM.lua.
---
--- @file    sets/thf_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

include('sets/0_AugGear_Gabvanstronger.lua')

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- Aeneas, Kartika, Tauret, Naegling, Norgish Dagger (main) and Fusetto +2,
-- Gleti's Knife, Tanmogayi +1, Ternion Dagger +1, Qutrub Knife (sub) need no
-- set (equip_without_set). 'Free' has no set on purpose: his
-- check_weaponsets equipped {main = 'Free'}, which is no item, so the worn
-- weapon stayed; a value with no set and no such weapon does the same here.

-- • Abyssea proc weapons (AbyWeapon values), from the "Abyssea Farm" sets of
-- his 0_AugGear_shared.lua (his AbysseaSet, used in OffenseMode Abyssea).
-- His Katana / Great Katana pairs only existed with NIN main job: never on THF.
sets.Dagger			= {main = "Aern Dagger", sub = "Nihility"}		-- (2/9 Wind, Darkness): Cyclone/Energy Drain
sets.Sword			= {main = "Extinction", sub = "Nihility"}		-- (3/9 Light, Fire): Seraph Blade/Red Lotus Blade
sets.Club			= {main = "Charm Wand", sub = "Nihility"}		-- (4/9 Light): Seraph Strike
sets.Polearm		= {main = "Pitchfork +1"}						-- (5/9 Thunder): Raiden Thrust
sets.Scythe			= {main = "Hoe"}								-- (6/9 Darkness): Shadow of Death
sets['Great Sword']	= {main = "Lament"}								-- (7/9 Ice): Freezebite
sets.Staff			= {main = "Chatoyant Staff"}					-- (9/9 Earth, Light): Earth Crusher/Sunburst

-- • His RangedSet values. 'Pull' is worn and locked by the RangedSet mode of
-- THF_CUSTOM.lua. His sets.Ammo was never equipped on THF (check_rangedset
-- equipped {range = 'Ammo'}, no item): kept for reference only.
sets.Ammo			= {ammo = "Coiste Bodhar"}
sets.Pull			= {range = "Antitail +1"}
--	sets.Ullr		= {range = "Ullr", ammo = " Arrow"}

-- • Capacity Point cape (CP mode of THF_CUSTOM.lua)
sets.CP				= {back = CAPACITY.Cape}

-- ═══════════════════════════════════════════════════════════════════════════
-- MOVEMENT
-- ═══════════════════════════════════════════════════════════════════════════
-- sets.MoveSpeed goes on while moving, outside town (his 0_AutoMove.lua)
-- sets.MoveSpeed	= {feet = "Pill. Poulaines +1"}
sets.MoveSpeed		= {feet = "Skadi's Jambeaux +1"}
-- Mote's Kiting toggle (Alt+F10)
sets.Kiting			= {feet = "Skadi's Jambeaux +1"}
-- No sets.Adoulin: his was {body = "Councilor's Garb"} alone (built before
-- sets.MoveSpeed existed) and only went on while moving; ours would replace
-- the whole idle set in Adoulin. Adoulin uses sets.idle.Town instead.

-- ═══════════════════════════════════════════════════════════════════════════
-- TREASURE HUNTER / BUFF SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.TreasureHunter = {--Proc@8, shows in log @9.
	ammo		=	"Perfect Lucky Egg",--TH+1
--	head		=	"Wh. Rarab Cap +1",	--TH+1
	--body		=	"Volte Jupon",		--TH+2
	hands		=	RELIC.Hands,		--TH+3 | +2",--TH+3 | +3",--TH+4
	feet		=	EMPY.Feet,			--TH+3
	waist		=	"Chaac Belt",		--TH+1
}--									Total:TH+9(+4 from traits)

-- His customize_idle_set added this under 80% HP (rule in THF_CUSTOM.lua)
sets.ExtraRegen = {
	neck		=	"Bathy Choker +1",
	left_ear	=	"Infused Earring",
	left_ring	=	"Chirich Ring +1",
}

sets.buff = {}

sets.buff['Sneak Attack'] = { --SA+ & Crit dmg+
	ammo		=	"C. Palug Stone",
	head		=	AF.Head,
	body		=	AF.Body,
	hands		=	EMPY.Hands,
	legs		=	MUMM.Legs, --AF.Legs,
	feet		=	RELIC.Feet,
	neck		=	"Anu Torque",
--	ear1		=	"Dudgeon Earring",
--	ear2		=	"Heartseeker Earring",
	ring1		=	"Epona's Ring",
	ring2		=	"Rajas Ring",
	back		=	THFCape.WS,
--	waist		=	"Patentia Sash",
}

sets.buff['Trick Attack'] = {
	ammo		=	"C. Palug Stone",
	head		=	AF.Head,
	neck		=	"Anu Torque",
--	ear1		=	"Dudgeon Earring",
--	ear2="Heartseeker Earring",
	body		=	AF.Body,
	hands		=	AF.Hands,
	ring1		=	"Epona's Ring",
--	ring2="Stormsoul Ring",
	back		=	"Atheling Mantle",
--	waist="Patentia Sash",
	legs		=	MUMM.Legs, --legs		=AF.Legs (+1),
	feet		=	RELIC.Feet,
}

-- Doom: no Doom set in his file
sets.buff.Doom = {}	-- empty in his file

-- TreasureMode SATA / Full: these replace sets.buff[...] as the engaged SA/TA
-- overlay. His check_buff equipped sets.buff[buff] THEN sets.TreasureHunter
-- (TH wins), for each active buff.
sets.TreasureHunterSA = set_combine(sets.buff['Sneak Attack'], sets.TreasureHunter)
sets.TreasureHunterTA = set_combine(sets.buff['Trick Attack'], sets.TreasureHunter)
sets.TreasureHunterSATA = set_combine(sets.buff['Sneak Attack'], sets.buff['Trick Attack'], sets.TreasureHunter)

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.precast = {}
sets.precast.JA = {}

-- Actions we want to use to tag TH.
sets.precast.Step = sets.TreasureHunter
sets.precast.Flourish1 = sets.TreasureHunter
sets.precast.JA.Provoke = sets.TreasureHunter

-- Precast sets to enhance JAs
sets.precast.JA['Collaborator'] 	= {	head	=	EMPY.Head}
sets.precast.JA['Accomplice']		= {	head	=	EMPY.Head}
sets.precast.JA['Flee']				= {	feet	=	AF.Feet} --+15s; +1 16s; +2 17s; 3 +18s
sets.precast.JA['Hide']				= {	body	=	AF.Body}
sets.precast.JA['Conspirator']		= {} -- {body="Raider's Vest +2"}	-- empty in his file
sets.precast.JA['Steal']			= {	head	=	RELIC.Head,hands=AF.Hands,legs=AF.Legs,feet=AF.Feet,ammo="Barathrum"}
sets.precast.JA['Despoil']			= {	legs	=	EMPY.Legs,feet=EMPY.Feet,ammo="Barathrum"}
sets.precast.JA['Perfect Dodge']	= {	hands	=	RELIC.Hands}
sets.precast.JA['Feint']			= {	legs	=	RELIC.Legs}
sets.precast.JA['Mug']				= {	head	=	RELIC.Head}

sets.precast.JA['Sneak Attack'] 	= sets.buff['Sneak Attack']
sets.precast.JA['Trick Attack'] 	= sets.buff['Trick Attack']

-- Waltzes ((Dancer's CHR + Receiver's VIT)/4) + 60HP)
sets.precast.Waltz = {
--	ammo="Sonia's Plectrum",
	head		=	MEGH.Head,
--	body		=
	hands		=	MEGH.Hands,
	legs		=	MEGH.Legs,
	feet		=	MEGH.Feet,
--	neck		=	"Star Necklace",
--  back="Iximulew Cape",
--	ring1="Asklepian Ring",
}

-- Don't need any special gear for Healing Waltz.
sets.precast.Waltz['Healing Waltz'] = {}

-- Fast cast sets for spells
-- (his key was "Ammo": slot names are case-insensitive, it did go on)
sets.precast.FC = {
	ammo		=	"Sapience Orb",			--FC+ 2%
	head		=	HERC.Head.FC,			--FC+13%
	hands		=	"Leyline Gloves",		--FC+ 7%
	--legs="Enif Cosciales"
	feet		=	HERC.Feet.FC,			--FC+ 5%
	neck		=	"Baetyl Pendant",		--FC+ 4%
	right_ear	=	"Loquac. Earring",		--FC+ 2%
	left_ear	=	"Etiolation Earring",	--FC+ 1%
	right_ring	=	"Naji's Loop",			--FC+ 1%
}--										Total:FC+39%

sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, {
	body		=	"Passion Jacket",
	neck		=	"Magoraga Beads"
})

--[[ Ranged Gear RA Delay:
		Snapshot (Throw, Bow, Marksmanship)
		Rapid Shot (Bow and Marksmanship)]]
sets.precast.RA = {
	hands		=	PURS.Hands.A,	--Rapid Shot +8
	legs		=	"Adhemar Kecks", --Snapshot +9, Rapid Shot +10
	feet		=	MEGH.Feet,
}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPONSKILL SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- Default WS Set	| WS.Acc | WS.SA | WS.TA |
-- Full DEX Rudra's Storm / Mandalic Stab
sets.precast.WS = {
	ammo		=	"C. Palug Stone",
	head		=	"Nyame Helm",
	body		=	"Nyame Mail",
	hands		=	"Nyame Gauntlets",
	legs		=	"Nyame Flanchard",
	feet		=	"Nyame Sollerets",
	neck		=	"Maskirova Torque",
	waist		=	"Grunfeld Rope",
	back		=	THFCape.WS,
	left_ring	=	"Regal Ring",
	right_ring	=	"Cornelia's Ring",
--	left_ring	=	"Beithir Ring",
--	right_ring	=	"Karieyh Ring",
	left_ear	=	"Moonshade Earring",
--	right_ear	=	"Ishvara Earring",
	right_ear	=	"Odr Earring",
}

-- His WeaponskillMode Acc set: a copy of the base set (no state reads it here)
sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

-- His generic SA / TA variants. Mote used them for EVERY weaponskill with no
-- set of its own (his get_custom_wsmode). With both buffs his mode was
-- 'SATA', which had no set, so he got the plain set; here a SA+TA
-- weaponskill takes .SA (sa_ta_manager falls back to .SA when .SATA is absent).
sets.precast.WS.SA = set_combine(sets.precast.WS, {
	ammo		=	"Yetshila +1",
})
sets.precast.WS.TA = set_combine(sets.precast.WS, {
	ammo		=	"Yetshila +1",
})

-- Our SA/TA variant lookup is per weaponskill name, so every weaponskill
-- that fell back to his generic set gets a copy of it with the same .SA/.TA.
-- (Copies, not the same table: sets.precast.WS must not contain itself.)
for _, ws_name in ipairs({"Rudra's Storm", 'Evisceration', 'Exenterator', 'Mandalic Stab',
		'Shark Bite', 'Dancing Edge', 'Savage Blade'}) do
	sets.precast.WS[ws_name] = set_combine(sets.precast.WS, {})
	sets.precast.WS[ws_name].SA = sets.precast.WS.SA
	sets.precast.WS[ws_name].TA = sets.precast.WS.TA
end

-- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
sets.precast.WS['Aeolian Edge'] = { --Stat Modifier: DEX40%/INT40% MAB
	ammo		=	"Seeth. Bomblet +1",
	head		=	"Nyame Helm",
	body		=	"Nyame Mail",
	hands		=	"Nyame Gauntlets",
	legs		=	"Nyame Flanchard",
	feet		=	"Nyame Sollerets",
	neck		=	"Baetyl Pendant",
	waist		=	"Orpheus's Sash",
	left_ear	=	"Friomisi Earring",
	right_ear	=	{ name="Moonshade Earring", augments={'Attack+4','TP Bonus +250',}},
	left_ring	=	"Dingir Ring",
	right_ring	=	"Cornelia's Ring",
	back		=	{ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','DEX+10','Weapon skill damage +10%',}},
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.midcast = {}

sets.midcast.FastRecast = {
	head		=	HERC.Head.Refresh,
--	body="Shned. Tabard +1",
	hands		=	AF.Hands, --or Adhemar Wristbands H5 Eva36, or Pursuer's CuffsH5 eva24, or Rawhide Gloves h5 eva24
--	legs="Kaabnax Trousers",
	feet		=	EMPY.Feet, --Herculean boots H4 PDT2, Iuitl Gaiters H4 PDT3 > Eventuellement Iuitl Gaiters +1 H5
	waist		=	"Sailfi Belt +1",
	left_ear	=	"Etiolation Earring",
	right_ear	=	"Loquac. Earring",
}

-- Specific spells
sets.midcast.Utsusemi = set_combine(sets.midcast.FastRecast, {
	back		=	"Mujin Mantle",
})

-- Ranged gear (RangedMode Normal / Acc)
sets.midcast.RA = {
	head		=	MEGH.Head,
	body		=	MEGH.Body,
	hands		=	MEGH.Hands,
	legs		=	MEGH.Legs,
	feet		=	MEGH.Feet,
	neck		=	"Iskur Gorget",
	waist		=	"Yemaya Belt",
	left_ear	=	"Crep. Earring",
	right_ear	=	"Telos Earring",
	left_ring	=	"Cacoethic Ring +1",
	right_ring	=	"Fistmele Ring",
	back		=	"Buquwik Cape",
}

sets.midcast.RA.Acc = {
	head		=	MEGH.Head,
	body		=	MEGH.Body,
	hands		=	MEGH.Hands,
	legs		=	MEGH.Legs,
	feet		=	MEGH.Feet,
	neck		=	"Iskur Gorget",
	left_ear	=	"Crep. Earring",
--	right_ear="Vision Earring",
	left_ring	=	"Longshot Ring",
	right_ring	=	"Cacoethic Ring +1",
	back		=	"Kayapa Cape",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS (IdleMode: Normal / Refresh / Regain)
-- ═══════════════════════════════════════════════════════════════════════════
-- Resting sets
sets.resting = {}	-- empty in his file

sets.idle = {
	ammo		=	"Staunch Tathlum",		-- DT- 3%
	head		=	"Nyame Helm",			-- DT- 7%
	body		=	"Malignance Tabard",	-- DT- 9%
	hands		=	"Nyame Gauntlets",		-- DT- 7%
	legs		=	"Nyame Flanchard",		-- DT- 8%
	feet		=	"Malignance Boots",
	neck		=	"Rep. Plat. Medal",
	waist		=	"Null Belt",
	left_ear	=	"Alabaster Earring",
	right_ear	=	"Infused Earring",
	left_ring	=	"Defending Ring",		-- DT-10%
	right_ring	=	"Murky Ring",			-- Regain +5
	back		=	THFCape.TP,				-- DT- 5%
}--										Total: DT-46%
sets.idle.Refresh = set_combine(sets.idle, {
	head		=	"Rawhide Mask",
	hands		=	HERC.Hands.Refresh,
	left_ring	=	STIK.One,
	right_ring	=	STIK.Two,
})
sets.idle.Regain = set_combine(sets.idle, {
	body		=	"Gleti's Cuirass",		-- DT- 9%
	hands		=	"Gleti's Gauntlets",	-- DT- 7% (his THF.lua:375 wrote "Gleti's Gloves", no such item; his BLU.lua has Gauntlets)
	legs		=	"Gleti's Breeches",		-- DT- 8%
	neck		=	"Rep. Plat. Medal",
})
sets.idle.Town = set_combine(sets.idle, {
--	feet="Councilor's Garb",
})
sets.idle.Weak = set_combine(sets.idle, {})

-- Defense sets (Mote's F10 / F11 emergency modes; his PhysicalDefenseMode
-- options were commented out, so Evasion was never reached)
sets.defense = {}
sets.defense.Evasion = {
--	ammo		=	"Yamarang",		-- EVA+15
	head		=	AF.Head,
--	body="Qaaxo Harness",
--	hands		=	AF.Hands,
--	legs="Kaabnax Trousers",
--	feet="Iuitl Gaiters +1",
	neck="Ej Necklace",--Combatant's Torque
--	back="Canny Cape",
--	waist="Flume Belt",
	ring1="Defending Ring",
--	ring2="Beeline Ring",
}

sets.defense.PDT = {
--	ammo			=	"Demonry Stone",
	head			=	MEGH.Head,
	body			=	MEGH.Body,
	hands			=	MEGH.Hands,
	legs			=	MEGH.Legs,
	feet			=	MEGH.Feet,
	neck			=	"Loricate Torque +1",
	right_ear		=	"Ethereal Earring",
	left_ring		=	"Defending Ring",
	right_ring		=	"Gelatinous Ring +1",
	--back			=	THFCape.TP,
	--waist			=	"Flume Belt",
}

sets.defense.MDT = {
--	ammo			=	"Demonry Stone",
	head			=	AF.Head,
	body			=	MEGH.Body,
	hands			=	AF.Hands,
	legs			=	MUMM.Legs,
	feet			=	MUMM.Feet,
	neck			=	"Loricate Torque +1",
	--back			=	THFCape.TP,
	--waist			=	"Flume Belt",
	left_ear		=	"Eabani Earring",
	right_ear		=	"Ethereal Earring",
	left_ring		=	"Defending Ring",
	right_ring		=	"Archon Ring",
}

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS (HybridMode: Normal / DT = his OffenseMode Normal / DT)
-- ═══════════════════════════════════════════════════════════════════════════
-- Normal melee group 0% M.Haste
--		--H+25 DW5 DA/TA20/QA2 STP19 FC7 WSD1
sets.engaged = {--						Total: DA 		TA		QA		STP		DT		Haste	Acc 	Atk 	Stats
	ammo		=	"Coiste Bodhar",		-- DA+ 3					STP+ 3
	head		=	"Malignance Chapeau",	-- 							STP+ 8	DT- 6	H+ 6
	body		=	"Malignance Tabard",	-- 							STP+11	DT- 9	H+ 4
	hands		=	"Malignance Gloves",	-- 							STP+12	DT- 5	H+ 4
	legs		=	"Malignance Tights",	--		 					STP+10	DT- 7	H+ 9
	feet		=	"Malignance Boots",		-- 							STP+ 9	DT- 4	H+ 3
	neck		=	"Iskur Gorget",			--							STP+ 8
	waist		=	"Reiki Yotai",			-- 							STP+ 4					DW+ 7
	left_ear	=	"Sherida Earring",		-- DA+ 5					STP+ 5
	right_ear	=	EMPY.Ear,				-- 			TA+ 4			STP+ 3
	left_ring	=	"Epona's Ring",			-- DA+ 3	TA+ 3
	right_ring	=	"Petrov Ring",			-- DA+ 1					STP+ 5
	back		=	THFCape.TP,				--							STP+10	PDT-10
}--										Total: DA+ 12	TA+ 9	QA+ 2	STP+86	DT- 41	H+26

sets.engaged.DT = set_combine(sets.engaged, {
	ammo="Coiste Bodhar",
	head="Nyame Helm",
	body="Nyame Mail",
	hands="Nyame Gauntlets",
	legs="Nyame Flanchard",
	feet="Nyame Sollerets",
	neck="Iskur Gorget",
	waist="Reiki Yotai",
	left_ear="Sherida Earring",
	right_ear={ name="Skulk. Earring +1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+13','Mag. Acc.+13','"Store TP"+4',}},
	left_ring="Epona's Ring",
	right_ring="Petrov Ring",
	back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}},
})

-- Not in his cycle (his OffenseMode Acc / Crit and HybridMode Evasion /
-- 'DT TH' were commented out): nothing selects these, kept as he wrote them.
sets.engaged.Acc = set_combine(sets.engaged, {
	ammo		=	"Yamarang",
	head		=	MEGH.Head,
	hands		=	MEGH.Hands,
	feet		=	MEGH.Feet,
	neck		=	"Null Loop",
	waist		=	"Grunfeld Rope",
	left_ear	=	"Telos Earring",
--	left_ring	=	"Keen Ring",
	right_ring	=	"Rajas Ring",
})

sets.engaged.Evasion = set_combine(sets.engaged, {ammo="Yamarang",})
sets.engaged.Acc.Evasion = set_combine(sets.engaged.Acc, sets.engaged.Evasion)

sets.engaged.Crit = set_combine(sets.engaged, {
	ammo={ name="Coiste Bodhar", augments={'Path: A',}},
	head="Blistering Sallet +1",
	body="Gleti's Cuirass",
	hands="Malignance Gloves",
	legs="Gleti's Breeches",
	feet="Malignance Boots",
	neck={ name="Loricate Torque +1", augments={'Path: A',}},
	waist="Windbuffet Belt +1",
	left_ear="Sherida Earring",
	right_ear="Suppanomimi",
	left_ring="Begrudging Ring",
	right_ring="Hetairoi Ring",
	back={ name="Toutatis's Cape", augments={'DEX+20','Accuracy+20 Attack+20','Accuracy+10','"Store TP"+10','Damage taken-5%',}},
})
sets.engaged['DT TH'] = set_combine(sets.engaged, {
	head		=	"Nyame Helm",			-- DT- 7%
	body		=	"Malignance Tabard",	-- DT- 9%
	legs		=	"Nyame Flanchard",		-- DT- 8%
	neck		=	"Loricate Torque +1",	-- DT- 6%
	right_ring	=	"Defending Ring",		-- DT-10%
	back		=	THFCape.TP,				-- DT- 5%
})--									Total: DT-45%

sets.engaged.Acc.DT = {}	-- empty in his file


-- ═══════════════════════════════════════════════════════════════════════════
-- SETS OF TETSOUO'S THF HE DID NOT HAVE
-- ═══════════════════════════════════════════════════════════════════════════
-- Every set name of Tetsouo's THF exists here too. Each one he had no set for
-- is built from his own sets only, with no piece added: fill them in later.

-- Engaged / idle
sets.engaged.PDT      = set_combine(sets.engaged.DT, {})
sets.engaged.PDTAFM3  = set_combine(sets.engaged.DT, {})
sets.engaged.TH       = set_combine(sets.engaged, sets.TreasureHunter)
sets.idle.PDT         = set_combine(sets.idle, sets.defense.PDT)
sets.idle.Regen       = set_combine(sets.idle, sets.ExtraRegen)
-- Replaces the whole idle in Adoulin (base_set_builder): his town idle with
-- his own Adoulin piece (sets.Adoulin of his 0_AutoMove.lua line 22)
sets.Adoulin          = set_combine(sets.idle.Town, {body = "Councilor's Garb"})

-- Treasure Hunter on Aeolian Edge and ranged attacks
sets.AeolianTH        = set_combine(sets.precast.WS['Aeolian Edge'], sets.TreasureHunter)
sets.precast.RATH     = set_combine(sets.precast.RA, sets.TreasureHunter)
sets.TreasureHunterRA = set_combine(sets.precast.RA, sets.TreasureHunter)
sets.midcast.RA.TH    = set_combine(sets.midcast.RA, sets.TreasureHunter)

-- Spells, abilities
sets.midcast.Cure           = set_combine(sets.midcast.FastRecast, {})
sets.midcast.EnhancingMagic = set_combine(sets.midcast.FastRecast, {})
sets.precast.JA['Animated Flourish'] = set_combine(sets.precast.JA.Provoke, {})

-- Weaponskills
sets.precast.WS['Circle Blade'] = set_combine(sets.precast.WS, {})
for _, ws_name in ipairs({"Rudra's Storm", 'Evisceration', 'Exenterator', 'Mandalic Stab',
		'Shark Bite', 'Dancing Edge', 'Savage Blade'}) do
	sets.precast.WS[ws_name].SATA = set_combine(sets.precast.WS.SA, {})
end

-- Weapon sets: Tetsouo's weapons, not in his files (left empty; his weapon
-- choices work without a set, WEAPON_CONFIG equip_without_set). Dagger2 is
-- Tetsouo's Abyssea dagger slot: his own Abyssea dagger pair.
sets.Dagger2 = set_combine(sets.Dagger, {})
for _, name in ipairs({'Alber', 'Blurred', 'Centovente', 'Crepu', 'Gleti', 'Jugo', 'Kraken',
		'Malevolence', 'Naegling', 'Tanmogayi', 'Tauret', 'TwashtarM', 'TwashtarS', 'Vajra',
		'Mpu Gandring', 'Telop Knife'}) do
	sets[name] = {}
end

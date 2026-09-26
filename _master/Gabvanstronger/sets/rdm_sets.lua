---============================================================================
--- RDM Equipment Sets - Gabvanstronger
---============================================================================
--- Gab's RDM gear (from his Gabvanstronger/sets/rdm_sets.lua) under the set
--- names our RDM code reads today. His gear tables (AF, RELIC, EMPY,
--- RDMCape, CHIR, STIK, ...) come from sets/0_AugGear_Gabvanstronger.lua,
--- under his own names.
---
--- How our RDM picks these sets (docs/dev/jobs/rdm.md):
---   * Idle / engaged: sets.idle[IdleMode], sets.engaged[EngagedMode] (its
---     .DW child when the sub weapon is not in sets.shields), then the
---     MainWeapon / SubWeapon sets.
---   * Weapons: equip_without_set (config/WEAPON_CONFIG.lua) equips a plain
---     weapon without a set. A shield is not a weapon in the game's item
---     list, so each shield of SubWeapon keeps its set.
---   * Midcast: MidcastManager (spell name, family, enfeebling type, mode,
---     Composure target, then the skill's own set).
---
--- Where his old file pointed at a table that did not exist (the piece or
--- the base was silently nil), the reference is corrected and marked
--- "was nil" below.
---
--- @file    sets/rdm_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-25
---============================================================================

include('sets/0_AugGear_Gabvanstronger.lua')

sets = {}

-- ═══════════════════════════════════════════════════════════════════════════
-- WEAPON SETS
-- ═══════════════════════════════════════════════════════════════════════════
-- Sakpata's Sword, Excalibur, Maxentius, Naegling, Murgleis, Crocea Mors,
-- Tauret, Aern Dagger, Nihility (main) and Daybreak, Bunzi's Rod, Thibron,
-- Crepuscular Knife, Gleti's Knife, Qutrub Knife (sub) need no set
-- (equip_without_set).

-- 'Free' is not an item: this set is what the value does
sets['Free'] = {main = ''}

-- • Shields (Armor in the game's item list: the resolver cannot equip them without a set)
sets['Sacro Bulwark'] = {sub = 'Sacro Bulwark'}
sets['Forfend +1'] = {sub = 'Forfend +1'}
sets["Archduke's Shield"] = {sub = "Archduke's Shield"}

-- • Shield Configuration List (a sub listed here = single wield sets, else .DW)
sets.shields = {
	'Ammurapi Shield',
	'Genmei Shield',
	'Forfend +1',
	"Archduke's Shield",
	'Sacro Bulwark',       -- added: a SubWeapon value, missing from his list (would pick the .DW sets)
}

-- ═══════════════════════════════════════════════════════════════════════════
-- IDLE SETS
-- ═══════════════════════════════════════════════════════════════════════════
sets.idle = {}

-- Refresh Idle (maximize Refresh+)
sets.idle.Refresh = {
	--	main 		=	Bolelabunga			--Refresh+ 1			Regen+1			>	Colada+2 main/sub
	--	sub				Sacro Bulwark		--				 DT-10%
	ammo		=	"Homiliary",		--Refresh+ 1
	head		=	RELIC.Head,			--Refresh+ 3		-			Meva+ 95
	body		=	EMPY.Body,			--Refresh+ 4 	 DT-14%			Meva+136
	hands		=	CHIR.Hands.Refresh,	--Refresh+ 2
	legs		=	CHIR.Legs.Refresh,	--Refresh+ 2		-			Meva+112
	feet		=	CHIR.Feet.Refresh,	--Refresh+ 2	PDT- 2%			Meva+112
	neck		=	"Loricate Torque +1",--				 DT- 6%
	waist		=	"Null Belt",		--				 		Regen+3	Meva+ 30	Eva+30
	left_ear	=	"Infused Earring",	--					-	Regen+1
	right_ear	=	"Ethereal Earring",	--				Convert 3% to MP
	left_ring	=	STIK.One,			--Refresh+ 1		-
	right_ring	=	STIK.Two,			--Refresh+ 1		-
	back		=	RDMCape.Idle,		--				PDT-10%			Meva+ 30	VIT+20
}

-- DT Idle (Physical Damage Taken -, cap 50%)
sets.idle.DT = set_combine(sets.idle.Refresh, {
	ammo		=	"Staunch Tathlum",	--				 DT- 2%
	head		=	RELIC.Head,			--Refresh+ 3	 ......			Meva+ 95	Eva+ 56
	body		=	EMPY.Body,			--Refresh+ 4 	 DT-14%			Meva+136	Eva+ 91
	hands		=	"Nyame Gauntlets",	--				 DT- 7%			Meva+112	Eva+ 80
	legs		=	"Nyame Flanchard",	--				 DT- 8%			Meva+150	Eva+ 85
	feet		=	"Nyame Sollerets",	--				 DT- 7%			Meva+150	Eva+119
	neck		=	"Loricate Torque +1",--				 DT- 6%
	waist		=	"Null Belt",		--				 		Regen+3	Meva+ 30	Eva+ 30
	left_ear	=	"Infused Earring",	--					-	Regen+1
	right_ear	=	"Ethereal Earring",	--				Convert 3% to MP
	left_ring	=	STIK.One,			--Refresh+ 1		-
	right_ring	=	STIK.Two,			--Refresh+ 1		-
	back		=	RDMCape.Idle,		--				PDT-54%			Meva+ 30	VIT+20
})

sets.idle.Regain = set_combine(sets.idle.Refresh, {
	--	head		=	"Null Masque",		-- Regain+ 2
		neck		=	"Rep. Plat. Medal",	-- Regain+ 2
	--	right_ring	=	"Karieyh Ring",		-- Regain+ 5
})
sets.idle.Regen = set_combine(sets.idle.Refresh, {
	--	ammo		=	-- None
	--	head		=	"Null Masque",		-- Regen+ 3
	--	body		=	"Telchine Chasuble",-- Regen+ 1~2 en aug ou Pluviale?
	--	hands		=	"Telchine Gloves",	-- Regen+ 1~2 en aug
	--	legs		=	"Telchine Braconi",	-- Regen+ 1~2 en aug
	-- 	feet		=	"Telchine Pigaches",	-- Regen+ 1~2 en aug
		neck		=	"Bathy Choker +1",	-- Regen+ 3
		waist		=	"Null Belt",		-- Regen+ 3
		left_ear	=	"Infused Earring",	-- Regen+ 1
	--	right_ear	=
		left_ring	=	CHIR.One,		-- Regen+ 2
		right_ring	=	CHIR.Two,		-- Regen+ 2 ou Paguroidea Ring Regen +2
		back		=	"Kumbira Cape",		--Regen+ 1
})

-- ═══════════════════════════════════════════════════════════════════════════
-- ENGAGED SETS (EngagedMode: Store TP / Refresh DT / DT / Enspell / Subtle Blow)
-- ═══════════════════════════════════════════════════════════════════════════
sets.engaged = {}

-- Refresh Engaged (MP refresh while engaged)
sets.engaged['Refresh DT'] = {
	ammo		=	"Coiste Bodhar",		-- 		DA+ 3	STP+ 3
	head		=	"Malignance Chapeau",	-- 				STP+ 8 			 DT- 6%	DmgL+3%
	body		=	EMPY.Body,				-- 								 DT-14%	Refresh+ 4
	hands		=	"Malignance Gloves",	-- 				STP+12 			 DT- 5%	DmgL+4%
	legs		=	"Malignance Tights",	-- 				STP+10 			 DT- 7%	DmgL+5%
	feet		=	"Malignance Boots",		-- 				STP+ 9			 DT- 4%	DmgL+2%
	neck		=	"Anu Torque",			--				STP+ 7
	waist		=	"Sailfi Belt +1",		--		DA+ 5			TA+2
	left_ear	=	"Telos Earring",		--		DA+ 1	STP+ 5
	right_ear	=	"Sherida Earring",		-- 		DA+ 5	STP+ 5
	left_ring	=	"Hetairoi Ring",		--						TA+2
	-- left_ring	=	"Petrov Ring",			--		DA+1	STP+ 5
	right_ring	=	"Ilabrat Ring",			--				STP+ 5								Atk/STR/DEX
	back		=	RDMCape.TP,				-- 				STP+10			PDT-10%
}

-- DT Engaged (defensive melee - Physical Damage Taken -)
sets.engaged.DT = {
	ammo		=	"Coiste Bodhar",		--		DA+3	STP+3
	head		=	EMPY.Head,			-- DT- 9%
	body		=	EMPY.Body,			-- DT-13%
	hands		=	"Bunzi's Gloves",	-- DT- 8%
	legs		=	"Nyame Flanchard",	-- DT- 8%
	feet		=	"Nyame Sollerets",	-- DT- 7%
	neck		=	"Anu Torque",			--				STP+7
	waist		=	"Sailfi Belt +1",		--		DA+5			TA+2
	left_ear	=	"Telos Earring",		--		DA+ 1	STP+ 5
	right_ear	=	"Sherida Earring",		--		DA+5	STP+5
	left_ring	=	"Hetairoi Ring",		--						TA+2
	right_ring	=	"Ilabrat Ring",			--				STP+5			Atk/STR/DEX
	back		=	RDMCape.TP,				--				STP+10			PDT-10%
}

-- TP Engaged (maximize Store TP, TP gain)
-- Built on sets.engaged (empty) as he asked; every slot is listed anyway.
sets.engaged['Store TP'] = set_combine(sets.engaged, {
	ammo		=	"Coiste Bodhar",		--		DA+ 3	STP+ 3								Aurgelmir+1	STP+ 5
	head		=	"Malignance Chapeau",	-- 				STP+ 8			 DT- 6%	DmgL+3%
	body		=	"Malignance Tabard",	--				STP+11			 DT- 9%	DmgL+6%
	hands		=	"Malignance Gloves",	--				STP+12			 DT- 5%	DmgL+4%
	legs		=	"Malignance Tights",	--				STP+10			 DT- 7%	DmgL+5%
	feet		=	"Malignance Boots",		--				STP+ 9			 DT- 4%	DmgL+2%
	neck		=	"Anu Torque",			--				STP+ 7								Ainia CollarSTP+ 8
	waist		=	"Kentarch Belt +1",		--		DA+ 3	STP+ 5
	left_ear	=	"Sherida Earring",		--		DA+ 5	STP+ 5								Suppanomimi	DW+ 5
	right_ear	=	"Dedition Earring",		--				STP+ 8
	left_ring	=	CHIR.One,				--				STP+ 6
	right_ring	=	CHIR.Two,				--				STP+ 6
	back		=	RDMCape.STP,			--				STP+10			PDT-10%
})

-- Enspell Engaged (enspell bonus)
sets.engaged.Enspell = set_combine(sets.engaged.DT, {
	ammo		=	"Coiste Bodhar",		--		DA+3	STP+3
	head		=	"Umuthi Hat",			--Sword enhancement spell damage +8
	body		=	"Malignance Tabard",	-- 								DT- 6%
	hands		=	AYAN.Hands,				--Sword enhancement spell damage +17
	legs		=	JHAK.Legs,
	feet		=	"Malignance Boots",
	neck		=	"Dls. Torque +2",
	waist		=	"Orpheus's Sash",		--
--	left_ear	=	"Lyc. Earring",			--Sword enhancement spell damage +2
--	right_ear	=	"Hollow Earring",		--Sword enhancement spell damage +3
	left_ear	=	"Telos Earring",		--		DA+ 1	STP+ 5
	right_ear	=	"Sherida Earring",		--		DA+5	STP+5
	left_ring	=	CHIR.One,				--				STP+ 6
	right_ring	=	"Ilabrat Ring",			--				STP+5			Atk/STR/DEX
	back		=	RDMCape.Ens,			--Sword enhancement spell damage +5
})

-- Subtle Blow Engaged
sets.engaged['Subtle Blow'] = set_combine(sets.engaged.DT, {
	ammo		=	"Coiste Bodhar",		--		DA+ 3	STP+ 3								Aurgelmir+1	STP+ 5
	head		=	"Malignance Chapeau",	-- 				STP+ 8			 DT- 6%	DmgL+3%
	-- body		=	"Malignance Tabard",	--				STP+11			 DT- 9%	DmgL+6%  (listed twice in his set: Volte Harness was the one used)
	body		=	"Volte Harness",		-- SB+10
	hands		=	"Malignance Gloves",	--				STP+12			 DT- 5%	DmgL+4%
	legs		=	"Malignance Tights",	--				STP+10			 DT- 7%	DmgL+5%
	feet		=	"Malignance Boots",		--				STP+ 9			 DT- 4%	DmgL+2%
	neck		=	"Clotharius Torque",	-- SB+ 4
	waist		=	"Kentarch Belt +1",		--		DA+ 3	STP+ 5
	left_ear 	=	"Sherida Earring",		-- SB2+5
	right_ear	=	"Digni. Earring",		-- SB+ 5
	left_ring	=	CHIR.One,				-- SB+10		STP+ 6
	right_ring	=	CHIR.Two,				-- SB+10		STP+ 6
	back		=	RDMCape.STP,			--				STP+10			PDT-10%
})

-- ───────────────────────────────────────────────────────────────────────────
-- Dual Wield Variants (sub weapon not in sets.shields)
-- ───────────────────────────────────────────────────────────────────────────

-- Refresh Dual Wield (MP refresh while dual wielding)
sets.engaged['Refresh DT'].DW = set_combine(sets.engaged['Refresh DT'], {
	ammo		=	"Coiste Bodhar",		-- 		DA+3	STP+3
	head		=	"Malignance Chapeau",	-- 				STP+ 8 			 DT- 6%	DmgL+3%
	body		=	EMPY.Body,				-- 								 DT-14%	Refresh+ 4
	hands		=	"Malignance Gloves",	-- 				STP+12 			 DT- 5%	DmgL+4%
	legs		=	"Malignance Tights",	-- 				STP+10 			 DT- 7%	DmgL+5%
	feet		=	"Malignance Boots",		-- 				STP+ 9			 DT- 4%	DmgL+2%
	neck		=	"Anu Torque",			--				STP+7
	waist		=	"Sailfi Belt +1",		--		DA+5			TA+2
	left_ear	=	"Suppanomimi",			-- DW+5
	right_ear	=	"Sherida Earring",		-- 		DA+5	STP+5
	left_ring	=	"Hetairoi Ring",		--						TA+2
	right_ring	=	"Ilabrat Ring",			--				STP+5								Atk/STR/DEX
	back		=	RDMCape.TP,				-- 				STP+10			PDT-10%
})

-- TP Dual Wield (TP gain with dual wield)
sets.engaged['Store TP'].DW = set_combine(sets.engaged['Store TP'], {
	ammo		=	"Coiste Bodhar",		--		DA+ 3	STP+ 3								Aurgelmir+1	STP+ 5
	head		=	"Malignance Chapeau",	-- 				STP+ 8			 DT- 6%	DmgL+3%
	body		=	"Malignance Tabard",	--				STP+11			 DT- 9%	DmgL+6%
	hands		=	"Malignance Gloves",	--				STP+12			 DT- 5%	DmgL+4%
	legs		=	"Malignance Tights",	--				STP+10			 DT- 7%	DmgL+5%
	feet		=	"Malignance Boots",		--				STP+ 9			 DT- 4%	DmgL+2%
	neck		=	"Anu Torque",			--				STP+ 7								Ainia CollarSTP+ 8
	waist		=	"Reiki Yotai",			-- DW+7			STP+ 4
	left_ear	=	"Telos Earring",		--		DA+ 1	STP+ 5								Suppanomimi	DW+ 5
	right_ear	=	"Dedition Earring",		--				STP+ 8
	left_ring	=	"Chirich Ring +1",		--				STP+ 6
	right_ring	=	"Ilabrat Ring",			--				STP+ 5								Chirich +1  STP+ 6
	back		=	RDMCape.STP,			--				STP+10			PDT-10%
})

-- DT Dual Wield (defensive melee with dual wield gear)
sets.engaged.DT.DW = set_combine(sets.engaged.DT, {
	ammo		=	"Coiste Bodhar",		--		DA+3	STP+3
	head		=	EMPY.Head,			-- DT- 9%
	body		=	EMPY.Body,			-- DT-13%
	hands		=	"Bunzi's Gloves",	-- DT- 8%
	legs		=	"Nyame Flanchard",	-- DT- 8%
	feet		=	"Nyame Sollerets",	-- DT- 7%
	neck		=	"Anu Torque",			--				STP+7
	waist		=	"Sailfi Belt +1",		--		DA+5			TA+2
	left_ear	=	"Suppanomimi",			-- DW+5
	right_ear	=	"Sherida Earring",		--		DA+5	STP+5
	left_ring	=	"Hetairoi Ring",		--						TA+2
	right_ring	=	"Ilabrat Ring",			--				STP+5			Atk/STR/DEX
	back		=	RDMCape.TP,				--				STP+10			PDT-10%
})

-- Enspell Dual Wield (enspell bonus with dual wield)
sets.engaged.Enspell.DW = set_combine(sets.engaged.Enspell, {
	ammo		=	"Coiste Bodhar",		--		DA+3	STP+3
	head		=	"Umuthi Hat",			--Sword enhancement spell damage +8
	body		=	"Nyame Mail",	-- 								DT- 6%
	hands		=	AYAN.Hands,				--Sword enhancement spell damage +17
	legs		=	"Nyame Flanchard",
	feet		=	"Carmine Greaves +1",
	neck		=	"Clotharius Torque",
	waist		=	"Orpheus's Sash",		--
--	left_ear	=	"Lyc. Earring",			--Sword enhancement spell damage +2
--	right_ear	=	"Hollow Earring",		--Sword enhancement spell damage +3
	left_ear	=	"Suppanomimi",			-- DW+5
	right_ear	=	"Sherida Earring",		--		DA+5	STP+5
	left_ring	=	"Hetairoi Ring",		--
	right_ring	=	"Petrov Ring",			--				STP+5			Atk/STR/DEX
	back		=	RDMCape.Ens,			--Sword enhancement spell damage +5
})

-- ═══════════════════════════════════════════════════════════════════════════
-- PRECAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.precast = {}
sets.precast.JA = {}

-- • Fast Cast (generic - maximize Fast Cast % for all spells)
-- Target: 80% Fast Cast cap (RDM gets 30% from job traits = need 50% from gear)
sets.precast.FC = {
	ammo		=	"Crepuscular Pebble",		--	 DT- 3%
	head		=	AF.Head,			--FC+16% |
	body		=	RELIC.Body,			--FC+15% |
	hands		=	EMPY.Hands,			--			 DT-11%
	legs		=	"Nyame Flanchard",	--			 DT- 8%
	feet		=	"Nyame Sollerets",	--			 DT- 7%
	neck		=	"Baetyl Pendant",	--FC+ 4%
	waist		=	"Embla Sash",		--FC+ 5%
	left_ear	=	"Loquac. Earring",	--FC+ 2%
	right_ear	=	"Malignance Earring",
	left_ring	=	"Kishar Ring",		--FC+ 4%
	right_ring	=	"Murky Ring",	--			 DT-10%
	back		=	RDMCape.Idle,		--			PDT-10%   (was nil: RDMCape.idle)
}--									Total : +46%	PDT-49%

sets.precast.FC['Enhancing Magic'] = set_combine(sets.precast.FC, {
	waist		=	"Siegel Sash",-- -8%
})
-- His key was 'Stonekin', never looked up: Stoneskin got FC['Enhancing Magic'],
-- which stays the base here so the other slots keep their Fast Cast
sets.precast.FC['Stoneskin'] = set_combine(sets.precast.FC['Enhancing Magic'], {
	main		=	"Pukulatmuj +1",-- -11% Casting Time
	sub			=	"Sacro Bulwark",
	head		=	"Umuthi Hat",	-- -15% Casting Time
	legs		=	"Doyen Pants",	-- -10% Casting Time
})

-- Special Spells
sets.precast.FC['Dispelga'] = set_combine(sets.precast.FC, {main="Daybreak", sub="Ammurapi Shield"})

-- His "sets.precast.cure" ("Curing Precast, Cure Spell Casting time -"): built on
-- sets.precast.casting, which his file never defined (skipped by set_combine), and
-- named in lower case, which Mote never looks up, so it never went on. Written under the names Mote
-- reads for Cure (spell map "Cure") and Curaga, on his Fast Cast set.
sets.precast.FC.Cure = set_combine(sets.precast.FC, {
    -- sub="Sors Shield",
    back="Disperser's Cape",
})
sets.precast.FC.Curaga = sets.precast.FC.Cure
sets.precast.FC['Impact'] = set_combine(sets.precast.FC, {body="Crepuscular Cloak"})

-- Job Abilities
-- ───────────────────────────────────────────────────────────────────────────

-- • Chainspell (2-hour ability - instant cast magic for 1 minute)
sets.precast.JA['Chainspell'] = {
    body = 'Vitiation Tabard +3'
}
-- • Convert (swaps HP and MP values - useful for emergency MP recovery)
sets.precast.JA["Convert"] = {--        1760 HP+912 = 3284 HP				--
	main		= "Murgleis",			--HP+
	sub			= "Evalach +1",			--HP+177
	ammo		= "Happy Egg",			--HP+    ( 1%)
	head		= "Nyame Helm",			--HP+ 91
	body		= "Nyame Mail",			--HP+136 | "Adamantite Armor",	--HP+182
	hands		= "Nyame Gauntlets",	--HP+ 91 | "Telchine Gloves",	--HP+102
	legs		= "Nyame Flanchard",	--HP+114
	feet		= "Llwyd's Clogs",		--HP+105 ( 4%)
	neck		= "Unmoving Collar +1",	--HP+200
	waist		= "Plat. Mog. Belt",	--HP+295 (10%)					--+10%
--	back		= "Moonbeam Cape",		--HP+250
	left_ear	= "Etiolation Earring",	--HP+ 50 | "Tuisto Earring",	--HP+150
	right_ear	= "Odnowa Earring +1",	--HP+110
	left_ring	= "Gelatinous Ring +1",		--HP+ 60 | "Meridian Ring",		--HP+ 90
	right_ring	= "Ilabrat Ring", --HP+125
}

-- ═══════════════════════════════════════════════════════════════════════════
-- MIDCAST SETS
-- ═══════════════════════════════════════════════════════════════════════════

sets.midcast = {}

-- His "sets.midcast.casting": no code looks it up, kept as the base of Healing Magic
local Casting = {
	main		=	"Maxentius",
	sub			=	"Ammurapi Shield",
	ammo		=	"Pemphredo Tathlum",
	head		=	EMPY.Head,
	body		=	EMPY.Body,
	hands		=	EMPY.Hands,
	legs		=	EMPY.Legs,
	feet		=	EMPY.Feet,
	neck		=	"Dls. Torque +2",
	waist		=	"Refoccilation Stone",
	back		=	"Aurist's Cape +1",
	left_ear	=	"Loquac. Earring",
	right_ear	=	"Etiolation Earring",
	left_ring	=	"Kishar Ring",
	right_ring	=	"Murky Ring",		--DT-3%
}
-- ───────────────────────────────────────────────────────────────────────────
-- Elemental Magic (Nuking) - NukeMode: FreeNuke / Magic Burst
-- ───────────────────────────────────────────────────────────────────────────
sets.midcast['Elemental Magic'] = {}
sets.midcast['Elemental Magic'].Helix = {
	head		=	"Pixie Hairpin +1",
}

sets.midcast['Elemental Magic'].FreeNuke = set_combine(sets.midcast['Elemental Magic'], {
	main		=	"Daybreak",			--			MAB+40	Macc+40 > "Bunzi's Rod",	--(R5+) INT+30	MAB+40	Macc+40
	sub			=	"Ammurapi Shield",	--INT+13	MAB+38	Macc+38
	ammo		=	"Sroda Tathlum",
	--				"Pemphredo Tathlum",--INT+4		MAB+ 4	Macc+ 8	Conserve MP+4
	head		=	EMPY.Head,			--INT+33	MAB+51	Macc+51
	body		=	EMPY.Body,			--INT+47	MAB+54	Macc+64
	hands		=	EMPY.Hands,			--INT+33	MAB+52	Macc+25
	legs		=	EMPY.Legs,			--INT+43	MAB+53	Macc+53
	feet		=	RELIC.Feet,			--INT+33	MAB+39	Macc+42
	neck		=	"Baetyl Pendant",	--			MAB+13
	waist		=	"Refoccilation Stone",--		MAB+10	Macc+ 4
	back		=	RDMCape.INT,		--INT+30	MAB+10	Macc+20
	left_ear	=	"Friomisi Earring",	--			MAB+10
	right_ear	=	"Malignance Earring",--NT+8		MAB+ 6	Macc+10
	left_ring	=	"Freke Ring",		--INT+16			Macc+15
	right_ring	=	"Metamor. Ring +1",	--INT+10	MAB+ 8
})

sets.midcast['Elemental Magic']['Magic Burst'] = set_combine(sets.midcast['Elemental Magic'], {
	main		=	"Bunzi's Rod",		--MB+10			INT+ 15	MAB+ 35	Macc+ 40
	sub			=	"Ammurapi Shield",	--				INT+ 13	MAB+ 38	Macc+ 38
	ammo		=	"Pemphredo Tathlum",--				INT+  4	MAB+  4	Macc+  8
	head		=	"Ea Hat +1",		--MB+ 7 MBII+ 7	INT+ 43	MAB+ 38	Macc+ 50
	body		=	"Ea Houppe. +1",	--MB+ 9 MBII+ 9	INT+ 48	MAB+ 44	Macc+ 52
	hands		=	"Amalric Gages +1",	--		MBII+ 6	INT+ 36	MAB+ 53	Macc+ 20	Skill+14
	legs		=	"Ea Slops +1",		--MB+ 8	MBII+ 8	INT+ 48	MAB+ 41	Macc+ 51
	feet		=	"Ea Pigaches +1",	--MB+ 5	MBII+ 5 INT+ 15	MAB+ 32	Macc+ 48
	neck		=	"Mizu. Kubikazari",	--MB+10			INT+  4	MAB+  8
	waist		=	"Sacro Cord",		--				INT+  8	MAB+  8	Macc+  8
	--	waist		=	"Orpheus's Sash",
	left_ear	=	"Friomisi Earring",	--						MAB+ 10
	right_ear	=	"Malignance Earring",--				INT+  8	MAB+  6	Macc+ 10
	left_ring	=	"Mujin Band",    	--		MBII+ 5
	right_ring	=	"Freke Ring",		--				INT+ 10	MAB+  8
	back		=	RDMCape.INT,		--				INT+ 30	MAB+ 10	Macc+ 20
	})--						Total:	  	  MB+49 MBII+40	INT+246	MAB+264	Macc+263

-- ───────────────────────────────────────────────────────────────────────────
-- Healing Magic (Cures)
-- ───────────────────────────────────────────────────────────────────────────
sets.midcast['Healing Magic'] = set_combine(Casting, {
	main		=	Grioavolr.ConserveMP,--							Conserve MP+ 15
	sub			=	"Giuoco Grip",		--							Conserve MP+  4	PDT- 1%
	ammo		=	"Regal Gem",		--					MND+ 7
	head		=	VANY.Cure,			-- CP+17%			MND+27	Conserve MP+  6	Enmity-6   (was nil: VANY.Head.A)
	body		=	KAYK.Body.HQ.D,		-- CP+ 6%	CP2+ 4%			Conserve MP+  7
	hands		=	KAYK.Hands.HQ.D,	-- CP+11	CP2+ 2%	MND+47	Conserve MP+  7	Enmity-6
	legs		=	VANY.Legs.C,		--			MND+ 44			Conserve MP+ 12
	feet		=	VANY.Feet.D,		--CP+10%	Skill+20		Conserve MP+  6
	neck		=	"Reti Pendant",		--							Conserve MP+  4
	waist		=	"Shinjutsu-no-Obi +1",--						Conserve MP+ 15
	left_ear	=	"Gifted Earring",	--							Conserve MP+  3
	right_ear	=	"Calamitous Earring",--							Conserve MP+  4
	left_ring	=	"Menelaus's Ring",	--CP+ 5%	Skill+15
	right_ring	=	"Mephitas's Ring +1",--			Enmity-			Conserve MP+ 15
	back		=	"Aurist's Cape +1",	--			MND+33 			Conserve MP+  5
})--							 Cure Potency+49 	CP2+ 6%	MND+	Conserve MP+103

-- Cure (single target healing)
sets.midcast.Cure = set_combine(sets.midcast['Healing Magic'], {
	-- main		=	"Bunzi's Rod",		--MB+10			INT+ 15	MAB+ 35	Macc+ 40
})

-- Curaga (AoE healing)
sets.midcast.Curaga = set_combine(sets.midcast['Healing Magic'], {})

-- Cure Self (self-target cure - can add defensive gear here). Worn on top of
-- the Cure set for a Cure on himself (RDM_MIDCAST, midcast_healing).
sets.midcast.CureSelf = set_combine(sets.midcast['Healing Magic'], {})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ ENFEEBLING MAGIC (DEBUFFS)                                                   │
--╰──────────────────────────────────────────────────────────────────────────────╯
sets.midcast['Enfeebling Magic'] = {
	main		=	"Murgleis",			--Macc+70
	sub			=	"Ammurapi Shield",	--Macc+38								MND+13
	ranged		=	"Ullr",				--Macc+40
	head		=	RELIC.Head,			--Macc+37	Skill +26
	body		=	AF.Body,			--Macc+55	Skill +21
	hands		=	EMPY.Hands,			--Macc+52	Skill +24 > Macc+62 Skill+29
	legs		=	CHIR.Legs.Macc,		--Macc+56	Skill +13					MND+29
	feet		=	RELIC.Feet,			--Macc+48	Skill +18							Effect+10
	neck		=	"Dls. Torque +2",	--Macc+30				Duration+25%			Effect+10
	waist		=	"Obstin. Sash",		--Macc+15				Duration+ 5%	MND+ 5
	left_ear	=	"Snotra Earring",	--Macc+10				Duration+10%	MND+ 8
	right_ear	=	"Regal Earring",	--Macc+15								MND+10
	left_ring	=	STIK.One,			--Macc+11	Skill + 8
	right_ring	=	STIK.Two,			--Macc+11	Skill + 8
	back		=	"Aurist's Cape +1",	--Macc+33	MND INT +33
}

-- Enfeebling Type Sets (picked from the spell's type in the enfeebling database)
	--		| Addle, Blind, Dispel, Distract I-II,
	--		| Inundation, Frazzle I-II, Paralyze, Poison, Sleep, Slow, Stun.
sets.midcast['Enfeebling Magic'].macc = set_combine(sets.midcast['Enfeebling Magic'], {})

-- MND & Potency
	--		| Addle II		(± 0 dMND = macc-50 | ±1000 dMND = macc-70)
	--		| Paralyze II	(-40 dMND = 14  %   | +40MND = 34  %)
	--		| Slow II		(-75 dMND = 16.5%   | +40MND = 39.1%)
sets.midcast['Enfeebling Magic'].mnd_potency = set_combine(sets.midcast['Enfeebling Magic'], {
--	sub			=	"Archduke's Shield",	--								MND+20
	ammo		=	"Regal Gem",		--MND+ 7 Macc+15	Effect+10
	body		=	EMPY.Body,			--MND+45 Macc+64	Effect+18
	-- legs		=	EMPY.Legs,			--MND+43 Macc+63
	waist		=	"Obstin. Sash",		--MND+ 5 Macc+12				Duration +5%
	left_ring	=	STIK.One,			--		 Macc+11								Skill+ 8
	right_ring	=	STIK.Two,			--		 Macc+11								Skill+ 8
--	back		=	RDMCape.MND,		--MND+30 Macc+20	Effect+10
})
-- INT & Potency"	| Blind II |
sets.midcast['Enfeebling Magic'].int_potency = set_combine(sets.midcast['Enfeebling Magic'], {
	ammo		=	"Regal Gem",		--MND+ 7 Macc+15	Effect+10
	waist		=	"Acuity Belt +1",	--INT+16 Macc+15
	back		=	RDMCape.INT,		--INT+30 Macc+20	Effect+10
})
-- Skill & Potency	| Poison II |
sets.midcast['Enfeebling Magic'].skill_potency = set_combine(sets.midcast['Enfeebling Magic'], {
	ammo		=	"Regal Gem",		--MND+7 Macc15 Effect+10
	waist		=	"Obstin. Sash",		--MND+5 Macc12 Duration +5% eventuellement skill+5
	right_ear	=	"Vor Earring",		--Skill+10
	left_ring	=	STIK.One,			--Macc+11	Skill+8
	right_ring	=	STIK.Two,			--Macc+11	Skill+8
	back		=	RDMCape.INT,		--INT+30 Macc+20	Effect+10
})
-- Skill, MND & Potency	| Distract III (cap 625 skill) | Frazzle III (cap 625 skill) |
sets.midcast['Enfeebling Magic'].skill_mnd_potency = set_combine(sets.midcast['Enfeebling Magic'], {
		ammo		=	"Regal Gem",		--Effect+10	Macc+15	MND+ 7
	--	body		=	EMPY.Body,			--Effect+18	Macc+64	MND+45 @ML34 EMPY.Hands+3/Obstin. Sash skill+5
		waist		=	"Obstin. Sash",		--			Macc+14 MND+ 5	Skill+ 5	Duration +5%
		back		=	RDMCape.WS.MNDma,	--Effect+10	Macc+20	MND+30
		left_ring	=	STIK.One,			--			Macc+11	MND+ 8	Skill+ 8
		right_ring	=	STIK.Two,			--			Macc+11	MND+ 8	Skill+ 8
		right_ear	=	"Vor Earring",		--							Skill+10
	--				****************** Other options to acheve 625 (Frazzle III) ******************
	--	main		=	"Contemplator +1"	--										Skill+20 (+20)
	--	sub			=	"Mephitis Grip"		--										Skill+ 5 (+ 5) Macc-33
	--	hands		=	EMPY.Hands			--										Skill+19 (+ 3) Macc-29
	--	neck		=	"Incanter's Torque",--										Skill+10 (+10) Macc-30 Duration-25%
	--	left_ear	=	"Enfeebling Earring",--										Skill+ 3 (+ 3) Macc-10 Duration-10%
})

-- Enfeeb Potency | Dias, Bios, Gravity II.
sets.midcast['Enfeebling Magic'].potency = set_combine(sets.midcast['Enfeebling Magic'], {
		ammo		=	"Regal Gem",		--Potency +10%
		body		=	EMPY.Body,			--Potency +14%
		feet		=	RELIC.Feet,			--Potency +10%
		back		=	RDMCape.INT,		--Potency +10%
		neck		=	"Dls. Torque +2",	--Potency +10%
		right_ear	=	"Malignance Earring",
})

-- EnfeebleMode on top of the potency type (type.mode, looked up before the type)
sets.midcast['Enfeebling Magic'].potency.Acc = set_combine(sets.midcast['Enfeebling Magic'].potency, {})
sets.midcast['Enfeebling Magic'].potency.Skill = set_combine(sets.midcast['Enfeebling Magic'].potency, {
	hands		=	"Regal Cuffs",		--Duration +20%
})
-- Type G : Duration | Bind, Break, Poisonga, Silence, Sleepga, Sleep II
sets.midcast['Enfeebling Magic'].duration = set_combine(sets.midcast['Enfeebling Magic'], {
	head		=	RELIC.Head,			--Duration +15s
	hands		=	"Regal Cuffs",		--Duration +20%
	waist		=	"Obstinate Sash",	--Duration +5% | Odyssey
	left_ear	=	"Snotra Earring",	--Duration +10%
	left_ring	=	"Kishar Ring",		--Duration +10%
})

-- EnfeebleMode sets (only used for a spell with no type set)
sets.midcast['Enfeebling Magic'].Potency = sets.midcast['Enfeebling Magic']
sets.midcast['Enfeebling Magic'].Acc = sets.midcast['Enfeebling Magic']

-- Enfeebling with Saboteur active (equipped on top of the chosen set)
sets.midcast['Enfeebling Magic'].Saboteur = {hands = EMPY.Hands}

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ ENHANCING MAGIC (BUFFS)                                                      │
--╰──────────────────────────────────────────────────────────────────────────────╯
--	Base Enhancing Magic set | Duration+ | Duration
	-- Apparently Haste 2, Flurry 2 et Refresh 3
sets.midcast['Enhancing Magic'] = {
	main		=	Colada.Enhancing,	--			Duration+ 4%
	sub			=	"Ammurapi Shield",	--			Duration+10%
	head		=	TELC.Head.Enh,		--			Duration+10%
	body		=	RELIC.Body,			--Skill+23	Duration+15%
	hands		=	AF.Hands,			--			Duration+20%
	legs		=	TELC.Legs.Enh,		--			Duration+10%
	feet		=	EMPY.Feet,			--Skill+25	Duration+35%
	neck		=	"Dls. Torque +2",	--			Duration+25%
	waist		=	"Embla Sash",		--			Duration+10%
	left_ear	=	"Mimir Earring",	-- Skill+10
	right_ear	=	EMPY.Ear,	--			Duration+ 7% +2 +9%
	left_ring	=	STIK.One,			-- Skill+ 8
	right_ring	=	STIK.Two,			-- Skill+ 8
	back		=	RDMCape.Ens			--Skill+10	Duration+20%}
}

-- For Potency spells like Temper, Enspells, Gain(cap@500)| Skill+
-- No code looks this one up by itself: it is the base of Gain, Enspell,
-- BarElement, BarAilment, Temper, Protect, Shell and Aquaveil below.
sets.midcast['Enhancing Magic'].Potency = {
	main		=	"Pukulatmuj +1",		-- Skill+11
	sub			=	"Forfend +1",			-- Skill+10
	head		=	"Befouled Crown",		-- Skill+16
	body		=	RELIC.Body,				-- Skill+23
	hands		=	RELIC.Hands,			-- Skill+24
	legs		=	AF.Legs,				-- Skill+21
	feet		=	EMPY.Feet,				-- Skill+35
	neck		=	"Incanter's Torque",	-- Skill+10 > "Hoxne Torque" -- Skill+30
	waist		=	"Olympus Sash",			-- Skill+ 5
	left_ear	=	"Mimir Earring",		-- Skill+10
	right_ear	=	"Andoaa Earring",		-- Skill+ 5
	left_ring	=	STIK.One,				-- Skill+ 8
	right_ring	=	STIK.Two,				-- Skill+ 8
	back		=	RDMCape.Ens				-- Skill+10	Duration+15%
}

-- Enhancing on Others (with Composure - duration bonus)
sets.midcast['Enhancing Magic'].Composure = set_combine(sets.midcast['Enhancing Magic'], {
	-- AF hands better than empy bonus
		head		=	EMPY.Head,
		body		=	EMPY.Body,
        legs		=	EMPY.Legs,
		feet		=	EMPY.Feet,
})

-- Spell families (enhancing database), under the skill
sets.midcast['Enhancing Magic'].Gain = sets.midcast['Enhancing Magic'].Potency
sets.midcast['Enhancing Magic'].Enspell = sets.midcast['Enhancing Magic'].Potency
sets.midcast['Enhancing Magic'].BarElement = sets.midcast['Enhancing Magic'].Potency
sets.midcast['Enhancing Magic'].BarAilment =  set_combine(sets.midcast['Enhancing Magic'].Potency, {
	neck		=	"Sroda Necklace",	--			Duration-50%
})
sets.midcast.Temper = sets.midcast['Enhancing Magic'].Potency
sets.midcast.Protect = set_combine(sets.midcast['Enhancing Magic'].Potency, {
	right_ring = "Sheltered Ring"
})
sets.midcast.Shell = set_combine(sets.midcast['Enhancing Magic'].Potency, {
	right_ring = "Sheltered Ring"
})
-- Refresh
sets.midcast.Refresh = set_combine(sets.midcast['Enhancing Magic'], {
	head		=	AMAL.Head.HQ.D,	-- Refresh+ 2
    body		=	AF.Body,
    legs		=	EMPY.Legs,
	right_ear	=	"Malignance Earring",	-- FC+ 4%
	left_ring	=	"Kishar Ring",			-- FC+ 4%
	right_ring	=	"Naji's Loop",			-- FC+ 1%
})
sets.midcast.Refresh.Composure = set_combine(sets.midcast['Enhancing Magic'].Composure, sets.midcast.Refresh)

-- Regen
sets.midcast.Regen = set_combine(sets.midcast['Enhancing Magic'], {
    main = 'Bolelabunga',
    body = 'Telchine Chas.',
	-- feet = "Bunzi's Sabots",
})
-- (his base, sets.midcast['Enhancing Magic'].others, did not exist: set_combine skips it, so
-- his set was his Regen set; same pieces here)
sets.midcast.Regen.Composure = set_combine(sets.midcast['Enhancing Magic'].Composure, sets.midcast.Regen)

-- Phalanx (self, Phalanx+)
sets.midcast.Phalanx = set_combine(sets.midcast['Enhancing Magic'], {
	main		=	"Sakpata's Sword",
	-- head		=	CHIR.Head.Phalanx,
	-- body		=	CHIR.Body.Phalanx,
	hands		=	CHIR.Hands.Phalanx,
	legs		=	CHIR.Legs.Phalanx,
	feet		=	CHIR.Feet.Phalanx,
})
-- Phalanx (others, Composure active, duration+)
sets.midcast.Phalanx.Composure = set_combine(sets.midcast['Enhancing Magic'].Composure, {})

-- Stoneskin
sets.midcast.Stoneskin = set_combine(sets.midcast['Enhancing Magic'], {
	-- left_ear = 'Earthcry Earring',
	legs = "Shedir Seraweels",
    neck = 'Nodens Gorget',
    waist = 'Siegel Sash'
})
sets.midcast.Aquaveil = set_combine(sets.midcast['Enhancing Magic'].Potency, {
-- 	--								   Merits Sird+10%
	main		=	"Sakpata's Sword",		--			DT-10%
	sub			=	"Sacro Bulwark",		--Sird+ 7%	DT-10%
	ammo		=	"Staunch Tathlum",		--Sird+10%	DT- 2%
	head		=	AMAL.Head.HQ.D,			--					Aquaveil+ 2
	body		=	"Ros. Jaseran +1",		--Sird+25%	DT- 5%
	hands		=	"Regal Cuffs",			--					Aquaveil+ 2
	legs		=	"Shedir Seraweels",		--	 				Aquaveil+ 1
	feet		=	"Amalric Nails +1",		--Sird+16%
	neck		=	"Loricate Torque +1",	--Sird+ 5%	DT- 6%
	waist		=	"Emphatikos Rope",		--Sird+12%			Aquaveil+ 1
	left_ear	=	"Alabaster Earring",	--			DT- 5%
	right_ear	=	"Odnowa Earring +1",	--			DT- 3%
	left_ring	=	"Freke Ring",			--Sird+10%
	right_ring	=	"Murky Ring",			--Sird+ 3%	DT-10%
	back		=	"Solitaire Cape",		--Sird+ 8%
})--									Total :	 +103%	DT-51%	Aquaveil+ 6

sets.midcast.Spikes = set_combine(sets.midcast['Enhancing Magic'], {})


--╭──────────────────────────────────────────────────────────────────────────────╮
--│ DARK MAGIC                                                                   │
--╰──────────────────────────────────────────────────────────────────────────────╯

-- Generic Dark Magic (Magic Accuracy focus, uses the Enfeebling base)
sets.midcast['Dark Magic'] = set_combine(sets.midcast['Enfeebling Magic'], {})

-- Impact (AoE Magic Defense Down - uses full Elemental Magic set)
-- Note: the Crepuscular Cloak goes on in precast (sets.precast.FC['Impact'])
sets.midcast.Impact = set_combine(sets.midcast['Elemental Magic'], {})

-- Drain (HP absorption)
sets.midcast.Drain = {
	main		=	"Murgleis",			--Macc+70
	sub			=	"Ammurapi Shield",	--Macc+38
	ranged		=	"Ullr",				--Macc+40
	head		=	RELIC.Head,			--Macc+37
	body		=	AF.Body,			--Macc+55
	hands		=	EMPY.Hands,			--Macc+52
	legs		=	CHIR.Legs.Macc,		--Macc+56
	feet		=	RELIC.Feet,			--Macc+48
	neck		=	"Erra Pendant",		--Macc+17	Skill +10	Effect+ 5%
	waist		=	"Obstin. Sash",		--Macc+15
	left_ear	=	"Snotra Earring",	--Macc+10
	right_ear	=	"Regal Earring",	--Macc+15
	left_ring	=	STIK.One,			--Macc+11
	right_ring	=	"Excelsis Ring",	--	Enhances effect
	back		=	"Aurist's Cape +1",	--Macc+33	INT +33
}

-- Aspir (MP absorption)
sets.midcast.Aspir = sets.midcast.Drain
sets.midcast['Dispelga'] = set_combine(sets.midcast['Enfeebling Magic'], {
	main="Daybreak",
	sub="Ammurapi Shield"
})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ WEAPONSKILL SETS                                                             │
--╰──────────────────────────────────────────────────────────────────────────────╯

-- Weaponskills
sets.precast.WS = {
	ammo		=	"Oshasha's Treatise",
    head		=	'Nyame Helm',
    body		=	'Nyame Mail',
    hands		=	'Nyame Gauntlets',
    legs		=	'Nyame Flanchard',
    feet		=	EMPY.Feet,
    neck		=	'Fotia Gorget',
    waist		=	"Fotia Belt",
	left_ear	=	"Moonshade Earring",
	right_ear	=	"Ishvara Earring",	-- WSD+ 2
	left_ring   =  	"Epaminondas's Ring",--WSD+ 5
	right_ring	=	"Cornelia's Ring",	-- WSD+10
	back		=	RDMCape.WS.STR,		-- WSD+10
    }

-- Sword : Physical
-- Twofold attack | Physical | STR50% MND50% | 1000 TP fTP 4.0 | 2000 TP fTP 10.25 | 3000 TP fTP 13.75 |
sets.precast.WS["Savage Blade"] = {
--	ammo		=	"Regal Gem",
	ammo		=	"Oshasha's Treatise",--WSD+ 3
	head		=	"Nyame Helm",			--RELIC.Head,			-- WSD+ 6	STR+
	body		=	RELIC.Body,
	hands		=	"Nyame Gauntlets",	-- WSD+ 8
	legs		=	"Nyame Flanchard",	-- WSD+ 7 STR+43 MND+32 Atk+50 Acc+40
	feet		=	EMPY.Feet,			-- WSD+12
--	neck		=	"Dls. Torque +2",
	neck		=	"Rep. Plat. Medal",
	waist		=	"Sailfi Belt +1",
	left_ear	=	"Moonshade Earring",
	right_ear	=	"Ishvara Earring",	-- WSD+ 2
	left_ring   =  	"Sroda Ring",--WSD+ 5
	right_ring	=	"Cornelia's Ring",	-- WSD+10
	back		=	RDMCape.WS.STR,		-- WSD+10
}
sets.precast.WS["Knights of Round"] = set_combine(sets.precast.WS["Savage Blade"], {})	--	 40% STR / 40% MND	Physical
sets.precast.WS["Death Blossom"] = set_combine(sets.precast.WS["Savage Blade"], {		--	 50% MND / 30% STR	Physical
	ammo		=	"Regal Gem",
	back		=	RDMCape.WS.MND,
})
sets.precast.WS["Chant du Cygne"] = {-- Threefold Attack 						--  80% DEX				Physical fTP
	ammo		=	"Yetshila +1",-- 1000 TP Crit +15% | 2000 TP Crit + 25% | 3000 TP Crit +40% | DEX Crit rate/damage, DA/TA, Attack/Accuracy
	head		=	"Blistering Sallet +1",	--CrRate+10%	DEX+41
	body		=	"Malignance Tabard",
	hands		=	"Malignance Gloves",	--				DEX+56 Taeon
	legs		=	"Nyame Flanchard",		-->> RELIC.Legs,				--				DEX+22 >> Zoar Subligar
	feet		=	"Malignance Boots",		-->> "Thereoid Greaves",		-- CrRate+4% Crdmg+5% DEX+28
	neck		=	"Fotia Gorget",			--
	waist		=	"Fotia Belt",			--
	left_ear	=	"Moonshade Earring",	--"Mache Earring +1",
	right_ear	=	"Sherida Earring",		--				DEX+ 5
	left_ring	=	"Begrudging Ring",			--				DEX+10
	right_ring	=	"Ilabrat Ring",		--CrRate+ 5%
	back		=	RDMCape.TP,				-- 							Cape DEX crit to get
}
sets.precast.WS["Requiescat"] = {-- Fivefold attack								--   73~85% MND 		Physical fTP
	ammo        =   "Regal Gem",
	head        =   RELIC.Head,
	body        =   EMPY.Body,
	hands       =   AF.Hands,
	legs        =   JHAK.Legs,
	feet        =   JHAK.Feet,
	neck        =   "Fotia Gorget",
	waist       =   "Fotia Belt",
	left_ear	=	"Moonshade Earring",
	right_ear	=	"Regal Earring",
	left_ring   =	"Rufescent Ring",
	right_ring  =	"Stikini Ring +1",
	back        =   RDMCape.WS.MND,
}

sets.precast.WS["Swift Blade"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	 50% STR / 50% MND	Physical fTP
sets.precast.WS["Flat Blade"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	100% STR			Physical
sets.precast.WS["Circle Blade"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	100% STR			Physical
sets.precast.WS["Vorpal Blade"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	 60% STR			Physical fTP
sets.precast.WS["Fast Blade"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	 40% STR / 40% DEX	Physical
-- Sword : Magical
sets.precast.WS["Sanguine Blade"] = {											--	 50% MND / 30% STR	Magical dSTAT INT
	ammo		=	"Pemphredo Tathlum",
				--	"Sroda Tathlum",
	head		=	"Pixie Hairpin +1",
	body		=	"Amalric Doublet +1",	--Path A
	hands		=	JHAK.Hands,
	legs		=	EMPY.Legs,
	-- legs		=	"Amalric Slops +1",		--Path A
	-- feet		=	"Amalric Nails +1",		--Path D
	feet		=	EMPY.Feet,
	neck		=	"Sibyl Scarf",
	waist		=	"Orpheus's Sash",
	left_ear	=	"Regal Earring",
	right_ear	=	"Malignance Earring",
	left_ring	=	"Archon Ring",
	right_ring	=	"Metamor. Ring +1",
	--	STIK.Two,
	back		=	RDMCape.WS.MNDma,
}
sets.precast.WS["Seraph Blade"] = set_combine(sets.precast.WS["Sanguine Blade"], {	--	 40% STR / 40% MND	Magical Light
	ammo		=--	"Pemphredo Tathlum",
	"Sroda Tathlum",
	head		=	RELIC.Head,				-- MND+42			WSD+ 6	> Nyame
	body		=	EMPY.Body,				--							> Nyame
	hands		=	JHAK.Hands,				-- MND+35	MAB+40	WSD+ 7
	-- legs		=	"Amalric Slops +1",		--Path A					> EMPY.Legs,
	legs		=	EMPY.Legs,
	feet		=	EMPY.Feet,				-- MND+32	MAB+50	WSD+12
	neck		=	"Dls. Torque +2",		--
				--	"Baetyl Pendant",		-- 			MAB+13
				--	"Fotia Gorget",
	waist		=	"Orpheus's Sash",
	back		=	RDMCape.WS.MNDma,		-- MND/Macc/Mdmg/WSD
	left_ear	=	"Moonshade Earring",	-- TP Bonus+250
	right_ear	=	"Malignance Earring",	-- MND+ 8	MAB+ 8
	left_ring	=	"Metamor. Ring +1",		--"Weatherspoon Ring",	--(BiS)
	right_ring	=	"Cornelia's Ring",
})
sets.precast.WS["Shining Blade"] = set_combine(sets.precast.WS["Sanguine Blade"], {})	--	 40% STR / 40% MND	Magical
sets.precast.WS["Burning Blade"] = set_combine(sets.precast.WS["Sanguine Blade"], {})	--	 40% STR / 40% INT	Magical
sets.precast.WS["Red Lotus Blade"] = set_combine(sets.precast.WS["Sanguine Blade"], {--	 40% STR / 40% INT	Magical
	head		=	RELIC.Head,				-- WSD+ 6
	back		=	RDMCape.INT,			-- INT MAB
	left_ear	=	"Regal Earring",		-- INT+10
	right_ring	=	"Cornelia's Ring",			-- WSD+ 3
})
-- Club	: Physical
sets.precast.WS["Black Halo"] = {												--	 70% MND / 30% STR	Physical
	ammo        =   "Crepuscular Pebble",--"Coiste Bodhar",
	head        =   RELIC.Head,
	body        =   "Nyame Mail",
	hands       =   AF.Hands,
	legs        =   "Nyame Flanchard",
	feet        =   EMPY.Feet,
	-- neck        =   "Dls. Torque +2",
	neck        =   "Rep. Plat. Medal",--<<"Null Loop",
	waist       =   "Sailfi Belt +1",
	left_ear    =   "Sherida Earring",-->>"Hoxne Earring",
	right_ear   =   "Moonshade Earring",--<<"Regal Earring",
	left_ring   =   "Epaminondas's Ring",
	right_ring  =   "Cornelia's Ring",--<<"Sroda Ring",
	back        =   RDMCape.WS.MND,
}

--Club : Physical
sets.precast.WS["Judgment"] = set_combine(sets.precast.WS["Savage Blade"], {})			--	 50% STR / 50% MND	Physical fTP
sets.precast.WS["Brainshaker"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	100% STR 			Physical
sets.precast.WS["Skullbreaker"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	100% STR 		 	Physical
sets.precast.WS["True Strike"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	100% STR 			Physical
-- Club : Magical
sets.precast.WS["Shining Strike"] = set_combine(sets.precast.WS["Savage Blade"], {})	--	 40% STR / 40% MND	Magical
sets.precast.WS["Seraph Strike"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	 40% STR / 40% MND	Magical

-- Dagger : Physical
sets.precast.WS["Mercy Stroke"] = set_combine(sets.precast.WS["Savage Blade"], {})		--	 80% STR			Physical
sets.precast.WS["Evisceration"] = set_combine(sets.precast.WS["Chant du Cygne"], {})
-- Dagger : Magical
sets.precast.WS["Aeolian Edge"] = set_combine(sets.precast.WS["Sanguine Blade"], {
--	ammo		=	"Pemphredo Tathlum",
	ammo		=	"Sroda Tathlum",
	head		=	"Nyame Helm",
	body		=	"Nyame Mail",
	hands		=	"Nyame Gauntlets",
	legs		=	"Nyame Flanchard",
	feet		=	"Nyame Sollerets",
	neck		=	"Baetyl Pendant",
	waist		=	"Orpheus's Sash",
	left_ear	=	"Friomisi Earring",
	right_ear	=	"Malignance Earring",
	left_ring	=	"Acumen Ring",
	right_ring	=	"Metamorph Ring +1",
	back		=	RDMCape.INT,
})
--╭──────────────────────────────────────────────────────────────────────────────╮
--│ MOVEMENT SETS                                                                │
--╰──────────────────────────────────────────────────────────────────────────────╯

sets.MoveSpeed = {legs = 'Carmine Cuisses +1'}
-- Adoulin Movement (City-specific speed boost)
sets.Adoulin = set_combine(sets.MoveSpeed, {body = "Councilor's Garb"})

--╭──────────────────────────────────────────────────────────────────────────────╮
--│ BUFF SETS                                                                    │
--╰──────────────────────────────────────────────────────────────────────────────╯
sets.buff = {}

-- Doom: Nicander's Necklace removes it, the rest resists it
sets.buff.Doom = {
    neck = "Nicander's Necklace",
    -- left_ring = "Purity Ring",
    right_ring = "Blenmot's Ring +1",
    waist = "Gishdubar Sash",
}

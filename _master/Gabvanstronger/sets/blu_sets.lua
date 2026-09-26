---============================================================================
--- BLU Equipment Sets - Gabvanstronger
---============================================================================
--- Gab's BLU gear: init_gear_sets of his Gabvanstronger/BLU.lua, copied as it
--- was (his layout, his comments), under the set names he used: they are the
--- names our BLU code reads (Mote's own names). His gear tables (AF, RELIC,
--- EMPY, BLUCape, HERC, CARM, AMAL, ADHE, TELC, JHAK, STIK...) come from
--- sets/0_AugGear_Gabvanstronger.lua, under his own names.
---
--- How our BLU picks these sets (shared/jobs/blu):
---   * Idle: sets.idle[IdleMode] (Normal = sets.idle), then MainWeapon /
---     SubWeapon, then sets.MoveSpeed while moving outside a city.
---   * Engaged: sets.engaged, .SW when single wielding (nothing, a shield or
---     a grip in the off hand), then [OffenseMode] when that level has it.
---   * Weaponskills and Fast Cast: Mote, as in his file (sets.precast.WS[name]
---     [WeaponskillMode], sets.precast.FC['Blue Magic']).
---   * Blue Magic midcast: sets.midcast[spell] (Sound Blast, Restoral, White
---     Wind), else sets.midcast['Blue Magic'][category][CastingMode] /
---     [category]; the categories are his blue_magic_maps
---     (config/blu/BLU_SPELL_MAP.lua). Then sets.buff[...] for Burst / Chain
---     Affinity, Convergence, Diffusion, Efflux, and sets.self_healing for a
---     Healing spell on himself.
---   * Weapons: equip_without_set (config/WEAPON_CONFIG.lua): his WeaponSet /
---     SubSet values are plain weapons, no set needed. 'Free' keeps the weapon
---     worn, as his check_weaponsets did (it equipped {main = 'Free'}).
---
--- Changed from his file (and why), marked where they are:
---   * Enmity ammo "Sapiens Orb" -> "Sapience Orb" (no item of that name;
---     his Fast Cast sets spell it right)
---   * sets.precast.WS.acc -> .Acc (Mote reads the mode name, lower case
---     never matched)
---   * Chant du Cygne feet HERC.Feet.TA commented: nil when his files ran
---
--- @file    sets/blu_sets.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
---============================================================================

include('sets/0_AugGear_Gabvanstronger.lua')

sets = {}

--Ranged Weapons (RangedSet mode of config/blu/BLU_CUSTOM.lua)
	sets['Pull']				= {range=	"Albin Bane"}
--Capacity Point cape (CP mode of config/blu/BLU_CUSTOM.lua, his 0_Shared.lua sets.CP)
	sets.CP						= {back	=	CAPACITY.Cape}

    sets.buff = {}
    sets.buff['Burst Affinity'] = {legs=AF.Legs, feet=EMPY.Feet}
    sets.buff['Chain Affinity'] = {head=EMPY.Head, feet=AF.Feet}
    sets.buff.Convergence		= {head=RELIC.Head}
    sets.buff.Diffusion			= {feet=RELIC.Feet}
    sets.buff.Enchainment		= {body=RELIC.Body}	-- never worn: "Enchainment" is no buff nor ability in the game
    sets.buff.Efflux			= {legs=EMPY.Legs}

	sets.buff.Doom				= {}	-- no Doom set in his file

	sets.MoveSpeed 				= {legs = "Carmine Cuisses +1"}
--
-- Precast JAs, Fastcast, Casting time reduction, Snapshot ================================================== --
--	-- Precast sets to enhance JAs
	sets.precast = {}
	sets.precast.JA = {}
	sets.precast.JA['Azure Lore'] = {hands=RELIC.Hands}
	-- Waltz set (chr and vit)
	sets.precast.Waltz = {}
	-- Don't need any special gear for Healing Waltz.
	sets.precast.Waltz['Healing Waltz'] = {}
	-- Fast cast sets for spells
	sets.precast.FC = {
		ammo		=	"Sapience Orb",			--FC+ 2%
		head		=	HERC.Head.FC,			--FC+13%
		body		=	RELIC.Body,				--FC+ 9%
		hands		=	"Leyline Gloves",		--FC+ 7% 	> Perf aug = FC+ 8%
		legs		=	"Psycloth Lappas",		--FC+ 7%
		feet		=	CARM.Feet.HQ.B,			--FC+ 8%
		neck		=	"Baetyl Pendant",		--FC+ 4%
	--	waist				Witful Belt +3%
		back		=	BLUCape.Eva,			--FC+10%
		left_ear	=	"Loquac. Earring",		--FC+ 2%
		right_ear	=	"Etiolation Earring",	--FC+ 1%
		left_ring	=	"Kishar Ring",			--FC+ 4%
		right_ring	=	"Naji's Loop",			--FC+ 1%
	}--									Total :   FC+72% + Sakpata Sword

    sets.precast.FC['Blue Magic'] = set_combine(sets.precast.FC, {
	--									(FC+10%)
	--									(FC+ 2%)
	--									(FC+13%)
		body		=	EMPY.Body,				--CT-16%
		hands		=	EMPY.Hands,				--recast -
	--									(FC+ 7%)
	--									(FC+ 8%)
	--									(FC+ 4%)
	--									(FC+10%)
	--									(FC+ 2%)
	--									(FC+ 1%)
	--									(FC+ 4%)
	--									(FC+ 5%)
	})--						Total : (FC+66%)  CT-16%

-- Weaponskills ============================================================================================= --
	-- Default set for any weaponskill that isn't any more specifically defined
    sets.precast.WS = {
		ammo		=	"Oshasha's Treatise",
		head		=	"Blistering Sallet +1",
		body		=	AF.Body,
		hands		=	"Nyame Gauntlets",	--WSD+ 8%
		legs		=	RELIC.Legs,			--WSD+10%
		feet		=	"Nyame Sollerets",	--WSD+ 8%
		neck		=	"Mirage Stole +2",
		waist		=	"Sailfi Belt +1",
		left_ear	=	"Moonshade Earring",
		right_ear	=	"Ishvara Earring",
		left_ring	=	"Sroda Ring",
		right_ring	=	"Cornelia's Ring",
		back		=	BLUCape.WS.STR,
	}
	sets.precast.WS['Expiacion'] = set_combine(sets.precast.WS, {
		ammo		=	"Crepuscular Pebble",
		head		=	EMPY.Head,			--WSD+12%
		body		=	AF.Body,			--WSD+10% > Nyame R22 +11%
		legs		=	RELIC.Legs,			--WSD+10% > Nyame R22 +10%
		waist		=	"Kentarch Belt +1",
		left_ring	=	"Sroda Ring",
	})
	-- LowBuffs: no WeaponskillMode of that name, never worn (kept as it was)
	sets.precast.WS['Expiacion'].LowBuffs = set_combine(sets.precast.WS, {
		ammo		=	"Coiste Bodhar",	--"Oshasha's Treatise",
		head		=	EMPY.Head,			--WSD+12%
		body		=	AF.Body,			--WSD+10% > Nyame R22 +11%
		legs		=	RELIC.Legs,			--WSD+10% > Nyame R22 +10%
	})
	sets.precast.WS['Savage Blade'] = set_combine(sets.precast.WS, {
		ammo		=	"Oshasha's Treatise",
		head		=	EMPY.Head,			--WSD+12%
		body		=	AF.Body,			--WSD+12% > Nyame R22 +11%/Gleti
		hands		=	"Nyame Gauntlets",	--WSD+ 8%
		legs		=	RELIC.Legs,			--WSD+10% > Nyame
		feet		=	"Nyame Sollerets",	--WSD+ 8% > Nyame
		neck		=	"Mirage Stole +2",
		waist		=	"Sailfi Belt +1",				--/Kentarch
		left_ear	=	"Moonshade Earring",
		right_ear	=	"Ishvara Earring",
		left_ring	=	"Sroda Ring",			--/Sroda
		right_ring	=	"Cornelia's Ring",
		back		=	BLUCape.WS.STR,
	})

    sets.precast.WS['Chant du Cygne'] = set_combine(sets.precast.WS, {
		ammo		=	"Yetshila +1",
		body		=	"Gleti's Cuirass",
		hands		=	ADHE.Hands.A,
		legs		=	"Samnuha Tights",
	--	feet		=	HERC.Feet.TA,	-- nil in his loaded files (only in 0_AugGear.lua, never loaded): feet of sets.precast.WS
		neck		=	"Mirage Stole +2",
		waist		=	"Fotia Belt",
		left_ring	=	"Begrudging Ring",
		right_ring	=	"Epona's Ring",
		back		=	BLUCape.WS.DEX,
	})
    -- His "sets.precast.WS.acc" (lower case) was never read: WeaponskillMode Acc looks up .Acc
    sets.precast.WS.Acc = set_combine(sets.precast.WS, {})

    -- Specific weaponskill sets.  Uses the base set if an appropriate WSMod version isn't found.
    sets.precast.WS['Requiescat'] = set_combine(sets.precast.WS, {feet=RELIC.Feet})
    sets.precast.WS['Sanguine Blade'] = {
	    ammo		=	"Pemphredo Tathlum",	-->> Ghastly Tathlum +1
		head		=	EMPY.Head,
		body		=	"Nyame Mail",
		hands		=	JHAK.Hands,
		legs		=	RELIC.Legs,
		feet		=	EMPY.Feet,
		neck		=	"Sibyl Scarf",
		waist		=	"Orpheus's Sash",
		left_ear	=	"Regal Earring",
		right_ear	=	"Malignance Earring",
		left_ring	=	"Archon Ring",
		right_ring	=	"Metamor. Ring +1",
		back		=	"Aurist's Cape +1",
	}
-- Midcast (Recast time reduction, Ranged attack) ============================================================ --
	-- Base set for every midcast : FC, Haste, BLU MRD-
    sets.midcast = {}
    sets.midcast.FastRecast = {
		ammo		=	"Sapience Orb",			--FC+ 2%
		head		=	AMAL.Head.HQ.D,			--FC+11%	H+ 6%
		body		=	RELIC.Body,				--FC+ 9%	H+ 4%
		hands		=	EMPY.Hands,				--BLU Magic recast delay-14%
		legs		=	"Psycloth Lappas",		--FC+ 7%
		feet		=	CARM.Feet.HQ.B,			--FC+ 8%	H+ 4%
		neck		=	"Baetyl Pendant",		--FC+ 4%
		waist		=	"Sailfi Belt +1",		--			H+ 9%
		left_ear	=	"Loquac. Earring",		--FC+ 2%
		right_ear	=	"Etiolation Earring",	--FC+ 1%
		left_ring	=	"Kishar Ring",			--FC+ 4%
		right_ring	=	"Naji's Loop",			--FC+ 1%
		back		=	BLUCape.Eva,			--FC+10%
	}--									Total :   FC+62/2=31 +32%	=	63% +14% = 77% /80%
    sets.midcast['Blue Magic'] = {}

-- Physical ====(2025/03/10)================================================================================== --
    sets.midcast['Blue Magic'].Physical = {--2025/03/10
		ammo		=	"Coiste Bodhar",
		head		=	RELIC.Head,
		body		=	RELIC.Body,
		hands		=	RELIC.Hands,
		legs		=	RELIC.Legs,
		feet		=	RELIC.Feet,
		neck		=	"Mirage Stole +2",
		waist		=	"Grunfeld Rope",
		left_ear	=	"Telos Earring",
		right_ear	=	"Cessance Earring",
		left_ring	=	"Petrov Ring",
		right_ring	=	"Rajas Ring",
		back		=	BLUCape.TP,
	}
    sets.midcast['Blue Magic'].PhysicalAcc = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalStr = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalDex = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalVit = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalAgi = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalInt = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalMnd = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalChr = set_combine(sets.midcast['Blue Magic'].Physical, {})
    sets.midcast['Blue Magic'].PhysicalHP = set_combine(sets.midcast['Blue Magic'].Physical, {})

-- Magical =====(2025/03/10)================================================================================= --
    sets.midcast['Blue Magic'].Magical = {
		ammo		=	"Pemphredo Tathlum",
		head		=	EMPY.Head,
		body		=	EMPY.Body,
		hands		=	EMPY.Hands,
		legs		=	RELIC.Legs,
		feet		=	EMPY.Feet,
		neck		=	"Sibyl Scarf",
		waist		=	"Ghastly Tathlum +1",--"Orpheus's Sash",
		left_ear	=	"Regal Earring",--"Hecate's Earring",
		right_ear	=	"Friomisi Earring",
		left_ring	=	"Mephitas's Ring +1",--"Jhakri Ring",
		right_ring	=	"Metamor. Ring +1",
		back		=	"Cornflower Cape",
	}
	sets.midcast['Blue Magic'].MagicalEarth = set_combine(sets.midcast['Blue Magic'].Magical, {
		neck		=	"Quanpur Necklace",
	})
    sets.midcast['Blue Magic'].Magical.Resistant = set_combine(sets.midcast['Blue Magic'].Magical, {
		back		=	"Aurist's Cape +1",
	})
    sets.midcast['Blue Magic'].MagicalMnd = set_combine(sets.midcast['Blue Magic'].Magical, {})
    sets.midcast['Blue Magic'].MagicalChr = set_combine(sets.midcast['Blue Magic'].Magical, {})
    sets.midcast['Blue Magic'].MagicalVit = set_combine(sets.midcast['Blue Magic'].Magical, {})
    sets.midcast['Blue Magic'].MagicalDex = set_combine(sets.midcast['Blue Magic'].Magical, {})

    sets.midcast['Blue Magic'].MagicAccuracy = {
					--			Tizona		-- Macc+70
					--			Sakpata		-- Macc+40							FC+10%
		ammo		=	"Pemphredo Tathlum",-- Macc+ 8
		head		=	AF.Head,			-- Macc+66				Haste+ 8%
		body		=	EMPY.Body,			-- Macc+64				Haste+ 4%
		hands		=	EMPY.Hands,			-- Macc+63				Haste+ 3%			Blue Magic Recast-16%
		legs		=	EMPY.Legs,			-- Macc+63	Skill+33	Haste+ 5%
		feet		=	AF.Feet,			-- Macc+65				Haste+ 4%
		neck		=	"Mirage Stole +2",	-- Macc+25	Skill+20
		waist		=	"Null Belt",		-- Macc+30
		left_ear	=	"Regal Earring",	-- Macc+30
		right_ear	=	EMPY.Ear,			-- Macc+11	Skill+11
		left_ring	=	STIK.One,			-- Macc+11	Skill+ 8
		right_ring	=	STIK.Two,			-- Macc+11	Skill+ 8
		back		=	"Aurist's Cape +1",	-- Macc+33
	}--								Total:Macc+673	Skill+80	Haste+24%	FC+10%	Blue Magic Recast-16%
	sets.midcast['Blue Magic'].TPRemoval = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
	sets.midcast['Blue Magic'].Enmity = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {
		ammo		=	"Sapience Orb",		-- Enmity+ 2 (max)	(his file: "Sapiens Orb", no such item)
		head		=	"Rabid Visor",		-- Enmity+ 6 (max)
		body		=	"Emet Harness +1",	-- Enmity+10 (max)
		hands		=	"Leyline Gloves",	-- 					FC+ 7%	("Enif Manopolas" Enmity+ 7 max)
		legs		=	"Psycloth Lappas",	--					FC+ 7%	("Zoar Subligar +1" Enmity+ 6 max)
		feet		=	CARM.Feet.HQ.B,		--					FC+ 8%	("Ahosi Leggings" Enmity+ 7 max PDT-4%)
		neck		=	"Unmoving Collar +1",--Enmity+10 (max)
		waist		=	"Kasiri Belt",		-- Enmity+ 3				(+4 max)
		left_ear	=	"Cryptic Earring",	-- Enmity+ 4 (max)
		right_ear	=	"Friomisi Earring",	-- Enmity+ 2				("Trux Earring" Enmity+ 5 max)
		left_ring	=	"Begrudging Ring",	-- Enmity+ 5 (max)
		right_ring	=	"Petrov Ring",		-- Enmity+ 4				("Provocare Ring" Enmity+ 5 max)
		back		=	"Enuma Mantle",		-- Enmity+ 6				("Earthcry Mantle" +7 max)
	})

	sets.midcast['Sound Blast'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {
		ammo		=	"Per. Lucky Egg",	--TH+1
		head		=	"Wh. Rarab Cap +1",	--TH+1
		waist		=	"Chaac Belt",		--TH+1
	})
	sets.midcast['Blue Magic'].Breath = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
	sets.midcast['Blue Magic'].Stun = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {
	})
	sets.midcast['Blue Magic'].Healing = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {
		ammo		=	"Crepuscular Pebble",	--DT- 3%
		head		=	EMPY.Head,				--
		body		=	TELC.Body.Enh,			--			CP+ 7%
		hands		=	TELC.Hands.Cure,		--HP+101	CP+18%
		legs		=	TELC.Legs.Enh,			--MND+26	CP+ 8%
		feet		=	TELC.Feet.Enh,			--			CP+ 8%
		neck		=	"Loricate Torque +1",	--DT- 6%
		waist		=	"Sacro Cord",			--MND+ 8
		left_ear	=	"Regal Earring",		
		right_ear	=	"Mendi. Earring",		--			CP+ 5%
		left_ring	=	"Naji's Loop",			--			CP+ 1%	CP2+ 1%
		right_ring	=	"Menelaus's Ring",		--			CP+ 5%	Healing skill+15
		back		=	"Aurist's Cape +1",
	})--								Total : 			CP+52%	CP2+ 1%
	sets.midcast['Restoral'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {--Potency+, BLU Skill
	})
	sets.midcast['White Wind'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {--HP+, Potency+
	    ammo		=	"Happy Egg",			--HP+  1%
		head		=	"Blistering Sallet +1",	--HP+118
		body		=	"Nyame Mail",			--HP+136
		hands		=	TELC.Hands.Cure,		--HP+101	CP+18%
		legs		=	"Nyame Flanchard",		--HP+114
		feet		=	"Nyame Sollerets",		--HP+  4%
		neck		=	"Unmoving Collar +1",	--HP+200
		waist		=	"Plat. Mog. Belt",		--HP+ 10%
		left_ear	=	"Etiolation Earring",	--HP+ 50	>	"Tuisto Earring",	--HP+150
		right_ear	=	"Odnowa Earring +1",	--HP+150
		left_ring	=	"Gelatinous Ring +1",	--HP+135
		right_ring	=	"Ilabrat Ring",			--HP+ 60	>	"Meridian Ring",	--HP+ 90
		back		=	"Twilight Cape",		--HP+25
		-- back		=	"Moonbeam Cape",		--HP+250
	})
	
    sets.self_healing = set_combine(sets.midcast['Blue Magic'].Healing, {
	--	neck		=	"Phalaina Locket",
	--	waist		=	"Gishdubar Sash",
	--	left_ring	=	"Kunaji Ring",
	})

    sets.midcast['Blue Magic'].SkillBasedBuff = set_combine(sets.midcast.FastRecast, {--(skill/50)
		-- main		=	"Iris",				--Skill+30
		-- sub		=	"Iris",				--Skill+30
		ammo		=	"Mavi Tathlum",		--Skill+ 5	Porter Moogle
        head		=	RELIC.Head,			--Skill+17
        body		=	AF.Body,			--Skill+24
	--	hands		=	"Rawhide Gloves",	--Skill+10	Gabvansmaller
		hands		=	EMPY.Hands,			-- Recast -
		legs		=	EMPY.Legs,			--Skill+28 | > Skill+33
		feet		=	RELIC.Feet,			--Skill+12
		neck		=	"Mirage Stole +2",	--Skill+20
	--	waist		=	"",
		back		=	"Cornflower Cape",	--Skill+15
		left_ear	=	"Njordr Earring",	--Skill+10
		right_ear	=	EMPY.Ear,			--Skill+11 | > +2 +12
		left_ring	=	"Stikini Ring +1",	--Skill+ 8
		right_ring	=	"Stikini Ring +1",	--Skill+ 8
	})--							Total : Skill +158 | +142 | 152
    sets.midcast['Blue Magic'].Buff = set_combine(sets.midcast.FastRecast, {
		head		=	AMAL.Head.HQ.D,		--Battery Charge
		body		=	TELC.Body.Enh,		--Regeneration
	--	waist		=	"Gishdubar Sash",	--Refresh+20s	100 Domain points
		back		=	"Grapevine Cape",	--Refresh+30s
	})
	-- sets.midcast['Regeneration'] = {
		-- head		=	TAEO.Head.Regen,
		-- body		=	TELC.Body.Regen,
		-- hands		=	TELC.Hands.Regen,
		-- legs		=	TELC.Legs.Regen,
		-- feet		=	TELC.Feet.Regen,		
		-- }
	sets.midcast['WhiteMagic'] = set_combine(sets.midcast['Blue Magic'].Healing, {
		head		=	TELC.Head.Enh,
		body		=	TELC.Body.Enh,
		-- hands		=	TELC.Hands.Enh,
		legs		=	TELC.Legs.Enh,
		feet		=	TELC.Feet.Enh,
	})
	sets.midcast['Enfeebling Magic'] = set_combine(sets.midcast['Blue Magic'].MagicAccuracy, {})
	sets.midcast['Phalanx'] = set_combine(sets.midcast['Blue Magic'].Buff, {
		main		=	"Sakpata's Sword",
		head		=	HERC.Head.Phalanx,
		body		=	HERC.Body.Phalanx,
		hands		=	HERC.Hands.Phalanx,
		legs		=	HERC.Legs.Phalanx,
		feet		=	HERC.Feet.Phalanx,
	})
	sets.midcast.Refresh = set_combine(sets.midcast['WhiteMagic'], sets.midcast['Blue Magic'].Buff, {
		waist		=	"Gishdubar Sash",
		back		=	"Grapevine Cape",
	})
--	sets.midcast.Protect = {ring1="Sheltered Ring"}
--	sets.midcast.Protectra = {ring1="Sheltered Ring"}
--	sets.midcast.Shell = {ring1="Sheltered Ring"}
--	sets.midcast.Shellra = {ring1="Sheltered Ring"}
	--  _    ____ ____ ____ _  _ _ _  _ ____ 
	--  |    |___ |__| |__/ |\ | | |\ | | __ 
	--  |___ |___ |  | |  \ | \| | | \| |__] 
	--				+skill and AF hands.
    sets.Learning = set_combine(sets.midcast['Blue Magic'].SkillBasedBuff, {
		hands		=	AF.Hands,
	})
    -- His customize_idle_set threw this away (set_combine result not kept): never worn.
    -- Rule left commented in config/blu/BLU_CUSTOM.lua.
    sets.latent_refresh = {waist="Fucho-no-obi"}
	-- sets.latent_regain	= {right_ring =	"Karieyh Ring"}
    
	--==============================================================================================--
	--  ██ ██████  ██      ███████ 	Idle
	--  ██ ██   ██ ██      ██      	Resting
	--  ██ ██   ██ ██      █████   	Defense
	--  ██ ██   ██ ██      ██      	Kiting
	--  ██ ██████  ███████ ███████ 
	--==============================================================================================--
    -- Resting sets
    sets.resting = {}

    sets.idle = {
		ammo		=	"Amar Cluster",			--						Eva+10
		head		=	HERC.Head.Refresh,		-- Refresh+1~2
		body		=	EMPY.Body,				-- Refresh+ 4	DT-12%
		hands		=	HERC.Hands.Refresh,		-- Refresh+ 2
	--	legs		=	"Carmine Cuisses +1",	-- 
		legs		=	HERC.Legs.Refresh,		-- Refresh+ 2
		feet		=	HERC.Feet.Refresh,		-- Refresh+ 2
		neck		=	"Loricate Torque +1",	-- 				 DT- 6%
		waist		=	"Null Belt",			-- 						Eva+30
		back		=	BLUCape.TP,				-- 				PDT-10%
		left_ear	=	"Infused Earring",		-- Regen +1				Eva+10
		right_ear	=	"Odnowa Earring +1",	--				 DT- 3%
		left_ring	=	STIK.One,		-- Refresh+ 1
		right_ring	=	STIK.Two,		-- Refresh+ 1
	}--										Total: Refresh+11	 DT-
									--	Sakpata's: 				 DT-10%
	sets.idle.Evasion = {
		ammo		=	"Amar Cluster",			-- Eva+ 10
		head		=	"Nyame Helm",			-- Eva+ 90	DT- 7
		body		=	"Nyame Mail",			-- Eva+102	DT- 9
		hands		=	"Nyame Gauntlets",		-- Eva+ 80	DT- 7
		legs		=	"Carmine Cuisses +1",	-- Eva+ 27 		--"Nyame Flanchard",
		feet		=	"Nyame Sollerets",		-- Eva+119	DT- 7
		neck		=	"Bathy Choker +1",		-- Eva+ 20
		waist		=	"Null Belt",			-- Eva+ 30
		back		=	BLUCape.Eva,			-- Eva+ 45
		left_ear	=	"Eabani Earring",		-- Eva+ 15
		right_ear	=	"Infused Earring",		-- Eva+ 10
		left_ring	=	"Murky Ring",		--			DT-10
		right_ring	=	"Vengeful Ring",		-- Eva+ 9
	}--										Total: Eva+531	DT-50% si Sakpata
    sets.idle.DT 		= set_combine(sets.idle, {
		left_ring	=	"Murky Ring",
		right_ring	=	"Archon Ring",
	})
    sets.idle.Regain 		= set_combine(sets.idle, {
        body		=	"Gleti's Cuirass",		-- DT- 9%
		hands		=	"Gleti's Gauntlets",	-- DT- 7%
		legs		=	"Gleti's Breeches",		-- DT- 8%
		neck		=	"Rep. Plat. Medal",
	})
--	sets.idle.Town 		= set_combine(sets.idle, {})
    sets.idle.Learning	= set_combine(sets.idle, sets.Learning)	-- no IdleMode Learning: never worn
    
    sets.Kiting = {legs=CARM.Legs.HQ.D}

	--==============================================================================================--
	--  ████████ ██████  	Haste Cap : Equip 25% | Magic 43,75% | JA 25%
	--     ██    ██   ██ 	30% Magical Haste = DW+26 / 21
	--     ██    ██████  	Cap Magical Haste = DW+ 6 /  1
	--     ██    ██      	
	--     ██    ██      	
	--==============================================================================================--

    --[[ Variations for TP weapon and (optional) offense/defense modes.  Code will fall back on previous
			sets if more refined versions aren't defined.
			If you create a set with both offense and defense modes, the offense mode should be first.
			EG: sets.engaged.Dagger.Accuracy.Evasion	]]

    -- Normal melee group
    sets.engaged = {
		ammo		=	"Coiste Bodhar",		--
		head		=	"Malignance Chapeau",	-- DT- 6%
		body		=	"Malignance Tabard",	-- DT- 9%
		hands		=	"Gazu Bracelets +1",	--
		legs		=	"Gleti's Breeches",		--PDT- 8%
		feet		=	"Malignance Boots",		-- DT- 4%
		neck		=	"Mirage Stole +2",		--		  STP+7 	 Acc+25 Crit+7 STR/DEX+25
		waist		=	"Kentarch Belt +1",
		left_ear	=	"Telos Earring",		--		  STP+5 DA+1 Acc+10
		right_ear	=	"Cessance Earring",				--STP+3 DA+3 Acc+ 6
					--	EMPY.Ear,				--		DA+3 Acc+22 Atk+11 si plus de DA c'est bon avec dedition
					--	"Dedition Earring",				--STP+8
		left_ring	=	"Chirich Ring +1",		--		  STP+6		 Acc+10
		right_ring	=	"Epona's Ring",			--				DA+3 TA+3
		back		=	BLUCape.TP,				--PDT-10%
	}							--Total :		  PDT-37%
    sets.engaged.Acc = set_combine(sets.engaged, {})
	-- Eva: no OffenseMode Eva (HybridMode commented out in his file): never worn
	sets.engaged.Eva	=	{
		ammo		=	"Staunch Tathlum",		-- 			DT- 2
		head		=	"Nyame Helm",			-- Eva+ 90	DT- 7
		body		=	"Malignance Tabard",	-- Eva+102	DT- 9
		hands		=	"Malignance Gloves",	-- Eva+ 80	DT- 5
		legs		=	"Nyame Flanchard",		--			DT- 8"Samnuha Tights",		--
		feet		=	"Malignance Boots",		-- Eva+119	DT- 4
		neck		=	"Mirage Stole +2",		-- Acc
		waist		=	"Sailfi Belt +1",		-- DA/TA
		back		=	BLUCape.TP,				-- 			DT- 5
		left_ear	=	"Eabani Earring",		-- Eva+ 15
		right_ear	=	"Telos Earring",		-- 
		left_ring	=	"Petrov Ring",			--
		right_ring	=	"Epona's Ring",			-- DA/TA
	}
	sets.engaged.DT = set_combine(sets.engaged, {
		ammo		=	"Coiste Bodhar",
		head		=	"Nyame Helm",
		body		=	"Nyame Mail",
		hands		=	"Nyame Gauntlets",
		legs		=	"Nyame Flanchard",
		feet		=	"Nyame Sollerets",
		neck		=	"Mirage Stole +2",
		waist		=	"Kentarch Belt +1",
		left_ear	=	"Telos Earring",
		right_ear	=	"Cessance Earring",
		left_ring	=	"Chirich Ring +1",
		right_ring	=	"Epona's Ring",
		back		=	BLUCape.TP,
	})
	sets.engaged['Subtle Blow'] = set_combine(sets.engaged, {
		ammo		=	"Expeditious Pinion",	--			SB+ 7
		head		=	ADHE.Head.HQ.B,			--			SB+ 8
		-- body		=	"Volte Harness",		--			SB+10
		body		=	"Malignance Tabard",	--
		-- hands		=	"Gazu Bracelets +1",	--
		hands		=	"Gleti's Gauntlets",	--PDT- 7%
		legs		=	"Gleti's Breeches",		--PDT- 8%	SB+10
		feet		=	"Malignance Boots",		-- DT- 4%
		-- neck		=	"Bathy Choker +1",		--
		neck		=	"Mirage Stole +2",		-- Acc
		waist		=	"Kentarch Belt +1",		--
		left_ear	=	"Telos Earring",		--
		right_ear	=	"Digni. Earring",		--			SB+ 5
		left_ring	=	"Murky Ring",		-- DT-10%
		right_ring	=	"Chirich Ring +1",		--			SB+10
		back		=	BLUCape.TP,				--PDT-10%	SB+50
	})

    sets.engaged.Refresh = set_combine(sets.engaged, {})
    sets.engaged.Learning = set_combine(sets.engaged, sets.Learning)	-- no OffenseMode Learning: never worn

    -- Single wield (his update_combat_form: Genbu's Shield or nothing in the off hand).
    -- Only Acc and Refresh have an .SW version: DT, Subtle Blow and Capped
    -- single wielding wear sets.engaged.SW, as with Mote.
    sets.engaged.SW = set_combine(sets.engaged, {})
    sets.engaged.SW.Acc = set_combine(sets.engaged.Acc, {})
    sets.engaged.SW.Refresh = set_combine(sets.engaged, {})
    sets.engaged.SW.Learning = set_combine(sets.engaged.SW, sets.Learning)

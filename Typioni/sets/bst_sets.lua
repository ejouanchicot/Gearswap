---============================================================================
--- BST Equipment Sets - Complete Gear Configuration
---============================================================================
--- Equipment sets for Beastmaster job.
--- Includes master sets, pet sets, ready move sets, weapon sets, and 25 jug pet broth sets.
---
--- @file jobs/bst/sets/bst_sets.lua
--- @author Typioni
--- @version 2.0
--- @date Created: 2025-10-17 | Updated: 2025-10-18
---============================================================================

---@diagnostic disable: lowercase-global

--============================================================--
--                  COMMON GEAR DEFINITIONS                    --
--============================================================--

-- Frequently used rings
local RINGS = {
    MoonLight1 = 'Moonlight Ring',
    MoonLight2 = 'Moonlight Ring',
    Chirich1 = 'Chirich Ring +1',
    Chirich2 = 'Chirich Ring +1',
    Stikini1 = 'Stikini Ring +1',
    Stikini2 = 'Stikini Ring +1',
    Varar2 = 'Varar Ring +1',
    Defending = 'Defending Ring',
    CPalug = 'C. Palug Ring',
    Gere = 'Gere Ring',
    Hetairoi = 'Hetairoi Ring',
    Cornelia = "Cornelia's Ring",
    Metamorph = 'Metamor. Ring +1',
    Purity = 'Purity Ring',
    Tali = "Tali'ah Ring"
}

-- Aliases for backward compatibility
MoonLightRing1 = RINGS.MoonLight1
MoonLightRing2 = RINGS.MoonLight2
ChirichRing1 = RINGS.Chirich1
ChirichRing2 = RINGS.Chirich2
StikiniRing1 = RINGS.Stikini1
StikiniRing2 = RINGS.Stikini2
StikiRing1 = RINGS.Stikini1 -- Legacy alias
VararRing2 = RINGS.Varar2

-- Common earrings
local EARRINGS = {
    Odnowa = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
    Nukumi = {
        name = 'Nukumi Earring +1',
        augments = {'System: 1 ID: 1676 Val: 0', 'Accuracy+12', 'Mag. Acc.+12', 'Pet: "Dbl. Atk."+6'}
    },
    Telos = 'Telos Earring',
    Enmerkar = 'Enmerkar Earring',
    Sroda = 'Sroda Earring',
    Ferine = 'Ferine Earring',
    Thrud = 'Thrud Earring',
    Sortiarius = 'Sortiarius Earring',
    Friomisi = 'Friomisi Earring',
    Hija = 'Hija Earring'
}

-- Common neck pieces
local NECK = {
    BstCollar = {name = 'Bst. Collar +2', augments = {'Path: A'}},
    EliteRoyal = 'Elite Royal Collar',
    Adad = 'Adad Amulet',
    Sibyl = 'Sibyl Scarf',
    Nicander = "Nicander's Necklace"
}

-- Cape pieces (Artio's Mantle variations)
Artio = {
    STP = {
        name = "Artio's Mantle",
        augments = {
            'DEX+20',
            'Accuracy+20 Attack+20',
            'Accuracy+10',
            '"Store TP"+10',
            'Damage taken-5%'
        }
    },
    WS1 = {
        name = "Artio's Mantle",
        augments = {
            'STR+20',
            'Accuracy+20 Attack+20',
            'STR+10',
            'Weapon skill damage +10%',
            'Damage taken-5%'
        }
    },
    PETSTP = {
        name = "Artio's Mantle",
        augments = {
            'Pet: Acc.+20 Pet: R.Acc.+20 Pet: Atk.+20 Pet: R.Atk.+20',
            'Accuracy+20 Attack+20',
            'Pet: Accuracy+10 Pet: Rng. Acc.+10',
            'Pet: Haste+10',
            'Pet: Damage taken -5%'
        }
    },
    PETMB = {
        name = "Artio's Mantle",
        augments = {
            'Pet: M.Acc.+20 Pet: M.Dmg.+20',
            'Eva.+20 /Mag. Eva.+20',
            'Pet: Magic Damage+10',
            'Pet: "Regen"+10',
            'Pet: Damage taken -5%'
        }
    }
}

-- Alternative pet tanking mantle
Pastoralist = {
    petDT = {
        name = "Pastoralist's Mantle",
        augments = {
            'STR+3 DEX+3',
            'Pet: Accuracy+18 Pet: Rng. Acc.+18',
            'Pet: Damage taken -4%'
        }
    }
}

-- Additional reusable gear
JumalikHead = {
    name = 'Jumalik Helm',
    augments = {
        'MND+10',
        '"Mag.Atk.Bns."+15',
        'Magic burst dmg.+10%',
        '"Refresh"+1'
    }
}

JumalikBody = {
    name = 'Jumalik Mail',
    augments = {
        'HP+50',
        'Attack+15',
        'Enmity+9',
        '"Refresh"+2'
    }
}

-- Common augmented gear for pet multi-hit physical Ready moves
local PhysMultiGear = {
    head = {name = 'Valorous Mask', augments = {'Pet: "Dbl. Atk."+5', 'Pet: STR+6', 'Pet: Attack+15 Pet: Rng.Atk.+15'}},
    body = {
        name = 'Valorous Mail',
        augments = {
            'Pet: "Dbl. Atk."+5',
            'Pet: STR+7',
            'Pet: Accuracy+11 Pet: Rng. Acc.+11',
            'Pet: Attack+8 Pet: Rng.Atk.+8'
        }
    },
    hands = {name = 'Valorous Mitts', augments = {'Pet: Attack+15 Pet: Rng.Atk.+15', 'Pet: "Dbl. Atk."+5'}},
    legs = {name = 'Emicho Hose', augments = {'Pet: Accuracy+15', 'Pet: Attack+15', 'Pet: "Dbl. Atk."+3'}},
    feet = {name = "Gleti's Boots"}
}

-- Aliases for the PhysMultiGear pieces
Emicho_Coronet_phys_multi = PhysMultiGear.head
Valorous_Mail_phys_multi = PhysMultiGear.body
Valorous_Mitts_phys_multi = PhysMultiGear.hands
Emicho_Hose_phys_multi = PhysMultiGear.legs
Valorous_Greaves_phys_multi = PhysMultiGear.feet

-- Common augmented gear for pet MAB Ready moves
local MabGear = {
    head = {
        name = 'Valorous Mask',
        augments = {'Pet: "Mag.Atk.Bns."+28', 'Pet: INT+12', 'Pet: Attack+6 Pet: Rng.Atk.+6'}
    },
    body = {name = 'Valorous Mail', augments = {'Pet: "Mag.Atk.Bns."+27', '"Dbl.Atk."+1', 'Pet: INT+13'}},
    hands = {
        name = 'Valorous Mitts',
        augments = {
            'Pet: "Mag.Atk.Bns."+30',
            '"Store TP"+5',
            'Pet: INT+14',
            'Pet: Accuracy+14 Pet: Rng. Acc.+14',
            'Pet: Attack+2 Pet: Rng.Atk.+2'
        }
    },
    legs = {name = 'Valorous Hose', augments = {'Pet: "Mag.Atk.Bns."+27', 'Pet: "Subtle Blow"+7', 'Pet: INT+8'}},
    feet = {
        name = 'Valorous Greaves',
        augments = {'Pet: "Mag.Atk.Bns."+29', 'Pet: INT+15', 'Pet: Accuracy+13 Pet: Rng. Acc.+13'}
    }
}

-- Aliases for the MabGear pieces
Valorous_Mask_mab = MabGear.head
Valorous_Mail_mab = MabGear.body
Valorous_Mitts_mab = MabGear.hands
Valorous_Hose_mab = MabGear.legs
Gleti_Boots_mab = MabGear.feet

--============================================================--
--             WEAPON & AMMO VIRTUAL SETS (State.*)           --
--============================================================--

-- Main/Sub weapon definitions
sets['Aymur'] = {main = 'Aymur'}
sets["Agwu's Axe"] = {sub = "Agwu's Axe"}
sets['Tauret'] = {main = 'Tauret'}
sets['Blur Knife'] = {sub = 'Blurred Knife +1'}
sets['Adapa Shield'] = {sub = 'Adapa Shield'}
sets['Diamond Aspis'] = {sub = 'Diamond Aspis'}

-- JUG PET BROTH SETS (25 PETS - matches BST_PET_DATA.lua)
sets['Amiable Roche (Fish)'] = {ammo = 'Airy Broth'}
sets['Jovial Edwin (Crab)'] = {ammo = 'Pungent Broth'}
sets['Fluffy Bredo (Acuex)'] = {ammo = 'Venomous Broth'}
sets['Sultry Patrice (Slime)'] = {ammo = 'Putrescent Broth'}
sets['Fatso Fargann (Leech)'] = {ammo = 'C. Plasma Broth'}
sets['Generous Arthur (Slug)'] = {ammo = 'Dire Broth'}
sets['Blackbeard Randy (Tiger)'] = {ammo = 'Meaty Broth'}
sets['Rhyming Shizuna (Sheep)'] = {ammo = 'Lyrical Broth'}
sets['Pondering Peter (Rabbit)'] = {ammo = 'Vis. Broth'}
sets['Vivacious Vickie (Raaz)'] = {ammo = 'Tant. Broth'}
sets['Choral Leera (Colibri)'] = {ammo = 'Glazed Broth'}
sets['Daring Roland (Hippogryph)'] = {ammo = 'Feculent Broth'}
sets['Swooping Zhivago (Tulfaire)'] = {ammo = 'Windy Greens'}
sets['Warlike Patrick (Lizard)'] = {ammo = 'Livid Broth'}
sets['Suspicious Alice (Eft)'] = {ammo = 'Furious Broth'}
sets['Brainy Waluis (Funguar)'] = {ammo = 'Crumbly Soil'}
sets['Sweet Caroline (Mandragora)'] = {ammo = 'Aged Humus'}
sets['Bouncing Bertha (Chapuli)'] = {ammo = 'Bubbly Broth'}
sets['Threestar Lynn (Ladybug)'] = {ammo = 'Muddy Broth'}
sets['Headbreaker Ken (Fly)'] = {ammo = 'Blackwater Broth'}
sets['Energized Sefina (Beetle)'] = {ammo = 'Gassy Sap'}
sets['Anklebiter Jedd (Diremite)'] = {ammo = 'Crackling Broth'}
sets['Left-Handed Yoko (Mosquito)'] = {ammo = 'Heavenly Broth'}
sets['Cursed Annabelle (Antlion)'] = {ammo = 'Creepy Broth'}
sets['Weevil Familiar (Weevil)'] = {ammo = 'T. Pristine Sap'}

--============================================================--
--                PET READY MOVE CATEGORY TABLES              --
--============================================================--

-- Single-hit physical moves
petPhysicalMoves =
    S {
    'Foot Kick',
    'Whirl Claws',
    'Sheep Charge',
    'Lamb Chop',
    'Head Butt',
    'Leaf Dagger',
    'Claw Cyclone',
    'Razor Fang',
    'Nimble Snap',
    'Cyclotail',
    'Rhino Attack',
    'Power Attack',
    'Mandibular Bite',
    'Big Scissors',
    'Grapple',
    'Spinning Top',
    'Double Claw',
    'Frogkick',
    'Blockhead',
    'Brain Crush',
    'Tail Blow',
    '??? Needles',
    'Needleshot',
    'Scythe Tail',
    'Ripper Fang',
    'Recoil Dive',
    'Sudden Lunge',
    'Spiral Spin',
    'Beak Lunge',
    'Suction',
    'Back Heel',
    'Choke Breath',
    'Fantod',
    'Tortoise Stomp',
    'Sensilla Blades',
    'Tegmina Buffet',
    'Swooping Frenzy',
    'Zealous Snort',
    'Somersault',
    'Sickle Slash',
    'Crossthrash'
}

-- Multi-hit physical moves
petPhysicalMultiMoves =
    S {
    'Sweeping Gouge',
    'Tickling Tendrils',
    'Chomp Rush',
    'Pentapeck',
    'Wing Slap',
    'Pecking Flurry'
}

-- Magical nukes / damage-based spells
petMagicAtkMoves =
    S {
    'Cursed Sphere',
    'Venom',
    'Toxic Spit',
    'Bubble Shower',
    'Drainkiss',
    'Fireball',
    'Snow Cloud',
    'Charged Whisker',
    'Purulent Ooze',
    'Corrosive Ooze',
    'Aqua Breath',
    'Choke Breath',
    'Stink Bomb',
    'Nectarous Deluge',
    'Nepenthic Plunge',
    'Pestilent Plume',
    'Foul Waters',
    'Acid Spray'
}

-- Magical accuracy-based moves (debuffs, status effects, buffs)
petMagicAccMoves =
    S {
    -- Debuffs
    'Sheep Song',
    'Scream',
    'Dream Flower',
    'Roar',
    'Gloeosuccus',
    'Palsy Pollen',
    'Soporific',
    'Geist Wall',
    'Numbing Noise',
    'Spoil',
    'Hi-Freq Field',
    'Sandpit',
    'Sandblast',
    'Venom Spray',
    'Filamented Hold',
    'Queasyshroom',
    'Numbshroom',
    'Spore',
    'Shakeshroom',
    'Infrasonics',
    'Chaotic Eye',
    'Blaster',
    'Intimidate',
    'Noisome Powder',
    'Acid Mist',
    'TP Drainkiss',
    'Jettatura',
    'Nihility Song',
    'Molting Plumage',
    'Spider Web',
    'Digest',
    'Silence Gas',
    'Dark Spore',
    'Predatory Glare',
    -- Healing/regen moves
    'Wild Carrot',
    'Wild Oats',
    -- Defensive buffs
    'Bubble Curtain',
    'Scissor Guard',
    'Metallic Body',
    'Rhino Guard',
    'Water Wall',
    'Harden Shell',
    -- Status enhancement
    'Secretion',
    'Rage'
}

--============================================================--
--                   BASE GEARSETS & TEMPLATES                --
--============================================================--

-- Initialize base tables
sets.me = sets.me or {}
sets.pet = sets.pet or {}

-- Standard pet defensive core gear (reused in multiple sets)
local petDTCore = {
    head = {
        name = 'Anwig Salade',
        augments = {
            'CHR+4',
            '"Waltz" ability delay -2',
            'Attack+3',
            'Pet: Damage taken -10%'
        }
    },
    body = 'Tot. Jackcoat +3',
    hands = {
        name = 'Ankusa Gloves +3',
        augments = {
            'Enhances "Beast Affinity" effect'
        }
    }
}

-- Malignance set (defensive master gear)
local malignanceSet = {
    head = 'Malignance Chapeau',
    body = 'Malignance Tabard',
    hands = 'Malignance Gloves',
    legs = 'Malignance Tights',
    feet = 'Malignance Boots'
}

-- Base idle set used by both player and pet
local baseIdleSet =
    set_combine(
    malignanceSet,
    {
        ammo = 'Hesperiidae',
        neck = NECK.BstCollar,
        waist = 'Flume Belt +1',
        left_ear = EARRINGS.Odnowa,
        right_ear = EARRINGS.Nukumi,
        left_ring = RINGS.Defending,
        right_ring = 'Chirich Ring +1',
        back = Artio.STP
    }
)

--============================================================--
--                   IDLE & DEFENSIVE GEARSETS                --
--============================================================--

-- Master idle sets
sets.idle = set_combine({}, baseIdleSet)
sets.me.idle = set_combine({}, baseIdleSet)
sets.me.idle.PDT = set_combine(sets.me.idle, {})
sets.me.idle.Town =
    set_combine(
    sets.me.idle,
    {
        feet = 'Skd. Jambeaux +1'
    }
)

-- Pet idle set (regen/defense focus)
sets.pet.idle = {
    head = 'Nuk. Cabasset +3',
    body = "Gleti's Cuirass",
    hands = 'Nukumi Manoplas +3',
    legs = 'Nukumi Quijotes +3',
    feet = 'Ankusa Gaiters +3',
    neck = NECK.EliteRoyal,
    waist = 'Isa Belt',
    left_ear = EARRINGS.Enmerkar,
    right_ear = EARRINGS.Odnowa,
    left_ring = RINGS.Chirich1,
    right_ring = RINGS.Chirich2,
    back = Artio.PETMB
}

-- Pet PDT idle set (defensive variant)
sets.pet.idle.PDT =
    set_combine(
    sets.pet.idle,
    petDTCore,
    {
        neck = NECK.BstCollar,
        right_ear = EARRINGS.Nukumi,
        left_ring = RINGS.Varar2,
        right_ring = RINGS.CPalug
    }
)

--============================================================--
--                  ENGAGED (MELEE COMBAT) SETS               --
--============================================================--

-- Master engaged set (balanced ACC/DT hybrid)
sets.me.engaged =
    set_combine(
    malignanceSet,
    {
        neck = NECK.BstCollar,
        waist = 'Kentarch Belt +1',
        left_ear = EARRINGS.Telos,
        right_ear = EARRINGS.Nukumi,
        left_ring = RINGS.Chirich1,
        right_ring = RINGS.Chirich2,
        back = Artio.STP
    }
)

-- Master engaged PDT variant (tankier)
sets.me.engaged.PDT =
    set_combine(
    sets.me.engaged,
    {
        head = 'Nuk. Cabasset +3',
        hands = 'Nukumi Manoplas +3',
        legs = 'Nukumi Quijotes +3',
        back = Pastoralist.petDT
    }
)

-- Pet engaged set (offensive focus)
sets.pet.engaged = {
    ammo = 'Hesperiidae',
    head = 'Nuk. Cabasset +3',
    body = 'Nukumi Gausape +3',
    hands = 'Nukumi Manoplas +3',
    legs = 'Nukumi Quijotes +3',
    feet = 'Ankusa Gaiters +3',
    neck = NECK.BstCollar,
    waist = 'Klouskap Sash',
    left_ear = EARRINGS.Enmerkar,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Chirich1,
    right_ring = RINGS.Chirich2,
    back = Pastoralist.petDT
}

-- Pet engaged PDT set (defensive variant)
sets.pet.engaged.PDT =
    set_combine(
    sets.pet.engaged,
    {
        ammo = 'Hesperiidae',
        neck = NECK.BstCollar,
        waist = 'Isa Belt',
        left_ring = RINGS.Varar2,
        right_ring = RINGS.CPalug,
        back = Artio.PETMB
    }
)

-- Master + pet engaged set (used in synced combat)
sets.pet.engagedBoth =
    set_combine(
    malignanceSet,
    {
        ammo = 'Hesperiidae',
        neck = NECK.BstCollar,
        waist = 'Kentarch Belt +1',
        left_ear = EARRINGS.Telos,
        right_ear = EARRINGS.Nukumi,
        left_ring = RINGS.Chirich1,
        right_ring = RINGS.Chirich2,
        back = Artio.STP
    }
)

-- Base engaged set (used by Mote-Include - will be customized by SetBuilder)
sets.engaged = set_combine({}, sets.me.engaged)

--============================================================--
--                  PRECAST JOB ABILITY SETS                  --
--============================================================--

-- Initialize precast tables
sets.precast = sets.precast or {}
sets.precast.JA = sets.precast.JA or {}

-- Call Beast / Bestial Loyalty (pet summoning)
local summonSet = {
    head = 'Acro Helm',
    body = 'Mirke Wardecors',
    hands = 'Ankusa Gloves +3',
    ear2 = EARRINGS.Nukumi,
    legs = 'Acro Breeches'
}

-- Configure JA sets
-- TEST CONFIG: BOTH Charmer's AND Gleti's to see if they stack
-- If stack: 30s - 10s (merits) - 5s (JP) - 5s (Charmer's) - 5s (Gleti's) = 5s
-- If NOT stack: 30s - 10s (merits) - 5s (JP) - 5s (one item) = 10s
sets.precast.JA['Sic'] = {
    sub = "Charmer's Merlin",         -- Ready Recast -5s
    hands = 'Nukumi Manoplas +3',     -- Pet: Store TP +12
    legs = "Gleti's Breeches"         -- Ready Recast -5s (TEST if stack)
}

sets.precast.JA['Ready'] = sets.precast.JA['Sic']
sets.precast.JA['Call Beast'] = summonSet
sets.precast.JA['Bestial Loyalty'] = summonSet

-- Reward (pet heal)
sets.precast.JA['Reward'] = {
    ammo = 'Pet Food Theta',
    head = 'Khimaira Bonnet',
    body = {name = 'An. Jackcoat +3', augments = {'Enhances "Feral Howl" effect'}},
    hands = 'Malignance Gloves',
    legs = {name = 'Ankusa Trousers +3', augments = {'Enhances "Familiar" effect'}},
    feet = {name = 'Ankusa Gaiters +3', augments = {'Enhances "Beast Healer" effect'}},
    neck = 'Adad Amulet',
    waist = 'Isa Belt',
    left_ear = 'Enmerkar Earring',
    right_ear = {name = 'Odnowa Earring +1', augments = {'Path: A'}},
    left_ring = 'Stikini Ring +1',
    right_ring = {name = 'Metamor. Ring +1', augments = {'Path: A'}},
    back = Artio.PETMB
}

-- Killer Instinct (buff)
sets.precast.JA['Killer Instinct'] = {
    sub = 'Diamond aspis',
    head = 'Ankusa Helm +3',
    body = 'Nukumi Gausape +3'
}

-- Spur (pet TP gain)
sets.precast.JA['Spur'] = {
    feet = 'Nukumi Ocreae +3',
    back = Artio.PETSTP
}

-- Default/fallback precast sets
sets.precast.JA['Misc Idle'] = {
    hands = 'Ankusa Gloves +3',
    legs = "Gleti's Breeches"
}
sets.precast.JA['Default'] = sets.precast.JA['Misc Idle']

--============================================================--
--                  PET READY MOVE GEAR SETS                  --
--============================================================--

-- Single-hit physical Ready moves
sets.midcast.pet_physical_moves = {
    ammo = 'Hesperiidae',
    head = PhysMultiGear.head,
    body = PhysMultiGear.body,
    hands = PhysMultiGear.hands,
    legs = PhysMultiGear.legs,
    feet = PhysMultiGear.feet,
    neck = NECK.BstCollar,
    waist = 'Incarnation Sash',
    left_ear = EARRINGS.Sroda,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Varar2,
    right_ring = RINGS.CPalug,
    back = Artio.PETSTP
}

-- Multi-hit physical Ready moves
sets.midcast.pet_physicalMulti_moves = set_combine(sets.midcast.pet_physical_moves, {})

-- Magical attack Ready moves
sets.midcast.pet_magicAtk_moves = {
    ammo = 'Hesperiidae',
    head = MabGear.head,
    body = MabGear.body,
    hands = MabGear.hands,
    legs = MabGear.legs,
    feet = MabGear.feet,
    neck = NECK.Adad,
    waist = 'Incarnation Sash',
    left_ear = EARRINGS.Hija,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Tali,
    right_ring = RINGS.CPalug,
    back = Artio.PETMB
}

-- Magical accuracy Ready moves (debuffs, buffs)
sets.midcast.pet_magicAcc_moves = set_combine(sets.midcast.pet_magicAtk_moves, {})

-- Set for when pet uses magic while wielding a weapon
sets.midcast.pet_magicAtk_moves_ww = sets.midcast.pet_magicAtk_moves
sets.midcast.pet_magicAcc_moves_ww = sets.midcast.pet_magicAcc_moves

--============================================================--

--                     WEAPON SKILL SETS                      --
--============================================================--

-- Default WS set (STR/DEX hybrid)
sets.precast.WS = {
    ammo = "Oshasha's Treatise",
    head = 'Ankusa Helm +3',
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = "Gleti's Breeches",
    feet = 'Nukumi Ocreae +3',
    neck = NECK.BstCollar,
    waist = 'Fotia Belt',
    left_ear = EARRINGS.Sroda,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Gere,
    right_ring = RINGS.Hetairoi,
    back = Artio.WS1
}

-- Primal Rend (MAB WS)
sets.precast.WS['Primal Rend'] = {
    ammo = 'Ghastly Tathlum +1',
    head = 'Nyame Helm',
    body = 'Nyame Mail',
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nyame Sollerets',
    neck = NECK.Sibyl,
    waist = "Orpheus's Sash",
    left_ear = EARRINGS.Sortiarius,
    right_ear = EARRINGS.Friomisi,
    left_ring = RINGS.Cornelia,
    right_ring = RINGS.Metamorph,
    back = Artio.WS1
}

sets.precast.WS['Decimation'] = {
    ammo = 'Coiste Bodhar',
    head = 'Nuk. Cabasset +3',
    body = "Gleti's Cuirass",
    hands = "Gleti's Gauntlets",
    legs = 'Nukumi Quijotes +3',
    feet = 'Nukumi Ocreae +3',
    neck = 'Bst. Collar +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Sherida Earring',
    ear2 = 'Nukumi Earring +1',
    ring1 = 'Sroda Ring',
    ring2 = 'Gere Ring',
    back = Artio.WS1
}

sets.precast.WS['Bora Axe'] = {
    ammo = 'Crepuscular Pebble',
    head = 'Ankusa Helm +3',
    body = "Gleti's Cuirass",
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nukumi Ocreae +3',
    neck = 'Bst. Collar +2',
    waist = 'Sailfi Belt +1',
    ear1 = 'Odnowa Earring +1',
    ear2 = 'Nukumi Earring +1',
    ring1 = 'Defending Ring',
    ring2 = "Cornelia's ring",
    back = Artio.WS1
}

-- Calamity (physical WS)
sets.precast.WS['Calamity'] = {
    ammo = 'Crepuscular Pebble',
    head = 'Nyame Helm',
    body = "Gleti's Cuirass",
    hands = 'Nyame Gauntlets',
    legs = 'Nyame Flanchard',
    feet = 'Nukumi Ocreae +3',
    neck = NECK.BstCollar,
    waist = 'Sailfi Belt +1',
    left_ear = EARRINGS.Thrud,
    right_ear = EARRINGS.Nukumi,
    left_ring = RINGS.Cornelia,
    right_ring = RINGS.Defending,
    back = Artio.WS1
}

--============================================================--
--                     TPBonus Sets (Moonshade)               --
--============================================================--

-- Default TPBonus Set (Moonshade Earring for TP scaling)
sets.precast.WS.TPBonus = {
    left_ear = 'Moonshade Earring' -- TP Bonus +250
}

-- TPBonus variants for weapon skills
sets.precast.WS['Primal Rend'].TPBonus = set_combine(sets.precast.WS['Primal Rend'], sets.precast.WS.TPBonus)
sets.precast.WS['Decimation'].TPBonus = set_combine(sets.precast.WS['Decimation'], sets.precast.WS.TPBonus)
sets.precast.WS['Bora Axe'].TPBonus = set_combine(sets.precast.WS['Bora Axe'], sets.precast.WS.TPBonus)
sets.precast.WS['Calamity'].TPBonus = set_combine(sets.precast.WS['Calamity'], sets.precast.WS.TPBonus)

--============================================================--
--                     UTILITY GEARSETS                       --
--============================================================--

-- Movement speed set
sets.MoveSpeed = {
    feet = 'Skd. Jambeaux +1'
}

-- Doom resistance set
sets.buff = sets.buff or {}
sets.buff.Doom = {
    neck = RINGS.Nicander,
    ring1 = RINGS.Purity,
    waist = 'Gishdubar Sash'
}

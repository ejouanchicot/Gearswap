---============================================================================
--- BLU Spell Map - which Blue Magic spell wears which midcast set
---============================================================================
--- Each category names the set a spell wears:
---     sets.midcast['Blue Magic'].<Category>       e.g. .PhysicalDex, .Magical
---     sets.midcast['Blue Magic'].<Category>.Resistant   with CastingMode Resistant
--- A spell listed nowhere takes the broad category of the Blue Magic
--- database (Physical, Magical, Buff, Breath, Healing, or MagicAccuracy for
--- a debuff), and sets.midcast['Blue Magic'] itself when that set is missing.
--- A spell with its own set (sets.midcast['White Wind']) wears that one first.
--- Spell names are the game's (res/spells.lua): 'Winds of Promy.',
--- 'Tail Slap', 'Quad. Continuum', 'Evryone. Grudge'...
--- A spell in two categories keeps the first by alphabetical order of
--- category, and a warning names it on load.
---
--- Default: the Mote-Include Blue Mage categories, as Gabvanstronger's BLU
--- file listed them (blue_magic_maps), with its fixes:
---   'Tail slap' -> 'Tail Slap', 'Winds of Promyvion' -> 'Winds of Promy.';
---   'Orcish Counterstance' -> 'O. Counterstance' (the game's name);
---   spells he listed twice kept in one category: Mind Blast (MagicalMnd),
---   Sub-zero Smash (PhysicalVit), Hecatomb Wave (Breath), Exuviation (Enmity).
---
--- Added 2026-09-27, from BG-Wiki's stat modifiers (WSC):
---   Sweeping Gouge 30% VIT, Uproot 40% VIT, Polar Roar 20% STR 20% INT,
---   Crashing Thunder 30% AGI (no MagicalAgi set: Magical); Tearing Gust
---   and Cesspool undocumented (Magical); Saurian Slide undocumented,
---   PhysicalStr as in Arislan's list; Atra. Libations and Sound Blast
---   depend on magic accuracy, not damage stats.
--- Whether a spell needs Unbridled Learning is read from the database, not
--- from this map.
---
--- @file    config/blu/BLU_SPELL_MAP.lua
--- @author  ejouanchicot
--- @version 1.1
--- @date    Created: 2026-09-26 | Updated: 2026-09-27
---============================================================================

return {
    Physical = {
        'Bilgestorm',
    },
    PhysicalAcc = {
        'Heavy Strike',
    },
    PhysicalStr = {
        'Battle Dance', 'Bloodrake', 'Death Scissors', 'Dimensional Death',
        'Empty Thrash', 'Quadrastrike', 'Saurian Slide', 'Sinker Drill', 'Spinal Cleave', 'Uppercut',
        'Vertical Cleave',
    },
    PhysicalDex = {
        'Amorphic Spikes', 'Asuran Claws', 'Barbed Crescent', 'Claw Cyclone',
        'Disseverment', 'Foot Kick', 'Frenetic Rip', 'Goblin Rush',
        'Hysteric Barrage', 'Paralyzing Triad', 'Seedspray', 'Sickle Slash',
        'Smite of Rage', 'Terror Touch', 'Thrashing Assault', 'Vanity Dive',
    },
    PhysicalVit = {
        'Body Slam', 'Cannonball', 'Delta Thrust', 'Glutinous Dart', 'Grand Slam',
        'Power Attack', 'Quad. Continuum', 'Sprout Smack', 'Sub-zero Smash',
        'Sweeping Gouge',
    },
    PhysicalAgi = {
        'Benthic Typhoon', 'Feather Storm', 'Helldive', 'Hydro Shot', 'Jet Stream',
        'Pinecone Bomb', 'Spiral Spin', 'Wild Oats',
    },
    PhysicalInt = {
        'Mandibular Bite', 'Queasyshroom',
    },
    PhysicalMnd = {
        'Ram Charge', 'Screwdriver',
    },
    PhysicalChr = {
        'Bludgeon',
    },
    PhysicalHP = {
        'Final Sting',
    },
    Magical = {
        'Blastbomb', 'Blazing Bound', 'Bomb Toss', 'Cursed Sphere', 'Dark Orb',
        'Death Ray', 'Diffusion Ray', 'Droning Whirlwind', 'Embalming Earth',
        'Firespit', 'Foul Waters', 'Ice Break', 'Leafstorm', 'Maelstrom',
        'Rail Cannon', 'Regurgitation', 'Rending Deluge', 'Retinal Glare',
        'Subduction', 'Tem. Upheaval', 'Water Bomb', 'Molting Plumage',
        'Nectarous Deluge', 'Searing Tempest', 'Blinding Fulgor', 'Spectral Floe',
        'Scouring Spate', 'Anvil Lightning', 'Tenebral Crush', 'Palling Salvo',
        'Crashing Thunder', 'Polar Roar', 'Tearing Gust', 'Cesspool',
    },
    MagicalEarth = {
        'Entomb',
    },
    MagicalMnd = {
        'Acrid Stream', 'Evryone. Grudge', 'Magic Hammer', 'Mind Blast',
    },
    MagicalChr = {
        'Eyes On Me', 'Mysterious Light',
    },
    MagicalVit = {
        'Thermal Pulse', 'Uproot',
    },
    MagicalDex = {
        'Charged Whisker', 'Gates of Hades',
    },
    MagicAccuracy = {
        '1000 Needles', 'Absolute Terror', 'Auroral Drape', 'Awful Eye',
        'Blank Gaze', 'Blistering Roar', 'Blood Drain', 'Blood Saber',
        'Chaotic Eye', 'Cimicine Discharge', 'Cold Wave', 'Corrosive Ooze',
        'Demoralizing Roar', 'Digest', 'Dream Flower', 'Enervation',
        'Filamented Hold', 'Frightful Roar', 'Geist Wall', 'Infrasonics',
        'Jettatura', 'Light of Penance', 'Lowing', 'Mortal Ray', 'MP Drainkiss',
        'Osmosis', 'Sandspin', 'Sandspray', 'Sheep Song', 'Soporific', 'Stinking Gas',
        'Venom Shell', 'Voracious Trunk', 'Yawn', 'Cruel Joke', 'Silent Storm',
        'Tourbillion', 'Atra. Libations', 'Sound Blast',
    },
    TPRemoval = {
        'Reaving Wind', 'Feather Tickle',
    },
    Enmity = {
        'Actinic Burst', 'Temporal Shift', 'Fantod', 'Exuviation',
    },
    Breath = {
        'Bad Breath', 'Flying Hip Press', 'Frost Breath', 'Heat Breath',
        'Hecatomb Wave', 'Magnetite Cloud', 'Poison Breath', 'Radiant Breath',
        'Self-Destruct', 'Thunder Breath', 'Vapor Spray', 'Wind Breath',
    },
    Stun = {
        'Blitzstrahl', 'Frypan', 'Head Butt', 'Sudden Lunge', 'Tail Slap',
        'Thunderbolt', 'Whirl of Rage',
    },
    Healing = {
        'Healing Breeze', 'Magic Fruit', 'Plenilune Embrace', 'Pollen',
        'Wild Carrot',
    },
    -- Not Healing, as Gabvanstronger's file had it: White Wind scales with
    -- max HP, Restoral with Blue Magic skill, each wears its own set
    -- (sets.midcast['White Wind']...). A Healing spell cast on oneself also
    -- gets sets.self_healing on top, which would cover that set. Unlisted,
    -- the database would make them Healing again.
    HealingHP = {
        'White Wind',
    },
    HealingSkill = {
        'Restoral',
    },
    SkillBasedBuff = {
        'Barrier Tusk', 'Diamondhide', 'Magic Barrier', 'Metallic Body',
        'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool',
    },
    Buff = {
        'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
        'Cocoon', 'Erratic Flutter', 'Feather Barrier', 'Harden Shell',
        'Memento Mori', 'Nat. Meditation', 'Refueling', 'Regeneration',
        'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
        'Zephyr Mantle', 'Mighty Guard', 'O. Counterstance',
    },
}

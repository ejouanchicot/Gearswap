---============================================================================
--- BLU Spell Map - which Blue Magic spell wears which midcast set
---============================================================================
--- Each category names the set a spell wears:
---     sets.midcast['Blue Magic'].<Category>       e.g. .PhysicalDex, .Magical
---     sets.midcast['Blue Magic'].<Category>.Resistant   with CastingMode Resistant
--- A spell listed nowhere wears sets.midcast['Blue Magic'] itself; a spell
--- with its own set (sets.midcast['White Wind']) wears that one first.
--- Spell names are the game's (res/spells.lua): 'Winds of Promy.',
--- 'Tail Slap', 'Quad. Continuum', 'Evryone. Grudge'...
--- A spell in two categories keeps the first by alphabetical order of
--- category, and a warning names it on load.
---
--- Default: the Mote-Include Blue Mage categories, as Gabvanstronger's BLU
--- file listed them (blue_magic_maps), with its fixes:
---   'Tail slap' -> 'Tail Slap', 'Winds of Promyvion' -> 'Winds of Promy.';
---   'Orcish Counterstance' dropped (no such spell in the game);
---   spells he listed twice kept in one category: Mind Blast (MagicalMnd),
---   Sub-zero Smash (PhysicalVit), Hecatomb Wave (Breath), Exuviation (Enmity).
---
--- Unbridled spells are not listed here: they come from the Blue Magic
--- database (shared/data/magic/BLU_SPELL_DATABASE.lua).
---
--- @file    config/blu/BLU_SPELL_MAP.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-09-26
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
        'Empty Thrash', 'Quadrastrike', 'Sinker Drill', 'Spinal Cleave', 'Uppercut',
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
        'Thermal Pulse',
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
        'Tourbillion',
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
    SkillBasedBuff = {
        'Barrier Tusk', 'Diamondhide', 'Magic Barrier', 'Metallic Body',
        'Occultation', 'Plasma Charge', 'Pyric Bulwark', 'Reactor Cool',
    },
    Buff = {
        'Amplification', 'Animating Wail', 'Battery Charge', 'Carcharian Verve',
        'Cocoon', 'Erratic Flutter', 'Feather Barrier', 'Harden Shell',
        'Memento Mori', 'Nat. Meditation', 'Refueling', 'Regeneration',
        'Saline Coat', 'Triumphant Roar', 'Warm-Up', 'Winds of Promy.',
        'Zephyr Mantle',
    },
}

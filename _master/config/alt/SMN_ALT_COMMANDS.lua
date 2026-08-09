---============================================================================
--- SMN Alt Commands - what the alt does when it is on SMN
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether SMN is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in SMN_ALT_CUSTOM.lua, which is
--- merged on top of this file and never regenerated.
---
--- Sources: the project's own data decides what exists and at which level
--- (shared/data/job_abilities/ and shared/data/magic/), res/spells.lua and
--- res/job_abilities.lua supply targeting.
---
--- Abilities carry `level`, spells carry every tier with the level it needs.
--- The engine picks the highest the alt is high enough for, from the level it
--- reported - a subjob caps far below a main (Master Level 50 reaches sub 58).
--- `main_only` entries disappear entirely when the job is the subjob.
---
--- @file    config/alt/SMN_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- ELEMENTAL - select the mob first
    -- ========================================================================
    impact           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },

    -- ========================================================================
    -- AVATARS - summoned on the alt
    -- ========================================================================
    airspirit        = { action = 'ma', spell = 'Air Spirit',             target = 'me', level = 1, group = 'summon', desc = 'Summons Air Spirit.' },
    alexander        = { action = 'ma', spell = 'Alexander',              target = 'me', level = 75, group = 'summon', desc = 'Summons Alexander.' },
    atomos           = { action = 'ma', spell = 'Atomos',                 target = 'me', level = 75, group = 'summon', desc = 'Summons Atomos.' },
    caitsith         = { action = 'ma', spell = 'Cait Sith',              target = 'me', level = 30, group = 'summon', desc = 'Summons Cait Sith.' },
    carbuncle        = { action = 'ma', spell = 'Carbuncle',              target = 'me', level = 1, group = 'summon', desc = 'Summons Carbuncle.' },
    darkspirit       = { action = 'ma', spell = 'Dark Spirit',            target = 'me', level = 1, group = 'summon', desc = 'Summons Dark Spirit.' },
    diabolos         = { action = 'ma', spell = 'Diabolos',               target = 'me', level = 20, group = 'summon', desc = 'Summons Diabolos.' },
    earthspirit      = { action = 'ma', spell = 'Earth Spirit',           target = 'me', level = 1, group = 'summon', desc = 'Summons Earth Spirit.' },
    fenrir           = { action = 'ma', spell = 'Fenrir',                 target = 'me', level = 1, group = 'summon', desc = 'Summons Fenrir.' },
    firespirit       = { action = 'ma', spell = 'Fire Spirit',            target = 'me', level = 1, group = 'summon', desc = 'Summons Fire Spirit.' },
    garuda           = { action = 'ma', spell = 'Garuda',                 target = 'me', level = 1, group = 'summon', desc = 'Summons Garuda.' },
    icespirit        = { action = 'ma', spell = 'Ice Spirit',             target = 'me', level = 1, group = 'summon', desc = 'Summons Ice Spirit.' },
    ifrit            = { action = 'ma', spell = 'Ifrit',                  target = 'me', level = 1, group = 'summon', desc = 'Summons Ifrit.' },
    leviathan        = { action = 'ma', spell = 'Leviathan',              target = 'me', level = 1, group = 'summon', desc = 'Summons Leviathan.' },
    lightspirit      = { action = 'ma', spell = 'Light Spirit',           target = 'me', level = 1, group = 'summon', desc = 'Summons Light Spirit.' },
    odin             = { action = 'ma', spell = 'Odin',                   target = 'me', level = 75, group = 'summon', desc = 'Summons Odin.' },
    ramuh            = { action = 'ma', spell = 'Ramuh',                  target = 'me', level = 1, group = 'summon', desc = 'Summons Ramuh.' },
    shiva            = { action = 'ma', spell = 'Shiva',                  target = 'me', level = 1, group = 'summon', desc = 'Summons Shiva.' },
    siren            = { action = 'ma', spell = 'Siren',                  target = 'me', level = 75, group = 'summon', desc = 'Summons Siren.' },
    thunderspirit    = { action = 'ma', spell = 'Thunder Spirit',         target = 'me', level = 1, group = 'summon', desc = 'Summons Thunder Spirit.' },
    titan            = { action = 'ma', spell = 'Titan',                  target = 'me', level = 1, group = 'summon', desc = 'Summons Titan.' },
    waterspirit      = { action = 'ma', spell = 'Water Spirit',           target = 'me', level = 1, group = 'summon', desc = 'Summons Water Spirit.' },

    -- ========================================================================
    -- BLOOD PACT: RAGE - select the mob first
    -- ========================================================================
    aerialblast      = { action = 'pet', spell = 'Aerial Blast',           target = 'lastst', level = 1, group = 'rage', desc = 'Garuda - Deals wind damage (AoE). (Astral Flow only)' },
    aeroii           = { action = 'pet', spell = 'Aero II',                target = 'lastst', level = 10, group = 'rage', desc = 'Garuda - Deals wind damage.' },
    aeroiv           = { action = 'pet', spell = 'Aero IV',                target = 'lastst', level = 60, group = 'rage', desc = 'Garuda - Deals wind damage.' },
    axekick          = { action = 'pet', spell = 'Axe Kick',               target = 'lastst', level = 1, group = 'rage', desc = 'Shiva - Deals physical dmg.' },
    barracudadive    = { action = 'pet', spell = 'Barracuda Dive',         target = 'lastst', level = 1, group = 'rage', desc = 'Leviathan - Deals physical dmg.' },
    blindside        = { action = 'pet', spell = 'Blindside',              target = 'lastst', level = 99, group = 'rage', desc = 'Diabolos - Deals physical dmg (ignores Utsusemi).' },
    blizzardii       = { action = 'pet', spell = 'Blizzard II',            target = 'lastst', level = 10, group = 'rage', desc = 'Shiva - Deals ice damage.' },
    blizzardiv       = { action = 'pet', spell = 'Blizzard IV',            target = 'lastst', level = 60, group = 'rage', desc = 'Shiva - Deals ice damage.' },
    burningstrike    = { action = 'pet', spell = 'Burning Strike',         target = 'lastst', level = 23, group = 'rage', desc = 'Ifrit - Deals fire physical dmg.' },
    camisado         = { action = 'pet', spell = 'Camisado',               target = 'lastst', level = 1, group = 'rage', desc = 'Diabolos - Deals physical dmg + darkness.' },
    chaoticstrike    = { action = 'pet', spell = 'Chaotic Strike',         target = 'lastst', level = 70, group = 'rage', desc = 'Ramuh - Deals thunder physical dmg + stun.' },
    clarsachcall     = { action = 'pet', spell = 'Clarsach Call',          target = 'lastst', level = 1, group = 'rage', desc = 'Siren - Deals wind damage + buffs (AoE). (Astral Flow only)' },
    claw             = { action = 'pet', spell = 'Claw',                   target = 'lastst', level = 1, group = 'rage', desc = 'Garuda - Deals physical dmg.' },
    conflagstrike    = { action = 'pet', spell = 'Conflag Strike',         target = 'lastst', level = 99, group = 'rage', desc = 'Ifrit - Deals fire physical dmg (multi-hit).' },
    cragthrow        = { action = 'pet', spell = 'Crag Throw',             target = 'lastst', level = 99, group = 'rage', desc = 'Titan - Deals earth physical dmg + slow.' },
    crescentfang     = { action = 'pet', spell = 'Crescent Fang',          target = 'lastst', level = 10, group = 'rage', desc = 'Fenrir - Deals 3-fold physical dmg + paralyze.' },
    diamonddust      = { action = 'pet', spell = 'Diamond Dust',           target = 'lastst', level = 1, group = 'rage', desc = 'Shiva - Deals ice damage (AoE). (Astral Flow only)' },
    doublepunch      = { action = 'pet', spell = 'Double Punch',           target = 'lastst', level = 30, group = 'rage', desc = 'Ifrit - Deals 2-fold physical dmg.' },
    doubleslap       = { action = 'pet', spell = 'Double Slap',            target = 'lastst', level = 50, group = 'rage', desc = 'Shiva - Deals 2-fold physical dmg.' },
    earthenfury      = { action = 'pet', spell = 'Earthen Fury',           target = 'lastst', level = 1, group = 'rage', desc = 'Titan - Deals earth damage (AoE). (Astral Flow only)' },
    eclipsebite      = { action = 'pet', spell = 'Eclipse Bite',           target = 'lastst', level = 65, group = 'rage', desc = 'Fenrir - Deals physical dmg + blindness.' },
    fireii           = { action = 'pet', spell = 'Fire II',                target = 'lastst', level = 10, group = 'rage', desc = 'Ifrit - Deals fire damage.' },
    fireiv           = { action = 'pet', spell = 'Fire IV',                target = 'lastst', level = 60, group = 'rage', desc = 'Ifrit - Deals fire damage.' },
    flamingcrush     = { action = 'pet', spell = 'Flaming Crush',          target = 'lastst', level = 70, group = 'rage', desc = 'Ifrit - Deals fire physical dmg.' },
    geocrush         = { action = 'pet', spell = 'Geocrush',               target = 'lastst', level = 75, group = 'rage', desc = 'Titan - Deals earth physical dmg (AoE).' },
    grandfall        = { action = 'pet', spell = 'Grand Fall',             target = 'lastst', level = 75, group = 'rage', desc = 'Leviathan - Deals water physical dmg (multi-hit).' },
    heavenlystrike   = { action = 'pet', spell = 'Heavenly Strike',        target = 'lastst', level = 75, group = 'rage', desc = 'Shiva - Deals ice physical dmg (AoE).' },
    holymist         = { action = 'pet', spell = 'Holy Mist',              target = 'lastst', level = 76, group = 'rage', desc = 'Carbuncle - Deals light damage (AoE).' },
    howlingmoon      = { action = 'pet', spell = 'Howling Moon',           target = 'lastst', level = 1, group = 'rage', desc = 'Fenrir - Deals dark damage (AoE). (Astral Flow only)' },
    hystericassault  = { action = 'pet', spell = 'Hysteric Assault',       target = 'lastst', level = 99, group = 'rage', desc = 'Siren - Deals triple attack + HP drain.' },
    impactbp         = { action = 'pet', spell = 'Impact',                 target = 'lastst', level = 99, group = 'rage', desc = 'Fenrir - Deals dark damage + stat down (AoE).' },
    inferno          = { action = 'pet', spell = 'Inferno',                target = 'lastst', level = 1, group = 'rage', desc = 'Ifrit - Deals fire damage (AoE). (Astral Flow only)' },
    judgmentbolt     = { action = 'pet', spell = 'Judgment Bolt',          target = 'lastst', level = 1, group = 'rage', desc = 'Ramuh - Deals thunder damage (AoE). (Astral Flow only)' },
    levelholy        = { action = 'pet', spell = 'Level ? Holy',           target = 'lastst', level = 75, group = 'rage', desc = 'Cait Sith - Deals light damage (level-based).' },
    lunarbay         = { action = 'pet', spell = 'Lunar Bay',              target = 'lastst', level = 78, group = 'rage', desc = 'Fenrir - Deals dark damage (AoE).' },
    megaliththrow    = { action = 'pet', spell = 'Megalith Throw',         target = 'lastst', level = 35, group = 'rage', desc = 'Titan - Deals physical dmg + slow.' },
    meteorstrike     = { action = 'pet', spell = 'Meteor Strike',          target = 'lastst', level = 75, group = 'rage', desc = 'Ifrit - Deals fire physical dmg (AoE).' },
    meteorite        = { action = 'pet', spell = 'Meteorite',              target = 'lastst', level = 55, group = 'rage', desc = 'Carbuncle - Deals light damage (AoE).' },
    moonlitcharge    = { action = 'pet', spell = 'Moonlit Charge',         target = 'lastst', level = 5, group = 'rage', desc = 'Fenrir - Deals physical dmg + blindness.' },
    mountainbuster   = { action = 'pet', spell = 'Mountain Buster',        target = 'lastst', level = 70, group = 'rage', desc = 'Titan - Deals earth physical dmg.' },
    netherblast      = { action = 'pet', spell = 'Nether Blast',           target = 'lastst', level = 65, group = 'rage', desc = 'Diabolos - Deals dark damage.' },
    nightterror      = { action = 'pet', spell = 'Night Terror',           target = 'lastst', level = 80, group = 'rage', desc = 'Diabolos - Deals dark damage (AoE).' },
    poisonnails      = { action = 'pet', spell = 'Poison Nails',           target = 'lastst', level = 5, group = 'rage', desc = 'Carbuncle - Deals physical dmg + poison.' },
    predatorclaws    = { action = 'pet', spell = 'Predator Claws',         target = 'lastst', level = 70, group = 'rage', desc = 'Garuda - Deals wind physical dmg.' },
    punch            = { action = 'pet', spell = 'Punch',                  target = 'lastst', level = 1, group = 'rage', desc = 'Ifrit - Deals physical dmg.' },
    regalgash        = { action = 'pet', spell = 'Regal Gash',             target = 'lastst', level = 99, group = 'rage', desc = 'Cait Sith - Restores HP + removes ailments.' },
    regalscratch     = { action = 'pet', spell = 'Regal Scratch',          target = 'lastst', level = 1, group = 'rage', desc = 'Cait Sith - Deals physical dmg + dispel.' },
    rockbuster       = { action = 'pet', spell = 'Rock Buster',            target = 'lastst', level = 21, group = 'rage', desc = 'Titan - Deals earth physical dmg + bind.' },
    rockthrow        = { action = 'pet', spell = 'Rock Throw',             target = 'lastst', level = 1, group = 'rage', desc = 'Titan - Deals physical dmg + slow.' },
    roundhouse       = { action = 'pet', spell = 'Roundhouse',             target = 'lastst', level = 25, group = 'rage', desc = 'Siren - Deals physical dmg.' },
    ruinousomen      = { action = 'pet', spell = 'Ruinous Omen',           target = 'lastst', level = 1, group = 'rage', desc = 'Diabolos - Deals dark damage (AoE). (Astral Flow only)' },
    rush             = { action = 'pet', spell = 'Rush',                   target = 'lastst', level = 70, group = 'rage', desc = 'Shiva - Deals 4-fold physical dmg.' },
    searinglight     = { action = 'pet', spell = 'Searing Light',          target = 'lastst', level = 1, group = 'rage', desc = 'Carbuncle - Deals light damage (AoE). (Astral Flow only)' },
    shockstrike      = { action = 'pet', spell = 'Shock Strike',           target = 'lastst', level = 1, group = 'rage', desc = 'Ramuh - Deals physical dmg + stun.' },
    sonicbuffet      = { action = 'pet', spell = 'Sonic Buffet',           target = 'lastst', level = 65, group = 'rage', desc = 'Siren - Deals wind damage + dispel (AoE).' },
    spinningdive     = { action = 'pet', spell = 'Spinning Dive',          target = 'lastst', level = 70, group = 'rage', desc = 'Leviathan - Deals water physical dmg.' },
    stoneii          = { action = 'pet', spell = 'Stone II',               target = 'lastst', level = 10, group = 'rage', desc = 'Titan - Deals earth damage.' },
    stoneiv          = { action = 'pet', spell = 'Stone IV',               target = 'lastst', level = 60, group = 'rage', desc = 'Titan - Deals earth damage.' },
    tailwhip         = { action = 'pet', spell = 'Tail Whip',              target = 'lastst', level = 26, group = 'rage', desc = 'Leviathan - Deals water physical dmg (AoE).' },
    thunderii        = { action = 'pet', spell = 'Thunder II',             target = 'lastst', level = 10, group = 'rage', desc = 'Ramuh - Deals thunder damage.' },
    thunderiv        = { action = 'pet', spell = 'Thunder IV',             target = 'lastst', level = 60, group = 'rage', desc = 'Ramuh - Deals thunder damage.' },
    thunderspark     = { action = 'pet', spell = 'Thunderspark',           target = 'lastst', level = 19, group = 'rage', desc = 'Ramuh - Deals thunder physical dmg + paralyze (AoE).' },
    thunderstorm     = { action = 'pet', spell = 'Thunderstorm',           target = 'lastst', level = 75, group = 'rage', desc = 'Ramuh - Deals thunder damage (AoE).' },
    tidalwave        = { action = 'pet', spell = 'Tidal Wave',             target = 'lastst', level = 1, group = 'rage', desc = 'Leviathan - Deals water damage (AoE). (Astral Flow only)' },
    tornadoii        = { action = 'pet', spell = 'Tornado II',             target = 'lastst', level = 75, group = 'rage', desc = 'Siren - Deals wind damage.' },
    voltstrike       = { action = 'pet', spell = 'Volt Strike',            target = 'lastst', level = 99, group = 'rage', desc = 'Ramuh - Deals thunder physical dmg + stun (multi-hit).' },
    waterii          = { action = 'pet', spell = 'Water II',               target = 'lastst', level = 10, group = 'rage', desc = 'Leviathan - Deals water damage.' },
    wateriv          = { action = 'pet', spell = 'Water IV',               target = 'lastst', level = 60, group = 'rage', desc = 'Leviathan - Deals water damage.' },
    welt             = { action = 'pet', spell = 'Welt',                   target = 'lastst', level = 1, group = 'rage', desc = 'Siren - Deals physical dmg.' },
    windblade        = { action = 'pet', spell = 'Wind Blade',             target = 'lastst', level = 75, group = 'rage', desc = 'Garuda - Deals wind physical dmg.' },
    zantetsuken      = { action = 'pet', spell = 'Zantetsuken',            target = 'lastst', level = 75, group = 'rage', desc = 'Odin - Attempts instant KO (AoE).' },

    -- ========================================================================
    -- BLOOD PACT: WARD
    -- ========================================================================
    aerialarmor      = { action = 'pet', spell = 'Aerial Armor',           target = 'me', level = 25, group = 'ward', desc = 'Garuda - Boosts evasion.' },
    altanasfavor     = { action = 'pet', spell = "Altana's Favor",         target = 'me', level = 1, group = 'ward', desc = 'Cait Sith - Grants party buffs. (Astral Flow only)' },
    bitterelegy      = { action = 'pet', spell = 'Bitter Elegy',           target = 'lastst', level = 50, group = 'ward', desc = 'Siren - Inflicts elegy.' },
    chinook          = { action = 'pet', spell = 'Chinook',                target = 'me', level = 42, group = 'ward', desc = 'Siren - Grants aquaveil (AoE).' },
    chronoshift      = { action = 'pet', spell = 'Chronoshift',            target = 'lastst', level = 75, group = 'ward', desc = 'Atomos - Party Haste; enemy Slow.' },
    crimsonhowl      = { action = 'pet', spell = 'Crimson Howl',           target = 'me', level = 38, group = 'ward', desc = 'Ifrit - Boosts attack (AoE).' },
    crystalblessing  = { action = 'pet', spell = 'Crystal Blessing',       target = 'me', level = 99, group = 'ward', desc = 'Shiva - Boosts max HP (AoE).' },
    deconstruction   = { action = 'pet', spell = 'Deconstruction',         target = 'lastst', level = 75, group = 'ward', desc = 'Atomos - Lowers defense (AoE).' },
    diamondstorm     = { action = 'pet', spell = 'Diamond Storm',          target = 'lastst', level = 90, group = 'ward', desc = 'Shiva - Deals ice damage (AoE).' },
    dreamshroud      = { action = 'pet', spell = 'Dream Shroud',           target = 'me', level = 56, group = 'ward', desc = 'Diabolos - Boosts magic attack + accuracy (AoE).' },
    earthenarmor     = { action = 'pet', spell = 'Earthen Armor',          target = 'me', level = 88, group = 'ward', desc = 'Titan - Boosts defense (AoE).' },
    earthenward      = { action = 'pet', spell = 'Earthen Ward',           target = 'me', level = 46, group = 'ward', desc = 'Titan - Grants stoneskin (AoE).' },
    eclipticgrowl    = { action = 'pet', spell = 'Ecliptic Growl',         target = 'me', level = 43, group = 'ward', desc = 'Fenrir - Boosts accuracy + evasion.' },
    ecliptichowl     = { action = 'pet', spell = 'Ecliptic Howl',          target = 'me', level = 54, group = 'ward', desc = 'Fenrir - Boosts accuracy + evasion (AoE).' },
    eerieeye         = { action = 'pet', spell = 'Eerie Eye',              target = 'lastst', level = 55, group = 'ward', desc = 'Cait Sith - Inflicts silence + amnesia (cone).' },
    fleetwind        = { action = 'pet', spell = 'Fleet Wind',             target = 'me', level = 86, group = 'ward', desc = 'Garuda - Deals wind damage (AoE).' },
    frostarmor       = { action = 'pet', spell = 'Frost Armor',            target = 'me', level = 28, group = 'ward', desc = 'Shiva - Grants ice spikes.' },
    glitteringruby   = { action = 'pet', spell = 'Glittering Ruby',        target = 'me', level = 44, group = 'ward', desc = 'Carbuncle - Restores HP (AoE).' },
    hastega          = { action = 'pet', spell = 'Hastega',                target = 'me', level = 48, group = 'ward', desc = 'Garuda - Boosts attack speed (AoE).' },
    hastegaii        = { action = 'pet', spell = 'Hastega II',             target = 'me', level = 99, group = 'ward', desc = 'Garuda - Boosts attack speed (AoE).' },
    healingruby      = { action = 'pet', spell = 'Healing Ruby',           target = 'lastst', level = 1, group = 'ward', desc = 'Carbuncle - Restores HP.' },
    healingrubyii    = { action = 'pet', spell = 'Healing Ruby II',        target = 'me', level = 65, group = 'ward', desc = 'Carbuncle - Restores HP (strong).' },
    heavenwardhowl   = { action = 'pet', spell = 'Heavenward Howl',        target = 'me', level = 96, group = 'ward', desc = 'Fenrir - Grants drain + aspir effect.' },
    infernohowl      = { action = 'pet', spell = 'Inferno Howl',           target = 'me', level = 88, group = 'ward', desc = 'Ifrit - Boosts attack + accuracy (AoE).' },
    katabaticblades  = { action = 'pet', spell = 'Katabatic Blades',       target = 'me', level = 31, group = 'ward', desc = 'Siren - Grants enaero (AoE).' },
    lightningarmor   = { action = 'pet', spell = 'Lightning Armor',        target = 'me', level = 42, group = 'ward', desc = 'Ramuh - Grants shock spikes (AoE).' },
    lunarcry         = { action = 'pet', spell = 'Lunar Cry',              target = 'lastst', level = 21, group = 'ward', desc = 'Fenrir - Lowers accuracy + evasion (AoE).' },
    lunarroar        = { action = 'pet', spell = 'Lunar Roar',             target = 'lastst', level = 32, group = 'ward', desc = 'Fenrir - Removes beneficial effects (AoE).' },
    lunaticvoice     = { action = 'pet', spell = 'Lunatic Voice',          target = 'lastst', level = 15, group = 'ward', desc = 'Siren - Inflicts silence (AoE).' },
    mewinglullaby    = { action = 'pet', spell = 'Mewing Lullaby',         target = 'lastst', level = 25, group = 'ward', desc = 'Cait Sith - Inflicts sleep + TP reduction (AoE).' },
    nightmare        = { action = 'pet', spell = 'Nightmare',              target = 'lastst', level = 29, group = 'ward', desc = 'Diabolos - Inflicts sleep + bio dmg (AoE).' },
    noctoshield      = { action = 'pet', spell = 'Noctoshield',            target = 'me', level = 49, group = 'ward', desc = 'Diabolos - Grants damage shield (AoE).' },
    pacifyingruby    = { action = 'pet', spell = 'Pacifying Ruby',         target = 'lastst', level = 99, group = 'ward', desc = 'Carbuncle - Removes one enfeebling effect.' },
    pavornocturnus   = { action = 'pet', spell = 'Pavor Nocturnus',        target = 'lastst', level = 98, group = 'ward', desc = 'Diabolos - Inflicts death or dispel (AoE).' },
    perfectdefense   = { action = 'pet', spell = 'Perfect Defense',        target = 'lastst', level = 75, group = 'ward', desc = 'Alexander - Grants party invincibility.' },
    raiseii          = { action = 'pet', spell = 'Raise II',               target = 'lastst', level = 15, group = 'ward', desc = 'Cait Sith - Revives with HP + MP.' },
    reraiseii        = { action = 'pet', spell = 'Reraise II',             target = 'lastst', level = 30, group = 'ward', desc = 'Cait Sith - Grants reraise.' },
    rollingthunder   = { action = 'pet', spell = 'Rolling Thunder',        target = 'me', level = 31, group = 'ward', desc = 'Ramuh - Grants enthunder (AoE).' },
    shiningruby      = { action = 'pet', spell = 'Shining Ruby',           target = 'me', level = 24, group = 'ward', desc = 'Carbuncle - Restores HP (enhanced).' },
    shocksquall      = { action = 'pet', spell = 'Shock Squall',           target = 'lastst', level = 92, group = 'ward', desc = 'Ramuh - Inflicts stun (AoE).' },
    sleepga          = { action = 'pet', spell = 'Sleepga',                target = 'lastst', level = 39, group = 'ward', desc = 'Shiva - Inflicts sleep (AoE).' },
    slowga           = { action = 'pet', spell = 'Slowga',                 target = 'lastst', level = 33, group = 'ward', desc = 'Leviathan - Inflicts slow (AoE).' },
    somnolence       = { action = 'pet', spell = 'Somnolence',             target = 'lastst', level = 20, group = 'ward', desc = 'Diabolos - Restores HP + MP + gravity.' },
    soothingcurrent  = { action = 'pet', spell = 'Soothing Current',       target = 'me', level = 99, group = 'ward', desc = 'Leviathan - Boosts cure potency (AoE).' },
    soothingruby     = { action = 'pet', spell = 'Soothing Ruby',          target = 'me', level = 94, group = 'ward', desc = 'Carbuncle - Restores HP + removes ailments.' },
    springwater      = { action = 'pet', spell = 'Spring Water',           target = 'me', level = 47, group = 'ward', desc = 'Leviathan - Restores HP.' },
    tidalroar        = { action = 'pet', spell = 'Tidal Roar',             target = 'lastst', level = 84, group = 'ward', desc = 'Leviathan - Removes beneficial effects (AoE).' },
    ultimateterror   = { action = 'pet', spell = 'Ultimate Terror',        target = 'lastst', level = 37, group = 'ward', desc = 'Diabolos - Inflicts terror (AoE).' },
    whisperingwind   = { action = 'pet', spell = 'Whispering Wind',        target = 'me', level = 36, group = 'ward', desc = 'Garuda - Restores HP (AoE).' },
    windsblessing    = { action = 'pet', spell = "Wind's Blessing",        target = 'me', level = 88, group = 'ward', desc = 'Siren - Grants magic shield (AoE).' },
}

return M

---============================================================================
--- BRD Alt Commands - what the alt does when it is on BRD
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether BRD is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in BRD_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/BRD_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    clarioncall      = { action = 'ja', spell = 'Clarion Call',           target = 'me', level = 96, main_only = true, group = 'ja', desc = '+1 song slot for party' },
    marcato          = { action = 'ja', spell = 'Marcato',                target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Next song effect x1.5' },
    nightingale      = { action = 'ja', spell = 'Nightingale',            target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Song cast/recast -50%' },
    pianissimo       = { action = 'ja', spell = 'Pianissimo',             target = 'me', level = 20, group = 'ja', desc = 'Next song affects single target' },
    soulvoice        = { action = 'ja', spell = 'Soul Voice',             target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Song effects x2' },
    tenuto           = { action = 'ja', spell = 'Tenuto',                 target = 'me', level = 83, main_only = true, group = 'ja', desc = 'Next self song no overwrite (5 max)' },
    troubadour       = { action = 'ja', spell = 'Troubadour',             target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Song duration x2' },

    -- ========================================================================
    -- SONGS
    -- ========================================================================
    advancingmarch   = { action = 'so', target = 'me', group = 'song', desc = 'Advancing March',
                       tiers = { { spell = 'Advancing March', level = 29 } } },
    adventurersdirge = { action = 'so', target = 'me', group = 'song', desc = "Adventurer's Dirge",
                       tiers = { { spell = "Adventurer's Dirge", level = 75 } } },
    archersprelude   = { action = 'so', target = 'me', group = 'song', desc = "Archer's Prelude",
                       tiers = { { spell = "Archer's Prelude", level = 71 } } },
    ariaofpassion    = { action = 'so', target = 'me', group = 'song', desc = 'Aria of Passion',
                       tiers = { { spell = 'Aria of Passion', level = 99 } } },
    armyspaeon       = { action = 'so', target = 'me', group = 'song', desc = "Army's Paeon",
                       tiers = { { spell = "Army's Paeon VI", level = 78 }, { spell = "Army's Paeon V", level = 65 }, { spell = "Army's Paeon IV", level = 45 }, { spell = "Army's Paeon III", level = 35 }, { spell = "Army's Paeon II", level = 15 }, { spell = "Army's Paeon", level = 5 } } },
    battlefieldelegy = { action = 'so', target = 'lastst', group = 'song', desc = 'Battlefield Elegy',
                       tiers = { { spell = 'Battlefield Elegy', level = 39 } } },
    bewitchingetude  = { action = 'so', target = 'me', group = 'song', desc = 'Bewitching Etude',
                       tiers = { { spell = 'Bewitching Etude', level = 62 } } },
    blademadrigal    = { action = 'so', target = 'me', group = 'song', desc = 'Blade Madrigal',
                       tiers = { { spell = 'Blade Madrigal', level = 51 } } },
    carnageelegy     = { action = 'so', target = 'lastst', group = 'song', desc = 'Carnage Elegy',
                       tiers = { { spell = 'Carnage Elegy', level = 59 } } },
    chocobomazurka   = { action = 'so', target = 'me', group = 'song', desc = 'Chocobo Mazurka',
                       tiers = { { spell = 'Chocobo Mazurka', level = 73 } } },
    darkcarol        = { action = 'so', target = 'me', group = 'song', desc = 'Dark Carol',
                       tiers = { { spell = 'Dark Carol II', level = 99 }, { spell = 'Dark Carol', level = 50 } } },
    darkthrenody     = { action = 'so', target = 'lastst', group = 'song', desc = 'Dark Threnody',
                       tiers = { { spell = 'Dark Threnody II', level = 99 }, { spell = 'Dark Threnody', level = 12 } } },
    dextrousetude    = { action = 'so', target = 'me', group = 'song', desc = 'Dextrous Etude',
                       tiers = { { spell = 'Dextrous Etude', level = 32 } } },
    dragonfoemambo   = { action = 'so', target = 'me', group = 'song', desc = 'Dragonfoe Mambo',
                       tiers = { { spell = 'Dragonfoe Mambo', level = 53 } } },
    earthcarol       = { action = 'so', target = 'me', group = 'song', desc = 'Earth Carol',
                       tiers = { { spell = 'Earth Carol II', level = 81 }, { spell = 'Earth Carol', level = 38 } } },
    earththrenody    = { action = 'so', target = 'lastst', group = 'song', desc = 'Earth Threnody',
                       tiers = { { spell = 'Earth Threnody II', level = 99 }, { spell = 'Earth Threnody', level = 14 } } },
    enchantingetude  = { action = 'so', target = 'me', group = 'song', desc = 'Enchanting Etude',
                       tiers = { { spell = 'Enchanting Etude', level = 22 } } },
    firecarol        = { action = 'so', target = 'me', group = 'song', desc = 'Fire Carol',
                       tiers = { { spell = 'Fire Carol II', level = 90 }, { spell = 'Fire Carol', level = 44 } } },
    firethrenody     = { action = 'so', target = 'lastst', group = 'song', desc = 'Fire Threnody',
                       tiers = { { spell = 'Fire Threnody II', level = 99 }, { spell = 'Fire Threnody', level = 20 } } },
    foelullaby       = { action = 'so', target = 'lastst', group = 'song', desc = 'Foe Lullaby',
                       tiers = { { spell = 'Foe Lullaby II', level = 83 }, { spell = 'Foe Lullaby', level = 16 } } },
    foerequiem       = { action = 'so', target = 'lastst', group = 'song', desc = 'Foe Requiem',
                       tiers = { { spell = 'Foe Requiem VII', level = 76 }, { spell = 'Foe Requiem VI', level = 67 }, { spell = 'Foe Requiem V', level = 57 }, { spell = 'Foe Requiem IV', level = 47 }, { spell = 'Foe Requiem III', level = 37 }, { spell = 'Foe Requiem II', level = 17 }, { spell = 'Foe Requiem', level = 7 } } },
    foesirvente      = { action = 'so', target = 'me', group = 'song', desc = 'Foe Sirvente',
                       tiers = { { spell = 'Foe Sirvente', level = 75 } } },
    fowlaubade       = { action = 'so', target = 'me', group = 'song', desc = 'Fowl Aubade',
                       tiers = { { spell = 'Fowl Aubade', level = 33 } } },
    goblingavotte    = { action = 'so', target = 'me', group = 'song', desc = 'Goblin Gavotte',
                       tiers = { { spell = 'Goblin Gavotte', level = 49 } } },
    goldcapriccio    = { action = 'so', target = 'me', group = 'song', desc = 'Gold Capriccio',
                       tiers = { { spell = 'Gold Capriccio', level = 54 } } },
    herbpastoral     = { action = 'so', target = 'me', group = 'song', desc = 'Herb Pastoral',
                       tiers = { { spell = 'Herb Pastoral', level = 9 } } },
    herculeanetude   = { action = 'so', target = 'me', group = 'song', desc = 'Herculean Etude',
                       tiers = { { spell = 'Herculean Etude', level = 74 } } },
    honormarch       = { action = 'so', target = 'me', group = 'song', desc = 'Honor March',
                       tiers = { { spell = 'Honor March', level = 99 } } },
    hordelullaby     = { action = 'so', target = 'lastst', group = 'song', desc = 'Horde Lullaby',
                       tiers = { { spell = 'Horde Lullaby II', level = 92 }, { spell = 'Horde Lullaby', level = 27 } } },
    huntersprelude   = { action = 'so', target = 'me', group = 'song', desc = "Hunter's Prelude",
                       tiers = { { spell = "Hunter's Prelude", level = 31 } } },
    icecarol         = { action = 'so', target = 'me', group = 'song', desc = 'Ice Carol',
                       tiers = { { spell = 'Ice Carol II', level = 93 }, { spell = 'Ice Carol', level = 46 } } },
    icethrenody      = { action = 'so', target = 'lastst', group = 'song', desc = 'Ice Threnody',
                       tiers = { { spell = 'Ice Threnody II', level = 99 }, { spell = 'Ice Threnody', level = 22 } } },
    knightsminne     = { action = 'so', target = 'me', group = 'song', desc = "Knight's Minne",
                       tiers = { { spell = "Knight's Minne V", level = 80 }, { spell = "Knight's Minne IV", level = 61 }, { spell = "Knight's Minne III", level = 41 }, { spell = "Knight's Minne II", level = 21 }, { spell = "Knight's Minne", level = 1 } } },
    learnedetude     = { action = 'so', target = 'me', group = 'song', desc = 'Learned Etude',
                       tiers = { { spell = 'Learned Etude', level = 26 } } },
    lightcarol       = { action = 'so', target = 'me', group = 'song', desc = 'Light Carol',
                       tiers = { { spell = 'Light Carol II', level = 99 }, { spell = 'Light Carol', level = 36 } } },
    lightthrenody    = { action = 'so', target = 'lastst', group = 'song', desc = 'Light Threnody',
                       tiers = { { spell = 'Light Threnody II', level = 99 }, { spell = 'Light Threnody', level = 10 } } },
    lightningcarol   = { action = 'so', target = 'me', group = 'song', desc = 'Lightning Carol',
                       tiers = { { spell = 'Lightning Carol II', level = 96 }, { spell = 'Lightning Carol', level = 48 } } },
    logicaletude     = { action = 'so', target = 'me', group = 'song', desc = 'Logical Etude',
                       tiers = { { spell = 'Logical Etude', level = 64 } } },
    magesballad      = { action = 'so', target = 'me', group = 'song', desc = "Mage's Ballad",
                       tiers = { { spell = "Mage's Ballad III", level = 85 }, { spell = "Mage's Ballad II", level = 55 }, { spell = "Mage's Ballad", level = 25 } } },
    magicfinale      = { action = 'so', target = 'lastst', group = 'song', desc = 'Magic Finale',
                       tiers = { { spell = 'Magic Finale', level = 33 } } },
    maidensvirelai   = { action = 'so', target = 'lastst', group = 'song', desc = "Maiden's Virelai",
                       tiers = { { spell = "Maiden's Virelai", level = 75 } } },
    piningnocturne   = { action = 'so', target = 'lastst', group = 'song', desc = 'Pining Nocturne',
                       tiers = { { spell = 'Pining Nocturne', level = 95 } } },
    puppetsoperetta  = { action = 'so', target = 'me', group = 'song', desc = "Puppet's Operetta",
                       tiers = { { spell = "Puppet's Operetta", level = 69 } } },
    quicketude       = { action = 'so', target = 'me', group = 'song', desc = 'Quick Etude',
                       tiers = { { spell = 'Quick Etude', level = 28 } } },
    raptormazurka    = { action = 'so', target = 'me', group = 'song', desc = 'Raptor Mazurka',
                       tiers = { { spell = 'Raptor Mazurka', level = 37 } } },
    sageetude        = { action = 'so', target = 'me', group = 'song', desc = 'Sage Etude',
                       tiers = { { spell = 'Sage Etude', level = 66 } } },
    scopsoperetta    = { action = 'so', target = 'me', group = 'song', desc = "Scop's Operetta",
                       tiers = { { spell = "Scop's Operetta", level = 19 } } },
    sentinelsscherzo = { action = 'so', target = 'me', group = 'song', desc = "Sentinel's Scherzo",
                       tiers = { { spell = "Sentinel's Scherzo", level = 82 } } },
    sheepfoemambo    = { action = 'so', target = 'me', group = 'song', desc = 'Sheepfoe Mambo',
                       tiers = { { spell = 'Sheepfoe Mambo', level = 13 } } },
    shiningfantasia  = { action = 'so', target = 'me', group = 'song', desc = 'Shining Fantasia',
                       tiers = { { spell = 'Shining Fantasia', level = 56 } } },
    sinewyetude      = { action = 'so', target = 'me', group = 'song', desc = 'Sinewy Etude',
                       tiers = { { spell = 'Sinewy Etude', level = 34 } } },
    spiritedetude    = { action = 'so', target = 'me', group = 'song', desc = 'Spirited Etude',
                       tiers = { { spell = 'Spirited Etude', level = 24 } } },
    swiftetude       = { action = 'so', target = 'me', group = 'song', desc = 'Swift Etude',
                       tiers = { { spell = 'Swift Etude', level = 68 } } },
    swordmadrigal    = { action = 'so', target = 'me', group = 'song', desc = 'Sword Madrigal',
                       tiers = { { spell = 'Sword Madrigal', level = 11 } } },
    uncannyetude     = { action = 'so', target = 'me', group = 'song', desc = 'Uncanny Etude',
                       tiers = { { spell = 'Uncanny Etude', level = 72 } } },
    valorminuet      = { action = 'so', target = 'me', group = 'song', desc = 'Valor Minuet',
                       tiers = { { spell = 'Valor Minuet V', level = 87 }, { spell = 'Valor Minuet IV', level = 63 }, { spell = 'Valor Minuet III', level = 43 }, { spell = 'Valor Minuet II', level = 23 }, { spell = 'Valor Minuet', level = 3 } } },
    victorymarch     = { action = 'so', target = 'me', group = 'song', desc = 'Victory March',
                       tiers = { { spell = 'Victory March', level = 60 } } },
    vitaletude       = { action = 'so', target = 'me', group = 'song', desc = 'Vital Etude',
                       tiers = { { spell = 'Vital Etude', level = 70 } } },
    vivaciousetude   = { action = 'so', target = 'me', group = 'song', desc = 'Vivacious Etude',
                       tiers = { { spell = 'Vivacious Etude', level = 30 } } },
    wardinground     = { action = 'so', target = 'me', group = 'song', desc = 'Warding Round',
                       tiers = { { spell = 'Warding Round', level = 73 } } },
    watercarol       = { action = 'so', target = 'me', group = 'song', desc = 'Water Carol',
                       tiers = { { spell = 'Water Carol II', level = 84 }, { spell = 'Water Carol', level = 40 } } },
    waterthrenody    = { action = 'so', target = 'lastst', group = 'song', desc = 'Water Threnody',
                       tiers = { { spell = 'Water Threnody II', level = 99 }, { spell = 'Water Threnody', level = 16 } } },
    windcarol        = { action = 'so', target = 'me', group = 'song', desc = 'Wind Carol',
                       tiers = { { spell = 'Wind Carol II', level = 87 }, { spell = 'Wind Carol', level = 42 } } },
    windthrenody     = { action = 'so', target = 'lastst', group = 'song', desc = 'Wind Threnody',
                       tiers = { { spell = 'Wind Threnody II', level = 99 }, { spell = 'Wind Threnody', level = 18 } } },
}

return M

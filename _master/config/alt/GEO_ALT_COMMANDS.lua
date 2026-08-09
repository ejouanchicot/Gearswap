---============================================================================
--- GEO Alt Commands - what the alt does when it is on GEO
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether GEO is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in GEO_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/GEO_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    blazeofglory     = { action = 'ja', spell = 'Blaze of Glory',         target = 'me', level = 60, main_only = true, group = 'ja', desc = 'Next luopan +50%, -50% HP' },
    bolster          = { action = 'ja', spell = 'Bolster',                target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Geomancy effects x2' },
    collimatedfervor = { action = 'ja', spell = 'Collimated Fervor',      target = 'me', level = 40, group = 'ja', desc = 'Next Cardinal Chant +50%' },
    concentricpulse  = { action = 'ja', spell = 'Concentric Pulse',       target = 'lastst', level = 90, main_only = true, group = 'ja', desc = 'Dismiss luopan, AoE damage' },
    dematerialize    = { action = 'ja', spell = 'Dematerialize',          target = 'me', level = 70, main_only = true, group = 'ja', desc = 'Luopan damage immunity' },
    eclipticattrition = { action = 'ja', spell = 'Ecliptic Attrition',     target = 'me', level = 25, main_only = true, group = 'ja', desc = 'Luopan +25%, HP consumption +6/tick' },
    entrust          = { action = 'ja', spell = 'Entrust',                target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Next Indi targets party member' },
    fullcircle       = { action = 'ja', spell = 'Full Circle',            target = 'me', level = 5, main_only = true, group = 'ja', desc = 'Dismiss luopan, recover MP' },
    lastingemanation = { action = 'ja', spell = 'Lasting Emanation',      target = 'me', level = 25, main_only = true, group = 'ja', desc = 'Luopan HP consumption -7/tick' },
    lifecycle        = { action = 'ja', spell = 'Life Cycle',             target = 'me', level = 50, group = 'ja', desc = '25% your HP >> luopan' },
    mendinghalation  = { action = 'ja', spell = 'Mending Halation',       target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Dismiss luopan, party HP' },
    radialarcana     = { action = 'ja', spell = 'Radial Arcana',          target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Dismiss luopan, party MP' },
    theurgicfocus    = { action = 'ja', spell = 'Theurgic Focus',         target = 'me', level = 80, main_only = true, group = 'ja', desc = 'Next -ra spell MAB+50' },
    widenedcompass   = { action = 'ja', spell = 'Widened Compass',        target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Geomancy range x2' },

    -- ========================================================================
    -- ENFEEBLING - select the mob first
    -- ========================================================================
    sleep            = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Sleep',
                       tiers = { { spell = 'Sleep II', level = 70 }, { spell = 'Sleep', level = 35 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first
    -- ========================================================================
    aero             = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Aero',
                       tiers = { { spell = 'Aero V', level = 99 }, { spell = 'Aero IV', level = 82 }, { spell = 'Aero III', level = 64 }, { spell = 'Aero II', level = 42 }, { spell = 'Aero', level = 14 } } },
    blizzara         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzara',
                       tiers = { { spell = 'Blizzara III', level = 99 }, { spell = 'Blizzara II', level = 90 }, { spell = 'Blizzara', level = 45 } } },
    blizzard         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzard',
                       tiers = { { spell = 'Blizzard V', level = 99 }, { spell = 'Blizzard IV', level = 88 }, { spell = 'Blizzard III', level = 70 }, { spell = 'Blizzard II', level = 50 }, { spell = 'Blizzard', level = 24 } } },
    fira             = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Fira',
                       tiers = { { spell = 'Fira III', level = 99 }, { spell = 'Fira II', level = 85 }, { spell = 'Fira', level = 40 } } },
    fire             = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Fire',
                       tiers = { { spell = 'Fire V', level = 99 }, { spell = 'Fire IV', level = 85 }, { spell = 'Fire III', level = 67 }, { spell = 'Fire II', level = 46 }, { spell = 'Fire', level = 19 } } },
    impact           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
    stone            = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stone',
                       tiers = { { spell = 'Stone V', level = 99 }, { spell = 'Stone IV', level = 76 }, { spell = 'Stone III', level = 58 }, { spell = 'Stone II', level = 34 }, { spell = 'Stone', level = 4 } } },
    stonera          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stonera',
                       tiers = { { spell = 'Stonera III', level = 99 }, { spell = 'Stonera II', level = 70 }, { spell = 'Stonera', level = 25 } } },
    thundara         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thundara',
                       tiers = { { spell = 'Thundara III', level = 99 }, { spell = 'Thundara II', level = 95 }, { spell = 'Thundara', level = 50 } } },
    thunder          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thunder',
                       tiers = { { spell = 'Thunder V', level = 99 }, { spell = 'Thunder IV', level = 91 }, { spell = 'Thunder III', level = 73 }, { spell = 'Thunder II', level = 54 }, { spell = 'Thunder', level = 29 } } },
    water            = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Water',
                       tiers = { { spell = 'Water V', level = 99 }, { spell = 'Water IV', level = 79 }, { spell = 'Water III', level = 61 }, { spell = 'Water II', level = 38 }, { spell = 'Water', level = 9 } } },
    watera           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Watera',
                       tiers = { { spell = 'Watera III', level = 99 }, { spell = 'Watera II', level = 75 }, { spell = 'Watera', level = 30 } } },

    -- ========================================================================
    -- DARK MAGIC - select the mob first
    -- ========================================================================
    aspir            = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Aspir',
                       tiers = { { spell = 'Aspir III', level = 99 }, { spell = 'Aspir II', level = 90 }, { spell = 'Aspir', level = 30 } } },
    drain            = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Drain',
                       tiers = { { spell = 'Drain', level = 15 } } },

    -- ========================================================================
    -- GEOMANCY
    -- ========================================================================
    geoagi           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-AGI',
                       tiers = { { spell = 'Geo-AGI', level = 43 } } },
    geoacumen        = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Acumen',
                       tiers = { { spell = 'Geo-Acumen', level = 50 } } },
    geoattunement    = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Attunement',
                       tiers = { { spell = 'Geo-Attunement', level = 20 } } },
    geobarrier       = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Barrier',
                       tiers = { { spell = 'Geo-Barrier', level = 32 } } },
    geochr           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-CHR',
                       tiers = { { spell = 'Geo-CHR', level = 34 } } },
    geodex           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-DEX',
                       tiers = { { spell = 'Geo-DEX', level = 49 } } },
    geofade          = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Fade',
                       tiers = { { spell = 'Geo-Fade', level = 98 } } },
    geofend          = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Fend',
                       tiers = { { spell = 'Geo-Fend', level = 44 } } },
    geofocus         = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Focus',
                       tiers = { { spell = 'Geo-Focus', level = 26 } } },
    geofrailty       = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Frailty',
                       tiers = { { spell = 'Geo-Frailty', level = 80 } } },
    geofury          = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Fury',
                       tiers = { { spell = 'Geo-Fury', level = 38 } } },
    geogravity       = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Gravity',
                       tiers = { { spell = 'Geo-Gravity', level = 92 } } },
    geohaste         = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Haste',
                       tiers = { { spell = 'Geo-Haste', level = 97 } } },
    geoint           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-INT',
                       tiers = { { spell = 'Geo-INT', level = 40 } } },
    geolanguor       = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Languor',
                       tiers = { { spell = 'Geo-Languor', level = 68 } } },
    geomnd           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-MND',
                       tiers = { { spell = 'Geo-MND', level = 37 } } },
    geomalaise       = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Malaise',
                       tiers = { { spell = 'Geo-Malaise', level = 92 } } },
    geoparalysis     = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Paralysis',
                       tiers = { { spell = 'Geo-Paralysis', level = 72 } } },
    geopoison        = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Poison',
                       tiers = { { spell = 'Geo-Poison', level = 5 } } },
    geoprecision     = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Precision',
                       tiers = { { spell = 'Geo-Precision', level = 14 } } },
    georefresh       = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Refresh',
                       tiers = { { spell = 'Geo-Refresh', level = 34 } } },
    georegen         = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Regen',
                       tiers = { { spell = 'Geo-Regen', level = 19 } } },
    geostr           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-STR',
                       tiers = { { spell = 'Geo-STR', level = 52 } } },
    geoslip          = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Slip',
                       tiers = { { spell = 'Geo-Slip', level = 62 } } },
    geoslow          = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Slow',
                       tiers = { { spell = 'Geo-Slow', level = 52 } } },
    geotorpor        = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Torpor',
                       tiers = { { spell = 'Geo-Torpor', level = 56 } } },
    geovit           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-VIT',
                       tiers = { { spell = 'Geo-VIT', level = 46 } } },
    geovex           = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Vex',
                       tiers = { { spell = 'Geo-Vex', level = 74 } } },
    geovoidance      = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Voidance',
                       tiers = { { spell = 'Geo-Voidance', level = 8 } } },
    geowilt          = { action = 'ma', target = 'lastst', group = 'geomancy', desc = 'Geo-Wilt',
                       tiers = { { spell = 'Geo-Wilt', level = 86 } } },
    indiagi          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-AGI',
                       tiers = { { spell = 'Indi-AGI', level = 39 } } },
    indiacumen       = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Acumen',
                       tiers = { { spell = 'Indi-Acumen', level = 46 } } },
    indiattunement   = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Attunement',
                       tiers = { { spell = 'Indi-Attunement', level = 16 } } },
    indibarrier      = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Barrier',
                       tiers = { { spell = 'Indi-Barrier', level = 28 } } },
    indichr          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-CHR',
                       tiers = { { spell = 'Indi-CHR', level = 30 } } },
    indidex          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-DEX',
                       tiers = { { spell = 'Indi-DEX', level = 45 } } },
    indifade         = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Fade',
                       tiers = { { spell = 'Indi-Fade', level = 94 } } },
    indifend         = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Fend',
                       tiers = { { spell = 'Indi-Fend', level = 40 } } },
    indifocus        = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Focus',
                       tiers = { { spell = 'Indi-Focus', level = 22 } } },
    indifrailty      = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Frailty',
                       tiers = { { spell = 'Indi-Frailty', level = 76 } } },
    indifury         = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Fury',
                       tiers = { { spell = 'Indi-Fury', level = 34 } } },
    indigravity      = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Gravity',
                       tiers = { { spell = 'Indi-Gravity', level = 88 } } },
    indihaste        = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Haste',
                       tiers = { { spell = 'Indi-Haste', level = 93 } } },
    indiint          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-INT',
                       tiers = { { spell = 'Indi-INT', level = 36 } } },
    indilanguor      = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Languor',
                       tiers = { { spell = 'Indi-Languor', level = 64 } } },
    indimnd          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-MND',
                       tiers = { { spell = 'Indi-MND', level = 33 } } },
    indimalaise      = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Malaise',
                       tiers = { { spell = 'Indi-Malaise', level = 88 } } },
    indiparalysis    = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Paralysis',
                       tiers = { { spell = 'Indi-Paralysis', level = 68 } } },
    indipoison       = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Poison',
                       tiers = { { spell = 'Indi-Poison', level = 1 } } },
    indiprecision    = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Precision',
                       tiers = { { spell = 'Indi-Precision', level = 10 } } },
    indirefresh      = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Refresh',
                       tiers = { { spell = 'Indi-Refresh', level = 30 } } },
    indiregen        = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Regen',
                       tiers = { { spell = 'Indi-Regen', level = 15 } } },
    indistr          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-STR',
                       tiers = { { spell = 'Indi-STR', level = 48 } } },
    indislip         = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Slip',
                       tiers = { { spell = 'Indi-Slip', level = 58 } } },
    indislow         = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Slow',
                       tiers = { { spell = 'Indi-Slow', level = 48 } } },
    inditorpor       = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Torpor',
                       tiers = { { spell = 'Indi-Torpor', level = 52 } } },
    indivit          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-VIT',
                       tiers = { { spell = 'Indi-VIT', level = 42 } } },
    indivex          = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Vex',
                       tiers = { { spell = 'Indi-Vex', level = 70 } } },
    indivoidance     = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Voidance',
                       tiers = { { spell = 'Indi-Voidance', level = 4 } } },
    indiwilt         = { action = 'ma', target = 'me', group = 'geomancy', desc = 'Indi-Wilt',
                       tiers = { { spell = 'Indi-Wilt', level = 82 } } },
}

return M

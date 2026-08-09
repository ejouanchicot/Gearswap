---============================================================================
--- WHM Alt Commands - what the alt does when it is on WHM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether WHM is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in WHM_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/WHM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    afflatusmisery   = { action = 'ja', spell = 'Afflatus Misery',        target = 'me', level = 40, main_only = true, group = 'ja', desc = 'Damage taken boosts Banish/Cura/Esuna potency' },
    afflatussolace   = { action = 'ja', spell = 'Afflatus Solace',        target = 'me', level = 40, main_only = true, group = 'ja', desc = 'Cure >> Stoneskin (25% of heal)' },
    asylum           = { action = 'ja', spell = 'Asylum',                 target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Party debuff/dispel immunity' },
    benediction      = { action = 'ja', spell = 'Benediction',            target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Restore party HP, remove status' },
    devotion         = { action = 'ja', spell = 'Devotion',               target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Sacrifice 25% HP >> ally MP' },
    divinecaress     = { action = 'ja', spell = 'Divine Caress',          target = 'me', level = 83, main_only = true, group = 'ja', desc = 'Next status removal >> immunity' },
    divineseal       = { action = 'ja', spell = 'Divine Seal',            target = 'me', level = 15, group = 'ja', desc = 'Next cure x2 potency' },
    martyr           = { action = 'ja', spell = 'Martyr',                 target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Sacrifice 25% HP >> heal ally 50%' },
    sacrosanctity    = { action = 'ja', spell = 'Sacrosanctity',          target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Party magic damage -75%' },

    -- ========================================================================
    -- ENFEEBLING - select the mob first
    -- ========================================================================
    addle            = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Addle',
                       tiers = { { spell = 'Addle', level = 93 } } },
    dia              = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Dia',
                       tiers = { { spell = 'Dia II', level = 36 }, { spell = 'Dia', level = 3 } } },
    diaga            = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Diaga',
                       tiers = { { spell = 'Diaga', level = 18 } } },
    paralyze         = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Paralyze',
                       tiers = { { spell = 'Paralyze', level = 4 } } },
    silence          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Silence',
                       tiers = { { spell = 'Silence', level = 15 } } },
    slow             = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Slow',
                       tiers = { { spell = 'Slow', level = 13 } } },

    -- ========================================================================
    -- ENHANCING - select the ally, or it lands on the alt
    -- ========================================================================
    aquaveil         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Aquaveil',
                       tiers = { { spell = 'Aquaveil', level = 10 } } },
    auspice          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Auspice',
                       tiers = { { spell = 'Auspice', level = 55 } } },
    baraera          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Baraera',
                       tiers = { { spell = 'Baraera', level = 13 } } },
    baramnesra       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Baramnesra',
                       tiers = { { spell = 'Baramnesra', level = 78 } } },
    barblindra       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barblindra',
                       tiers = { { spell = 'Barblindra', level = 18 } } },
    barblizzara      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barblizzara',
                       tiers = { { spell = 'Barblizzara', level = 21 } } },
    barfira          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barfira',
                       tiers = { { spell = 'Barfira', level = 17 } } },
    barparalyzra     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barparalyzra',
                       tiers = { { spell = 'Barparalyzra', level = 12 } } },
    barpetra         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barpetra',
                       tiers = { { spell = 'Barpetra', level = 43 } } },
    barpoisonra      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barpoisonra',
                       tiers = { { spell = 'Barpoisonra', level = 10 } } },
    barsilencera     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barsilencera',
                       tiers = { { spell = 'Barsilencera', level = 23 } } },
    barsleepra       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barsleepra',
                       tiers = { { spell = 'Barsleepra', level = 7 } } },
    barstonra        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barstonra',
                       tiers = { { spell = 'Barstonra', level = 5 } } },
    barthundra       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barthundra',
                       tiers = { { spell = 'Barthundra', level = 25 } } },
    barvira          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barvira',
                       tiers = { { spell = 'Barvira', level = 39 } } },
    barwatera        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barwatera',
                       tiers = { { spell = 'Barwatera', level = 9 } } },
    blink            = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Blink',
                       tiers = { { spell = 'Blink', level = 19 } } },
    boostagi         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-AGI',
                       tiers = { { spell = 'Boost-AGI', level = 90 } } },
    boostchr         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-CHR',
                       tiers = { { spell = 'Boost-CHR', level = 87 } } },
    boostdex         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-DEX',
                       tiers = { { spell = 'Boost-DEX', level = 99 } } },
    boostint         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-INT',
                       tiers = { { spell = 'Boost-INT', level = 96 } } },
    boostmnd         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-MND',
                       tiers = { { spell = 'Boost-MND', level = 84 } } },
    booststr         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-STR',
                       tiers = { { spell = 'Boost-STR', level = 93 } } },
    boostvit         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Boost-VIT',
                       tiers = { { spell = 'Boost-VIT', level = 81 } } },
    deodorize        = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Deodorize',
                       tiers = { { spell = 'Deodorize', level = 15 } } },
    erase            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Erase',
                       tiers = { { spell = 'Erase', level = 32 } } },
    haste            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Haste',
                       tiers = { { spell = 'Haste', level = 40 } } },
    invisible        = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Invisible',
                       tiers = { { spell = 'Invisible', level = 25 } } },
    protect          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Protect',
                       tiers = { { spell = 'Protect V', level = 76 }, { spell = 'Protect IV', level = 63 }, { spell = 'Protect III', level = 47 }, { spell = 'Protect II', level = 27 }, { spell = 'Protect', level = 7 } } },
    protectra        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Protectra',
                       tiers = { { spell = 'Protectra V', level = 75 }, { spell = 'Protectra IV', level = 63 }, { spell = 'Protectra III', level = 47 }, { spell = 'Protectra II', level = 27 }, { spell = 'Protectra', level = 7 } } },
    recalljugner     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Recall-Jugner',
                       tiers = { { spell = 'Recall-Jugner', level = 53 } } },
    recallmeriph     = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Recall-Meriph',
                       tiers = { { spell = 'Recall-Meriph', level = 53 } } },
    recallpashh      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Recall-Pashh',
                       tiers = { { spell = 'Recall-Pashh', level = 53 } } },
    regen            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Regen',
                       tiers = { { spell = 'Regen IV', level = 86 }, { spell = 'Regen III', level = 66 }, { spell = 'Regen II', level = 44 }, { spell = 'Regen', level = 21 } } },
    shell            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Shell',
                       tiers = { { spell = 'Shell V', level = 76 }, { spell = 'Shell IV', level = 68 }, { spell = 'Shell III', level = 57 }, { spell = 'Shell II', level = 37 }, { spell = 'Shell', level = 17 } } },
    shellra          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Shellra',
                       tiers = { { spell = 'Shellra V', level = 75 }, { spell = 'Shellra IV', level = 68 }, { spell = 'Shellra III', level = 57 }, { spell = 'Shellra II', level = 37 }, { spell = 'Shellra', level = 17 } } },
    sneak            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Sneak',
                       tiers = { { spell = 'Sneak', level = 20 } } },
    stoneskin        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Stoneskin',
                       tiers = { { spell = 'Stoneskin', level = 28 } } },
    teleportaltep    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Teleport-Altep',
                       tiers = { { spell = 'Teleport-Altep', level = 38 } } },
    teleportdem      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Teleport-Dem',
                       tiers = { { spell = 'Teleport-Dem', level = 36 } } },
    teleportholla    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Teleport-Holla',
                       tiers = { { spell = 'Teleport-Holla', level = 36 } } },
    teleportmea      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Teleport-Mea',
                       tiers = { { spell = 'Teleport-Mea', level = 36 } } },
    teleportvahzl    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Teleport-Vahzl',
                       tiers = { { spell = 'Teleport-Vahzl', level = 42 } } },
    teleportyhoat    = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Teleport-Yhoat',
                       tiers = { { spell = 'Teleport-Yhoat', level = 38 } } },

    -- ========================================================================
    -- HEALING - select the ally first
    -- ========================================================================
    arise            = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Arise',
                       tiers = { { spell = 'Arise', level = 99 } } },
    blindna          = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Blindna',
                       tiers = { { spell = 'Blindna', level = 14 } } },
    cura             = { action = 'ma', target = 'me', group = 'healing', desc = 'Cura',
                       tiers = { { spell = 'Cura III', level = 96 }, { spell = 'Cura II', level = 83 }, { spell = 'Cura', level = 40 } } },
    curaga           = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Curaga',
                       tiers = { { spell = 'Curaga V', level = 91 }, { spell = 'Curaga IV', level = 71 }, { spell = 'Curaga III', level = 51 }, { spell = 'Curaga II', level = 31 }, { spell = 'Curaga', level = 16 } } },
    cure             = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Cure',
                       tiers = { { spell = 'Cure VI', level = 80 }, { spell = 'Cure V', level = 61 }, { spell = 'Cure IV', level = 41 }, { spell = 'Cure III', level = 21 }, { spell = 'Cure II', level = 11 }, { spell = 'Cure', level = 1 } } },
    cursna           = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Cursna',
                       tiers = { { spell = 'Cursna', level = 29 } } },
    esuna            = { action = 'ma', target = 'me', group = 'healing', desc = 'Esuna',
                       tiers = { { spell = 'Esuna', level = 61 } } },
    fullcure         = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Full Cure',
                       tiers = { { spell = 'Full Cure', level = 99 } } },
    paralyna         = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Paralyna',
                       tiers = { { spell = 'Paralyna', level = 9 } } },
    poisona          = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Poisona',
                       tiers = { { spell = 'Poisona', level = 6 } } },
    raise            = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Raise',
                       tiers = { { spell = 'Raise III', level = 70 }, { spell = 'Raise II', level = 56 }, { spell = 'Raise', level = 25 } } },
    reraise          = { action = 'ma', target = 'me', group = 'healing', desc = 'Reraise',
                       tiers = { { spell = 'Reraise IV', level = 99 }, { spell = 'Reraise III', level = 70 }, { spell = 'Reraise II', level = 56 }, { spell = 'Reraise', level = 25 } } },
    sacrifice        = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Sacrifice',
                       tiers = { { spell = 'Sacrifice', level = 65 } } },
    silena           = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Silena',
                       tiers = { { spell = 'Silena', level = 19 } } },
    stona            = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Stona',
                       tiers = { { spell = 'Stona', level = 39 } } },
    viruna           = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Viruna',
                       tiers = { { spell = 'Viruna', level = 34 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first
    -- ========================================================================
    impact           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
}

return M

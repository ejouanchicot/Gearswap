---============================================================================
--- WHM Alt Commands - what the alt does when it is on WHM
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether WHM is the alt's
--- MAIN job or its SUBJOB.
---
--- Generated from Windower's res/spells.lua: only spells WHM can cast, every
--- tier of a family with the level it needs, and the target taken from the
--- spell's `targets` bitmask.
---
--- The engine picks the highest tier the alt is high enough for, from the level
--- it reported. A subjob caps far below a main (Master Level 50 reaches sub
--- 58), and a spell the alt has not learned is silently dropped by the client
--- rather than reported - so the tier has to be chosen before sending.
---
--- @file    config/alt/WHM_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- ENFEEBLING - select the mob first (/ta <stnpc>)
    -- ========================================================================
    addle          = { action = 'ma', target = 'lastst', desc = 'Addle',
                       tiers = { { spell = 'Addle', level = 93 } } },
    dia            = { action = 'ma', target = 'lastst', desc = 'Dia',
                       tiers = { { spell = 'Dia II', level = 36 }, { spell = 'Dia', level = 3 } } },
    diaga          = { action = 'ma', target = 'lastst', desc = 'Diaga',
                       tiers = { { spell = 'Diaga', level = 18 } } },
    paralyze       = { action = 'ma', target = 'lastst', desc = 'Paralyze',
                       tiers = { { spell = 'Paralyze', level = 4 } } },
    silence        = { action = 'ma', target = 'lastst', desc = 'Silence',
                       tiers = { { spell = 'Silence', level = 15 } } },
    slow           = { action = 'ma', target = 'lastst', desc = 'Slow',
                       tiers = { { spell = 'Slow', level = 13 } } },
    slowga         = { action = 'ma', target = 'lastst', desc = 'Slowga',
                       tiers = { { spell = 'Slowga', level = 61 } } },

    -- ========================================================================
    -- ENHANCING - ally spells need /ta <stpc>, self spells go to the alt
    -- ========================================================================
    aquaveil       = { action = 'ma', target = 'me', desc = 'Aquaveil',
                       tiers = { { spell = 'Aquaveil', level = 10 } } },
    auspice        = { action = 'ma', target = 'me', desc = 'Auspice',
                       tiers = { { spell = 'Auspice', level = 55 } } },
    baraera        = { action = 'ma', target = 'me', desc = 'Baraera',
                       tiers = { { spell = 'Baraera', level = 13 } } },
    baramnesra     = { action = 'ma', target = 'me', desc = 'Baramnesra',
                       tiers = { { spell = 'Baramnesra', level = 78 } } },
    barblindra     = { action = 'ma', target = 'me', desc = 'Barblindra',
                       tiers = { { spell = 'Barblindra', level = 18 } } },
    barblizzara    = { action = 'ma', target = 'me', desc = 'Barblizzara',
                       tiers = { { spell = 'Barblizzara', level = 21 } } },
    barfira        = { action = 'ma', target = 'me', desc = 'Barfira',
                       tiers = { { spell = 'Barfira', level = 17 } } },
    barparalyzra   = { action = 'ma', target = 'me', desc = 'Barparalyzra',
                       tiers = { { spell = 'Barparalyzra', level = 12 } } },
    barpetra       = { action = 'ma', target = 'me', desc = 'Barpetra',
                       tiers = { { spell = 'Barpetra', level = 43 } } },
    barpoisonra    = { action = 'ma', target = 'me', desc = 'Barpoisonra',
                       tiers = { { spell = 'Barpoisonra', level = 10 } } },
    barsilencera   = { action = 'ma', target = 'me', desc = 'Barsilencera',
                       tiers = { { spell = 'Barsilencera', level = 23 } } },
    barsleepra     = { action = 'ma', target = 'me', desc = 'Barsleepra',
                       tiers = { { spell = 'Barsleepra', level = 7 } } },
    barstonra      = { action = 'ma', target = 'me', desc = 'Barstonra',
                       tiers = { { spell = 'Barstonra', level = 5 } } },
    barthundra     = { action = 'ma', target = 'me', desc = 'Barthundra',
                       tiers = { { spell = 'Barthundra', level = 25 } } },
    barvira        = { action = 'ma', target = 'me', desc = 'Barvira',
                       tiers = { { spell = 'Barvira', level = 39 } } },
    barwatera      = { action = 'ma', target = 'me', desc = 'Barwatera',
                       tiers = { { spell = 'Barwatera', level = 9 } } },
    blink          = { action = 'ma', target = 'me', desc = 'Blink',
                       tiers = { { spell = 'Blink', level = 19 } } },
    boostagi       = { action = 'ma', target = 'me', desc = 'Boost-AGI',
                       tiers = { { spell = 'Boost-AGI', level = 90 } } },
    boostchr       = { action = 'ma', target = 'me', desc = 'Boost-CHR',
                       tiers = { { spell = 'Boost-CHR', level = 87 } } },
    boostdex       = { action = 'ma', target = 'me', desc = 'Boost-DEX',
                       tiers = { { spell = 'Boost-DEX', level = 99 } } },
    boostint       = { action = 'ma', target = 'me', desc = 'Boost-INT',
                       tiers = { { spell = 'Boost-INT', level = 96 } } },
    boostmnd       = { action = 'ma', target = 'me', desc = 'Boost-MND',
                       tiers = { { spell = 'Boost-MND', level = 84 } } },
    booststr       = { action = 'ma', target = 'me', desc = 'Boost-STR',
                       tiers = { { spell = 'Boost-STR', level = 93 } } },
    boostvit       = { action = 'ma', target = 'me', desc = 'Boost-VIT',
                       tiers = { { spell = 'Boost-VIT', level = 81 } } },
    deodorize      = { action = 'ma', target = 'lastst', desc = 'Deodorize',
                       tiers = { { spell = 'Deodorize', level = 15 } } },
    erase          = { action = 'ma', target = 'lastst', desc = 'Erase',
                       tiers = { { spell = 'Erase', level = 32 } } },
    haste          = { action = 'ma', target = 'lastst', desc = 'Haste',
                       tiers = { { spell = 'Haste', level = 40 } } },
    hastega        = { action = 'ma', target = 'me', desc = 'Hastega',
                       tiers = { { spell = 'Hastega', level = 61 } } },
    invisible      = { action = 'ma', target = 'lastst', desc = 'Invisible',
                       tiers = { { spell = 'Invisible', level = 25 } } },
    protect        = { action = 'ma', target = 'lastst', desc = 'Protect',
                       tiers = { { spell = 'Protect V', level = 76 }, { spell = 'Protect IV', level = 63 }, { spell = 'Protect III', level = 47 }, { spell = 'Protect II', level = 27 }, { spell = 'Protect', level = 7 } } },
    protectra      = { action = 'ma', target = 'me', desc = 'Protectra',
                       tiers = { { spell = 'Protectra V', level = 75 }, { spell = 'Protectra IV', level = 63 }, { spell = 'Protectra III', level = 47 }, { spell = 'Protectra II', level = 27 }, { spell = 'Protectra', level = 7 } } },
    recalljugner   = { action = 'ma', target = 'me', desc = 'Recall-Jugner',
                       tiers = { { spell = 'Recall-Jugner', level = 53 } } },
    recallmeriph   = { action = 'ma', target = 'me', desc = 'Recall-Meriph',
                       tiers = { { spell = 'Recall-Meriph', level = 53 } } },
    recallpashh    = { action = 'ma', target = 'me', desc = 'Recall-Pashh',
                       tiers = { { spell = 'Recall-Pashh', level = 53 } } },
    regen          = { action = 'ma', target = 'lastst', desc = 'Regen',
                       tiers = { { spell = 'Regen IV', level = 86 }, { spell = 'Regen III', level = 66 }, { spell = 'Regen II', level = 44 }, { spell = 'Regen', level = 21 } } },
    shell          = { action = 'ma', target = 'lastst', desc = 'Shell',
                       tiers = { { spell = 'Shell V', level = 76 }, { spell = 'Shell IV', level = 68 }, { spell = 'Shell III', level = 57 }, { spell = 'Shell II', level = 37 }, { spell = 'Shell', level = 17 } } },
    shellra        = { action = 'ma', target = 'me', desc = 'Shellra',
                       tiers = { { spell = 'Shellra V', level = 75 }, { spell = 'Shellra IV', level = 68 }, { spell = 'Shellra III', level = 57 }, { spell = 'Shellra II', level = 37 }, { spell = 'Shellra', level = 17 } } },
    altsneak       = { action = 'ma', target = 'lastst', desc = 'Sneak',
                       tiers = { { spell = 'Sneak', level = 20 } } },
    stoneskin      = { action = 'ma', target = 'me', desc = 'Stoneskin',
                       tiers = { { spell = 'Stoneskin', level = 28 } } },
    teleportaltep  = { action = 'ma', target = 'me', desc = 'Teleport-Altep',
                       tiers = { { spell = 'Teleport-Altep', level = 38 } } },
    teleportdem    = { action = 'ma', target = 'me', desc = 'Teleport-Dem',
                       tiers = { { spell = 'Teleport-Dem', level = 36 } } },
    teleportholla  = { action = 'ma', target = 'me', desc = 'Teleport-Holla',
                       tiers = { { spell = 'Teleport-Holla', level = 36 } } },
    teleportmea    = { action = 'ma', target = 'me', desc = 'Teleport-Mea',
                       tiers = { { spell = 'Teleport-Mea', level = 36 } } },
    teleportvahzl  = { action = 'ma', target = 'me', desc = 'Teleport-Vahzl',
                       tiers = { { spell = 'Teleport-Vahzl', level = 42 } } },
    teleportyhoat  = { action = 'ma', target = 'me', desc = 'Teleport-Yhoat',
                       tiers = { { spell = 'Teleport-Yhoat', level = 38 } } },

    -- ========================================================================
    -- HEALING - select the ally first (/ta <stpc>)
    -- ========================================================================
    arise          = { action = 'ma', target = 'lastst', desc = 'Arise',
                       tiers = { { spell = 'Arise', level = 99 } } },
    blindna        = { action = 'ma', target = 'lastst', desc = 'Blindna',
                       tiers = { { spell = 'Blindna', level = 14 } } },
    cura           = { action = 'ma', target = 'me', desc = 'Cura',
                       tiers = { { spell = 'Cura III', level = 96 }, { spell = 'Cura II', level = 83 }, { spell = 'Cura', level = 40 } } },
    curaga         = { action = 'ma', target = 'lastst', desc = 'Curaga',
                       tiers = { { spell = 'Curaga V', level = 91 }, { spell = 'Curaga IV', level = 71 }, { spell = 'Curaga III', level = 51 }, { spell = 'Curaga II', level = 31 }, { spell = 'Curaga', level = 16 } } },
    cure           = { action = 'ma', target = 'lastst', desc = 'Cure',
                       tiers = { { spell = 'Cure VI', level = 80 }, { spell = 'Cure V', level = 61 }, { spell = 'Cure IV', level = 41 }, { spell = 'Cure III', level = 21 }, { spell = 'Cure II', level = 11 }, { spell = 'Cure', level = 1 } } },
    cursna         = { action = 'ma', target = 'lastst', desc = 'Cursna',
                       tiers = { { spell = 'Cursna', level = 29 } } },
    esuna          = { action = 'ma', target = 'me', desc = 'Esuna',
                       tiers = { { spell = 'Esuna', level = 61 } } },
    fullcure       = { action = 'ma', target = 'lastst', desc = 'Full Cure',
                       tiers = { { spell = 'Full Cure', level = 99 } } },
    paralyna       = { action = 'ma', target = 'lastst', desc = 'Paralyna',
                       tiers = { { spell = 'Paralyna', level = 9 } } },
    poisona        = { action = 'ma', target = 'lastst', desc = 'Poisona',
                       tiers = { { spell = 'Poisona', level = 6 } } },
    raise          = { action = 'ma', target = 'lastst', desc = 'Raise',
                       tiers = { { spell = 'Raise III', level = 70 }, { spell = 'Raise II', level = 56 }, { spell = 'Raise', level = 25 } } },
    reraise        = { action = 'ma', target = 'me', desc = 'Reraise',
                       tiers = { { spell = 'Reraise IV', level = 99 }, { spell = 'Reraise III', level = 70 }, { spell = 'Reraise II', level = 56 }, { spell = 'Reraise', level = 25 } } },
    sacrifice      = { action = 'ma', target = 'lastst', desc = 'Sacrifice',
                       tiers = { { spell = 'Sacrifice', level = 65 } } },
    silena         = { action = 'ma', target = 'lastst', desc = 'Silena',
                       tiers = { { spell = 'Silena', level = 19 } } },
    stona          = { action = 'ma', target = 'lastst', desc = 'Stona',
                       tiers = { { spell = 'Stona', level = 39 } } },
    viruna         = { action = 'ma', target = 'lastst', desc = 'Viruna',
                       tiers = { { spell = 'Viruna', level = 34 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first (/ta <stnpc>)
    -- ========================================================================
    impact         = { action = 'ma', target = 'lastst', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
}

return M

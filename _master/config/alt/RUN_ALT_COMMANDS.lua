---============================================================================
--- RUN Alt Commands - what the alt does when it is on RUN
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether RUN is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in RUN_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/RUN_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    battuta          = { action = 'ja', spell = 'Battuta',                target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Parry rate +40%, counter damage' },
    elementalsforzo  = { action = 'ja', spell = 'Elemental Sforzo',       target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Immune to all magic attacks' },
    embolden         = { action = 'ja', spell = 'Embolden',               target = 'me', level = 60, main_only = true, group = 'ja', desc = 'Next enhancing +50% potency, -50% duration' },
    flabra           = { action = 'ja', spell = 'Flabra',                 target = 'me', level = 5, group = 'ja', desc = 'Wind rune, resist earth' },
    gambit           = { action = 'ja', spell = 'Gambit',                 target = 'lastst', level = 70, main_only = true, group = 'ja', desc = 'Reduce enemy elemental defense (all runes)' },
    gelus            = { action = 'ja', spell = 'Gelus',                  target = 'me', level = 5, group = 'ja', desc = 'Ice rune, resist fire' },
    ignis            = { action = 'ja', spell = 'Ignis',                  target = 'me', level = 5, group = 'ja', desc = 'Fire rune, resist ice' },
    liement          = { action = 'ja', spell = 'Liement',                target = 'me', level = 85, main_only = true, group = 'ja', desc = 'Absorb elemental damage' },
    lunge            = { action = 'ja', spell = 'Lunge',                  target = 'lastst', level = 25, group = 'ja', desc = 'Single-target damage (all runes)' },
    lux              = { action = 'ja', spell = 'Lux',                    target = 'me', level = 5, group = 'ja', desc = 'Light rune, resist dark' },
    odyllicsubterfuge = { action = 'ja', spell = 'Odyllic Subterfuge',     target = 'lastst', level = 96, main_only = true, group = 'ja', desc = 'Enemy MACC -40' },
    oneforall        = { action = 'ja', spell = 'One for All',            target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Party Magic Shield (HP × 0.2)' },
    pflug            = { action = 'ja', spell = 'Pflug',                  target = 'me', level = 40, group = 'ja', desc = 'Enhance elemental status resistance' },
    rayke            = { action = 'ja', spell = 'Rayke',                  target = 'lastst', level = 75, main_only = true, group = 'ja', desc = 'Reduce enemy elemental resistance' },
    sulpor           = { action = 'ja', spell = 'Sulpor',                 target = 'me', level = 5, group = 'ja', desc = 'Thunder rune, resist water' },
    swipe            = { action = 'ja', spell = 'Swipe',                  target = 'lastst', level = 25, group = 'ja', desc = 'Single-target damage (1 rune)' },
    swordplay        = { action = 'ja', spell = 'Swordplay',              target = 'me', level = 20, group = 'ja', desc = 'ACC/EVA boost (stacking)' },
    tellus           = { action = 'ja', spell = 'Tellus',                 target = 'me', level = 5, group = 'ja', desc = 'Earth rune, resist wind' },
    tenebrae         = { action = 'ja', spell = 'Tenebrae',               target = 'me', level = 5, group = 'ja', desc = 'Dark rune, resist light' },
    unda             = { action = 'ja', spell = 'Unda',                   target = 'me', level = 5, group = 'ja', desc = 'Water rune, resist thunder' },
    valiance         = { action = 'ja', spell = 'Valiance',               target = 'me', level = 50, group = 'ja', desc = 'Party elemental damage reduction' },
    vallation        = { action = 'ja', spell = 'Vallation',              target = 'me', level = 10, group = 'ja', desc = 'Reduce elemental damage by runes' },
    vivaciouspulse   = { action = 'ja', spell = 'Vivacious Pulse',        target = 'me', level = 65, main_only = true, group = 'ja', desc = 'Restore HP based on runes' },

    -- ========================================================================
    -- ENHANCING - select the ally, or it lands on the alt
    -- ========================================================================
    aquaveil         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Aquaveil',
                       tiers = { { spell = 'Aquaveil', level = 15 } } },
    baraero          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Baraero',
                       tiers = { { spell = 'Baraero', level = 12 } } },
    baramnesia       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Baramnesia',
                       tiers = { { spell = 'Baramnesia', level = 76 } } },
    barblind         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barblind',
                       tiers = { { spell = 'Barblind', level = 17 } } },
    barblizzard      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barblizzard',
                       tiers = { { spell = 'Barblizzard', level = 20 } } },
    barfire          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barfire',
                       tiers = { { spell = 'Barfire', level = 16 } } },
    barparalyze      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barparalyze',
                       tiers = { { spell = 'Barparalyze', level = 11 } } },
    barpetrify       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barpetrify',
                       tiers = { { spell = 'Barpetrify', level = 42 } } },
    barpoison        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barpoison',
                       tiers = { { spell = 'Barpoison', level = 9 } } },
    barsilence       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barsilence',
                       tiers = { { spell = 'Barsilence', level = 22 } } },
    barsleep         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barsleep',
                       tiers = { { spell = 'Barsleep', level = 6 } } },
    barstone         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barstone',
                       tiers = { { spell = 'Barstone', level = 4 } } },
    barthunder       = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barthunder',
                       tiers = { { spell = 'Barthunder', level = 24 } } },
    barvirus         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barvirus',
                       tiers = { { spell = 'Barvirus', level = 38 } } },
    barwater         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Barwater',
                       tiers = { { spell = 'Barwater', level = 8 } } },
    blazespikes      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Blaze Spikes',
                       tiers = { { spell = 'Blaze Spikes', level = 45 } } },
    blink            = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Blink',
                       tiers = { { spell = 'Blink', level = 35 } } },
    crusade          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Crusade',
                       tiers = { { spell = 'Crusade', level = 88 } } },
    foil             = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Foil',
                       tiers = { { spell = 'Foil', level = 58 } } },
    icespikes        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Ice Spikes',
                       tiers = { { spell = 'Ice Spikes', level = 65 } } },
    phalanx          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Phalanx',
                       tiers = { { spell = 'Phalanx', level = 68 } } },
    protect          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Protect',
                       tiers = { { spell = 'Protect IV', level = 80 }, { spell = 'Protect III', level = 60 }, { spell = 'Protect II', level = 40 }, { spell = 'Protect', level = 20 } } },
    refresh          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Refresh',
                       tiers = { { spell = 'Refresh', level = 62 } } },
    regen            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Regen',
                       tiers = { { spell = 'Regen IV', level = 99 }, { spell = 'Regen III', level = 70 }, { spell = 'Regen II', level = 48 }, { spell = 'Regen', level = 23 } } },
    shell            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Shell',
                       tiers = { { spell = 'Shell V', level = 90 }, { spell = 'Shell IV', level = 70 }, { spell = 'Shell III', level = 50 }, { spell = 'Shell II', level = 30 }, { spell = 'Shell', level = 10 } } },
    shockspikes      = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Shock Spikes',
                       tiers = { { spell = 'Shock Spikes', level = 85 } } },
    stoneskin        = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Stoneskin',
                       tiers = { { spell = 'Stoneskin', level = 55 } } },
    temper           = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Temper',
                       tiers = { { spell = 'Temper', level = 99 } } },
}

return M

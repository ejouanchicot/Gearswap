---============================================================================
--- DRK Alt Commands - what the alt does when it is on DRK
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether DRK is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in DRK_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/DRK_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    arcanecircle     = { action = 'ja', spell = 'Arcane Circle',          target = 'me', level = 5, group = 'ja', desc = 'ATK/DEF+ vs Arcana (party AoE)' },
    arcanecrest      = { action = 'ja', spell = 'Arcane Crest',           target = 'lastst', level = 87, main_only = true, group = 'ja', desc = 'Arcana: ACC/EVA/MACC/MEVA/TP down' },
    bloodweapon      = { action = 'ja', spell = 'Blood Weapon',           target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Drain HP with melee attacks' },
    consumemana      = { action = 'ja', spell = 'Consume Mana',           target = 'me', level = 55, group = 'ja', desc = 'All MP >> damage (1 per 10 MP)' },
    darkseal         = { action = 'ja', spell = 'Dark Seal',              target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Next dark magic MACC+' },
    diaboliceye      = { action = 'ja', spell = 'Diabolic Eye',           target = 'me', level = 75, main_only = true, group = 'ja', desc = 'ACC+20, max HP-15%' },
    lastresort       = { action = 'ja', spell = 'Last Resort',            target = 'me', level = 15, group = 'ja', desc = 'ATK+25% DEF-25%' },
    nethervoid       = { action = 'ja', spell = 'Nether Void',            target = 'me', level = 78, main_only = true, group = 'ja', desc = 'Next Absorb/Drain +50%' },
    scarletdelirium  = { action = 'ja', spell = 'Scarlet Delirium',       target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Damage taken >> ATK/MATT boost' },
    soulenslavement  = { action = 'ja', spell = 'Soul Enslavement',       target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Absorb TP with melee attacks' },
    souleater        = { action = 'ja', spell = 'Souleater',              target = 'me', level = 30, group = 'ja', desc = 'HP >> damage, ACC+25' },
    weaponbash       = { action = 'ja', spell = 'Weapon Bash',            target = 'lastst', level = 20, group = 'ja', desc = 'Stun attack' },

    -- ========================================================================
    -- ENFEEBLING - select the mob first
    -- ========================================================================
    bind             = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Bind',
                       tiers = { { spell = 'Bind', level = 20 } } },
    breaksp          = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Break',
                       tiers = { { spell = 'Break', level = 95 } } },
    poison           = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Poison',
                       tiers = { { spell = 'Poison II', level = 46 }, { spell = 'Poison', level = 6 } } },
    poisonga         = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Poisonga',
                       tiers = { { spell = 'Poisonga', level = 26 } } },
    sleep            = { action = 'ma', target = 'lastst', group = 'enfeebling', desc = 'Sleep',
                       tiers = { { spell = 'Sleep II', level = 56 }, { spell = 'Sleep', level = 30 } } },

    -- ========================================================================
    -- ELEMENTAL - select the mob first
    -- ========================================================================
    aero             = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Aero',
                       tiers = { { spell = 'Aero III', level = 84 }, { spell = 'Aero II', level = 54 }, { spell = 'Aero', level = 17 } } },
    blizzard         = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Blizzard',
                       tiers = { { spell = 'Blizzard III', level = 92 }, { spell = 'Blizzard II', level = 66 }, { spell = 'Blizzard', level = 29 } } },
    fire             = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Fire',
                       tiers = { { spell = 'Fire III', level = 88 }, { spell = 'Fire II', level = 60 }, { spell = 'Fire', level = 23 } } },
    impact           = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Impact',
                       tiers = { { spell = 'Impact', level = 90 } } },
    stone            = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Stone',
                       tiers = { { spell = 'Stone III', level = 76 }, { spell = 'Stone II', level = 42 }, { spell = 'Stone', level = 5 } } },
    thunder          = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Thunder',
                       tiers = { { spell = 'Thunder III', level = 96 }, { spell = 'Thunder II', level = 72 }, { spell = 'Thunder', level = 35 } } },
    water            = { action = 'ma', target = 'lastst', group = 'elemental', desc = 'Water',
                       tiers = { { spell = 'Water III', level = 80 }, { spell = 'Water II', level = 48 }, { spell = 'Water', level = 11 } } },

    -- ========================================================================
    -- DARK MAGIC - select the mob first
    -- ========================================================================
    absorbacc        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-ACC',
                       tiers = { { spell = 'Absorb-ACC', level = 61 } } },
    absorbagi        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-AGI',
                       tiers = { { spell = 'Absorb-AGI', level = 37 } } },
    absorbattri      = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-Attri',
                       tiers = { { spell = 'Absorb-Attri', level = 91 } } },
    absorbchr        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-CHR',
                       tiers = { { spell = 'Absorb-CHR', level = 33 } } },
    absorbdex        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-DEX',
                       tiers = { { spell = 'Absorb-DEX', level = 41 } } },
    absorbint        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-INT',
                       tiers = { { spell = 'Absorb-INT', level = 39 } } },
    absorbmnd        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-MND',
                       tiers = { { spell = 'Absorb-MND', level = 31 } } },
    absorbstr        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-STR',
                       tiers = { { spell = 'Absorb-STR', level = 43 } } },
    absorbtp         = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-TP',
                       tiers = { { spell = 'Absorb-TP', level = 45 } } },
    absorbvit        = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Absorb-VIT',
                       tiers = { { spell = 'Absorb-VIT', level = 35 } } },
    aspir            = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Aspir',
                       tiers = { { spell = 'Aspir II', level = 78 }, { spell = 'Aspir', level = 20 } } },
    bio              = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Bio',
                       tiers = { { spell = 'Bio II', level = 40 }, { spell = 'Bio', level = 15 } } },
    drain            = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Drain',
                       tiers = { { spell = 'Drain III', level = 99 }, { spell = 'Drain II', level = 62 }, { spell = 'Drain', level = 10 } } },
    dreadspikes      = { action = 'ma', target = 'me', group = 'dark', desc = 'Dread Spikes',
                       tiers = { { spell = 'Dread Spikes', level = 71 } } },
    endark           = { action = 'ma', target = 'me', group = 'dark', desc = 'Endark',
                       tiers = { { spell = 'Endark II', level = 99 }, { spell = 'Endark', level = 85 } } },
    stun             = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Stun',
                       tiers = { { spell = 'Stun', level = 37 } } },
    tractor          = { action = 'ma', target = 'lastst', group = 'dark', desc = 'Tractor',
                       tiers = { { spell = 'Tractor', level = 32 } } },
}

return M

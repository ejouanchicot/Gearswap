---============================================================================
--- NIN Alt Commands - what the alt does when it is on NIN
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether NIN is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in NIN_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/NIN_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    futae            = { action = 'ja', spell = 'Futae',                  target = 'me', level = 77, main_only = true, group = 'ja', desc = 'Next elemental ninjutsu +50% (2 tools)' },
    innin            = { action = 'ja', spell = 'Innin',                  target = 'me', level = 40, main_only = true, group = 'ja', desc = '-Enmity/EVA, +Ninjutsu/Crit from behind' },
    issekigan        = { action = 'ja', spell = 'Issekigan',              target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Parry rate+, enmity on parry' },
    mijingakure      = { action = 'ja', spell = 'Mijin Gakure',           target = 'lastst', level = 1, main_only = true, group = 'ja', desc = 'Sacrifice self, damage enemy (~50% HP)' },
    mikage           = { action = 'ja', spell = 'Mikage',                 target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Multi-attack based on Utsusemi shadows' },
    sange            = { action = 'ja', spell = 'Sange',                  target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Daken 100%, consume shuriken' },
    yonin            = { action = 'ja', spell = 'Yonin',                  target = 'me', level = 40, main_only = true, group = 'ja', desc = '+Enmity/EVA, -ACC' },

    -- ========================================================================
    -- NINJUTSU
    -- ========================================================================
    aishaichi        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Aisha: Ichi',
                       tiers = { { spell = 'Aisha: Ichi', level = 78 } } },
    dokumoriichi     = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Dokumori: Ichi',
                       tiers = { { spell = 'Dokumori: Ichi', level = 27 } } },
    dotonichi        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Doton: Ichi',
                       tiers = { { spell = 'Doton: Ichi', level = 15 } } },
    dotonni          = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Doton: Ni',
                       tiers = { { spell = 'Doton: Ni', level = 40 } } },
    dotonsan         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Doton: San',
                       tiers = { { spell = 'Doton: San', level = 75 } } },
    gekkaichi        = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Gekka: Ichi',
                       tiers = { { spell = 'Gekka: Ichi', level = 88 } } },
    hojoichi         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Hojo: Ichi',
                       tiers = { { spell = 'Hojo: Ichi', level = 23 } } },
    hojoni           = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Hojo: Ni',
                       tiers = { { spell = 'Hojo: Ni', level = 48 } } },
    hutonichi        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Huton: Ichi',
                       tiers = { { spell = 'Huton: Ichi', level = 15 } } },
    hutonni          = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Huton: Ni',
                       tiers = { { spell = 'Huton: Ni', level = 40 } } },
    hutonsan         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Huton: San',
                       tiers = { { spell = 'Huton: San', level = 75 } } },
    hyotonichi       = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Hyoton: Ichi',
                       tiers = { { spell = 'Hyoton: Ichi', level = 15 } } },
    hyotonni         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Hyoton: Ni',
                       tiers = { { spell = 'Hyoton: Ni', level = 40 } } },
    hyotonsan        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Hyoton: San',
                       tiers = { { spell = 'Hyoton: San', level = 75 } } },
    jubakuichi       = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Jubaku: Ichi',
                       tiers = { { spell = 'Jubaku: Ichi', level = 30 } } },
    kakkaichi        = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Kakka: Ichi',
                       tiers = { { spell = 'Kakka: Ichi', level = 93 } } },
    katonichi        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Katon: Ichi',
                       tiers = { { spell = 'Katon: Ichi', level = 15 } } },
    katonni          = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Katon: Ni',
                       tiers = { { spell = 'Katon: Ni', level = 40 } } },
    katonsan         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Katon: San',
                       tiers = { { spell = 'Katon: San', level = 75 } } },
    kurayamiichi     = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Kurayami: Ichi',
                       tiers = { { spell = 'Kurayami: Ichi', level = 19 } } },
    kurayamini       = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Kurayami: Ni',
                       tiers = { { spell = 'Kurayami: Ni', level = 44 } } },
    migawariichi     = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Migawari: Ichi',
                       tiers = { { spell = 'Migawari: Ichi', level = 88 } } },
    monomiichi       = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Monomi: Ichi',
                       tiers = { { spell = 'Monomi: Ichi', level = 25 } } },
    myoshuichi       = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Myoshu: Ichi',
                       tiers = { { spell = 'Myoshu: Ichi', level = 85 } } },
    raitonichi       = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Raiton: Ichi',
                       tiers = { { spell = 'Raiton: Ichi', level = 15 } } },
    raitonni         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Raiton: Ni',
                       tiers = { { spell = 'Raiton: Ni', level = 40 } } },
    raitonsan        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Raiton: San',
                       tiers = { { spell = 'Raiton: San', level = 75 } } },
    suitonichi       = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Suiton: Ichi',
                       tiers = { { spell = 'Suiton: Ichi', level = 15 } } },
    suitonni         = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Suiton: Ni',
                       tiers = { { spell = 'Suiton: Ni', level = 40 } } },
    suitonsan        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Suiton: San',
                       tiers = { { spell = 'Suiton: San', level = 75 } } },
    tonkoichi        = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Tonko: Ichi',
                       tiers = { { spell = 'Tonko: Ichi', level = 9 } } },
    tonkoni          = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Tonko: Ni',
                       tiers = { { spell = 'Tonko: Ni', level = 34 } } },
    utsusemiichi     = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Utsusemi: Ichi',
                       tiers = { { spell = 'Utsusemi: Ichi', level = 12 } } },
    utsusemini       = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Utsusemi: Ni',
                       tiers = { { spell = 'Utsusemi: Ni', level = 37 } } },
    utsusemisan      = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Utsusemi: San',
                       tiers = { { spell = 'Utsusemi: San', level = 99 } } },
    yainichi         = { action = 'ninjutsu', target = 'me', group = 'ninjutsu', desc = 'Yain: Ichi',
                       tiers = { { spell = 'Yain: Ichi', level = 91 } } },
    yurinichi        = { action = 'ninjutsu', target = 'lastst', group = 'ninjutsu', desc = 'Yurin: Ichi',
                       tiers = { { spell = 'Yurin: Ichi', level = 83 } } },
}

return M

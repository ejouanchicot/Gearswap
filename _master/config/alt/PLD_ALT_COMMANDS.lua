---============================================================================
--- PLD Alt Commands - what the alt does when it is on PLD
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether PLD is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in PLD_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/PLD_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    chivalry         = { action = 'ja', spell = 'Chivalry',               target = 'me', level = 75, main_only = true, group = 'ja', desc = 'TP >> MP' },
    cover            = { action = 'ja', spell = 'Cover',                  target = 'lastst', level = 35, group = 'ja', desc = 'Redirect ally damage to self' },
    divineemblem     = { action = 'ja', spell = 'Divine Emblem',          target = 'me', level = 78, main_only = true, group = 'ja', desc = 'Next divine spell MACC+, enmity+' },
    fealty           = { action = 'ja', spell = 'Fealty',                 target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Enfeebling resist, blocks Charm' },
    holycircle       = { action = 'ja', spell = 'Holy Circle',            target = 'me', level = 5, group = 'ja', desc = 'ATK/DEF+ vs Undead (party AoE)' },
    intervene        = { action = 'ja', spell = 'Intervene',              target = 'lastst', level = 96, main_only = true, group = 'ja', desc = 'Shield strike, ATK/ACC >> 1' },
    invincible       = { action = 'ja', spell = 'Invincible',             target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Physical damage immunity' },
    majesty          = { action = 'ja', spell = 'Majesty',                target = 'me', level = 70, main_only = true, group = 'ja', desc = 'Cure/Protect AoE, +potency/-recast' },
    palisade         = { action = 'ja', spell = 'Palisade',               target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Shield block +30%, no enmity loss' },
    rampart          = { action = 'ja', spell = 'Rampart',                target = 'me', level = 62, main_only = true, group = 'ja', desc = 'Party damage -25%' },
    sentinel         = { action = 'ja', spell = 'Sentinel',               target = 'me', level = 30, group = 'ja', desc = 'Physical damage -90>>-50%, +enmity' },
    sepulcher        = { action = 'ja', spell = 'Sepulcher',              target = 'lastst', level = 87, main_only = true, group = 'ja', desc = 'Undead: ACC/EVA/MACC/MEVA/TP down' },
    shieldbash       = { action = 'ja', spell = 'Shield Bash',            target = 'lastst', level = 15, group = 'ja', desc = 'Stun attack' },

    -- ========================================================================
    -- ENHANCING - select the ally, or it lands on the alt
    -- ========================================================================
    crusade          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Crusade',
                       tiers = { { spell = 'Crusade', level = 88 } } },
    phalanx          = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Phalanx',
                       tiers = { { spell = 'Phalanx', level = 77 } } },
    protect          = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Protect',
                       tiers = { { spell = 'Protect V', level = 90 }, { spell = 'Protect IV', level = 70 }, { spell = 'Protect III', level = 50 }, { spell = 'Protect II', level = 30 }, { spell = 'Protect', level = 10 } } },
    reprisal         = { action = 'ma', target = 'me', group = 'enhancing', desc = 'Reprisal',
                       tiers = { { spell = 'Reprisal', level = 61 } } },
    shell            = { action = 'ma', target = 'lastst', group = 'enhancing', desc = 'Shell',
                       tiers = { { spell = 'Shell IV', level = 80 }, { spell = 'Shell III', level = 60 }, { spell = 'Shell II', level = 40 }, { spell = 'Shell', level = 20 } } },

    -- ========================================================================
    -- HEALING - select the ally first
    -- ========================================================================
    cure             = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Cure',
                       tiers = { { spell = 'Cure IV', level = 55 }, { spell = 'Cure III', level = 30 }, { spell = 'Cure II', level = 17 }, { spell = 'Cure', level = 5 } } },
    raise            = { action = 'ma', target = 'lastst', group = 'healing', desc = 'Raise',
                       tiers = { { spell = 'Raise', level = 50 } } },
}

return M

---============================================================================
--- DNC Alt Commands - what the alt does when it is on DNC
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether DNC is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in DNC_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/DNC_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    aspirsamba       = { action = 'ja', spell = 'Aspir Samba',            target = 'me', level = 25, group = 'ja', desc = 'Party drains MP from target' },
    aspirsambaii     = { action = 'ja', spell = 'Aspir Samba II',         target = 'me', level = 60, main_only = true, group = 'ja', desc = 'Party drains MP from target (enhanced)' },
    boxstep          = { action = 'ja', spell = 'Box Step',               target = 'lastst', level = 30, group = 'ja', desc = 'Defense down. Grants FM if successful' },
    chocobojig       = { action = 'ja', spell = 'Chocobo Jig',            target = 'me', level = 55, main_only = true, group = 'ja', desc = 'Movement speed +20%' },
    chocobojigii     = { action = 'ja', spell = 'Chocobo Jig II',         target = 'me', level = 70, main_only = true, group = 'ja', desc = 'Movement speed +20% (AoE)' },
    contradance      = { action = 'ja', spell = 'Contradance',            target = 'me', level = 50, group = 'ja', desc = 'Doubles next Waltz potency' },
    curingwaltz      = { action = 'ja', spell = 'Curing Waltz',           target = 'lastst', level = 15, group = 'ja', desc = 'Restores HP' },
    curingwaltzii    = { action = 'ja', spell = 'Curing Waltz II',        target = 'lastst', level = 30, group = 'ja', desc = 'Restores HP' },
    curingwaltziii   = { action = 'ja', spell = 'Curing Waltz III',       target = 'lastst', level = 45, group = 'ja', desc = 'Restores HP' },
    curingwaltziv    = { action = 'ja', spell = 'Curing Waltz IV',        target = 'lastst', level = 70, main_only = true, group = 'ja', desc = 'Restores HP' },
    curingwaltzv     = { action = 'ja', spell = 'Curing Waltz V',         target = 'lastst', level = 87, main_only = true, group = 'ja', desc = 'Restores HP' },
    divinewaltz      = { action = 'ja', spell = 'Divine Waltz',           target = 'lastst', level = 25, group = 'ja', desc = 'Restores HP (AoE)' },
    divinewaltzii    = { action = 'ja', spell = 'Divine Waltz II',        target = 'lastst', level = 78, main_only = true, group = 'ja', desc = 'Restores HP (AoE)' },
    drainsamba       = { action = 'ja', spell = 'Drain Samba',            target = 'me', level = 5, group = 'ja', desc = 'Party drains HP from target' },
    drainsambaii     = { action = 'ja', spell = 'Drain Samba II',         target = 'me', level = 35, group = 'ja', desc = 'Party drains HP from target (enhanced)' },
    drainsambaiii    = { action = 'ja', spell = 'Drain Samba III',        target = 'me', level = 65, main_only = true, group = 'ja', desc = 'Party drains HP from target (superior)' },
    fandance         = { action = 'ja', spell = 'Fan Dance',              target = 'me', level = 75, main_only = true, group = 'ja', desc = 'PDT- Enmity+ but disables Sambas' },
    featherstep      = { action = 'ja', spell = 'Feather Step',           target = 'lastst', level = 83, main_only = true, group = 'ja', desc = 'Crit Evasion down. Grants FM if successful' },
    grandpas         = { action = 'ja', spell = 'Grand Pas',              target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Flourishes without FM cost (30s or 3 uses)' },
    hastesamba       = { action = 'ja', spell = 'Haste Samba',            target = 'me', level = 45, group = 'ja', desc = 'Party gains Haste from target' },
    healingwaltz     = { action = 'ja', spell = 'Healing Waltz',          target = 'lastst', level = 35, group = 'ja', desc = 'Removes one status ailment' },
    nofootrise       = { action = 'ja', spell = 'No Foot Rise',           target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Instantly grants FM (1 per merit)' },
    presto           = { action = 'ja', spell = 'Presto',                 target = 'me', level = 77, main_only = true, group = 'ja', desc = 'Enhances next Step and grants +FM' },
    quickstep        = { action = 'ja', spell = 'Quickstep',              target = 'lastst', level = 20, group = 'ja', desc = 'Evasion down. Grants FM if successful' },
    saberdance       = { action = 'ja', spell = 'Saber Dance',            target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Double Attack+ but disables Waltzes' },
    spectraljig      = { action = 'ja', spell = 'Spectral Jig',           target = 'me', level = 25, group = 'ja', desc = 'Sneak + Invisible' },
    stutterstep      = { action = 'ja', spell = 'Stutter Step',           target = 'lastst', level = 40, group = 'ja', desc = 'Magic Evasion down. Grants FM if successful' },
    trance           = { action = 'ja', spell = 'Trance',                 target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Dances and steps TP cost 0' },
}

return M

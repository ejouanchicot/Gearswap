---============================================================================
--- RNG Alt Commands - what the alt does when it is on RNG
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether RNG is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in RNG_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/RNG_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    barrage          = { action = 'ja', spell = 'Barrage',                target = 'me', level = 30, group = 'ja', desc = 'Fire multiple shots (4-13 based on level)' },
    bountyshot       = { action = 'ja', spell = 'Bounty Shot',            target = 'lastst', level = 87, main_only = true, group = 'ja', desc = 'Apply TH+2 to target' },
    camouflage       = { action = 'ja', spell = 'Camouflage',             target = 'me', level = 20, group = 'ja', desc = 'Invisible, reduced ranged enmity' },
    decoyshot        = { action = 'ja', spell = 'Decoy Shot',             target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Transfer 80% ranged enmity to party' },
    doubleshot       = { action = 'ja', spell = 'Double Shot',            target = 'me', level = 79, main_only = true, group = 'ja', desc = '40% chance double damage' },
    eagleeyeshot     = { action = 'ja', spell = 'Eagle Eye Shot',         target = 'lastst', level = 1, main_only = true, group = 'ja', desc = 'Powerful accurate shot x5 damage' },
    flashyshot       = { action = 'ja', spell = 'Flashy Shot',            target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Next attack +enmity/ACC/damage' },
    hovershot        = { action = 'ja', spell = 'Hover Shot',             target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Damage/ACC+ per shot from different position' },
    overkill         = { action = 'ja', spell = 'Overkill',               target = 'me', level = 96, main_only = true, group = 'ja', desc = 'Ranged speed +50%, Double/Triple Shot 100%' },
    scavenge         = { action = 'ja', spell = 'Scavenge',               target = 'me', level = 10, group = 'ja', desc = 'Recover spent ammunition' },
    shadowbind       = { action = 'ja', spell = 'Shadowbind',             target = 'lastst', level = 40, group = 'ja', desc = 'Root enemy (30s, breaks on damage)' },
    sharpshot        = { action = 'ja', spell = 'Sharpshot',              target = 'me', level = 1, group = 'ja', desc = 'Ranged ACC +40' },
    stealthshot      = { action = 'ja', spell = 'Stealth Shot',           target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Next attack -enmity' },
    unlimitedshot    = { action = 'ja', spell = 'Unlimited Shot',         target = 'me', level = 51, group = 'ja', desc = 'Next ranged attack no ammo cost' },
    velocityshot     = { action = 'ja', spell = 'Velocity Shot',          target = 'me', level = 45, main_only = true, group = 'ja', desc = 'Ranged ATK/speed +15%, melee -15%' },
}

return M

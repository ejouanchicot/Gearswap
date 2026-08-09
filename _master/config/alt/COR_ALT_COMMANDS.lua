---============================================================================
--- COR Alt Commands - what the alt does when it is on COR
---============================================================================
--- Read by shared/utils/dualbox/alt_commands.lua, whether COR is the alt's
--- MAIN job or its SUBJOB. Type the key on the MAIN and the alt performs it.
---
--- GENERATED - do not edit. Put your changes in COR_ALT_CUSTOM.lua, which is
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
--- @file    config/alt/COR_ALT_COMMANDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2026-08-09
---============================================================================

local M = {}

M.commands = {
    -- ========================================================================
    -- JOB ABILITIES
    -- ========================================================================
    alliesroll       = { action = 'ja', spell = "Allies' Roll",           target = 'me', level = 89, main_only = true, group = 'ja', desc = 'Skillchain damage+' },
    avengersroll     = { action = 'ja', spell = "Avenger's Roll",         target = 'me', level = 97, main_only = true, group = 'ja', desc = 'Counter rate+' },
    beastroll        = { action = 'ja', spell = 'Beast Roll',             target = 'me', level = 34, group = 'ja', desc = 'Pet Attack/Ranged Attack+' },
    blitzersroll     = { action = 'ja', spell = "Blitzer's Roll",         target = 'me', level = 83, main_only = true, group = 'ja', desc = 'Attack delay-' },
    boltersroll      = { action = 'ja', spell = "Bolter's Roll",          target = 'me', level = 76, main_only = true, group = 'ja', desc = 'Movement speed+' },
    castersroll      = { action = 'ja', spell = "Caster's Roll",          target = 'me', level = 79, main_only = true, group = 'ja', desc = 'Fast Cast+' },
    chaosroll        = { action = 'ja', spell = 'Chaos Roll',             target = 'me', level = 14, group = 'ja', desc = 'Attack+' },
    choralroll       = { action = 'ja', spell = 'Choral Roll',            target = 'me', level = 26, group = 'ja', desc = 'Spell interruption rate-' },
    companionsroll   = { action = 'ja', spell = "Companion's Roll",       target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Pet Regain/Regen' },
    corsairsroll     = { action = 'ja', spell = "Corsair's Roll",         target = 'me', level = 5, group = 'ja', desc = 'EXP/CP/EP bonus' },
    coursersroll     = { action = 'ja', spell = "Courser's Roll",         target = 'me', level = 81, main_only = true, group = 'ja', desc = 'Snapshot+' },
    crookedcards     = { action = 'ja', spell = 'Crooked Cards',          target = 'me', level = 95, main_only = true, group = 'ja', desc = 'Next roll +20% (bust penalty +20%)' },
    cuttingcards     = { action = 'ja', spell = 'Cutting Cards',          target = 'lastst', level = 96, main_only = true, group = 'ja', desc = 'Party SP recast -5-50%' },
    dancersroll      = { action = 'ja', spell = "Dancer's Roll",          target = 'me', level = 61, main_only = true, group = 'ja', desc = 'Regen (HP/tick)' },
    doubleup         = { action = 'ja', spell = 'Double-Up',              target = 'me', level = 5, group = 'ja', desc = 'Reroll last roll (max 11)' },
    drachenroll      = { action = 'ja', spell = 'Drachen Roll',           target = 'me', level = 23, group = 'ja', desc = 'Pet Accuracy/Ranged Accuracy+' },
    evokersroll      = { action = 'ja', spell = "Evoker's Roll",          target = 'me', level = 40, group = 'ja', desc = 'Refresh (MP regen)' },
    fightersroll     = { action = 'ja', spell = "Fighter's Roll",         target = 'me', level = 49, group = 'ja', desc = 'Double Attack rate+' },
    fold             = { action = 'ja', spell = 'Fold',                   target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Remove longest roll/bust' },
    gallantsroll     = { action = 'ja', spell = "Gallant's Roll",         target = 'me', level = 55, group = 'ja', desc = 'Defense+' },
    healersroll      = { action = 'ja', spell = "Healer's Roll",          target = 'me', level = 20, group = 'ja', desc = 'Cure potency+' },
    huntersroll      = { action = 'ja', spell = "Hunter's Roll",          target = 'me', level = 11, group = 'ja', desc = 'Accuracy/Ranged Accuracy+' },
    magussroll       = { action = 'ja', spell = "Magus's Roll",           target = 'me', level = 17, group = 'ja', desc = 'Magic Defense+' },
    misersroll       = { action = 'ja', spell = "Miser's Roll",           target = 'me', level = 92, main_only = true, group = 'ja', desc = 'Save TP' },
    monksroll        = { action = 'ja', spell = "Monk's Roll",            target = 'me', level = 31, group = 'ja', desc = 'Subtle Blow+' },
    naturalistsroll  = { action = 'ja', spell = "Naturalist's Roll",      target = 'me', level = 67, main_only = true, group = 'ja', desc = 'Enhancing magic duration+' },
    ninjaroll        = { action = 'ja', spell = 'Ninja Roll',             target = 'me', level = 8, group = 'ja', desc = 'Evasion+' },
    puppetroll       = { action = 'ja', spell = 'Puppet Roll',            target = 'me', level = 52, group = 'ja', desc = 'Pet Magic Attack/Magic Accuracy+' },
    quickdraw        = { action = 'ja', spell = 'Quick Draw',             target = 'me', level = 40, group = 'ja', desc = 'Ranged elemental damage' },
    randomdeal       = { action = 'ja', spell = 'Random Deal',            target = 'me', level = 50, group = 'ja', desc = 'Random party ability reset' },
    roguesroll       = { action = 'ja', spell = "Rogue's Roll",           target = 'me', level = 43, group = 'ja', desc = 'Critical hit rate+' },
    runeistsroll     = { action = 'ja', spell = "Runeist's Roll",         target = 'me', level = 70, main_only = true, group = 'ja', desc = 'Magic Evasion+' },
    samurairoll      = { action = 'ja', spell = 'Samurai Roll',           target = 'me', level = 37, group = 'ja', desc = 'Store TP+' },
    scholarsroll     = { action = 'ja', spell = "Scholar's Roll",         target = 'me', level = 64, main_only = true, group = 'ja', desc = 'Conserve MP+' },
    snakeeye         = { action = 'ja', spell = 'Snake Eye',              target = 'me', level = 75, main_only = true, group = 'ja', desc = 'Force roll = 1, auto-11 chance' },
    tacticiansroll   = { action = 'ja', spell = "Tactician's Roll",       target = 'me', level = 86, main_only = true, group = 'ja', desc = 'Regain (TP/tick)' },
    tripleshot       = { action = 'ja', spell = 'Triple Shot',            target = 'me', level = 87, main_only = true, group = 'ja', desc = '40% triple shot' },
    warlocksroll     = { action = 'ja', spell = "Warlock's Roll",         target = 'me', level = 46, group = 'ja', desc = 'Magic Accuracy+' },
    wildcard         = { action = 'ja', spell = 'Wild Card',              target = 'me', level = 1, main_only = true, group = 'ja', desc = 'Random party ability reset (1-6)' },
    wizardsroll      = { action = 'ja', spell = "Wizard's Roll",          target = 'me', level = 58, group = 'ja', desc = 'Magic Attack+' },
}

return M

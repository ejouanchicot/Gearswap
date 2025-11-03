---============================================================================
--- Dagger Weapon Skills Database
---============================================================================
--- Daggers are primarily used by Thief (A+, skill cap 424) and Dancer
--- (A+, skill cap 424), with extensive support from Corsair (B+, 404),
--- Red Mage (B, 398), Bard (B-, 388), and Ranger (B-, 388).
---
--- Three WS categories:
---   • Status/Utility: Wasp Sting (Poison), Shadowstitch (Bind),
---     Viper Bite (Poison), Energy Steal/Drain (MP drain)
---   • Damage: Gust Slash, Cyclone (AoE), Dancing Edge, Shark Bite,
---     Evisceration, Aeolian Edge (AoE), Exenterator
---   • Relic/Mythic/Empyrean: Mercy Stroke, Rudra's Storm, Mandalic Stab,
---     Mordant Rime, Pyrrhic Kleos, Ruthless Stroke
---
--- Total: 18 weaponskills
---
--- @file DAGGER_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-10-29
---============================================================================

local DAGGER_WS = {
    ---========================================================================
    --- BASIC WEAPONSKILLS (Levels 1-60)
    ---========================================================================

    ['Wasp Sting'] = {
        description = "Poison, duration varies",
        skill_level = 5,
        job_levels = {
            THF = 1, DNC = 1, RDM = 2, BRD = 2, RNG = 2,
            NIN = 2, COR = 2, WAR = 2, BST = 2, DRK = 2,
            GEO = 2, PLD = 2, PUP = 2, BLM = 2, SCH = 2,
            DRG = 2, SAM = 2, SMN = 2
        },
        stat_modifiers = "100% DEX",
        sc_properties = {'Scission'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "Poison duration 30-120s by TP"
    },

    ['Gust Slash'] = {
        description = "Wind elemental damage",
        skill_level = 40,
        job_levels = {
            THF = 13, DNC = 13, RDM = 14, BRD = 14, RNG = 14,
            NIN = 14, COR = 14, WAR = 14, BST = 14
        },
        stat_modifiers = "40% DEX / 40% INT",
        sc_properties = {'Detonation'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = "Wind",
        notes = "Wind-based magical WS"
    },

    ['Shadowstitch'] = {
        description = "Bind, chance varies",
        skill_level = 70,
        job_levels = {
            THF = 23, DNC = 23, RDM = 24, BRD = 24, RNG = 24,
            NIN = 24, COR = 24, WAR = 24, BST = 24
        },
        stat_modifiers = "100% CHR",
        sc_properties = {'Reverberation'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "Bind chance increases with TP"
    },

    ['Viper Bite'] = {
        description = "2-hit + Poison",
        skill_level = 100,
        job_levels = {
            THF = 33, DNC = 33, RDM = 34, BRD = 34, RNG = 34,
            NIN = 34, COR = 34
        },
        stat_modifiers = "100% DEX",
        sc_properties = {},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "2 hits, Poison duration varies by TP"
    },

    ['Cyclone'] = {
        description = "AoE Wind damage",
        skill_level = 125,
        job_levels = {
            THF = 41, DNC = 41, RDM = 42, BRD = 42, RNG = 42,
            NIN = 42, COR = 42
        },
        stat_modifiers = "40% DEX",
        sc_properties = {'Scission'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = "Wind",
        notes = "AoE Wind magical, damage varies by TP"
    },

    ['Energy Steal'] = {
        description = "Steals MP",
        skill_level = 150,
        job_levels = {
            THF = 49, DNC = 49, RDM = 51, BRD = 51, RNG = 51,
            NIN = 51, COR = 51
        },
        stat_modifiers = "100% MND",
        sc_properties = {},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "MP drain varies by TP"
    },

    ['Energy Drain'] = {
        description = "Steals MP (enhanced)",
        skill_level = 175,
        job_levels = {
            THF = 55, DNC = 55, RDM = 56, BRD = 56, RNG = 56,
            NIN = 56, COR = 56
        },
        stat_modifiers = "100% MND",
        sc_properties = {},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "Enhanced MP drain vs Energy Steal"
    },

    ---========================================================================
    --- ADVANCED WEAPONSKILLS (Levels 65-99)
    ---========================================================================

    ['Dancing Edge'] = {
        description = "5-hit, ACC varies",
        skill_level = 200,
        job_levels = {THF = 60, DNC = 60},
        stat_modifiers = "40% DEX / 40% CHR",
        sc_properties = {'Scission', 'Detonation'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "THF/DNC only, 5 hits, ACC bonus by TP"
    },

    ['Shark Bite'] = {
        description = "2-hit, dmg varies",
        skill_level = 225,
        job_levels = {THF = 65, DNC = 65},
        stat_modifiers = "40% DEX / 40% AGI",
        sc_properties = {'Fragmentation'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "THF/DNC only, 2 hits, fTP varies"
    },

    ['Evisceration'] = {
        description = "5-hit, crit varies",
        skill_level = 230,
        job_levels = {
            THF = 68, DNC = 68, RDM = 75, BRD = 75, RNG = 75,
            NIN = 75, COR = 75, WAR = 75, BST = 75
        },
        stat_modifiers = "50% DEX",
        sc_properties = {'Gravitation', 'Transfixion'},
        requires_quest = true,
        quest_name = "The Weight of Your Limits",
        requires_merit = false,
        special_weapons = nil,
        element = nil,
        notes = "5 hits, crit rate +10/+15/+25% by TP, quest required"
    },

    ['Aeolian Edge'] = {
        description = "AoE Wind, dmg varies",
        skill_level = 290,
        job_levels = {
            THF = 73, DNC = 73, RDM = 99, BRD = 99, RNG = 99,
            NIN = 99, COR = 99
        },
        stat_modifiers = "40% DEX / 40% INT",
        sc_properties = {'Scission', 'Detonation', 'Impaction'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = nil,
        element = "Wind",
        notes = "AoE Wind magical, fTP varies"
    },

    ---========================================================================
    --- MERIT/QUEST WEAPONSKILLS
    ---========================================================================

    ['Exenterator'] = {
        description = "4-hit, lowers ACC",
        skill_level = 357,
        job_levels = {
            THF = 90, DNC = 90, RDM = 95, BRD = 95, RNG = 95,
            NIN = 95, COR = 95, WAR = 95, BST = 95
        },
        stat_modifiers = "73~85% AGI (merit ranks)",
        sc_properties = {'Fragmentation', 'Scission'},
        requires_quest = true,
        quest_name = "Martial Mastery",
        requires_merit = true,
        merit_ranks = 5,
        special_weapons = nil,
        element = nil,
        notes = "4 hits, -ACC on target, fTP 1.0/3.0/5.0"
    },

    ---========================================================================
    --- RELIC/MYTHIC/EMPYREAN WEAPONSKILLS
    ---========================================================================

    ['Mercy Stroke'] = {
        description = "Relic WS, +5% crit AM",
        skill_level = nil,
        job_levels = {THF = 75},
        stat_modifiers = "80% STR",
        sc_properties = {'Darkness', 'Gravitation'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = {
            {weapon = "Batardeau", level = 75, type = "Relic", aftermath = true},
            {weapon = "Mandau", level = 75, type = "Relic", aftermath = true},
            {weapon = "Clement Skean", level = 85, type = "Quest"}
        },
        element = nil,
        notes = "Relic AM: +5% crit 20-60s, fTP 3.0"
    },

    ['Rudra\'s Storm'] = {
        description = "Empyrean 5-hit, Weight",
        skill_level = nil,
        job_levels = {THF = 85, BRD = 85, DNC = 85},
        stat_modifiers = "80% DEX",
        sc_properties = {'Darkness', 'Distortion'},
        requires_quest = true,
        quest_name = "Kupofried's Weapon Skill Moogle Magic",
        requires_merit = false,
        special_weapons = {
            {weapon = "Twashtar", level = 85, type = "Empyrean", aftermath = true},
            {weapon = "Eminent Dagger", level = 85, type = "Quest"},
            {weapon = "Atoyac", level = 85, type = "Quest"}
        },
        element = nil,
        notes = "5 hits, Weight 15%, Twashtar AM only"
    },

    ['Mandalic Stab'] = {
        description = "Mythic THF WS, high dmg",
        skill_level = nil,
        job_levels = {THF = 75},
        stat_modifiers = "60% DEX",
        sc_properties = {'Fusion', 'Compression'},
        requires_quest = true,
        quest_name = "Unlocking a Myth (Thief)",
        requires_merit = false,
        special_weapons = {
            {weapon = "Vajra", level = 75, type = "Mythic", bonus = "+30% dmg @99"}
        },
        element = nil,
        notes = "THF only, fTP 1.0/3.0/5.0"
    },

    ['Mordant Rime'] = {
        description = "Mythic BRD WS, Slow",
        skill_level = nil,
        job_levels = {BRD = 75},
        stat_modifiers = "30% DEX / 70% CHR",
        sc_properties = {'Fragmentation', 'Distortion'},
        requires_quest = true,
        quest_name = "Unlocking a Myth (Bard)",
        requires_merit = false,
        special_weapons = {
            {weapon = "Carnwenhan", level = 75, type = "Mythic", bonus = "+30% dmg @99"}
        },
        element = nil,
        notes = "BRD only, 2 hits, Slow 15-40% by TP"
    },

    ['Pyrrhic Kleos'] = {
        description = "Mythic DNC WS, lowers EVA",
        skill_level = nil,
        job_levels = {DNC = 75},
        stat_modifiers = "40% STR / 40% DEX",
        sc_properties = {'Distortion', 'Scission'},
        requires_quest = true,
        quest_name = "Unlocking a Myth (Dancer)",
        requires_merit = false,
        special_weapons = {
            {weapon = "Terpsichore", level = 75, type = "Mythic", bonus = "+30% dmg @99"}
        },
        element = nil,
        notes = "DNC only, 4 hits, -Evasion on target"
    },

    ['Ruthless Stroke'] = {
        description = "Prime WS, multi-SC props",
        skill_level = nil,
        job_levels = {THF = 99, DNC = 99},
        stat_modifiers = "25% DEX / 25% AGI",
        sc_properties = {'Liquefaction', 'Impaction', 'Fragmentation'},
        requires_quest = false,
        requires_merit = false,
        special_weapons = {
            {weapon = "Mpu Gandring", level = 99, type = "Prime", aftermath = "Sortie only"}
        },
        element = nil,
        notes = "Prime AM in Sortie only, 4 hits, fTP varies"
    }
}

return DAGGER_WS

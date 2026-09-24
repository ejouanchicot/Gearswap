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
--- @file shared/data/weaponskills/DAGGER_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Improved formatting
--- @date Created: 2025-10-29
---============================================================================

local dagger_ws = {}

dagger_ws.weaponskills = {
    ---========================================================================
    --- BASIC WEAPONSKILLS (Levels 1-60)
    ---========================================================================

    ['Wasp Sting'] = {
        description         = "Poison, duration varies",
        skill_level         = 5,
        job_levels          = {BLM = 4, BRD = 3, BST = 3, COR = 3, DNC = 1, DRG = 4, DRK = 3, GEO = 3, NIN = 3, PLD = 3, PUP = 3, RDM = 3, RNG = 3, SAM = 4, SMN = 4, THF = 1, WAR = 3, SCH = 2},
        stat_modifiers      = "100% DEX",
        sc_properties       = {'Scission'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = nil,
        notes               = "Poison -1 HP/tick, duration 90-135s by TP"
    },

    ['Gust Slash'] = {
        description         = "Wind elemental damage",
        skill_level         = 40,
        job_levels          = {BLM = 15, BRD = 14, BST = 14, COR = 14, DNC = 14, DRG = 16, DRK = 14, GEO = 14, NIN = 14, PLD = 14, PUP = 14, RDM = 14, RNG = 14, SAM = 16, SMN = 16, THF = 13, WAR = 14},
        stat_modifiers      = "40% DEX / 40% INT",
        sc_properties       = {'Detonation'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = "Wind",
        notes               = "Wind-based magical WS"
    },

    ['Shadowstitch'] = {
        description         = "Bind, chance varies",
        skill_level         = 70,
        job_levels          = {BLM = 26, BRD = 24, BST = 25, COR = 24, DNC = 24, DRG = 28, DRK = 25, GEO = 25, NIN = 25, PLD = 25, PUP = 25, RDM = 24, RNG = 24, SAM = 28, SMN = 28, THF = 23, WAR = 24},
        stat_modifiers      = "100% CHR",
        sc_properties       = {'Reverberation'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = nil,
        notes               = "Bind chance increases with TP"
    },

    ['Viper Bite'] = {
        description         = "Poison, 2x attack",
        skill_level         = 100,
        job_levels          = {BLM = 37, BRD = 34, BST = 35, COR = 34, DNC = 34, DRG = 40, DRK = 35, GEO = 35, NIN = 35, PLD = 35, PUP = 35, RDM = 34, RNG = 34, SAM = 40, SCH = 37, SMN = 40, THF = 33, WAR = 34},
        stat_modifiers      = "100% DEX",
        sc_properties       = {"Scission"},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = nil,
        notes               = "1 hit, attack x2, Poison -3 HP/tick, 90-180s by TP"
    },

    ['Cyclone'] = {
        description         = "AoE Wind damage",
        skill_level         = 125,
        job_levels          = {BLM = 46, BRD = 43, BST = 44, COR = 43, DNC = 43, DRG = 50, DRK = 44, GEO = 44, NIN = 44, PLD = 44, PUP = 44, RDM = 43, RNG = 43, SAM = 50, SCH = 46, SMN = 50, THF = 41, WAR = 43},
        stat_modifiers      = "40% DEX / 40% INT",
        sc_properties       = {"Detonation", "Impaction"},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = "Wind",
        notes               = "AoE Wind magical, damage varies by TP"
    },

    ['Energy Steal'] = {
        description         = "Steals MP",
        skill_level         = 150,
        job_levels          = {BLM = 53, BRD = 51, BST = 52, COR = 51, DNC = 51, DRG = 56, DRK = 52, GEO = 52, NIN = 52, PLD = 52, PUP = 52, RDM = 51, RNG = 51, SAM = 56, SMN = 56, THF = 49, WAR = 51},
        stat_modifiers      = "100% MND",
        sc_properties       = {},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = "Dark",
        notes               = "MP drain varies by TP"
    },

    ['Energy Drain'] = {
        description         = "Steals MP (enhanced)",
        skill_level         = 175,
        job_levels          = {BLM = 59, BRD = 56, BST = 57, COR = 56, DNC = 56, DRG = 63, DRK = 57, GEO = 57, NIN = 57, PLD = 57, PUP = 57, RDM = 56, RNG = 56, SAM = 63, SCH = 59, SMN = 63, THF = 55, WAR = 56},
        stat_modifiers      = "100% MND",
        sc_properties       = {},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = "Dark",
        notes               = "Enhanced MP drain vs Energy Steal"
    },

    ---========================================================================
    --- ADVANCED WEAPONSKILLS (Levels 65-99)
    ---========================================================================

    ['Dancing Edge'] = {
        description         = "5-hit, ACC varies",
        skill_level         = 200,
        job_levels          = {DNC = 62, THF = 60},
        stat_modifiers      = "40% DEX / 40% CHR",
        sc_properties       = {'Scission', 'Detonation'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = nil,
        notes               = "THF/DNC only, 5 hits, ACC bonus by TP"
    },

    ['Shark Bite'] = {
        description         = "2-hit, dmg varies",
        skill_level         = 225,
        job_levels          = {BLM = 99, DNC = 68, GEO = 99, SCH = 99, SMN = 99, THF = 66},
        stat_modifiers      = "40% DEX / 40% AGI",
        sc_properties       = {'Fragmentation'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = nil,
        notes               = "THF/DNC main (BLM/SMN/SCH/GEO via Beryllium Kris), 2 hits, fTP 4.5/6.8/8.5"
    },

    ['Evisceration'] = {
        description         = "5-hit, crit varies",
        skill_level         = 230,
        job_levels          = {BRD = 73, BST = 75, COR = 70, DNC = 70, NIN = 75, PUP = 99, RDM = 71, RNG = 73, THF = 67, WAR = 73},
        stat_modifiers      = "50% DEX",
        sc_properties       = {'Gravitation', 'Transfixion'},
        requires_quest      = true,
        quest_name          = "Cloak and Dagger",
        requires_merit      = false,
        special_weapons     = nil,
        element             = nil,
        notes               = "5 hits, crit rate +10/+25/+50% by TP (2000/3000 unverified), quest required"
    },

    ['Aeolian Edge'] = {
        description         = "AoE Wind, dmg varies",
        skill_level         = 290,
        job_levels          = {BLM = 92, BRD = 85, BST = 86, COR = 82, DNC = 78, DRG = 97, DRK = 87, GEO = 88, NIN = 86, PLD = 88, PUP = 88, RDM = 83, RNG = 85, SAM = 97, SCH = 92, SMN = 97, THF = 78, WAR = 85},
        stat_modifiers      = "40% DEX / 40% INT",
        sc_properties       = {'Scission', 'Detonation', 'Impaction'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = nil,
        element             = "Wind",
        notes               = "AoE Wind magical, fTP varies"
    },

    ---========================================================================
    --- MERIT/QUEST WEAPONSKILLS
    ---========================================================================

    ['Exenterator'] = {
        description         = "4-hit, lowers ACC",
        skill_level         = 357,
        job_levels          = {BRD = 95, BST = 96, COR = 93, DNC = 93, NIN = 96, RDM = 94, RNG = 95, THF = 91, WAR = 95},
        stat_modifiers      = "73~85% AGI (merit ranks)",
        sc_properties       = {'Fragmentation', 'Scission'},
        requires_quest      = true,
        quest_name          = "Martial Mastery",
        requires_merit      = true,
        merit_ranks         = 5,
        special_weapons     = nil,
        element             = nil,
        notes               = "4 hits, Accuracy -20 on target (duration 90/180/270s by TP, 2000/3000 unverified), fTP 1.1875"
    },

    ---========================================================================
    --- RELIC/MYTHIC/EMPYREAN WEAPONSKILLS
    ---========================================================================

    ['Mercy Stroke'] = {
        description         = "Relic WS, +5% crit AM",
        skill_level         = nil,
        job_levels          = {BRD = 75, DNC = 85, RDM = 75, THF = 75},
        stat_modifiers      = "80% STR",
        sc_properties       = {'Darkness', 'Gravitation'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = {
            {weapon = "Batardeau", level = 75, type = "Relic", aftermath = true},
            {weapon = "Mandau", level = 75, type = "Relic", aftermath = true},
            {weapon = "Clement Skean", level = 85, type = "Quest"}
        },
        element             = nil,
        notes               = "Relic AM: +5% crit 20-60s, fTP 5.0"
    },

    ['Rudra\'s Storm'] = {
        description         = "Empyrean, quintuple dmg, Weight",
        skill_level         = nil,
        job_levels          = {THF = 85, BRD = 85, DNC = 85},
        stat_modifiers      = "80% DEX",
        sc_properties       = {'Darkness', 'Distortion'},
        requires_quest      = true,
        quest_name          = "Kupofried's Weapon Skill Moogle Magic",
        requires_merit      = false,
        special_weapons     = {{aftermath = true, level = 85, type = "Empyrean", weapon = "Twashtar"}, {level = 85, type = "Quest", weapon = "Daka"}, {level = 85, type = "Quest", weapon = "Khandroma"}},
        element             = nil,
        notes               = "fTP 5.0/10.19/13, Weight (~-26% move speed, 60s), Twashtar AM only"
    },

    ['Mandalic Stab'] = {
        description         = "Mythic THF WS, high dmg",
        skill_level         = nil,
        job_levels          = {THF = 75},
        stat_modifiers      = "60% DEX",
        sc_properties       = {'Fusion', 'Compression'},
        requires_quest      = true,
        quest_name          = "Unlocking a Myth (Thief)",
        requires_merit      = false,
        special_weapons     = {
            {weapon = "Vajra", level = 75, type = "Mythic", bonus = "+30% dmg @99"}
        },
        element             = nil,
        notes               = "THF only, fTP 4.0/6.09/8.5"
    },

    ['Mordant Rime'] = {
        description         = "Mythic BRD WS, Weight",
        skill_level         = nil,
        job_levels          = {BRD = 75},
        stat_modifiers      = "30% DEX / 70% CHR",
        sc_properties       = {'Fragmentation', 'Distortion'},
        requires_quest      = true,
        quest_name          = "Unlocking a Myth (Bard)",
        requires_merit      = false,
        special_weapons     = {
            {weapon = "Carnwenhan", level = 75, type = "Mythic", bonus = "+30% dmg @99"}
        },
        element             = nil,
        notes               = "BRD only, 2 hits, Weight (~-26% move speed, 60s), chance varies with TP"
    },

    ['Pyrrhic Kleos'] = {
        description         = "Mythic DNC WS, lowers EVA",
        skill_level         = nil,
        job_levels          = {DNC = 75},
        stat_modifiers      = "40% STR / 40% DEX",
        sc_properties       = {'Distortion', 'Scission'},
        requires_quest      = true,
        quest_name          = "Unlocking a Myth (Dancer)",
        requires_merit      = false,
        special_weapons     = {
            {weapon = "Terpsichore", level = 75, type = "Mythic", bonus = "+30% dmg @99"}
        },
        element             = nil,
        notes               = "DNC only, 4 hits, -Evasion on target"
    },

    ['Ruthless Stroke'] = {
        description         = "4-hit, dmg varies",
        skill_level         = 424,
        job_levels          = {RDM = 99, THF = 99, BRD = 99, DNC = 99},
        stat_modifiers      = "25% DEX / 25% AGI",
        sc_properties       = {'Liquefaction', 'Impaction', 'Fragmentation'},
        requires_quest      = false,
        requires_merit      = false,
        special_weapons     = {
            {weapon = "Mpu Gandring", level = 119, type = "Prime", aftermath = true}
        },
        element             = nil,
        notes               = "Prime WS, 4 hits, fTP 5.375/14/23, Mpu Gandring only"
    }
}

return dagger_ws

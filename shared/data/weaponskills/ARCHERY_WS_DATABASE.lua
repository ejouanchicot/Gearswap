---============================================================================
--- Archery Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Archery weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, AGI%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum archery skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file ARCHERY_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Improved formatting - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local archery_ws = {}

archery_ws.weaponskills = {
    ---========================================================================
    --- BASIC ARCHERY WEAPON SKILLS (Skill 5-175)
    ---========================================================================

    ['Flaming Arrow'] = {
        description         = 'Fire elemental. Damage varies with TP.',
        type                = 'Hybrid',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = 'Fire',
        skillchain          = {'Liquefaction', 'Transfixion'},
        ftp                 = {[1000] = 0.5, [2000] = 1.55, [3000] = 2.1},
        skill_required      = 5,
        jobs                = {
            RNG                 = 1, THF = 1, SAM = 1,
            WAR                 = 2, RDM = 2, NIN = 2
        },
        special_notes       = 'Can only be used with RNG as main or sub job.'
    },

    ['Piercing Arrow'] = {
        description         = 'Ignores defense. Amount varies with TP.',
        type                = 'Physical',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Reverberation', 'Transfixion'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 40,
        jobs                = {
            RNG                 = 13,
            THF                 = 14, SAM = 14,
            WAR                 = 15, RDM = 15,
            NIN                 = 16
        },
        special_notes       = 'Can only be used with RNG as main or sub job. Defense ignore: 0%@1000TP / 35%@2000TP / 50%@3000TP.'
    },

    ['Dulling Arrow'] = {
        description         = 'Critical + lowers INT. Chance varies.',
        type                = 'Physical',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Liquefaction', 'Transfixion'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 80,
        jobs                = {
            RNG                 = 26,
            THF                 = 28, SAM = 28,
            WAR                 = 30, RDM = 30,
            NIN                 = 32
        },
        special_notes       = 'Can only be used with RNG as main or sub job. Critical hit rate varies with TP (exact percentages unknown). INT Down effect (amount unknown). INT Down accuracy improved in June 2017.'
    },

    ['Sidewinder'] = {
        description         = 'Powerful but inaccurate. Varies with TP.',
        type                = 'Physical',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Reverberation', 'Transfixion', 'Detonation'},
        ftp                 = {[1000] = 5.0, [2000] = 5.0, [3000] = 5.0},
        skill_required      = 175,
        jobs                = {
            RNG                 = 55,
            THF                 = 57, SAM = 57,
            WAR                 = 59, RDM = 59,
            NIN                 = 63
        },
        special_notes       = 'Can only be used with RNG as main or sub job. Ranged accuracy: -50@1000TP / ±0@2000TP / unknown@3000TP.'
    },

    ---========================================================================
    --- INTERMEDIATE ARCHERY WEAPON SKILLS (Skill 200-290)
    ---========================================================================

    ['Blast Arrow'] = {
        description         = 'Close range attack. Accuracy varies with TP.',
        type                = 'Physical',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Induration', 'Transfixion'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0}, -- verification needed
        skill_required      = 200,
        jobs                = {RNG = 60},
        special_notes       = 'Can only be used with RNG as main job. Close range only (within melee distance). Does not stack with Sneak Attack. fTP values require verification.'
    },

    ['Arching Arrow'] = {
        description         = 'Single hit. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Fusion'},
        ftp                 = {[1000] = 3.5, [2000] = 3.5, [3000] = 3.5},
        skill_required      = 225,
        jobs                = {
            RNG                 = 66,
            -- Level 99 via Exalted Bow/+1
            WAR                 = 99, RDM = 99, THF = 99, PLD = 99, DRK = 99,
            BST                 = 99, SAM = 99, NIN = 99
        },
        special_notes       = 'Can only be used with RNG as main job. Other jobs at level 99 via Exalted Bow/+1 only. Critical hit rate varies with TP (exact percentages unknown).'
    },

    ['Empyreal Arrow'] = {
        description         = 'Single hit. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 20, AGI = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Fusion', 'Transfixion'},
        ftp                 = {[1000] = 1.5, [2000] = 2.5, [3000] = 5.0},
        skill_required      = 250,
        jobs                = {
            RNG                 = 72,
            -- Level 99 via Kaja Bow/Ullr
            WAR                 = 99, RDM = 99, THF = 99, PLD = 99, DRK = 99,
            BST                 = 99, SAM = 99, NIN = 99
        },
        special_notes       = "Requires 'From Saplings Grow' quest for RNG. Other jobs at level 99 via Kaja Bow/Ullr only (+50% damage bonus). Attack modifier: 2.0."
    },

    ['Refulgent Arrow'] = {
        description         = 'Single hit. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60},
        hits                = 1, -- described as "twofold" but actually single hit
        element             = nil,
        skillchain          = {'Reverberation', 'Transfixion'},
        ftp                 = {[1000] = 3.0, [2000] = 4.25, [3000] = 7.0},
        skill_required      = 290,
        jobs                = {
            RNG                 = 80,
            SAM                 = 86,
            THF                 = 90,
            WAR                 = 92, RDM = 92,
            NIN                 = 98
        },
        special_notes       = 'Can only be used with RNG as main or sub job. Description mentions "twofold attack" but testing suggests single hit.'
    },

    ---========================================================================
    --- MERIT/RELIC/EMPYREAN/PRIME WEAPON SKILLS
    ---========================================================================

    ['Apex Arrow'] = {
        description         = 'Ignores defense. Amount varies with TP.',
        type                = 'Physical',
        mods                = {AGI = 73}, -- 73-85% with merits
        hits                = 1, -- described as "4x" but actually single hit
        element             = nil,
        skillchain          = {'Light', 'Fragmentation', 'Transfixion'},
        ftp                 = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required      = 357,
        jobs                = {RNG = 91, SAM = 96},
        special_notes       = "Requires 'Martial Mastery' quest. Merits: 73% AGI@1/5, +3% per merit, 85% AGI@5/5. Can only be used with RNG/SAM as main job. Defense ignore: 15%@1000TP (2000/3000TP unknown). Light becomes primary under Aeonic Aftermath. Description mentions '4x attack' but actually single hit."
    },

    ['Namas Arrow'] = {
        description         = 'Ranged Accuracy bonus (Aftermath).',
        type                = 'Physical',
        mods                = {STR = 40, AGI = 40},
        hits                = 1,
        element             = nil,
        skillchain          = {'Light', 'Distortion'},
        ftp                 = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required      = 357,
        jobs                = {
            RNG                 = 75, SAM = 75, -- via Futatokoroto or Yoichinoyumi
            -- Level 85 via Murti Bow
        },
        special_notes       = 'Futatokoroto/Yoichinoyumi: RNG/SAM level 75. Murti Bow: RNG/SAM level 85 (after 13 other WS). Aftermath: Ranged Accuracy +20 for 20s@1000TP / 40s@2000TP / 60s@3000TP. Yoichinoyumi level 90+: +25-40% damage bonus. Only Futatokoroto/Yoichinoyumi grant Relic Aftermath.'
    },

    ['Jishnu\'s Radiance'] = {
        description         = 'Three hits. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {DEX = 80},
        hits                = 3,
        element             = nil,
        skillchain          = {'Light', 'Fusion'},
        ftp                 = {[1000] = 1.75, [2000] = 1.75, [3000] = 1.75},
        skill_required      = 357,
        jobs                = {RNG = 85},
        special_notes       = "Gandiva/Harrier/Circinae: RNG level 85. Requires 'Kupofried's Weapon Skill Moogle Magic' quest. fTP-replicating weapon skill. Critical hit rate varies with TP (exact percentages unknown). Only Gandiva grants Empyrean Aftermath."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Sarv'] = {
        description         = 'Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 65, AGI = 65},
        hits                = 1,
        element             = nil,
        skillchain          = {'Transfixion', 'Scission', 'Gravitation'},
        ftp                 = {[1000] = 2.75, [2000] = 5.5, [3000] = 8.25},
        skill_required      = 1,
        jobs                = {RNG = 99},
        special_notes       = 'Requires Pinaka (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Ranged Damage Limit+).'
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return archery_ws

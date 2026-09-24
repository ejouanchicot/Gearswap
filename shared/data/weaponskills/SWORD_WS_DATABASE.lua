---============================================================================
--- Sword Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Sword weapon skills in FFXI with:
---   • description - Effect description
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, DEX%, INT%, MND%, etc.)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum sword skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file shared/data/weaponskills/SWORD_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Improved formatting - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local sword_ws = {}

sword_ws.weaponskills = {
    ---========================================================================
    --- BASIC SWORD WEAPON SKILLS (Skill 1-150)
    ---========================================================================

    ['Fast Blade'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 40, DEX = 40},
        hits                = 2,
        element             = nil,
        skillchain          = {'Scission'},
        ftp                 = {[1000] = 1.0, [2000] = 3.0, [3000] = 5.0},
        skill_required      = 5,
        jobs                = {BLU = 1, BRD = 3, BST = 4, COR = 3, DNC = 4, DRG = 3, DRK = 3, NIN = 3, PLD = 1, RDM = 3, RNG = 4, RUN = 3, SAM = 3, THF = 4, WAR = 3}
    },
    ['Burning Blade'] = {
        description         = 'Fire damage. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, INT = 40},
        hits                = 1,
        element             = 'Fire',
        skillchain          = {'Liquefaction'},
        ftp                 = {[1000] = 1.0, [2000] = 2.09, [3000] = 3.39},
        skill_required      = 30,
        jobs                = {BLU = 9, BRD = 10, BST = 12, COR = 10, DNC = 11, DRG = 10, DRK = 10, NIN = 10, PLD = 9, RDM = 10, RNG = 11, RUN = 9, SAM = 10, THF = 11, WAR = 10}
    },
    ['Red Lotus Blade'] = {
        description         = 'Fire damage. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, INT = 40},
        hits                = 1,
        element             = 'Fire',
        skillchain          = {'Liquefaction', 'Detonation'},
        ftp                 = {[1000] = 1.0, [2000] = 2.38, [3000] = 3.75},
        skill_required      = 50,
        jobs                = {BLU = 16, BRD = 18, BST = 20, COR = 17, DNC = 19, DRG = 18, DRK = 17, NIN = 18, PLD = 16, RDM = 17, RNG = 19, RUN = 16, SAM = 18, THF = 19, WAR = 17}
    },
    ['Flat Blade'] = {
        description         = 'Stun. Chance varies with TP.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 75,
        jobs                = {BLU = 24, BRD = 26, BST = 30, COR = 26, DNC = 28, DRG = 26, DRK = 26, NIN = 26, PLD = 24, RDM = 26, RNG = 28, RUN = 24, SAM = 26, THF = 28, WAR = 26},
        special_notes       = 'Stun chance varies with TP'
    },
    ['Shining Blade'] = {
        description         = 'Light damage. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Scission'},
        ftp                 = {[1000] = 1.125, [2000] = 2.22, [3000] = 3.52},
        skill_required      = 100,
        jobs                = {BLU = 33, BRD = 35, BST = 40, COR = 34, DNC = 37, DRG = 35, DRK = 34, NIN = 35, PLD = 33, RDM = 34, RNG = 37, RUN = 33, SAM = 35, THF = 37, WAR = 34}
    },
    ['Seraph Blade'] = {
        description         = 'Light damage. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Scission'},
        ftp                 = {[1000] = 1.125, [2000] = 2.625, [3000] = 4.125},
        skill_required      = 125,
        jobs                = {PLD = 41, BLU = 41, RUN = 41, WAR = 43, RDM = 43, DRK = 43, COR = 43, BRD = 44, SAM = 44, NIN = 44, DRG = 44, THF = 46, RNG = 46, DNC = 46, BST = 50},
        special_notes       = 'Can only be used with WAR/RDM/PLD/DRK/BLU/RUN as main or sub job'
    },
    ['Circle Blade'] = {
        description         = 'AoE attack. Radius varies with TP.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Reverberation', 'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 150,
        jobs                = {PLD = 49, BLU = 49, RUN = 49, WAR = 51, RDM = 51, DRK = 51, COR = 51, BRD = 52, SAM = 52, NIN = 52, DRG = 52, THF = 53, RNG = 53, DNC = 53, BST = 56},
        special_notes       = 'AoE attack. Radius 4.0-5.0 yalms (varies with TP: 2334+ TP = 5.0 yalms)'
    },
    ---========================================================================
    --- INTERMEDIATE SWORD WEAPON SKILLS (Skill 175-300)
    ---========================================================================

    ['Vorpal Blade'] = {
        description         = 'Four hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60},
        hits                = 4,
        element             = nil,
        skillchain          = {'Scission', 'Impaction'},
        ftp                 = {[1000] = 1.375, [2000] = 1.375, [3000] = 1.375},
        skill_required      = 200,
        jobs                = {PLD = 60, BLU = 60, RUN = 60, WAR = 62, RDM = 62, DRK = 62, COR = 62, SAM = 64, BRD = 65, NIN = 65, DRG = 65, THF = 70, RNG = 70, DNC = 70, BST = 75},
        special_notes       = 'Can only be used with WAR/RDM/PLD/DRK/BLU/RUN as main or sub job. fTP-replicating weapon skill. Critical hit rate varies with TP.'
    },
    ['Swift Blade'] = {
        description         = 'Three hits. Accuracy varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50, MND = 50},
        hits                = 3,
        element             = nil,
        skillchain          = {'Gravitation'},
        ftp                 = {[1000] = 1.5, [2000] = 1.5, [3000] = 1.5},
        skill_required      = 225,
        jobs                = {
            PLD                 = 65,
            RUN                 = 66,
            -- Level 99 via Hepatizon Sapara/+1:
            WAR                 = 99,
            THF                 = 99,
            DRK                 = 99,
            SAM                 = 99,
            BLU                 = 99,
            COR                 = 99,
            -- Level 99 via Hepatizon Rapier/+1:
            RDM                 = 99,
            BRD                 = 99,
            DRG                 = 99,
            DNC                 = 99
        },
        special_notes       = 'fTP-replicating weapon skill. Accuracy varies with TP.'
    },
    ['Savage Blade'] = {
        description         = 'Two aerial hits. Varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50, MND = 50},
        hits                = 2,
        element             = nil,
        skillchain          = {'Fragmentation', 'Scission'},
        ftp                 = {[1000] = 4.0, [2000] = 10.25, [3000] = 13.75},
        skill_required      = 240,
        jobs                = {BLU = 68, BRD = 99, BST = 99, COR = 75, DRG = 99, DRK = 75, NIN = 99, PLD = 68, RDM = 73, RNG = 99, RUN = 70, SAM = 99, THF = 99, WAR = 73},
        special_notes       = "Requires 'Old Wounds' quest (bypassed with Kaja Sword or Naegling). Kaja Sword/Naegling: +15% damage bonus."
    },
    ['Sanguine Blade'] = {
        description         = 'Dark damage + HP drain. Varies with TP.',
        type                = 'Magical',
        mods                = {MND = 50, STR = 30},
        hits                = 1,
        element             = 'Dark',
        skillchain          = {},
        ftp                 = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required      = 300,
        jobs                = {PLD = 80, BLU = 80, RUN = 81, WAR = 85, RDM = 85, DRK = 86, COR = 86, SAM = 88, NIN = 89, BRD = 90, DRG = 90, THF = 94, RNG = 94, DNC = 94, BST = 99},
        special_notes       = 'HP drain: 50%@1000TP / 100%@2000TP / 160%@3000TP. Can restore more HP than target\'s remaining HP. Damage dealt to undead is not converted to HP.'
    },
    ---========================================================================
    --- ADVANCED SWORD WEAPON SKILLS (Quest/Merit/Empyrean)
    ---========================================================================

    ['Requiescat'] = {
        description         = 'Five hits. Property-less. MND scaling.',
        type                = 'Physical',
        mods                = {MND = 73}, -- 73-85% with merits
        hits                = 5,
        element             = nil,
        skillchain          = {'Darkness', 'Gravitation', 'Scission'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 357,
        jobs                = {PLD = 90, BLU = 90, RUN = 91, WAR = 94, RDM = 94, DRK = 95, COR = 95, SAM = 96},
        special_notes       = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Property-less damage (uses physical equations but neither Physical nor Magical property). Attack penalty: -20%@1000TP / -10%@2000TP / 0%@3000TP. Merits: +3% MND per merit (2nd-5th)."
    },
    ['Knights of Round'] = {
        description         = 'Regen aftermath (Caliburn/Excalibur).',
        type                = 'Physical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        skillchain          = {'Light', 'Fusion'},
        ftp                 = {[1000] = 5.0, [2000] = 5.0, [3000] = 5.0},
        skill_required      = 300,
        jobs                = {
            RDM                 = 75,
            PLD                 = 75, -- via Caliburn or Excalibur
            BLU                 = 85 -- via Corbenic Sword
        },
        special_notes       = 'Caliburn/Excalibur: PLD+RDM level 75. Corbenic Sword: RDM+PLD+BLU level 85 (requires 13 other WS first). Aftermath (75-119 II): Regen +10HP/tick for 20s@1000TP / 40s@2000TP / 60s@3000TP. Excalibur 119 III: Regen +30HP/tick and Refresh +3MP/tick for 60s/120s/180s. Excalibur level 90+: +25-40% damage bonus.'
    },
    ['Death Blossom'] = {
        description         = 'Three hits. Magic Evasion down.',
        type                = 'Physical',
        mods                = {MND = 50, STR = 30},
        hits                = 3,
        element             = nil,
        skillchain          = {'Fragmentation', 'Distortion'},
        ftp                 = {[1000] = 4.0, [2000] = 4.0, [3000] = 4.0},
        skill_required      = 357,
        jobs                = {RDM = 75},
        special_notes       = 'Requires \'Unlocking a Myth (Red Mage)\' quest. Magic Evasion Down about -10 (60s duration, chance varies with TP). Murgleis: +15% damage@90-95, +30% damage@99/99 II.'
    },
    ['Chant du Cygne'] = {
        description         = 'Three hits. Crit rate increase.',
        type                = 'Physical',
        mods                = {DEX = 80},
        hits                = 3,
        element             = nil,
        skillchain          = {'Light', 'Distortion'},
        ftp                 = {[1000] = 1.6328125, [2000] = 1.6328125, [3000] = 1.6328125},
        skill_required      = 290,
        jobs                = {RDM = 85, PLD = 85, BLU = 85},
        special_notes       = "Requires 'Kupofried's Weapon Skill Moogle Magic' quest. fTP-replicating weapon skill. Critical hit rate: +15%@1000TP / +25%@2000TP / +40%@3000TP. Almace: Empyrean Aftermath."
    },
    ['Expiacion'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 30, DEX = 20, INT = 30},
        hits                = 2,
        element             = nil,
        skillchain          = {'Distortion', 'Scission'},
        ftp                 = {[1000] = 3.796875, [2000] = 9.390625, [3000] = 12.1875},
        skill_required      = 357,
        jobs                = {BLU = 75},
        special_notes       = 'Requires \'Unlocking a Myth (Blue Mage)\' quest. Can only be used with BLU as main job. Tizona: +15% damage@90-95, +30% damage@99/99 II/119 III.'
    },
    ['Uriel Blade'] = {
        description         = 'Light AoE damage + Flash. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 32, MND = 32},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Light', 'Fragmentation', 'Scission'},
        ftp                 = {[1000] = 4.5, [2000] = 6.0, [3000] = 7.5},
        skill_required      = 250,
        jobs                = {WAR = 73, RDM = 73, PLD = 73, DRK = 73, BLU = 73, COR = 73, RUN = 73},
        special_notes       = 'Only usable during Campaign Battles while equipped with Griffinclaw. AoE attack with Flash effect.'
    },
    ---========================================================================
    --- SPECIAL WEAPON SKILLS (Level 99 - All Jobs)
    ---========================================================================

    ['Fast Blade II'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {DEX = 80},
        hits                = 2,
        element             = nil,
        skillchain          = {'Fusion'},
        ftp                 = {[1000] = 1.8, [2000] = 3.5, [3000] = 5.0},
        skill_required      = 1,
        jobs                = {
            -- All jobs at level 99 via Onion Sword III
            WAR                 = 99,
            MNK                 = 99,
            WHM                 = 99,
            BLM                 = 99,
            RDM                 = 99,
            THF                 = 99,
            PLD                 = 99,
            DRK                 = 99,
            BST                 = 99,
            BRD                 = 99,
            RNG                 = 99,
            SAM                 = 99,
            NIN                 = 99,
            DRG                 = 99,
            SMN                 = 99,
            BLU                 = 99,
            COR                 = 99,
            PUP                 = 99,
            DNC                 = 99,
            SCH                 = 99,
            GEO                 = 99,
            RUN                 = 99
        },
        special_notes       = 'Requires Onion Sword III. fTP-replicating weapon skill. Available to all jobs at level 99.'
    },
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return sword_ws

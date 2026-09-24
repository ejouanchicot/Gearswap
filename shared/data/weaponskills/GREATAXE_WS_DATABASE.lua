---============================================================================
--- Great Axe Weapon Skills Database
---============================================================================
--- Complete database of all Great Axe weapon skills for FFXI
--- Source: BG-Wiki (https://www.bg-wiki.com/ffxi/)
--- Verified: 2025-10-30
---
--- @file shared/data/weaponskills/GREATAXE_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Improved formatting
--- @date Created: 2025-10-30
---============================================================================

local greataxe_ws = {}

---============================================================================
--- WEAPON SKILLS DATA
---============================================================================

greataxe_ws.weaponskills = {
    ---========================================================================
    --- BASIC WEAPON SKILLS (Skill 5-225)
    ---========================================================================

    ['Shield Break'] = {
        description         = 'Lowers target evasion.',
        type                = 'Physical',
        mods                = {STR = 60, VIT = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 5,
        jobs                = {WAR = 1, DRK = 3, RUN = 3},
        special_notes       = 'Basic WS. Lowers target evasion.'
    },

    ['Iron Tempest'] = {
        description         = 'Single hit. Attack varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Scission'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 40,
        jobs                = {WAR = 13, DRK = 14, RUN = 14},
        special_notes       = 'Attack bonus varies with TP: +0%@1000TP / +100%@2000TP / +250%@3000TP (unverified).'
    },

    ['Sturmwind'] = {
        description         = 'Two hits. Attack varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60},
        hits                = 2,
        element             = nil,
        skillchain          = {'Reverberation', 'Scission'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 70,
        jobs                = {WAR = 23, DRK = 24, RUN = 24},
        special_notes       = 'WAR/DRK/RUN main or sub job only. Twofold attack. Attack bonus varies with TP: +0%@1000TP / +100%@2000TP / +250%@3000TP (unverified).'
    },

    ['Armor Break'] = {
        description         = 'Lowers target defense.',
        type                = 'Physical',
        mods                = {STR = 60, VIT = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 100,
        jobs                = {WAR = 33, DRK = 34, RUN = 34},
        special_notes       = 'Lowers target defense. Effect duration varies with TP.'
    },

    ['Keen Edge'] = {
        description         = 'Single hit. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Compression'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 150,
        jobs                = {WAR = 49, DRK = 51, RUN = 51},
        special_notes       = 'Critical hit rate varies with TP (exact values unknown).'
    },

    ['Weapon Break'] = {
        description         = 'Lowers target attack.',
        type                = 'Physical',
        mods                = {STR = 60, VIT = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 175,
        jobs                = {WAR = 55, DRK = 56, RUN = 56},
        special_notes       = 'Lowers target attack. Effect duration varies with TP.'
    },

    ['Raging Rush'] = {
        description         = 'Three hits. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50},
        hits                = 3,
        element             = nil,
        skillchain          = {'Induration', 'Reverberation'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 200,
        jobs                = {WAR = 60},
        special_notes       = 'WAR main job only. Critical hit rate: +15%@1000TP / +30%@2000TP / +50%@3000TP (2000/3000 values unverified).'
    },

    ---========================================================================
    --- ADVANCED WEAPON SKILLS (Skill 225+)
    ---========================================================================

    ['Full Break'] = {
        description         = 'Lowers accuracy, attack, defense, evasion.',
        type                = 'Physical',
        mods                = {STR = 50, VIT = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Distortion'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 225,
        jobs                = {
            WAR                 = 65, DRK = 99, RUN = 99
        },
        special_notes       = 'WAR level 65. DRK/RUN level 99 requires Hepatizon Axe. Applies four distinct debuffs. Duration varies with TP: 180s/360s/720s at 1000/2000/3000 TP.'
    },

    ['Steel Cyclone'] = {
        description         = 'Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60, VIT = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Distortion', 'Detonation'},
        ftp                 = {[1000] = 1.5, [2000] = 2.5, [3000] = 4.0},
        skill_required      = 240,
        jobs                = {
            WAR                 = 68, DRK = 75, RUN = 73
        },
        special_notes       = 'Requires "The Weight of Your Limits" quest. Attack modifier: x1.5. High damage scaling at 3000 TP.'
    },

    ['Fell Cleave'] = {
        description         = 'AOE attack. Radius varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Scission', 'Detonation', 'Impaction'},
        ftp                 = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required      = 300,
        jobs                = {
            WAR                 = 80, DRK = 86, RUN = 85
        },
        special_notes       = 'Area of effect. Radius: 4 yalms at 1000-2000 TP, scales to 5 yalms at 2334 TP. WAR/DRK/RUN main job only.'
    },

    ---========================================================================
    --- MERIT WEAPON SKILLS
    ---========================================================================

    ['Upheaval'] = {
        description         = 'Four hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {VIT = 73},  -- 73% base, up to 85% with 5/5 merits
        hits                = 4,
        element             = nil,
        skillchain          = {'Light', 'Fusion', 'Compression'},
        ftp                 = {[1000] = 1.0, [2000] = 3.5, [3000] = 6.5},
        skill_required      = 357,
        jobs                = {
            WAR                 = 90, DRK = 95, RUN = 94
        },
        special_notes       = 'Requires "Martial Mastery" quest. Merit enhancement: +3% VIT per rank (max 85% VIT at 5/5). Light is only available under Aeonic Aftermath. WAR/DRK/RUN main job only.'
    },

    ---========================================================================
    --- RELIC WEAPON SKILLS (Bravura)
    ---========================================================================

    ['Metatron Torment'] = {
        description         = 'Lowers defense. Damage taken aftermath.',
        type                = 'Physical',
        mods                = {STR = 80},
        hits                = 1,
        skillchain          = {'Light', 'Fusion'},
        ftp                 = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required      = 1,
        jobs                = {WAR = 75},
        special_notes       = 'Abaddon Killer/Bravura: WAR level 75. Barbarus Bhuj: WAR level 85. Single hit. Defense Down -18.75% for 2 minutes (wind-based additional effect). Aftermath: -20% Damage Taken (duration: 20s/40s/60s at 1000/2000/3000 TP). Bravura: +25% damage@90-95, +40% damage@99/99 II. Only Abaddon Killer/Bravura grant Relic Aftermath.'
    },

    ---========================================================================
    --- MYTHIC WEAPON SKILLS (Conqueror)
    ---========================================================================

    ['King\'s Justice'] = {
        description         = 'Three hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50},
        hits                = 3,
        element             = nil,
        skillchain          = {'Fragmentation', 'Scission'},
        ftp                 = {[1000] = 1.0, [2000] = 3.0, [3000] = 5.0},
        skill_required      = 1,
        jobs                = {WAR = 75},
        special_notes       = 'Requires "Unlocking a Myth (Warrior)" quest. WAR main job only. Conqueror: Mythic Aftermath, +15% damage@90-95, +30% damage@99/99 II.'
    },

    ---========================================================================
    --- EMPYREAN WEAPON SKILLS (Ukonvasara)
    ---========================================================================

    ['Ukko\'s Fury'] = {
        description         = 'Two hits. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 80},
        hits                = 2,
        element             = nil,
        skillchain          = {'Light', 'Fragmentation'},
        ftp                 = {[1000] = 2.0, [2000] = 2.0, [3000] = 2.0},
        skill_required      = 1,
        jobs                = {WAR = 85},
        special_notes       = 'Ukonvasara/Maschu/Shamash: WAR level 85. WAR main job only. Critical hit rate: +20%/+35%/+65% at 1000/2000/3000 TP (3000 TP value unverified). Inflicts 15% Slow (overwrites Hojo: Ni, overwritten by Slow II). Requires "Kupofried\'s Weapon Skill Moogle Magic" quest. Only Ukonvasara grants Empyrean Aftermath.'
    },

    ---========================================================================
    --- AEONIC WEAPON SKILLS (Dolichenus)
    ---========================================================================

}

---============================================================================
--- MODULE EXPORT
---============================================================================

return greataxe_ws

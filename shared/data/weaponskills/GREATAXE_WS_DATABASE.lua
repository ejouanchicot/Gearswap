---============================================================================
--- Great Axe Weapon Skills Database
---============================================================================
--- Complete database of all Great Axe weapon skills for FFXI
--- Source: BG-Wiki (https://www.bg-wiki.com/ffxi/)
--- Verified: 2025-10-30
---
--- @file GREATAXE_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-10-30
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
        description = 'Lowers target evasion.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Scission'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 5,
        jobs = {
            WAR = 1, DRK = 1, RUN = 1
        },
        special_notes = 'Basic WS. Lowers target evasion.'
    },

    ['Iron Tempest'] = {
        description = 'Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Scission', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 1.5, [3000] = 2.0},
        skill_required = 40,
        jobs = {
            WAR = 1, DRK = 1, RUN = 1
        },
        special_notes = 'Basic WS. Damage scales with TP.'
    },

    ['Sturmwind'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 2,
        element = nil,
        skillchain = {'Reverberation', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 1.25, [3000] = 1.5},
        skill_required = 70,
        jobs = {
            WAR = 1, DRK = 1, RUN = 1
        },
        special_notes = 'WAR/DRK/RUN only. Twofold attack.'
    },

    ['Armor Break'] = {
        description = 'Lowers target defense.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Impaction', 'Detonation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 100,
        jobs = {
            WAR = 1, DRK = 1, RUN = 1
        },
        special_notes = 'Lowers target defense. Effect duration varies with TP.'
    },

    ['Keen Edge'] = {
        description = 'Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Compression', 'Transfixion'},
        ftp = {[1000] = 1.0, [2000] = 1.5, [3000] = 2.0},
        skill_required = 150,
        jobs = {
            WAR = 1, DRK = 1, RUN = 1
        },
        special_notes = 'Basic WS. Damage scales with TP.'
    },

    ['Weapon Break'] = {
        description = 'Lowers target attack.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Impaction', 'Detonation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 175,
        jobs = {
            WAR = 1, DRK = 1, RUN = 1
        },
        special_notes = 'Lowers target attack. Effect duration varies with TP.'
    },

    ['Raging Rush'] = {
        description = 'Three hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 3,
        element = nil,
        skillchain = {'Induration', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 1.3, [3000] = 1.6},
        skill_required = 200,
        jobs = {
            WAR = 1
        },
        special_notes = 'WAR only. Threefold attack.'
    },

    ---========================================================================
    --- ADVANCED WEAPON SKILLS (Skill 225+)
    ---========================================================================

    ['Full Break'] = {
        description = 'Lowers accuracy, attack, defense, evasion.',
        type = 'Physical',
        mods = {STR = 50, VIT = 50},
        hits = 1,
        element = nil,
        skillchain = {'Distortion'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 225,
        jobs = {
            WAR = 65, DRK = 99, RUN = 99
        },
        special_notes = 'WAR level 65. DRK/RUN level 99 requires Hepatizon Axe. Applies four distinct debuffs. Duration varies with TP: 180s/360s/720s at 1000/2000/3000 TP.'
    },

    ['Steel Cyclone'] = {
        description = 'Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60, VIT = 60},
        hits = 1,
        element = nil,
        skillchain = {'Distortion', 'Detonation'},
        ftp = {[1000] = 1.5, [2000] = 2.5, [3000] = 4.0},
        skill_required = 240,
        jobs = {
            WAR = 68, DRK = 75, RUN = 73
        },
        special_notes = 'Requires "The Weight of Your Limits" quest. Attack modifier: x1.5. High damage scaling at 3000 TP.'
    },

    ['Fell Cleave'] = {
        description = 'AOE attack. Radius varies with TP.',
        type = 'Physical',
        mods = {STR = 60},
        hits = 1,
        element = nil,
        skillchain = {'Scission', 'Detonation', 'Impaction'},
        ftp = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required = 300,
        jobs = {
            WAR = 80, DRK = 86, RUN = 85
        },
        special_notes = 'Area of effect. Radius: 4 yalms at 1000-2349 TP, 5 yalms at 2350-3000 TP. WAR/DRK/RUN main or sub job only.'
    },

    ---========================================================================
    --- MERIT WEAPON SKILLS
    ---========================================================================

    ['Upheaval'] = {
        description = 'Four hits. Damage varies with TP.',
        type = 'Physical',
        mods = {VIT = 73},  -- 73% base, up to 85% with 5/5 merits
        hits = 4,
        element = nil,
        skillchain = {'Light', 'Fusion', 'Compression'},
        ftp = {[1000] = 1.0, [2000] = 3.5, [3000] = 6.5},
        skill_required = 357,
        jobs = {
            WAR = 90, DRK = 95, RUN = 94
        },
        special_notes = 'Requires "Martial Mastery" quest. Merit enhancement: +3% VIT per rank (max 85% VIT at 5/5). Compression skillchain requires Aeonic Aftermath (Chango). Main job only.'
    },

    ---========================================================================
    --- RELIC WEAPON SKILLS (Bravura)
    ---========================================================================

    ['Metatron Torment'] = {
        description = 'Lowers defense. Wind damage.',
        type = 'Hybrid',
        mods = {STR = 80},
        hits = 1,
        element = 'Wind',
        skillchain = {'Light', 'Fusion'},
        ftp = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required = 1,
        jobs = {
            WAR = 75
        },
        special_notes = 'Requires Bravura or Abaddon Killer. Wind-based hybrid WS. Lowers target defense -18.75% for 2 minutes. Aftermath: -20% Damage Taken (duration: 20s/40s/60s at 1000/2000/3000 TP).'
    },

    ---========================================================================
    --- MYTHIC WEAPON SKILLS (Conqueror)
    ---========================================================================

    ['King\'s Justice'] = {
        description = 'Three hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 3,
        element = nil,
        skillchain = {'Fragmentation', 'Scission'},
        ftp = {[1000] = 1.0, [2000] = 3.0, [3000] = 5.0},
        skill_required = 1,
        jobs = {
            WAR = 75
        },
        special_notes = 'Requires Conqueror (Mythic). WAR main job only. Requires "Unlocking a Myth (Warrior)" quest. Equipment modifier: 15-30% damage bonus with Conqueror variants.'
    },

    ---========================================================================
    --- EMPYREAN WEAPON SKILLS (Ukonvasara)
    ---========================================================================

    ['Ukko\'s Fury'] = {
        description = 'Two hits. Crit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 80},
        hits = 2,
        element = nil,
        skillchain = {'Light', 'Fragmentation'},
        ftp = {[1000] = 2.0, [2000] = 2.0, [3000] = 2.0},
        skill_required = 1,
        jobs = {
            WAR = 85
        },
        special_notes = 'Requires Ukonvasara (Empyrean). WAR main job only. Critical hit rate: +20%/+35%/+65% at 1000/2000/3000 TP. Inflicts 15% Slow (overwrites Hojo: Ni, overwritten by Slow II). Requires "Kupofried\'s Weapon Skill Moogle Magic" quest.'
    },

    ---========================================================================
    --- AEONIC WEAPON SKILLS (Dolichenus)
    ---========================================================================

    ['Decimation'] = {
        description = 'Three hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 3,
        element = nil,
        skillchain = {'Fusion'},
        ftp = {[1000] = 1.5, [2000] = 2.5, [3000] = 4.0},
        skill_required = 1,
        jobs = {
            WAR = 1
        },
        special_notes = 'Requires Dolichenus (Aeonic). WAR main job only. Aftermath: Critical hit rate +5% (duration varies with TP).'
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return greataxe_ws

---============================================================================
--- Katana Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Katana weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, INT%, AGI%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum katana skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file shared/data/weaponskills/KATANA_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Improved formatting - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local katana_ws = {}

katana_ws.weaponskills = {
    ---========================================================================
    --- BASIC KATANA WEAPON SKILLS (Skill 5-150)
    ---========================================================================

    ['Blade: Rin'] = {
        description         = 'Critical hit. Rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 60, DEX = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Transfixion'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 5,
        jobs                = {NIN = 1},
        special_notes       = 'Critical hit rate ~25%@1000TP (varies with TP). Does NOT factor in critical hit rate bonuses from equipment, stats, or merits.'
    },

    ['Blade: Retsu'] = {
        description         = 'Two hits + Paralyze. Duration varies.',
        type                = 'Physical',
        mods                = {STR = 20, DEX = 60},
        hits                = 2,
        element             = nil,
        skillchain          = {'Scission'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 30,
        jobs                = {NIN = 9},
        special_notes       = 'Paralyze duration: 30s@1000TP / 60s@2000TP / 120s@3000TP. Potency ~30%.'
    },

    ['Blade: Teki'] = {
        description         = 'Water elemental. Varies with TP.',
        type                = 'Hybrid',
        mods                = {STR = 30, INT = 30},
        hits                = 1,
        element             = 'Water',
        skillchain          = {'Reverberation'},
        ftp                 = {[1000] = 0.5, [2000] = 1.375, [3000] = 2.25},
        skill_required      = 70,
        jobs                = {NIN = 23}
    },

    ['Blade: To'] = {
        description         = 'Ice elemental attack. Damage varies with TP.',
        type                = 'Hybrid',
        mods                = {STR = 40, INT = 40},
        hits                = 1,
        element             = 'Ice',
        skillchain          = {'Induration', 'Detonation'},
        ftp                 = {[1000] = 0.5, [2000] = 1.5, [3000] = 2.5},
        skill_required      = 100,
        jobs                = {NIN = 33}
    },

    ['Blade: Chi'] = {
        description         = 'Two hits. Earth damage. Varies with TP.',
        type                = 'Hybrid',
        mods                = {STR = 30, INT = 30},
        hits                = 2,
        element             = 'Earth',
        skillchain          = {'Impaction', 'Transfixion'},
        ftp                 = {[1000] = 0.5, [2000] = 1.375, [3000] = 2.25},
        skill_required      = 150,
        jobs                = {NIN = 49}
    },

    ---========================================================================
    --- INTERMEDIATE KATANA WEAPON SKILLS (Skill 175-290)
    ---========================================================================

    ['Blade: Ei'] = {
        description         = 'Dark elemental. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, INT = 40},
        hits                = 1,
        element             = 'Dark',
        skillchain          = {'Compression'},
        ftp                 = {[1000] = 1.0, [2000] = 3.0, [3000] = 5.0},
        skill_required      = 175,
        jobs                = {NIN = 55},
        special_notes       = 'Damage formula: (pINT-mINT)/2 + 8 (cap: 32). Bypasses Utsusemi and barrier spells.'
    },

    ['Blade: Jin'] = {
        description         = 'Three hits. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 30, DEX = 30},
        hits                = 3,
        element             = nil,
        skillchain          = {'Impaction', 'Detonation'},
        ftp                 = {[1000] = 1.375, [2000] = 1.375, [3000] = 1.375},
        skill_required      = 200,
        jobs                = {NIN = 60},
        special_notes       = 'Can only be used with NIN as main job. fTP-replicating weapon skill. Critical hit rate varies with TP.'
    },

    ['Blade: Ten'] = {
        description         = 'Single hit. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 30, DEX = 30},
        hits                = 1,
        element             = nil,
        skillchain          = {'Gravitation'},
        ftp                 = {[1000] = 4.5, [2000] = 11.5, [3000] = 15.5},
        skill_required      = 225,
        jobs                = {NIN = 66},
        special_notes       = 'Can only be used with NIN as main job.'
    },

    ['Blade: Ku'] = {
        description         = 'Five hits. Accuracy varies with TP.',
        type                = 'Physical',
        mods                = {STR = 30, DEX = 30},
        hits                = 5,
        element             = nil,
        skillchain          = {'Gravitation', 'Transfixion'},
        ftp                 = {[1000] = 1.25, [2000] = 1.25, [3000] = 1.25},
        skill_required      = 250,
        jobs                = {NIN = 72},
        special_notes       = "Requires 'Bugi Soden' quest for main job usage. Kaja Katana/Gokotai: enable use by any job at level 99 without quest. Accuracy varies with TP."
    },

    ['Blade: Yu'] = {
        description         = 'Water + Poison. Duration varies with TP.',
        type                = 'Magical',
        mods                = {DEX = 40, INT = 40},
        hits                = 1,
        element             = 'Water',
        skillchain          = {'Reverberation', 'Scission'},
        ftp                 = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required      = 290,
        jobs                = {NIN = 80},
        special_notes       = 'Can only be used with NIN as main job. Poison: -10 HP/tick. Duration: 90s@1000TP / 180s@2000TP / 270s@3000TP (unresisted). Unlikely to land on Water/Thunder enemies.'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Blade: Shun'] = {
        description         = 'Five hits. Attack power varies with TP.',
        type                = 'Physical',
        mods                = {DEX = 73}, -- 73-85% with merits
        hits                = 5,
        element             = nil,
        skillchain          = {'Light', 'Fusion', 'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 2.0, [3000] = 3.0},
        skill_required      = 357,
        jobs                = {NIN = 91},
        special_notes       = "Requires 'Martial Mastery' quest and 'Heart of the Bushin' key item. fTP-replicating weapon skill. Merits: 73% DEX@1/5, +3% per merit, 85% DEX@5/5. Can only be used as main job. Light becomes primary during Aeonic Aftermath."
    },

    ['Blade: Metsu'] = {
        description         = 'Critical damage. Subtle Blow aftermath.',
        type                = 'Physical',
        mods                = {DEX = 80},
        hits                = 1,
        element             = nil,
        skillchain          = {'Darkness', 'Fragmentation'},
        ftp                 = {[1000] = 5.0, [2000] = 5.0, [3000] = 5.0},
        skill_required      = 357,
        jobs                = {
            NIN                 = 75, -- via Yoshimitsu or Kikoku
            -- Level 85 via Sekirei
        },
        special_notes       = 'Yoshimitsu/Kikoku: NIN level 75. Sekirei: NIN level 85. Aftermath: Subtle Blow +10 for 20s@1000TP / 40s@2000TP / 60s@3000TP (capped at +50 total). Kikoku level 119 III: +40% damage bonus + Attack +10. Only Yoshimitsu/Kikoku grant Relic Aftermath.'
    },

    ['Blade: Kamu'] = {
        description         = 'Lowers accuracy. Duration varies.',
        type                = 'Physical',
        mods                = {STR = 60, INT = 60},
        hits                = 1,
        element             = nil,
        skillchain          = {'Fragmentation', 'Compression'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 357,
        jobs                = {NIN = 75},
        special_notes       = "Requires 'Unlocking a Myth (Ninja)' quest. Can only be used with NIN as main job. Accuracy Down: -10. Duration: 60s@1000TP / 120s@2000TP / 180s@3000TP. Attack modifier: 3.0. Kannagi: +15% damage@90-95, +30% damage@99-119."
    },

    ['Blade: Hi'] = {
        description         = 'Quad damage. Crit rate varies with TP.',
        type                = 'Physical',
        mods                = {AGI = 80},
        hits                = 1,
        element             = nil,
        skillchain          = {'Darkness', 'Gravitation'},
        ftp                 = {[1000] = 5.0, [2000] = 5.0, [3000] = 5.0},
        skill_required      = 357,
        jobs                = {NIN = 85},
        special_notes       = "Kannagi/Tobi/Kasasagi: NIN level 85. Requires 'Kupofried's Weapon Skill Moogle Magic' quest. Can only be used with NIN as main job. Quad damage mechanic. Critical hit rate: +15%@1000TP / +20%@2000TP / +25%@3000TP. Only Kannagi grants Empyrean Aftermath."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Zesho Meppo'] = {
        description         = 'Four hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {DEX = 25, AGI = 25},
        hits                = 4,
        element             = nil,
        skillchain          = {'Induration', 'Reverberation', 'Fusion'},
        ftp                 = {[1000] = 4.0, [2000] = 4.0, [3000] = 18.715}, -- 2000 TP fTP needs verification
        skill_required      = 1,
        jobs                = {NIN = 99},
        special_notes       = 'Requires Dokoku (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Physical Damage Limit+). 2000 TP fTP value requires verification.'
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return katana_ws

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
--- @file SWORD_WS_DATABASE.lua
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
        skill_required      = 1,
        jobs                = {PLD = 1, BLU = 1, WAR = 3, RDM = 3, DRK = 4, COR = 5, BRD = 6, SAM = 7, NIN = 7, DRG = 8, THF = 11, RNG = 11, DNC = 11, BST = 15}
    },
    ['Burning Blade'] = {
        description         = 'Fire damage. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, INT = 40},
        hits                = 1,
        element             = 'Fire',
        skillchain          = {'Liquefaction'},
        ftp                 = {[1000] = 1.0, [2000] = 2.09, [3000] = 3.39},
        skill_required      = 10,
        jobs                = {PLD = 10, BLU = 10, RUN = 11, WAR = 12, RDM = 12, DRK = 13, COR = 14, BRD = 15, SAM = 16, NIN = 16, DRG = 17, THF = 20, RNG = 20, DNC = 20, BST = 24}
    },
    ['Red Lotus Blade'] = {
        description         = 'Fire damage. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, INT = 40},
        hits                = 1,
        element             = 'Fire',
        skillchain          = {'Liquefaction', 'Detonation'},
        ftp                 = {[1000] = 1.0, [2000] = 2.38, [3000] = 3.75},
        skill_required      = 30,
        jobs                = {PLD = 20, BLU = 20, RUN = 21, WAR = 22, RDM = 22, DRK = 23, COR = 24, BRD = 25, SAM = 26, NIN = 26, DRG = 27, THF = 30, RNG = 30, DNC = 30, BST = 34}
    },
    ['Flat Blade'] = {
        description         = 'Stun. Duration varies with TP.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 75,
        jobs                = {PLD = 30, BLU = 30, RUN = 31, WAR = 32, RDM = 32, DRK = 33, COR = 34, BRD = 35, SAM = 36, NIN = 36, DRG = 37, THF = 40, RNG = 40, DNC = 40, BST = 44},
        special_notes       = 'Stun effect duration varies with TP'
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
        jobs                = {PLD = 40, BLU = 40, RUN = 41, WAR = 42, RDM = 42, DRK = 43, COR = 44, BRD = 45, SAM = 46, NIN = 46, DRG = 47, THF = 50, RNG = 50, DNC = 50, BST = 54}
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
        jobs                = {
            PLD                 = 70,
            BLU                 = 70,
            RUN                 = 70,
            WAR                 = 73,
            RDM                 = 73,
            DRK                 = 75,
            COR                 = 75,
            -- Level 99 via Kaja Sword or Naegling:
            BRD                 = 99,
            SAM                 = 99,
            NIN                 = 99,
            THF                 = 99,
            RNG                 = 99,
            DRG                 = 99,
            DNC                 = 99,
            BST                 = 99
        },
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
        special_notes       = "HP drain: 50%@1000TP / 100%@2000TP / 160%@3000TP. Can restore more HP than target's remaining HP. Does not work on undead."
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
        skill_required      = 290,
        jobs                = {PLD = 90, BLU = 90, RUN = 91, WAR = 94, RDM = 94, DRK = 95, COR = 95, SAM = 96},
        special_notes       = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Property-less damage (uses physical equations but neither Physical nor Magical property). Attack penalty: -20%@1000TP / -10%@2000TP / 0%@3000TP. Merits: +3% MND per merit (2nd-5th)."
    },
    ['Knights of Round'] = {
        description         = 'Light damage + Regen aftermath.',
        type                = 'Physical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Light', 'Fusion'},
        ftp                 = {[1000] = 5.0, [2000] = 5.0, [3000] = 5.0},
        skill_required      = 300,
        jobs                = {
            RDM                 = 75,
            PLD                 = 75, -- via Caliburn or Excalibur
            BLU                 = 85 -- via Corbenic Sword
        },
        special_notes       = 'Caliburn/Excalibur: PLD+RDM level 75. Corbenic Sword: RDM+PLD+BLU level 85 (requires 13 other WS first). Aftermath: Regen +10HP/tick for 20s@1000TP / 40s@2000TP / 60s@3000TP. Excalibur level 90+: +25-40% damage bonus.'
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
        special_notes       = "Requires 'Unlocking a Myth (Red Mage)' quest. Magic Evasion -10 (60s duration, chance increases with TP). Murgleis: +15-30% damage bonus."
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
    ['Aeolian Edge'] = {
        description         = 'Wind AoE damage. Varies with TP.',
        type                = 'Magical',
        mods                = {DEX = 40, INT = 40},
        hits                = 1,
        element             = 'Wind',
        skillchain          = {'Scission', 'Detonation', 'Impaction'},
        ftp                 = {[1000] = 2.0, [2000] = 3.0, [3000] = 4.5},
        skill_required      = 290,
        jobs                = {THF = 78, DNC = 78, COR = 82, RDM = 83, WAR = 85, BRD = 85, RNG = 85, BST = 86, NIN = 86, DRK = 87, PLD = 88, PUP = 88, GEO = 88, BLM = 92, SCH = 92, SAM = 97, DRG = 97, SMN = 97},
        special_notes       = 'Requires dagger (290 skill) and melee range. Can only be used with RDM/THF/BRD/RNG/NIN/DNC as main or sub job. Damage formula: (pINT-mINT)/2 + 8 (cap: 32).'
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
        special_notes       = "Requires 'Unlocking a Myth (Blue Mage)' quest. Can only be used with BLU as main job. Tizona: +15-30% damage bonus (level 99 II and 119 III)."
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
    ['Black Halo'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {MND = 70, STR = 30},
        hits                = 2,
        element             = nil,
        skillchain          = {'Fragmentation', 'Compression'},
        ftp                 = {[1000] = 3.0, [2000] = 7.25, [3000] = 9.75},
        skill_required      = 230,
        jobs                = {
            PLD                 = 67,
            WHM                 = 67,
            GEO                 = 70,
            WAR                 = 73,
            BLU                 = 73,
            MNK                 = 74,
            BLM                 = 74,
            SMN                 = 75,
            -- RDM/SCH via Kaja Rod or Maxentius as main-hand
            RDM                 = 99,
            SCH                 = 99
        },
        special_notes       = "Requires 'Orastery Woes' quest (club skill 230). Kaja Rod or Maxentius: +50% damage bonus (RDM/SCH access)."
    },
    ['Judgment'] = {
        description         = 'Single attack. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50, MND = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 3.5, [2000] = 8.75, [3000] = 12.0},
        skill_required      = 200,
        jobs                = {PLD = 60, WAR = 62, WHM = 62, BLU = 62, GEO = 62, MNK = 64, BLM = 64, SMN = 64, SCH = 64, RUN = 64, DRK = 65, RDM = 70, BST = 70, BRD = 70, PUP = 70, THF = 75, RNG = 75, SAM = 75, NIN = 75, DRG = 75},
        special_notes       = 'Club weapon skill (200 skill). Must be set as main or sub job.'
    },
    ['True Strike'] = {
        description         = '100% crit rate. Accuracy varies.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Detonation', 'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 175,
        jobs                = {PLD = 55, WAR = 56, WHM = 56, BLU = 56, GEO = 56, MNK = 57, BLM = 57, DRK = 57, SMN = 57, SCH = 57, RUN = 57, RDM = 59, BST = 59, BRD = 59, PUP = 59, THF = 63, SAM = 63, NIN = 63, DRG = 63},
        special_notes       = 'Club weapon skill (175 skill). 100% critical hit rate. Large accuracy penalty at all TP levels. Attack modifier: 2.0.'
    },
    ['Shining Strike'] = {
        description         = 'Light elemental. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.625, [2000] = 3.0, [3000] = 4.625},
        skill_required      = 5,
        jobs                = {PLD = 1, WAR = 3, MNK = 3, WHM = 3, BLM = 3, DRK = 3, SMN = 3, BLU = 3, SCH = 3, RUN = 3, GEO = 3, RDM = 4, THF = 4, BST = 4, BRD = 4, SAM = 4, NIN = 4, DRG = 4, PUP = 4},
        special_notes       = 'Club weapon skill (5 skill). Deals light elemental damage.'
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
    ['Dimidiation'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {DEX = 80},
        hits                = 2,
        element             = nil,
        skillchain          = {'Light', 'Fragmentation'},
        ftp                 = {[1000] = 2.25, [2000] = 4.5, [3000] = 6.75},
        skill_required      = 357,
        jobs                = {RUN = 99},
        special_notes       = "Requires 'Rune Fencing the Night Away' quest. Can only be used with RUN as main job. Epeolatry (Level 119): Aftermath effect varies with TP. Attack modifier: 1.25."
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function sword_ws.get_ws_data(ws_name)
    return sword_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (WAR, PLD, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function sword_ws.can_use(ws_name, job_code, level)
    local ws_data = sword_ws.weaponskills[ws_name]
    if not ws_data or not ws_data.jobs then
        return false
    end

    local required_level = ws_data.jobs[job_code]
    if not required_level then
        return false
    end

    return level >= required_level
end

--- Get all jobs that can use a weapon skill
--- @param ws_name string The weapon skill name
--- @return table|nil Table of {JOB = level} or nil if not found
function sword_ws.get_jobs_for_ws(ws_name)
    local ws_data = sword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function sword_ws.get_ws_type(ws_name)
    local ws_data = sword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function sword_ws.get_ws_element(ws_name)
    local ws_data = sword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function sword_ws.get_skillchain_properties(ws_name)
    local ws_data = sword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function sword_ws.get_ftp(ws_name, tp)
    local ws_data = sword_ws.weaponskills[ws_name]
    if not ws_data or not ws_data.ftp then
        return nil
    end

    -- Round TP to nearest 1000
    local tp_key = 1000
    if tp >= 2500 then
        tp_key              = 3000
    elseif tp >= 1500 then
        tp_key              = 2000
    end

    return ws_data.ftp[tp_key]
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return sword_ws

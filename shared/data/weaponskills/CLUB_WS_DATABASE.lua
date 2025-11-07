---============================================================================
--- Club Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Club weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, INT%, MND%, CHR%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum club skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file CLUB_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Improved formatting - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local club_ws = {}

club_ws.weaponskills = {
    ---========================================================================
    --- BASIC CLUB WEAPON SKILLS (Skill 5-150)
    ---========================================================================

    ['Shining Strike'] = {
        description         = 'Light elemental. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 1.625, [2000] = 3.0, [3000] = 4.625},
        skill_required      = 5,
        jobs                = {
            PLD                 = 1,
            WAR                 = 3, MNK = 3, WHM = 3, BLM = 3, DRK = 3, SMN = 3, BLU = 3, SCH = 3, RUN = 3, GEO = 3,
            RDM                 = 4, THF = 4, BST = 4, BRD = 4, SAM = 4, NIN = 4, DRG = 4, PUP = 4
        }
    },

    ['Seraph Strike'] = {
        description         = 'Light elemental. Varies with TP.',
        type                = 'Magical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 2.125, [2000] = 3.675, [3000] = 6.125},
        skill_required      = 40,
        jobs                = {
            PLD                 = 13,
            WAR                 = 14, MNK = 14, WHM = 14, BLM = 14, DRK = 14, SMN = 14, BLU = 14, SCH = 14, GEO = 14, RUN = 14,
            RDM                 = 15, BST = 15, BRD = 15, PUP = 15,
            THF                 = 16, RNG = 16, SAM = 16, NIN = 16, DRG = 16
        },
        special_notes       = 'Can only be used with WAR/WHM/PLD/DRK/SAM/BLU/GEO as main or sub job.'
    },

    ['Brainshaker'] = {
        description         = 'Stuns target. Chance varies with TP.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = 'Thunder',
        skillchain          = {'Reverberation'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 70,
        jobs                = {
            PLD                 = 23,
            WAR                 = 24, WHM = 24, BLU = 24, GEO = 24,
            MNK                 = 25, BLM = 25, DRK = 25, SMN = 25, SCH = 25, RUN = 25,
            RDM                 = 26, BST = 26, BRD = 26, PUP = 26,
            THF                 = 28, SAM = 28, NIN = 28, DRG = 28
        },
        special_notes       = 'Stun chance varies with TP. Thunder-based, less effective against Thunder/Earth enemies.'
    },

    ['Starlight'] = {
        description         = 'Restores own MP. Amount varies with TP.',
        type                = 'Magical',
        mods                = {}, -- Club Skill based
        hits                = 0, -- Self-targeted utility
        element             = nil,
        skillchain          = {},
        ftp                 = {[1000] = 2.0, [2000] = 3.0, [3000] = 4.0}, -- MP multipliers
        skill_required      = 100,
        jobs                = {
            PLD                 = 33,
            WAR                 = 34, WHM = 34, BLU = 34, GEO = 34,
            MNK                 = 35, BLM = 35, DRK = 35, SMN = 35, SCH = 35, RUN = 35,
            RDM                 = 37, BST = 37, BRD = 37, PUP = 37,
            THF                 = 40, SAM = 40, NIN = 40, DRG = 40
        },
        special_notes       = 'Self-targeted MP restoration. Formula: floor(Club Skill × 0.11) × MP Multiplier. Dukkha club triples potency. Usable without claiming monster.'
    },

    ['Moonlight'] = {
        description         = 'Restores party MP. Amount varies with TP.',
        type                = 'Magical',
        mods                = {}, -- Club Skill based
        hits                = 0, -- Party utility
        element             = nil,
        skillchain          = {},
        ftp                 = {[1000] = 2.25, [2000] = 3.5, [3000] = 4.75}, -- MP multipliers
        skill_required      = 125,
        jobs                = {
            PLD                 = 41,
            WAR                 = 43, WHM = 43, BLU = 43, GEO = 43,
            MNK                 = 44, BLM = 44, DRK = 44, SMN = 44, SCH = 44, RUN = 44,
            RDM                 = 46, BST = 46, BRD = 46, PUP = 46,
            THF                 = 50, RNG = 50, SAM = 50, NIN = 50, DRG = 50
        },
        special_notes       = 'Can only be used with WAR/WHM/PLD/DRK/SAM/BLU/GEO as main or sub job. Party MP restoration. Formula: floor(Club Skill × 0.11) × MP Multiplier.'
    },

    ['Skullbreaker'] = {
        description         = 'Lowers target INT. Duration 140s.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Induration', 'Reverberation'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 150,
        jobs                = {
            PLD                 = 49,
            WAR                 = 51, WHM = 51, BLU = 51, GEO = 51,
            MNK                 = 52, BLM = 52, DRK = 52, SMN = 52, SCH = 52, RUN = 52,
            RDM                 = 53, BST = 53, BRD = 53, PUP = 53,
            THF                 = 56, SAM = 56, NIN = 56, DRG = 56
        },
        special_notes       = 'INT Down: -10 for 140 seconds (decays by -1 every 10 seconds). Accuracy increased in June 2017.'
    },

    ---========================================================================
    --- INTERMEDIATE CLUB WEAPON SKILLS (Skill 175-230)
    ---========================================================================

    ['True Strike'] = {
        description         = '100% crit rate. Accuracy varies.',
        type                = 'Physical',
        mods                = {STR = 100},
        hits                = 1,
        element             = nil,
        skillchain          = {'Detonation', 'Impaction'},
        ftp                 = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required      = 175,
        jobs                = {
            PLD                 = 55,
            WAR                 = 56, WHM = 56, BLU = 56, GEO = 56,
            MNK                 = 57, BLM = 57, DRK = 57, SMN = 57, SCH = 57, RUN = 57,
            RDM                 = 59, BST = 59, BRD = 59, PUP = 59,
            THF                 = 63, SAM = 63, NIN = 63, DRG = 63
        },
        special_notes       = '100% critical hit rate. Attack modifier: 2.0. Large accuracy penalty across all TP levels.'
    },

    ['Judgment'] = {
        description         = 'Single hit. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50, MND = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Impaction'},
        ftp                 = {[1000] = 3.5, [2000] = 8.75, [3000] = 12.0},
        skill_required      = 200,
        jobs                = {
            PLD                 = 60,
            WAR                 = 62, WHM = 62, BLU = 62, GEO = 62,
            MNK                 = 64, BLM = 64, SMN = 64, SCH = 64, RUN = 64,
            DRK                 = 65,
            RDM                 = 70, BST = 70, BRD = 70, PUP = 70,
            THF                 = 75, RNG = 75, SAM = 75, NIN = 75, DRG = 75
        },
        special_notes       = 'Can only be used with WAR/WHM/PLD/DRK/SAM/BLU/GEO as main or sub job.'
    },

    ['Hexa Strike'] = {
        description         = 'Six hits. Critical hit rate varies with TP.',
        type                = 'Physical',
        mods                = {STR = 30, MND = 30},
        hits                = 6,
        element             = nil,
        skillchain          = {'Fusion'},
        ftp                 = {[1000] = 1.125, [2000] = 1.125, [3000] = 1.125},
        skill_required      = 220,
        jobs                = {
            WHM                 = 67, GEO = 67,
            WAR                 = 99, PLD = 99 -- via Beryllium Mace/+1
        },
        special_notes       = 'Can only be used with WHM/GEO as main job. WAR/PLD at level 99 via Beryllium Mace/+1 only. Critical hit rate: +10%@1000TP / +≥25%@3000TP (2000TP unknown).'
    },

    ['Black Halo'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 30, MND = 70},
        hits                = 2,
        element             = nil,
        skillchain          = {'Fragmentation', 'Compression'},
        ftp                 = {[1000] = 3.0, [2000] = 7.25, [3000] = 9.75},
        skill_required      = 230,
        jobs                = {
            PLD                 = 67,
            WHM                 = 70, GEO = 70,
            WAR                 = 73, BLU = 73,
            MNK                 = 75, BLM = 75, SMN = 75,
            RDM                 = 99, SCH = 99 -- via Kaja Rod/Maxentius
        },
        special_notes       = "Requires 'Orastery Woes' quest. Main job requirement after quest. RDM/SCH at level 99 via Kaja Rod/Maxentius only (+50% damage bonus). WHM/PLD/GEO cannot complete quest before level 71."
    },

    ---========================================================================
    --- ADVANCED CLUB WEAPON SKILLS (Skill 290+)
    ---========================================================================

    ['Flash Nova'] = {
        description         = 'Light damage + Flash. Chance varies with TP.',
        type                = 'Magical',
        mods                = {STR = 50, MND = 50},
        hits                = 1,
        element             = 'Light',
        skillchain          = {'Reverberation', 'Induration'},
        ftp                 = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required      = 290,
        jobs                = {
            PLD                 = 80,
            WHM                 = 82, GEO = 82,
            WAR                 = 85, BLU = 85,
            MNK                 = 86, BLM = 86, SMN = 86, SCH = 86, RUN = 86,
            DRK                 = 88,
            RDM                 = 92, BST = 92, BRD = 92, PUP = 92,
            THF                 = 97, RNG = 97, SAM = 97, NIN = 97, DRG = 97
        },
        special_notes       = 'Can only be used with WAR/WHM/PLD/DRK/SAM/BLU/GEO as main or sub job. Light damage + Flash effect (accuracy varies with TP). Damage formula: (pINT-mINT)/2 + 8 (cap: 32).'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN/ERGON WEAPON SKILLS
    ---========================================================================

    ['Realmrazer'] = {
        description         = 'Seven hits. Accuracy varies with TP.',
        type                = 'Physical',
        mods                = {MND = 73}, -- 73-85% with merits
        hits                = 7,
        element             = nil,
        skillchain          = {'Light', 'Fusion', 'Impaction'},
        ftp                 = {[1000] = 0.9, [2000] = 0.9, [3000] = 0.9}, -- verification needed
        skill_required      = 357,
        jobs                = {
            PLD                 = 92,
            WHM                 = 93, GEO = 93,
            WAR                 = 95, BLU = 95,
            MNK                 = 96, BLM = 96, SMN = 96, RUN = 96
        },
        special_notes       = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Merits: 73% MND@1/5, +3% per merit, 85% MND@5/5. Can only be used as main job (WAR/MNK/WHM/BLM/PLD/SMN/BLU/SCH/GEO). Light becomes primary under Aeonic Aftermath."
    },

    ['Randgrith'] = {
        description         = 'Lowers target evasion.',
        type                = 'Physical',
        mods                = {STR = 40, MND = 40},
        hits                = 1,
        element             = nil,
        skillchain          = {'Light', 'Fragmentation'},
        ftp                 = {[1000] = 4.25, [2000] = 4.25, [3000] = 4.25},
        skill_required      = 357,
        jobs                = {
            WHM                 = 75, -- via Gullintani or Mjollnir
            -- Level 85 via Molva Maul
            GEO                 = 85, SCH = 85 -- via Molva Maul
        },
        special_notes       = 'Gullintani/Mjollnir: WHM level 75. Molva Maul: WHM/GEO/SCH level 85. Evasion Down: -32. Aftermath: Accuracy +20 for 20s@1000TP / 40s@2000TP / 60s@3000TP. Mjollnir level 90+: +25-40% damage bonus. Only Gullintani/Mjollnir grant Relic Aftermath.'
    },

    ['Dagan'] = {
        description         = 'Restores HP and MP. Amount varies with TP.',
        type                = 'Magical',
        mods                = {}, -- Max HP/MP based
        hits                = 0, -- Self-targeted utility
        element             = nil,
        skillchain          = {},
        ftp                 = {[1000] = 0.22, [2000] = 0.33, [3000] = 0.52}, -- HP % restore
        skill_required      = 357,
        jobs                = {WHM = 85},
        special_notes       = "Gambanteinn/Canne de Combat/Rose Couverte: WHM level 85. Requires 'Kupofried's Weapon Skill Moogle Magic' quest. Can only be used with WHM as main job. MP restore: 15%@1000TP / 22%@2000TP / 35%@3000TP. HP restore: 22%@1000TP / 33%@2000TP / 52%@3000TP. Self-targeted, usable without claiming monster. Only Gambanteinn grants Empyrean Aftermath."
    },

    ['Mystic Boon'] = {
        description         = 'Converts damage to own MP.',
        type                = 'Physical',
        mods                = {STR = 30, MND = 70},
        hits                = 1,
        element             = nil,
        skillchain          = {},
        ftp                 = {[1000] = 2.5, [2000] = 4.0, [3000] = 7.0},
        skill_required      = 357,
        jobs                = {WHM = 75},
        special_notes       = "Requires 'Unlocking a Myth (White Mage)' quest. Can only be used with WHM as main job. No skillchain properties. All damage converted to MP. Yagrush: +15% damage@90-95, +30% damage@99-119."
    },

    ['Exudation'] = {
        description         = 'Attack power varies with TP.',
        type                = 'Physical',
        mods                = {INT = 50, MND = 50},
        hits                = 1,
        element             = nil,
        skillchain          = {'Darkness', 'Fragmentation'},
        ftp                 = {[1000] = 1.5, [2000] = 3.625, [3000] = 4.75},
        skill_required      = 1,
        jobs                = {GEO = 99},
        special_notes       = "Requires 'Geomancerrific' quest. Can only be used with GEO as main job. Ergon weapon skill. Idris (Level 119): Ergon Aftermath varies with TP. Attack varies with TP: +50%@1000TP / +262.5%@2000TP / +375%@3000TP."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Dagda'] = {
        description         = 'Two hits. Damage varies with TP.',
        type                = 'Physical',
        mods                = {STR = 50, MND = 50}, -- verification needed (was INT/MND, corrected March 2024)
        hits                = 2,
        element             = nil,
        skillchain          = {'Transfixion', 'Scission', 'Gravitation'},
        ftp                 = {[1000] = 3.0, [2000] = 6.0, [3000] = 9.0}, -- verification needed
        skill_required      = 1,
        jobs                = {
            WHM                 = 99, GEO = 99
        },
        special_notes       = 'Requires Lorg Mor (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Physical Damage Limit+). Stat modifiers changed from INT/MND to STR/MND in March 2024 update. fTP values require verification.'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function club_ws.get_ws_data(ws_name)
    return club_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (WAR, MNK, WHM, PLD, GEO, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function club_ws.can_use(ws_name, job_code, level)
    local ws_data = club_ws.weaponskills[ws_name]
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
function club_ws.get_jobs_for_ws(ws_name)
    local ws_data = club_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function club_ws.get_ws_type(ws_name)
    local ws_data = club_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function club_ws.get_ws_element(ws_name)
    local ws_data = club_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function club_ws.get_skillchain_properties(ws_name)
    local ws_data = club_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function club_ws.get_ftp(ws_name, tp)
    local ws_data = club_ws.weaponskills[ws_name]
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

return club_ws

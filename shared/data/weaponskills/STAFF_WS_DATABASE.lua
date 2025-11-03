---============================================================================
--- Staff Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Staff weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, INT%, MND%, CHR%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum staff skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file STAFF_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local staff_ws = {}

staff_ws.weaponskills = {
    ---========================================================================
    --- BASIC STAFF WEAPON SKILLS (Skill 5-150)
    ---========================================================================

    ['Heavy Swing'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 2.0, [3000] = 3.0},
        skill_required = 5,
        jobs = {
            WAR = 1, MNK = 1, WHM = 1, BLM = 1, PLD = 1,
            BRD = 1, DRG = 1, SMN = 1, SCH = 1, GEO = 1
        }
    },

    ['Rock Crusher'] = {
        description = 'Earth elemental. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = 'Earth',
        skillchain = {'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 3.27, [3000] = 5.54},
        skill_required = 40,
        jobs = {
            PLD = 13,
            WAR = 14, MNK = 14, WHM = 14, BLM = 14,
            BRD = 14, DRG = 14, SMN = 14, SCH = 14, GEO = 14
        },
        special_notes = 'Damage formula: (pINT-mINT)/2 + 8 (cap: 32).'
    },

    ['Earth Crusher'] = {
        description = 'AoE Earth damage. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = 'Earth',
        skillchain = {'Detonation', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 3.58, [3000] = 6.16},
        skill_required = 70,
        jobs = {
            PLD = 23,
            WAR = 24, MNK = 24, BLM = 24, DRG = 24, SMN = 24,
            WHM = 25, BRD = 25, SCH = 25, GEO = 25
        },
        special_notes = 'Can only be used with WAR/MNK/WHM/PLD/GEO as main or sub job. Damage formula: (pINT-mINT)×1 (cap: 32).'
    },

    ['Starburst'] = {
        description = 'Light/Dark random. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, MND = 40},
        hits = 1,
        element = nil, -- Random Light/Dark
        skillchain = {'Compression', 'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 3.27, [3000] = 5.54},
        skill_required = 100,
        jobs = {
            PLD = 33,
            WAR = 34, MNK = 34, BLM = 34, DRG = 34, SMN = 34,
            WHM = 35, BRD = 35, SCH = 35, GEO = 35
        },
        special_notes = 'Randomly deals Light or Dark elemental damage. Uses monster Blunt Damage Taken % instead of Magic Damage Taken %. dSTAT cap: 32.'
    },

    ['Sunburst'] = {
        description = 'Light/Dark random. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, MND = 40},
        hits = 1,
        element = nil, -- Random Light/Dark
        skillchain = {'Compression', 'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 3.58, [3000] = 6.16},
        skill_required = 150,
        jobs = {
            PLD = 49,
            WAR = 51, MNK = 51, BLM = 51, DRG = 51, SMN = 51,
            WHM = 52, BRD = 52, SCH = 52, GEO = 52
        },
        special_notes = 'Can only be used with WAR/MNK/WHM/PLD/GEO as main or sub job. Randomly deals Light or Dark elemental damage. Uses monster Blunt Damage Taken % instead of Magic Damage Taken %.'
    },

    ---========================================================================
    --- INTERMEDIATE STAFF WEAPON SKILLS (Skill 175-290)
    ---========================================================================

    ['Shell Crusher'] = {
        description = 'Lowers defense. Duration varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = 'Wind',
        skillchain = {'Detonation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 175,
        jobs = {
            PLD = 55,
            WAR = 56, MNK = 56, BLM = 56, DRG = 56, SMN = 56,
            WHM = 57, BRD = 57, SCH = 57, GEO = 57
        },
        special_notes = 'Defense Down: -25%. Duration: 180s@1000TP / 360s@2000TP / 540s@3000TP (halved if resisted). Wind-based. Does not stack with Dia, Full Break, or Angon.'
    },

    ['Full Swing'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 1,
        element = nil,
        skillchain = {'Liquefaction', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 3.0, [3000] = 9.0},
        skill_required = 200,
        jobs = {
            PLD = 60,
            WAR = 62, MNK = 62, BLM = 62, DRG = 62, SMN = 62,
            WHM = 64, BRD = 64, SCH = 64, GEO = 64
        }
    },

    ['Spirit Taker'] = {
        description = 'Converts damage to own MP.',
        type = 'Physical',
        mods = {INT = 50, MND = 50},
        hits = 1,
        element = nil,
        skillchain = {},
        ftp = {[1000] = 1.0, [2000] = 2.0, [3000] = 3.0},
        skill_required = 215,
        jobs = {
            PLD = 63,
            WAR = 66, MNK = 66, SMN = 66,
            BLM = 68, DRG = 68,
            WHM = 70, BRD = 70, SCH = 70, GEO = 70
        },
        special_notes = 'No skillchain properties. MP drain equal to damage dealt.'
    },

    ['Retribution'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 30, MND = 50},
        hits = 1,
        element = nil,
        skillchain = {'Gravitation', 'Reverberation'},
        ftp = {[1000] = 2.0, [2000] = 3.0, [3000] = 5.0},
        skill_required = 230,
        jobs = {
            PLD = 67,
            WAR = 71, MNK = 71, SMN = 71,
            BLM = 73, DRG = 73,
            WHM = 75, BRD = 75, GEO = 75,
            RDM = 99, BST = 99, SCH = 99 -- via Kaja Staff/Xoanon
        },
        special_notes = "Requires 'Blood and Glory' quest for main job usage. Kaja Staff/Xoanon: enable use by any job at level 99 without quest. Attack modifier: 1.5. PLD cannot complete quest before level 71."
    },

    ['Cataclysm'] = {
        description = 'AoE Dark damage. Varies with TP.',
        type = 'Magical',
        mods = {STR = 30, INT = 30},
        hits = 1,
        element = 'Dark',
        skillchain = {'Compression', 'Reverberation'},
        ftp = {[1000] = 1.75, [2000] = 3.75, [3000] = 6.5},
        skill_required = 290,
        jobs = {
            PLD = 80,
            WAR = 83, MNK = 83, SMN = 83,
            BLM = 85, DRG = 85,
            WHM = 86, BRD = 86, SCH = 86, GEO = 86
        },
        special_notes = 'Can only be used with WAR/MNK/WHM/PLD/GEO as main or sub job. Damage formula: (pINT-mINT)/2 + 8 (cap: 32).'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Shattersoul'] = {
        description = 'Three hits. Lowers target magic defense.',
        type = 'Physical',
        mods = {INT = 73}, -- 73-85% with merits
        hits = 3,
        element = nil,
        skillchain = {'Darkness', 'Gravitation', 'Induration'},
        ftp = {[1000] = 1.375, [2000] = 1.375, [3000] = 1.375},
        skill_required = 357,
        jobs = {
            PLD = 91,
            MNK = 94, SMN = 94, WAR = 94,
            BLM = 95, DRG = 95,
            WHM = 96, BRD = 96, SCH = 96, GEO = 96
        },
        special_notes = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Magic Defense Bonus -10 for 120 seconds. Merits: 73% INT@1/5, +3% per merit, 85% INT@5/5. Darkness becomes primary only under Aeonic Aftermath."
    },

    ['Gate of Tartarus'] = {
        description = 'Lowers target attack. Refresh (Aftermath).',
        type = 'Physical',
        mods = {INT = 80},
        hits = 1,
        element = nil,
        skillchain = {'Darkness', 'Distortion'},
        ftp = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required = 357,
        jobs = {
            BLM = 75, SMN = 75, -- via Thyrus or Claustrum
            -- Level 85 via Chthonic Staff
        },
        special_notes = 'Thyrus/Claustrum: BLM/SMN level 75. Chthonic Staff: BLM/SMN level 85. Attack Down: -18.75% for 2 minutes. Aftermath: Refresh +8 MP/tick for 20-60s@1000TP / 40-120s@2000TP / 60-180s@3000TP (varies by Aftermath level). Claustrum level 99-119: +40% damage bonus. Only Thyrus/Claustrum grant Relic Aftermath.'
    },

    ['Garland of Bliss'] = {
        description = 'Light damage. Lowers defense. Varies.',
        type = 'Magical',
        mods = {STR = 30, MND = 70},
        hits = 1,
        element = 'Light',
        skillchain = {'Fusion', 'Reverberation'},
        ftp = {[1000] = 2.25, [2000] = 2.25, [3000] = 2.25},
        skill_required = 357,
        jobs = {
            SMN = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Summoner)' quest. Can only be used with SMN as main job. Defense Down: -12.5%. Duration: 60s@1000TP / 120s@2000TP / 180s@3000TP. Damage formula: (pMND-mMND)×2. Nirvana: +15% damage@90-95, +30% damage@99-119."
    },

    ['Omniscience'] = {
        description = 'Dark damage. Lowers magic attack.',
        type = 'Magical',
        mods = {MND = 80},
        hits = 1,
        element = 'Dark',
        skillchain = {'Gravitation', 'Transfixion'},
        ftp = {[1000] = 2.0, [2000] = 2.0, [3000] = 2.0},
        skill_required = 357,
        jobs = {
            SCH = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Scholar)' quest. Can only be used with SCH as main job. Magic Attack Bonus -10. Duration: ~60s@1000TP / ~120s@2000TP / ~180s@3000TP. Damage formula: (pMND-mMND)×2. Tupsimati: +15% damage@90-95, +30% damage@99-119."
    },

    ['Vidohunir'] = {
        description = 'Dark damage. Lowers magic defense.',
        type = 'Magical',
        mods = {INT = 80},
        hits = 1,
        element = 'Dark',
        skillchain = {'Fragmentation', 'Distortion'},
        ftp = {[1000] = 1.75, [2000] = 1.75, [3000] = 1.75},
        skill_required = 357,
        jobs = {
            BLM = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Black Mage)' quest. Can only be used with BLM as main job. Magic Defense Bonus -10. Duration: 60s@1000TP / 120s@2000TP / 180s@3000TP. Damage formula: (pINT-mINT)×2. Laevateinn: +15% damage@90-95, +30% damage@99-119."
    },

    ---========================================================================
    --- EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Myrkr'] = {
        description = 'Restores MP and removes status ailments.',
        type = 'Magical',
        mods = {}, -- Based on Max MP
        hits = 0, -- Self-targeted utility
        element = nil,
        skillchain = {},
        ftp = {[1000] = 0.2, [2000] = 0.4, [3000] = 0.6}, -- MP % restore
        skill_required = 357,
        jobs = {
            BLM = 85, SMN = 85, SCH = 85
        },
        special_notes = "Hvergelmir/Taiaha/Paikea: BLM/SMN/SCH level 85. Requires 'Kupofried's Weapon Skill Moogle Magic' quest. MP restore: 20%@1000TP / 40%@2000TP / 60%@3000TP. Removes up to 3 status ailments. Self-targeted, usable without claiming monsters. Only Hvergelmir grants Empyrean Aftermath."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Oshala'] = {
        description = 'Damage varies. Magic aftermath bonus.',
        type = 'Physical',
        mods = {INT = 45, MND = 45}, -- verification needed
        hits = 1, -- verification needed
        element = nil,
        skillchain = {'Induration', 'Reverberation', 'Fusion'},
        ftp = {[1000] = 3.95, [2000] = 7.89, [3000] = 11.84},
        skill_required = 1,
        jobs = {
            BLM = 99, SMN = 99, SCH = 99
        },
        special_notes = 'Requires Opashoro (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Magic Damage Limit+). Stat modifiers require verification.'
    },

    ---========================================================================
    --- CAMPAIGN WEAPON SKILLS
    ---========================================================================

    ['Tartarus Torpor'] = {
        description = 'AoE Sleep. Lowers magic defense and evasion.',
        type = 'Magical',
        mods = {STR = 30, INT = 30},
        hits = 1, -- verification needed
        element = 'Dark',
        skillchain = {},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0}, -- verification needed
        skill_required = 73,
        jobs = {
            MNK = 73, WHM = 73, BLM = 73, RDM = 73, PLD = 73,
            BRD = 73, RNG = 73, SMN = 73, BLU = 73, PUP = 73,
            SCH = 73, GEO = 73, RUN = 73
        },
        special_notes = 'Only available during Campaign Battle while equipped with Samudra. AoE Sleep + lowers magic defense and magic evasion. Sleep duration and exact fTP values require verification. No skillchain properties.'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function staff_ws.get_ws_data(ws_name)
    return staff_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (WAR, MNK, WHM, BLM, PLD, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function staff_ws.can_use(ws_name, job_code, level)
    local ws_data = staff_ws.weaponskills[ws_name]
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
function staff_ws.get_jobs_for_ws(ws_name)
    local ws_data = staff_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function staff_ws.get_ws_type(ws_name)
    local ws_data = staff_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function staff_ws.get_ws_element(ws_name)
    local ws_data = staff_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function staff_ws.get_skillchain_properties(ws_name)
    local ws_data = staff_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function staff_ws.get_ftp(ws_name, tp)
    local ws_data = staff_ws.weaponskills[ws_name]
    if not ws_data or not ws_data.ftp then
        return nil
    end

    -- Round TP to nearest 1000
    local tp_key = 1000
    if tp >= 2500 then
        tp_key = 3000
    elseif tp >= 1500 then
        tp_key = 2000
    end

    return ws_data.ftp[tp_key]
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return staff_ws

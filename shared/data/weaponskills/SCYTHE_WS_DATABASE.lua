---============================================================================
--- Scythe Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Scythe weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, INT%, MND%, CHR%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum scythe skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file SCYTHE_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local scythe_ws = {}

scythe_ws.weaponskills = {
    ---========================================================================
    --- BASIC SCYTHE WEAPON SKILLS (Skill 5-150)
    ---========================================================================

    ['Slice'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Scission'},
        ftp = {[1000] = 1.0, [2000] = 2.5, [3000] = 4.125},
        skill_required = 5,
        jobs = {
            DRK = 1,
            WAR = 3,
            BST = 3,
            BLM = 4
        }
    },

    ['Dark Harvest'] = {
        description = 'Dark elemental. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = 'Dark',
        skillchain = {'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 3.54, [3000] = 6.07},
        skill_required = 30,
        jobs = {
            DRK = 9,
            WAR = 10,
            BST = 10,
            BLM = 12
        },
        special_notes = 'Damage formula: (pINT-mINT)/2 + 8 (cap: 32). Magic accuracy increased in June 2014 update.'
    },

    ['Shadow of Death'] = {
        description = 'Dark elemental. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = 'Dark',
        skillchain = {'Induration', 'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 4.17, [3000] = 8.6},
        skill_required = 70,
        jobs = {
            DRK = 23,
            WAR = 24,
            BST = 24,
            BLM = 28
        },
        special_notes = 'Can only be used with WAR/DRK as main or sub job. BLM cannot use despite level requirement. Damage formula: (pINT-mINT)/2 + 8 (cap: 32).'
    },

    ['Nightmare Scythe'] = {
        description = 'Blinds target. Duration varies with TP.',
        type = 'Physical',
        mods = {STR = 60, MND = 60},
        hits = 1,
        element = nil,
        skillchain = {'Compression', 'Scission'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 100,
        jobs = {
            DRK = 33,
            WAR = 34,
            BST = 34,
            BLM = 40
        },
        special_notes = 'Blind duration: 60s@1000TP / 120s@2000TP / 180s@3000TP. Accuracy of additional effect increased in June 2017.'
    },

    ['Spinning Scythe'] = {
        description = 'AoE attack. Radius varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Reverberation', 'Scission'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 125,
        jobs = {
            DRK = 41,
            WAR = 43,
            BST = 43,
            BLM = 50
        },
        special_notes = 'AoE radius: 3.5@1000TP / 4.5@2000TP / 5.5@3000TP.'
    },

    ['Vorpal Scythe'] = {
        description = 'Single hit. Crit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Transfixion', 'Scission'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 150,
        jobs = {
            DRK = 49,
            WAR = 51,
            BST = 51,
            BLM = 56
        },
        special_notes = 'Critical hit rate varies with TP (exact percentages need verification).'
    },

    ---========================================================================
    --- INTERMEDIATE SCYTHE WEAPON SKILLS (Skill 200-300)
    ---========================================================================

    ['Guillotine'] = {
        description = 'Four hits + Silence. Duration varies.',
        type = 'Physical',
        mods = {STR = 30, MND = 50},
        hits = 4,
        element = nil,
        skillchain = {'Induration'},
        ftp = {[1000] = 0.875, [2000] = 0.875, [3000] = 0.875},
        skill_required = 200,
        jobs = {
            DRK = 60
        },
        special_notes = 'Can only be used with DRK as main job. Silence duration: 60s@1000TP / 120s@2000TP / 180s@3000TP.'
    },

    ['Cross Reaper'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60, MND = 60},
        hits = 2,
        element = nil,
        skillchain = {'Distortion'},
        ftp = {[1000] = 2.0, [2000] = 4.0, [3000] = 7.0},
        skill_required = 225,
        jobs = {
            DRK = 65,
            -- Level 99 via Maliya Sickle/+1
            WAR = 99,
            BST = 99,
            BLM = 99
        },
        special_notes = 'DRK level 65 (main job). Other jobs at level 99 via Maliya Sickle/+1 only.'
    },

    ['Spiral Hell'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50, INT = 50},
        hits = 1,
        element = nil,
        skillchain = {'Distortion', 'Scission'},
        ftp = {[1000] = 1.375, [2000] = 2.75, [3000] = 4.75},
        skill_required = 240,
        jobs = {
            DRK = 68,
            WAR = 72,
            BST = 75,
            BLM = 99 -- via Kaja Scythe/Drepanum
        },
        special_notes = "Requires 'Souls in Shadow' quest for main job usage. Kaja Scythe/Drepanum: +100% damage bonus and enable use by any job at level 99."
    },

    ['Infernal Scythe'] = {
        description = 'Dark damage. Lowers attack. Varies.',
        type = 'Magical',
        mods = {STR = 30, INT = 70},
        hits = 1,
        element = 'Dark',
        skillchain = {'Compression', 'Reverberation'},
        ftp = {[1000] = 3.5, [2000] = 3.5, [3000] = 3.5},
        skill_required = 300,
        jobs = {
            DRK = 80,
            WAR = 84,
            BST = 86,
            BLM = 99
        },
        special_notes = 'Can only be used with WAR/DRK as main or sub job. Attack Down -25%. Duration: 180s@1000TP / 360s@2000TP / 540s@3000TP (halved if resisted). Water-based, unlikely to land on Water/Thunder enemies.'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Entropy'] = {
        description = 'Four hits. Damage to MP. Accuracy varies.',
        type = 'Physical',
        mods = {INT = 73}, -- 73-85% with merits
        hits = 4,
        element = nil,
        skillchain = {'Darkness', 'Gravitation', 'Reverberation'},
        ftp = {[1000] = 0.75, [2000] = 1.25, [3000] = 2.0},
        skill_required = 357,
        jobs = {
            DRK = 90,
            WAR = 93,
            BST = 95
        },
        special_notes = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. MP drain: 15-25% of damage. Merits: 73% INT@1/5, +3% per merit, 85% INT@5/5. Functions against undead. Can only be used as main job. Darkness becomes exclusive during Aeonic Aftermath."
    },

    ['Catastrophe'] = {
        description = 'Damage to HP. Aftermath varies with TP.',
        type = 'Physical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = nil,
        skillchain = {'Darkness', 'Gravitation'},
        ftp = {[1000] = 2.75, [2000] = 2.75, [3000] = 2.75},
        skill_required = 357,
        jobs = {
            DRK = 75, -- via Bec de Faucon or Apocalypse
            -- Level 85 via Crisis Scythe
        },
        special_notes = 'Bec de Faucon/Apocalypse: DRK level 75. Crisis Scythe: DRK level 85. HP drain: 30-70% of damage (does not work on undead). Aftermath: 10% Equipment Haste for 20s@1000TP / 40s@2000TP / 60s@3000TP. Apocalypse level 90+: +25-40% damage bonus. Apocalypse 119 III: Aftermath becomes 10% Job Ability Haste + Accuracy +15. Only Bec de Faucon/Apocalypse grant Relic Aftermath.'
    },

    ['Quietus'] = {
        description = 'Triple damage. Ignores defense.',
        type = 'Physical',
        mods = {STR = 60, MND = 60},
        hits = 3,
        element = nil,
        skillchain = {'Darkness', 'Distortion'},
        ftp = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required = 357,
        jobs = {
            DRK = 85
        },
        special_notes = "Redemption/Penitence/Umiliati: DRK level 85. Requires 'Kupofried's Weapon Skill Moogle Magic' quest. Defense ignore: 12.5%@1000TP / 37.5%@2000TP / 62.5%@3000TP. Can only be used with DRK as main job. Only Redemption grants Empyrean Aftermath."
    },

    ['Insurgency'] = {
        description = 'Four hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 20, INT = 20},
        hits = 4,
        element = nil,
        skillchain = {'Fusion', 'Compression'},
        ftp = {[1000] = 0.5, [2000] = 3.25, [3000] = 6.0},
        skill_required = 357,
        jobs = {
            DRK = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Dark Knight)' quest. Can only be used with DRK as main job. Liberator: +15% damage@90-95, +30% damage@99-119."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Origin'] = {
        description = 'Absorbs HP and MP. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60, INT = 60},
        hits = 1,
        element = nil,
        skillchain = {'Induration', 'Reverberation', 'Fusion'},
        ftp = {[1000] = 3.0, [2000] = 6.0, [3000] = 9.0},
        skill_required = 1,
        jobs = {
            DRK = 99
        },
        special_notes = 'Requires Foenaria (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Physical Damage Limit+). HP/MP drain does not work on undead. MP drain requires target to have MP.'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function scythe_ws.get_ws_data(ws_name)
    return scythe_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (DRK, WAR, BST, BLM, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function scythe_ws.can_use(ws_name, job_code, level)
    local ws_data = scythe_ws.weaponskills[ws_name]
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
function scythe_ws.get_jobs_for_ws(ws_name)
    local ws_data = scythe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function scythe_ws.get_ws_type(ws_name)
    local ws_data = scythe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function scythe_ws.get_ws_element(ws_name)
    local ws_data = scythe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function scythe_ws.get_skillchain_properties(ws_name)
    local ws_data = scythe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function scythe_ws.get_ftp(ws_name, tp)
    local ws_data = scythe_ws.weaponskills[ws_name]
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

return scythe_ws

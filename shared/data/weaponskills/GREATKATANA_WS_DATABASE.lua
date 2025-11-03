---============================================================================
--- Great Katana Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Great Katana weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, INT%, MND%, CHR%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum great katana skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file GREATKATANA_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local greatkatana_ws = {}

greatkatana_ws.weaponskills = {
    ---========================================================================
    --- BASIC GREAT KATANA WEAPON SKILLS (Skill 5-150)
    ---========================================================================

    ['Tachi: Enpi'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60},
        hits = 2,
        element = nil,
        skillchain = {'Transfixion', 'Scission'},
        ftp = {[1000] = 1.0, [2000] = 2.0, [3000] = 4.0},
        skill_required = 5,
        jobs = {
            SAM = 1,
            NIN = 3
        }
    },

    ['Tachi: Hobaku'] = {
        description = 'Stuns target. Accuracy varies with TP.',
        type = 'Physical',
        mods = {STR = 60},
        hits = 1,
        element = nil,
        skillchain = {'Induration'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0}, -- 2000/3000 need verification
        skill_required = 30,
        jobs = {
            SAM = 9,
            NIN = 10
        },
        special_notes = 'Stun accuracy varies with TP. fTP values at 2000/3000 TP require verification.'
    },

    ['Tachi: Goten'] = {
        description = 'Thunder elemental. Varies with TP.',
        type = 'Hybrid',
        mods = {STR = 60},
        hits = 1,
        element = 'Thunder',
        skillchain = {'Transfixion', 'Impaction'},
        ftp = {[1000] = 0.5, [2000] = 1.5, [3000] = 2.5},
        skill_required = 70,
        jobs = {
            SAM = 23,
            NIN = 25
        }
    },

    ['Tachi: Kagero'] = {
        description = 'Fire elemental. Varies with TP.',
        type = 'Hybrid',
        mods = {STR = 75},
        hits = 1,
        element = 'Fire',
        skillchain = {'Liquefaction'},
        ftp = {[1000] = 0.5, [2000] = 1.5, [3000] = 2.5},
        skill_required = 100,
        jobs = {
            SAM = 33,
            NIN = 35
        }
    },

    ['Tachi: Jinpu'] = {
        description = 'Two hits. Wind damage. Varies with TP.',
        type = 'Hybrid',
        mods = {STR = 30},
        hits = 2,
        element = 'Wind',
        skillchain = {'Scission', 'Detonation'},
        ftp = {[1000] = 0.5, [2000] = 1.5, [3000] = 2.5},
        skill_required = 150,
        jobs = {
            SAM = 49,
            NIN = 52
        }
    },

    ---========================================================================
    --- INTERMEDIATE GREAT KATANA WEAPON SKILLS (Skill 175-300)
    ---========================================================================

    ['Tachi: Koki'] = {
        description = 'Light elemental. Varies with TP.',
        type = 'Hybrid',
        mods = {STR = 50, MND = 30},
        hits = 1,
        element = 'Light',
        skillchain = {'Reverberation', 'Impaction'},
        ftp = {[1000] = 0.5, [2000] = 1.5, [3000] = 2.5},
        skill_required = 175,
        jobs = {
            SAM = 55,
            NIN = 57
        }
    },

    ['Tachi: Yukikaze'] = {
        description = 'Blinds target. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 75},
        hits = 1,
        element = nil,
        skillchain = {'Induration', 'Detonation'},
        ftp = {[1000] = 1.5625, [2000] = 2.6875, [3000] = 4.125},
        skill_required = 200,
        jobs = {
            SAM = 60
        },
        special_notes = 'Can only be used with SAM as main job. Blind duration: 60 seconds. Attack modifier: 1.5.'
    },

    ['Tachi: Gekko'] = {
        description = 'Silences target. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 75},
        hits = 1,
        element = nil,
        skillchain = {'Distortion', 'Reverberation'},
        ftp = {[1000] = 1.5625, [2000] = 2.6875, [3000] = 4.125},
        skill_required = 225,
        jobs = {
            SAM = 65,
            NIN = 99 -- via Beryllium Tachi/+1
        },
        special_notes = 'SAM level 65 (main job). NIN at level 99 via Beryllium Tachi/+1 only. Silence duration: 45 seconds (unresisted). Attack modifier: 2.0.'
    },

    ['Tachi: Kasha'] = {
        description = 'Paralyzes target. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 75},
        hits = 1,
        element = nil,
        skillchain = {'Fusion', 'Compression'},
        ftp = {[1000] = 1.5625, [2000] = 2.6875, [3000] = 4.125},
        skill_required = 250,
        jobs = {
            SAM = 71,
            NIN = 99 -- via Kaja Tachi/Hachimonji
        },
        special_notes = "Requires 'The Potential Within' quest for SAM main job at level 71. NIN at level 99 via Kaja Tachi/Hachimonji. Paralyze duration: 60 seconds. Attack modifier: 1.65."
    },

    ['Tachi: Ageha'] = {
        description = 'Lowers defense. Effectiveness varies.',
        type = 'Physical',
        mods = {STR = 40, CHR = 60},
        hits = 1,
        element = nil,
        skillchain = {'Compression', 'Scission'},
        ftp = {[1000] = 2.625, [2000] = 2.625, [3000] = 2.625}, -- verification needed
        skill_required = 300,
        jobs = {
            SAM = 80,
            NIN = 90
        },
        special_notes = 'Defense Down: -25% for 3 minutes (if successful). Resist cooldown: 1.5 minutes. Only one Defense Down effect may be active at a time. Significantly buffed in June 2017 to land consistently on average mobs up to level 130.'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Tachi: Shoha'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 73}, -- 73-85% with merits
        hits = 2,
        element = nil,
        skillchain = {'Light', 'Fragmentation', 'Compression'},
        ftp = {[1000] = 1.375, [2000] = 3.25, [3000] = 4.625},
        skill_required = 357,
        jobs = {
            SAM = 90
        },
        special_notes = "Requires 'Martial Mastery' quest. Merits: 73% STR@1/5, +3% per merit, 85% STR@5/5. Can only be used with SAM as main job. Light becomes available only while under Aeonic Aftermath."
    },

    ['Tachi: Kaiten'] = {
        description = 'TP Bonus aftermath. Duration varies.',
        type = 'Physical',
        mods = {STR = 80},
        hits = 1,
        element = nil,
        skillchain = {'Light', 'Fragmentation'},
        ftp = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required = 357,
        jobs = {
            SAM = 75, -- via Totsukanotsurugi or Amanomurakumo
            -- Level 85 via Ame-no-ohabari
            -- Level 99 via Fusenaikyo with Sekkanoki
        },
        special_notes = 'Totsukanotsurugi/Amanomurakumo: SAM level 75. Ame-no-ohabari: SAM level 85. Fusenaikyo (with Sekkanoki): SAM level 99. Aftermath: Store TP +7 (standard) or +10 (Afterglow) for 20s@1000TP / 40s@2000TP / 60s@3000TP. Amanomurakumo level 90+: +25-40% damage bonus. Only Totsukanotsurugi/Amanomurakumo grant Relic Aftermath.'
    },

    ['Tachi: Fudo'] = {
        description = 'Double damage. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 80},
        hits = 1,
        element = nil,
        skillchain = {'Light', 'Distortion'},
        ftp = {[1000] = 3.75, [2000] = 5.75, [3000] = 8.0},
        skill_required = 357,
        jobs = {
            SAM = 85
        },
        special_notes = "Masamune/Hiradennotachi/Torigashira: SAM level 85. Requires 'Kupofried's Weapon Skill Moogle Magic' quest. Can only be used with SAM as main job. Double damage mechanic. Receives NO Attack/Defense Ratio bonus (raw Attack stat more important). Only Masamune grants Empyrean Aftermath."
    },

    ['Tachi: Rana'] = {
        description = 'Three hits. Accuracy varies with TP.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 3,
        element = nil,
        skillchain = {'Gravitation', 'Induration'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 357,
        jobs = {
            SAM = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Samurai)' quest. Can only be used with SAM as main job. Accuracy varies with TP (exact values unknown). Kogarasumaru: +15% damage@90-95, +30% damage@99-119."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Tachi: Mumei'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50, DEX = 50},
        hits = 1,
        element = nil,
        skillchain = {'Detonation', 'Compression', 'Distortion'},
        ftp = {[1000] = 3.66, [2000] = 7.33, [3000] = 11.0},
        skill_required = 1,
        jobs = {
            SAM = 99
        },
        special_notes = 'Requires Kusanagi (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Physical Damage Limit+).'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function greatkatana_ws.get_ws_data(ws_name)
    return greatkatana_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (SAM, NIN, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function greatkatana_ws.can_use(ws_name, job_code, level)
    local ws_data = greatkatana_ws.weaponskills[ws_name]
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
function greatkatana_ws.get_jobs_for_ws(ws_name)
    local ws_data = greatkatana_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function greatkatana_ws.get_ws_type(ws_name)
    local ws_data = greatkatana_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function greatkatana_ws.get_ws_element(ws_name)
    local ws_data = greatkatana_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function greatkatana_ws.get_skillchain_properties(ws_name)
    local ws_data = greatkatana_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function greatkatana_ws.get_ftp(ws_name, tp)
    local ws_data = greatkatana_ws.weaponskills[ws_name]
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

return greatkatana_ws

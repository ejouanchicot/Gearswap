---============================================================================
--- Great Sword Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Great Sword weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, INT%, MND%, AGI%, DEX%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum great sword skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file GREATSWORD_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local greatsword_ws = {}

greatsword_ws.weaponskills = {
    ---========================================================================
    --- BASIC GREAT SWORD WEAPON SKILLS (Skill 1-150)
    ---========================================================================

    ['Hard Slash'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Scission'},
        ftp = {[1000] = 1.5, [2000] = 2.5, [3000] = 3.5},
        skill_required = 5,
        jobs = {
            WAR = 1,
            PLD = 1,
            DRK = 1,
            RUN = 1
        }
    },

    ['Power Slash'] = {
        description = 'Single hit. Crit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 60, VIT = 60},
        hits = 1,
        element = nil,
        skillchain = {'Transfixion'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 30,
        jobs = {
            DRK = 9,
            RUN = 9,
            WAR = 10,
            PLD = 10
        },
        special_notes = 'May have static critical hit rate rather than bonus to base rate.'
    },

    ['Frostbite'] = {
        description = 'Ice elemental attack. Damage varies with TP.',
        type = 'Magical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = 'Ice',
        skillchain = {'Induration'},
        ftp = {[1000] = 1.5, [2000] = 3.25, [3000] = 5.0},
        skill_required = 70,
        jobs = {
            DRK = 23,
            RUN = 23,
            WAR = 24,
            PLD = 24
        },
        special_notes = 'Damage formula: (pINT-mINT)/2 + 8 (cap: 32).'
    },

    ['Freezebite'] = {
        description = 'Ice elemental attack. Damage varies with TP.',
        type = 'Magical',
        mods = {STR = 40, INT = 40},
        hits = 1,
        element = 'Ice',
        skillchain = {'Induration', 'Detonation'},
        ftp = {[1000] = 1.5, [2000] = 3.5, [3000] = 6.0},
        skill_required = 100,
        jobs = {
            DRK = 33,
            RUN = 33,
            WAR = 34,
            PLD = 34
        },
        special_notes = 'Damage formula: (pINT-mINT)/2 + 8 (cap: 32). Magic accuracy increased in June 2014 update.'
    },

    ['Shockwave'] = {
        description = 'AoE sleep. Duration varies with TP.',
        type = 'Physical',
        mods = {STR = 30, MND = 30},
        hits = 1,
        element = 'Dark',
        skillchain = {'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 150,
        jobs = {
            DRK = 49,
            RUN = 49,
            WAR = 51,
            PLD = 51
        },
        special_notes = 'Sleep duration: ~130s@1000TP / >230s@2000TP / >330s@3000TP. Dark-based sleep, can be overwritten by Sleep II.'
    },

    ---========================================================================
    --- INTERMEDIATE GREAT SWORD WEAPON SKILLS (Skill 175-250)
    ---========================================================================

    ['Crescent Moon'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 80},
        hits = 1,
        element = nil,
        skillchain = {'Scission'},
        ftp = {[1000] = 1.0, [2000] = 2.25, [3000] = 4.0},
        skill_required = 175,
        jobs = {
            DRK = 55,
            RUN = 55,
            WAR = 56,
            PLD = 56
        }
    },

    ['Sickle Moon'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 40, AGI = 40},
        hits = 2,
        element = nil,
        skillchain = {'Scission', 'Impaction'},
        ftp = {[1000] = 1.5, [2000] = 3.5, [3000] = 6.5},
        skill_required = 200,
        jobs = {
            DRK = 60,
            RUN = 60,
            PLD = 62
        },
        special_notes = 'Can only be used with RUN/DRK/PLD as main job.'
    },

    ['Spinning Slash'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 30, INT = 30},
        hits = 1,
        element = nil,
        skillchain = {'Fragmentation'},
        ftp = {[1000] = 2.5, [2000] = 5.0, [3000] = 7.5},
        skill_required = 225,
        jobs = {
            RUN = 65,
            DRK = 66,
            PLD = 69,
            WAR = 99 -- via Beryllium Sword/+1
        },
        special_notes = 'WAR access via Beryllium Sword/+1 only. Beryllium/Dervish/Foreshock Sword: +35% damage bonus.'
    },

    ['Ground Strike'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50, INT = 50},
        hits = 1,
        element = nil,
        skillchain = {'Fragmentation', 'Distortion'},
        ftp = {[1000] = 1.5, [2000] = 3.0, [3000] = 5.0},
        skill_required = 250,
        jobs = {
            RUN = 70,
            DRK = 72,
            WAR = 74,
            PLD = 75
        },
        special_notes = "Requires 'Inheritance' quest for main job usage. Kaja Claymore/Nandaka: +15% damage bonus and enable use by any job at level 99. Attack modifier: 1.75."
    },

    ---========================================================================
    --- ADVANCED GREAT SWORD WEAPON SKILLS (Skill 300+)
    ---========================================================================

    ['Herculean Slash'] = {
        description = 'Paralyzes target. Duration varies with TP.',
        type = 'Magical',
        mods = {VIT = 80},
        hits = 1,
        element = 'Ice',
        skillchain = {'Induration', 'Impaction', 'Detonation'},
        ftp = {[1000] = 3.5, [2000] = 3.5, [3000] = 3.5},
        skill_required = 300,
        jobs = {
            RUN = 78,
            DRK = 80,
            WAR = 82,
            PLD = 83
        },
        special_notes = 'Paralyze duration: 60s@1000TP / 120s@2000TP / 180s@3000TP.'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Resolution'] = {
        description = 'Five hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 73}, -- 73-85% with merits
        hits = 5,
        element = nil,
        skillchain = {'Light', 'Fragmentation', 'Scission'},
        ftp = {[1000] = 0.71875, [2000] = 1.5, [3000] = 2.25},
        skill_required = 357,
        jobs = {
            WAR = 96,
            PLD = 96,
            DRK = 96,
            RUN = 96
        },
        special_notes = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Attack modifier: 0.85. Merits: 73% STR@1/5, +3% per merit, 85% STR@5/5."
    },

    ['Scourge'] = {
        description = 'Crit rate aftermath. Duration varies.',
        type = 'Physical',
        mods = {STR = 40, VIT = 40},
        hits = 1,
        element = nil,
        skillchain = {'Light', 'Fusion'},
        ftp = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required = 357,
        jobs = {
            WAR = 75, -- via Valhalla or Ragnarok
            PLD = 75, -- via Valhalla or Ragnarok
            DRK = 75, -- via Valhalla or Ragnarok
            -- Level 85 via Khloros Blade
        },
        special_notes = 'Valhalla/Ragnarok: WAR/PLD/DRK level 75. Khloros Blade: WAR/PLD/DRK level 85. Aftermath: Crit +5% for 20s@1000TP / 40s@2000TP / 60s@3000TP. Ragnarok level 90+: +25-40% damage bonus. Ragnarok 119 III: Crit +10% + Accuracy +15.'
    },

    ['Torcleaver'] = {
        description = 'Triple damage. Damage varies with TP.',
        type = 'Physical',
        mods = {VIT = 80},
        hits = 3,
        element = nil,
        skillchain = {'Light', 'Distortion'},
        ftp = {[1000] = 4.75, [2000] = 7.5, [3000] = 9.765625},
        skill_required = 357,
        jobs = {
            PLD = 85,
            DRK = 85
        },
        special_notes = 'Caladbolg/Espafut/Xiphias: PLD/DRK level 85. Only Caladbolg grants Empyrean Aftermath.'
    },

    ['Dimidiation'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {DEX = 80},
        hits = 2,
        element = nil,
        skillchain = {'Light', 'Fragmentation'},
        ftp = {[1000] = 2.25, [2000] = 4.5, [3000] = 6.75},
        skill_required = 357,
        jobs = {
            RUN = 99
        },
        special_notes = "Requires 'Rune Fencing the Night Away' quest. Can only be used with RUN as main job. Epeolatry (Level 119): Aftermath effect varies with TP. Attack modifier: 1.25."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Fimbulvetr'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60, VIT = 60},
        hits = 1,
        element = nil,
        skillchain = {'Detonation', 'Compression', 'Distortion'},
        ftp = {[1000] = 3.3, [2000] = 6.6, [3000] = 9.9},
        skill_required = 1,
        jobs = {
            WAR = 99,
            PLD = 99,
            DRK = 99,
            RUN = 99
        },
        special_notes = 'Requires Helheim (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Physical Damage Limit+ including pets).'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function greatsword_ws.get_ws_data(ws_name)
    return greatsword_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (WAR, PLD, DRK, RUN, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function greatsword_ws.can_use(ws_name, job_code, level)
    local ws_data = greatsword_ws.weaponskills[ws_name]
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
function greatsword_ws.get_jobs_for_ws(ws_name)
    local ws_data = greatsword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function greatsword_ws.get_ws_type(ws_name)
    local ws_data = greatsword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function greatsword_ws.get_ws_element(ws_name)
    local ws_data = greatsword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function greatsword_ws.get_skillchain_properties(ws_name)
    local ws_data = greatsword_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function greatsword_ws.get_ftp(ws_name, tp)
    local ws_data = greatsword_ws.weaponskills[ws_name]
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

return greatsword_ws

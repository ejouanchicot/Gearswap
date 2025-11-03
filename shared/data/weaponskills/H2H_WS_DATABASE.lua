---============================================================================
--- Hand-to-Hand Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Hand-to-Hand weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, DEX%, VIT%, etc.)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum hand-to-hand skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file H2H_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local h2h_ws = {}

h2h_ws.weaponskills = {
    ---========================================================================
    --- BASIC HAND-TO-HAND WEAPON SKILLS (Skill 1-150)
    ---========================================================================

    ['Combo'] = {
        description = 'Three hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 30, DEX = 30},
        hits = 3,
        element = nil,
        skillchain = {'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 3.75, [3000] = 5.5},
        skill_required = 1,
        jobs = {
            MNK = 1,
            PUP = 1,
            WAR = 2,
            THF = 2,
            NIN = 2,
            DNC = 2
        },
        special_notes = 'fTP-replicating weapon skill. TP bonus increased when 2000+ TP.'
    },

    ['Shoulder Tackle'] = {
        description = 'Stuns target. Accuracy varies with TP.',
        type = 'Physical',
        mods = {VIT = 100},
        hits = 1,
        element = nil,
        skillchain = {'Impaction', 'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 40,
        jobs = {
            MNK = 13,
            PUP = 14,
            WAR = 15,
            DNC = 15,
            THF = 16,
            NIN = 16
        },
        special_notes = 'fTP-replicating weapon skill. Stun effect accuracy varies with TP.'
    },

    ['One Inch Punch'] = {
        description = 'Ignores defense. Amount varies with TP.',
        type = 'Physical',
        mods = {VIT = 100},
        hits = 1,
        element = nil,
        skillchain = {'Compression'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 75,
        jobs = {
            MNK = 24,
            PUP = 26,
            WAR = 28,
            DNC = 28,
            THF = 30,
            NIN = 30
        },
        special_notes = 'fTP-replicating weapon skill. Defense ignored: 0%@1000TP / 25%@2000TP / 50%@3000TP.'
    },

    ['Backhand Blow'] = {
        description = 'Critical hit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 50, DEX = 50},
        hits = 2,
        element = nil,
        skillchain = {'Detonation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 100,
        jobs = {
            MNK = 33,
            PUP = 35,
            WAR = 37,
            DNC = 37,
            THF = 40,
            NIN = 40
        },
        special_notes = 'fTP-replicating weapon skill. Critical hit rate: +40%@1000TP (higher TP values unknown).'
    },

    ['Raging Fists'] = {
        description = 'Five hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 30, DEX = 30},
        hits = 5,
        element = nil,
        skillchain = {'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 2.1875, [3000] = 3.75},
        skill_required = 125,
        jobs = {
            MNK = 41,
            PUP = 44,
            WAR = 46,
            DNC = 46,
            THF = 50,
            NIN = 50
        },
        special_notes = 'Can only be used with MNK/PUP as main or sub job. fTP-replicating weapon skill.'
    },

    ['Spinning Attack'] = {
        description = 'Two hits AoE attack. Radius varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 2,
        element = nil,
        skillchain = {'Liquefaction', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 150,
        jobs = {
            MNK = 49,
            PUP = 51,
            WAR = 53,
            DNC = 53,
            THF = 56,
            NIN = 56
        },
        special_notes = 'fTP-replicating weapon skill. AoE radius: 4 yalms@1000-2349TP / 5 yalms@2350+TP.'
    },

    ---========================================================================
    --- INTERMEDIATE HAND-TO-HAND WEAPON SKILLS (Skill 175-300)
    ---========================================================================

    ['Howling Fist'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {VIT = 50, STR = 20},
        hits = 2,
        element = nil,
        skillchain = {'Transfixion', 'Impaction'},
        ftp = {[1000] = 2.05, [2000] = 3.55, [3000] = 5.75},
        skill_required = 200,
        jobs = {
            MNK = 60,
            PUP = 62
        },
        special_notes = 'Can only be used with MNK/PUP as main job. fTP-replicating weapon skill.'
    },

    ['Dragon Kick'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50, VIT = 50},
        hits = 2,
        element = nil,
        skillchain = {'Fragmentation'},
        ftp = {[1000] = 1.7, [2000] = 3.0, [3000] = 5.0},
        skill_required = 225,
        jobs = {
            MNK = 65,
            PUP = 68,
            -- Level 99 via Hepatizon Baghnakhs:
            WAR = 99,
            RDM = 99,
            THF = 99,
            DRK = 99,
            BST = 99,
            NIN = 99,
            DNC = 99
        },
        special_notes = 'During Footwork: uses foot damage + kick attack bonuses. fTP-replicating weapon skill.'
    },

    ['Asuran Fists'] = {
        description = 'Eight hits. Accuracy varies with TP.',
        type = 'Physical',
        mods = {STR = 15, VIT = 15},
        hits = 8,
        element = nil,
        skillchain = {'Gravitation', 'Liquefaction'},
        ftp = {[1000] = 1.25, [2000] = 1.25, [3000] = 1.25},
        skill_required = 250,
        jobs = {
            MNK = 71,
            PUP = 74,
            -- Level 99 via Kaja Knuckles or Karambit:
            WAR = 99,
            RDM = 99,
            THF = 99,
            DRK = 99,
            BST = 99,
            NIN = 99,
            DNC = 99
        },
        special_notes = "Requires 'The Walls of Your Mind' quest. Kaja Knuckles/Karambit: +50% damage bonus and enable use without quest."
    },

    ['Tornado Kick'] = {
        description = 'Three hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 40, VIT = 40},
        hits = 3,
        element = nil,
        skillchain = {'Induration', 'Impaction', 'Detonation'},
        ftp = {[1000] = 1.7, [2000] = 2.8, [3000] = 4.5},
        skill_required = 300,
        jobs = {
            MNK = 80,
            PUP = 84,
            WAR = 94,
            DNC = 94,
            THF = 99,
            NIN = 99
        },
        special_notes = 'Can only be used with MNK/PUP as main or sub job. During Footwork: uses foot damage. fTP-replicating weapon skill.'
    },

    ---========================================================================
    --- ADVANCED HAND-TO-HAND WEAPON SKILLS (Quest/Merit/Relic/Mythic/Empyrean)
    ---========================================================================

    ['Shijin Spiral'] = {
        description = 'Five hits + Plague. Chance varies.',
        type = 'Physical',
        mods = {DEX = 73}, -- 73-85% with merits
        hits = 5,
        element = nil,
        skillchain = {'Fusion', 'Reverberation'},
        ftp = {[1000] = 1.5, [2000] = 1.5, [3000] = 1.5},
        skill_required = 290,
        jobs = {
            MNK = 90,
            PUP = 93
        },
        special_notes = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Plague: -50 TP/tick for 5-8 ticks. Merits: 73% DEX@1/5, +3% per merit, 85% DEX@5/5."
    },

    ['Final Heaven'] = {
        description = 'Subtle Blow+10. Duration varies with TP.',
        type = 'Physical',
        mods = {VIT = 80},
        hits = 1,
        element = nil,
        skillchain = {'Light', 'Fusion'},
        ftp = {[1000] = 3.0, [2000] = 3.0, [3000] = 3.0},
        skill_required = 357,
        jobs = {
            MNK = 75, -- via Caestus or Spharai
            PUP = 85  -- via Heofon Knuckles (MNK/PUP)
        },
        special_notes = 'Caestus/Spharai: MNK level 75. Heofon Knuckles: MNK/PUP level 85. Aftermath: Subtle Blow +10 for 20s@1000TP / 40s@2000TP / 60s@3000TP. Spharai level 90+: +25-40% damage bonus.'
    },

    ['Victory Smite'] = {
        description = 'Four hits. Critical hit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 80},
        hits = 4,
        element = nil,
        skillchain = {'Light', 'Fragmentation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 290,
        jobs = {
            MNK = 85,
            PUP = 85
        },
        special_notes = "Requires 'Kupofried's Weapon Skill Moogle Magic' quest. fTP-replicating weapon skill. Critical hit rate: +10%@1000TP / +25%@2000TP / +45%@3000TP. Verethragna/Revenant Fists/Dumuzis required."
    },

    ['Ascetic\'s Fury'] = {
        description = 'Single hit. Crit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 50, VIT = 50},
        hits = 1,
        element = nil,
        skillchain = {'Fusion', 'Transfixion'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 357,
        jobs = {
            MNK = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Monk)' quest. Can only be used with MNK as main job. fTP-replicating weapon skill. Critical hit rate: +20%@1000TP / +30%@2000TP / +50%@3000TP. Attack modifier: >2.0. Glanzfaust: +15-30% damage bonus."
    },

    ['Stringing Pummel'] = {
        description = 'Six hits. Critical hit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 32, VIT = 32},
        hits = 6,
        element = nil,
        skillchain = {'Gravitation', 'Liquefaction'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 357,
        jobs = {
            PUP = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Puppetmaster)' quest. Can only be used with PUP as main job. fTP-replicating weapon skill. Critical hit rate: +<15%@1000TP / unknown@2000TP / +<45%@3000TP. Kenkonken: +15-30% damage bonus."
    },

    ---========================================================================
    --- SPECIAL WEAPON SKILLS (Prime/Unique Weapons)
    ---========================================================================

    ['Maru Kala'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60, DEX = 60},
        hits = 2,
        element = nil,
        skillchain = {'Detonation', 'Compression', 'Distortion'},
        ftp = {[1000] = 3.092, [2000] = 7.516, [3000] = 11.94},
        skill_required = 1,
        jobs = {
            MNK = 99,
            PUP = 99
        },
        special_notes = 'Requires Varga Purnikawa (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath. Available in Sortie content.'
    },

    ['Dragon Blow'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {DEX = 85},
        hits = 2,
        element = nil,
        skillchain = {'Distortion'},
        ftp = {[1000] = 3.675, [2000] = 7.0, [3000] = 10.4375},
        skill_required = 1,
        jobs = {
            MNK = 99,
            PUP = 99
        },
        special_notes = 'Requires Dragon Fangs weapon. No fTP transfer or attack bonus (unlike Howling Fist).'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function h2h_ws.get_ws_data(ws_name)
    return h2h_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (MNK, PUP, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function h2h_ws.can_use(ws_name, job_code, level)
    local ws_data = h2h_ws.weaponskills[ws_name]
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
function h2h_ws.get_jobs_for_ws(ws_name)
    local ws_data = h2h_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function h2h_ws.get_ws_type(ws_name)
    local ws_data = h2h_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function h2h_ws.get_ws_element(ws_name)
    local ws_data = h2h_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function h2h_ws.get_skillchain_properties(ws_name)
    local ws_data = h2h_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function h2h_ws.get_ftp(ws_name, tp)
    local ws_data = h2h_ws.weaponskills[ws_name]
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

return h2h_ws

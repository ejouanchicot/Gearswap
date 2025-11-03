---============================================================================
--- Axe Weapon Skills Database - Complete Metadata
---============================================================================
--- Comprehensive database for all Axe weapon skills in FFXI with:
---   • description - Effect description in English
---   • type - Physical/Magical/Hybrid
---   • mods - Stat modifiers (STR%, VIT%, DEX%, INT%, MND%, CHR%)
---   • hits - Number of hits
---   • element - Elemental affinity (Fire/Ice/Wind/Earth/Water/Light/Dark)
---   • skillchain - Skillchain properties
---   • ftp - TP modifier values at 1000/2000/3000 TP
---   • skill_required - Minimum axe skill level
---   • jobs - Job availability with level requirements
---   • special_notes - Quest requirements, aftermath effects, restrictions
---
--- @file AXE_WS_DATABASE.lua
--- @author Tetsouo
--- @version 1.0 - Complete 300% Verified against BG-Wiki
--- @date Created: 2025-10-30
--- @source https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
---============================================================================

local axe_ws = {}

axe_ws.weaponskills = {
    ---========================================================================
    --- BASIC AXE WEAPON SKILLS (Skill 5-150)
    ---========================================================================

    ['Raging Axe'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60},
        hits = 2,
        element = nil,
        skillchain = {'Detonation', 'Impaction'},
        ftp = {[1000] = 1.0, [2000] = 3.0, [3000] = 6.0},
        skill_required = 5,
        jobs = {
            WAR = 1,
            DRK = 1,
            BST = 1,
            RNG = 1,
            RUN = 1
        }
    },

    ['Smash Axe'] = {
        description = 'Stuns target. Stun chance varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = nil,
        skillchain = {'Induration', 'Reverberation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 40,
        jobs = {
            WAR = 13,
            BST = 13,
            DRK = 14,
            RNG = 14,
            RUN = 14
        },
        special_notes = 'Stun effect chance varies with TP.'
    },

    ['Gale Axe'] = {
        description = 'Wind + Choke. Chance varies with TP.',
        type = 'Physical',
        mods = {STR = 100},
        hits = 1,
        element = 'Wind',
        skillchain = {'Detonation'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 70,
        jobs = {
            WAR = 23,
            BST = 23,
            DRK = 24,
            RNG = 24,
            RUN = 24
        },
        special_notes = 'Choke duration: 60s at all TP levels. VIT -13. Wind Shot stacks for additional VIT reduction.'
    },

    ['Avalanche Axe'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60},
        hits = 1,
        element = nil,
        skillchain = {'Scission', 'Impaction'},
        ftp = {[1000] = 1.5, [2000] = 3.0, [3000] = 5.5},
        skill_required = 100,
        jobs = {
            WAR = 33,
            BST = 33,
            DRK = 34,
            RNG = 34,
            RUN = 34
        }
    },

    ['Spinning Axe'] = {
        description = 'Two hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 60},
        hits = 2,
        element = nil,
        skillchain = {'Liquefaction', 'Scission', 'Impaction'},
        ftp = {[1000] = 2.0, [2000] = 4.0, [3000] = 6.5},
        skill_required = 150,
        jobs = {
            WAR = 49,
            BST = 49,
            DRK = 51,
            RNG = 51,
            RUN = 51
        },
        special_notes = 'Can only be used with WAR/DRK/BST/RNG/RUN as main or sub job.'
    },

    ---========================================================================
    --- INTERMEDIATE AXE WEAPON SKILLS (Skill 175-290)
    ---========================================================================

    ['Rampage'] = {
        description = 'Five hits. Critical hit rate varies with TP.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 5,
        element = nil,
        skillchain = {'Scission'},
        ftp = {[1000] = 1.0, [2000] = 1.0, [3000] = 1.0},
        skill_required = 175,
        jobs = {
            WAR = 55,
            BST = 55,
            DRK = 56,
            RNG = 56,
            RUN = 56
        },
        special_notes = 'fTP-replicating weapon skill. Critical hit rate: 0%@1000TP / +20%@2000TP / +40%@3000TP.'
    },

    ['Calamity'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50, VIT = 50},
        hits = 1,
        element = nil,
        skillchain = {'Scission', 'Impaction'},
        ftp = {[1000] = 2.5, [2000] = 6.5, [3000] = 10.375},
        skill_required = 200,
        jobs = {
            WAR = 60,
            BST = 60
        },
        special_notes = 'Can only be used with WAR/BST as main job.'
    },

    ['Mistral Axe'] = {
        description = 'Single hit. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 1,
        element = nil,
        skillchain = {'Fusion'},
        ftp = {[1000] = 4.0, [2000] = 10.5, [3000] = 13.625},
        skill_required = 225,
        jobs = {
            WAR = 66,
            BST = 66,
            DRK = 99, -- via Beryllium Pick/+1
            RUN = 99  -- via Beryllium Pick/+1
        },
        special_notes = 'Ranged attack (effective range >15 feet). DRK/RUN access via Beryllium Pick/+1 at level 99.'
    },

    ['Decimation'] = {
        description = 'Three aerial hits. Accuracy varies.',
        type = 'Physical',
        mods = {STR = 50},
        hits = 3,
        element = nil,
        skillchain = {'Fusion', 'Reverberation'},
        ftp = {[1000] = 1.75, [2000] = 1.75, [3000] = 1.75},
        skill_required = 240,
        jobs = {
            WAR = 70,
            BST = 70,
            DRK = 75,
            RNG = 75,
            RUN = 75
        },
        special_notes = "Requires 'Axe the Competition' quest. Kaja Axe/Dolichenus: +15% damage bonus (applies to all hits) and enable use at level 99. fTP transfers across hits."
    },

    ['Bora Axe'] = {
        description = 'Binds target. Bind chance varies with TP.',
        type = 'Physical',
        mods = {DEX = 100},
        hits = 1,
        element = nil,
        skillchain = {'Scission', 'Detonation'},
        ftp = {[1000] = 4.5, [2000] = 4.5, [3000] = 4.5},
        skill_required = 290,
        jobs = {
            WAR = 80,
            BST = 80,
            DRK = 85,
            RNG = 85,
            RUN = 85
        },
        special_notes = 'Can only be used with WAR/DRK/BST/RUN as main or sub job. Ranged attack (effective range >15 feet).'
    },

    ---========================================================================
    --- MERIT/RELIC/MYTHIC/EMPYREAN WEAPON SKILLS
    ---========================================================================

    ['Ruinator'] = {
        description = 'Four hits. Accuracy varies with TP.',
        type = 'Physical',
        mods = {STR = 73}, -- 73-85% with merits
        hits = 4,
        element = nil,
        skillchain = {'Darkness', 'Distortion', 'Detonation'},
        ftp = {[1000] = 1.08, [2000] = 1.08, [3000] = 1.08},
        skill_required = 357,
        jobs = {
            WAR = 91,
            BST = 91,
            DRK = 95,
            RNG = 95,
            RUN = 95
        },
        special_notes = "Requires 'Martial Mastery' quest. fTP-replicating weapon skill. Attack modifier: +10%. Merits: 73% STR@1/5, +3% per merit, 85% STR@5/5. Can only be used as main job."
    },

    ['Onslaught'] = {
        description = 'Lowers accuracy. Aftermath varies.',
        type = 'Physical',
        mods = {DEX = 80},
        hits = 1,
        element = nil,
        skillchain = {'Darkness', 'Gravitation'},
        ftp = {[1000] = 4.275, [2000] = 4.275, [3000] = 4.275},
        skill_required = 357,
        jobs = {
            BST = 75, -- via Ogre Killer or Guttler
            -- Level 85 via Cleofun Axe
        },
        special_notes = 'Ogre Killer/Guttler: BST level 75. Cleofun Axe: BST level 85. Accuracy -30 on target. Aftermath: Attack+ for 20s@1000TP / 40s@2000TP / 60s@3000TP. Guttler level 90+: +25-40% damage bonus. Only Ogre Killer/Guttler grant Relic Aftermath.'
    },

    ['Cloudsplitter'] = {
        description = 'Lightning elemental. Varies with TP.',
        type = 'Magical',
        mods = {STR = 40, MND = 40},
        hits = 1,
        element = 'Thunder',
        skillchain = {'Darkness', 'Fragmentation'},
        ftp = {[1000] = 3.75, [2000] = 6.69921875, [3000] = 8.5},
        skill_required = 357,
        jobs = {
            WAR = 85,
            BST = 85
        },
        special_notes = "Requires 'Kupofried's Weapon Skill Moogle Magic' quest. Can only be used with WAR/BST as main job. Boosts magic accuracy significantly. No dSTAT term. Farsha: Empyrean Aftermath."
    },

    ['Primal Rend'] = {
        description = 'Light elemental. Varies with TP.',
        type = 'Magical',
        mods = {DEX = 30, CHR = 60},
        hits = 1,
        element = 'Light',
        skillchain = {'Gravitation', 'Reverberation'},
        ftp = {[1000] = 3.0625, [2000] = 5.8359375, [3000] = 7.5625},
        skill_required = 357,
        jobs = {
            BST = 75
        },
        special_notes = "Requires 'Unlocking a Myth (Beastmaster)' quest. Can only be used with BST as main job. Damage formula: (pCHR-mINT)×1.5. Aymur: +15-30% damage bonus."
    },

    ---========================================================================
    --- PRIME WEAPON SKILLS
    ---========================================================================

    ['Blitz'] = {
        description = 'Five hits. Damage varies with TP.',
        type = 'Physical',
        mods = {STR = 32, DEX = 32},
        hits = 5,
        element = nil,
        skillchain = {'Liquefaction', 'Impaction', 'Fragmentation'},
        ftp = {[1000] = 1.5, [2000] = 7.0, [3000] = 12.5},
        skill_required = 1,
        jobs = {
            BST = 99
        },
        special_notes = 'Requires Spalirisos (Level 119/119 II/119 III). Prime weapon skill with Prime Aftermath (Physical Damage Limit+ including pets).'
    }
}

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function axe_ws.get_ws_data(ws_name)
    return axe_ws.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (WAR, BST, DRK, RNG, RUN, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function axe_ws.can_use(ws_name, job_code, level)
    local ws_data = axe_ws.weaponskills[ws_name]
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
function axe_ws.get_jobs_for_ws(ws_name)
    local ws_data = axe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function axe_ws.get_ws_type(ws_name)
    local ws_data = axe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function axe_ws.get_ws_element(ws_name)
    local ws_data = axe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function axe_ws.get_skillchain_properties(ws_name)
    local ws_data = axe_ws.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function axe_ws.get_ftp(ws_name, tp)
    local ws_data = axe_ws.weaponskills[ws_name]
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

return axe_ws

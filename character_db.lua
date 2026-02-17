---============================================================================
--- Character Database - Maps characters to their active jobs
---============================================================================
--- Central registry used by the clone system to determine which jobs,
--- sets, and configs belong to each character.
---
--- Usage (Lua):
---   local CharDB = require('character_db')
---   local jobs = CharDB.get_jobs('Kaories')      -- {'RDM','COR','GEO'}
---   local owner = CharDB.get_owner('BLM')         -- 'Tetsouo'
---   local is_rdm = CharDB.has_job('Kaories','RDM') -- true
---
--- Usage (Python - clone_character.py):
---   Parsed via regex from CHARACTERS table below.
---
--- Master data location:
---   _master/sets/[job]_sets.lua    - Equipment sets (15 jobs)
---   _master/config/[job]/          - Job configs (14 jobs, PUP has no config)
---
--- @file    character_db.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    2026-02-16
---============================================================================

local CharDB = {}

---============================================================================
--- CHARACTER DEFINITIONS
---============================================================================
--- Each character maps to a list of job abbreviations they actually play.
--- Jobs not assigned to any character go to _archive.

local CHARACTERS = {
    ---------------------------------------------------------------------------
    -- MAIN CHARACTER
    ---------------------------------------------------------------------------
    Tetsouo = {
        jobs = { 'BLM', 'BRD', 'BST', 'DNC', 'PLD', 'THF', 'WAR' },
        role = 'main',
    },

    ---------------------------------------------------------------------------
    -- ALT CHARACTER
    ---------------------------------------------------------------------------
    Kaories = {
        jobs = { 'RDM', 'COR', 'GEO' },
        role = 'alt',
    },
}

---============================================================================
--- ARCHIVE - Jobs nobody currently plays
---============================================================================
--- These are preserved but not cloned to any active character.
--- Move a job from _archive to a character entry above to re-activate it.

local ARCHIVE_JOBS = { 'DRK', 'PUP', 'RUN', 'SAM', 'WHM' }

---============================================================================
--- MASTER DATA PATHS (relative to data/ directory)
---============================================================================
--- Central storage for all job sets and configs.
--- The clone script copies FROM here into each character's directory.

local MASTER = {
    sets_dir   = '_master/sets',       -- [job]_sets.lua files
    config_dir = '_master/config',     -- [job]/ directories with STATES, KEYBINDS, etc.
}

---============================================================================
--- ALL SUPPORTED JOBS (for validation)
---============================================================================

local ALL_JOBS = {
    'BLM', 'BRD', 'BST', 'COR', 'DNC', 'DRK', 'GEO',
    'PLD', 'PUP', 'RDM', 'RUN', 'SAM', 'THF', 'WAR', 'WHM',
}

---============================================================================
--- PUBLIC API
---============================================================================

--- Get the job list for a character (case-insensitive lookup)
--- @param name string Character name
--- @return table|nil List of job abbreviations, or nil if unknown character
function CharDB.get_jobs(name)
    for char_name, data in pairs(CHARACTERS) do
        if char_name:lower() == name:lower() then
            return data.jobs
        end
    end
    return nil
end

--- Get the character role ('main' or 'alt')
--- @param name string Character name
--- @return string|nil Role string, or nil if unknown
function CharDB.get_role(name)
    for char_name, data in pairs(CHARACTERS) do
        if char_name:lower() == name:lower() then
            return data.role
        end
    end
    return nil
end

--- Check if a character has a specific job
--- @param name string Character name
--- @param job string Job abbreviation (e.g. 'RDM')
--- @return boolean
function CharDB.has_job(name, job)
    local jobs = CharDB.get_jobs(name)
    if not jobs then return false end
    local j = job:upper()
    for _, v in ipairs(jobs) do
        if v == j then return true end
    end
    return false
end

--- Find which character owns a given job
--- @param job string Job abbreviation (e.g. 'BLM')
--- @return string|nil Character name, or '_archive', or nil
function CharDB.get_owner(job)
    local j = job:upper()
    for char_name, data in pairs(CHARACTERS) do
        for _, v in ipairs(data.jobs) do
            if v == j then return char_name end
        end
    end
    for _, v in ipairs(ARCHIVE_JOBS) do
        if v == j then return '_archive' end
    end
    return nil
end

--- Get all archived (unplayed) jobs
--- @return table List of archived job abbreviations
function CharDB.get_archive_jobs()
    return ARCHIVE_JOBS
end

--- Get all known character names
--- @return table List of character name strings
function CharDB.get_character_names()
    local names = {}
    for name, _ in pairs(CHARACTERS) do
        names[#names + 1] = name
    end
    return names
end

--- Get the full CHARACTERS table (for clone script parsing)
--- @return table The raw characters table
function CharDB.get_all()
    return CHARACTERS
end

--- Get the complete job list (for validation)
--- @return table All 15 supported job abbreviations
function CharDB.get_all_jobs()
    return ALL_JOBS
end

--- Get master data paths
--- @return table { sets_dir, config_dir }
function CharDB.get_master_paths()
    return MASTER
end

--- Validate database integrity (no duplicates, no missing jobs)
--- @return boolean, string True if valid, or false + error message
function CharDB.validate()
    local assigned = {}

    -- Check character jobs
    for char_name, data in pairs(CHARACTERS) do
        for _, job in ipairs(data.jobs) do
            if assigned[job] then
                return false, job .. ' assigned to both ' .. assigned[job] .. ' and ' .. char_name
            end
            assigned[job] = char_name
        end
    end

    -- Check archive jobs
    for _, job in ipairs(ARCHIVE_JOBS) do
        if assigned[job] then
            return false, job .. ' is in both _archive and ' .. assigned[job]
        end
        assigned[job] = '_archive'
    end

    -- Check all jobs are accounted for
    for _, job in ipairs(ALL_JOBS) do
        if not assigned[job] then
            return false, job .. ' is not assigned to any character or _archive'
        end
    end

    return true, 'OK - all 15 jobs assigned'
end

return CharDB

---============================================================================
--- Universal Job Ability Database - Smart Loading (Main + Sub Only)
---============================================================================
--- Loads only the JA databases for current main job and subjob.
--- Reduces load time from ~76ms (21 jobs) to ~7ms (2 jobs).
---
--- This eliminates the subjob problem:
---   • WAR/SAM can display Third Eye messages (from SAM_JA_DATABASE)
---   • PLD/WAR can display Provoke messages (from WAR_JA_DATABASE)
---   • Any job combination gets full JA coverage
---
--- Architecture:
---   • Individual databases remain separate (easy to maintain)
---   • Only loads main + sub job databases (2 instead of 21)
---   • JobChangeManager reloads GearSwap on job change = fresh load
---
--- @file    UNIVERSAL_JA_DATABASE.lua
--- @author  Tetsouo
--- @version 2.0 - Smart Loading (main+sub only)
--- @date    Created: 2025-10-29 | Updated: 2025-11-27
--- @see     shared/data/job_abilities/README.md
---============================================================================

local UNIVERSAL_JA_DB = {}

---============================================================================
--- SMART JOB DETECTION
---============================================================================

--- Get current main job and subjob from player data
--- @return string, string main_job, sub_job (uppercase 3-letter codes)
local function get_current_jobs()
    local main_job = nil
    local sub_job = nil

    -- Try GearSwap's player global first
    if player and player.main_job then
        main_job = player.main_job:upper()
        sub_job = player.sub_job and player.sub_job:upper() or nil
    -- Fallback to windower.ffxi.get_player()
    elseif windower and windower.ffxi and windower.ffxi.get_player then
        local p = windower.ffxi.get_player()
        if p then
            main_job = p.main_job and p.main_job:upper() or nil
            sub_job = p.sub_job and p.sub_job:upper() or nil
        end
    end

    return main_job, sub_job
end

---============================================================================
--- LOAD ONLY MAIN + SUB JOB DATABASES
---============================================================================

local main_job, sub_job = get_current_jobs()

-- Track loaded jobs for debugging
local loaded_jobs = {}

--- Load a single job database and merge into universal
--- @param job string Job code (e.g., "WAR", "BLM")
local function load_job_database(job)
    if not job then return end

    local success, job_db = pcall(require, 'shared/data/job_abilities/' .. job .. '_JA_DATABASE')
    if success and job_db then
        -- Merge job database into universal
        for ability_name, description in pairs(job_db) do
            UNIVERSAL_JA_DB[ability_name] = description
        end
        table.insert(loaded_jobs, job)
    end
end

-- Load main job database
load_job_database(main_job)

-- Load subjob database (if different from main)
if sub_job and sub_job ~= main_job then
    load_job_database(sub_job)
end

-- PROFILING: Show what was loaded (only if profiling enabled)
if _G.PERFORMANCE_PROFILING and _G.PERFORMANCE_PROFILING.enabled then
    local jobs_str = table.concat(loaded_jobs, '+') or 'none'
    add_to_chat(158, string.format('[PERF] JA_DB loaded: %s (2 jobs max instead of 21)', jobs_str))
end

return UNIVERSAL_JA_DB

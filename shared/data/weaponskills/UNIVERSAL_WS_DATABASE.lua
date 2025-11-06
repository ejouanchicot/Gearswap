---============================================================================
--- Universal Weapon Skills Database - Complete Integration
---============================================================================
--- Automatically merges all 12 weapon-specific WS databases into one universal
--- database for easy lookup and display.
---
--- Pattern: Same as UNIVERSAL_JA_DATABASE
---   1. Individual weapon databases maintained separately (easy editing)
---   2. Universal database auto-merges all at runtime
---   3. PRECAST modules use universal database for WS validation & display
---
--- Database Coverage:
---   • SWORD (22 WS)
---   • DAGGER (18 WS) ← NEW!
---   • H2H (17 WS)
---   • GREATSWORD (15 WS)
---   • GREATAXE (18 WS)
---   • AXE (15 WS)
---   • SCYTHE (15 WS)
---   • POLEARM (15 WS)
---   • KATANA (15 WS)
---   • GREATKATANA (15 WS)
---   • STAFF (18 WS)
---   • CLUB (17 WS)
---   • ARCHERY (12 WS)
---   TOTAL: 212 Weapon Skills
---
--- @file UNIVERSAL_WS_DATABASE.lua
--- @author Tetsouo
--- @version 2.2 - Dagger Integration (212 WS)
--- @date Created: 2025-10-29
--- @date Updated: 2025-11-04 - All 13 weapon types integrated
--- @source All data verified 300% against BG-Wiki
---============================================================================

local UniversalWS = {}
UniversalWS.weaponskills = {}
UniversalWS.weapon_types = {}

---============================================================================
--- WEAPON TYPE CONFIGURATION
---============================================================================

-- List of all weapon types with databases (in load order)
local weapon_type_configs = {
    {file = 'SWORD_WS_DATABASE',       type = 'Sword',        count = 22},
    {file = 'DAGGER_WS_DATABASE',      type = 'Dagger',       count = 18},
    {file = 'H2H_WS_DATABASE',         type = 'Hand-to-Hand', count = 17},
    {file = 'GREATSWORD_WS_DATABASE',  type = 'Great Sword',  count = 15},
    {file = 'GREATAXE_WS_DATABASE',    type = 'Great Axe',    count = 18},
    {file = 'AXE_WS_DATABASE',         type = 'Axe',          count = 15},
    {file = 'SCYTHE_WS_DATABASE',      type = 'Scythe',       count = 15},
    {file = 'POLEARM_WS_DATABASE',     type = 'Polearm',      count = 15},
    {file = 'KATANA_WS_DATABASE',      type = 'Katana',       count = 15},
    {file = 'GREATKATANA_WS_DATABASE', type = 'Great Katana', count = 15},
    {file = 'STAFF_WS_DATABASE',       type = 'Staff',        count = 18},
    {file = 'CLUB_WS_DATABASE',        type = 'Club',         count = 17},
    {file = 'ARCHERY_WS_DATABASE',     type = 'Archery',      count = 12}
}

---============================================================================
--- AUTO-MERGE ALL WEAPON DATABASES
---============================================================================

local total_loaded = 0
local failed_loads = {}

for _, config in ipairs(weapon_type_configs) do
    local success, weapon_db = pcall(require, 'shared/data/weaponskills/' .. config.file)

    if success and weapon_db and weapon_db.weaponskills then
        local ws_count = 0

        -- Merge all weapon skills from this weapon type
        for ws_name, ws_data in pairs(weapon_db.weaponskills) do
            -- Add weapon type metadata to each WS
            ws_data.weapon_type = config.type
            ws_data.weapon_file = config.file

            -- Add to universal database at ROOT LEVEL (for job compatibility)
            -- Jobs access like: WS_DB['Fast Blade'] not WS_DB.weaponskills['Fast Blade']
            UniversalWS[ws_name] = ws_data

            -- Also add to .weaponskills table (for helper functions)
            UniversalWS.weaponskills[ws_name] = ws_data
            ws_count = ws_count + 1
        end

        -- Track weapon type
        UniversalWS.weapon_types[config.type] = {
            file = config.file,
            count = ws_count,
            expected = config.count
        }

        total_loaded = total_loaded + ws_count

    else
        -- Track failed loads
        table.insert(failed_loads, {
            file = config.file,
            type = config.type,
            error = weapon_db or "Unknown error"
        })
    end
end

-- Store load statistics
UniversalWS.load_stats = {
    total_loaded = total_loaded,
    expected_total = 212,
    weapon_type_count = #weapon_type_configs,
    failed_loads = failed_loads,
    load_date = os.date("%Y-%m-%d %H:%M:%S")
}

---============================================================================
--- HELPER FUNCTIONS - Universal WS Lookup
---============================================================================

--- Get weapon skill data by name
--- @param ws_name string The weapon skill name
--- @return table|nil Weapon skill data or nil if not found
function UniversalWS.get_ws_data(ws_name)
    return UniversalWS.weaponskills[ws_name]
end

--- Check if a job can use a weapon skill at a given level
--- @param ws_name string The weapon skill name
--- @param job_code string Job code (WAR, MNK, WHM, etc.)
--- @param level number Character level
--- @return boolean True if job can use WS at level
function UniversalWS.can_use(ws_name, job_code, level)
    local ws_data = UniversalWS.weaponskills[ws_name]
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
function UniversalWS.get_jobs_for_ws(ws_name)
    local ws_data = UniversalWS.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.jobs
end

--- Get weapon skill type (Physical/Magical/Hybrid)
--- @param ws_name string The weapon skill name
--- @return string|nil Type or nil if not found
function UniversalWS.get_ws_type(ws_name)
    local ws_data = UniversalWS.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.type
end

--- Get weapon skill element
--- @param ws_name string The weapon skill name
--- @return string|nil Element or nil if not found/non-elemental
function UniversalWS.get_ws_element(ws_name)
    local ws_data = UniversalWS.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.element
end

--- Get weapon skill skillchain properties
--- @param ws_name string The weapon skill name
--- @return table|nil Array of skillchain properties or nil if not found
function UniversalWS.get_skillchain_properties(ws_name)
    local ws_data = UniversalWS.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.skillchain
end

--- Get fTP value for a weapon skill at specific TP
--- @param ws_name string The weapon skill name
--- @param tp number TP value (1000/2000/3000)
--- @return number|nil fTP value or nil if not found
function UniversalWS.get_ftp(ws_name, tp)
    local ws_data = UniversalWS.weaponskills[ws_name]
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

--- Get weapon type for a weapon skill
--- @param ws_name string The weapon skill name
--- @return string|nil Weapon type (Sword, Katana, etc.) or nil if not found
function UniversalWS.get_weapon_type(ws_name)
    local ws_data = UniversalWS.weaponskills[ws_name]
    if not ws_data then
        return nil
    end

    return ws_data.weapon_type
end

--- Get all weapon skills for a specific weapon type
--- @param weapon_type string Weapon type (Sword, Katana, etc.)
--- @return table Array of {ws_name, ws_data} or empty table
function UniversalWS.get_ws_by_weapon_type(weapon_type)
    local result = {}

    for ws_name, ws_data in pairs(UniversalWS.weaponskills) do
        if ws_data.weapon_type == weapon_type then
            table.insert(result, {name = ws_name, data = ws_data})
        end
    end

    return result
end

--- Get all weapon skills available to a specific job
--- @param job_code string Job code (WAR, MNK, WHM, etc.)
--- @param level number Character level
--- @return table Array of {ws_name, ws_data, required_level} or empty table
function UniversalWS.get_ws_by_job(job_code, level)
    local result = {}

    for ws_name, ws_data in pairs(UniversalWS.weaponskills) do
        if ws_data.jobs and ws_data.jobs[job_code] then
            local required_level = ws_data.jobs[job_code]
            if level >= required_level then
                table.insert(result, {
                    name = ws_name,
                    data = ws_data,
                    required_level = required_level
                })
            end
        end
    end

    return result
end

--- Search weapon skills by partial name match (case-insensitive)
--- @param search_term string Search term
--- @return table Array of matching WS names
function UniversalWS.search_ws(search_term)
    local result = {}
    local search_lower = search_term:lower()

    for ws_name, _ in pairs(UniversalWS.weaponskills) do
        if ws_name:lower():find(search_lower, 1, true) then
            table.insert(result, ws_name)
        end
    end

    return result
end

--- Get database load statistics
--- @return table Load statistics with counts and status
function UniversalWS.get_load_stats()
    return UniversalWS.load_stats
end

--- Print database load summary to chat
function UniversalWS.print_load_summary()
    local stats = UniversalWS.load_stats

    add_to_chat(001, '========================================')
    add_to_chat(001, 'Universal WS Database - Load Summary')
    add_to_chat(001, '========================================')
    add_to_chat(001, string.format('Loaded: %d / %d weapon skills', stats.total_loaded, stats.expected_total))
    add_to_chat(001, string.format('Weapon Types: %d databases', stats.weapon_type_count))
    add_to_chat(001, string.format('Load Date: %s', stats.load_date))

    if #stats.failed_loads > 0 then
        add_to_chat(167, string.format('Failed Loads: %d', #stats.failed_loads))
        for _, failure in ipairs(stats.failed_loads) do
            add_to_chat(167, string.format('  - %s (%s)', failure.file, failure.type))
        end
    end

    add_to_chat(001, '========================================')

    -- Print weapon type breakdown
    add_to_chat(001, 'Weapon Type Breakdown:')
    for weapon_type, info in pairs(UniversalWS.weapon_types) do
        local status = (info.count == info.expected) and '✓' or '✗'
        add_to_chat(001, string.format('  %s %s: %d WS', status, weapon_type, info.count))
    end
    add_to_chat(001, '========================================')
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return UniversalWS

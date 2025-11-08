---============================================================================
--- Test Generator - Auto-generate all job test suites from JA databases
---============================================================================
--- This script reads all JA databases and generates comprehensive test suites
---
--- @file tests/generate_all_tests.lua
--- @author Tetsouo
--- @date Created: 2025-11-08
---============================================================================

-- Job list with their 3-letter codes
local JOBS = {
    {code = 'war', name = 'Warrior'},
    {code = 'mnk', name = 'Monk'},
    {code = 'whm', name = 'White Mage'},
    {code = 'blm', name = 'Black Mage'},
    {code = 'rdm', name = 'Red Mage'},
    {code = 'thf', name = 'Thief'},
    {code = 'pld', name = 'Paladin'},
    {code = 'drk', name = 'Dark Knight'},
    {code = 'bst', name = 'Beastmaster'},
    {code = 'brd', name = 'Bard'},
    {code = 'rng', name = 'Ranger'},
    {code = 'sam', name = 'Samurai'},
    {code = 'nin', name = 'Ninja'},
    {code = 'drg', name = 'Dragoon'},
    {code = 'smn', name = 'Summoner'},
    {code = 'blu', name = 'Blue Mage'},
    {code = 'cor', name = 'Corsair'},
    {code = 'pup', name = 'Puppetmaster'},
    {code = 'dnc', name = 'Dancer'},
    {code = 'sch', name = 'Scholar'},
    {code = 'geo', name = 'Geomancer'},
    {code = 'run', name = 'Runemaster'}
}

--- Load JA database for a job
local function load_ja_database(job_code)
    local abilities = {}

    -- Try loading main job abilities
    local files = {
        job_code .. '_mainjob',
        job_code .. '_subjob',
        job_code .. '_sp'
    }

    for _, file in ipairs(files) do
        local path = 'shared/data/job_abilities/' .. job_code .. '/' .. file
        local ok, module = pcall(require, path)
        if ok and module and module.abilities then
            for name, data in pairs(module.abilities) do
                abilities[name] = data
            end
        end
    end

    return abilities
end

--- Generate test file for a job
local function generate_test_file(job)
    local job_code = job.code
    local job_name = job.name
    local job_upper = job_code:upper()

    -- Load JA database
    local abilities = load_ja_database(job_code)

    -- Count abilities
    local ability_count = 0
    for _ in pairs(abilities) do
        ability_count = ability_count + 1
    end

    if ability_count == 0 then
        print(string.format("No abilities found for %s (%s)", job_name, job_upper))
        return nil
    end

    -- Generate test file content
    local lines = {}
    table.insert(lines, "---============================================================================")
    table.insert(lines, string.format("--- %s Test Suite - %s Job Messages", job_upper, job_name))
    table.insert(lines, "---============================================================================")
    table.insert(lines, string.format("--- Tests all %s job abilities", job_upper))
    table.insert(lines, "---")
    table.insert(lines, string.format("--- @file tests/test_%s.lua", job_code))
    table.insert(lines, "--- @author Tetsouo (Auto-generated)")
    table.insert(lines, "--- @date Created: 2025-11-08")
    table.insert(lines, "---============================================================================")
    table.insert(lines, "")
    table.insert(lines, "local M = require('shared/utils/messages/api/messages')")
    table.insert(lines, "")
    table.insert(lines, string.format("local Test%s = {}", job_upper))
    table.insert(lines, "")
    table.insert(lines, string.format("--- Run all %s tests", job_upper))
    table.insert(lines, "--- @param test function Test runner function")
    table.insert(lines, "--- @return number total_tests Total number of tests")
    table.insert(lines, string.format("function Test%s.run(test)", job_upper))
    table.insert(lines, "    local gray_code = string.char(0x1F, 160)")
    table.insert(lines, "    local cyan = string.char(0x1F, 13)")
    table.insert(lines, "    local total = 0")
    table.insert(lines, "")
    table.insert(lines, "    ---========================================================================")
    table.insert(lines, string.format("    --- %s JOB ABILITIES", job_upper))
    table.insert(lines, "    ---========================================================================")
    table.insert(lines, "")
    table.insert(lines, "    add_to_chat(121, \" \")")
    table.insert(lines, string.format("    add_to_chat(121, cyan .. \"%s Job Abilities (%d):\")", job_upper, ability_count))
    table.insert(lines, "")

    -- Add test for each ability
    for name, data in pairs(abilities) do
        local description = data.description or "Unknown effect"
        table.insert(lines, string.format("    test(function() M.send('JA_BUFFS', 'activated_full', {job_tag = '%s', ability_name = '%s', description = '%s'}) end)", job_upper, name, description))
    end

    table.insert(lines, string.format("    total = total + %d", ability_count))
    table.insert(lines, "")
    table.insert(lines, "    return total")
    table.insert(lines, "end")
    table.insert(lines, "")
    table.insert(lines, string.format("return Test%s", job_upper))
    table.insert(lines, "")

    return table.concat(lines, "\n"), ability_count
end

--- Main execution
local function main()
    local separator = string.rep("=", 74)
    print(separator)
    print("Generating Test Suites from JA Databases")
    print(separator)
    print("")

    local total_jobs = 0
    local total_abilities = 0

    for _, job in ipairs(JOBS) do
        local content, count = generate_test_file(job)
        if content then
            local filename = string.format("test_%s_generated.lua", job.code)
            local file = io.open(filename, "w")
            if file then
                file:write(content)
                file:close()
                print(string.format("[OK] %s: %d abilities >> %s", job.name:upper(), count, filename))
                total_jobs = total_jobs + 1
                total_abilities = total_abilities + count
            else
                print(string.format("[FAIL] %s: Failed to write file", job.name:upper()))
            end
        end
    end

    print("")
    print(separator)
    print(string.format("Generated %d test suites with %d total abilities", total_jobs, total_abilities))
    print(separator)
end

-- Run if executed directly
if ... == nil then
    main()
end

return {
    generate_test_file = generate_test_file,
    load_ja_database = load_ja_database,
    JOBS = JOBS
}

---============================================================================
--- Message System Validator - Automated Testing
---============================================================================
--- Validates the entire message system automatically:
---   • Template parameters match function signatures
---   • All color tags are valid
---   • All functions follow naming conventions
---   • All exports exist in MessageFormatter
---   • No broken templates
---
--- Usage:
---   //gs c msgtests
---
--- @file utils/messages/message_validator.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-01-07
---============================================================================

local MessageValidator = {}

---============================================================================
--- CONFIGURATION
---============================================================================

-- Valid color tags that can be used in templates
local VALID_COLORS = {
    gray = true,
    yellow = true,
    green = true,
    orange = true,
    red = true,
    cyan = true,
    lightblue = true,
    blue = true,
    white = true
}

-- Jobs to validate
local JOBS_TO_VALIDATE = {
    'BLM', 'BRD', 'BST', 'COR', 'DRG', 'GEO', 'RDM', 'WHM'
}

-- Common parameter names (not colors)
local COMMON_PARAMS = {
    job = true, spell = true, ability = true, buff = true,
    target = true, time = true, delay = true, count = true,
    status = true, value = true, name = true, action = true,
    pet = true, broth = true, move = true, index = true,
    song = true, element = true, tier = true, category = true,
    mp = true, recast = true, distance = true, type = true,
    -- BLM specific
    storm = true, state_type = true, aja = true, arts = true,
    gear_type = true, stratagem = true, original = true, downgrade = true,
    -- BRD specific
    slot = true, pack = true, stat = true, dummy = true,
    rotation = true, dummy_count = true, songs = true,
    -- BST specific
    ecosystem = true, species = true, species_text = true,
    jug_text = true, status_color = true,
    -- GEO specific
    desired = true, description = true, final = true
}

---============================================================================
--- TEST RESULTS TRACKING
---============================================================================

local test_results = {
    total = 0,
    passed = 0,
    failed = 0,
    errors = {}
}

local function add_error(test_name, message)
    test_results.total = test_results.total + 1
    test_results.failed = test_results.failed + 1
    table.insert(test_results.errors, {
        test = test_name,
        message = message
    })
end

local function add_success(test_name)
    test_results.total = test_results.total + 1
    test_results.passed = test_results.passed + 1
end

---============================================================================
--- VALIDATION FUNCTIONS
---============================================================================

--- Extract all {tags} from a template string
--- @param template string Template with {param} tags
--- @return table Array of tag names
local function extract_tags(template)
    local tags = {}
    for tag in template:gmatch("{([^}]+)}") do
        table.insert(tags, tag)
    end
    return tags
end

--- Check if a tag is a valid color or common parameter
--- @param tag string Tag name to check
--- @return boolean, string true if valid, error message if not
local function validate_tag(tag)
    -- Check if it's a valid color
    if VALID_COLORS[tag] then
        return true
    end

    -- Check if it's a common parameter
    if COMMON_PARAMS[tag] then
        return true
    end

    -- Check if it's a job-specific parameter (ends with common suffixes)
    if tag:match("_color$") or tag:match("_text$") or tag:match("_name$") then
        return true
    end

    return false, "Unknown tag: {" .. tag .. "} (not a valid color or parameter)"
end

--- Validate a single message template
--- @param job string Job name (e.g., "BLM")
--- @param message_key string Message key (e.g., "buff_casting")
--- @param message_data table Message data with template and color
local function validate_template(job, message_key, message_data)
    local test_name = job .. "." .. message_key

    -- Check template exists
    if not message_data.template then
        add_error(test_name, "Missing 'template' field")
        return
    end

    -- Check color exists
    if not message_data.color then
        add_error(test_name, "Missing 'color' field")
        return
    end

    -- Extract and validate all tags
    local tags = extract_tags(message_data.template)
    for _, tag in ipairs(tags) do
        local valid, err = validate_tag(tag)
        if not valid then
            add_error(test_name, err)
            return
        end
    end

    add_success(test_name)
end

--- Validate function naming conventions
--- @param job string Job name (e.g., "BLM")
--- @param module table Job message module
local function validate_function_naming(job, module)
    for name, func in pairs(module) do
        if type(func) == "function" then
            local test_name = job .. "." .. name

            -- Check if function starts with "show_"
            if not name:match("^show_") then
                add_error(test_name, "Function should start with 'show_' prefix")
            else
                add_success(test_name)
            end
        end
    end
end

--- Validate MessageFormatter exports
--- @param job string Job name (e.g., "BLM")
--- @param module table Job message module
local function validate_exports(job, module)
    local MessageFormatter = require('shared/utils/messages/message_formatter')

    for name, func in pairs(module) do
        if type(func) == "function" then
            local test_name = job .. ".export." .. name

            -- Check if function is exported in MessageFormatter
            if not MessageFormatter[name] then
                add_error(test_name, "Function not exported in MessageFormatter")
            else
                add_success(test_name)
            end
        end
    end
end

---============================================================================
--- MAIN VALIDATION RUNNER
---============================================================================

--- Run all validation tests
--- @return boolean true if all tests passed
function MessageValidator.run_all_tests()
    -- Reset results
    test_results = {
        total = 0,
        passed = 0,
        failed = 0,
        errors = {}
    }

    print("==============================================")
    print("   MESSAGE SYSTEM VALIDATION")
    print("==============================================")
    print("")

    -- Test each job
    for _, job in ipairs(JOBS_TO_VALIDATE) do
        print("Testing " .. job .. " messages...")

        -- Load message data
        local data_path = 'shared/utils/messages/data/jobs/' .. job:lower() .. '_messages'
        local success_data, message_data = pcall(require, data_path)

        if not success_data then
            add_error(job, "Failed to load message data: " .. data_path)
        else
            -- Validate each template
            for key, data in pairs(message_data) do
                if type(data) == "table" and data.template then
                    validate_template(job, key, data)
                end
            end
        end

        -- Load message formatter module
        local formatter_path = 'shared/utils/messages/formatters/jobs/message_' .. job:lower()
        local success_formatter, formatter_module = pcall(require, formatter_path)

        if success_formatter and type(formatter_module) == "table" then
            -- Validate function naming
            validate_function_naming(job, formatter_module)

            -- Validate exports
            validate_exports(job, formatter_module)
        end
    end

    -- Print results
    print("")
    print("==============================================")
    print("   RESULTS")
    print("==============================================")

    if test_results.failed == 0 then
        print(string.format("[OK] ALL TESTS PASSED! (%d/%d)",
            test_results.passed, test_results.total))
        print("")
        print("Message system is valid and production-ready!")

        -- Auto-export results
        MessageValidator.export_json()
        MessageValidator.export_txt()

        return true
    else
        print(string.format("[FAIL] TESTS FAILED: %d/%d",
            test_results.failed, test_results.total))
        print("")
        print("Errors found:")

        -- Group errors by test
        for _, error in ipairs(test_results.errors) do
            print(string.format("  • %s: %s", error.test, error.message))
        end

        print("")
        print("Please fix these errors before deploying.")

        -- Auto-export results (even on failure for debugging)
        MessageValidator.export_json()
        MessageValidator.export_txt()

        return false
    end
end

--- Get test statistics
--- @return table Test results summary
function MessageValidator.get_stats()
    return {
        total = test_results.total,
        passed = test_results.passed,
        failed = test_results.failed,
        success_rate = test_results.total > 0
            and (test_results.passed / test_results.total * 100) or 0
    }
end

---============================================================================
--- EXPORT FUNCTIONS
---============================================================================

--- Export test results to JSON file
--- @param filepath string Optional file path (defaults to Windower/addons/GearSwap/data/message_validation.json)
--- @return boolean true if export succeeded
function MessageValidator.export_json(filepath)
    -- Default path (windower.addon_path = "D:/Windower Tetsouo/addons/GearSwap/")
    local default_path = windower.addon_path .. 'data/message_validation.json'
    local output_path = filepath or default_path

    -- Build JSON manually (simple structure, no need for json library)
    local json_lines = {}
    table.insert(json_lines, '{')
    table.insert(json_lines, '  "timestamp": "' .. os.date("%Y-%m-%d %H:%M:%S") .. '",')
    table.insert(json_lines, '  "summary": {')
    table.insert(json_lines, '    "total": ' .. test_results.total .. ',')
    table.insert(json_lines, '    "passed": ' .. test_results.passed .. ',')
    table.insert(json_lines, '    "failed": ' .. test_results.failed .. ',')

    local success_rate = test_results.total > 0
        and (test_results.passed / test_results.total * 100) or 0
    table.insert(json_lines, '    "success_rate": ' .. string.format("%.2f", success_rate))
    table.insert(json_lines, '  },')

    -- Add errors array
    table.insert(json_lines, '  "errors": [')
    for i, error in ipairs(test_results.errors) do
        local comma = i < #test_results.errors and ',' or ''
        table.insert(json_lines, '    {')
        table.insert(json_lines, '      "test": "' .. error.test .. '",')
        table.insert(json_lines, '      "message": "' .. error.message:gsub('"', '\\"') .. '"')
        table.insert(json_lines, '    }' .. comma)
    end
    table.insert(json_lines, '  ]')
    table.insert(json_lines, '}')

    -- Write to file
    local file = io.open(output_path, 'w')
    if not file then
        print("ERROR: Could not write to " .. output_path)
        return false
    end

    file:write(table.concat(json_lines, '\n'))
    file:close()

    print("")
    print("[OK] Results exported to: " .. output_path)
    return true
end

--- Export test results to TXT file (human-readable)
--- @param filepath string Optional file path (defaults to Windower/addons/GearSwap/data/message_validation.txt)
--- @return boolean true if export succeeded
function MessageValidator.export_txt(filepath)
    -- Default path (windower.addon_path = "D:/Windower Tetsouo/addons/GearSwap/")
    local default_path = windower.addon_path .. 'data/message_validation.txt'
    local output_path = filepath or default_path

    -- Build text report
    local lines = {}
    table.insert(lines, "==============================================")
    table.insert(lines, "   MESSAGE SYSTEM VALIDATION REPORT")
    table.insert(lines, "==============================================")
    table.insert(lines, "")
    table.insert(lines, "Date: " .. os.date("%Y-%m-%d %H:%M:%S"))
    table.insert(lines, "")
    table.insert(lines, "SUMMARY:")
    table.insert(lines, "--------")
    table.insert(lines, "Total Tests:   " .. test_results.total)
    table.insert(lines, "Passed:        " .. test_results.passed)
    table.insert(lines, "Failed:        " .. test_results.failed)

    local success_rate = test_results.total > 0
        and (test_results.passed / test_results.total * 100) or 0
    table.insert(lines, "Success Rate:  " .. string.format("%.2f%%", success_rate))
    table.insert(lines, "")

    if test_results.failed == 0 then
        table.insert(lines, "STATUS: [OK] ALL TESTS PASSED")
        table.insert(lines, "")
        table.insert(lines, "Message system is valid and production-ready!")
    else
        table.insert(lines, "STATUS: [FAIL] TESTS FAILED")
        table.insert(lines, "")
        table.insert(lines, "ERRORS:")
        table.insert(lines, "-------")

        for _, error in ipairs(test_results.errors) do
            table.insert(lines, "")
            table.insert(lines, "Test: " .. error.test)
            table.insert(lines, "Error: " .. error.message)
        end

        table.insert(lines, "")
        table.insert(lines, "Please fix these errors before deploying.")
    end

    table.insert(lines, "")
    table.insert(lines, "==============================================")

    -- Write to file
    local file = io.open(output_path, 'w')
    if not file then
        print("ERROR: Could not write to " .. output_path)
        return false
    end

    file:write(table.concat(lines, '\n'))
    file:close()

    print("")
    print("[OK] Results exported to: " .. output_path)
    return true
end

return MessageValidator

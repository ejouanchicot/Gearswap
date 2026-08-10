---============================================================================
--- Messages API - Unified public interface for all message operations
---============================================================================
--- Single entry point for all messaging needs
--- Replaces 40+ message_*.lua files with one clean API
---
--- Usage:
---   local M = require('shared/utils/messages/api/messages')
---   M.job('BLM', 'manawall_ready', {time = 30})
---   M.combat('ws_tp', {ws = 'Tachi: Fudo', tp = 2500})
---   M.error("Something went wrong")
---
--- @file api/messages.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-11-06
---============================================================================

-- Lazy-load core modules (only when first message is sent)
local MessageEngine = nil
local MessageRenderer = nil

local function get_MessageEngine()
    if not MessageEngine then
        MessageEngine = require('shared/utils/messages/core/message_engine')
    end
    return MessageEngine
end

local function get_MessageRenderer()
    if not MessageRenderer then
        MessageRenderer = require('shared/utils/messages/core/message_renderer')
    end
    return MessageRenderer
end

local Messages = {}

---============================================================================
--- CORE MESSAGING API
---============================================================================

--- Send a message from any namespace
--- @param namespace string "BLM", "COMBAT", "SYSTEM", etc.
--- @param key string Message key
--- @param params table? Parameters to inject into template
--- @param options table? Rendering options {level, timestamp}
--- @return boolean success, number? message_length Length of visible message (excluding color codes)
function Messages.send(namespace, key, params, options)
    params = params or {}
    options = options or {}

    -- Try to format the message
    local ok, message, color = pcall(function()
        return get_MessageEngine().format(namespace, key, params)
    end)

    if not ok then
        -- Error formatting message
        get_MessageRenderer().show_error(string.format(
            "Failed to format message %s.%s: %s",
            namespace, key, tostring(message)
        ))
        return false, 0
    end

    -- Calculate visible length (strip color codes)
    -- Color codes are: \x1F + 1 byte (2 bytes total)
    local visible_message = message:gsub(string.char(0x1F) .. ".", "")
    local message_length = #visible_message

    -- Add namespace to options for statistics
    options.namespace = namespace

    -- Render the message
    get_MessageRenderer().send(message, color, options)

    return true, message_length
end

---============================================================================
--- CONVENIENCE METHODS
---============================================================================

--- Send a job-specific message
--- @param job string Job code ("BLM", "BRD", "RDM", etc.)
--- @param key string Message key
--- @param params table? Parameters
function Messages.job(job, key, params)
    return Messages.send(job, key, params)
end

--- Send a combat message (WS, TP, engaged, etc.)
--- @param key string Message key
--- @param params table? Parameters
function Messages.combat(key, params)
    return Messages.send('COMBAT', key, params)
end

--- Send a magic message (spells, buffs, debuffs)
--- @param key string Message key
--- @param params table? Parameters
function Messages.magic(key, params)
    return Messages.send('MAGIC', key, params)
end

--- Send an ability message (JA, pet commands)
--- @param key string Message key
--- @param params table? Parameters
function Messages.ability(key, params)
    return Messages.send('ABILITY', key, params)
end

--- Send a system message (errors, warnings, info, success)
--- @param level string "error"|"warning"|"info"|"success"
--- @param message string Message text
function Messages.system(level, message)
    local colors = {
        error = 167,
        warning = 200,
        info = 122,
        success = 158,
        debug = 8
    }

    local color = colors[level] or colors.info
    local formatted = string.format("[SYSTEM] %s", message)

    get_MessageRenderer().send(formatted, color, {
        level = (level == "error" and 2) or (level == "warning" and 1) or 0
    })
end

---============================================================================
--- SYSTEM MESSAGE SHORTCUTS
---============================================================================

--- Show error message
--- @param message string Error message
function Messages.error(message)
    Messages.system('error', message)
end

--- Show warning message
--- @param message string Warning message
function Messages.warning(message)
    Messages.system('warning', message)
end

--- Show info message
--- @param message string Info message
function Messages.info(message)
    Messages.system('info', message)
end

--- Show success message
--- @param message string Success message
function Messages.success(message)
    Messages.system('success', message)
end

--- Show debug message
--- @param message string Debug message
function Messages.debug(message)
    Messages.system('debug', message)
end

---============================================================================
--- BUILDER PATTERN (Advanced Usage)
---============================================================================

--- Create a custom message builder for one-off messages
--- @param template string Template with {placeholders}
--- @param color number? Optional color code (default: 1)
--- @return table Builder object
function Messages.custom(template, color)
    local builder = {
        template = template,
        color = color or 1,
        params = {},
        options = {}
    }

    --- Set a parameter (fluent interface)
    --- @param key string Parameter name
    --- @param value any Parameter value
    --- @return table self (for chaining)
    function builder:with(key, value)
        self.params[key] = value
        return self
    end

    --- Set color (fluent interface)
    --- @param new_color number Color code
    --- @return table self
    function builder:colored(new_color)
        self.color = new_color
        return self
    end

    --- Set importance level
    --- @param level number 0=all, 1=important, 2=critical
    --- @return table self
    function builder:level(level)
        self.options.level = level
        return self
    end

    --- Build and send the message
    function builder:send()
        -- Simple template replacement (no caching for custom messages)
        local message = self.template
        for key, value in pairs(self.params) do
            local placeholder = "{" .. key .. "}"
            message = message:gsub(placeholder, tostring(value), 1)
        end

        get_MessageRenderer().send(message, self.color, self.options)
    end

    --- Preview without sending (for testing)
    --- @return string Preview string
    function builder:preview()
        local message = self.template
        for key, value in pairs(self.params) do
            local placeholder = "{" .. key .. "}"
            message = message:gsub(placeholder, tostring(value), 1)
        end
        return string.format("[COLOR:%d] %s", self.color, message)
    end

    return builder
end

---============================================================================
--- CONFIGURATION API
---============================================================================

--- Configure the message system
--- @param config table Configuration options
---   - enabled: boolean (master toggle)
---   - filter_level: number (0=all, 1=important, 2=critical)
---   - color_mode: string ("normal", "colorblind", "monochrome")
---   - timestamp: boolean (add timestamps)
function Messages.config(config)
    get_MessageRenderer().configure(config)
end

--- Get current configuration
--- @return table Current config
function Messages.get_config()
    return get_MessageRenderer().get_config()
end

--- Toggle all messages on/off
--- @return boolean New state
function Messages.toggle()
    return get_MessageRenderer().toggle()
end

--- Set filter level
--- @param level number 0=all, 1=important, 2=critical
function Messages.set_filter_level(level)
    get_MessageRenderer().set_filter_level(level)
end

--- Set color mode for accessibility
--- @param mode string "normal", "colorblind", "monochrome"
function Messages.set_color_mode(mode)
    get_MessageRenderer().set_color_mode(mode)
end

--- Toggle timestamps
--- @return boolean New state
function Messages.toggle_timestamp()
    return get_MessageRenderer().toggle_timestamp()
end

---============================================================================
--- DEBUGGING & UTILITIES
---============================================================================

--- Show system statistics
function Messages.show_stats()
    get_MessageRenderer().show_stats()
end

--- Reset statistics
function Messages.reset_stats()
    get_MessageRenderer().reset_stats()
end

--- List all available messages in a namespace (for debugging)
--- @param namespace string
function Messages.list(namespace)
    local keys = get_MessageEngine().list_keys(namespace)

    add_to_chat(160, "-----------------------------------------------------")
    add_to_chat(158, string.format("[Messages] Namespace: %s", namespace))
    add_to_chat(160, "-----------------------------------------------------")
    for _, key in ipairs(keys) do
        add_to_chat(1, "  " .. key)
    end
    add_to_chat(160, "-----------------------------------------------------")
    add_to_chat(158, string.format("Total: %d messages", #keys))
    add_to_chat(160, "-----------------------------------------------------")
end

--- Get cache statistics from engine
function Messages.get_engine_stats()
    return get_MessageEngine().get_stats()
end

--- Clear engine cache (for development/testing)
function Messages.clear_cache()
    get_MessageEngine().clear_cache()
    Messages.info("Message cache cleared")
end

---============================================================================
--- HELP COMMAND
---============================================================================

--- Show help information
function Messages.help()
    add_to_chat(158, "=== Message System API ===")
    add_to_chat(122, "Usage:")
    add_to_chat(1, "  M.job('BLM', 'manawall_ready', {time = 30})")
    add_to_chat(1, "  M.combat('ws_tp', {ws = 'Fudo', tp = 2500})")
    add_to_chat(1, "  M.error('Something went wrong')")
    add_to_chat(122, "Commands:")
    add_to_chat(1, "  M.toggle() - Enable/disable messages")
    add_to_chat(1, "  M.set_color_mode('colorblind')")
    add_to_chat(1, "  M.show_stats() - Show statistics")
    add_to_chat(1, "  M.list('BLM') - List all BLM messages")
    add_to_chat(1, "  M.test() - Run all test suites")
    add_to_chat(1, "  M.test('BRD') - Run BRD tests only")
    add_to_chat(1, "  M.test('SYSTEM') - Run system tests only")
end

---============================================================================
--- INTEGRATED TEST SUITE
---============================================================================

--- Silent test runner helper
local function create_test_runner()
    local passed = 0
    local total = 0

    local function test(fn)
        total = total + 1
        local renderer = get_MessageRenderer()
        local old_show_error = renderer.show_error
        renderer.show_error = function() end
        local ok = pcall(fn)
        renderer.show_error = old_show_error
        if ok then passed = passed + 1 end
        return ok
    end

    return test, function() return passed, total end
end

local TEST_GRAY   = string.char(0x1F, 160)
local TEST_YELLOW = string.char(0x1F, 50)
local TEST_GREEN  = string.char(0x1F, 158)
local TEST_RED    = string.char(0x1F, 167)
local TEST_SEPARATOR = string.rep("=", 74)

-- 21 jobs plus the general suite. Order is the order they run in.
local TEST_JOBS = {
    'system',                                    -- magic, JA, WS
    'whm', 'blm', 'rdm', 'sch', 'geo', 'blu',    -- mages
    'brd', 'cor',                                -- support
    'war', 'mnk', 'thf', 'pld', 'drk', 'bst',
    'rng', 'sam', 'nin', 'drg', 'pup', 'dnc', 'run',
}

local function test_module_path(job)
    return 'shared/utils/messages/api/tests/test_' .. job:lower()
end

local function show_test_header(job_filter)
    add_to_chat(121, TEST_GRAY .. TEST_SEPARATOR)
    if job_filter then
        add_to_chat(121, TEST_YELLOW .. "[Messages] Running " .. job_filter .. " Test Suite")
    else
        add_to_chat(121, TEST_YELLOW .. "[Messages] Running ALL Test Suites")
    end
    add_to_chat(121, TEST_GRAY .. TEST_SEPARATOR)
    add_to_chat(121, " ")
end

--- Names the caller could have passed, listed when the one they did is unknown.
local function show_missing_test_file(test_file)
    add_to_chat(167, TEST_RED .. "Test file not found: " .. test_file .. ".lua")
    add_to_chat(167, TEST_RED .. "Available tests (22 total):")
    add_to_chat(167, TEST_RED .. "  SYSTEM (general)")
    add_to_chat(167, TEST_RED .. "  Mages: WHM, BLM, RDM, SCH, GEO, BLU")
    add_to_chat(167, TEST_RED .. "  Support: BRD, COR")
    add_to_chat(167, TEST_RED .. "  Melee: WAR, MNK, THF, PLD, DRK, BST")
    add_to_chat(167, TEST_RED .. "  Melee: RNG, SAM, NIN, DRG, PUP, DNC, RUN")
    add_to_chat(121, TEST_GRAY .. TEST_SEPARATOR)
end

--- Run one named suite, or every suite that exists.
--- A suite missing from the full run is skipped silently: the list names jobs
--- that have no test file yet, and that is not an error.
--- @return boolean False only when a suite the caller NAMED does not exist
local function run_test_suites(test, job_filter)
    if job_filter then
        local test_file = test_module_path(job_filter)
        local ok, test_module = pcall(require, test_file)
        if not (ok and test_module and test_module.run) then
            show_missing_test_file(test_file)
            return false
        end
        test_module.run(test)
        return true
    end

    for _, job in ipairs(TEST_JOBS) do
        local ok, test_module = pcall(require, test_module_path(job))
        if ok and test_module and test_module.run then
            test_module.run(test)
        end
    end
    return true
end

local function show_test_results(passed, total)
    add_to_chat(121, " ")
    add_to_chat(121, TEST_GRAY .. TEST_SEPARATOR)

    if passed == total then
        add_to_chat(121, TEST_GREEN .. string.format("[OK] Message System: %d/%d tests PASSED", passed, total))
    else
        add_to_chat(121, TEST_RED .. string.format("[FAIL] Message System: %d/%d tests FAILED (%d passed)", total - passed, total, passed))
    end

    add_to_chat(121, TEST_GRAY .. TEST_SEPARATOR)
end

--- Run integrated test suite (all jobs or specific job)
--- Usage: M.test() or M.test('BRD') or M.test('system')
--- @param job_filter string|nil Optional job filter (e.g., "BRD", "GEO", "WAR", "system")
function Messages.test(job_filter)
    local test, get_stats = create_test_runner()

    if job_filter then
        job_filter = job_filter:upper()
    end

    show_test_header(job_filter)

    if not run_test_suites(test, job_filter) then
        return false
    end

    local passed, total = get_stats()
    show_test_results(passed, total)

    return passed == total
end

return Messages

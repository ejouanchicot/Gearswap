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

local MessageEngine = require('shared/utils/messages/core/message_engine')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')

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
        return MessageEngine.format(namespace, key, params)
    end)

    if not ok then
        -- Error formatting message
        MessageRenderer.show_error(string.format(
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
    MessageRenderer.send(message, color, options)

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

    MessageRenderer.send(formatted, color, {
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

        MessageRenderer.send(message, self.color, self.options)
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
    MessageRenderer.configure(config)
end

--- Get current configuration
--- @return table Current config
function Messages.get_config()
    return MessageRenderer.get_config()
end

--- Toggle all messages on/off
--- @return boolean New state
function Messages.toggle()
    return MessageRenderer.toggle()
end

--- Set filter level
--- @param level number 0=all, 1=important, 2=critical
function Messages.set_filter_level(level)
    MessageRenderer.set_filter_level(level)
end

--- Set color mode for accessibility
--- @param mode string "normal", "colorblind", "monochrome"
function Messages.set_color_mode(mode)
    MessageRenderer.set_color_mode(mode)
end

--- Toggle timestamps
--- @return boolean New state
function Messages.toggle_timestamp()
    return MessageRenderer.toggle_timestamp()
end

---============================================================================
--- DEBUGGING & UTILITIES
---============================================================================

--- Show system statistics
function Messages.show_stats()
    MessageRenderer.show_stats()
end

--- Reset statistics
function Messages.reset_stats()
    MessageRenderer.reset_stats()
end

--- List all available messages in a namespace (for debugging)
--- @param namespace string
function Messages.list(namespace)
    local keys = MessageEngine.list_keys(namespace)

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
    return MessageEngine.get_stats()
end

--- Clear engine cache (for development/testing)
function Messages.clear_cache()
    MessageEngine.clear_cache()
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
        local old_renderer = MessageRenderer.show_error
        MessageRenderer.show_error = function() end
        local ok = pcall(fn)
        MessageRenderer.show_error = old_renderer
        if ok then passed = passed + 1 end
        return ok
    end

    return test, function() return passed, total end
end

--- Run integrated test suite (all jobs or specific job)
--- Usage: M.test() or M.test('BRD') or M.test('system')
--- @param job_filter string|nil Optional job filter (e.g., "BRD", "GEO", "WAR", "system")
function Messages.test(job_filter)
    local test, get_stats = create_test_runner()

    -- Normalize job filter to uppercase
    if job_filter then
        job_filter = job_filter:upper()
    end

    -- Color codes
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local green = string.char(0x1F, 158)
    local red = string.char(0x1F, 167)
    local separator = string.rep("=", 74)

    -- Header
    add_to_chat(121, gray .. separator)
    if job_filter then
        add_to_chat(121, yellow .. "[Messages] Running " .. job_filter .. " Test Suite")
    else
        add_to_chat(121, yellow .. "[Messages] Running ALL Test Suites")
    end
    add_to_chat(121, gray .. separator)
    add_to_chat(121, " ")

    local total_tests = 0

    -- Load job-specific test file if filter provided
    if job_filter then
        local test_file = 'shared/utils/messages/api/tests/test_' .. job_filter:lower()
        local ok, test_module = pcall(require, test_file)

        if ok and test_module and test_module.run then
            -- Run job-specific tests
            total_tests = test_module.run(test)
        else
            add_to_chat(167, red .. "Test file not found: " .. test_file .. ".lua")
            add_to_chat(167, red .. "Available tests (22 total):")
            add_to_chat(167, red .. "  SYSTEM (general)")
            add_to_chat(167, red .. "  Mages: WHM, BLM, RDM, SCH, GEO, BLU")
            add_to_chat(167, red .. "  Support: BRD, COR")
            add_to_chat(167, red .. "  Melee: WAR, MNK, THF, PLD, DRK, BST")
            add_to_chat(167, red .. "  Melee: RNG, SAM, NIN, DRG, PUP, DNC, RUN")
            add_to_chat(121, gray .. separator)
            return false
        end
    else
        -- Run all available tests (21 jobs + system = 22 total)
        local test_jobs = {
            'system',  -- General system tests (magic, JA, WS)
            -- Mages
            'whm',     -- White Mage
            'blm',     -- Black Mage
            'rdm',     -- Red Mage
            'sch',     -- Scholar
            'geo',     -- Geomancer
            'blu',     -- Blue Mage
            -- Support
            'brd',     -- Bard
            'cor',     -- Corsair
            -- Melee
            'war',     -- Warrior
            'mnk',     -- Monk
            'thf',     -- Thief
            'pld',     -- Paladin
            'drk',     -- Dark Knight
            'bst',     -- Beastmaster
            'rng',     -- Ranger
            'sam',     -- Samurai
            'nin',     -- Ninja
            'drg',     -- Dragoon
            'pup',     -- Puppetmaster
            'dnc',     -- Dancer
            'run'      -- Runemaster
        }

        for _, job in ipairs(test_jobs) do
            local test_file = 'shared/utils/messages/api/tests/test_' .. job
            local ok, test_module = pcall(require, test_file)

            if ok and test_module and test_module.run then
                total_tests = total_tests + test_module.run(test)
            end
        end
    end

    -- Results
    local passed, total = get_stats()

    add_to_chat(121, " ")
    add_to_chat(121, gray .. separator)

    if passed == total then
        add_to_chat(121, green .. string.format("[OK] Message System: %d/%d tests PASSED", passed, total))
    else
        add_to_chat(121, red .. string.format("[FAIL] Message System: %d/%d tests FAILED (%d passed)", total - passed, total, passed))
    end

    add_to_chat(121, gray .. separator)

    return passed == total
end

return Messages

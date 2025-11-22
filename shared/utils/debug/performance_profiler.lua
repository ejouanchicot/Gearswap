---============================================================================
--- Performance Profiler - On-Demand Performance Monitoring
---============================================================================
--- Provides timing utilities for performance debugging.
--- Can be enabled/disabled via commands without code changes.
---
--- Usage:
---   //gs c perf start   - Enable profiling
---   //gs c perf stop    - Disable profiling
---   //gs c perf status  - Show current status
---
--- In code:
---   local Profiler = require('shared/utils/debug/performance_profiler')
---   Profiler.start('get_sets')
---   -- ... code to profile ...
---   Profiler.mark('After Mote-Include')
---   -- ... more code ...
---   Profiler.mark('After war_functions')
---   Profiler.finish()
---
--- @file    shared/utils/debug/performance_profiler.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    2025-11-15
---============================================================================

local Profiler = {}

-- Import message system
local M = require('shared/utils/messages/api/messages')

-- State file path (persistent across reloads)
local STATE_FILE = windower.addon_path .. 'data/.profiler_enabled'

---============================================================================
--- PERSISTENT STATE MANAGEMENT
---============================================================================

--- Check if profiling is enabled (reads from file)
--- @return boolean
local function read_state()
    local file = io.open(STATE_FILE, 'r')
    if file then
        file:close()
        return true
    end
    return false
end

--- Save enabled state to file
local function save_state_enabled()
    local file = io.open(STATE_FILE, 'w')
    if file then
        file:write('enabled')
        file:close()
    end
end

--- Delete state file (disabled)
local function save_state_disabled()
    os.remove(STATE_FILE)
end

-- Global state (accessible via _G for commands)
if not _G.PERFORMANCE_PROFILING then
    _G.PERFORMANCE_PROFILING = {
        enabled = read_state(),  -- Read from file at startup!
        start_time = nil,
        context = nil
    }
end

---============================================================================
--- PROFILING CONTROL
---============================================================================

--- Enable profiling
function Profiler.enable()
    _G.PERFORMANCE_PROFILING.enabled = true
    save_state_enabled()  -- Persist to file
    M.send('PROFILER', 'enabled')
    M.send('PROFILER', 'reload_hint')
end

--- Disable profiling
function Profiler.disable()
    _G.PERFORMANCE_PROFILING.enabled = false
    save_state_disabled()  -- Remove file
    M.send('PROFILER', 'disabled')
end

--- Toggle profiling on/off
function Profiler.toggle()
    if _G.PERFORMANCE_PROFILING.enabled then
        Profiler.disable()
    else
        Profiler.enable()
    end
    return _G.PERFORMANCE_PROFILING.enabled
end

--- Check if profiling is enabled
--- @return boolean
function Profiler.is_enabled()
    return _G.PERFORMANCE_PROFILING.enabled == true
end

--- Show profiling status
function Profiler.status()
    if _G.PERFORMANCE_PROFILING.enabled then
        M.send('PROFILER', 'status_enabled')
        M.send('PROFILER', 'status_hint')
    else
        M.send('PROFILER', 'status_disabled')
    end
end

---============================================================================
--- PERFORMANCE THRESHOLDS & COLOR CODING
---============================================================================

--- Determine color based on performance timing
--- @param elapsed number Elapsed time in milliseconds
--- @param checkpoint_type string Type: 'main', 'job', 'total_main', 'total_job'
--- @return string Color code (green, yellow, red)
local function get_performance_color(elapsed, checkpoint_type)
    if checkpoint_type == 'main' then
        -- Main checkpoints (cumulative): green < 50ms, yellow 50-100ms, red > 100ms
        if elapsed < 50 then return 'green'
        elseif elapsed < 100 then return 'yellow'
        else return 'red' end
    elseif checkpoint_type == 'job' then
        -- Individual job modules: green < 5ms, yellow 5-10ms, red > 10ms
        if elapsed < 5 then return 'green'
        elseif elapsed < 10 then return 'yellow'
        else return 'red' end
    elseif checkpoint_type == 'total_main' then
        -- Total get_sets: green < 200ms, yellow 200-300ms, red > 300ms
        if elapsed < 200 then return 'green'
        elseif elapsed < 300 then return 'yellow'
        else return 'red' end
    elseif checkpoint_type == 'total_job' then
        -- Total job_functions: green < 50ms, yellow 50-100ms, red > 100ms
        if elapsed < 50 then return 'green'
        elseif elapsed < 100 then return 'yellow'
        else return 'red' end
    else
        return 'cyan'  -- Fallback
    end
end

--- Pad label for alignment
--- @param label string Label to pad
--- @param width number Target width (default 40)
--- @return string Padded label
local function pad_label(label, width)
    width = width or 40
    local len = string.len(label)
    if len >= width then
        return label
    end
    return label .. string.rep(' ', width - len)
end

---============================================================================
--- TIMING FUNCTIONS
---============================================================================

--- Start a profiling session
--- @param context string Context name (e.g., 'get_sets', 'war_functions')
function Profiler.start(context)
    if not Profiler.is_enabled() then
        return
    end

    _G.PERFORMANCE_PROFILING.start_time = os.clock()
    _G.PERFORMANCE_PROFILING.last_mark_time = os.clock()  -- Track incremental time
    _G.PERFORMANCE_PROFILING.context = context or 'unknown'
end

--- Mark a timing checkpoint
--- @param label string Label for this checkpoint
--- @param color number Optional chat color (ignored, using message system)
function Profiler.mark(label, color)
    if not Profiler.is_enabled() or not _G.PERFORMANCE_PROFILING.start_time then
        return
    end

    local now = os.clock()
    local elapsed_total = (now - _G.PERFORMANCE_PROFILING.start_time) * 1000
    local elapsed_incremental = (now - (_G.PERFORMANCE_PROFILING.last_mark_time or _G.PERFORMANCE_PROFILING.start_time)) * 1000
    _G.PERFORMANCE_PROFILING.last_mark_time = now

    local context = _G.PERFORMANCE_PROFILING.context or ''

    -- Use INCREMENTAL time for color coding (not cumulative!)
    local perf_color_name = get_performance_color(elapsed_incremental, 'main')
    local padded_label = pad_label(label, 35)

    -- Map color name to FFXI color code
    local color_codes = {
        green = string.char(0x1F, 158),
        yellow = string.char(0x1F, 50),
        red = string.char(0x1F, 167)
    }
    local perf_color_code = color_codes[perf_color_name] or color_codes['cyan']

    M.send('PROFILER', 'checkpoint_main', {
        context = context,
        label = padded_label,
        time = string.format('%3.0f', elapsed_incremental),  -- Show INCREMENTAL time
        perf_color = perf_color_code
    })
end

--- Finish profiling session and show total time
--- @param color number Optional chat color (ignored, using message system)
function Profiler.finish(color)
    if not Profiler.is_enabled() or not _G.PERFORMANCE_PROFILING.start_time then
        return
    end

    local elapsed = (os.clock() - _G.PERFORMANCE_PROFILING.start_time) * 1000
    local context = _G.PERFORMANCE_PROFILING.context or ''
    local perf_color_name = get_performance_color(elapsed, 'total_main')

    -- Map color name to FFXI color code
    local color_codes = {
        green = string.char(0x1F, 158),
        yellow = string.char(0x1F, 50),
        red = string.char(0x1F, 167)
    }
    local perf_color_code = color_codes[perf_color_name] or color_codes['green']

    M.send('PROFILER', 'total', {
        context = context,
        time = string.format('%3.0f', elapsed),
        perf_color = perf_color_code
    })
    M.send('PROFILER', 'separator')

    -- Reset
    _G.PERFORMANCE_PROFILING.start_time = nil
    _G.PERFORMANCE_PROFILING.last_mark_time = nil
    _G.PERFORMANCE_PROFILING.context = nil
end

--- Create a scoped timer that automatically marks on function calls
--- @param context string Context name (job code like "WAR", "BRD", etc.)
--- @return function Timer function
function Profiler.create_timer(context)
    if not Profiler.is_enabled() then
        return function() end  -- No-op function
    end

    local start_time = os.clock()
    local last_time = start_time

    return function(label, is_total)
        local elapsed = (os.clock() - start_time) * 1000
        local incremental = (os.clock() - last_time) * 1000
        last_time = os.clock()

        -- Determine if this is a TOTAL line
        local checkpoint_type = 'job'
        local time_to_show = incremental

        if is_total or string.match(label, '^TOTAL') then
            checkpoint_type = 'total_job'
            time_to_show = elapsed
        end

        local perf_color_name = get_performance_color(time_to_show, checkpoint_type)
        local padded_label = pad_label(label, 30)

        -- Map color name to FFXI color code
        local color_codes = {
            green = string.char(0x1F, 158),
            yellow = string.char(0x1F, 50),
            red = string.char(0x1F, 167)
        }
        local perf_color_code = color_codes[perf_color_name] or color_codes['green']

        M.send('PROFILER', 'checkpoint_job', {
            job = context,
            label = padded_label,
            time = string.format('%3.0f', time_to_show),
            perf_color = perf_color_code
        })
    end
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Profile a function call and return its result
--- @param label string Label for this profiling
--- @param func function Function to profile
--- @param ... any Arguments to pass to function
--- @return any Function result
function Profiler.profile_call(label, func, ...)
    if not Profiler.is_enabled() then
        return func(...)
    end

    local start = os.clock()
    local results = {func(...)}
    local elapsed = (os.clock() - start) * 1000

    M.send('PROFILER', 'call', {
        label = label,
        time = string.format('%.0f', elapsed)
    })

    return unpack(results)
end

--- Measure time for a code block
--- Usage:
---   Profiler.measure('my_code', function()
---       -- code to measure
---   end)
---
--- @param label string Label for measurement
--- @param code_block function Code to measure
function Profiler.measure(label, code_block)
    if not Profiler.is_enabled() then
        code_block()
        return
    end

    local start = os.clock()
    code_block()
    local elapsed = (os.clock() - start) * 1000

    M.send('PROFILER', 'measure', {
        label = label,
        time = string.format('%.0f', elapsed)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return Profiler

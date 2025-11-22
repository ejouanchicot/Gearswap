---============================================================================
--- PROFILER Message Data - Performance Profiling Messages
---============================================================================
--- Pure data file for performance profiler messages
--- Used by performance_profiler.lua via new message system
---
--- @file data/systems/profiler_messages.lua
--- @author Tetsouo
--- @date Created: 2025-11-15
---============================================================================

return {
    ---========================================================================
    --- PROFILING CONTROL MESSAGES
    ---========================================================================

    enabled = {
        template = "{green}[PROFILER] {white}Performance profiling {green}ENABLED",
        color = 122
    },

    disabled = {
        template = "{gray}[PROFILER] {white}Performance profiling {gray}DISABLED",
        color = 122
    },

    reload_hint = {
        template = "{gray}[PROFILER] {white}Reload job to see timings: {cyan}//lua reload gearswap",
        color = 122
    },

    status_enabled = {
        template = "{green}[PROFILER] {white}Status: {green}ENABLED",
        color = 122
    },

    status_disabled = {
        template = "{gray}[PROFILER] {white}Status: {gray}DISABLED",
        color = 167
    },

    status_hint = {
        template = "{gray}[PROFILER] {white}Reload job to profile: {cyan}//lua reload gearswap",
        color = 122
    },

    usage = {
        template = "{yellow}[PROFILER] {white}Usage: {cyan}//gs c perf [start|stop|toggle|status]",
        color = 122
    },

    ---========================================================================
    --- TIMING CHECKPOINT MESSAGES
    ---========================================================================

    checkpoint_main = {
        template = "{lightblue}[PERF:{context}] {white}{label} {perf_color}{time}ms",
        color = 122
    },

    checkpoint_job = {
        template = "  {yellow}[{job}] {white}{label} {perf_color}{time}ms",
        color = 122
    },

    total = {
        template = "{lightblue}[PERF:{context}] {white}TOTAL: {perf_color}{time}ms",
        color = 122
    },

    separator = {
        template = "{gray}==========================================================================",
        color = 1
    },

    ---========================================================================
    --- ADVANCED PROFILING MESSAGES
    ---========================================================================

    measure = {
        template = "{purple}[PERF:MEASURE] {white}{label}: {cyan}{time}ms",
        color = 122
    },

    call = {
        template = "{purple}[PERF:CALL] {white}{label}: {cyan}{time}ms",
        color = 122
    },
}

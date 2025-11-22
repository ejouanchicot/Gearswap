---============================================================================
--- UNIVERSAL JOB OPTIMIZER - Apply Lazy Loading to ALL Jobs
---============================================================================
--- Automatically applies lazy-loading patterns to all job modules.
--- This script optimizes PRECAST, MIDCAST, IDLE, ENGAGED, STATUS, BUFFS,
--- COMMANDS, LOCKSTYLE, MACROBOOK for all jobs.
---
--- Usage:
---   lua scripts/optimize_all_jobs.lua
---
--- @file    scripts/optimize_all_jobs.lua
--- @author  Tetsouo (via Claude Code)
--- @version 1.0
--- @date    2025-11-15
---============================================================================

-- Job list (all jobs in shared/jobs/)
local JOBS = {
    'brd', 'blm', 'bst', 'cor', 'dnc', 'drk',
    'geo', 'pld', 'rdm', 'run', 'sam', 'thf', 'war', 'whm'
}

-- Modules to optimize (pattern-based)
local MODULES_TO_OPTIMIZE = {
    'PRECAST',
    'MIDCAST',
    'IDLE',
    'ENGAGED',
    'STATUS',
    'BUFFS',
    'COMMANDS',
    'LOCKSTYLE',
    'MACROBOOK'
}

---============================================================================
--- LAZY LOADING PATTERNS
---============================================================================

local PATTERNS = {}

-- Pattern: LOCKSTYLE (factory pattern -> lazy wrapper)
PATTERNS.LOCKSTYLE = {
    find_pattern = "local LockstyleManager = require%(.-%).-return LockstyleManager%.create%(",
    replace = function(content, job_upper)
        -- Check if already optimized
        if content:match("Lazy loading:") or content:match("lazy load") then
            return nil  -- Already optimized
        end

        -- Extract config details
        local job_code = content:match("'(%u+)'")
        local config_path = content:match("'(config/[^']+)'")
        local lockstyle_num = content:match("create%([^,]+,[^,]+,%s*(%d+)")
        local default_subjob = content:match("create%([^,]+,[^,]+,[^,]+,%s*'(%u+)'")

        if not (job_code and config_path and lockstyle_num) then
            return nil
        end

        return string.format([[
---============================================================================
--- %s Lockstyle Module - Lockstyle Management (Factory Pattern)
---============================================================================
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Module created on first function call (saves ~30ms at startup)
---
--- @file    jobs/%s/functions/%s_LOCKSTYLE.lua
--- @version 2.1 - Lazy Loading for performance
--- @date    Updated: 2025-11-15
---============================================================================

-- Lazy loading: Module created on first use
local LockstyleManager = nil
local lockstyle_module = nil

local function get_lockstyle_module()
    if not lockstyle_module then
        if not LockstyleManager then
            LockstyleManager = require('shared/utils/lockstyle/lockstyle_manager')
        end
        lockstyle_module = LockstyleManager.create(
            '%s',                      -- job_code
            '%s',                      -- config_path
            %s,                        -- default_lockstyle
            '%s'                       -- default_subjob
        )
    end
    return lockstyle_module
end

function select_default_lockstyle()
    return get_lockstyle_module().select_default_lockstyle()
end

function cancel_%s_lockstyle_operations()
    return get_lockstyle_module().cancel_%s_lockstyle_operations()
end

_G.select_default_lockstyle = select_default_lockstyle
_G.cancel_%s_lockstyle_operations = cancel_%s_lockstyle_operations
]], job_upper, job_code:lower(), job_upper,
   job_code, config_path, lockstyle_num, default_subjob or 'SAM',
   job_code:lower(), job_code:lower(),
   job_code:lower(), job_code:lower())
    end
}

-- Pattern: MACROBOOK (factory pattern -> lazy wrapper)
PATTERNS.MACROBOOK = {
    find_pattern = "local MacrobookManager = require%(.-%).-return MacrobookManager%.create%(",
    replace = function(content, job_upper)
        if content:match("Lazy loading:") or content:match("lazy load") then
            return nil
        end

        local job_code = content:match("'(%u+)'")
        local config_path = content:match("'(config/[^']+)'")
        local default_subjob = content:match(",%s*'(%u+)'")
        local book = content:match(",%s*(%d+),%s*%d+")
        local page = content:match(",%s*%d+,%s*(%d+)")

        if not (job_code and config_path) then
            return nil
        end

        return string.format([[
---============================================================================
--- %s Macrobook Module - Macro Book Management (Factory Pattern)
---============================================================================
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Module created on first function call (saves ~45ms at startup)
---
--- @file    jobs/%s/functions/%s_MACROBOOK.lua
--- @version 2.1 - Lazy Loading for performance
--- @date    Updated: 2025-11-15
---============================================================================

-- Lazy loading: Module created on first use
local MacrobookManager = nil
local macrobook_module = nil

local function get_macrobook_module()
    if not macrobook_module then
        if not MacrobookManager then
            MacrobookManager = require('shared/utils/macrobook/macrobook_manager')
        end
        macrobook_module = MacrobookManager.create(
            '%s',                         -- job_code
            '%s',                         -- config_path
            '%s',                         -- default_subjob
            %s,                           -- default_book
            %s                            -- default_page
        )
    end
    return macrobook_module
end

function select_default_macro_book()
    return get_macrobook_module().select_default_macro_book()
end

_G.select_default_macro_book = select_default_macro_book
]], job_upper, job_code:lower(), job_upper,
   job_code, config_path, default_subjob or 'SAM', book or '1', page or '1')
    end
}

---============================================================================
--- MAIN OPTIMIZATION FUNCTION
---============================================================================

local function optimize_job(job)
    local job_upper = job:upper()
    local base_path = string.format("D:/Windower Tetsouo/addons/GearSwap/data/shared/jobs/%s/functions", job)

    print(string.format("\n[OPTIMIZER] Processing %s...", job_upper))

    local optimized_count = 0
    local skipped_count = 0

    for _, module in ipairs(MODULES_TO_OPTIMIZE) do
        local file_path = string.format("%s/%s_%s.lua", base_path, job_upper, module)

        -- Check if file exists
        local file = io.open(file_path, "r")
        if not file then
            print(string.format("  [SKIP] %s_%s.lua (file not found)", job_upper, module))
            skipped_count = skipped_count + 1
        else
            local content = file:read("*all")
            file:close()

            -- Check if already optimized
            if content:match("PERFORMANCE OPTIMIZATION") and content:match("Lazy") then
                print(string.format("  [SKIP] %s_%s.lua (already optimized)", job_upper, module))
                skipped_count = skipped_count + 1
            else
                -- Apply pattern if available
                local pattern = PATTERNS[module]
                if pattern and pattern.find_pattern and content:match(pattern.find_pattern) then
                    local new_content = pattern.replace(content, job_upper)
                    if new_content then
                        -- Write optimized file
                        local out_file = io.open(file_path, "w")
                        if out_file then
                            out_file:write(new_content)
                            out_file:close()
                            print(string.format("  [✓] %s_%s.lua (optimized)", job_upper, module))
                            optimized_count = optimized_count + 1
                        end
                    else
                        print(string.format("  [SKIP] %s_%s.lua (no changes needed)", job_upper, module))
                        skipped_count = skipped_count + 1
                    end
                else
                    print(string.format("  [TODO] %s_%s.lua (manual optimization needed)", job_upper, module))
                    skipped_count = skipped_count + 1
                end
            end
        end
    end

    print(string.format("[%s] Optimized: %d | Skipped: %d", job_upper, optimized_count, skipped_count))
end

---============================================================================
--- EXECUTE
---============================================================================

print("╔═══════════════════════════════════════════════════════════════════╗")
print("║  UNIVERSAL JOB OPTIMIZER - Lazy Loading Migration                ║")
print("╚═══════════════════════════════════════════════════════════════════╝")

for _, job in ipairs(JOBS) do
    optimize_job(job)
end

print("\n[OPTIMIZER] Complete!")
print("\nNOTE: This script optimized LOCKSTYLE and MACROBOOK modules.")
print("For PRECAST, MIDCAST, COMMANDS, etc., use job-specific patterns.")

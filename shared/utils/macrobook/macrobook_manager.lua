---  ═══════════════════════════════════════════════════════════════════════════
---   Macrobook Manager - Centralized Macrobook Management Factory
---  ═══════════════════════════════════════════════════════════════════════════
---   Factory pattern that creates job-specific macrobook modules.
---   Eliminates 124-line duplication across WAR/PLD/DNC (372 lines >> 124 lines).
---
---   @file    shared/utils/macrobook/macrobook_manager.lua
---   @author  Tetsouo
---   @version 1.2 - create() split into ctx-taking operations (parity with LockstyleManager)
---   @date    Created: 2025-10-05 | Updated: 2026-08-10
---  ═══════════════════════════════════════════════════════════════════════════

local MacrobookManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   SHARED DEPENDENCIES (loaded once, reused by every per-job ctx)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Names of globals set by the most recent create() call. Cleared at the top
-- of every new create() so PLD->RDM->... job changes don't accumulate stale
-- _G.set_pld_macro_book / _G.get_pld_macro_info / _G.show_pld_macro_configs.
-- Persists across job changes because package.loaded is NOT cleared on FFXI
-- job change (only on gs reload), so this module-local table remembers what
-- the previous job exported.
local last_registered_globals = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   CONFIG LOADING
---  ═══════════════════════════════════════════════════════════════════════════

--- What a job falls back to when it has no config file at all: its own default
--- book on every path.
--- @return table MACROBOOKS
local function fallback_macrobooks(default_subjob, default_book, default_page)
    return {
        solo = {
            [default_subjob] = { book = default_book, page = default_page },
            ['default']      = { book = default_book, page = default_page },
        },
        dualbox = {},
    }
end

--- Normalise a job's macrobook config into { solo = {...}, dualbox = {...} }.
--- Two shapes are accepted: the current one, which names solo and dualbox, and
--- the original one, which had a flat `macrobooks` table and no dualbox idea.
--- @param config_path string Path to the job config
--- @param default_subjob string Fallback subjob when there is no config at all
--- @param default_book number Fallback book
--- @param default_page number Fallback page
--- @return table MACROBOOKS
local function load_macrobooks(config_path, default_subjob, default_book, default_page)
    local success, MacroConfig = pcall(require, config_path)
    if not success or not MacroConfig then
        return fallback_macrobooks(default_subjob, default_book, default_page)
    end

    local books
    if MacroConfig.solo or MacroConfig.dualbox then
        books = {
            solo    = MacroConfig.solo or {},
            dualbox = MacroConfig.dualbox or {},
        }
    else
        books = {
            solo    = MacroConfig.macrobooks or {},
            dualbox = {},
        }
    end

    books.solo['default'] = MacroConfig.default
        or { book = default_book, page = default_page }

    return books
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PER-INSTANCE OPERATIONS
---  ═══════════════════════════════════════════════════════════════════════════
---
---   Each function takes a `ctx` table built by create():
---     ctx.job_code        string - 'WAR', 'PLD', ...
---     ctx.default_subjob  string - used when player.sub_job is not readable yet
---     ctx.default_book    number
---     ctx.default_page    number
---     ctx.MACROBOOKS      table  - { solo = {...}, dualbox = {...} }

--- Select macro book with delay to prevent FFXI erasure bug
--- @param ctx table Per-job context
--- @param book number Macro book number
--- @param page number Macro page number
--- @param delay number Optional delay in seconds (default: 1.5)
local function set_macro_with_delay(ctx, book, page, delay)
    delay = delay or 1.5

    -- Invalidation counter: prevents stale scheduled macros from firing after gs reload
    -- Old coroutines survive gs reload but check this counter before executing
    _G._macrobook_schedule_id = (_G._macrobook_schedule_id or 0) + 1
    local my_id = _G._macrobook_schedule_id

    coroutine.schedule(function()
        if my_id ~= _G._macrobook_schedule_id then return end
        set_macro_page(page, book)
    end, delay)
end

--- Which book the alt's job asks for, if an alt is online and configured.
--- @param ctx table Per-job context
--- @param sub_job string Current subjob
--- @return table|nil { book, page }, or nil to fall back to the solo config
local function dualbox_config(ctx, sub_job)
    local success, DualBoxManager = pcall(require, 'shared/utils/dualbox/dualbox_manager')
    if not (success and DualBoxManager and DualBoxManager.is_alt_online()) then
        return nil
    end

    local alt_job = DualBoxManager.get_alt_job()
    if alt_job and ctx.MACROBOOKS.dualbox and ctx.MACROBOOKS.dualbox[alt_job] then
        return ctx.MACROBOOKS.dualbox[alt_job][sub_job]
    end
    return nil
end

--- Select default macro book based on current sub-job and dual-boxing status
--- @param ctx table Per-job context
local function select_default_macro_book(ctx)
    if not player then
        coroutine.schedule(function() select_default_macro_book(ctx) end, 0.5)
        return
    end

    local sub_job = player.sub_job or ctx.default_subjob
    local config = dualbox_config(ctx, sub_job)

    if not config and ctx.MACROBOOKS.solo then
        config = ctx.MACROBOOKS.solo[sub_job] or ctx.MACROBOOKS.solo['default']
    end

    if not config then
        config = { book = ctx.default_book, page = ctx.default_page }
    end

    set_macro_with_delay(ctx, config.book, config.page, 1.5)
end

--- Manually set macro book for specific subjob
--- @param ctx table Per-job context
--- @param subjob string Subjob code
local function set_macro_book(ctx, subjob)
    if not subjob then return end

    subjob = string.upper(subjob)
    local config = ctx.MACROBOOKS.solo and ctx.MACROBOOKS.solo[subjob]

    if not config then
        MessageFormatter.show_error(string.format("%s: Unknown subjob '%s' for macro book",
            ctx.job_code, subjob))
        return
    end

    set_macro_with_delay(ctx, config.book, config.page, 0.5)
end

--- Get current macro book info for display
--- @param ctx table Per-job context
--- @return table|nil Macro book info {book, page, subjob}
local function get_macro_info(ctx)
    if not player then return nil end

    local sub_job = player.sub_job or ctx.default_subjob
    local config = ctx.MACROBOOKS.solo
        and (ctx.MACROBOOKS.solo[sub_job] or ctx.MACROBOOKS.solo['default'])

    if not config then
        config = { book = ctx.default_book, page = ctx.default_page }
    end

    return {
        book = config.book,
        page = config.page,
        subjob = sub_job
    }
end

--- Display available macro book configurations
--- @param ctx table Per-job context
local function show_macro_configs(ctx)
    MessageFormatter.show_success(string.format("%s Macro Book Configurations:", ctx.job_code))

    if ctx.MACROBOOKS.solo then
        MessageFormatter.show_info("  Solo Configurations:")
        for subjob, config in pairs(ctx.MACROBOOKS.solo) do
            if subjob ~= 'default' then
                MessageFormatter.show_info(string.format("    %s/%s: Book %d Page %d",
                    ctx.job_code, subjob, config.book, config.page))
            end
        end
    end

    if ctx.MACROBOOKS.dualbox and next(ctx.MACROBOOKS.dualbox) then
        MessageFormatter.show_info("  Dual-Boxing Configurations:")
        for alt_job, subjob_configs in pairs(ctx.MACROBOOKS.dualbox) do
            for subjob, config in pairs(subjob_configs) do
                MessageFormatter.show_info(string.format("    %s/%s + Alt %s: Book %d Page %d",
                    ctx.job_code, subjob, alt_job, config.book, config.page))
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   FACTORY
---  ═══════════════════════════════════════════════════════════════════════════

--- Create a macrobook module configured for a specific job
--- @param job_code string Job code (e.g., 'WAR', 'PLD', 'DNC')
--- @param config_path string Path to job macrobook config (e.g., 'config/war/WAR_MACROBOOK')
--- @param default_subjob string Default subjob for this job (e.g., 'SAM', 'RUN', 'NIN')
--- @param default_book number Default macro book number
--- @param default_page number Default macro page number
--- @return table Macrobook module with all functions
function MacrobookManager.create(job_code, config_path, default_subjob, default_book, default_page)
    local ctx = {
        job_code       = job_code,
        default_subjob = default_subjob,
        default_book   = default_book,
        default_page   = default_page,
        MACROBOOKS     = load_macrobooks(config_path, default_subjob, default_book, default_page),
    }

    local function bind(fn) return function(...) return fn(ctx, ...) end end

    local api = {
        select_default_macro_book = bind(select_default_macro_book),
        set_macro_book            = bind(set_macro_book),
        get_macro_info            = bind(get_macro_info),
        show_macro_configs        = bind(show_macro_configs),
    }

    -- Clear globals registered by the previous create() (different job) so
    -- old _G.set_pld_macro_book / _G.get_pld_macro_info / _G.show_pld_macro_configs
    -- don't linger after PLD->RDM. Same rationale as LockstyleManager.
    for _, name in ipairs(last_registered_globals) do
        _G[name] = nil
    end
    last_registered_globals = {}

    -- Export functions globally for include() compatibility
    local jl = string.lower(job_code)
    local exports = {
        ['select_default_macro_book']        = api.select_default_macro_book,
        ['set_'  .. jl .. '_macro_book']     = api.set_macro_book,
        ['get_'  .. jl .. '_macro_info']     = api.get_macro_info,
        ['show_' .. jl .. '_macro_configs']  = api.show_macro_configs,
    }
    for name, fn in pairs(exports) do
        _G[name] = fn
        table.insert(last_registered_globals, name)
    end

    -- Also return as module for require() usage
    return {
        -- Public API
        select_default_macro_book = api.select_default_macro_book,
        set_macro_book = api.set_macro_book,
        get_macro_info = api.get_macro_info,
        show_macro_configs = api.show_macro_configs,

        -- Legacy function names for compatibility
        ['set_' .. jl .. '_macro_book'] = api.set_macro_book,
        ['get_' .. jl .. '_macro_info'] = api.get_macro_info,
        ['show_' .. jl .. '_macro_configs'] = api.show_macro_configs
    }
end

return MacrobookManager

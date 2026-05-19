---  ═══════════════════════════════════════════════════════════════════════════
---   Lockstyle Manager - Centralized Lockstyle Management Factory
---  ═══════════════════════════════════════════════════════════════════════════
---   Factory pattern that creates job-specific lockstyle modules.
---   Eliminates 293-line duplication across WAR/PLD/DNC (879 lines >> 293 lines).
---
---   @file    shared/utils/lockstyle/lockstyle_manager.lua
---   @author  Tetsouo
---   @version 1.2 - Add persistent DressUp toggle (//gs c dressup)
---   @date    Created: 2025-10-05 | Updated: 2025-11-26
---  ═══════════════════════════════════════════════════════════════════════════

local LockstyleManager = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   GLOBAL DRESSUP STATE (Persistent across reloads)
---  ═══════════════════════════════════════════════════════════════════════════

-- File exists = DISABLED, no file = ENABLED (default ON)
local DRESSUP_STATE_FILE = windower.addon_path .. 'data/.dressup_disabled'

--- Read DressUp state from persistent file
--- @return boolean True if DressUp management is enabled (default: true)
local function read_dressup_state()
    local f = io.open(DRESSUP_STATE_FILE, 'r')
    if f then
        f:close()
        return false  -- File exists = disabled
    end
    return true  -- No file = enabled (default)
end

--- Save DressUp enabled state (delete the disable file)
local function save_dressup_enabled()
    os.remove(DRESSUP_STATE_FILE)
end

--- Save DressUp disabled state (create the disable file)
local function save_dressup_disabled()
    local f = io.open(DRESSUP_STATE_FILE, 'w')
    if f then
        f:write('disabled')
        f:close()
    end
end

-- Initialize global state once (shared across all job instances)
if _G.DRESSUP_MANAGEMENT_ENABLED == nil then
    _G.DRESSUP_MANAGEMENT_ENABLED = read_dressup_state()
end

--- Toggle DressUp management globally (persistent)
--- @return boolean New state (true = enabled, false = disabled)
function LockstyleManager.toggle_dressup()
    _G.DRESSUP_MANAGEMENT_ENABLED = not _G.DRESSUP_MANAGEMENT_ENABLED
    if _G.DRESSUP_MANAGEMENT_ENABLED then
        save_dressup_enabled()
    else
        save_dressup_disabled()
    end
    return _G.DRESSUP_MANAGEMENT_ENABLED
end

--- Get current DressUp management state
--- @return boolean Current state
function LockstyleManager.is_dressup_enabled()
    return _G.DRESSUP_MANAGEMENT_ENABLED == true
end

--- Apply an arbitrary lockstyle number with DressUp awareness.
--- Stateless helper usable from anywhere (craft/fish commands, debug, etc).
--- If DressUp management is enabled, unloads dressup, applies the style,
--- and reloads dressup after 3s. Otherwise just sends /lockstyleset directly.
--- @param style number Lockstyle number to apply (0-99, FFXI client limit)
function LockstyleManager.apply_style(style)
    if not style or type(style) ~= 'number' then return end

    if _G.DRESSUP_MANAGEMENT_ENABLED == true then
        send_command('lua unload dressup')
        coroutine.schedule(function()
            send_command('input /lockstyleset ' .. style)
        end, 0.3)
        coroutine.schedule(function()
            send_command('lua load dressup')
        end, 3.0)
    else
        send_command('input /lockstyleset ' .. style)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SHARED DEPENDENCIES (loaded once, reused by every per-job ctx)
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageCore      = require('shared/utils/messages/message_core')

---  ═══════════════════════════════════════════════════════════════════════════
---   PER-INSTANCE OPERATIONS
---  ═══════════════════════════════════════════════════════════════════════════
---
---   Each function takes a `ctx` table built by create():
---     ctx.job_code           string  - 'WAR', 'PLD', ...
---     ctx.default_lockstyle  number
---     ctx.default_subjob     string  - 'SAM', 'RUN', ...
---     ctx.LockstyleConfig    table   - per-job config (with .default + .get_style)
---     ctx.STATE              table   - mutable per-job runtime state
---
---   STATE shape:
---     enabled, is_processing, current_coroutines, dressup_state,
---     last_dressup_command_time, operation_id

local function get_manage_dressup()
    return _G.DRESSUP_MANAGEMENT_ENABLED == true
end

--- Bump operation_id so any in-flight coroutine.schedule callback aborts on its
--- next `operation_id ~= STATE.operation_id` check.
local function cancel_pending_operations(ctx)
    ctx.STATE.operation_id      = ctx.STATE.operation_id + 1
    ctx.STATE.current_coroutines = {}
    ctx.STATE.is_processing      = false
end

--- Send the lockstyleset command now, cycling DressUp if configured to.
local function apply_lockstyle_immediate(ctx, style, operation_id)
    local STATE = ctx.STATE
    if not STATE.enabled then return end
    if operation_id ~= STATE.operation_id then return end

    if not get_manage_dressup() then
        send_command('input /lockstyleset ' .. style)
        STATE.is_processing = false
        return
    end

    local current_time = os.clock()
    if STATE.dressup_state ~= 'unloaded'
       and current_time - STATE.last_dressup_command_time > 0.5 then
        send_command('lua unload dressup')
        STATE.last_dressup_command_time = current_time
        STATE.dressup_state             = 'unloaded'
    end

    coroutine.schedule(function()
        if operation_id ~= STATE.operation_id then return end
        send_command('input /lockstyleset ' .. style)
    end, 0.3)

    -- Reload dressup after 3.0s to give the FFXI server time to apply lockstyle.
    -- Capture FRESH os.clock() inside the coroutine, not the stale outer value.
    coroutine.schedule(function()
        if operation_id ~= STATE.operation_id then return end
        local reload_time = os.clock()
        if reload_time - STATE.last_dressup_command_time > 0.5 then
            send_command('lua load dressup')
            STATE.last_dressup_command_time = reload_time
            STATE.dressup_state             = 'loaded'
            STATE.is_processing             = false
        end
    end, 3.0)
end

--- Schedule a lockstyle change after `delay` (default 2s). Cancels any pending
--- operation first so rapid calls don't pile up.
local function set_lockstyle_with_delay(ctx, style, delay)
    if not ctx.STATE.enabled then return end
    delay = delay or 2.0
    cancel_pending_operations(ctx)
    ctx.STATE.is_processing = true
    local current_operation = ctx.STATE.operation_id
    local coro = coroutine.schedule(function()
        apply_lockstyle_immediate(ctx, style, current_operation)
    end, delay)
    table.insert(ctx.STATE.current_coroutines, coro)
end

--- Compute the lockstyle for the active (job, subjob) pair.
--- @return number style, string subjob
local function resolve_style(ctx)
    local subjob = (player and player.sub_job) or ctx.default_subjob
    local style  = ctx.LockstyleConfig.default or ctx.default_lockstyle
    if ctx.LockstyleConfig.get_style then
        style = ctx.LockstyleConfig.get_style(subjob) or style
    end
    return style, subjob
end

--- Apply the default lockstyle iff the player is on this job.
local function select_default_lockstyle(ctx)
    if not player or player.main_job ~= ctx.job_code then return end
    local style = resolve_style(ctx)
    set_lockstyle_with_delay(ctx, style, 2.0)
end

local function get_lockstyle_info(ctx)
    local style, subjob = resolve_style(ctx)
    return {
        job            = ctx.job_code,
        subjob         = subjob,
        style          = style,
        enabled        = ctx.STATE.enabled,
        manage_dressup = get_manage_dressup(),
    }
end

local function show_lockstyle_config(ctx)
    local info = get_lockstyle_info(ctx)
    local msg  = string.format(
        "[%s] Lockstyle: %s | DressUp: %s | Style: %d",
        info.job,
        info.enabled and "ON" or "OFF",
        info.manage_dressup and "Managed" or "Manual",
        info.style
    )
    if MessageFormatter then
        MessageFormatter.show_info(msg)
    else
        MessageCore.show_lockstyle_status(msg)
    end
end

local function set_lockstyle_enabled(ctx, enabled)
    ctx.STATE.enabled = enabled
    show_lockstyle_config(ctx)
end

local function set_dressup_management(ctx, manage_dressup)
    _G.DRESSUP_MANAGEMENT_ENABLED = manage_dressup
    if manage_dressup then save_dressup_enabled() else save_dressup_disabled() end
    show_lockstyle_config(ctx)
end

--- Load per-job lockstyle config, or build a minimal fallback that always
--- returns `default_lockstyle` so callers can rely on .default / .get_style.
local function load_config_or_fallback(config_path, default_lockstyle)
    local ok, cfg = pcall(require, config_path)
    if ok and cfg then return cfg end
    return {
        default   = default_lockstyle,
        get_style = function() return default_lockstyle end,
    }
end

---  ═══════════════════════════════════════════════════════════════════════════
---   FACTORY
---  ═══════════════════════════════════════════════════════════════════════════

-- Names of globals set by the most recent create() call. Cleared at the top
-- of every new create() so PLD->RDM->... job changes don't accumulate stale
-- _G.cancel_pld_*, _G.set_pld_*, _G.get_pld_* etc. (slow leak: ~5 globals
-- per unique job played per session). Survives across job changes because
-- package.loaded is NOT cleared on FFXI job change (only on gs reload), so
-- this module-local table persists and remembers the previous job's exports.
local last_registered_globals = {}

--- Create a lockstyle module bound to a specific job.
--- @param job_code string Job code (e.g., 'WAR', 'PLD', 'DNC')
--- @param config_path string Path to job lockstyle config (e.g., 'Tetsouo/config/war/WAR_LOCKSTYLE')
--- @param default_lockstyle number Default lockstyle number for this job
--- @param default_subjob string Default subjob (used as fallback when player.sub_job is nil)
--- @return table Per-job lockstyle module
function LockstyleManager.create(job_code, config_path, default_lockstyle, default_subjob)
    local ctx = {
        job_code          = job_code,
        default_lockstyle = default_lockstyle,
        default_subjob    = default_subjob,
        LockstyleConfig   = load_config_or_fallback(config_path, default_lockstyle),
        STATE = {
            enabled                   = true,
            is_processing             = false,
            current_coroutines        = {},
            dressup_state             = 'unknown',
            last_dressup_command_time = 0,
            operation_id              = 0,
        },
    }

    local function bind(fn) return function(...) return fn(ctx, ...) end end

    local api = {
        select_default_lockstyle  = bind(select_default_lockstyle),
        set_lockstyle_with_delay  = bind(set_lockstyle_with_delay),
        get_lockstyle_info        = bind(get_lockstyle_info),
        show_lockstyle_config     = bind(show_lockstyle_config),
        set_lockstyle_enabled     = bind(set_lockstyle_enabled),
        set_dressup_management    = bind(set_dressup_management),
        cancel_pending_operations = bind(cancel_pending_operations),
        get_state                 = function() return ctx.STATE end,
    }
    api.get_info = api.get_lockstyle_info  -- backward-compat alias

    -- Clear globals registered by the previous create() (different job) so
    -- old _G.cancel_pld_*, _G.set_pld_* etc. don't linger after PLD->RDM.
    -- Safe: callers (Mote-Include / commands) only ever look up the active
    -- job's suffixed names; nothing references a previous job's helpers.
    for _, name in ipairs(last_registered_globals) do
        _G[name] = nil
    end
    last_registered_globals = {}

    -- Globals for include() compatibility (unchanged names).
    local jl = job_code:lower()
    local exports = {
        ['select_default_lockstyle']                 = api.select_default_lockstyle,
        ['cancel_' .. jl .. '_lockstyle_operations'] = api.cancel_pending_operations,
        ['set_'    .. jl .. '_lockstyle_enabled']    = api.set_lockstyle_enabled,
        ['set_'    .. jl .. '_dressup_management']   = api.set_dressup_management,
        ['get_'    .. jl .. '_lockstyle_info']       = api.get_lockstyle_info,
        ['show_'   .. jl .. '_lockstyle_config']     = api.show_lockstyle_config,
    }
    for name, fn in pairs(exports) do
        _G[name] = fn
        table.insert(last_registered_globals, name)
    end

    return api
end

return LockstyleManager

---  ═══════════════════════════════════════════════════════════════════════════
---   Universal Systems Auto-Initialization Facade (OPTIMIZED)
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads all universal systems that should be active for ALL jobs/characters.
---   Include this file in each job's main file to enable all universal features.
---
---   **PERFORMANCE OPTIMIZATION:**
---     • Critical systems load immediately (MidcastWatchdog)
---     • Non-critical systems defer to 0.5s (WarpInit, AutoMove, StateDisplay)
---     • Non-blocking initialization
---
---   Usage in character file (e.g., Tetsouo_WAR.lua, KAORIES_BRD.lua):
---     include('../shared/utils/core/INIT_SYSTEMS.lua')
---
---   Systems Initialized:
---     1. Midcast Watchdog (3.5s timeout protection) - CRITICAL
---     2. Warp System (universal warp detection + IPC multi-boxing) - DEFERRED
---     3. AutoMove (movement speed detection) - DEFERRED
---     4. State Display Override (conditional state messages) - DEFERRED
---
---   @file    shared/utils/core/INIT_SYSTEMS.lua
---   @author  Tetsouo
---   @version 1.3 - PERFORMANCE: Deferred loading for non-critical systems
---   @date    Created: 2025-10-28 | Updated: 2025-11-15
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   RESTORE PERSISTENT DEBUG FLAGS (survives job changes)
---  ═══════════════════════════════════════════════════════════════════════════

-- Restore debug flags from windower table (persists across GearSwap reloads)
if windower._gs_debug then
    _G.UPDATE_DEBUG = windower._gs_debug.UPDATE
    _G.AUTOMOVE_DEBUG = windower._gs_debug.UPDATE
end

-- Track total gs reload count (persists across reloads via windower table)
windower._gs_reload_count = (windower._gs_reload_count or 0) + 1

---  ═══════════════════════════════════════════════════════════════════════════
---   LAG DEBUGGER (loaded immediately, lightweight - only active when toggled)
---  ═══════════════════════════════════════════════════════════════════════════

-- LagDebugger is always loaded so //gs c lagdebug works immediately on any job
-- It does nothing unless explicitly started with //gs c lagdebug
if not _G.LagDebugger then
    pcall(require, 'shared/utils/debug/lag_debugger')
end

-- Log reload completion (marks when GearSwap finished loading after job change)
if _G.LagDebugger then
    local job = player and player.main_job or 'UNK'
    local sub = player and player.sub_job  or 'UNK'
    _G.LagDebugger.on_reload_complete(job, sub, windower._automove_seq)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES (LAZY LOADING for performance)
---  ═══════════════════════════════════════════════════════════════════════════

-- MessageInit loaded on-demand (only when showing errors)
local MessageInit = nil

local function ensure_message_init()
    if not MessageInit then
        local success, module = pcall(require, 'shared/utils/messages/formatters/system/message_init')
        if success then
            MessageInit = module
        end
    end
    return MessageInit
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CRITICAL SYSTEM: MIDCAST WATCHDOG (Deferred loading)
---  ═══════════════════════════════════════════════════════════════════════════

-- PERFORMANCE: Defer MidcastWatchdog loading, deferred for fast startup
-- It already starts after 2s delay anyway, so load it then
coroutine.schedule(function()
    local watchdog_success, MidcastWatchdog = pcall(require, 'shared/utils/core/midcast_watchdog')

    if watchdog_success and MidcastWatchdog then
        -- Expose globally for command access (e.g., //gs c watchdog status)
        _G.MidcastWatchdog = MidcastWatchdog
        MidcastWatchdog.start()
        -- Silent init - no message displayed
    else
        ensure_message_init().show_module_load_failed('Watchdog', MidcastWatchdog)
    end
end, 2.0)

---  ═══════════════════════════════════════════════════════════════════════════
---   IMMEDIATE: DUAL-BOX SYNC IPC
---  ═══════════════════════════════════════════════════════════════════════════
-- Registers a Windower IPC listener and the per-command hooks. Loaded
-- synchronously (NOT in the deferred 0.5s block below) so the listener is
-- available immediately after get_sets() returns - otherwise a broadcast
-- arriving in the 0-0.5s window after a job change would be silently dropped
-- (the new job's hooks wouldn't be registered yet, and the previous job's
-- `select_default_lockstyle` closure would no longer match the new job).
--
-- Hooks are re-registered every load (cheap; replaces if present) so the
-- captured `select_default_lockstyle` always points at the freshly-loaded
-- GearSwap globals for the current job.
local sync_ok, SyncIPC = pcall(require, 'shared/utils/dualbox/dualbox_sync_ipc')
if sync_ok and SyncIPC then
    SyncIPC.register_hook('ls', function()
        if select_default_lockstyle then select_default_lockstyle() end
    end)
    SyncIPC.register_hook('lockstyle', function()
        if select_default_lockstyle then select_default_lockstyle() end
    end)
    -- Refill: each instance pulls its own consumables from Case/Sack.
    local refill_hook = function()
        local ok, RefillManager = pcall(require, 'shared/utils/inventory/refill_manager')
        if ok and RefillManager and RefillManager.refill then RefillManager.refill() end
    end
    SyncIPC.register_hook('rf', refill_hook)
    SyncIPC.register_hook('refill', refill_hook)
    SyncIPC.init_listener()
else
    ensure_message_init().show_module_load_failed('DualBox Sync IPC', SyncIPC)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   NON-CRITICAL SYSTEMS: DEFERRED LOADING (0.5s delay to improve startup)
---  ═══════════════════════════════════════════════════════════════════════════

-- PERFORMANCE OPTIMIZATION: Defer non-critical systems to avoid blocking get_sets()
-- These systems are not needed immediately and can load asynchronously
-- Non-blocking initialization
coroutine.schedule(function()
    ---  ─────────────────────────────────────────────────────────────────────────
    ---   SYSTEM 2: WARP SYSTEM (with IPC Multi-Boxing Support)
    ---  ─────────────────────────────────────────────────────────────────────────

    local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')

    if warp_success and WarpInit then
        local ok_init, err_init = pcall(WarpInit.init)
        if not ok_init then
            ensure_message_init().show_module_load_failed('Warp System init()', err_init)
        end
    else
        ensure_message_init().show_module_load_failed('Warp System', WarpInit)
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   SYSTEM 3: AUTOMOVE (Movement Detection)
    ---  ─────────────────────────────────────────────────────────────────────────

    -- Check if job wants to disable AutoMove (e.g., BST uses custom movement system)
    if _G.DISABLE_AUTOMOVE ~= true then
        -- IMPORTANT: AutoMove uses include() not require() because it's a GearSwap script,
        -- not a Lua module. It registers event handlers in global scope.
        local automove_success, automove_error = pcall(include, '../shared/utils/movement/automove.lua')

        if automove_success then
            -- Start AutoMove explicitly (no longer auto-starts on include)
            if AutoMove and AutoMove.start then
                AutoMove.start()
            end
        else
            ensure_message_init().show_module_load_failed('AutoMove', automove_error)
        end
        -- Silent init when successful
    else
        -- AutoMove disabled by job (custom movement system used)
        -- Silent - no message needed (job explicitly requested this)
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   SYSTEM 4: STATE DISPLAY OVERRIDE (Conditional State Messages)
    ---  ─────────────────────────────────────────────────────────────────────────

    local state_display_success, StateDisplayOverride = pcall(require, 'shared/utils/core/state_display_override')

    if state_display_success and StateDisplayOverride then
        -- Override Mote-Include's display_current_state globally
        StateDisplayOverride.init()
        -- Silent init
    else
        ensure_message_init().show_module_load_failed('State Display Override', StateDisplayOverride)
    end
end, 0.5)  -- Defer by 0.5 seconds (non-blocking)

---  ═══════════════════════════════════════════════════════════════════════════
---   SYSTEM 5: FUTURE SYSTEMS
---  ═══════════════════════════════════════════════════════════════════════════

-- Example template for adding new universal systems:
--
-- local system_success, SystemModule = pcall(require, 'shared/utils/path/to/system')
-- if system_success and SystemModule then
--     SystemModule.init()
-- else
--     MessageInit.show_module_load_failed('System Name', SystemModule)
-- end

---  ═══════════════════════════════════════════════════════════════════════════
---   INITIALIZATION COMPLETE
---  ═══════════════════════════════════════════════════════════════════════════

-- All universal systems initialized
-- Individual system messages displayed above (if any errors occurred)
-- This is a pure initialization script - no return value needed

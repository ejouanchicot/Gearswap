---  ═══════════════════════════════════════════════════════════════════════════
---   Universal Systems Auto-Initialization Façade (OPTIMIZED)
---  ═══════════════════════════════════════════════════════════════════════════
---   Loads all universal systems that should be active for ALL jobs/characters.
---   Include this file in each job's main file to enable all universal features.
---
---   **PERFORMANCE OPTIMIZATION:**
---     • Critical systems load immediately (MidcastWatchdog)
---     • Non-critical systems defer to 0.5s (WarpInit, AutoMove, StateDisplay)
---     • Saves ~30-50ms during job loading (non-blocking)
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

-- PERFORMANCE: Defer MidcastWatchdog loading to save ~3-5ms at startup
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
---   NON-CRITICAL SYSTEMS: DEFERRED LOADING (0.5s delay to improve startup)
---  ═══════════════════════════════════════════════════════════════════════════

-- PERFORMANCE OPTIMIZATION: Defer non-critical systems to avoid blocking get_sets()
-- These systems are not needed immediately and can load asynchronously
-- Saves ~30-50ms during job loading
coroutine.schedule(function()
    ---  ─────────────────────────────────────────────────────────────────────────
    ---   SYSTEM 2: WARP SYSTEM (with IPC Multi-Boxing Support)
    ---  ─────────────────────────────────────────────────────────────────────────

    local warp_success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')

    if warp_success and WarpInit then
        WarpInit.init()
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

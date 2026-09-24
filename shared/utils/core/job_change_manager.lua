---============================================================================
--- Job Change Manager - Debounced reload on job/subjob change
---============================================================================
--- Called from every job's job_sub_job_change(). Tears the running systems
--- down at once (AutoMove, MidcastWatchdog, UI), then sends `gs reload` after
--- a debounce: 0.5 s when the main job is the one this environment was loaded
--- for, 3.0 s otherwise. Every new change bumps debounce_counter, so only the
--- last change of a burst reloads. A normal main job change never reaches
--- on_job_change(): GearSwap reloads the job file by itself.
---
--- @file    shared/utils/core/job_change_manager.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-03
---============================================================================

local JobChangeManager = {}

local DebugLogger = require('shared/utils/debug/debug_logger')

-- MessageFormatter lazy-loaded (only when showing error messages)
local MessageFormatter = nil
local function get_MessageFormatter()
    if not MessageFormatter then
        local success
        success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if not success then MessageFormatter = nil end
    end
    return MessageFormatter
end

-- State lives on _G, not in a module local: the entry point requires this
-- module before ModuleCache is installed, so the same sandbox can hold two
-- instances of it (entry's and the cached one). _G is what they share. It does
-- NOT survive a job file load: the sandbox, and its _G, are rebuilt each time.
if not _G.JobChangeManagerSTATE then
    _G.JobChangeManagerSTATE = {
        -- Current job state
        current_main_job          = nil,
        current_sub_job           = nil,

        -- Target job state (what we're changing TO after debounce)
        target_main_job           = nil,
        target_sub_job            = nil,

        -- Debounce state
        debounce_timer            = nil,
        debounce_counter          = 0,  -- Increments on each change to invalidate old timers

        -- Global registry of all job lockstyle cancel functions
        lockstyle_cancel_registry = {}
    }
end

local STATE = _G.JobChangeManagerSTATE

--- Invalidate any scheduled reload.
local function cancel_all_pending()
    -- Bumping the counter invalidates any in-flight coroutine: the scheduled
    -- closure compares my_counter to STATE.debounce_counter and aborts on
    -- mismatch. Clearing the timer reference alone does NOT stop a coroutine
    -- already queued via coroutine.schedule.
    STATE.debounce_counter = STATE.debounce_counter + 1
    STATE.debounce_timer = nil
end

--- Stop the running systems before the reload: their coroutines outlive the
--- sandbox, so they would otherwise keep running until the next load.
local function cleanup_all_systems()
    -- 1. Stop AutoMove (movement detection coroutine)
    if AutoMove and AutoMove.stop then
        pcall(AutoMove.stop)
    end

    -- 2. Stop MidcastWatchdog (background check coroutine)
    if _G.MidcastWatchdog and _G.MidcastWatchdog.stop then
        pcall(_G.MidcastWatchdog.stop)
    end

    -- 3. Destroy UI (texts element + state cache)
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.destroy then
        pcall(KeybindUI.destroy)
    end

    -- 4. Clear UI globals to prevent leaks
    _G.keybind_ui_display = nil
    _G.keybind_ui_visible = false

    -- 5. Clear UI state cache
    if _G.ui_manager_state then
        _G.ui_manager_state.current_job = nil
        _G.ui_manager_state.current_subjob = nil
        _G.ui_manager_state.pending_update_id = 0
        _G.ui_manager_state.update_in_progress = false
    end

    -- 6. Stop any pending smart_init coroutines
    if _G.ui_manager_state then
        _G.ui_manager_state.smart_init_id = (_G.ui_manager_state.smart_init_id or 0) + 1
    end

    if _G.LagDebugger then _G.LagDebugger.on_cleanup() end
    DebugLogger.log_if('JOBCHANGE_DEBUG', 'JCM', 'cleanup_all_systems() completed')
end

--- Seed the job state this manager compares against, once per environment.
---
--- Deliberately a seed and not an assignment. Mote calls `user_setup()` BEFORE
--- `job_sub_job_change()` (Mote-Include.lua:981-988), and every job's
--- user_setup calls this. Overwriting here meant `current_sub_job` already held
--- the NEW subjob by the time `on_job_change()` compared them, so the
--- subjob-only branch could never be true and every change waited the full
--- main-job delay. Seeding only when unset keeps the value captured at load
--- time, which is what the comparison actually needs.
--- @param config table Unused, kept for the call sites that pass job modules
function JobChangeManager.initialize(config)
    if not player then
        return
    end
    if STATE.current_main_job == nil then
        STATE.current_main_job = player.main_job
    end
    if STATE.current_sub_job == nil then
        STATE.current_sub_job = player.sub_job
    end
end

--- Handle a job/subjob change (call from job_sub_job_change): clean up now,
--- `gs reload` after the debounce delay.
--- @param main_job string New main job
--- @param sub_job string New subjob
function JobChangeManager.on_job_change(main_job, sub_job)
    if not main_job or not sub_job then
        return
    end

    DebugLogger.logf_if('JOBCHANGE_DEBUG', 'JCM',
        'on_job_change called: %s/%s -> %s/%s | counter=%d',
        tostring(STATE.current_main_job), tostring(STATE.current_sub_job),
        main_job, sub_job, STATE.debounce_counter)

    -- Cleanup happens now, before the delay, so AutoMove, the watchdog and
    -- the UI do not keep acting on the old job while the reload is pending.
    if _G.LagDebugger then _G.LagDebugger.on_job_change(main_job, sub_job) end
    cleanup_all_systems()

    -- Only read by the debug displays
    STATE.target_main_job = main_job
    STATE.target_sub_job = sub_job

    -- Increment counter to invalidate previous debounce timers
    STATE.debounce_counter = STATE.debounce_counter + 1
    local my_counter = STATE.debounce_counter

    -- Only a main job change needs the long delay. Keyed on the main job alone:
    -- a subjob round trip (WAR -> DNC -> WAR inside the window) ends where it
    -- started, and the old test read "same subjob" as a main job change. The
    -- reload itself still has to happen - cleanup_all_systems() above has
    -- already torn the UI and AutoMove down.
    local delay = 3.0
    if STATE.current_main_job == main_job then
        delay = 0.5
    end

    -- Clearing the handle does not stop a queued coroutine; the counter above does.
    STATE.debounce_timer = nil

    STATE.debounce_timer = coroutine.schedule(function()
        if my_counter ~= STATE.debounce_counter then
            DebugLogger.logf_if('JOBCHANGE_DEBUG', 'JCM',
                'ABORT reload: my_counter=%d != current=%d',
                my_counter, STATE.debounce_counter)
            return  -- Newer change queued, abort this reload
        end

        if _G.LagDebugger then _G.LagDebugger.on_gs_reload(delay) end
        DebugLogger.logf_if('JOBCHANGE_DEBUG', 'JCM',
            'EXECUTING reload: counter=%d, %s/%s',
            my_counter, main_job, sub_job)

        -- Update current job state before reload
        STATE.current_main_job = main_job
        STATE.current_sub_job = sub_job

        -- Reloads the job file only (not the addon), the same thing GearSwap
        -- does on a main job change.
        windower.send_command('gs reload')
    end, delay)
end

--- Immediate `gs reload` (no debounce, no cleanup), for //gs c reload.
--- @param main_job string|nil Defaults to player.main_job
--- @param sub_job string|nil Defaults to player.sub_job
function JobChangeManager.force_reload(main_job, sub_job)
    main_job = main_job or (player and player.main_job)
    sub_job  = sub_job or (player and player.sub_job)

    if not main_job or not sub_job then
        local mf = get_MessageFormatter()
        if mf then
            mf.show_error("Cannot reload: Job data not available")
        end
        return
    end

    STATE.current_main_job = main_job
    STATE.current_sub_job = sub_job

    -- Increment counter to invalidate any pending debounced changes
    STATE.debounce_counter = STATE.debounce_counter + 1

    windower.send_command('gs reload')
end

--- Cancel the pending reload and every registered lockstyle operation
--- (called from each entry point's file_unload).
function JobChangeManager.cancel_all()
    cancel_all_pending()

    for _, cancel_func in pairs(STATE.lockstyle_cancel_registry) do
        if cancel_func then
            pcall(cancel_func)
        end
    end
end

--- Register a job's lockstyle cancel function, run by cancel_all().
--- @param job_name string Registry key (job code)
--- @param cancel_func function Cancels that job's pending lockstyle
function JobChangeManager.register_lockstyle_cancel(job_name, cancel_func)
    STATE.lockstyle_cancel_registry[job_name] = cancel_func
end

return JobChangeManager
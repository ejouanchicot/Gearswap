-- JobChangeManager: debounced job/subjob change handling with full GearSwap reload.
-- 3.0s debounce for main job, 0.5s for subjob. Guarantees clean state on every change.

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

-- State persisted in _G to survive module reloads (resets on full GearSwap reload)
-- (Reload GearSwap will reset these, but they persist during debounce delays)
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


--- Cancel all pending operations
local function cancel_all_pending()
    -- Bumping the counter invalidates any in-flight coroutine: the scheduled
    -- closure compares my_counter to STATE.debounce_counter and aborts on
    -- mismatch. Clearing the timer reference alone does NOT stop a coroutine
    -- already queued via coroutine.schedule.
    STATE.debounce_counter = STATE.debounce_counter + 1
    STATE.debounce_timer = nil
end

--- Cleanup all systems before job change/reload
--- This prevents memory leaks and zombie coroutines
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


--- Initialize job change manager with current job state
--- NOTE: This now only sets initial job state (module references removed)
function JobChangeManager.initialize(config)
    -- Set initial job state
    if player then
        STATE.current_main_job = player.main_job
        STATE.current_sub_job  = player.sub_job
    end
end

--- Handle job change event (call from job_sub_job_change)
--- Full GearSwap reload to guarantee a clean state
function JobChangeManager.on_job_change(main_job, sub_job)
    if not main_job or not sub_job then
        return
    end

    -- DEBUG: Track job changes
    DebugLogger.logf_if('JOBCHANGE_DEBUG', 'JCM',
        'on_job_change called: %s/%s -> %s/%s | counter=%d',
        tostring(STATE.current_main_job), tostring(STATE.current_sub_job),
        main_job, sub_job, STATE.debounce_counter)

    -- CRITICAL: Cleanup all systems IMMEDIATELY to prevent:
    -- - AutoMove command spam during reload
    -- - UI memory leaks
    -- - Zombie watchdog coroutines
    if _G.LagDebugger then _G.LagDebugger.on_job_change(main_job, sub_job) end
    cleanup_all_systems()

    -- Update target job
    STATE.target_main_job = main_job
    STATE.target_sub_job = sub_job

    -- Increment counter to invalidate previous debounce timers
    STATE.debounce_counter = STATE.debounce_counter + 1
    local my_counter = STATE.debounce_counter

    -- Determine debounce delay based on change type
    local delay = 3.0  -- Default: main job change
    if STATE.current_main_job == main_job and STATE.current_sub_job ~= sub_job then
        delay = 0.5  -- Faster for subjob-only changes
    end

    -- Cancel previous debounce timer
    STATE.debounce_timer = nil

    -- Schedule reload with debounce
    STATE.debounce_timer = coroutine.schedule(function()
        -- Verify counter (prevent outdated execution)
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

        -- Reload job file only (NOT full addon reload - much faster)
        -- 'gs reload' reloads only the character file, preserving addon state
        -- This is what happens on main job change - fast and clean
        windower.send_command('gs reload')

        -- Note: Code after this line won't execute (GearSwap reloaded)
    end, delay)
end

--- Force immediate job change (skip debounce, for manual triggers)
--- Force immediate GearSwap reload
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

    -- Update state
    STATE.current_main_job = main_job
    STATE.current_sub_job = sub_job

    -- Increment counter to invalidate any pending debounced changes
    STATE.debounce_counter = STATE.debounce_counter + 1

    -- Reload job file immediately (no debounce) - fast reload
    windower.send_command('gs reload')
end

--- Cancel all pending operations (for cleanup in file_unload)
function JobChangeManager.cancel_all()
    cancel_all_pending()

    -- Cancel all registered job lockstyle operations
    for job_name, cancel_func in pairs(STATE.lockstyle_cancel_registry) do
        if cancel_func then
            pcall(cancel_func)
        end
    end
end

--- Register a job's lockstyle cancel function
function JobChangeManager.register_lockstyle_cancel(job_name, cancel_func)
    STATE.lockstyle_cancel_registry[job_name] = cancel_func
end

return JobChangeManager
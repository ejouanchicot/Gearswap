---  ═══════════════════════════════════════════════════════════════════════════
---   Job Change Manager - Robust Job Change Coordination System
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles job/subjob changes with debouncing and sequential coordination to
---   prevent conflicts between lockstyle, macros, keybinds, and UI systems.
---
---   Features:
---     - Debouncing for rapid job changes
---     - Cancellation of pending operations
---     - Sequential execution with proper delays
---     - UI destroy/rebuild coordination
---     - Keybind unbind/rebind management
---
---   @file    shared/utils/core/job_change_manager.lua
---   @author  Tetsouo
---   @version 1.3 - Bug fixes + refactoring (fix undefined var, remove coroutine.close, optimize MessageFormatter)
---   @date    Created: 2025-10-02 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local JobChangeManager = {}

-- Load MessageFormatter once (cached for all usages)
local MessageFormatter_success, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')

-- Load lockstyle timing configuration
local LockstyleConfig = _G.LockstyleConfig or {}  -- Loaded from character main file
if not LockstyleConfig or type(LockstyleConfig) ~= 'table' or not LockstyleConfig.cooldown then
    -- Fallback defaults if config not found
    LockstyleConfig = {
        initial_load_delay   = 8.0,
        job_change_delay     = 8.0,
        cooldown             = 15.0
    }
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE MANAGEMENT (PERSISTED GLOBALLY TO SURVIVE RELOADS)
---  ═══════════════════════════════════════════════════════════════════════════

-- Use global scope to persist STATE between module reloads
-- (Mote-Include reloads the Lua file on every subjob change)
if not _G.JobChangeManagerSTATE then
    _G.JobChangeManagerSTATE = {
        -- Current job state
        current_main_job          = nil,
        current_sub_job           = nil,

        -- Target job state (what we're changing TO after debounce)
        target_main_job           = nil,
        target_sub_job            = nil,

        -- Processing state
        is_changing               = false,
        debounce_timer            = nil,
        debounce_counter          = 0,  -- Increments on each change to invalidate old timers
        pending_coroutines        = {},

        -- Configuration
        debounce_delay            = 3.0,  -- Wait 3.0s before applying changes

        -- Lockstyle cooldown tracking (from LOCKSTYLE_CONFIG.lua)
        last_lockstyle_time       = 0,  -- os.time() of last lockstyle application
        lockstyle_cooldown        = LockstyleConfig.cooldown,  -- Configured cooldown (default: 15s)

        -- Module references (set during initialization)
        keybind_module            = nil,
        ui_module                 = nil,
        lockstyle_func            = nil,
        macrobook_func            = nil,

        -- Global registry of all job lockstyle cancel functions
        lockstyle_cancel_registry = {}
    }
end

local STATE = _G.JobChangeManagerSTATE

---  ═══════════════════════════════════════════════════════════════════════════
---   UTILITY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Cancel all pending operations
local function cancel_all_pending()
    -- Cancel debounce timer (clear reference, GC will clean up)
    STATE.debounce_timer = nil

    -- Cancel all coroutines (clear references, scheduled coroutines complete naturally)
    STATE.pending_coroutines = {}

    STATE.is_changing = false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CLEANUP PHASE
---  ═══════════════════════════════════════════════════════════════════════════

--- Cleanup current job setup (unbind keybinds, destroy UI, stop coroutines, clear callbacks)
local function cleanup_current_setup()
    -- Unbind keybinds
    if STATE.keybind_module and type(STATE.keybind_module) == 'table' and STATE.keybind_module.unbind_all then
        STATE.keybind_module.unbind_all()
    end

    -- Destroy UI
    if STATE.ui_module and type(STATE.ui_module) == 'table' and STATE.ui_module.destroy then
        STATE.ui_module.destroy()
    end

    -- Stop infinite coroutines (prevent memory leaks)
    if _G.MidcastWatchdog and type(_G.MidcastWatchdog.stop) == 'function' then
        _G.MidcastWatchdog.stop()
    end

    if _G.AutoMove and type(_G.AutoMove.stop) == 'function' then
        _G.AutoMove.stop()
    end

    -- Clear callback registries (prevent accumulation)
    if _G.AutoMove and type(_G.AutoMove.clear_callbacks) == 'function' then
        _G.AutoMove.clear_callbacks()
    end

    -- Reinitialize AutoMove position to prevent false movement detection
    -- Without this, old position data from previous job causes movement gear to equip incorrectly
    if _G.AutoMove and type(_G.AutoMove.reinit_position) == 'function' then
        _G.AutoMove.reinit_position()
    end

    -- CRITICAL: Reset movement state to prevent stale state from old job
    -- This prevents MoveSpeed gear being equipped when idle after job change
    if _G.state and _G.state.Moving then
        _G.state.Moving.value = 'false'
    end

    local warp_detector_success, WarpDetector = pcall(require, 'shared/utils/warp/warp_detector')
    if warp_detector_success and WarpDetector and type(WarpDetector.clear_callbacks) == 'function' then
        WarpDetector.clear_callbacks()
    end

    -- Clear job-specific global state (prevent state corruption between jobs)
    -- These variables persist across job changes and can cause issues if not cleaned
    local job_globals_to_clear = {
        -- COR (Corsair) - Roll tracking and party management
        'cor_active_rolls',
        'cor_last_roll',
        'cor_natural_eleven_active',
        'cor_last_roll_display',
        'cor_party_jobs',
        'cor_party_state',
        'cor_lockstyle_watchdog_active',
        'cor_lockstyle_watchdog',
        'cor_pending_roll_value',
        'cor_pending_roll_timestamp',
        'cor_crooked_timestamp',
        'cor_action_event_id',
        'cor_party_event_id',

        -- THF (Thief) - Sneak Attack / Trick Attack tracking
        'thf_sa_pending',
        'thf_ta_pending',

        -- DRK (Dark Knight) - Buff anticipation
        'drk_dark_seal_pending',
        'drk_nether_void_pending',

        -- BST (Beastmaster) - Ready move tracking
        'bst_rdymove_active',

        -- DNC (Dancer) - Climactic Flourish tracking
        'dnc_climactic_timestamp',

        -- BLM (Black Mage) - Arts tracking
        'BLM_ARTS_LAST_CAST',

        -- BRD (Bard) - Song tracking (if any exist)
        'brd_song_state',

        -- Add more job-specific globals as discovered
    }

    for _, var_name in ipairs(job_globals_to_clear) do
        if _G[var_name] ~= nil then
            _G[var_name] = nil
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   APPLY PHASE
---  ═══════════════════════════════════════════════════════════════════════════

--- Apply new job setup with parallel execution
--- @param main_job string Main job
--- @param sub_job string Sub job
--- @param expected_counter number Counter value to verify at each step
local function apply_job_setup(main_job, sub_job, expected_counter)
    -- PARALLEL EXECUTION: Lockstyle runs independently, keybinds/UI run fast

    -- Path 1: Fast path for keybinds/UI (doesn't wait for lockstyle)
    -- Step 1: Apply macros (1s delay for FFXI macro bug)
    local macro_coro = coroutine.schedule(function()
        if expected_counter ~= STATE.debounce_counter then return end  -- Outdated, abort

        if STATE.macrobook_func and type(STATE.macrobook_func) == 'function' then
            STATE.macrobook_func()
        end

        -- Step 2: Rebind keybinds immediately after macros
        local keybind_coro = coroutine.schedule(function()
            if expected_counter ~= STATE.debounce_counter then return end  -- Outdated, abort

            if STATE.keybind_module and type(STATE.keybind_module) == 'table' and STATE.keybind_module.bind_all then
                STATE.keybind_module.bind_all()
            end

            -- Step 3: Rebuild UI immediately after keybinds
            local ui_coro = coroutine.schedule(function()
                if expected_counter ~= STATE.debounce_counter then return end  -- Outdated, abort

                -- Use init() directly instead of smart_init() since states are already ready
                if STATE.ui_module and type(STATE.ui_module) == 'table' and STATE.ui_module.init then
                    STATE.ui_module.init()
                end

                -- All done
                STATE.is_changing = false

                -- Show success message
                if MessageFormatter_success and MessageFormatter then
                    MessageFormatter.show_success(string.format("Job change complete: %s/%s", main_job, sub_job))
                end
            end, 0.1)

            table.insert(STATE.pending_coroutines, ui_coro)
        end, 0.1)

        table.insert(STATE.pending_coroutines, keybind_coro)
    end, 1.0)

    table.insert(STATE.pending_coroutines, macro_coro)

    -- Path 2: Lockstyle runs in parallel (independent, doesn't block anything)
    -- Calculate delay before applying lockstyle (respect FFXI cooldown)
    local time_since_last_lockstyle = os.time() - STATE.last_lockstyle_time
    local lockstyle_delay           = LockstyleConfig.job_change_delay  -- From LOCKSTYLE_CONFIG (default: 8s)

    -- If lockstyle was applied recently, wait for cooldown to expire
    if time_since_last_lockstyle < STATE.lockstyle_cooldown then
        local additional_delay = STATE.lockstyle_cooldown - time_since_last_lockstyle
        lockstyle_delay        = lockstyle_delay + additional_delay

        -- Show warning to user
        if MessageFormatter_success and MessageFormatter then
            MessageFormatter.show_warning(string.format("Lockstyle cooldown: waiting %.1fs", additional_delay))
        end
    end

    -- Apply lockstyle independently (doesn't block keybinds/UI)
    local lockstyle_coro = coroutine.schedule(function()
        if expected_counter ~= STATE.debounce_counter then return end  -- Outdated, abort

        -- Update timestamp BEFORE applying lockstyle (reserve the slot)
        STATE.last_lockstyle_time = os.time()

        if STATE.lockstyle_func and type(STATE.lockstyle_func) == 'function' then
            -- Job lockstyle module applies lockstyle (no additional delay inside)
            STATE.lockstyle_func()
        end
    end, lockstyle_delay)  -- Runs in parallel, doesn't block anything

    table.insert(STATE.pending_coroutines, lockstyle_coro)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEBOUNCING
---  ═══════════════════════════════════════════════════════════════════════════

--- Execute job change after debounce delay
--- @param main_job string Main job
--- @param sub_job string Sub job
--- @param expected_counter number The counter value when this execution was scheduled
local function execute_job_change(main_job, sub_job, expected_counter)
    -- Double-check counter hasn't changed (race condition protection)
    if expected_counter ~= STATE.debounce_counter then
        return  -- Outdated execution, abort
    end

    -- Block any concurrent executions
    if STATE.is_changing then
        return  -- Already executing another change
    end

    -- Cancel any pending operations
    cancel_all_pending()

    -- Mark as changing
    STATE.is_changing = true

    -- Update current job state
    STATE.current_main_job = main_job
    STATE.current_sub_job  = sub_job

    -- Clear target state (we're executing it now)
    STATE.target_main_job  = nil
    STATE.target_sub_job   = nil

    -- Cleanup phase (immediate)
    cleanup_current_setup()

    -- Apply phase (with delays, passing counter for verification)
    apply_job_setup(main_job, sub_job, expected_counter)
end

--- Debounced job change handler
--- @param main_job string Main job
--- @param sub_job string Sub job
local function debounced_job_change(main_job, sub_job)
    -- Update target job
    STATE.target_main_job = main_job
    STATE.target_sub_job  = sub_job

    -- Increment counter to invalidate previous timers
    STATE.debounce_counter = STATE.debounce_counter + 1
    local my_counter       = STATE.debounce_counter

    -- Determine debounce delay based on change type
    local delay            = STATE.debounce_delay

    -- If only subjob changed (main job stayed same), use shorter debounce
    if STATE.current_main_job == main_job and STATE.current_sub_job ~= sub_job then
        delay = 0.5  -- Shorter delay for subjob-only changes
    end

    -- Create new debounce timer
    STATE.debounce_timer = coroutine.schedule(function()
        -- Pass the counter to execute_job_change for double-verification
        execute_job_change(STATE.target_main_job, STATE.target_sub_job, my_counter)
        STATE.debounce_timer = nil
    end, delay)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PUBLIC API
---  ═══════════════════════════════════════════════════════════════════════════

--- Initialize job change manager with module references
--- @param config table Configuration {keybinds, ui, lockstyle, macrobook}
function JobChangeManager.initialize(config)
    if not config then
        error("JobChangeManager.initialize: config table required")
        return
    end

    STATE.keybind_module = config.keybinds
    STATE.ui_module      = config.ui
    STATE.lockstyle_func = config.lockstyle
    STATE.macrobook_func = config.macrobook

    -- Set initial job state
    if player then
        STATE.current_main_job = player.main_job
        STATE.current_sub_job  = player.sub_job
    end
end

--- Handle job change event (call from job_change event)
--- @param main_job string New main job
--- @param sub_job string New sub job
function JobChangeManager.on_job_change(main_job, sub_job)
    if not main_job or not sub_job then
        return
    end

    -- ALWAYS debounce, even if job didn't change
    -- Let the debouncing and counter system handle duplicates
    -- The counter ensures only the latest executes
    debounced_job_change(main_job, sub_job)
end

--- Force immediate job change (skip debounce, for manual triggers)
--- @param main_job string Main job
--- @param sub_job string Sub job
function JobChangeManager.force_reload(main_job, sub_job)
    main_job = main_job or (player and player.main_job)
    sub_job  = sub_job or (player and player.sub_job)

    if not main_job or not sub_job then
        if MessageFormatter_success and MessageFormatter then
            MessageFormatter.show_error("Cannot reload: Job data not available")
        end
        return
    end

    -- Increment counter to invalidate any pending debounced changes
    STATE.debounce_counter = STATE.debounce_counter + 1

    -- Execute immediately with current counter
    execute_job_change(main_job, sub_job, STATE.debounce_counter)
end

--- Cancel all pending operations (for cleanup)
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
--- @param job_name string Job name (e.g., "WAR", "PLD")
--- @param cancel_func function Function to cancel lockstyle operations
function JobChangeManager.register_lockstyle_cancel(job_name, cancel_func)
    STATE.lockstyle_cancel_registry[job_name] = cancel_func
end

--- Get current processing state
--- @return boolean True if job change in progress
function JobChangeManager.is_processing()
    return STATE.is_changing
end

--- Set debounce delay
--- @param delay number Delay in seconds
function JobChangeManager.set_debounce_delay(delay)
    if type(delay) == "number" and delay > 0 then
        STATE.debounce_delay = delay
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return JobChangeManager

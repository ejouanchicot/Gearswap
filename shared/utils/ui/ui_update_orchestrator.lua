---============================================================================
--- UI Update Orchestrator - Update / ForceReinit / Schedule / Status
---============================================================================
--- Coordinates UI redraws and reinits with debouncing, cancellation tokens
--- and state-change detection. The main entry points:
---   • update()                       - state-aware redraw (skips if no change)
---   • force_reinit()                 - destroy + init with timeout polling
---   • schedule_update()              - debounced update with cancel token
---   • handle_job_configuration_change - dispatched by JobChangeManager
---
--- Bonus over previous version: 5 raw add_to_chat(207, '[UPDATE_DEBUG]') calls
--- migrated to MessageFormatter.show_debug('UI', ...) - consistent with the
--- entry-point migration done earlier.
---
--- @file ui/ui_update_orchestrator.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local Display      = require('shared/utils/ui/ui_display')
local StateTracker = require('shared/utils/ui/ui_state_tracker')
local Lifecycle    = require('shared/utils/ui/ui_lifecycle')

local Orchestrator = {}

--- Lazy debug log. Loads MessageFormatter only when UPDATE_DEBUG is on
--- (zero cost otherwise). Tag is always 'UI' so console traces are aligned
--- with the entry-point [job_update] traces.
--- @param msg string Debug message
local function debug_log(msg)
    if not _G.UPDATE_DEBUG then return end
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    MessageFormatter.show_debug('UI', msg)
end

--- Attach orchestrator methods to the given KeybindUI table.
--- MUST be called AFTER Lifecycle.attach() because update() calls safe_init()
--- and force_reinit() calls init().
--- @param KeybindUI table The KeybindUI module table to populate
function Orchestrator.attach(KeybindUI)
    --- Update UI when states change with error handling.
    --- Only redraws if states have actually changed (prevents redraw spam).
    function KeybindUI.update()
        local debug_start
        if _G.UPDATE_DEBUG then
            debug_start = os.clock()
            debug_log(string.format('[UPDATE_DEBUG] UI.update START | t=%.3f', debug_start))
        end

        if not _G.keybind_ui_display then
            debug_log('[UPDATE_DEBUG] UI.update -> safe_init (no display)')
            KeybindUI.safe_init()
            return
        end

        -- STATE CHANGE DETECTION: Only update if states actually changed
        local current_states = StateTracker.capture_current_states()
        if not StateTracker.have_states_changed(current_states) then
            debug_log('[UPDATE_DEBUG] UI.update SKIPPED (states unchanged)')
            return
        end

        -- States changed, update display
        debug_log('[UPDATE_DEBUG] UI.update -> update_display (states changed)')
        local ui_state = _G.ui_manager_state
        local success, error_msg = pcall(Display.update_display)
        if not success then
            ui_state.consecutive_failures = ui_state.consecutive_failures + 1
            ui_state.last_error = error_msg

            -- Try to recover if too many failures
            if ui_state.consecutive_failures > 5 then
                coroutine.schedule(function()
                    KeybindUI.force_reinit(player.main_job, 5.0)
                end, 2.0)
            end
        else
            ui_state.consecutive_failures = 0
            ui_state.last_update = os.clock()
            -- Cache states for next comparison
            ui_state.cached_states = current_states
        end

        if _G.UPDATE_DEBUG and debug_start then
            local debug_end = os.clock()
            debug_log(string.format('[UPDATE_DEBUG] UI.update DONE | took=%.3fms', (debug_end - debug_start) * 1000))
        end
    end

    --- Force complete UI reinitialization with cancel support.
    --- Uses cancel ID system (similar to JCM counter) to handle rapid job changes.
    --- Uses coroutine.schedule() for non-blocking state checking.
    function KeybindUI.force_reinit(job_name, max_wait_time)
        local ui_state = _G.ui_manager_state

        -- Cancel any previous force_reinit by incrementing cancel ID
        ui_state.update_cancel_id = ui_state.update_cancel_id + 1
        local my_cancel_id = ui_state.update_cancel_id

        -- Always destroy UI first (even if update_in_progress from previous call)
        KeybindUI.destroy()

        -- Mark as updating
        ui_state.update_in_progress = true
        max_wait_time = max_wait_time or 3

        -- If states are ready, initialize immediately
        if Lifecycle.are_states_ready() then
            local success = pcall(KeybindUI.init)
            if success then
                ui_state.last_successful_update = os.clock()
                ui_state.consecutive_failures = 0
                ui_state.update_count = ui_state.update_count + 1
                ui_state.cached_states = {}
            else
                ui_state.consecutive_failures = ui_state.consecutive_failures + 1
            end
            ui_state.update_in_progress = false
            return success
        end

        -- States not ready, use scheduled polling
        local start_time = os.clock()
        local check_interval = 0.2

        local function try_reinit()
            -- Check if cancelled
            if ui_state.update_cancel_id ~= my_cancel_id then
                ui_state.update_in_progress = false
                return false
            end

            -- Check if states are ready
            if Lifecycle.are_states_ready() then
                local success = pcall(KeybindUI.init)
                if success then
                    ui_state.last_successful_update = os.clock()
                    ui_state.consecutive_failures = 0
                    ui_state.update_count = ui_state.update_count + 1
                    ui_state.cached_states = {}
                else
                    ui_state.consecutive_failures = ui_state.consecutive_failures + 1
                end
                ui_state.update_in_progress = false
                return success
            end

            -- Check timeout
            if (os.clock() - start_time) > max_wait_time then
                -- Timeout, init anyway
                local success = pcall(KeybindUI.init)
                ui_state.update_in_progress = false
                return success
            end

            -- Reschedule
            coroutine.schedule(try_reinit, check_interval)
        end

        -- Start polling
        coroutine.schedule(try_reinit, check_interval)
        return true -- Return immediately, actual result comes async
    end

    --- Schedule UI update with intelligent debouncing
    function KeybindUI.schedule_update(reason, delay)
        delay = delay or 1.0
        local ui_state = _G.ui_manager_state

        -- Increment update ID to cancel previous pending updates
        ui_state.pending_update_id = ui_state.pending_update_id + 1
        local my_update_id = ui_state.pending_update_id

        -- Schedule the update
        coroutine.schedule(function()
            -- Check if this update is still valid
            if ui_state.pending_update_id ~= my_update_id then
                return
            end

            -- Check if job/subjob changed since scheduling
            if player and (ui_state.current_job ~= player.main_job or ui_state.current_subjob ~= player.sub_job) then
                ui_state.current_job = player.main_job
                ui_state.current_subjob = player.sub_job

                -- Force reinit for job change
                KeybindUI.force_reinit(player.main_job, 5.0)
            else
                -- Just update the display
                KeybindUI.update()
            end

            ui_state.last_update = os.clock()
        end, delay)
    end

    --- Check if UI needs reinitialization
    function KeybindUI.needs_reinit(job)
        local ui_state = _G.ui_manager_state

        -- Check if job changed
        if ui_state.current_job and ui_state.current_job ~= job then
            return true
        end

        -- Check if UI doesn't exist
        if not _G.keybind_ui_display then
            return true
        end

        -- Check if we've had multiple consecutive failures
        if ui_state.consecutive_failures > 3 then
            return true
        end

        return false
    end

    --- Get UI status information (for debug / monitoring)
    function KeybindUI.get_status()
        local ui_state = _G.ui_manager_state
        local avg_update_time = 0
        if ui_state.update_count > 0 then
            avg_update_time = ui_state.total_update_time / ui_state.update_count
        end

        return {
            job = ui_state.current_job,
            subjob = ui_state.current_subjob,
            update_in_progress = ui_state.update_in_progress,
            pending_updates = ui_state.pending_update_id,
            last_update = os.clock() - ui_state.last_update,
            consecutive_failures = ui_state.consecutive_failures,
            total_updates = ui_state.update_count,
            avg_update_time = avg_update_time,
            ui_exists = _G.keybind_ui_display ~= nil,
            ui_visible = _G.keybind_ui_visible
        }
    end

    --- Handle job configuration change from coordinator (JobChangeManager)
    function KeybindUI.handle_job_configuration_change(change_data)
        local change_type = change_data.type or 'unknown'
        local reason = string.format('%s_change', change_type)

        -- Schedule update with appropriate delay
        if change_type == 'job_change' then
            -- Job change needs full reinit
            KeybindUI.schedule_update(reason, 0.5)
        elseif change_type == 'subjob_change' then
            -- Subjob change might need reinit for some jobs
            KeybindUI.schedule_update(reason, 1.0)
        else
            -- Default update
            KeybindUI.schedule_update(reason, 1.5)
        end
    end
end

return Orchestrator

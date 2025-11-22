---  ═══════════════════════════════════════════════════════════════════════════
---   Lockstyle Manager - Centralized Lockstyle Management Factory
---  ═══════════════════════════════════════════════════════════════════════════
---   Factory pattern that creates job-specific lockstyle modules.
---   Eliminates 293-line duplication across WAR/PLD/DNC (879 lines >> 293 lines).
---
---   @file    shared/utils/lockstyle/lockstyle_manager.lua
---   @author  Tetsouo
---   @version 1.1 - BRD style + fix Lua 5.1 compatibility (remove coroutine.close)
---   @date    Created: 2025-10-05 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local LockstyleManager = {}

--- Create a lockstyle module configured for a specific job
--- @param job_code string Job code (e.g., 'WAR', 'PLD', 'DNC')
--- @param config_path string Path to job lockstyle config (e.g., 'config/war/WAR_LOCKSTYLE')
--- @param default_lockstyle number Default lockstyle number for this job
--- @param default_subjob string Default subjob for this job (e.g., 'SAM', 'RUN', 'NIN')
--- @return table Lockstyle module with all functions
function LockstyleManager.create(job_code, config_path, default_lockstyle, default_subjob)

    -- Load message formatter
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local MessageCore = require('shared/utils/messages/message_core')

    -- Load lockstyle configuration from user config file
    local lockstyle_config_success, LockstyleConfig = pcall(require, config_path)
    if not lockstyle_config_success or not LockstyleConfig then
        -- Fallback default config if file not found
        LockstyleConfig = {
            default = default_lockstyle,
            get_style = function() return default_lockstyle end
        }
    end

    -- System state and configuration
    local STATE = {
        enabled = true,
        manage_dressup = true,
        is_processing = false,
        current_coroutines = {},
        dressup_state = 'unknown',
        last_dressup_command_time = 0,
        operation_id = 0
    }

    ---  ═══════════════════════════════════════════════════════════════════════════
    ---   LOCKSTYLE FUNCTIONS WITH DELAY
    ---  ═══════════════════════════════════════════════════════════════════════════

    --- Cancel all pending lockstyle operations
    --- Increments operation_id to invalidate all pending coroutines
    local function cancel_pending_operations()
        STATE.operation_id = STATE.operation_id + 1
        STATE.current_coroutines = {}
        STATE.is_processing = false
    end

    --- Apply lockstyle immediately with DressUp cycle if needed
    --- @param style number Lockstyle number to apply
    --- @param operation_id number Operation ID to validate this operation
    local function apply_lockstyle_immediate(style, operation_id)
        if not STATE.enabled then return end
        if operation_id ~= STATE.operation_id then return end

        local current_time = os.clock()

        if STATE.manage_dressup then
            if STATE.dressup_state ~= 'unloaded' then
                if current_time - STATE.last_dressup_command_time > 0.5 then
                    send_command('lua unload dressup')
                    STATE.last_dressup_command_time = current_time
                    STATE.dressup_state = 'unloaded'
                end
            end

            coroutine.schedule(function()
                if operation_id ~= STATE.operation_id then return end

                send_command('input /lockstyleset ' .. style)
            end, 0.3)

            -- Reload dressup after 3.0s to give lockstyle time to apply on FFXI server
            coroutine.schedule(function()
                if operation_id ~= STATE.operation_id then return end

                -- Capture FRESH time when coroutine executes (not stale time from function start)
                local reload_time = os.clock()
                if reload_time - STATE.last_dressup_command_time > 0.5 then
                    send_command('lua load dressup')
                    STATE.last_dressup_command_time = reload_time
                    STATE.dressup_state = 'loaded'
                    STATE.is_processing = false
                end
            end, 3.0)
        else
            send_command('input /lockstyleset ' .. style)
            STATE.is_processing = false
        end
    end

    --- Set lockstyle with delay to prevent collisions
    --- @param style number Lockstyle number to set
    --- @param delay number Delay in seconds (default: 2.0)
    local function set_lockstyle_with_delay(style, delay)
        if not STATE.enabled then return end

        delay = delay or 2.0
        cancel_pending_operations()
        STATE.is_processing = true
        local current_operation = STATE.operation_id

        local coro = coroutine.schedule(function()
            apply_lockstyle_immediate(style, current_operation)
        end, delay)
        table.insert(STATE.current_coroutines, coro)
    end

    --- Select and apply default lockstyle for current job/subjob
    local function select_default_lockstyle()
        if not player or player.main_job ~= job_code then
            return
        end

        local lockstyle_num = LockstyleConfig.default or default_lockstyle

        if LockstyleConfig.get_style then
            local subjob = player.sub_job or default_subjob
            lockstyle_num = LockstyleConfig.get_style(subjob) or lockstyle_num
        end

        set_lockstyle_with_delay(lockstyle_num, 2.0)
    end

    --- Get current lockstyle configuration info
    --- @return table Configuration info
    local function get_lockstyle_info()
        local subjob = (player and player.sub_job) or default_subjob
        local style = LockstyleConfig.default or default_lockstyle

        if LockstyleConfig.get_style then
            style = LockstyleConfig.get_style(subjob) or style
        end

        return {
            job = job_code,
            subjob = subjob,
            style = style,
            enabled = STATE.enabled,
            manage_dressup = STATE.manage_dressup
        }
    end

    --- Show lockstyle configuration status
    local function show_lockstyle_config()
        local info = get_lockstyle_info()
        local status_msg = string.format(
            "[%s] Lockstyle: %s | DressUp: %s | Style: %d",
            info.job,
            info.enabled and "ON" or "OFF",
            info.manage_dressup and "Managed" or "Manual",
            info.style
        )

        if MessageFormatter then
            MessageFormatter.show_info(status_msg)
        else
            MessageCore.show_lockstyle_status(status_msg)
        end
    end

    --- Set lockstyle enabled/disabled
    --- @param enabled boolean Enable or disable lockstyle
    local function set_lockstyle_enabled(enabled)
        STATE.enabled = enabled
        show_lockstyle_config()
    end

    --- Set DressUp management on/off
    --- @param manage_dressup boolean Manage DressUp or not
    local function set_dressup_management(manage_dressup)
        STATE.manage_dressup = manage_dressup
        show_lockstyle_config()
    end

    ---  ═══════════════════════════════════════════════════════════════════════════
    ---   MODULE EXPORT
    ---  ═══════════════════════════════════════════════════════════════════════════

    -- Export functions globally for include() compatibility
    _G.select_default_lockstyle = select_default_lockstyle
    _G['cancel_' .. string.lower(job_code) .. '_lockstyle_operations'] = cancel_pending_operations
    _G['set_' .. string.lower(job_code) .. '_lockstyle_enabled'] = set_lockstyle_enabled
    _G['set_' .. string.lower(job_code) .. '_dressup_management'] = set_dressup_management
    _G['get_' .. string.lower(job_code) .. '_lockstyle_info'] = get_lockstyle_info
    _G['show_' .. string.lower(job_code) .. '_lockstyle_config'] = show_lockstyle_config

    -- Also return as module for require() usage
    return {
        -- Public API
        select_default_lockstyle = select_default_lockstyle,
        set_lockstyle_with_delay = set_lockstyle_with_delay,
        get_lockstyle_info = get_lockstyle_info,
        get_info = get_lockstyle_info,  -- Alias for backward compatibility
        show_lockstyle_config = show_lockstyle_config,
        set_lockstyle_enabled = set_lockstyle_enabled,
        set_dressup_management = set_dressup_management,
        cancel_pending_operations = cancel_pending_operations,

        -- State access (for debugging)
        get_state = function() return STATE end
    }
end

return LockstyleManager

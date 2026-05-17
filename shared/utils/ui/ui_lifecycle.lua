---============================================================================
--- UI Lifecycle - Init / SafeInit / SmartInit / Destroy
---============================================================================
--- Manages the creation and destruction of the keybind_ui_display texts
--- element. Uses the "attach" pattern (like ui_visibility) because smart_init
--- and the orchestrator's force_reinit both call back into KeybindUI.init.
---
--- Key concept: smart_init waits for job-critical states (HybridMode for
--- WAR/PLD, MainLightSpell for BLM, etc.) before initializing, so the UI
--- never displays "N/A" for states that just take a tick to populate.
---
--- @file ui/ui_lifecycle.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local texts              = require('texts')
local KeybindSettings    = require('shared/utils/ui/UI_SETTINGS')
local UISettingsResolver = require('shared/utils/ui/ui_settings_resolver')
local Display            = require('shared/utils/ui/ui_display')
local StateTracker       = require('shared/utils/ui/ui_state_tracker')

local Lifecycle = {}

local create_ui_settings = UISettingsResolver.create_ui_settings

--- Check if critical states are ready for UI initialization.
--- Each main job exposes a different "anchor" state that signals Mote-Include
--- has fully initialized that job's state setup.
--- @return boolean True if states are ready (or job has no anchor)
local function are_states_ready()
    if not _G.state then
        return false
    end

    local job = player and player.main_job or "UNK"

    if job == "BRD" then
        return _G.state.SongMode ~= nil
    elseif job == "BLM" then
        return _G.state.MainLightSpell ~= nil
    elseif job == "BST" then
        return _G.state.Ecosystem ~= nil
    elseif job == "THF" then
        return _G.state.TreasureMode ~= nil
    elseif job == "WAR" then
        return _G.state.HybridMode ~= nil
    elseif job == "PLD" then
        return _G.state.HybridMode ~= nil
    elseif job == "DNC" then
        return _G.state.MainStep ~= nil
    elseif job == "RDM" then
        return _G.state.MainLightSpell ~= nil
    elseif job == "DRG" then
        return _G.state.WeaponSet ~= nil
    elseif job == "RUN" then
        return _G.state.RuneElement ~= nil
    elseif job == "GEO" then
        return _G.state.MainIndi ~= nil
    end

    return true
end

--- Public exposure of are_states_ready for the orchestrator (force_reinit
--- needs to make the same readiness check).
function Lifecycle.are_states_ready()
    return are_states_ready()
end

--- Attach lifecycle methods to the given KeybindUI table.
--- @param KeybindUI table The KeybindUI module table to populate
function Lifecycle.attach(KeybindUI)
    --- Initialize UI: load settings, create texts element, show + first render
    function KeybindUI.init()
        -- ALWAYS load saved settings first (toggle/save need them even when disabled)
        if not _G.keybind_saved_settings then
            local saved_settings = KeybindSettings.load()
            _G.keybind_saved_settings = saved_settings
        end

        -- Check if UI is enabled in config
        if not _G.ui_display_config.enabled then
            return
        end

        if _G.keybind_ui_display then
            return -- Already exists, silent
        end

        -- Create ui_settings dynamically to pick up latest saved position
        local current_ui_settings = create_ui_settings()

        _G.keybind_ui_display = texts.new(current_ui_settings)
        _G.keybind_ui_visible = _G.ui_display_config.enabled

        -- Show UI if enabled
        if _G.ui_display_config.enabled then
            _G.keybind_ui_display:show()
            Display.update_display()
            -- Capture initial state after first display
            _G.ui_manager_state.cached_states = StateTracker.capture_current_states()
        end
    end

    --- Smart initialization that waits for states to be ready.
    --- Uses coroutine.schedule() for delayed initialization if states aren't ready.
    --- @param job_name string Job name (for logging - currently unused)
    --- @param max_wait_time number Maximum time to wait in seconds (default 3)
    function KeybindUI.smart_init(job_name, max_wait_time)
        max_wait_time = max_wait_time or 3
        local ui_state = _G.ui_manager_state

        -- Increment init ID to invalidate any previous smart_init coroutines
        ui_state.smart_init_id = ui_state.smart_init_id + 1
        local my_init_id = ui_state.smart_init_id

        -- If states are ready, initialize immediately
        if are_states_ready() then
            KeybindUI.init()
            return
        end

        -- States not ready, schedule delayed initialization
        local start_time = os.clock()
        local check_interval = 0.2

        local function try_init()
            -- Check if this coroutine is still valid (not superseded by newer init)
            if my_init_id ~= ui_state.smart_init_id then
                return -- Newer smart_init called, abort this one
            end

            -- Check if states are now ready
            if are_states_ready() then
                KeybindUI.init()
                return
            end

            -- Check timeout
            if (os.clock() - start_time) > max_wait_time then
                -- Timeout reached, initialize anyway
                KeybindUI.init()
                return
            end

            -- States still not ready, reschedule (only if still valid)
            if my_init_id == ui_state.smart_init_id then
                coroutine.schedule(try_init, check_interval)
            end
        end

        coroutine.schedule(try_init, check_interval)
    end

    --- Safe initialization - can be called multiple times without side effects
    function KeybindUI.safe_init()
        if not _G.keybind_ui_display then
            local ui_state = _G.ui_manager_state
            -- Track current job/subjob on init
            if player then
                ui_state.current_job = player.main_job
                ui_state.current_subjob = player.sub_job
            end
            KeybindUI.init()
        end
    end

    --- Cleanup with safety protection.
    --- Destroys UI with pcall to prevent crashes if texts library fails.
    function KeybindUI.destroy()
        if not _G.keybind_ui_display then
            return -- Already destroyed, nothing to do
        end

        -- Destroy texts element with error protection
        local success, error_msg = pcall(function()
            _G.keybind_ui_display:destroy()
        end)
        -- Ignore destroy failures - we still clear the reference below

        -- Always clear reference even if destroy failed
        _G.keybind_ui_display = nil
        _G.keybind_ui_visible = false

        -- Clear state cache on destroy
        local ui_state = _G.ui_manager_state
        if ui_state then
            ui_state.cached_states = {}
        end
    end
end

return Lifecycle

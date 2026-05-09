---============================================================================
--- UI State Tracker - Capture and Compare Mote State Values
---============================================================================
--- Pure helpers extracted from UI_MANAGER.lua to track which Mote states are
--- relevant to the keybind UI and detect changes between successive update
--- ticks. The display layer redraws only when this module reports a change,
--- which prevents per-frame redraw spam (e.g. AutoMove triggering 1-2 Hz).
---
--- @file ui/ui_state_tracker.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local StateTracker = {}

--- Capture all current state values, excluding internal Mote fields and
--- high-frequency states that don't affect the displayed UI.
--- @return table Dictionary of state_name -> string value
function StateTracker.capture_current_states()
    if not _G.state then return {} end

    local states = {}

    -- High-frequency states that don't affect UI display (excluded from change detection)
    -- Moving: AutoMove toggles this on every step start/stop (~1-2 Hz)
    local excluded_states = {
        Moving = true,
    }

    for state_name, state_obj in pairs(_G.state) do
        if state_name:sub(1, 1) ~= '_'
           and type(state_obj) ~= 'function'
           and not excluded_states[state_name] then

            local value = nil

            if type(state_obj) == 'table' then
                if state_obj.current then
                    value = tostring(state_obj.current)
                elseif state_obj.value ~= nil then
                    value = tostring(state_obj.value)
                end
            elseif type(state_obj) == 'boolean' then
                value = tostring(state_obj)
            else
                value = tostring(state_obj)
            end

            if value then
                states[state_name] = value
            end
        end
    end

    return states
end

--- Check if states have changed since last update by comparing against the
--- cached states stored in _G.ui_manager_state.cached_states.
--- @param current_states table Result of capture_current_states()
--- @return boolean True if any state changed (or cache empty)
function StateTracker.have_states_changed(current_states)
    -- Resolve cache lazily - _G.ui_manager_state may not exist yet on first call
    local ui_state = _G.ui_manager_state
    local cached = (ui_state and ui_state.cached_states) or {}

    -- First update, always show
    if not next(cached) then
        return true
    end

    -- Check for changed states
    for state_name, current_value in pairs(current_states) do
        if cached[state_name] ~= current_value then
            return true
        end
    end

    -- Check for new states (e.g., BRD song slots added dynamically)
    for state_name, cached_value in pairs(cached) do
        if current_states[state_name] == nil then
            return true
        end
    end

    return false
end

return StateTracker

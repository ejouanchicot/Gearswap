---============================================================================
--- UI State Value - Read Mote State Values for Display
---============================================================================
--- Pure helpers extracted from UI_MANAGER.lua to read individual Mote state
--- values for UI display. Two functions:
---   • get_state_value()      - current value of a state (for live display)
---   • get_all_state_values() - all possible values (for column width calc)
---
--- Handles BRD song slots (BRDSong1..N) and Mote M{} tables specially.
---
--- @file ui/ui_state_value.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local StateValue = {}

--- Get ALL possible values of a state (used to calculate max column width
--- so the UI doesn't shift width when values change).
--- @param state_name string The state name
--- @return table List of all possible values (or {"N/A"} if state missing,
---               {"Unknown"} if state present but no values readable)
function StateValue.get_all_state_values(state_name)
    if not _G.state or not _G.state[state_name] then
        return {"N/A"}
    end

    local state_obj = _G.state[state_name]
    local values = {}

    -- Handle different state object structures
    if type(state_obj) == 'table' then
        -- Check for numeric array (M{...} style) - skip the description entry
        if state_obj[1] then
            for i = 1, #state_obj do
                if state_obj[i] and state_obj[i] ~= state_obj.description then
                    table.insert(values, tostring(state_obj[i]))
                end
            end
        end

        -- Check for _options (state:options() style)
        if state_obj._options and type(state_obj._options) == 'table' then
            for _, opt in ipairs(state_obj._options) do
                table.insert(values, tostring(opt))
            end
        end

        -- If we found no values but have current, use current as fallback
        if #values == 0 and state_obj.current then
            table.insert(values, tostring(state_obj.current))
        end
    elseif type(state_obj) == 'boolean' then
        values = {"true", "false"}
    end

    -- Fallback if we still have no values
    if #values == 0 then
        values = {"Unknown"}
    end

    return values
end

--- Get the current value of a state for live display.
--- Special handling for BRD song slots (BRDSong1, BRDSong2, ...).
--- @param state_name string The state name
--- @param keybind_key string The keybind key (used for GEO numeric tier filtering)
--- @return string The current value as a string
function StateValue.get_state_value(state_name, keybind_key)
    -- BRD song slot handling - Fixed to use BRDSong instead of BRDSlot
    if state_name and state_name:match("^BRDSong(%d)$") then
        if _G.state and _G.state[state_name] then
            local state_obj = _G.state[state_name]
            if state_obj.current then
                return state_obj.current
            elseif state_obj.value then
                return state_obj.value
            end
        end
        return "Empty"
    end

    -- For other states, check if state exists
    if not _G.state or not _G.state[state_name] then
        return "N/A"
    end

    local state_obj = _G.state[state_name]

    -- Handle different state object types
    if type(state_obj) == 'table' then
        if state_obj.current then
            return state_obj.current
        elseif state_obj.display then
            local success, display_result = pcall(state_obj.display, state_obj)
            if success and display_result then
                return display_result
            end
        elseif state_obj.value ~= nil then
            if type(state_obj.value) == 'boolean' then
                return tostring(state_obj.value)
            end
            return tostring(state_obj.value)
        end
    elseif type(state_obj) == 'boolean' then
        return tostring(state_obj)
    end

    -- Special handling for numeric GEO spell tiers
    if keybind_key == "1" or keybind_key == "2" then
        return ""
    end

    -- NOTE: 'result' below is undeclared in the original code - these branches
    -- never trigger (result == nil). Preserved as-is for behavior parity.
    if state_name == "TierSpell" and (result == "" or result == "Unknown") then
        return ""
    end

    if state_name == "AjaTier" and result == "Ga" then
        return ""
    end

    return tostring(state_obj or "Unknown")
end

return StateValue

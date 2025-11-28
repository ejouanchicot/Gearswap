---============================================================================
--- Keybind UI System - Enhanced with Intelligent State Management
---============================================================================
--- Displays job-specific keybinds with real-time state updates for FFXI GearSwap
--- Features: Intelligent update queue, debouncing, state tracking, auto-recovery
--- Commands: //gs c ui (toggle), //gs c uisave (save position manually)
---
--- @file ui/UI_MANAGER.lua
--- @author Tetsouo
--- @version 3.0 - Intelligent State Management
--- @date 2025-09-28
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')

local KeybindUI = {}
local texts = require('texts')

-- Load modular UI system
local UIConfig = _G.UIConfig or {}  -- Loaded from character main file

-- Provide default UIConfig values if not loaded
if not UIConfig.text then
    UIConfig.text = { size = 10, font = 'Consolas', stroke = { width = 2, alpha = 200, red = 0, green = 0, blue = 0 } }
end
if not UIConfig.background then
    UIConfig.background = { r = 0, g = 0, b = 0, a = 150, visible = true }
end
if not UIConfig.default_position then
    UIConfig.default_position = { x = 1600, y = 300 }
end
if not UIConfig.flags then
    UIConfig.flags = { draggable = true }
end
if UIConfig.show_header == nil then UIConfig.show_header = true end
if UIConfig.show_legend == nil then UIConfig.show_legend = true end
if UIConfig.show_column_headers == nil then UIConfig.show_column_headers = true end
if UIConfig.show_footer == nil then UIConfig.show_footer = true end
if UIConfig.enabled == nil then UIConfig.enabled = true end

local MessageUI = require('shared/utils/messages/formatters/ui/message_ui')
local KeybindSettings = require('shared/utils/ui/UI_SETTINGS')

-- Global UI objects to persist across module reloads
if not _G.keybind_ui_display then
    _G.keybind_ui_display = nil
    _G.keybind_ui_visible = true
end

-- Note: _G.keybind_saved_settings is loaded dynamically in create_ui_settings()
-- to ensure it picks up the latest _G.UIConfig values from dofile()

-- Global UI display toggles (persistent across reloads)
-- NOTE: This should NEVER execute because main job files create _G.ui_display_config BEFORE loading UI_MANAGER
if not _G.ui_display_config then
    local UISettingsManager = require('shared/config/ui_settings')
    _G.ui_display_config = {
        show_header = UISettingsManager.get_show_header(),
        show_legend = UISettingsManager.get_show_legend(),
        show_column_headers = UISettingsManager.get_show_column_headers(),
        show_footer = UISettingsManager.get_show_footer(),
        enabled = UISettingsManager.get_enabled()
    }
end

-- Enhanced UI state management
if not _G.ui_manager_state then
    _G.ui_manager_state = {
        -- Current configuration
        current_job = nil,
        current_subjob = nil,
        last_update = 0,

        -- Update tracking
        pending_update_id = 0,
        update_in_progress = false,
        update_cancel_id = 0,  -- Cancel ID for force_reinit (similar to JCM counter)
        last_successful_update = 0,

        -- Smart init tracking (prevent coroutine accumulation)
        smart_init_id = 0,

        -- Error handling
        consecutive_failures = 0,
        last_error = nil,

        -- Performance tracking
        update_count = 0,
        total_update_time = 0,

        -- State change tracking (prevent unnecessary redraws)
        cached_states = {}
    }
end

local ui_state = _G.ui_manager_state
local KeybindLoader = require('shared/utils/ui/UI_LOADER')
local UIDisplayBuilder = require('shared/utils/ui/UI_DISPLAY_BUILDER')
local UISections = require('shared/utils/ui/UI_SECTIONS')

---============================================================================
--- POSITION OFFSET CALCULATION
---============================================================================

--- Calculate Y offset based on hidden UI elements
--- @return number Y offset to apply
local function calculate_y_offset()
    local offset = 0

    -- Get current font size from saved settings
    local UISettingsManager = require('shared/config/ui_settings')
    local font = UISettingsManager.get_font()
    local text_size = font.size or 10
    local line_height = text_size + 4  -- Font size + spacing

    -- Add offset for hidden header (title + separator + legend if visible)
    if not _G.ui_display_config.show_header then
        offset = offset + (line_height * 2)  -- Title + separator
        if _G.ui_display_config.show_legend then
            offset = offset + (line_height * 2)  -- Legend takes ~2 lines
        end
    end

    -- Add offset for hidden column headers
    if not _G.ui_display_config.show_column_headers then
        offset = offset + (line_height * 1)
    end

    return offset
end

--- Convert simplified RGBA format to texts library format
local function get_background_settings()
    -- Load from persistent settings (NOT from UIConfig)
    local UISettingsManager = require('shared/config/ui_settings')
    local bg = UISettingsManager.get_background()

    return {
        red = bg.r,
        green = bg.g,
        blue = bg.b,
        alpha = bg.a,
        visible = bg.visible
    }
end

-- Function to create UI settings (called dynamically to pick up latest saved position)
local function create_ui_settings()
    local UIConfig = _G.UIConfig or {}  -- Always get latest from _G

    -- ALWAYS reload saved settings from _G.UIConfig (which has latest position from dofile)
    local saved_settings = KeybindSettings.load()
    _G.keybind_saved_settings = saved_settings

    -- Use saved position if available, otherwise use default
    local saved_pos = saved_settings and saved_settings.pos or nil
    local default_x = 1600
    local default_y = 300
    local base_x = (saved_pos and saved_pos.x) or default_x
    local base_y = (saved_pos and saved_pos.y) or default_y

    return {
        pos = {
            x = base_x,
            y = base_y + (calculate_y_offset() or 0)  -- Recalculate offset dynamically
        },
        text = {
            size = saved_settings.font_size or 10,
            font = saved_settings.font_name or 'Consolas',
            stroke = (UIConfig.text and UIConfig.text.stroke) or { width = 2, alpha = 200, red = 0, green = 0, blue = 0 },
            padding = 0  -- Remove text padding
        },
        bg = get_background_settings(),
        flags = UIConfig.flags or { draggable = true }
    }
end

-- Create initial ui_settings with safe defaults (will be recreated in init() to pick up saved position)
local ui_settings = {
    pos = {
        x = 1600,
        y = 300
    },
    text = {
        size = 10,
        font = 'Consolas',
        stroke = { width = 2, alpha = 200, red = 0, green = 0, blue = 0 },
        padding = 0
    },
    bg = {
        red = 0,
        green = 0,
        blue = 0,
        alpha = 150,
        visible = true
    },
    flags = { draggable = true }
}

---============================================================================
--- CORE FUNCTIONS
---============================================================================

--- Save position and UI states when UI is moved or settings changed
local function save_position(x, y)
    -- Remove y_offset to save absolute position (relative to top of header, even if hidden)
    local current_y_offset = calculate_y_offset()

    _G.keybind_saved_settings.pos.x = x
    _G.keybind_saved_settings.pos.y = y - current_y_offset

    -- Include all UI display states from global config
    _G.keybind_saved_settings.enabled = _G.ui_display_config.enabled
    _G.keybind_saved_settings.show_header = _G.ui_display_config.show_header
    _G.keybind_saved_settings.show_legend = _G.ui_display_config.show_legend
    _G.keybind_saved_settings.show_column_headers = _G.ui_display_config.show_column_headers
    _G.keybind_saved_settings.show_footer = _G.ui_display_config.show_footer

    -- NOTE: Background and font settings are already in saved_settings, don't overwrite them

    local success = KeybindSettings.save(_G.keybind_saved_settings)

    if success then
        MessageUI.show_position_saved(x, y)
    else
        MessageUI.show_position_save_failed()
    end
end

--- Get current job keybinds using KeybindLoader
local function get_current_job_keybinds()
    local job = player and player.main_job or "UNK"

    -- Use KeybindLoader for character-aware configuration loading
    local keybinds = KeybindLoader.get_job_keybinds(job)

    -- If no configuration found, try fallbacks from KeybindLoader
    if not keybinds then
        keybinds = KeybindLoader.get_fallback_keybinds(job)
    end

    -- Add job-specific display elements (like BRD song slots)
    if keybinds then
        keybinds = KeybindLoader.add_job_specific_elements(job, keybinds)
    end

    return keybinds or {}
end

--- Capture all current state values (excluding high-frequency non-visual states)
--- @return table Dictionary of state_name -> current_value
local function capture_current_states()
    if not _G.state then return {} end

    local states = {}

    -- High-frequency states that don't affect UI display (exclude from change detection)
    -- These states change frequently but are not displayed in the UI, so redrawing on
    -- every change causes unnecessary performance overhead (e.g., AutoMove lag)
    local excluded_states = {
        Moving = true,  -- AutoMove: changes on every start/stop movement (~1-2 Hz)
    }

    for state_name, state_obj in pairs(_G.state) do
        -- Skip internal Mote-Include fields AND excluded high-frequency states
        if state_name:sub(1, 1) ~= '_'
           and type(state_obj) ~= 'function'
           and not excluded_states[state_name] then  -- NEW: Skip excluded states

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

--- Check if states have changed since last update
--- @param current_states table Current state values
--- @return boolean True if any state changed
local function have_states_changed(current_states)
    local cached = ui_state.cached_states

    -- First update, always show
    if not cached or not next(cached) then
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

--- Get ALL possible values of a state (for calculating max width)
--- @param state_name string The state name
--- @return table List of all possible values
local function get_all_state_values(state_name)
    if not _G.state or not _G.state[state_name] then
        return {"N/A"}
    end

    local state_obj = _G.state[state_name]
    local values = {}

    -- Handle different state object structures
    if type(state_obj) == 'table' then
        -- Check for numeric array (M{...} style)
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

--- Get current value of a state
local function get_state_value(state_name, keybind_key)
    -- BRD song slot handling - Fixed to use BRDSong instead of BRDSlot
    if state_name and state_name:match("^BRDSong(%d)$") then
        -- For BRDSong states, just get the value directly like other states
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

    if state_name == "TierSpell" and (result == "" or result == "Unknown") then
        return ""
    end

    if state_name == "AjaTier" and result == "Ga" then
        return ""
    end

    return tostring(state_obj or "Unknown")
end

--- Update display using modular UI system
local function update_display()
    if not _G.keybind_ui_display then return end

    local job = player and player.main_job or "UNK"

    -- For BRD, ensure song slots are updated before reading values
    if job == "BRD" and _G.update_brd_song_slots then
        _G.update_brd_song_slots()
    end

    local keybinds = get_current_job_keybinds()

    -- Get organized display structure
    local display_structure = UIDisplayBuilder.build_display_structure(job)

    -- Render complete UI using new modular system (reads from _G.ui_display_config)
    -- Pass both: get_state_value (current value) and get_all_state_values (for width calculation)
    local text = UISections.render_complete_ui(display_structure, keybinds, job, get_state_value, get_all_state_values)

    -- Update the actual display
    _G.keybind_ui_display:text(text)
end

---============================================================================
--- UI LIFECYCLE MANAGEMENT
---============================================================================

--- Initialize UI
function KeybindUI.init()
    -- ALWAYS load saved settings first (required for toggle/save to work even when disabled)
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
        update_display()
        -- Capture initial state after first display
        ui_state.cached_states = capture_current_states()
    end
end

--- Check if critical states are ready for UI initialization
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
        return _G.state.ecosystem ~= nil
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

--- Smart initialization that waits for states to be ready
--- Uses coroutine.schedule() for delayed initialization if states aren't ready
--- @param job_name string Job name (for logging)
--- @param max_wait_time number Maximum time to wait in seconds (default 3)
function KeybindUI.smart_init(job_name, max_wait_time)
    max_wait_time = max_wait_time or 3

    -- Increment init ID to invalidate any previous smart_init coroutines
    ui_state.smart_init_id = ui_state.smart_init_id + 1
    local my_init_id = ui_state.smart_init_id

    -- If states are ready, initialize immediately
    if are_states_ready() then
        KeybindUI.init()
        return
    end

    -- States not ready, schedule delayed initialization
    -- This ensures UI shows even if states take time to initialize
    local start_time = os.clock()
    local check_interval = 0.2  -- Check every 200ms

    local function try_init()
        -- Check if this coroutine is still valid (not superseded by newer init)
        if my_init_id ~= ui_state.smart_init_id then
            return  -- Newer smart_init called, abort this one
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

    -- Start the check loop
    coroutine.schedule(try_init, check_interval)
end

--- Safe initialization - can be called multiple times without side effects
function KeybindUI.safe_init()
    if not _G.keybind_ui_display then
        -- Track current job/subjob on init
        if player then
            ui_state.current_job = player.main_job
            ui_state.current_subjob = player.sub_job
        end
        KeybindUI.init()
    end
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Save current position
function KeybindUI.save_position()
    if _G.keybind_ui_display then
        local x, y = _G.keybind_ui_display:pos()
        if x and y then
            save_position(x, y)
        end
    end
end

--- Toggle UI
function KeybindUI.toggle()
    if _G.keybind_ui_display then
        _G.keybind_ui_visible = not _G.keybind_ui_visible
        if _G.keybind_ui_visible then
            _G.keybind_ui_display:show()
            update_display()
        else
            _G.keybind_ui_display:hide()
        end

        -- Update ui_display_config (required for reload persistence)
        _G.ui_display_config.enabled = _G.keybind_ui_visible

        -- Save enabled state
        if _G.keybind_saved_settings then
            _G.keybind_saved_settings.enabled = _G.keybind_ui_visible
            KeybindSettings.save(_G.keybind_saved_settings)
        end
    else
        -- UI not initialized, toggle enabled state
        if _G.ui_display_config.enabled then
            KeybindUI.disable()
        else
            KeybindUI.enable()
        end
    end
end

--- Show UI
function KeybindUI.show()
    if _G.keybind_ui_display and not _G.keybind_ui_visible then
        _G.keybind_ui_visible = true
        _G.keybind_ui_display:show()
        update_display()
    end
end

--- Hide UI
function KeybindUI.hide()
    if _G.keybind_ui_display and _G.keybind_ui_visible then
        _G.keybind_ui_visible = false
        _G.keybind_ui_display:hide()
    end
end

--- Check if UI is currently visible
--- @return boolean True if UI is visible, false otherwise
function KeybindUI.is_visible()
    return _G.keybind_ui_visible == true
end

--- Toggle header visibility
function KeybindUI.toggle_header()
    if not _G.keybind_ui_display then return end

    -- Calculate offset before toggle
    local old_offset = calculate_y_offset()

    -- Toggle setting
    _G.ui_display_config.show_header = not _G.ui_display_config.show_header

    -- Calculate new offset after toggle
    local new_offset = calculate_y_offset()

    -- Adjust position to keep visible content at same location
    local current_x, current_y = _G.keybind_ui_display:pos()
    local adjusted_y = current_y - (new_offset - old_offset)
    _G.keybind_ui_display:pos(current_x, adjusted_y)

    update_display()
    MessageUI.show_toggle("Header", _G.ui_display_config.show_header)

    -- Save header state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.show_header = _G.ui_display_config.show_header
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Toggle legend visibility
function KeybindUI.toggle_legend()
    if not _G.keybind_ui_display then return end

    -- Calculate offset before toggle
    local old_offset = calculate_y_offset()

    -- Toggle setting
    _G.ui_display_config.show_legend = not _G.ui_display_config.show_legend

    -- Calculate new offset after toggle
    local new_offset = calculate_y_offset()

    -- Adjust position to keep visible content at same location
    local current_x, current_y = _G.keybind_ui_display:pos()
    local adjusted_y = current_y - (new_offset - old_offset)
    _G.keybind_ui_display:pos(current_x, adjusted_y)

    update_display()
    MessageUI.show_toggle("Legend", _G.ui_display_config.show_legend)

    -- Save legend state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.show_legend = _G.ui_display_config.show_legend
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Toggle column headers visibility
function KeybindUI.toggle_column_headers()
    if not _G.keybind_ui_display then return end

    -- Calculate offset before toggle
    local old_offset = calculate_y_offset()

    -- Toggle setting
    _G.ui_display_config.show_column_headers = not _G.ui_display_config.show_column_headers

    -- Calculate new offset after toggle
    local new_offset = calculate_y_offset()

    -- Adjust position to keep visible content at same location
    local current_x, current_y = _G.keybind_ui_display:pos()
    local adjusted_y = current_y - (new_offset - old_offset)
    _G.keybind_ui_display:pos(current_x, adjusted_y)

    update_display()
    MessageUI.show_toggle("Column Headers", _G.ui_display_config.show_column_headers)

    -- Save column headers state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.show_column_headers = _G.ui_display_config.show_column_headers
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Toggle footer visibility
function KeybindUI.toggle_footer()
    if not _G.keybind_ui_display then return end

    -- Note: Footer is at bottom, so no Y position adjustment needed
    _G.ui_display_config.show_footer = not _G.ui_display_config.show_footer

    update_display()
    MessageUI.show_toggle("Footer", _G.ui_display_config.show_footer)

    -- Save footer state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.show_footer = _G.ui_display_config.show_footer
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Enable UI
function KeybindUI.enable()
    _G.ui_display_config.enabled = true
    if not _G.keybind_ui_display then
        KeybindUI.init()
    else
        KeybindUI.show()
    end
    MessageUI.show_enabled()

    -- Save enabled state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.enabled = true
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Disable UI
function KeybindUI.disable()
    _G.ui_display_config.enabled = false
    KeybindUI.hide()
    MessageUI.show_disabled()

    -- Save enabled state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.enabled = false
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Set background from preset
--- @param preset_name string Preset name (dark, light, blue, black, transparent)
function KeybindUI.set_background_preset(preset_name)
    if not UIConfig.background_presets then
        MessageUI.show_error("Background presets not loaded")
        return false
    end

    local preset = UIConfig.background_presets[preset_name]
    if not preset then
        MessageUI.show_error("Unknown background preset: " .. preset_name)
        return false
    end

    UIConfig.background.r = preset.r
    UIConfig.background.g = preset.g
    UIConfig.background.b = preset.b
    UIConfig.background.a = preset.a

    -- Apply to existing UI if active
    if _G.keybind_ui_display then
        _G.keybind_ui_display:bg_color(preset.r, preset.g, preset.b)
        _G.keybind_ui_display:bg_alpha(preset.a)
    end

    MessageUI.show_background_preset(preset_name, preset.r, preset.g, preset.b, preset.a)

    -- Save background state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.bg_r = preset.r
        _G.keybind_saved_settings.bg_g = preset.g
        _G.keybind_saved_settings.bg_b = preset.b
        _G.keybind_saved_settings.bg_a = preset.a
        KeybindSettings.save(_G.keybind_saved_settings)
    end

    return true
end

--- Set custom background RGBA
--- @param r number Red (0-255)
--- @param g number Green (0-255)
--- @param b number Blue (0-255)
--- @param a number Alpha (0-255)
function KeybindUI.set_background_rgba(r, g, b, a)
    r, g, b, a = tonumber(r), tonumber(g), tonumber(b), tonumber(a)

    if not r or not g or not b or not a then
        MessageUI.show_error("Invalid RGBA values. Use: //gs c ui bg <r> <g> <b> <a>")
        return false
    end

    -- Clamp values
    r = math.max(0, math.min(255, r))
    g = math.max(0, math.min(255, g))
    b = math.max(0, math.min(255, b))
    a = math.max(0, math.min(255, a))

    UIConfig.background.r = r
    UIConfig.background.g = g
    UIConfig.background.b = b
    UIConfig.background.a = a

    -- Apply to existing UI if active
    if _G.keybind_ui_display then
        _G.keybind_ui_display:bg_color(r, g, b)
        _G.keybind_ui_display:bg_alpha(a)
    end

    MessageUI.show_background_rgba(r, g, b, a)

    -- Save background state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.bg_r = r
        _G.keybind_saved_settings.bg_g = g
        _G.keybind_saved_settings.bg_b = b
        _G.keybind_saved_settings.bg_a = a
        KeybindSettings.save(_G.keybind_saved_settings)
    end

    return true
end

--- Toggle background visibility
function KeybindUI.toggle_background()
    UIConfig.background.visible = not UIConfig.background.visible

    if _G.keybind_ui_display then
        _G.keybind_ui_display:bg_visible(UIConfig.background.visible)
    end

    MessageUI.show_toggle("Background", UIConfig.background.visible)

    -- Save background visibility state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.bg_visible = UIConfig.background.visible
        KeybindSettings.save(_G.keybind_saved_settings)
    end
end

--- Set font
--- @param font_name string Font name (Consolas or Courier New)
function KeybindUI.set_font(font_name)
    -- Validate font (only allow safe monospace fonts)
    local valid_fonts = {
        ["consolas"] = "Consolas",
        ["courier new"] = "Courier New",
        ["courier"] = "Courier New"  -- Redirect Courier to Courier New
    }

    local normalized = font_name:lower()
    local validated_font = valid_fonts[normalized]

    if not validated_font then
        MessageUI.show_error("Invalid font. Available: Consolas (default), Courier New")
        return false
    end

    -- Update config
    UIConfig.text.font = validated_font

    -- Apply to existing UI if active
    if _G.keybind_ui_display then
        _G.keybind_ui_display:font(validated_font)
    end

    MessageCore.show_ui_info("Font changed to: " .. validated_font)

    -- Save font state
    if _G.keybind_saved_settings then
        _G.keybind_saved_settings.font_name = validated_font
        KeybindSettings.save(_G.keybind_saved_settings)
    end

    return true
end

--- Update UI when states change with error handling
--- Only redraws if states have actually changed (prevents unnecessary spam)
function KeybindUI.update()
    -- DEBUG: Trace UI update call
    local debug_start
    if _G.UPDATE_DEBUG then
        debug_start = os.clock()
        add_to_chat(207, string.format('[UPDATE_DEBUG] UI.update START | t=%.3f', debug_start))
    end

    if not _G.keybind_ui_display then
        if _G.UPDATE_DEBUG then
            add_to_chat(207, '[UPDATE_DEBUG] UI.update -> safe_init (no display)')
        end
        KeybindUI.safe_init()
        return
    end

    -- STATE CHANGE DETECTION: Only update if states actually changed
    local current_states = capture_current_states()
    if not have_states_changed(current_states) then
        -- States unchanged, skip redraw
        if _G.UPDATE_DEBUG then
            add_to_chat(207, '[UPDATE_DEBUG] UI.update SKIPPED (states unchanged)')
        end
        return
    end

    -- States changed, update display
    if _G.UPDATE_DEBUG then
        add_to_chat(207, '[UPDATE_DEBUG] UI.update -> update_display (states changed)')
    end
    local success, error_msg = pcall(update_display)
    if not success then
        ui_state.consecutive_failures = ui_state.consecutive_failures + 1
        ui_state.last_error = error_msg
        -- Update failed

        -- Try to recover if too many failures
        if ui_state.consecutive_failures > 5 then
            -- Too many failures, attempting recovery
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

    -- DEBUG: Trace UI update end
    if _G.UPDATE_DEBUG and debug_start then
        local debug_end = os.clock()
        add_to_chat(207, string.format('[UPDATE_DEBUG] UI.update DONE | took=%.3fms', (debug_end - debug_start) * 1000))
    end
end

--- Force complete UI reinitialization with cancel support
--- Uses cancel ID system (similar to JCM counter) to handle rapid job changes
--- Uses coroutine.schedule() for non-blocking state checking
function KeybindUI.force_reinit(job_name, max_wait_time)
    -- Cancel any previous force_reinit by incrementing cancel ID
    ui_state.update_cancel_id = ui_state.update_cancel_id + 1
    local my_cancel_id = ui_state.update_cancel_id

    -- Always destroy UI first (even if update_in_progress from previous call)
    KeybindUI.destroy()

    -- Mark as updating
    ui_state.update_in_progress = true
    max_wait_time = max_wait_time or 3

    -- If states are ready, initialize immediately
    if are_states_ready() then
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
        if are_states_ready() then
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
    return true  -- Return immediately, actual result comes async
end

--- Schedule UI update with intelligent debouncing
function KeybindUI.schedule_update(reason, delay)
    delay = delay or 1.0

    -- Increment update ID to cancel previous pending updates
    ui_state.pending_update_id = ui_state.pending_update_id + 1
    local my_update_id = ui_state.pending_update_id

    -- Scheduling update

    -- Schedule the update
    coroutine.schedule(function()
        -- Check if this update is still valid
        if ui_state.pending_update_id ~= my_update_id then
            -- Update cancelled (newer update pending)
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

--- Get UI status information
function KeybindUI.get_status()
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

--- Handle job configuration change from coordinator
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

--- Cleanup with safety protection
--- Destroys UI with pcall to prevent crashes if texts library fails
function KeybindUI.destroy()
    if not _G.keybind_ui_display then
        return  -- Already destroyed, nothing to do
    end

    -- Destroy texts element with error protection
    local success, error_msg = pcall(function()
        _G.keybind_ui_display:destroy()
    end)

    if not success then
        -- Failed to destroy, but continue cleanup anyway
        -- Error: error_msg
    end

    -- Always clear reference even if destroy failed
    _G.keybind_ui_display = nil
    _G.keybind_ui_visible = false

    -- Clear state cache on destroy
    if ui_state then
        ui_state.cached_states = {}
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return KeybindUI
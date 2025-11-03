---
--- UI Configuration Loader
---
--- Centralized loader for UI_CONFIG.lua to eliminate duplication across all job files.
--- This module loads the UI configuration, applies fallback defaults if needed,
--- and sets up global variables required by the UI system.
---
--- @module ConfigLoader
--- @author Tetsouo GearSwap System
--- @version 1.0
--- @date 2025-11-03

local ConfigLoader = {}

---
--- Load UI configuration for a character and job
---
--- This function:
--- 1. Constructs the path to UI_CONFIG.lua for the given character
--- 2. Attempts to load the configuration with error handling
--- 3. Falls back to sensible defaults if loading fails
--- 4. Sets up global variables (_G.UIConfig and _G.ui_display_config)
---
--- @param char_name string The character name (e.g., 'Tetsouo')
--- @param job_name string The job name for error messages (e.g., 'WAR', 'BRD')
--- @return table The loaded or default UI configuration
---
function ConfigLoader.load_ui_config(char_name, job_name)
    -- Validate parameters
    if not char_name or char_name == '' then
        add_to_chat(167, '[ConfigLoader] Error: char_name is required')
        char_name = 'Tetsouo'  -- Fallback
    end

    if not job_name or job_name == '' then
        job_name = 'UNKNOWN'
    end

    -- Construct path to UI_CONFIG.lua
    local config_path = windower.windower_path .. 'addons/GearSwap/data/' .. char_name .. '/config/UI_CONFIG.lua'

    -- Attempt to load configuration
    local success, UIConfig = pcall(function()
        return dofile(config_path)
    end)

    -- Apply fallback defaults if load failed
    if not success or not UIConfig then
        UIConfig = {
            init_delay = 5.0,
            default_position = { x = 1600, y = 300 },
            enabled = true,
            show_header = true,
            show_legend = true,
            show_column_headers = true,
            show_footer = true
        }
        add_to_chat(167, '[' .. job_name .. '] UIConfig load failed, using defaults')
    end

    -- Set global UIConfig (required by UI system)
    _G.UIConfig = UIConfig

    -- Create ui_display_config with nil-safe defaults
    _G.ui_display_config = {
        show_header = (UIConfig.show_header == nil) and true or UIConfig.show_header,
        show_legend = (UIConfig.show_legend == nil) and true or UIConfig.show_legend,
        show_column_headers = (UIConfig.show_column_headers == nil) and true or UIConfig.show_column_headers,
        show_footer = (UIConfig.show_footer == nil) and true or UIConfig.show_footer,
        enabled = (UIConfig.enabled == nil) and true or UIConfig.enabled
    }

    return UIConfig
end

return ConfigLoader

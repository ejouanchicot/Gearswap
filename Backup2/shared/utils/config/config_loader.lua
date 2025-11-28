---  ═══════════════════════════════════════════════════════════════════════════
---   UI Configuration Loader
---  ═══════════════════════════════════════════════════════════════════════════
---   Centralized loader for UI_CONFIG.lua to eliminate duplication across all job files.
---   This module loads the UI configuration, applies fallback defaults if needed,
---   and sets up global variables required by the UI system.
---
---   @file    shared/utils/config/config_loader.lua
---   @author  Tetsouo GearSwap System
---   @version 2.0 - Eliminated duplication (use UISettingsManager)
---   @date    Created: 2025-11-03 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local MessageCore = require('shared/utils/messages/message_core')

local ConfigLoader = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN FUNCTION
---  ═══════════════════════════════════════════════════════════════════════════

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
function ConfigLoader.load_ui_config(char_name, job_name)
    -- Validate parameters
    if not char_name or char_name == '' then
        MessageCore.show_config_error('ConfigLoader', 'Error: char_name is required')
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
            init_delay              = 5.0,
            default_position        = { x = 1600, y = 300 },
            enabled                 = true,
            show_header             = true,
            show_legend             = true,
            show_column_headers     = true,
            show_footer             = true
        }
        MessageCore.show_config_error(job_name, 'UIConfig load failed, using defaults')
    end

    -- Set global UIConfig (required by UI system)
    _G.UIConfig = UIConfig

    -- Load UI display config from UISettingsManager (centralized)
    local UISettingsManager = require('shared/config/ui_settings')
    _G.ui_display_config = {
        enabled             = UISettingsManager.get_enabled(),
        show_header         = UISettingsManager.get_show_header(),
        show_legend         = UISettingsManager.get_show_legend(),
        show_column_headers = UISettingsManager.get_show_column_headers(),
        show_footer         = UISettingsManager.get_show_footer()
    }

    return UIConfig
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return ConfigLoader

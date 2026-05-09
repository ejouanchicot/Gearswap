---============================================================================
--- Keybind UI System - Facade
---============================================================================
--- Public entry point for the keybind UI. After the v3.x refactor this file
--- is a thin facade: it owns the global state initialization (UIConfig
--- defaults, _G.keybind_ui_display, _G.ui_display_config, _G.ui_manager_state)
--- then composes the public KeybindUI API by attaching methods from the
--- specialized sub-modules:
---
---   ui_state_tracker        - capture/diff Mote state values
---   ui_state_value          - read individual state values for display
---   ui_display              - render UI text
---   ui_appearance           - background presets/RGBA + font
---   ui_section_toggles      - header/legend/column_headers/footer toggles
---   ui_visibility           - save_position/toggle/show/hide/enable/disable
---   ui_lifecycle            - init/smart_init/safe_init/destroy
---   ui_update_orchestrator  - update/force_reinit/schedule_update/status
---   ui_settings_resolver    - position/font/background settings resolver
---
--- Public API exposed on KeybindUI (used by 15 jobs):
---   init, smart_init, safe_init, destroy
---   save_position, toggle, show, hide, is_visible, enable, disable
---   toggle_header, toggle_legend, toggle_column_headers, toggle_footer
---   set_background_preset, set_background_rgba, toggle_background, set_font
---   update, force_reinit, schedule_update, needs_reinit, get_status,
---   handle_job_configuration_change
---
--- Commands: //gs c ui (toggle), //gs c uisave (save position manually)
---
--- @file ui/UI_MANAGER.lua
--- @author Tetsouo
--- @version 4.0 - Modular facade (refactored from monolithic 1085-line file)
--- @date 2025-09-28 (initial), 2026-05-09 (modular refactor)
---============================================================================

---============================================================================
--- GLOBAL STATE INITIALIZATION
---============================================================================
--- These globals must exist BEFORE the sub-modules load (they reference
--- _G.UIConfig, _G.keybind_ui_display, _G.ui_display_config, _G.ui_manager_state).

-- UIConfig is loaded from the character main file - provide defaults if missing
local UIConfig = _G.UIConfig or {}
_G.UIConfig = UIConfig

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
if UIConfig.show_header         == nil then UIConfig.show_header         = true end
if UIConfig.show_legend         == nil then UIConfig.show_legend         = true end
if UIConfig.show_column_headers == nil then UIConfig.show_column_headers = true end
if UIConfig.show_footer         == nil then UIConfig.show_footer         = true end
if UIConfig.enabled             == nil then UIConfig.enabled             = true end

-- Persist UI handle and visibility flag across module reloads
if not _G.keybind_ui_display then
    _G.keybind_ui_display = nil
    _G.keybind_ui_visible = true
end

-- _G.keybind_saved_settings is loaded lazily by Lifecycle.init via KeybindSettings.load()

-- Global UI display toggles (persistent across reloads).
-- This block typically does NOT execute because the character main file creates
-- _G.ui_display_config BEFORE loading UI_MANAGER. Kept as a safety net.
if not _G.ui_display_config then
    local UISettingsManager = require('shared/config/ui_settings')
    _G.ui_display_config = {
        show_header         = UISettingsManager.get_show_header(),
        show_legend         = UISettingsManager.get_show_legend(),
        show_column_headers = UISettingsManager.get_show_column_headers(),
        show_footer         = UISettingsManager.get_show_footer(),
        enabled             = UISettingsManager.get_enabled()
    }
end

-- Enhanced UI state machine (cancel tokens, failure tracking, state cache)
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

---============================================================================
--- SUB-MODULE LOADING
---============================================================================

local Appearance     = require('shared/utils/ui/ui_appearance')
local SectionToggles = require('shared/utils/ui/ui_section_toggles')
local Visibility     = require('shared/utils/ui/ui_visibility')
local Lifecycle      = require('shared/utils/ui/ui_lifecycle')
local Orchestrator   = require('shared/utils/ui/ui_update_orchestrator')

---============================================================================
--- PUBLIC API COMPOSITION
---============================================================================

local KeybindUI = {}

-- Lifecycle: init, smart_init, safe_init, destroy
-- Attach FIRST so subsequent attaches can reference KeybindUI.init at call time
Lifecycle.attach(KeybindUI)

-- Visibility: save_position, toggle, show, hide, is_visible, enable, disable
-- Attach AFTER Lifecycle (enable() calls KeybindUI.init)
Visibility.attach(KeybindUI)

-- Update orchestration: update, force_reinit, schedule_update, needs_reinit,
-- get_status, handle_job_configuration_change
-- Attach AFTER Lifecycle (force_reinit calls KeybindUI.init/destroy)
Orchestrator.attach(KeybindUI)

-- Section toggles (header, legend, column_headers, footer) - direct delegation
KeybindUI.toggle_header         = SectionToggles.toggle_header
KeybindUI.toggle_legend         = SectionToggles.toggle_legend
KeybindUI.toggle_column_headers = SectionToggles.toggle_column_headers
KeybindUI.toggle_footer         = SectionToggles.toggle_footer

-- Background and font customization - direct delegation
KeybindUI.set_background_preset = Appearance.set_background_preset
KeybindUI.set_background_rgba   = Appearance.set_background_rgba
KeybindUI.toggle_background     = Appearance.toggle_background
KeybindUI.set_font              = Appearance.set_font

return KeybindUI

---============================================================================
--- UI Visibility - Show/Hide/Toggle/Enable/Disable + Save Position
---============================================================================
--- Manages the runtime visibility of the keybind UI. Uses the "attach" pattern
--- because enable() / toggle() call back into KeybindUI.init() (defined in
--- UI_MANAGER) - attaching at the end of UI_MANAGER's load lets these methods
--- resolve KeybindUI.init at CALL time, sidestepping the require cycle.
---
--- Public methods attached:
---   save_position, toggle, show, hide, is_visible, enable, disable
---
--- @file ui/ui_visibility.lua
--- @author Tetsouo
--- @version 1.0
---============================================================================

local KeybindSettings    = require('shared/utils/ui/UI_SETTINGS')
local MessageUI          = require('shared/utils/messages/formatters/ui/message_ui')
local UISettingsResolver = require('shared/utils/ui/ui_settings_resolver')
local Display            = require('shared/utils/ui/ui_display')

local Visibility = {}

local calculate_y_offset = UISettingsResolver.calculate_y_offset

--- Persist current position + all UI display states.
--- Subtracts the dynamic Y offset so the saved Y is always relative to the
--- header position (even when header is hidden), making the layout stable
--- across toggle_header changes between sessions.
--- @param x number Current screen X
--- @param y number Current screen Y
local function save_position_internal(x, y)
    local current_y_offset = calculate_y_offset()

    _G.keybind_saved_settings.pos.x = x
    _G.keybind_saved_settings.pos.y = y - current_y_offset

    -- Include all UI display states from global config
    _G.keybind_saved_settings.enabled             = _G.ui_display_config.enabled
    _G.keybind_saved_settings.show_header         = _G.ui_display_config.show_header
    _G.keybind_saved_settings.show_legend         = _G.ui_display_config.show_legend
    _G.keybind_saved_settings.show_column_headers = _G.ui_display_config.show_column_headers
    _G.keybind_saved_settings.show_footer         = _G.ui_display_config.show_footer

    local success = KeybindSettings.save(_G.keybind_saved_settings)
    if success then
        MessageUI.show_position_saved(x, y)
    else
        MessageUI.show_position_save_failed()
    end
end

--- Attach visibility methods to the given KeybindUI table.
--- MUST be called AFTER KeybindUI.init is defined - enable() and toggle()
--- resolve KeybindUI.init at call time, so the table just needs to have
--- init populated by the time the user invokes enable/toggle (it does).
--- @param KeybindUI table The KeybindUI module table to populate
function Visibility.attach(KeybindUI)
    --- Save the current UI position (reads from texts element)
    function KeybindUI.save_position()
        if _G.keybind_ui_display then
            local x, y = _G.keybind_ui_display:pos()
            if x and y then
                save_position_internal(x, y)
            end
        end
    end

    --- Toggle UI visibility (or enable/disable if not yet initialized)
    function KeybindUI.toggle()
        if _G.keybind_ui_display then
            _G.keybind_ui_visible = not _G.keybind_ui_visible
            if _G.keybind_ui_visible then
                _G.keybind_ui_display:show()
                Display.update_display()
            else
                _G.keybind_ui_display:hide()
            end

            -- Update ui_display_config (required for reload persistence)
            _G.ui_display_config.enabled = _G.keybind_ui_visible

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

    --- Show UI (no-op if already visible or not initialized)
    function KeybindUI.show()
        if _G.keybind_ui_display and not _G.keybind_ui_visible then
            _G.keybind_ui_visible = true
            _G.keybind_ui_display:show()
            Display.update_display()
        end
    end

    --- Hide UI (no-op if already hidden or not initialized)
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

    --- Enable UI (initialize if needed, then show)
    function KeybindUI.enable()
        _G.ui_display_config.enabled = true
        if not _G.keybind_ui_display then
            KeybindUI.init()
        else
            KeybindUI.show()
        end
        MessageUI.show_enabled()

        if _G.keybind_saved_settings then
            _G.keybind_saved_settings.enabled = true
            KeybindSettings.save(_G.keybind_saved_settings)
        end
    end

    --- Disable UI (hide and persist disabled state)
    function KeybindUI.disable()
        _G.ui_display_config.enabled = false
        KeybindUI.hide()
        MessageUI.show_disabled()

        if _G.keybind_saved_settings then
            _G.keybind_saved_settings.enabled = false
            KeybindSettings.save(_G.keybind_saved_settings)
        end
    end
end

return Visibility

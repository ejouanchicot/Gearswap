---  ═══════════════════════════════════════════════════════════════════════════
---   Cycle Handler - UI-aware State Cycling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles state cycling with UI visibility awareness.
---   - UI visible: Silent cycle + UI update (no chat message)
---   - UI hidden: Delegate to Mote-Include (shows chat message)
---
---   @file    shared/utils/core/CYCLE_HANDLER.lua
---   @author  Tetsouo
---   @version 1.1 - Added defensive validation for all globals and sanitization
---   @date    Created: 2025-11-10 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

local CycleHandler = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   CYCLE STATE HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle cyclestate command with UI awareness
---
--- Behavior:
---   - UI visible: Silent cycle + UI update (no chat message)
---   - UI hidden: Delegate to Mote-Include (shows chat message in game)
---
--- Side effects:
---   - Cycles the specified state via state[state_name]:cycle()
---   - Calls job_state_change(state_name, newValue, oldValue) hook if defined
---   - Calls update_combat_form() if defined
---   - Calls handle_equipping_gear(player.status) if defined
---   - Updates UI via KeybindUI.update() (when UI is visible)
---
--- @param cmdParams table Command parameters (cmdParams[2] = state_name)
--- @param _eventArgs table Event arguments (unused, kept for signature compatibility)
--- @return boolean True if command was handled
function CycleHandler.handle_cyclestate(cmdParams, _eventArgs)
    if #cmdParams < 2 then
        MessageFormatter.show_error('cyclestate requires a state name')
        return true
    end

    local state_name = cmdParams[2]

    -- Sanitize state_name (alphanumeric + underscore only, prevent command injection)
    if not state_name:match('^[%w_]+$') then
        MessageFormatter.show_error('Invalid state name: ' .. state_name)
        return true
    end

    -- Check if UI is visible
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    local ui_visible = ui_success and KeybindUI and KeybindUI.is_visible and KeybindUI.is_visible()

    if ui_visible then
        -- UI visible: cycle directly without Mote message
        -- Validate state global exists and has the requested state with cycle method
        if _G.state and _G.state[state_name] and
            type(_G.state[state_name].cycle) == 'function' then

            -- Cycle the state
            _G.state[state_name]:cycle()

            -- Call job_state_change hook if defined
            if _G.job_state_change and type(_G.job_state_change) == 'function' then
                local newValue = _G.state[state_name].value or 'Unknown'
                local oldValue = _G.state[state_name].previous or newValue
                _G.job_state_change(state_name, newValue, oldValue)
            end

            -- Update combat form if defined
            if _G.update_combat_form and type(_G.update_combat_form) == 'function' then
                _G.update_combat_form()
            end

            -- Update gear if defined
            if player and player.status and _G.handle_equipping_gear and
                type(_G.handle_equipping_gear) == 'function' then
                _G.handle_equipping_gear(player.status)
            end

            -- Update UI (no delay needed - sync call)
            if KeybindUI and KeybindUI.update and type(KeybindUI.update) == 'function' then
                KeybindUI.update()
            end
        else
            MessageFormatter.show_error('Unknown state: ' .. state_name)
        end
    else
        -- UI invisible: delegate to Mote-Include (shows message)
        -- Verify windower command system is available
        if windower and windower.send_command and type(windower.send_command) == 'function' then
            windower.send_command('gs c cycle ' .. state_name)
        else
            MessageFormatter.show_error('Cannot cycle state: Windower command system unavailable')
        end
    end

    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return CycleHandler

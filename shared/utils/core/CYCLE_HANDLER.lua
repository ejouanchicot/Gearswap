---  ═══════════════════════════════════════════════════════════════════════════
---   Cycle Handler - UI-aware State Cycling
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles state cycling with UI visibility awareness.
---   - UI visible: Mote's cycle without the chat line, then a UI update
---   - UI hidden: Delegate to Mote-Include (shows chat message)
---
---   Both paths call job_state_change with the same arguments (the state
---   description and its real previous value) and both end in Mote's
---   handle_update, so a job hook behaves the same whether the HUD is shown.
---
---   @file    shared/utils/core/CYCLE_HANDLER.lua
---   @author  Tetsouo
---   @version 1.2 - Same job_state_change arguments and update path as Mote's cycle
---   @date    Created: 2025-11-10 | Updated: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local CycleHandler = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Same words Mote's handle_cycle accepts after the state name.
local REVERSE_WORDS = { reverse = true, backwards = true, r = true }

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Find a mode state by name, the way Mote's cycle command does.
--- @param name string State name typed after cyclestate
--- @return table|nil The Mote mode, nil when no such state exists
local function find_state(name)
    if type(_G.get_state) == 'function' then
        return _G.get_state(name)
    end
    local st = _G.state and _G.state[name]
    return (st and type(st.cycle) == 'function') and st or nil
end

--- Cycle one state exactly as Mote's handle_cycle does, minus its chat line.
--- @param state_var table Mote mode to cycle
--- @param name string State name typed by the player (used if no description)
--- @param reverse boolean True to cycle backwards
local function cycle_silently(state_var, name, reverse)
    local old_value = state_var.value
    if reverse then
        state_var:cycleback()
    else
        state_var:cycle()
    end

    if type(_G.job_state_change) == 'function' then
        _G.job_state_change(state_var.description or name, state_var.value, old_value)
    end

    -- job_update (weapon locks, BRD song rows) and the gear refresh live here.
    if type(_G.handle_update) == 'function' then
        _G.handle_update({'auto'})
    end
end

--- Hand the cycle to Mote, which prints "<state> is now <value>."
--- @param name string State name
--- @param reverse boolean True to cycle backwards
local function delegate_to_mote(name, reverse)
    if windower and type(windower.send_command) == 'function' then
        windower.send_command('gs c cycle ' .. name .. (reverse and ' reverse' or ''))
    else
        MessageFormatter.show_error('Cannot cycle state: Windower command system unavailable')
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CYCLE STATE HANDLER
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle `cyclestate <State> [reverse]` with UI awareness.
---
--- UI visible: cycle without a chat line, call job_state_change(description,
--- new, old) and handle_update({'auto'}) as Mote does, then repaint the UI.
--- UI hidden: send `gs c cycle <State> [reverse]` so Mote prints its message.
---
--- @param cmdParams table Command parameters ({'cyclestate', State, ['reverse']})
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

    local reverse = cmdParams[3] ~= nil and REVERSE_WORDS[cmdParams[3]:lower()] == true

    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    local ok_t, Trace = pcall(require, 'shared/utils/debug/trace_log')
    if ok_t and Trace then
        Trace.log('CYCLE', '%s: HUD exists %s, visible flag %s -> %s', state_name, _G.keybind_ui_display ~= nil,
            _G.keybind_ui_visible, (ui_success and KeybindUI and KeybindUI.is_visible and KeybindUI.is_visible())
            and 'silent (HUD shows it)' or 'Mote chat message')
    end
    if not (ui_success and KeybindUI and KeybindUI.is_visible and KeybindUI.is_visible()) then
        delegate_to_mote(state_name, reverse)
        return true
    end

    local state_var = find_state(state_name)
    if not state_var then
        MessageFormatter.show_error('Unknown state: ' .. state_name)
        return true
    end

    cycle_silently(state_var, state_name, reverse)

    if type(KeybindUI.update) == 'function' then
        KeybindUI.update()
    end
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return CycleHandler

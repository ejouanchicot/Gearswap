---============================================================================
--- SMN Keybind Configuration
---============================================================================
--- Number keys cycle Mote states. Function keys trigger SMN-specific commands.
---
--- @file config/smn/SMN_KEYBINDS.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-05-28
---============================================================================

local SMNKeybinds = {}

local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND DEFINITIONS
---============================================================================

SMNKeybinds.binds = {
    ---==========================================================================
    --- CASTING / IDLE MODES (Number Keys)
    ---==========================================================================
    { key = "^numpad1", command = "cyclestate IdleMode",     desc = "Idle Mode",     state = "IdleMode"     },
    { key = "^numpad2", command = "cyclestate CastingMode",  desc = "Casting Mode",  state = "CastingMode"  },
    { key = "^numpad3", command = "cyclestate AvatarFavor",  desc = "Avatar Favor",  state = "AvatarFavor"  },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },

    ---==========================================================================
    --- JOB ABILITIES (Function keys + modifiers)
    ---==========================================================================

    ---==========================================================================
    --- AVATAR SUMMONS (numpad)
    ---==========================================================================
}

---============================================================================
--- KEYBIND MANAGEMENT FUNCTIONS
---============================================================================

function SMNKeybinds.bind_all()
    if not SMNKeybinds.binds or #SMNKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("SMN")
        return false
    end

    local bound_count = 0
    for _, bind in pairs(SMNKeybinds.binds) do
        local ok, err = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if ok then
            bound_count = bound_count + 1
        else
            MessageFormatter.show_error('[SMN] Keybind Error (' .. bind.key .. '): ' .. tostring(err))
        end
    end

    if bound_count > 0 then
        SMNKeybinds.show_intro()
        return true
    end

    MessageFormatter.show_no_binds_error("SMN")
    return false
end

function SMNKeybinds.unbind_all()
    if not SMNKeybinds.binds then return end
    for _, bind in pairs(SMNKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end
    MessageFormatter.show_success("SMN keybinds unloaded.")
end

---============================================================================
--- SYSTEM INTRO & DISPLAY
---============================================================================

function SMNKeybinds.show_intro()
    MessageFormatter.show_system_intro("SMN SYSTEM LOADED", SMNKeybinds.binds)
end

function SMNKeybinds.show_binds()
    MessageFormatter.show_keybind_list("SMN Keybinds", SMNKeybinds.binds)
end

---============================================================================
--- STATE GETTER (used by UI)
---============================================================================

function SMNKeybinds.get_state_value(bind_config)
    if not bind_config.state then return nil end
    if _G.state and _G.state[bind_config.state] then
        return _G.state[bind_config.state].current or _G.state[bind_config.state].value
    end
    return nil
end

return SMNKeybinds

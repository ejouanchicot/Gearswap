---============================================================================
--- THF Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Thief job allowing easy customization
--- without modifying core job files.
---
--- Features:
---   • User-customizable key mappings without touching core job files
---   • State-based keybind organization (Weapon, Combat Modes, TH, Abyssea)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---   • MessageFormatter integration for consistent display
---
--- Keybind Categories:
---   • Weapon Management (Alt+1/2): MainWeapon, SubWeapon
---   • Combat Modes (Alt+3): HybridMode (PDT/Normal)
---   • Treasure Hunter (Alt+4): TreasureMode (Tag/SATA/Full)
---   • Abyssea Proc (Alt+5/6): AbyProc toggle, AbyWeapon cycle
---   • Ranged Lock (Alt+7): RangeLock toggle (On/Off)
---
--- Dependencies:
---   • MessageFormatter (error messages, system intro, keybind display)
---   • THF_MACROBOOK (macro info for intro message)
---   • THF_LOCKSTYLE (lockstyle info for intro message)
---
--- @file    config/thf/THF_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-06
---============================================================================

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local THFKeybinds = {}

-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Keybind definitions for THF job
-- Format: { key = "key_combination", command = "gs_command", desc = "description", state = "state_name", subjob = "required_subjob" }
THFKeybinds.binds = {
    -- Weapon Management
    { key = "^numpad1", command = "cyclestate MainWeapon", desc = "Main Weapon",  state = "MainWeapon" },
    { key = "^numpad2", command = "cyclestate SubWeapon", desc = "Sub Weapon",  state = "SubWeapon" },

    -- Combat Mode Control
    { key = "^numpad9", command = "cyclestate HybridMode", desc = "Hybrid Mode",  state = "HybridMode" },

    -- Treasure Hunter Mode
    { key = "^numpad3", command = "cyclestate TreasureMode", desc = "TH Mode",  state = "TreasureMode" },

    -- Abyssea Proc Mode (for /WAR subjob)
    { key = "^numpad4", command = "toggle AbyProc", desc = "Aby Proc",  state = "AbyProc", subjob = "WAR" },
    { key = "^numpad5", command = "cyclestate AbyWeapon", desc = "Aby Weapon",  state = "AbyWeapon", subjob = "WAR" },

    -- Ranged Weapon Lock
    { key = "^numpad6", command = "toggle RangeLock", desc = "Range Lock",  state = "RangeLock" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

---============================================================================
--- KEYBIND MANAGEMENT FUNCTIONS
---============================================================================

--- Get filtered keybinds based on current subjob
--- Filters out subjob-specific binds that don't match current subjob.
--- @return table Filtered keybinds appropriate for current subjob
function THFKeybinds.get_active_binds()
    local active_binds = {}
    local current_subjob = player and player.sub_job or nil

    for _, bind in ipairs(THFKeybinds.binds) do
        -- Include bind if no subjob requirement, or if subjob matches
        if not bind.subjob or bind.subjob == current_subjob then
            table.insert(active_binds, bind)
        end
    end

    return active_binds
end

--- Apply the keybinds of the current subjob
--- @return boolean Success status of binding operation
function THFKeybinds.bind_all()
    -- Validate binds exist
    if not THFKeybinds.binds or #THFKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("THF")
        return false
    end

    -- Get filtered binds based on current subjob
    local active_binds = THFKeybinds.get_active_binds()

    -- Unbind only the keys that will NOT be bound back. Dropping a conditional
    -- bind left over from another subjob is the whole point of this pass: it
    -- would otherwise stay bound to a state this subjob never creates, and do
    -- nothing when pressed.
    --
    -- The keys we are about to bind are deliberately left alone. A bind
    -- overwrites an existing one, so unbinding first gains nothing and opens a
    -- window where the key is down. That window is where ^numpad9 went missing
    -- after a reload: its bind is sent unconditionally every time, and
    -- `//gs c cyclestate HybridMode` still answered while the key was dead - so
    -- the key had been unbound and the bind that should have followed never
    -- took effect.
    local keeping = {}
    for _, bind in ipairs(active_binds) do
        keeping[bind.key] = true
    end
    for _, bind in ipairs(THFKeybinds.binds) do
        if not keeping[bind.key] then
            pcall(send_command, 'unbind ' .. bind.key)
        end
    end

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in ipairs(active_binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            -- Log the specific error message if available
            local error_detail = error_msg and tostring(error_msg) or "Command execution failed"
            MessageFormatter.show_bind_failed_error(bind.key, error_detail)
        end
    end

    -- Show intro message if successful
    if bound_count > 0 then
        THFKeybinds.show_intro()
        return true
    end

    return false
end

--- Remove all keybinds
--- @return boolean Success status of unbinding operation
function THFKeybinds.unbind_all()
    if not THFKeybinds.binds then
        return false
    end

    for _, bind in pairs(THFKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("THF keybinds unloaded.")
    return true
end

--- Display THF system intro message with macrobook and lockstyle info
--- @return void
function THFKeybinds.show_intro()
    -- Try to get macro info from THF_MACROBOOK module
    local macro_info = nil
    local success, THF_MACROBOOK = pcall(require, 'shared/jobs/thf/functions/THF_MACROBOOK')
    if success and THF_MACROBOOK and THF_MACROBOOK.get_thf_macro_info then
        macro_info = THF_MACROBOOK.get_thf_macro_info()
    end

    -- Try to get lockstyle info from THF_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, THF_LOCKSTYLE = pcall(require, 'shared/jobs/thf/functions/THF_LOCKSTYLE')
    if lockstyle_success and THF_LOCKSTYLE and THF_LOCKSTYLE.get_info then
        lockstyle_info = THF_LOCKSTYLE.get_info()
    end

    -- Get active binds (filtered by subjob)
    local active_binds = THFKeybinds.get_active_binds()

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("THF SYSTEM LOADED", active_binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("THF SYSTEM LOADED", active_binds)
    end
end

--- Display current keybind configuration
--- @return void
function THFKeybinds.show_binds()
    MessageFormatter.show_keybind_list("THF Keybinds", THFKeybinds.binds)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return THFKeybinds

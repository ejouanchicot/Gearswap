---============================================================================
--- PLD Keybind Configuration - Flexible Key Mapping System
---============================================================================
--- Centralized keybind management for Paladin job.
---
--- Features:
---   • User-customizable key mappings without modifying core job files
---   • State-based keybind organization (Weapon, Combat Modes, Subjob-specific)
---   • Subjob filtering (XP mode for RDM, Rune mode for RUN)
---   • Automatic bind/unbind with error handling
---   • System intro message with macro and lockstyle info display
---
--- @file    config/pld/PLD_KEYBINDS.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-03
---============================================================================
---============================================================================
--- DEPENDENCIES
---============================================================================
-- Load message formatter for consistent display
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND CONFIGURATION
---============================================================================

local PLDKeybinds = {}

--- Keybind definitions for PLD job
--- Format: { key = "key_combo", command = "gs_command", desc = "description",
---           state = "state_name", subjob = "required_subjob",
---           exclude_subjob = "subjob_that_skips_this_bind",
---           visible = function() ... end }
---
--- `subjob` and `exclude_subjob` are settled once per load; `visible` is asked
--- again on every HUD refresh, for a bind whose usefulness depends on a state
--- rather than on the job.
---
--- Under /SCH Phalanx SIRD is held on, so its bind is excluded rather than
--- left cycling a state nothing reads any more; Ctrl+Numpad2 is free there.
--- The weapon stays cyclable: the /SCH stances pick the set, not the sword.
PLDKeybinds.binds = { -- Hybrid Mode (PDT/MDT/Sortie, DPS/Tanking/Hoxne under /SCH)
{
    key = "^numpad9",
    command = "cyclestate HybridMode",
    desc = "Hybrid Mode",
    state = "HybridMode"
}, -- Weapon Management
{
    key = "^numpad1",
    command = "cyclestate MainWeapon",
    desc = "Main Weapon",
    state = "MainWeapon",
    -- Under /SCH the Tanking stance holds Burtgang whatever this says, so the
    -- choice has nothing to act on there: hide the row and drop the key rather
    -- than leave a live-looking control that changes nothing until you leave
    -- the stance.
    visible = function()
        return not (player and player.sub_job == 'SCH'
            and state and state.HybridMode and state.HybridMode.value == 'Tanking')
    end
}, -- XP Mode (PLD/RDM subjob only)
{
    key = "^numpad4",
    command = "cyclestate Xp",
    desc = "XP Mode",
    state = "Xp",
    subjob = "RDM"
}, -- Rune Mode (PLD/RUN subjob only)
{
    key = "^numpad3",
    command = "cyclestate RuneMode",
    desc = "Rune Mode",
    state = "RuneMode",
    subjob = "RUN"
},
    { key = "^numpad2", command = "cyclestate PhalanxSIRD", desc = "Phalanx SIRD", state = "PhalanxSIRD", exclude_subjob = "SCH" },
    { key = "^numpad5", command = "cyclestate WS1", desc = "WS Slot 1", state = "WS1" },
    { key = "^numpad6", command = "cyclestate WS2", desc = "WS Slot 2", state = "WS2" },
    { key = "#numpad0", command = "cyclestate AutoMedicine", desc = "Auto Medicine", state = "AutoMedicine" },
}

--- Keys this file used to bind and no longer does.
--- bind_all/unbind_all only ever walk PLDKeybinds.binds, so a key dropped from
--- that table keeps whatever Windower bound to it last - across reloads, for
--- the rest of the session. Listing it here is what finally clears it.
--- ^numpad7 held SneakInviAOE, retired when /SCH started holding it On.
PLDKeybinds.retired_keys = {
    "^numpad7"
}

--- The keys currently laid down, as key -> command.
--- bind_all() rewrites it wholesale; refresh() diffs against it and sends only
--- what actually changed. A stance change usually changes nothing at all -
--- DPS and Hoxne carry the same binds - and re-issuing the whole list on every
--- press put dozens of commands into Windower's queue for no effect.
local applied = {}

---============================================================================
--- KEYBIND MANAGEMENT
---============================================================================

--- Get the keybinds that apply right now
--- Drops subjob-specific binds that do not match, binds this subjob excludes,
--- and binds whose visible() says they have nothing to act on.
---
--- Both the HUD and bind_all() read this, so a bind dropped here disappears
--- from the display and loses its key together.
---
--- @return table Keybinds that apply to the current subjob and state
function PLDKeybinds.get_active_binds()
    local active_binds = {}
    local current_subjob = player and player.sub_job or nil

    for _, bind in ipairs(PLDKeybinds.binds) do
        local required = (not bind.subjob) or bind.subjob == current_subjob
        local excluded = bind.exclude_subjob and bind.exclude_subjob == current_subjob
        local shown = (type(bind.visible) ~= 'function') or bind.visible()
        if required and not excluded and shown then
            table.insert(active_binds, bind)
        end
    end

    return active_binds
end

--- Apply all keybinds defined in the configuration
--- Validates binds, attempts to bind each key, and displays intro on success.
---
--- @param silent boolean|nil True to skip the intro message (see refresh)
--- @return boolean True if at least one keybind was successfully applied, false otherwise
function PLDKeybinds.bind_all(silent)
    -- Validate binds exist
    if not PLDKeybinds.binds or #PLDKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("PLD")
        return false
    end

    -- Get filtered binds based on current subjob
    local active_binds = PLDKeybinds.get_active_binds()

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
    for _, bind in ipairs(PLDKeybinds.binds) do
        if not keeping[bind.key] then
            pcall(send_command, 'unbind ' .. bind.key)
        end
    end
    for _, key in ipairs(PLDKeybinds.retired_keys) do
        pcall(send_command, 'unbind ' .. key)
    end

    -- Attempt to bind each key
    local bound_count = 0
    for _, bind in ipairs(active_binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            -- Log specific error if available
            local error_detail = error_msg and tostring(error_msg) or "Command execution failed"
            MessageFormatter.show_bind_failed_error(bind.key, error_detail)
        end
    end

    -- Record what is down, so refresh() has something to diff against.
    applied = {}
    for _, bind in pairs(active_binds) do
        applied[bind.key] = bind.command
    end

    -- Show intro message if at least one bind succeeded
    if bound_count > 0 then
        if not silent then
            PLDKeybinds.show_intro()
        end
        return true
    end

    -- Zero keys down while binds are defined means every send_command failed.
    -- Silence here is what made this hard to chase: GearSwap keeps working,
    -- //gs c commands keep working, and only the keys are missing.
    MessageFormatter.show_error(
        ('PLD keybinds: %d bind(s) defined but none applied - keys will not respond')
        :format(#active_binds))

    return false
end

--- Bring the keys in line with the state the job is in now.
---
--- A `visible` bind can come and go while the job stays the same, and bind_all
--- only runs on load and on a subjob change - so a key would outlive the row
--- it belongs to. Called from the HybridMode state hook, which fires on every
--- press of the cycle key.
---
--- Sends only the difference. Re-issuing the whole list meant nineteen
--- commands per press to change nothing, and cycling quickly buried Windower's
--- queue under hundreds of them.
--- @return number How many bind/unbind commands were sent
function PLDKeybinds.refresh()
    local desired = {}
    for _, bind in pairs(PLDKeybinds.get_active_binds()) do
        desired[bind.key] = bind.command
    end

    local sent = 0

    for key, command in pairs(applied) do
        if desired[key] ~= command then
            pcall(send_command, 'unbind ' .. key)
            sent = sent + 1
        end
    end

    for key, command in pairs(desired) do
        if applied[key] ~= command then
            pcall(send_command, 'bind ' .. key .. ' gs c ' .. command)
            sent = sent + 1
        end
    end

    applied = desired
    return sent
end

--- Remove all keybinds
--- Safely unbinds all keys defined in the configuration.
---
--- @return boolean True if unbind operations completed, false if no binds defined
function PLDKeybinds.unbind_all()
    if not PLDKeybinds.binds then
        return false
    end

    for _, bind in pairs(PLDKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end
    for _, key in pairs(PLDKeybinds.retired_keys) do
        pcall(send_command, 'unbind ' .. key)
    end

    MessageFormatter.show_success("PLD keybinds unloaded.")
    return true
end

---============================================================================
--- SYSTEM INTRO & DISPLAY
---============================================================================

--- Display PLD system intro message with macrobook and lockstyle info
--- Attempts to load additional info from PLD_MACROBOOK and PLD_LOCKSTYLE modules.
--- Falls back to basic intro if additional info unavailable.
---
--- @return void
function PLDKeybinds.show_intro()
    -- Try to get macro info from PLD_MACROBOOK module
    local macro_info = nil
    local success, PLD_MACROBOOK = pcall(require, 'shared/jobs/pld/functions/PLD_MACROBOOK')
    if success and PLD_MACROBOOK and PLD_MACROBOOK.get_pld_macro_info then
        macro_info = PLD_MACROBOOK.get_pld_macro_info()
    end

    -- Try to get lockstyle info from PLD_LOCKSTYLE module
    local lockstyle_info = nil
    local lockstyle_success, PLD_LOCKSTYLE = pcall(require, 'shared/jobs/pld/functions/PLD_LOCKSTYLE')
    if lockstyle_success and PLD_LOCKSTYLE and PLD_LOCKSTYLE.get_info then
        lockstyle_info = PLD_LOCKSTYLE.get_info()
    end

    -- Get active binds (filtered by subjob)
    local active_binds = PLDKeybinds.get_active_binds()

    -- Show complete intro with macro and lockstyle info
    if macro_info or lockstyle_info then
        MessageFormatter.show_system_intro_complete("PLD SYSTEM LOADED", active_binds, macro_info, lockstyle_info)
    else
        -- Fallback to regular intro if no additional info available
        MessageFormatter.show_system_intro("PLD SYSTEM LOADED", active_binds)
    end
end

--- Display current keybind configuration
--- Formats and displays all configured keybinds in a readable list.
---
--- @return void
function PLDKeybinds.show_binds()
    MessageFormatter.show_keybind_list("PLD Keybinds", PLDKeybinds.binds)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return PLDKeybinds

---============================================================================
--- BST Keybind Configuration
---============================================================================
--- Keybind configuration for Beastmaster job.
--- Uses DUAL SYSTEM: Number keys (1,4-7) for state cycling + Alt+Numbers (!5,!6) for ecosystem/species functions.
---
--- @file config/bst/BST_KEYBINDS.lua
--- @author Morphetrix
--- @version 1.0
--- @date Created: 2025-10-17
---============================================================================

local BSTKeybinds = {}

-- Load message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

---============================================================================
--- KEYBIND DEFINITIONS (DUAL SYSTEM)
---============================================================================

--- Keybinds table
--- Format: { key = "key", command = "gs_command", desc = "description", state = "state_name" }
---
--- DUAL SYSTEM EXPLANATION:
--- • Number keys (1,4-7): Cycle Mote states using "cycle StateNam" command
--- • Alt+Numbers (!5,!6): Call BST-specific functions using command name directly
BSTKeybinds.binds = {
    ---==========================================================================
    --- WEAPON MANAGEMENT (Number Keys)
    ---==========================================================================
    { key = "1", command = "cycle WeaponSet", desc = "Main Weapon", state = "WeaponSet" },
    { key = "4", command = "cycle SubSet", desc = "Sub/Shield", state = "SubSet" },

    ---==========================================================================
    --- COMBAT MODES (Number Keys)
    ---==========================================================================
    { key = "5", command = "cycle HybridMode", desc = "Hybrid Mode", state = "HybridMode" },
    { key = "6", command = "cycle AutoPetEngage", desc = "Auto Pet Engage", state = "AutoPetEngage" },
    { key = "7", command = "cycle petIdleMode", desc = "Pet Idle Mode", state = "petIdleMode" },
    { key = "8", command = "cycle QuickReady", desc = "Quick Ready", state = "QuickReady" },

    ---==========================================================================
    --- ECOSYSTEM/SPECIES MANAGEMENT (Alt+Numbers - BST Functions)
    ---==========================================================================
    { key = "!5", command = "ecosystem", desc = "Cycle Ecosystem", state = "ecosystem" },
    { key = "!6", command = "species", desc = "Cycle Species", state = "species" },

    ---==========================================================================
    --- PET MANAGEMENT (Alt+Numbers - BST Functions)
    ---==========================================================================
    { key = "!7", command = "broth", desc = "Show Broth Count" },
    { key = "!8", command = "pet engage", desc = "Engage Pet" },
    { key = "!9", command = "pet disengage", desc = "Disengage Pet" }
}

---============================================================================
--- KEYBIND MANAGEMENT FUNCTIONS
---============================================================================

--- Apply all keybinds
--- @return boolean success True if at least one keybind was applied successfully
function BSTKeybinds.bind_all()
    if not BSTKeybinds.binds or #BSTKeybinds.binds == 0 then
        MessageFormatter.show_no_binds_error("BST")
        return false
    end

    local bound_count = 0
    for _, bind in pairs(BSTKeybinds.binds) do
        local success, error_msg = pcall(send_command, 'bind ' .. bind.key .. ' gs c ' .. bind.command)
        if success then
            bound_count = bound_count + 1
        else
            add_to_chat(167, '[BST] Keybind Error (' .. bind.key .. '): ' .. tostring(error_msg))
        end
    end

    if bound_count > 0 then
        BSTKeybinds.show_intro()
        return true
    else
        MessageFormatter.show_no_binds_error("BST")
        return false
    end
end

--- Remove all keybinds
--- @return void
function BSTKeybinds.unbind_all()
    if not BSTKeybinds.binds then return end

    for _, bind in pairs(BSTKeybinds.binds) do
        pcall(send_command, 'unbind ' .. bind.key)
    end

    MessageFormatter.show_success("BST keybinds unloaded.")
end

---============================================================================
--- SYSTEM INTRO & DISPLAY
---============================================================================

--- Display BST system intro message
--- @return void
function BSTKeybinds.show_intro()
    MessageFormatter.show_system_intro("BST SYSTEM LOADED", BSTKeybinds.binds)
end

--- Display current keybind configuration
--- @return void
function BSTKeybinds.show_binds()
    MessageFormatter.show_keybind_list("BST Keybinds", BSTKeybinds.binds)
end

---============================================================================
--- KEYBIND STATE GETTER (for UI display)
---============================================================================

--- Get current state value for a keybind
--- @param bind_config table Keybind configuration entry
--- @return string|nil state_value Current state value or nil if state not found
function BSTKeybinds.get_state_value(bind_config)
    if not bind_config.state then
        return nil
    end

    -- Check if state exists globally
    if _G.state and _G.state[bind_config.state] then
        return _G.state[bind_config.state].current or _G.state[bind_config.state].value
    end

    return nil
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return BSTKeybinds

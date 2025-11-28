---============================================================================
--- Warp System Auto-Initialization (Universal - No Mote Modification)
---============================================================================
--- Provides universal warp detection + equipment lock for ALL jobs
--- WITHOUT modifying Mote-Include.lua
---
--- How it works:
---   1. Load this file from each job's user_setup() or get_sets()
---   2. It hooks into global precast function
---   3. Detects warp spells + items automatically
---   4. Forces FC + locks equipment
---   5. Registers warp commands (//gs c warp [status|unlock|lock|test|help])
---
--- @file warp_init.lua
--- @author Tetsouo
--- @version 1.1 - Added command support
--- @date 2025-10-26
---============================================================================

local WarpInit = {}

local initialized = false

-- Load MessageWarp for formatted messages
local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

---============================================================================
--- GLOBAL PRECAST HOOK (Intercept without modifying Mote-Include)
---============================================================================

local original_precast = nil

--- Hook the global precast function to inject warp detection
local function hook_global_precast()
    -- Save original precast if exists
    if _G.precast and type(_G.precast) == 'function' then
        original_precast = _G.precast
    end

    -- Replace with our hooked version
    _G.precast = function(spell)
        -- FIRST: Check for warp spells and handle them
        if spell and spell.action_type == 'Magic' then
            local WarpPrecast = require('shared/utils/warp/warp_precast')
            WarpPrecast.handle_precast(spell, nil)
        end

        -- SECOND: Call original precast
        if original_precast then
            original_precast(spell)
        end
    end
end

---============================================================================
--- INITIALIZATION
---============================================================================

--- Initialize the universal warp system
--- Call this from user_setup() or get_sets() in each job file
function WarpInit.init()
    if initialized then
        return  -- Already initialized
    end

    -- Load and initialize warp equipment manager
    local eq_success, WarpEquipment = pcall(require, 'shared/utils/warp/warp_equipment')
    if eq_success and WarpEquipment then
        WarpEquipment.init()
    else
        MessageWarp.show_init_error('WarpEquipment', WarpEquipment)
        return
    end

    -- Load warp precast
    local pc_success, WarpPrecast = pcall(require, 'shared/utils/warp/warp_precast')
    if pc_success and WarpPrecast then
        WarpPrecast.init()
    else
        MessageWarp.show_init_error('WarpPrecast', WarpPrecast)
        return
    end

    -- Hook global precast function
    hook_global_precast()

    -- Register warp commands with common commands
    local cmd_success, WarpCommands = pcall(require, 'shared/utils/warp/warp_commands')
    if cmd_success and WarpCommands then
        WarpCommands.register()
        MessageWarp.show_commands_registered()
    end

    -- Initialize IPC system for multi-boxing support (GLOBAL SCOPE via include)
    local ipc_success = pcall(include, 'shared/utils/warp/warp_ipc_register.lua')
    if not ipc_success then
        MessageWarp.show_ipc_unavailable()
    end

    initialized = true
    MessageWarp.show_init_success()
end

---============================================================================
--- CONVENIENCE FUNCTIONS
---============================================================================

--- Check if system is initialized
--- @return boolean True if initialized
function WarpInit.is_initialized()
    return initialized
end

--- Manual warp detection (for custom integrations)
--- @param spell table The spell object
function WarpInit.handle_warp_spell(spell)
    local WarpPrecast = require('shared/utils/warp/warp_precast')
    WarpPrecast.handle_precast(spell, nil)
end

return WarpInit

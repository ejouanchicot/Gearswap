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

-- True once init() has run in this sandbox. windower._warp_init_done only
-- marks the once-per-session part.
local initialized = false

-- Load MessageWarp for formatted messages
local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

---============================================================================
--- GLOBAL PRECAST HOOK (Intercept without modifying Mote-Include)
---============================================================================

local original_precast = nil

--- Hook the global precast function to inject warp detection (once per sandbox)
local function hook_global_precast()
    -- A load replaced within 0.5 s runs its deferred init after the new load,
    -- on a second copy of this module in the new sandbox; wrapping twice would
    -- handle every warp spell twice.
    if rawget(_G, 'WARP_PRECAST_HOOKED') then
        return
    end
    _G.WARP_PRECAST_HOOKED = true

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
--- Called by INIT_SYSTEMS 0.5 s after every job-file load
function WarpInit.init()
    -- Everything up to the precast hook runs on every load: GearSwap drops
    -- every sandbox event listener when it loads a job file, and the new
    -- sandbox's precast is Mote's own.
    local ipc_success = pcall(include, 'shared/utils/warp/warp_ipc_register.lua')
    if not ipc_success then
        MessageWarp.show_ipc_unavailable()
    end

    -- Load and initialize warp equipment manager (detector action listener)
    local eq_success, WarpEquipment = pcall(require, 'shared/utils/warp/warp_equipment')
    if eq_success and WarpEquipment then
        -- Wrap init() in pcall: if WarpDetector throws, catch silently and report
        local ok_eq, err_eq = pcall(WarpEquipment.init)
        if not ok_eq then
            MessageWarp.show_init_error('WarpEquipment.init', err_eq)
            return
        end
    else
        MessageWarp.show_init_error('WarpEquipment', WarpEquipment)
        return
    end

    -- Load warp precast
    local pc_success, WarpPrecast = pcall(require, 'shared/utils/warp/warp_precast')
    if pc_success and WarpPrecast then
        local ok_pc, err_pc = pcall(WarpPrecast.init)
        if not ok_pc then
            MessageWarp.show_init_error('WarpPrecast.init', err_pc)
            return
        end
    else
        MessageWarp.show_init_error('WarpPrecast', WarpPrecast)
        return
    end

    -- Hook global precast function
    hook_global_precast()
    initialized = true

    -- Once per Windower session: command registration and its messages
    if windower._warp_init_done then
        return
    end

    -- Warp commands need no registration: COMMON_COMMANDS.handle_warp_commands
    -- requires this module directly when a //gs c warp command arrives.
    MessageWarp.show_commands_registered()

    windower._warp_init_done = true
    MessageWarp.show_init_success()
end

---============================================================================
--- CONVENIENCE FUNCTIONS
---============================================================================

--- Check if system is initialized in this sandbox (listeners + precast hook)
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

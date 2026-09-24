---============================================================================
--- Warp Init - Per-load bootstrap of the warp system
---============================================================================
--- Called by INIT_SYSTEMS 0.5 s after every job-file load, for every job.
--- Without modifying Mote-Include.lua it:
---   1. Registers the warp IPC listener (warp_ipc_register.lua)
---   2. Initializes WarpEquipment (detector `action` listener)
---   3. Initializes WarpPrecast
---   4. Wraps _G.precast so warp spells get Fast Cast before Mote's precast
--- Warp commands need no registration: CommonCommands requires
--- warp_commands.lua on demand.
---
--- @file shared/utils/warp/warp_init.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2025-10-26
---============================================================================

local WarpInit = {}

-- True once init() has run in this sandbox. windower._warp_init_done only
-- marks the once-per-session part.
local initialized = false

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

    if _G.precast and type(_G.precast) == 'function' then
        original_precast = _G.precast
    end

    _G.precast = function(spell)
        if spell and spell.action_type == 'Magic' then
            local WarpPrecast = require('shared/utils/warp/warp_precast')
            WarpPrecast.handle_precast(spell, nil)
        end

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

    -- Warp equipment manager (registers the detector action listener)
    local eq_success, WarpEquipment = pcall(require, 'shared/utils/warp/warp_equipment')
    if eq_success and WarpEquipment then
        local ok_eq, err_eq = pcall(WarpEquipment.init)
        if not ok_eq then
            MessageWarp.show_init_error('WarpEquipment.init', err_eq)
            return
        end
    else
        MessageWarp.show_init_error('WarpEquipment', WarpEquipment)
        return
    end

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

    hook_global_precast()
    initialized = true

    -- Once per addon session (windower.* survives reloads): the init messages
    if windower._warp_init_done then
        return
    end

    -- Warp commands need no registration: COMMON_COMMANDS.handle_warp_commands
    -- requires warp_commands.lua directly when a //gs c warp command arrives.
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

--- Manual warp detection (for custom integrations; no caller today)
--- @param spell table The spell object
function WarpInit.handle_warp_spell(spell)
    local WarpPrecast = require('shared/utils/warp/warp_precast')
    WarpPrecast.handle_precast(spell, nil)
end

return WarpInit

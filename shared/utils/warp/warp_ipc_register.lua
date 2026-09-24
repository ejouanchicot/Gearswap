---============================================================================
--- Warp IPC Listener Registration
---============================================================================
--- Registers the live 'ipc message' listener: the receiver side of the warp
--- `all` commands (sender: warp_ipc.lua). Runs as a script, not a module:
--- WarpInit.init() include()s it on every job-file load.
---
--- @file shared/utils/warp/warp_ipc_register.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2025-10-28
---============================================================================

-- WarpInit includes this file on every job load. GearSwap has already dropped
-- the previous load's listener by then (refresh.lua:69-71), so only an id
-- registered earlier in this same load is removed: a stale id could now belong
-- to another listener. The load stamp is windower._gs_reload_count, bumped by
-- INIT_SYSTEMS on every load. Same convention as warp_detector and
-- dualbox_sync_ipc.
if windower._warp_ipc_register_event_id
   and windower._warp_ipc_register_event_load == windower._gs_reload_count then
    pcall(windower.unregister_event, windower._warp_ipc_register_event_id)
end
windower._warp_ipc_register_event_id = nil

local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

-- Same prefix as warp_ipc.lua (sender)
local IPC_PREFIX = 'tetsouo_warp_'

-- Whitelist of allowed commands. Single source of truth: warp_command_registry.
local Registry = require('shared/utils/warp/warp_command_registry')

--- Check if command is whitelisted (via registry's O(1) lookup set).
local function is_command_allowed(command)
    return Registry.is_warp_command(command:lower())
end

-- Debounce tracking. IPC_DEBOUNCE shared via Registry to keep sender
-- (warp_ipc) and receiver (here) in lockstep.
local last_ipc_message = ''
local last_ipc_time = 0
local IPC_DEBOUNCE = Registry.IPC_DEBOUNCE

---============================================================================
--- IPC LISTENER
---============================================================================

windower._warp_ipc_register_event_id = windower.register_event('ipc message', function(msg)
    if _G.WARP_DEBUG then
        MessageWarp.show_ipc_raw_received(msg)
    end

    if not msg or not msg:find('^' .. IPC_PREFIX) then
        return
    end

    -- While this instance is broadcasting (2.5 s), drop every warp message:
    -- send_to_all already runs the command locally.
    if _G.WARP_IPC_BROADCASTING then
        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_debounced()
        end
        return
    end

    if msg:find('^tetsouo_warp_test_') then
        local sender = msg:gsub('^tetsouo_warp_test_', '')
        MessageWarp.show_ipc_test_received(sender)
        return
    end

    local current_time = os.clock()
    if msg == last_ipc_message and (current_time - last_ipc_time) < IPC_DEBOUNCE then
        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_debounced()
        end
        return
    end

    last_ipc_message = msg
    last_ipc_time = current_time

    -- Extract command: 'tetsouo_warp_warp' >> 'warp'
    local command = msg:gsub('^' .. IPC_PREFIX, '')

    MessageWarp.show_ipc_command_received(command)

    if not is_command_allowed(command) then
        MessageWarp.show_ipc_not_allowed(command)
        return
    end

    MessageWarp.show_ipc_executing(command)
    coroutine.schedule(function()
        windower.chat.input('//gs c ' .. command)
    end, 0.5)
end)
windower._warp_ipc_register_event_load = windower._gs_reload_count

MessageWarp.show_ipc_registered()

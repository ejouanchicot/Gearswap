---============================================================================
--- Warp IPC Listener Registration (Job-Level)
---============================================================================
--- This file registers the IPC listener at the job level (like MyHome does).
--- Must be included/executed in each job's main file to persist across reloads.
---
--- Usage in job file (TETSOUO_WAR.lua, KAORIES_BRD.lua, etc.):
---   include('shared/utils/warp/warp_ipc_register')
---
--- @file warp_ipc_register.lua
--- @author Tetsouo
--- @version 1.1 - Job-level registration (like MyHome)
--- @date 2025-10-28
---============================================================================

-- Unregister old listener before re-registering (survives job changes/reloads)
if _G.WARP_IPC_REGISTERED and _G.WARP_IPC_EVENT_ID then
    windower.unregister_event(_G.WARP_IPC_EVENT_ID)
    _G.WARP_IPC_EVENT_ID = nil
    _G.WARP_IPC_REGISTERED = false
end

-- Load MessageWarp for formatted messages
local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

-- IPC message prefix
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
--- IPC LISTENER (Registered at Job Level - Like MyHome)
---============================================================================

_G.WARP_IPC_EVENT_ID = windower.register_event('ipc message', function(msg)
    -- Debug: Show ALL IPC messages
    if _G.WARP_DEBUG then
        MessageWarp.show_ipc_raw_received(msg)
    end

    -- Only process our messages
    if not msg or not msg:find('^' .. IPC_PREFIX) then
        return
    end

    -- Skip self-echo: if WE sent this broadcast, don't process it again
    -- (we already execute locally in send_to_all via coroutine.schedule)
    if _G.WARP_IPC_BROADCASTING then
        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_debounced()
        end
        return
    end

    -- TEST MESSAGE
    if msg:find('^tetsouo_warp_test_') then
        local sender = msg:gsub('^tetsouo_warp_test_', '')
        MessageWarp.show_ipc_test_received(sender)
        return
    end

    -- Debounce
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

    -- Verify whitelist
    if not is_command_allowed(command) then
        MessageWarp.show_ipc_not_allowed(command)
        return
    end

    -- Execute command
    MessageWarp.show_ipc_executing(command)
    coroutine.schedule(function()
        windower.chat.input('//gs c ' .. command)
    end, 0.5)
end)

-- Mark as registered
_G.WARP_IPC_REGISTERED = true

MessageWarp.show_ipc_registered()

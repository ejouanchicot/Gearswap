---============================================================================
--- Warp IPC - Broadcast warp commands to every dual-boxed instance
---============================================================================
--- Sender side of the `all` commands. The receiver side is the listener in
--- warp_ipc_register.lua (registered by WarpInit on every load).
---
--- Usage:
---   //gs c warpall       >> All characters warp
---   //gs c tphall        >> All characters teleport to Holla
---   //gs c sdall         >> All characters go to San d'Oria
---
--- How it works:
---   1. Character 1 types //gs c warpall
---   2. WarpIPC.send_to_all('warp') runs '//gs c warp' locally (+0.3 s) and
---      sends 'tetsouo_warp_warp' over IPC (+0.5 s)
---   3. The other instances' warp_ipc_register listener runs //gs c warp
---
--- @file shared/utils/warp/warp_ipc.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-28
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

local WarpIPC = {}

-- IPC message prefix to avoid conflicts with other addons
local IPC_PREFIX = 'tetsouo_warp_'

-- Debounce: Track last received IPC message to prevent loops.
-- IPC_DEBOUNCE shared via warp_command_registry to avoid divergence between
-- sender (here) and receiver (warp_ipc_register).
local last_ipc_message = ''
local last_ipc_time = 0
local IPC_DEBOUNCE = require('shared/utils/warp/warp_command_registry').IPC_DEBOUNCE

-- Track if we initiated the broadcast (to avoid duplicate local execution)
local initiated_broadcast = false

---============================================================================
--- WHITELIST: Commands allowed for "all" broadcast
---============================================================================
-- Single source of truth: warp_command_registry. Both this whitelist and the
-- main command-dispatch list (COMMON_COMMANDS.lua) read from the same array.
local ALLOWED_COMMANDS = require('shared/utils/warp/warp_command_registry').COMMANDS

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if a command is whitelisted for broadcast
--- @param command string Command to check
--- @return boolean True if command is allowed
local function is_command_allowed(command)
    local cmd = command:lower()
    for _, allowed in ipairs(ALLOWED_COMMANDS) do
        if cmd == allowed then
            return true
        end
    end
    return false
end

---============================================================================
--- IPC LISTENER
---============================================================================

--- Handle incoming IPC messages from other characters.
--- Only reachable through WarpIPC.init(), which has no caller: the live
--- listener is warp_ipc_register.lua.
--- @param msg string IPC message received
local function handle_ipc_message(msg)
    if _G.WARP_DEBUG then
        MessageWarp.show_ipc_raw_received(msg)
    end

    if not msg:find('^tetsouo_warp_') then
        return
    end

    -- Skip our own broadcast echo (we already execute locally in send_to_all)
    if initiated_broadcast then
        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_debounced(msg)
        end
        return
    end

    if msg:find('^tetsouo_warp_test_') then
        local sender = msg:gsub('^tetsouo_warp_test_', '')
        MessageWarp.show_ipc_test_received(sender)
        return
    end

    MessageWarp.show_ipc_command_received(msg)

    local current_time = os.clock()
    if msg == last_ipc_message and (current_time - last_ipc_time) < IPC_DEBOUNCE then
        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_debounced(msg)
        end
        return
    end

    last_ipc_message = msg
    last_ipc_time = current_time

    -- Extract command from message: 'tetsouo_warp_warp' >> 'warp'
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
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Initialize IPC system (register listener). No caller today: the live
--- listener is registered by warp_ipc_register.lua. Unlike that file, this
--- unregisters the stored id without checking which load registered it.
function WarpIPC.init()
    if not windower or not windower.register_event then return end

    if windower._warp_ipc_event_id then
        pcall(windower.unregister_event, windower._warp_ipc_event_id)
        windower._warp_ipc_event_id = nil
    end

    windower._warp_ipc_event_id = windower.register_event('ipc message', handle_ipc_message)

    MessageWarp.show_ipc_registered()

    if _G.WARP_DEBUG then
        MessageWarp.show_ipc_listener_registered()
    end
end

--- Send command to all characters (including self)
--- @param command string Base command to execute (e.g., 'warp', 'tph', 'sd')
--- @return boolean True if broadcast was sent
function WarpIPC.send_to_all(command)
    local cmd = command:lower()

    if not is_command_allowed(cmd) then
        MessageCore.error('[WARP] Command "' .. cmd .. '" not allowed for broadcast')
        MessageCore.error('[WARP] Allowed commands: warp, tph, sd, etc. (see //gs c warp help)')
        return false
    end

    MessageWarp.show_ipc_broadcasting(cmd)

    -- Set BEFORE sending. The global is what the warp_ipc_register listener
    -- checks to drop incoming warp messages while this instance broadcasts.
    initiated_broadcast = true
    _G.WARP_IPC_BROADCASTING = true

    -- Execute locally with slight delay (avoids GearSwap self_command reentrancy)
    -- windower.chat.input during active self_command handler can be dropped
    coroutine.schedule(function()
        windower.chat.input('//gs c ' .. cmd)

        if _G.WARP_DEBUG then
            MessageWarp.show_executing_local_command(cmd)
        end
    end, 0.3)

    -- Broadcast to other characters via IPC (after local execution starts)
    coroutine.schedule(function()
        local ipc_msg = IPC_PREFIX .. cmd

        if _G.WARP_DEBUG then
            MessageWarp.show_sending_ipc_message(ipc_msg)
        end

        windower.send_ipc_message(ipc_msg)

        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_sent()
        end

        -- Reset broadcast flags after delay (allow future IPC messages)
        coroutine.schedule(function()
            initiated_broadcast = false
            _G.WARP_IPC_BROADCASTING = false
        end, 2.0)
    end, 0.5)  -- After local execution has started

    return true
end

--- Check that the Windower IPC functions are available (no caller today)
--- @return boolean True if send_ipc_message and register_event exist
function WarpIPC.is_initialized()
    return windower.send_ipc_message ~= nil and windower.register_event ~= nil
end

--- Get list of allowed commands (no caller today)
--- @return table List of allowed command strings
function WarpIPC.get_allowed_commands()
    return ALLOWED_COMMANDS
end

return WarpIPC

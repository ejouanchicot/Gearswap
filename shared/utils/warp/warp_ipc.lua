---============================================================================
--- Warp IPC - Inter-Process Communication for Multi-Boxing
---============================================================================
--- Enables sending warp commands to all characters simultaneously.
--- Based on MyHome addon's IPC system.
---
--- Usage:
---   //gs c warpall       >> All characters warp
---   //gs c tphall        >> All characters teleport to Holla
---   //gs c sdall         >> All characters go to San d'Oria
---
--- How it works:
---   1. Character 1 types //gs c warpall
---   2. WarpIPC.send_to_all('warp') executes locally + broadcasts IPC message
---   3. Characters 2-4 receive IPC message and execute //gs c warp
---   4. All characters warp simultaneously
---
--- @file warp_ipc.lua
--- @author Tetsouo
--- @version 1.0
--- @date 2025-10-28
---============================================================================

local MessageCore = require('shared/utils/messages/message_core')
local MessageWarp = require('shared/utils/messages/formatters/system/message_warp')

local WarpIPC = {}

-- IPC message prefix to avoid conflicts with other addons
local IPC_PREFIX = 'tetsouo_warp_'

-- Debounce: Track last received IPC message to prevent loops
local last_ipc_message = ''
local last_ipc_time = 0
local IPC_DEBOUNCE = 1.0  -- 1 second debounce for IPC messages

-- Track if we initiated the broadcast (to avoid duplicate local execution)
local initiated_broadcast = false

---============================================================================
--- WHITELIST: Commands allowed for "all" broadcast
---============================================================================

-- Commands that are safe to broadcast to all characters
local ALLOWED_COMMANDS = {
    -- BLM Spells
    'w', 'warp', 'w2', 'warp2', 'ret', 'retrace', 'esc', 'escape',

    -- WHM Teleports
    'tph', 'tpholla', 'tpd', 'tpdem', 'tpm', 'tpmea',
    'tpa', 'tpaltep', 'tpy', 'tpyhoat', 'tpv', 'tpvahzl',

    -- Recalls
    'rj', 'recjugner', 'rp', 'recpashh', 'rm', 'recmeriph',

    -- Nations
    'sd', 'sandoria', 'bt', 'bastok', 'wd', 'windurst',

    -- Jeuno
    'jn', 'jeuno',

    -- Outpost Cities
    'sb', 'selbina', 'mh', 'mhaura', 'rb', 'rabao', 'kz', 'kazham', 'ng', 'norg',

    -- Expansion Cities
    'tv', 'tavnazia', 'au', 'wg', 'whitegate', 'ns', 'nashmau', 'ad', 'adoulin',

    -- Chocobo Stables
    'stsd', 'stable-sd', 'stbt', 'stable-bt', 'stwd', 'stable-wd', 'stjn', 'stable-jn',

    -- Conquest Outposts
    'op', 'outpost',

    -- Adoulin Frontier
    'cz', 'ceizak', 'ys', 'yahse', 'hn', 'hennetiel', 'mm', 'morimar',
    'mj', 'marjami', 'yc', 'yorcia', 'km', 'kamihr',

    -- Special Locations
    'wj', 'wajaom', 'ar', 'arrapago', 'pg', 'purgonorgo', 'rl', 'rulude',
    'zv', 'zvahl', 'riv', 'riverne', 'yo', 'yoran', 'lf', 'leafallia',
    'bh', 'behemoth', 'cc', 'chocircuit', 'pt', 'parting', 'cg', 'chocogirl',

    -- Unique Mechanics
    'ld', 'leader', 'td', 'tidal'
}

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

--- Count active Windower instances (for confirmation message)
--- @return number Number of other characters that will receive broadcast
local function count_other_characters()
    -- Simple heuristic: assume 1-3 other characters
    -- (Windower doesn't provide direct API to count instances)
    -- User will see actual execution in game
    return "other characters"
end

---============================================================================
--- IPC LISTENER
---============================================================================

--- Handle incoming IPC messages from other characters
--- @param msg string IPC message received
local function handle_ipc_message(msg)
    -- Debug: Show ALL IPC messages received (even non-warp ones)
    if _G.WARP_DEBUG then
        MessageWarp.show_ipc_raw_received(msg)
    end

    -- Only process messages with our prefix
    if not msg:find('^tetsouo_warp_') then
        return
    end

    -- TEST MESSAGE: Show test IPC messages
    if msg:find('^tetsouo_warp_test_') then
        local sender = msg:gsub('^tetsouo_warp_test_', '')
        MessageWarp.show_ipc_test_received(sender)
        return
    end

    MessageWarp.show_ipc_command_received(msg)

    -- Debounce: Ignore duplicate messages within 1 second
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

    -- Verify command is whitelisted
    if not is_command_allowed(command) then
        MessageWarp.show_ipc_not_allowed(command)
        return
    end

    MessageWarp.show_ipc_executing(command)

    -- Execute command locally
    coroutine.schedule(function()
        -- Small delay to avoid packet collision with initiating character
        windower.chat.input('//gs c ' .. command)
    end, 0.5)
end

---============================================================================
--- PUBLIC API
---============================================================================

--- Initialize IPC system (register listener)
function WarpIPC.init()
    -- Register IPC message listener
    windower.register_event('ipc message', handle_ipc_message)

    -- Always show initialization message for debugging
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

    -- Verify command is whitelisted
    if not is_command_allowed(cmd) then
        MessageCore.error('[WARP] Command "' .. cmd .. '" not allowed for broadcast')
        MessageCore.error('[WARP] Allowed commands: warp, tph, sd, etc. (see //gs c warp help)')
        return false
    end

    -- Show confirmation message
    MessageWarp.show_ipc_broadcasting(cmd)

    -- Execute locally first (immediate feedback)
    initiated_broadcast = true
    windower.chat.input('//gs c ' .. cmd)

    if _G.WARP_DEBUG then
        MessageWarp.show_executing_local_command(cmd)
    end

    -- Broadcast to other characters via IPC
    coroutine.schedule(function()
        local ipc_msg = IPC_PREFIX .. cmd

        if _G.WARP_DEBUG then
            MessageWarp.show_sending_ipc_message(ipc_msg)
        end

        windower.send_ipc_message(ipc_msg)

        if _G.WARP_DEBUG then
            MessageWarp.show_ipc_message_sent()
        end

        -- Reset broadcast flag after delay
        coroutine.schedule(function()
            initiated_broadcast = false
        end, 2.0)
    end, 0.1)  -- Small delay to let local command execute first

    return true
end

--- Check if IPC system is initialized
--- @return boolean True if initialized
function WarpIPC.is_initialized()
    -- Check if windower IPC functions are available
    return windower.send_ipc_message ~= nil and windower.register_event ~= nil
end

--- Get list of allowed commands (for help display)
--- @return table List of allowed command strings
function WarpIPC.get_allowed_commands()
    return ALLOWED_COMMANDS
end

return WarpIPC

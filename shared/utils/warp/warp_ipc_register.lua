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

-- Whitelist of allowed commands (same as warp_ipc.lua)
local ALLOWED_COMMANDS = {
    'w', 'warp', 'w2', 'warp2', 'ret', 'retrace', 'esc', 'escape',
    'tph', 'tpholla', 'tpd', 'tpdem', 'tpm', 'tpmea',
    'tpa', 'tpaltep', 'tpy', 'tpyhoat', 'tpv', 'tpvahzl',
    'rj', 'recjugner', 'rp', 'recpashh', 'rm', 'recmeriph',
    'sd', 'sandoria', 'bt', 'bastok', 'wd', 'windurst',
    'jn', 'jeuno',
    'sb', 'selbina', 'mh', 'mhaura', 'rb', 'rabao', 'kz', 'kazham', 'ng', 'norg',
    'tv', 'tavnazia', 'au', 'wg', 'whitegate', 'ns', 'nashmau', 'ad', 'adoulin',
    'stsd', 'stable-sd', 'stbt', 'stable-bt', 'stwd', 'stable-wd', 'stjn', 'stable-jn',
    'op', 'outpost',
    'cz', 'ceizak', 'ys', 'yahse', 'hn', 'hennetiel', 'mm', 'morimar',
    'mj', 'marjami', 'yc', 'yorcia', 'km', 'kamihr',
    'wj', 'wajaom', 'ar', 'arrapago', 'pg', 'purgonorgo', 'rl', 'rulude',
    'zv', 'zvahl', 'riv', 'riverne', 'yo', 'yoran', 'lf', 'leafallia',
    'bh', 'behemoth', 'cc', 'chocircuit', 'pt', 'parting', 'cg', 'chocogirl',
    'ld', 'leader', 'td', 'tidal'
}

--- Check if command is whitelisted
local function is_command_allowed(command)
    local cmd = command:lower()
    for _, allowed in ipairs(ALLOWED_COMMANDS) do
        if cmd == allowed then
            return true
        end
    end
    return false
end

-- Debounce tracking
local last_ipc_message = ''
local last_ipc_time = 0
local IPC_DEBOUNCE = 1.0

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

---  ═══════════════════════════════════════════════════════════════════════════
---   Dual-Box Sync IPC - Mirror local commands across paired Windower instances
---  ═══════════════════════════════════════════════════════════════════════════
---   Generic Windower-IPC bridge for "do the same thing on every running
---   instance of this addon" commands. Modeled on warp_ipc but with two
---   important design differences:
---
---     1. The receiver dispatches to a registered Lua HOOK (not via
---        windower.chat.input '//gs c <cmd>'). This avoids re-entering the
---        command router that issued the broadcast in the first place, so
---        the broadcast itself does NOT need a separate "*all" alias to
---        stay loop-free.
---
---     2. Self-echo suppression uses a per-message flag with a short TTL
---        (the broadcaster's own listener fires too).
---
---   Current hooks:
---     ls / lockstyle  ->  select_default_lockstyle()
---
---   To register a new sync command:
---     DualBoxSyncIPC.register_hook('mycmd', function() ... end)
---
---   @file shared/utils/dualbox/dualbox_sync_ipc.lua
---   @author Tetsouo
---  ═══════════════════════════════════════════════════════════════════════════

local DualBoxSyncIPC = {}

local IPC_PREFIX     = 'tetsouo_sync_'
local IPC_DEBOUNCE   = 1.0   -- seconds: drop duplicate msg within this window
local BROADCAST_TTL  = 1.5   -- seconds: how long after send to ignore self-echo

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOK REGISTRY (cmd_name -> function)
---  ═══════════════════════════════════════════════════════════════════════════
--- Stored on `_G` so registrations survive `package.loaded` clears on reload
--- and are visible to any caller that re-requires this module.
_G.DUALBOX_SYNC_HOOKS = _G.DUALBOX_SYNC_HOOKS or {}

--- Register a Lua function to run when this instance receives `<cmd>` via IPC.
--- Hook names are case-insensitive. Re-registering replaces the previous hook.
--- @param cmd string Lowercased command identifier (e.g. 'ls')
--- @param fn  function Zero-arg function to invoke on receive
function DualBoxSyncIPC.register_hook(cmd, fn)
    if type(cmd) ~= 'string' or type(fn) ~= 'function' then return end
    _G.DUALBOX_SYNC_HOOKS[cmd:lower()] = fn
end

--- Remove a previously registered hook (no-op if absent).
function DualBoxSyncIPC.unregister_hook(cmd)
    if type(cmd) == 'string' then
        _G.DUALBOX_SYNC_HOOKS[cmd:lower()] = nil
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SEND
---  ═══════════════════════════════════════════════════════════════════════════

--- Broadcast `cmd` to all other Windower instances running this addon.
--- The local instance does NOT execute `cmd` here - the caller is expected
--- to have already done its own work (this is just a "tell the other client"
--- side-channel, mirroring the warp_ipc design where the initiator runs
--- locally first and then broadcasts).
--- @param cmd string Whitelisted hook name (e.g. 'ls')
--- @return boolean true if a message was actually sent
function DualBoxSyncIPC.broadcast(cmd)
    if type(cmd) ~= 'string' or cmd == '' then return false end
    if not windower or not windower.send_ipc_message then return false end

    local lower_cmd = cmd:lower()
    -- Only broadcast commands that have a registered hook anywhere (sanity:
    -- prevents typos like 'lo' from polluting IPC traffic).
    if not _G.DUALBOX_SYNC_HOOKS[lower_cmd] then
        return false
    end

    -- Mark our own broadcast so our own listener can drop the echo.
    -- Stored on `windower` table so it persists across `gs reload` (which
    -- wipes `_G`) - critical because send + receive can straddle a reload.
    windower._sync_ipc_last_sent      = IPC_PREFIX .. lower_cmd
    windower._sync_ipc_last_sent_time = os.clock()

    windower.send_ipc_message(IPC_PREFIX .. lower_cmd)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   RECEIVE
---  ═══════════════════════════════════════════════════════════════════════════

--- True iff `msg` is our own freshly-sent broadcast (within BROADCAST_TTL).
--- Why: send_ipc_message also delivers to the sender, so without this guard
--- the local instance would double-execute every broadcast hook.
local function is_self_echo(msg)
    if windower._sync_ipc_last_sent ~= msg then return false end
    local sent_at = windower._sync_ipc_last_sent_time or 0
    return (os.clock() - sent_at) < BROADCAST_TTL
end

-- Debounce state (per-instance, ephemeral).
local last_msg, last_msg_time = '', 0

--- IPC message handler. Public so tests/debug can call it directly.
--- @param msg string raw IPC message
function DualBoxSyncIPC._on_ipc_message(msg)
    if type(msg) ~= 'string' then return end
    if msg:sub(1, #IPC_PREFIX) ~= IPC_PREFIX then return end  -- not ours

    if is_self_echo(msg) then return end

    -- Drop duplicate messages within the debounce window.
    local now = os.clock()
    if msg == last_msg and (now - last_msg_time) < IPC_DEBOUNCE then return end
    last_msg, last_msg_time = msg, now

    local cmd  = msg:sub(#IPC_PREFIX + 1):lower()
    local hook = _G.DUALBOX_SYNC_HOOKS[cmd]
    if not hook then return end

    -- Run hook in pcall so a buggy hook doesn't kill the IPC listener
    -- (the event handler would be lost until next reload).
    local ok, err = pcall(hook)
    if not ok and _G.DUALBOX_SYNC_DEBUG then
        windower.add_to_chat(167, '[SyncIPC] hook "' .. cmd .. '" error: ' .. tostring(err))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   LISTENER LIFECYCLE
---  ═══════════════════════════════════════════════════════════════════════════
--- Idempotent registration: GearSwap reloads wipe event handlers but the
--- registration token persists on `windower`, so we unregister-then-register
--- to avoid stacking duplicate handlers across rapid job changes.

--- Register the IPC listener exactly once per Windower process.
--- Safe to call multiple times.
function DualBoxSyncIPC.init_listener()
    if not windower or not windower.register_event then return end

    if windower._sync_ipc_event_id then
        pcall(windower.unregister_event, windower._sync_ipc_event_id)
        windower._sync_ipc_event_id = nil
    end

    windower._sync_ipc_event_id =
        windower.register_event('ipc message', DualBoxSyncIPC._on_ipc_message)
end

return DualBoxSyncIPC

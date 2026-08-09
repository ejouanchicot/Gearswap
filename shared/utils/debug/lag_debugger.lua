---============================================================================
--- Lag Debugger - Diagnostic Event Journal for FPS/Lag Investigation
---============================================================================
--- Records what the client was doing when it stuttered: movement, job changes,
--- gs c update calls, the actions you take, every first-time module load with
--- its cost, and any frame long enough to be felt.
---
--- Export the journal to a file, share with developer for analysis.
---
--- Usage:
---   //gs c lagdebug          - Toggle recording ON/OFF
---   //gs c lagdebug export   - Write journal to data/debug_lag.txt
---   //gs c lagdebug reset    - Clear the journal
---   //gs c lagdebug status   - Show recording status
---
--- @file    shared/utils/debug/lag_debugger.lua
--- @author  Tetsouo
--- @version 1.2 - Module-load, stall and action probes
--- @date    Created: 2026-03-03
---============================================================================

local LagDebugger = {}

---============================================================================
--- STATE (persisted in windower table - survives gs reload)
---============================================================================
-- windower is a C++ object that persists across all GearSwap reloads.
-- Module-local variables are destroyed on each gs reload (package.loaded cleared).
-- Using windower._lagdebug guarantees the journal survives job changes.

windower._lagdebug = windower._lagdebug or {
    enabled       = false,
    log           = {},
    t0            = 0,
    update_count  = 0,
    last_update_t = 0,
}

local S = windower._lagdebug  -- Shorthand alias

local _max = 2000  -- Ring buffer max (enough for ~3min at 80ms intervals)

-- A frame longer than this is what a player calls a freeze. 40ms is about
-- 2.5 frames at 60fps: short enough to catch a hitch, long enough that normal
-- frame jitter does not fill the journal.
local STALL_MS = 40

-- Reading a cached module is free; only a real load is worth a line.
local MODULE_MS = 1.0

-- Deliberately module-local, NOT in the windower table. A gs reload builds a
-- fresh Lua state with a fresh `require`, so a flag that survived the reload
-- would claim the probe is installed when it no longer is.
local require_wrapped = false
local original_require = nil

---============================================================================
--- PROBES
---============================================================================

--- Time every module GearSwap loads for the first time.
---
--- This is what answers "is it loading the whole database?" - a lazy require
--- that costs real milliseconds shows up here with its path, at the moment it
--- happens, so it can be lined up against the action that triggered it.
local function install_module_probe()
    if require_wrapped or type(_G.require) ~= 'function' then
        return
    end
    original_require = _G.require
    require_wrapped = true

    -- Everything is timed, and only what costs anything is written down.
    -- Skipping already-cached paths would be cheaper, but `package` is nil in
    -- the GearSwap sandbox (like collectgarbage and loadfile), and a cached
    -- require returns far under the threshold anyway - so it filters itself.
    _G.require = function(path, ...)
        local t0 = os.clock()
        local a, b, c = original_require(path, ...)
        local ms = (os.clock() - t0) * 1000
        if ms >= MODULE_MS then
            S.last_module = path
            LagDebugger._raw('MODULE_LOAD', { path = path, ms = string.format('%.1f', ms) })
        end
        return a, b, c
    end
end

--- Put `require` back the way it was.
local function remove_module_probe()
    if require_wrapped and original_require then
        _G.require = original_require
    end
    require_wrapped = false
    original_require = nil
end

--- Report any frame long enough to be felt.
---
--- The point of measuring here rather than around suspected code is that it
--- makes no assumption about the cause: whatever stalls the client shows up,
--- including whatever nobody thought to instrument.
local function install_stall_probe()
    -- The id lives in the windower table because GearSwap does NOT unregister
    -- events registered from data files on reload. Without this, every reload
    -- would leave another live listener behind - which is exactly how the lag
    -- this tool exists to find got introduced in the first place.
    if S.stall_event_id then
        windower.unregister_event(S.stall_event_id)
        S.stall_event_id = nil
    end

    S.last_frame = os.clock()
    S.frames = S.frames or { n = 0, total = 0, max = 0, buckets = {} }

    S.stall_event_id = windower.register_event('prerender', function()
        if not S.enabled then return end
        local now = os.clock()
        local gap_ms = (now - (S.last_frame or now)) * 1000
        S.last_frame = now

        -- Every frame is counted, not just the slow ones. Without the baseline
        -- a "40ms stall" means nothing: it is a freeze on a client running at
        -- 60fps and an ordinary frame on one running at 22.
        local f = S.frames
        f.n = f.n + 1
        f.total = f.total + gap_ms
        if gap_ms > f.max then f.max = gap_ms end
        local bucket = math.floor(gap_ms / 10) * 10
        if bucket > 200 then bucket = 200 end
        f.buckets[bucket] = (f.buckets[bucket] or 0) + 1

        if gap_ms >= STALL_MS then
            LagDebugger._raw('STALL', {
                gap_ms      = math.floor(gap_ms),
                last_action = S.last_action or '-',
                last_module = S.last_module or '-',
            })
        end
    end)
end

--- Record what the player just did, so a stall has something to be blamed on.
local function install_action_probe()
    if S.action_event_id then
        windower.unregister_event(S.action_event_id)
        S.action_event_id = nil
    end

    local CATEGORY = {
        [1] = 'melee', [2] = 'ranged', [3] = 'weaponskill', [4] = 'magic',
        [5] = 'item',  [6] = 'job_ability', [7] = 'ws_start', [8] = 'magic_start',
        [9] = 'item_start', [12] = 'ranged_start', [13] = 'pet_ability',
    }

    S.action_event_id = windower.register_event('action', function(act)
        if not S.enabled or not act then return end
        -- Filter on the actor before touching anything else: this fires for
        -- every action in the zone, and a party in a busy camp is a lot.
        if not (player and act.actor_id == player.id) then return end

        local label = CATEGORY[act.category] or ('category_' .. tostring(act.category))
        S.last_action = label
        LagDebugger._raw('ACTION', { kind = label, cat = act.category })
    end)
end

--- Tear both event probes down.
local function remove_event_probes()
    if S.stall_event_id then
        windower.unregister_event(S.stall_event_id)
        S.stall_event_id = nil
    end
    if S.action_event_id then
        windower.unregister_event(S.action_event_id)
        S.action_event_id = nil
    end
end

---============================================================================
--- CORE API
---============================================================================

--- Start recording
function LagDebugger.start()
    S.enabled       = true
    S.log           = {}
    S.t0            = os.clock()
    S.update_count  = 0
    S.last_update_t = 0

    -- Snapshot: current state at start
    local job      = player and player.main_job or 'UNK'
    local sub      = player and player.sub_job  or 'UNK'
    local moving_val = (state and state.Moving and state.Moving.value) or 'nil'
    local am_seq   = tostring(_G._automove_sequence or 0)
    local am_run   = tostring(_G.AUTOMOVE_RUNNING or false)

    S.last_action = nil
    S.last_module = nil
    S.frames = { n = 0, total = 0, max = 0, buckets = {} }

    install_module_probe()
    install_stall_probe()
    install_action_probe()

    LagDebugger._raw('SESSION_START', {
        job    = job,
        sub    = sub,
        moving = moving_val,
        am_seq = am_seq,
        am_run = am_run,
    })
    add_to_chat(207, '[LagDebug] Recording ON - use a JA, a WS and a spell, then //gs c lagdebug export')
end

--- Stop recording
function LagDebugger.stop()
    LagDebugger._raw('SESSION_END', {total_updates = S.update_count})
    S.enabled = false
    remove_module_probe()
    remove_event_probes()
    add_to_chat(207, string.format('[LagDebug] Recording OFF - %d events, %d gs_c_update', #S.log, S.update_count))
end

--- Toggle recording
function LagDebugger.toggle()
    if S.enabled then
        LagDebugger.stop()
    else
        LagDebugger.start()
    end
end

--- Clear journal
function LagDebugger.reset()
    S.log          = {}
    S.update_count = 0
    S.t0           = os.clock()
    add_to_chat(207, '[LagDebug] Journal cleared')
end

--- Check if recording
function LagDebugger.is_enabled()
    return S.enabled
end

--- Show status
function LagDebugger.status()
    local state_str = S.enabled and 'ON' or 'OFF'
    add_to_chat(207, string.format('[LagDebug] Status: %s | Events: %d | gs_c_update count: %d',
        state_str, #S.log, S.update_count))
end

---============================================================================
--- INTERNAL LOG FUNCTION
---============================================================================

--- Internal: log one event (bypasses enabled check for SESSION_START/END)
function LagDebugger._raw(event_type, data)
    local t_ms = math.floor((os.clock() - S.t0) * 1000)
    local entry = { t = t_ms, type = event_type }
    if data then
        for k, v in pairs(data) do
            entry[k] = v
        end
    end
    table.insert(S.log, entry)
    -- Ring buffer: drop oldest if over max
    if #S.log > _max then
        table.remove(S.log, 1)
    end
end

--- Log an event (only when recording)
function LagDebugger.log(event_type, data)
    if not S.enabled then return end
    LagDebugger._raw(event_type, data)
end

---============================================================================
--- SPECIALIZED LOG HELPERS (called from instrumented modules)
---============================================================================

--- Called by AutoMove just before sending gs c update
function LagDebugger.on_automove_update(reason, dist, moving_state)
    if not S.enabled then return end
    S.update_count = S.update_count + 1
    local now = os.clock()
    local since_last = (S.last_update_t == 0) and 0 or (now - S.last_update_t)
    S.last_update_t = now
    LagDebugger._raw('GS_UPDATE_SENT', {
        src           = 'automove',
        reason        = tostring(reason),
        dist          = string.format('%.3f', dist or 0),
        moving        = tostring(moving_state),
        since_last_ms = math.floor(since_last * 1000),
        count         = S.update_count,
    })
end

--- Called by AutoMove.start()
function LagDebugger.on_automove_start(seq)
    if not S.enabled then return end
    LagDebugger._raw('AUTOMOVE_START', {seq = seq})
end

--- Called by AutoMove.stop()
function LagDebugger.on_automove_stop(seq)
    if not S.enabled then return end
    LagDebugger._raw('AUTOMOVE_STOP', {seq = seq})
end

--- Called by job_change_manager on_job_change
function LagDebugger.on_job_change(main_job, sub_job)
    if not S.enabled then return end
    LagDebugger._raw('JOB_CHANGE', {job = main_job, sub = sub_job})
end

--- Called by cleanup_all_systems
function LagDebugger.on_cleanup()
    if not S.enabled then return end
    local am_seq = tostring(_G._automove_sequence or 0)
    local am_run = tostring(_G.AUTOMOVE_RUNNING or false)
    LagDebugger._raw('CLEANUP_SYSTEMS', {am_seq = am_seq, am_run = am_run})
end

--- Called by GearSwap gs reload schedule (before windower.send_command('gs reload'))
function LagDebugger.on_gs_reload(delay)
    if not S.enabled then return end
    LagDebugger._raw('GS_RELOAD_SCHEDULED', {delay_s = string.format('%.1f', delay or 0)})
end

--- Called by INIT_SYSTEMS.lua at the end of each reload (marks reload complete)
function LagDebugger.on_reload_complete(job, sub, am_seq)
    if not S.enabled then return end
    LagDebugger._raw('GS_RELOAD_COMPLETE', {job = job, sub = sub, am_seq = tostring(am_seq or 0)})
end

--- Called by BST prerender when it fires and sends an update
function LagDebugger.on_prerender_check(pet_eng_val, prev_pet_eng, sent_update)
    if not S.enabled then return end
    if sent_update then
        S.update_count = S.update_count + 1
    end
    LagDebugger._raw('BST_PRERENDER', {
        pet_eng  = tostring(pet_eng_val),
        prev_eng = tostring(prev_pet_eng),
        sent_upd = tostring(sent_update),
    })
end

--- Called by job_update() (fires on every gs c update received by GearSwap)
function LagDebugger.on_job_update()
    if not S.enabled then return end
    local moving_val = (state and state.Moving and state.Moving.value) or 'nil'
    LagDebugger._raw('JOB_UPDATE', {moving = moving_val})
end

---============================================================================
--- EXPORT TO FILE
---============================================================================

--- Export journal to data/debug_lag.txt
function LagDebugger.export()
    if #S.log == 0 then
        add_to_chat(207, '[LagDebug] Nothing to export - run //gs c lagdebug first')
        return false
    end

    local path = windower.addon_path .. 'data/debug_lag.txt'
    local lines = {}

    -- Header
    table.insert(lines, '================================================================')
    table.insert(lines, '  LAG DEBUG JOURNAL - GearSwap Tetsouo')
    table.insert(lines, '================================================================')
    table.insert(lines, 'Date    : ' .. os.date('%Y-%m-%d %H:%M:%S'))
    table.insert(lines, 'Events  : ' .. #S.log)
    table.insert(lines, 'Updates : ' .. S.update_count .. ' gs c update sent during recording')

    -- The baseline. A stall threshold is only meaningful next to it.
    local f = S.frames
    if f and f.n > 0 then
        local avg = f.total / f.n
        table.insert(lines, '')
        table.insert(lines, 'FRAME TIME (this is the yardstick - read it before the stalls):')
        table.insert(lines, string.format('  frames  : %d over %.1fs', f.n, f.total / 1000))
        table.insert(lines, string.format('  average : %.1f ms  (%.0f fps)', avg, 1000 / avg))
        table.insert(lines, string.format('  worst   : %.0f ms', f.max))
        table.insert(lines, string.format('  a %dms frame is %.1fx your average', STALL_MS, STALL_MS / avg))
        table.insert(lines, '  distribution:')

        local keys = {}
        for b in pairs(f.buckets) do keys[#keys + 1] = b end
        table.sort(keys)
        for _, b in ipairs(keys) do
            local count = f.buckets[b]
            local pct = count / f.n * 100
            local bar = string.rep('#', math.max(1, math.floor(pct / 2)))
            table.insert(lines, string.format('    %3d-%3dms  %5d  %5.1f%%  %s',
                b, b + 9, count, pct, bar))
        end
    end

    table.insert(lines, '================================================================')
    table.insert(lines, '')
    table.insert(lines, 'LEGEND:')
    table.insert(lines, '  SESSION_START      : Recording started (state snapshot)')
    table.insert(lines, '  AUTOMOVE_START     : AutoMove.start() called')
    table.insert(lines, '  AUTOMOVE_STOP      : AutoMove.stop() called')
    table.insert(lines, '  GS_UPDATE_SENT     : gs c update sent by AutoMove')
    table.insert(lines, '  JOB_UPDATE         : gs c update received by GearSwap (job_update)')
    table.insert(lines, '  JOB_CHANGE         : job_sub_job_change detected')
    table.insert(lines, '  CLEANUP_SYSTEMS    : cleanup_all_systems() called')
    table.insert(lines, '  GS_RELOAD_SCHED    : gs reload scheduled (debounce)')
    table.insert(lines, '  GS_RELOAD_COMPLETE : GearSwap finished reloading (INIT_SYSTEMS)')
    table.insert(lines, '  BST_PRERENDER      : prerender BST (pet monitoring)')
    table.insert(lines, '  ACTION             : you used a JA / WS / spell (kind=what)')
    table.insert(lines, '  MODULE_LOAD        : a module was loaded for the FIRST time, with its cost')
    table.insert(lines, '                       -> this is where a database load would show up')
    table.insert(lines, '  STALL              : a frame took >= ' .. STALL_MS .. 'ms - a visible freeze')
    table.insert(lines, '                       gap_ms = how long, last_action / last_module = context')
    table.insert(lines, '  SESSION_END        : Recording stopped')
    table.insert(lines, '')
    table.insert(lines, 'HOW TO READ IT:')
    table.insert(lines, '  A STALL right after a MODULE_LOAD with a matching cost means the load')
    table.insert(lines, '  caused it. A STALL with no MODULE_LOAD near it means the freeze is')
    table.insert(lines, '  somewhere else entirely, and the databases are not to blame.')
    table.insert(lines, '')
    table.insert(lines, '----------------------------------------------------------------')
    table.insert(lines, string.format('%-12s %-25s %s', '[TIME(ms)]', '[EVENT]', '[DATA]'))
    table.insert(lines, '----------------------------------------------------------------')

    -- Events
    for _, e in ipairs(S.log) do
        local parts = {}
        for k, v in pairs(e) do
            if k ~= 't' and k ~= 'type' then
                table.insert(parts, k .. '=' .. tostring(v))
            end
        end
        table.sort(parts)
        local data_str = (#parts > 0) and (' | ' .. table.concat(parts, '  ')) or ''
        table.insert(lines, string.format('[%8dms] %-25s%s', e.t, e.type, data_str))
    end

    table.insert(lines, '')
    table.insert(lines, '================================================================')
    table.insert(lines, 'END OF LOG')

    -- Write file
    local f = io.open(path, 'w')
    if f then
        f:write(table.concat(lines, '\n'))
        f:close()
        add_to_chat(207, '[LagDebug] Export OK: ' .. path)
        add_to_chat(207, '[LagDebug] Share this file for analysis.')
        return true
    else
        add_to_chat(207, '[LagDebug] ERROR: could not write to ' .. path)
        return false
    end
end

---============================================================================
--- MODULE EXPORT (global + module)
---============================================================================

-- Recording survives a gs reload because the journal lives in the windower
-- table - but the probes do not: `require` is fresh in the new Lua state, and
-- the event ids point at listeners this state never registered. Reinstall them
-- so a session that spans a job change keeps recording instead of going quiet
-- while still reporting itself as ON.
if S.enabled then
    install_module_probe()
    install_stall_probe()
    install_action_probe()
    LagDebugger._raw('PROBES_REARMED', {
        job = player and player.main_job or 'UNK',
        sub = player and player.sub_job or 'UNK',
    })
end

_G.LagDebugger = LagDebugger
return LagDebugger

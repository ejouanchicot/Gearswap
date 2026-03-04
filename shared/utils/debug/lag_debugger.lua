---============================================================================
--- Lag Debugger - Diagnostic Event Journal for FPS/Lag Investigation
---============================================================================
--- Records all events related to movement, job changes, and gs c update calls.
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
--- @version 1.1 - FIX: Persist state in windower table (survives gs reload)
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

    LagDebugger._raw('SESSION_START', {
        job    = job,
        sub    = sub,
        moving = moving_val,
        am_seq = am_seq,
        am_run = am_run,
    })
    add_to_chat(207, '[LagDebug] Recording ON - Change job + move around, then //gs c lagdebug export')
end

--- Stop recording
function LagDebugger.stop()
    LagDebugger._raw('SESSION_END', {total_updates = S.update_count})
    S.enabled = false
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
    table.insert(lines, '  SESSION_END        : Recording stopped')
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

_G.LagDebugger = LagDebugger
return LagDebugger

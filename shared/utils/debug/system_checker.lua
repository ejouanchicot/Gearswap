-- SystemChecker: runtime health check for all GearSwap systems, outputs a % score.
-- //gs c syscheck [export]

local SystemChecker = {}

-- RESULT BUILDERS

local function ok(name, detail)
    return {status = 'OK', name = name, detail = detail, score = 1}
end

local function warn(name, detail)
    return {status = 'WARN', name = name, detail = detail, score = 0.5}
end

local function fail(name, detail)
    return {status = 'FAIL', name = name, detail = detail, score = 0}
end

-- INDIVIDUAL SYSTEM CHECKS

local function check_automove()
    local seq   = windower._automove_seq or 0
    local run   = _G.AUTOMOVE_RUNNING
    local disab = _G.DISABLE_AUTOMOVE

    if disab then
        return ok('AutoMove', 'disabled by job (intentional)')
    end
    if run == true then
        return ok('AutoMove', string.format('running | seq=%d', seq))
    end
    if run == false then
        return warn('AutoMove', string.format('stopped | seq=%d (normal during job change)', seq))
    end
    return fail('AutoMove', 'AUTOMOVE_RUNNING=nil - not started (INIT_SYSTEMS error?)')
end

local function check_watchdog()
    if _G.MidcastWatchdog then
        local ok_stat = 'loaded'
        if _G.MidcastWatchdog.get_stats then
            local s = _G.MidcastWatchdog.get_stats()
            if s and s.enabled ~= nil then
                ok_stat = s.enabled and 'active' or 'loaded (disabled)'
            end
        end
        return ok('Watchdog', ok_stat)
    end
    -- Watchdog loads after 2s delay — may just not be ready yet
    return warn('Watchdog', 'not loaded yet (normal if < 2s since reload)')
end

local function check_warp()
    -- Quick check via windower persistent flag (avoids loading the module)
    if windower._warp_init_done then
        return ok('WarpInit', 'initialized (windower persistent)')
    end

    local success, WarpInit = pcall(require, 'shared/utils/warp/warp_init')
    if success and WarpInit then
        if WarpInit.is_initialized and WarpInit.is_initialized() then
            return ok('WarpInit', 'initialized, precast hook active')
        else
            return warn('WarpInit', 'not yet initialized - run after 0.5s delay or check chat for errors')
        end
    end
    return fail('WarpInit', 'module failed to load')
end

local function check_hook_chain()
    local reloads = windower._gs_reload_count or 0
    local wraps   = windower._hook_wraps or {ability = 0, ws = 0, midcast = 0}
    local a, w, m = wraps.ability or 0, wraps.ws or 0, wraps.midcast or 0

    if reloads == 0 then
        return warn('Hook Chain', 'no reload data yet')
    end

    -- Ratio: wraps / reloads should be exactly 1.0 (1 wrap per reload)
    local ra = a / reloads
    local rw = w / reloads
    local rm = m / reloads

    local detail = string.format(
        'reloads=%d | ability=%.1fx  ws=%.1fx  midcast=%.1fx',
        reloads, ra, rw, rm)

    -- Accumulation = ratio > 1.0 (wrapped more than once per reload)
    if ra > 1.1 or rw > 1.1 or rm > 1.1 then
        return fail('Hook Chain', 'ACCUMULATION DETECTED! ' .. detail)
    end
    if ra < 0.5 or rw < 0.5 or rm < 0.5 then
        return warn('Hook Chain', 'hooks missing on some reloads - ' .. detail)
    end
    return ok('Hook Chain', detail)
end

local function check_state_moving()
    if state and state.Moving then
        return ok('State.Moving',
            string.format('initialized | value=%s', tostring(state.Moving.value)))
    end
    return warn('State.Moving', 'nil - AutoMove not yet started (normal < 0.5s after reload)')
end

local function check_jobchange_manager()
    local S = _G.JobChangeManagerSTATE
    if not S then
        return fail('JobChangeMgr', 'STATE not initialized')
    end
    local job = string.format('%s/%s', tostring(S.current_main_job), tostring(S.current_sub_job))
    local detail = string.format('job=%s | counter=%d', job, S.debounce_counter or 0)
    return ok('JobChangeMgr', detail)
end

local function check_ui()
    local U = _G.ui_manager_state
    if U then
        -- Fallback to player table when UI state not yet updated (first load)
        local main = U.current_job    or (player and player.main_job) or 'nil'
        local sub  = U.current_subjob or (player and player.sub_job)  or 'nil'
        local src  = (U.current_job == nil) and ' (from player)' or ''
        local detail = string.format('loaded | job=%s/%s%s | failures=%d',
            main, sub, src, U.consecutive_failures or 0)
        if (U.consecutive_failures or 0) > 3 then
            return warn('UI Manager', 'too many failures - ' .. detail)
        end
        return ok('UI Manager', detail)
    end
    if _G.KeybindUI then
        return ok('UI Manager', 'loaded (state not initialized yet)')
    end
    return warn('UI Manager', 'not loaded (normal if UI not required by this job)')
end

local function check_lagdebugger()
    local ld = _G.LagDebugger
    if not ld then
        return fail('LagDebugger', 'not loaded (INIT_SYSTEMS error?)')
    end
    local state_str = ld.is_enabled() and 'RECORDING' or 'standby'
    local S = windower._lagdebug
    local events = (S and S.log) and #S.log or 0
    return ok('LagDebugger', string.format('%s | %d events in buffer', state_str, events))
end

local function check_session()
    local reloads = windower._gs_reload_count or 0
    local seq     = windower._automove_seq    or 0
    local job     = player and string.format('%s/%s', player.main_job, player.sub_job) or 'UNK'
    return {
        reloads = reloads,
        seq     = seq,
        job     = job,
    }
end

-- MAIN CHECK RUNNER

function SystemChecker.run()
    local session = check_session()

    local results = {
        check_automove(),
        check_watchdog(),
        check_warp(),
        check_hook_chain(),
        check_state_moving(),
        check_jobchange_manager(),
        check_ui(),
        check_lagdebugger(),
    }

    -- Calculate score
    local total = #results
    local score_sum = 0
    for _, r in ipairs(results) do
        score_sum = score_sum + r.score
    end
    local pct = math.floor((score_sum / total) * 100)

    return {
        session = session,
        results = results,
        score   = pct,
        total   = total,
        passed  = score_sum,
    }
end

-- DISPLAY (CHAT)

local STATUS_ICON = {OK = '[  OK  ]', WARN = '[ WARN ]', FAIL = '[ FAIL ]'}
local STATUS_COLOR = {OK = 204, WARN = 167, FAIL = 167}  -- green-ish, orange, orange

function SystemChecker.display(report)
    add_to_chat(207, '====== SYSTEM HEALTH CHECK ======')
    add_to_chat(207, string.format('Job: %s | Reloads: %d | AutoMove seq: %d',
        report.session.job, report.session.reloads, report.session.seq))
    add_to_chat(207, '---------------------------------')

    for _, r in ipairs(report.results) do
        local icon  = STATUS_ICON[r.status]  or '[  ??  ]'
        local color = STATUS_COLOR[r.status] or 207
        add_to_chat(color, string.format('%s %-14s %s', icon, r.name, r.detail))
    end

    add_to_chat(207, '---------------------------------')

    -- Score color
    local score_color = report.score >= 90 and 204 or (report.score >= 70 and 167 or 167)
    add_to_chat(score_color, string.format('Score: %d%%  (%d/%d systems OK)',
        report.score, report.passed, report.total))
    add_to_chat(207, '=================================')
end

-- EXPORT (FILE)

function SystemChecker.export(report)
    local path = windower.addon_path .. 'data/syscheck.txt'
    local lines = {}

    table.insert(lines, '================================================================')
    table.insert(lines, '  SYSTEM HEALTH CHECK - GearSwap Tetsouo')
    table.insert(lines, '================================================================')
    table.insert(lines, 'Date    : ' .. os.date('%Y-%m-%d %H:%M:%S'))
    table.insert(lines, string.format('Job     : %s', report.session.job))
    table.insert(lines, string.format('Reloads : %d  (since lua load gearswap)', report.session.reloads))
    table.insert(lines, string.format('AM seq  : %d  (AutoMove sequence counter)', report.session.seq))
    table.insert(lines, '================================================================')
    table.insert(lines, '')
    table.insert(lines, string.format('%-10s %-14s %s', '[STATUS]', '[SYSTEM]', '[DETAIL]'))
    table.insert(lines, '----------------------------------------------------------------')

    for _, r in ipairs(report.results) do
        table.insert(lines, string.format('%-10s %-14s %s', r.status, r.name, r.detail))
    end

    table.insert(lines, '')
    table.insert(lines, '----------------------------------------------------------------')
    table.insert(lines, string.format('Score: %d%%  (%d/%d systems operational)',
        report.score, report.passed, report.total))
    table.insert(lines, '')
    table.insert(lines, 'GUIDE:')
    table.insert(lines, '  Hook Chain ratio > 1.0 -> hook accumulation bug (wraps > reloads)')
    table.insert(lines, '  AutoMove seq high      -> many job changes since last lua load')
    table.insert(lines, '  Watchdog WARN          -> normal if checked < 2s after reload')
    table.insert(lines, '  WarpInit WARN          -> normal if checked < 0.5s after reload')
    table.insert(lines, '================================================================')
    table.insert(lines, 'END')

    local f = io.open(path, 'w')
    if f then
        f:write(table.concat(lines, '\n'))
        f:close()
        add_to_chat(207, '[SysCheck] Export OK: ' .. path)
        return true
    else
        add_to_chat(207, '[SysCheck] ERROR: could not write to ' .. path)
        return false
    end
end

-- MODULE EXPORT

return SystemChecker

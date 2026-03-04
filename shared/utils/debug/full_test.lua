-- FullTest: comprehensive in-game health check (systems + modules + hooks + sets), no player action needed.
-- //gs c fulltest [export]  (alias: ft)

local FullTest = {}

-- RESULT BUILDERS

local function ok(name, detail)
    return {status = 'OK',   name = name, detail = detail or '', score = 1}
end

local function warn(name, detail)
    return {status = 'WARN', name = name, detail = detail or '', score = 0.5}
end

local function fail(name, detail)
    return {status = 'FAIL', name = name, detail = detail or '', score = 0}
end

-- SECTION A: RUNTIME SYSTEMS (delegates to SystemChecker)

local function run_system_checks()
    local ok_load, SystemChecker = pcall(require, 'shared/utils/debug/system_checker')
    if not ok_load or not SystemChecker then
        return {fail('SystemChecker', 'failed to load system_checker module')}
    end
    -- Returns the same {status, name, detail, score} table format
    return SystemChecker.run().results
end

-- SECTION B: MODULE LOADING (9 mandatory systems + key utilities)

-- 9 mandatory systems (CLAUDE.md) + essential utilities
-- Listed in declaration order: mandatory first, then utilities
local CRITICAL_MODULES = {
    -- 9 Mandatory Systems
    {name = 'CooldownChecker',   path = 'shared/utils/precast/cooldown_checker'},
    {name = 'MessageFormatter',  path = 'shared/utils/messages/message_formatter'},
    {name = 'MidcastManager',    path = 'shared/utils/midcast/midcast_manager'},
    {name = 'AbilityHelper',     path = 'shared/utils/precast/ability_helper'},
    {name = 'PrecastGuard',      path = 'shared/utils/debuff/precast_guard'},
    {name = 'WSPrecastHandler',  path = 'shared/utils/precast/ws_precast_handler'},
    {name = 'LockstyleManager',  path = 'shared/utils/lockstyle/lockstyle_manager'},
    {name = 'MacrobookManager',  path = 'shared/utils/macrobook/macrobook_manager'},
    {name = 'JobChangeManager',  path = 'shared/utils/core/job_change_manager'},
    -- Core utilities
    {name = 'CommonCommands',    path = 'shared/utils/core/COMMON_COMMANDS'},
    {name = 'MessageEngine',     path = 'shared/utils/messages/core/message_engine'},
    {name = 'MessageColors',     path = 'shared/utils/messages/message_colors'},
    {name = 'WarpInit',          path = 'shared/utils/warp/warp_init'},
    {name = 'MidcastWatchdog',   path = 'shared/utils/core/midcast_watchdog'},
}

local function run_module_checks()
    local results = {}
    for _, m in ipairs(CRITICAL_MODULES) do
        local load_ok, result = pcall(require, m.path)
        if load_ok and result then
            table.insert(results, ok(m.name, 'loaded'))
        else
            -- Trim error to first line to keep display readable
            local err = type(result) == 'string'
                and (result:match('([^\n]+)') or result)
                or  tostring(result)
            table.insert(results, fail(m.name, err))
        end
    end
    return results
end

-- SECTION C: _G HOOK EXPORTS

-- Hooks that MUST be exported for GearSwap to work correctly
local REQUIRED_HOOKS = {'job_update', 'job_precast', 'job_self_command'}

local function run_hook_checks()
    local results = {}

    -- Required hooks: FAIL if missing
    for _, name in ipairs(REQUIRED_HOOKS) do
        if type(_G[name]) == 'function' then
            table.insert(results, ok('_G.' .. name, 'exported'))
        else
            table.insert(results, fail('_G.' .. name, 'MISSING - GearSwap hook not exported'))
        end
    end

    -- Midcast: need at least one of job_midcast / job_post_midcast
    if type(_G.job_midcast) == 'function' or type(_G.job_post_midcast) == 'function' then
        local which = type(_G.job_midcast) == 'function' and 'job_midcast' or 'job_post_midcast'
        table.insert(results, ok('_G.midcast', 'exported (' .. which .. ')'))
    else
        table.insert(results, warn('_G.midcast', 'neither job_midcast nor job_post_midcast found'))
    end

    -- Optional hooks: count how many are present (no individual FAIL)
    local optional = {'job_aftercast', 'customize_idle_set', 'customize_melee_set', 'job_state_change'}
    local found = 0
    for _, name in ipairs(optional) do
        if type(_G[name]) == 'function' then found = found + 1 end
    end
    local detail = string.format('%d/%d present (aftercast, idle, engaged, state_change)', found, #optional)
    if found == 0 then
        table.insert(results, warn('_G.optional', detail))
    else
        table.insert(results, ok('_G.optional', detail))
    end

    return results
end

-- SECTION D: SETS STRUCTURE

local function check_sets_entry(name, tbl)
    if type(tbl) ~= 'table' then
        return fail('sets.' .. name, 'nil or not a table')
    end
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    if count == 0 then
        return warn('sets.' .. name, 'empty (no sets defined yet)')
    end
    return ok('sets.' .. name, string.format('%d entries', count))
end

local function run_sets_checks()
    if type(sets) ~= 'table' then
        return {fail('sets', 'global sets table not initialized')}
    end

    local results = {}
    table.insert(results, check_sets_entry('precast',  sets.precast))
    table.insert(results, check_sets_entry('midcast',  sets.midcast))
    table.insert(results, check_sets_entry('idle',     sets.idle))
    table.insert(results, check_sets_entry('engaged',  sets.engaged))

    -- Bonus: check sets.precast.WS exists
    if type(sets.precast) == 'table' then
        if type(sets.precast.WS) == 'table' then
            local ws_count = 0
            for _ in pairs(sets.precast.WS) do ws_count = ws_count + 1 end
            table.insert(results, ok('sets.precast.WS', string.format('%d WS sets', ws_count)))
        else
            table.insert(results, warn('sets.precast.WS', 'not defined (no WS sets for this job?)'))
        end
    end

    return results
end

-- MAIN RUNNER

function FullTest.run()
    local job     = player and string.format('%s/%s', player.main_job, player.sub_job) or 'UNK'
    local reloads = windower._gs_reload_count or 0

    local sections = {
        {title = 'A - RUNTIME SYSTEMS',  results = run_system_checks()},
        {title = 'B - MODULE LOADING',   results = run_module_checks()},
        {title = 'C - _G HOOK EXPORTS',  results = run_hook_checks()},
        {title = 'D - SETS STRUCTURE',   results = run_sets_checks()},
    }

    -- Aggregate score across all sections
    local total_checks = 0
    local total_score  = 0
    for _, section in ipairs(sections) do
        section.ok   = 0
        section.warn = 0
        section.fail = 0
        for _, r in ipairs(section.results) do
            total_checks = total_checks + 1
            total_score  = total_score  + r.score
            if     r.status == 'OK'   then section.ok   = section.ok   + 1
            elseif r.status == 'WARN' then section.warn = section.warn + 1
            else                           section.fail = section.fail + 1
            end
        end
    end

    local pct = total_checks > 0 and math.floor((total_score / total_checks) * 100) or 0

    return {
        job      = job,
        reloads  = reloads,
        sections = sections,
        score    = pct,
        total    = total_checks,
        passed   = total_score,
    }
end

-- DISPLAY (CHAT)

local STATUS_ICON  = {OK = '[  OK  ]', WARN = '[ WARN ]', FAIL = '[ FAIL ]'}
local STATUS_COLOR = {OK = 204,        WARN = 50,         FAIL = 167}

function FullTest.display(report)
    add_to_chat(207, '========== FULL TEST REPORT ==========')
    add_to_chat(207, string.format('Job: %s | Reloads: %d', report.job, report.reloads))
    add_to_chat(207, '--------------------------------------')

    for _, section in ipairs(report.sections) do
        local summary = string.format('OK:%d WARN:%d FAIL:%d',
            section.ok, section.warn, section.fail)
        add_to_chat(207, string.format('[ %s ] %s', summary, section.title))

        for _, r in ipairs(section.results) do
            local icon  = STATUS_ICON[r.status]  or '[  ??  ]'
            local color = STATUS_COLOR[r.status] or 207
            add_to_chat(color, string.format('  %s %-22s %s', icon, r.name, r.detail))
        end
    end

    add_to_chat(207, '--------------------------------------')

    local score_color
    if     report.score >= 90 then score_color = 204
    elseif report.score >= 70 then score_color = 50
    else                           score_color = 167
    end

    add_to_chat(score_color, string.format('SCORE: %d%%  (%d/%d checks passed)',
        report.score, report.passed, report.total))
    add_to_chat(207, '======================================')
    add_to_chat(207, 'Tip: //gs c fulltest export  -> save to data/fulltest_report.txt')
end

-- EXPORT (FILE)

function FullTest.export(report)
    local path = windower.addon_path .. 'data/fulltest_report.txt'
    local lines = {}

    table.insert(lines, '================================================================')
    table.insert(lines, '  FULL TEST REPORT - GearSwap Tetsouo')
    table.insert(lines, '================================================================')
    table.insert(lines, 'Date    : ' .. os.date('%Y-%m-%d %H:%M:%S'))
    table.insert(lines, string.format('Job     : %s', report.job))
    table.insert(lines, string.format('Reloads : %d  (since //lua reload gearswap)', report.reloads))
    table.insert(lines, string.format('Score   : %d%%  (%d/%d checks passed)',
        report.score, report.passed, report.total))
    table.insert(lines, '================================================================')
    table.insert(lines, '')

    for _, section in ipairs(report.sections) do
        table.insert(lines, string.format('=== %s  [OK:%d WARN:%d FAIL:%d] ===',
            section.title, section.ok, section.warn, section.fail))
        table.insert(lines, string.format('%-10s %-22s %s', '[STATUS]', '[CHECK]', '[DETAIL]'))
        table.insert(lines, '----------------------------------------------------------------')
        for _, r in ipairs(section.results) do
            table.insert(lines, string.format('%-10s %-22s %s', r.status, r.name, r.detail))
        end
        table.insert(lines, '')
    end

    table.insert(lines, '================================================================')
    table.insert(lines, 'GUIDE:')
    table.insert(lines, '  A FAIL  -> module crash or system not initialized (check chat errors)')
    table.insert(lines, '  B FAIL  -> require() failed: missing file or syntax error in module')
    table.insert(lines, '  C FAIL  -> _G export missing: check job file includes the right module')
    table.insert(lines, '  D WARN  -> sets empty: intentional (not built yet) or get_sets() error')
    table.insert(lines, '  D FAIL  -> sets nil: get_sets() did not run or threw an error')
    table.insert(lines, '')
    table.insert(lines, '  Cannot test without player action:')
    table.insert(lines, '    - Actual spell precast/midcast/aftercast gear flow')
    table.insert(lines, '    - Equipment physically equipping on character')
    table.insert(lines, '    - JA cooldown timers and AutoMove during real movement')
    table.insert(lines, '================================================================')
    table.insert(lines, 'END')

    local f = io.open(path, 'w')
    if f then
        f:write(table.concat(lines, '\n'))
        f:close()
        add_to_chat(207, '[FullTest] Export OK -> ' .. path)
        return true
    else
        add_to_chat(207, '[FullTest] ERROR: could not write to ' .. path)
        return false
    end
end

-- MODULE EXPORT

return FullTest

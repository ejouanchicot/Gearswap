---  ═══════════════════════════════════════════════════════════════════════════
---   DebugCommands - Diagnostic / debug-toggle command handlers
---  ═══════════════════════════════════════════════════════════════════════════
---   Extracted from COMMON_COMMANDS.lua to keep that file under the 600-line
---   soft limit. These are command handlers for diagnostics, performance
---   profiling, and message-config toggles - none of them are user-facing
---   gameplay commands. As a diagnostic tool it may write to chat directly
---   (CODE_QUALITY section 6).
---
---   Public API (re-exposed as CommonCommands.handle_* by COMMON_COMMANDS.lua):
---     DebugCommands.handle_perf(action)        - performance profiler control
---     DebugCommands.handle_fulltest(action)    - full system test runner
---     DebugCommands.handle_syscheck(action)    - system health check
---     DebugCommands.handle_lagdebug(action)    - lag debugger toggle
---     DebugCommands.handle_debugsubjob()       - dump player subjob info
---     DebugCommands.handle_jamsg(mode)         - JA messages display mode
---     DebugCommands.handle_spellmsg(mode)      - Spell messages display mode
---     DebugCommands.handle_wsmsg(mode)         - WS messages display mode
---     DebugCommands.handle_info(args)          - info command (JA/Spell/WS detail)
---     DebugCommands.handle_debugstate()        - lifecycle counters dump
---     DebugCommands.handle_memcheck()          - _G / package.loaded export
---     DebugCommands.handle_debugwarp/debugprecast/automovedebug/
---         debugjobchange/debugupdate()          - debug flag toggles
---     DebugCommands.handle_debugmsg()          - message display modes dump
---
---   @file    shared/utils/core/DEBUG_COMMANDS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-01
---  ═══════════════════════════════════════════════════════════════════════════

local DebugCommands = {}

local MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

---  ═══════════════════════════════════════════════════════════════════════════
---   PERFORMANCE PROFILER
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle //gs c perf [start|stop|toggle|status] (anything else = status).
--- @param action string|nil Sub-command
--- @return boolean False if the profiler failed to load
function DebugCommands.handle_perf(action)
    local profiler_success, Profiler = pcall(require, 'shared/utils/debug/performance_profiler')
    if not profiler_success or not Profiler then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load performance profiler")
        return false
    end

    action = action and action:lower() or 'status'

    if action == 'start' or action == 'on' or action == 'enable' then
        Profiler.enable()
    elseif action == 'stop' or action == 'off' or action == 'disable' then
        Profiler.disable()
    elseif action == 'toggle' then
        Profiler.toggle()
    else
        Profiler.status()
    end
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   FULL TEST / SYSTEM CHECK / LAG DEBUGGER
---  ═══════════════════════════════════════════════════════════════════════════

--- Run comprehensive in-game test across all verifiable areas.
--- Usage: //gs c fulltest [export]
--- @param action string|nil 'export' also writes the report to a file
--- @return boolean False if the test module failed to load
function DebugCommands.handle_fulltest(action)
    local ok_load, FullTest = pcall(require, 'shared/utils/debug/full_test')
    if not ok_load or not FullTest then
        add_to_chat(207, '[FullTest] Failed to load: ' .. tostring(FullTest))
        return false
    end
    local report = FullTest.run()
    FullTest.display(report)
    if action and action:lower() == 'export' then
        FullTest.export(report)
    end
    return true
end

--- Run a full system health check with % score.
--- Usage: //gs c syscheck [export]
--- @param action string|nil 'export' also writes the report to a file
--- @return boolean False if the checker failed to load
function DebugCommands.handle_syscheck(action)
    local ok, SystemChecker = pcall(require, 'shared/utils/debug/system_checker')
    if not ok or not SystemChecker then
        add_to_chat(207, '[SysCheck] Failed to load: ' .. tostring(SystemChecker))
        return false
    end
    local report = SystemChecker.run()
    SystemChecker.display(report)
    if action and action:lower() == 'export' then
        SystemChecker.export(report)
    end
    return true
end

--- Handle lag debugger commands.
--- Usage: //gs c lagdebug [export|reset|status]  (any other arg or none = toggle)
--- @param action string|nil Sub-command
--- @return boolean False if _G.LagDebugger is not loaded
function DebugCommands.handle_lagdebug(action)
    local ld = _G.LagDebugger
    if not ld then
        add_to_chat(207, '[LagDebug] Module not loaded - reload GearSwap')
        return false
    end
    action = action and action:lower() or 'toggle'
    if action == 'export' or action == 'exp' or action == 'e' then
        ld.export()
    elseif action == 'reset' or action == 'clear' or action == 'r' then
        ld.reset()
    elseif action == 'status' or action == 'stat' or action == 's' then
        ld.status()
    else
        ld.toggle()
    end
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SUBJOB DEBUG
---  ═══════════════════════════════════════════════════════════════════════════

--- Display detailed subjob information for testing.
--- Used to verify player.sub_job_level returns 0 in Odyssey Sheol Gaol.
--- @return boolean False if `player` is unavailable
function DebugCommands.handle_debugsubjob()
    if not player then
        MessageCommands.show_debugsubjob_no_player()
        return false
    end

    MessageCommands.show_debugsubjob_header()
    MessageCommands.show_main_job_info(player.main_job or "NIL", player.main_job_level or "NIL")
    MessageCommands.show_sub_job_info(player.sub_job or "NIL", player.sub_job_level or "NIL")

    local info = windower.ffxi.get_info()
    if info then
        MessageCommands.show_zone_info_header()
        MessageCommands.show_zone_id(info.zone or "NIL")
        local res_success, res = pcall(require, 'resources')
        if res_success and res and res.zones and res.zones[info.zone] then
            MessageCommands.show_zone_name(res.zones[info.zone].en or "Unknown")
        else
            MessageCommands.show_zone_name("Unknown (resources not loaded)")
        end
    else
        MessageCommands.show_zone_info_unavailable()
    end

    MessageCommands.show_debugsubjob_instructions()
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MESSAGE CONFIG TOGGLES (jamsg / spellmsg / wsmsg)
---  ═══════════════════════════════════════════════════════════════════════════

-- One handler for the three commands; the MessageCommands function names are
-- built from `prefix` ('show_jamsg_invalid_mode', ...).
local MSG_CONFIG_MAP = {
    ja    = {path = 'shared/config/JA_MESSAGES_CONFIG',        prefix = 'jamsg'},
    spell = {path = 'shared/config/ENHANCING_MESSAGES_CONFIG', prefix = 'spellmsg'},
    ws    = {path = 'shared/config/WS_MESSAGES_CONFIG',        prefix = 'wsmsg'},
}

--- Show or change one message display mode.
--- @param msg_type string 'ja', 'spell' or 'ws'
--- @param mode_arg string|nil New mode (nil = show the current one)
--- @return boolean True if shown or changed
local function handle_message_config_generic(msg_type, mode_arg)
    local cfg = MSG_CONFIG_MAP[msg_type]
    if not cfg then return false end

    local config_success, Config = pcall(require, cfg.path)
    if not config_success then
        MessageCommands['show_' .. cfg.prefix .. '_config_error']()
        return false
    end

    if not mode_arg or mode_arg:lower() == 'help' then
        MessageCommands.show_message_mode_help(msg_type, Config.display_mode)
        return true
    end

    local mode = mode_arg:lower()
    local new_mode

    if mode == 'full' or mode == 'f' then
        new_mode = 'full'
    elseif mode == 'on' or mode == 'name' or mode == 'nameonly' or mode == 'name_only' or mode == 'n'
        or (msg_type == 'ws' and (mode == 'tp' or mode == 'tponly' or mode == 'tp_only' or mode == 't')) then
        new_mode = 'on'
    elseif mode == 'off' or mode == 'disabled' or mode == 'disable' or mode == 'd' then
        new_mode = 'off'
    else
        MessageCommands['show_' .. cfg.prefix .. '_invalid_mode'](mode_arg)
        return false
    end

    if Config.set_display_mode(new_mode) then
        MessageCommands['show_' .. cfg.prefix .. '_mode_changed'](new_mode)
        return true
    else
        MessageCommands['show_' .. cfg.prefix .. '_set_failed']()
        return false
    end
end

--- //gs c jamsg <full|on|off>
--- @param mode_arg string|nil New mode (nil = show the current one)
--- @return boolean True if shown or changed
function DebugCommands.handle_jamsg(mode_arg)
    return handle_message_config_generic('ja', mode_arg)
end

--- //gs c spellmsg <full|on|off>. Enhancing and Enfeebling share spell_mode
--- (message_settings.lua), so this changes both.
--- @param mode_arg string|nil New mode (nil = show the current one)
--- @return boolean True if shown or changed
function DebugCommands.handle_spellmsg(mode_arg)
    return handle_message_config_generic('spell', mode_arg)
end

--- //gs c wsmsg <full|on|off|tp> ('tp' is an alias of 'on').
--- @param mode_arg string|nil New mode (nil = show the current one)
--- @return boolean True if shown or changed
function DebugCommands.handle_wsmsg(mode_arg)
    return handle_message_config_generic('ws', mode_arg)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INFO COMMAND  (JA/Spell/WS detail viewer)
---  ═══════════════════════════════════════════════════════════════════════════

--- //gs c info <name>: delegated to commands/info_command.lua.
--- @param args table Arguments after 'info'
--- @return boolean Result of InfoCommand.handle
function DebugCommands.handle_info(args)
    local InfoCommand = require('shared/utils/commands/info_command')
    return InfoCommand.handle(args)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEBUG STATE DUMP  (//gs c debugstate | ds)
---  ═══════════════════════════════════════════════════════════════════════════

--- Dump global state used to diagnose accumulated lifecycle issues
--- (AutoMove sequence counters, JobChangeManager debounce, UI manager IDs).
--- @return boolean Always true
function DebugCommands.handle_debugstate()
    add_to_chat(207, '=== DEBUG STATE ===')
    add_to_chat(207, string.format('AUTOMOVE_RUNNING: %s', tostring(_G.AUTOMOVE_RUNNING)))
    add_to_chat(207, string.format('windower._automove_seq: %s (persistent)', tostring(windower._automove_seq)))
    add_to_chat(207, string.format('_G._automove_sequence: %s (sync)', tostring(_G._automove_sequence)))
    if _G.JobChangeManagerSTATE then
        local S = _G.JobChangeManagerSTATE
        add_to_chat(207, string.format('JCM counter: %d', S.debounce_counter or 0))
        local reg_count = 0
        if S.lockstyle_cancel_registry then
            for _ in pairs(S.lockstyle_cancel_registry) do reg_count = reg_count + 1 end
        end
        add_to_chat(207, string.format('JCM lockstyle_registry: %d entries', reg_count))
    end
    if _G.ui_manager_state then
        local U = _G.ui_manager_state
        add_to_chat(207, string.format('UI smart_init_id: %d', U.smart_init_id or 0))
        add_to_chat(207, string.format('UI pending_update_id: %d', U.pending_update_id or 0))
        add_to_chat(207, string.format('UI update_cancel_id: %d', U.update_cancel_id or 0))
        add_to_chat(207, string.format('UI consecutive_failures: %d', U.consecutive_failures or 0))
    end
    add_to_chat(207, '===================')
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MEMCHECK
---  ═══════════════════════════════════════════════════════════════════════════

local MessageRenderer  = require('shared/utils/messages/core/message_renderer')
local MessageFormatter = require('shared/utils/messages/message_formatter')

local TYPE_ORDER = {'table', 'function', 'string', 'number', 'boolean', 'userdata', 'thread'}
local LINE_SEP = string.rep('=', 75)
local SUB_SEP  = string.rep('-', 75)
local TOP_TABLE_COUNT = 50

--- Every _G entry grouped by type, tables carrying their direct child count.
--- @return table by_type [type] = { {name, size?}, ... }
--- @return number Total number of _G entries
local function survey_globals()
    local by_type, total = {}, 0
    for k, v in pairs(_G) do
        total = total + 1
        local t = type(v)
        by_type[t] = by_type[t] or {}
        if t == 'table' then
            local n = 0
            for _ in pairs(v) do n = n + 1 end
            table.insert(by_type[t], {name = tostring(k), size = n})
        else
            table.insert(by_type[t], {name = tostring(k)})
        end
    end
    return by_type, total
end

--- @return table Sorted names of every loaded module
local function loaded_package_names()
    local names = {}
    if package and package.loaded then
        for name in pairs(package.loaded) do
            table.insert(names, tostring(name))
        end
        table.sort(names)
    end
    return names
end

--- Tables ranked by child count - the only size proxy left once the sandbox
--- has taken `collectgarbage` away.
--- @param by_type table From survey_globals
--- @return table Entries, biggest first
local function tables_by_size(by_type)
    local ranked = {}
    for _, entry in ipairs(by_type['table'] or {}) do
        table.insert(ranked, entry)
    end
    table.sort(ranked, function(a, b) return (a.size or 0) > (b.size or 0) end)
    return ranked
end

local function write_header(w, char, job)
    w(LINE_SEP)
    w(string.format('  GEARSWAP MEMCHECK  -  %s / %s', char, job))
    w(string.format('  Generated: %s', os.date('%Y-%m-%d %H:%M:%S')))
    w(LINE_SEP)
    w('')
end

local function write_type_summary(w, by_type, total)
    w('SECTION 1 - _G entries by type')
    w(SUB_SEP)
    for _, t in ipairs(TYPE_ORDER) do
        local list = by_type[t]
        if list then
            w(string.format('  %-10s : %d entries', t, #list))
        end
    end
    w(string.format('  %-10s : %d', 'TOTAL', total))
    w('')
end

local function write_top_tables(w, top_tables)
    local shown = math.min(TOP_TABLE_COUNT, #top_tables)
    w(string.format('SECTION 2 - Top %d tables by child count (proxy for size)', shown))
    w(SUB_SEP)
    for i = 1, shown do
        local entry = top_tables[i]
        w(string.format('  %4d  %s', entry.size or 0, entry.name))
    end
    w('')
end

local function write_all_globals(w, by_type)
    w('SECTION 3 - All _G entries (sorted)')
    w(SUB_SEP)
    for _, t in ipairs(TYPE_ORDER) do
        local list = by_type[t]
        if list then
            table.sort(list, function(a, b) return a.name < b.name end)
            w(string.format('-- [%s] %d entries', t, #list))
            for _, entry in ipairs(list) do
                if entry.size then
                    w(string.format('  %s  (size=%d)', entry.name, entry.size))
                else
                    w('  ' .. entry.name)
                end
            end
            w('')
        end
    end
end

local function write_packages(w, packages)
    w(string.format('SECTION 4 - package.loaded (%d modules)', #packages))
    w(SUB_SEP)
    for _, p in ipairs(packages) do w('  ' .. p) end
    w('')
    w(LINE_SEP)
    w('END')
    w(LINE_SEP)
end

--- Assemble the memcheck text file.
--- @return string The whole report, ready to write
local function build_report(char, job, by_type, total, top_tables, packages)
    local out = {}
    local function w(line) table.insert(out, line) end

    write_header(w, char, job)
    write_type_summary(w, by_type, total)
    write_top_tables(w, top_tables)
    write_all_globals(w, by_type)
    write_packages(w, packages)

    return table.concat(out, '\n')
end

--- Write the report to data/memcheck_<char>_<job>.txt.
--- @return string|nil Path written, nil on failure
--- @return string|nil Reason it could not be written
local function export_report(char, job, text)
    local path = windower.addon_path .. 'data/'
        .. string.format('memcheck_%s_%s.txt', char, job)
    local fh, err = io.open(path, 'w')
    if not fh then return nil, err end
    fh:write(text)
    fh:close()
    return path
end

--- The part that reaches chat: three numbers and where the rest of it went.
local function announce_summary(by_type, total_g, top_tables, packages, file_path, sep)
    MessageRenderer.send(string.format('  _G entries: %d  (tables=%d, functions=%d)',
        total_g,
        #(by_type['table'] or {}),
        #(by_type['function'] or {})), 121)
    MessageRenderer.send(string.format('  Loaded packages: %d', #packages), 121)
    if top_tables[1] then
        MessageRenderer.send(string.format('  Biggest table: %s (%d children)',
            top_tables[1].name, top_tables[1].size or 0), 121)
    end
    MessageRenderer.send('  Exported: ' .. file_path, 123)
    MessageRenderer.send(sep, 121)
end

--- Memory diagnostic for GearSwap.
--- The sandbox nukes `collectgarbage`/`gcinfo` (in-process introspection is
--- impossible) and `//lua m` output goes to Windower's console (F11) which
--- scrolls past the visible window. As a workaround we enumerate `_G` +
--- `package.loaded` from inside the addon and EXPORT the full breakdown to a
--- file for offline review.
---
--- Output file: data/memcheck_<char>_<job>.txt
---   - Sorted list of package.loaded. That is Windower's own libs and nothing
---     else: GearSwap's require is include_user, which reads package.loaded
---     but never writes to it, so no project module ever appears there. The
---     project's own modules live in `_G.__require_cache` instead, and show up
---     in the _G sections below (see shared/utils/core/module_cache.lua).
---   - Sorted list of every _G entry grouped by type
---   - Top tables ranked by direct child count (rough size proxy)
---
--- Chat shows just a summary + the file path.
--- Usage: //gs c memcheck     (or //gs c mem)
--- @param arg string|nil Unused (the router passes args[1])
--- @return boolean Always true
function DebugCommands.handle_memcheck(arg)
    local sep = string.rep('=', 60)
    MessageRenderer.send(sep, 121)
    MessageRenderer.send('[MEMCHECK] GearSwap memory', 121)
    MessageRenderer.send(sep, 121)

    local char = (player and player.name) or 'unknown'
    local job  = (player and player.main_job) or 'XXX'

    local by_type, total_g = survey_globals()
    local packages = loaded_package_names()
    local top_tables = tables_by_size(by_type)

    local report = build_report(char, job, by_type, total_g, top_tables, packages)
    local file_path, err = export_report(char, job, report)
    if not file_path then
        MessageFormatter.show_error('MEMCHECK', 'Failed to open output file: ' .. tostring(err))
        return true
    end

    announce_summary(by_type, total_g, top_tables, packages, file_path, sep)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEBUG TOGGLES
---  ═══════════════════════════════════════════════════════════════════════════

--- Flip one debug flag kept on windower, which outlives the sandbox: a flag
--- only in _G is gone at the next job load. INIT_SYSTEMS copies these fields
--- back into _G on every load.
--- @param key string Field of windower._gs_debug
--- @return boolean The new value
local function flip_debug(key)
    windower._gs_debug = windower._gs_debug or {}
    windower._gs_debug[key] = not windower._gs_debug[key]
    return windower._gs_debug[key]
end

--- //gs c debugwarp - toggle warp debug output.
--- @return boolean Always true
function DebugCommands.handle_debugwarp()
    _G.WARP_DEBUG = flip_debug('WARP')
    MessageCommands.show_warp_debug_toggled(_G.WARP_DEBUG)
    return true
end

--- //gs c debugprecast - toggle precast debug output.
--- @return boolean Always true
function DebugCommands.handle_debugprecast()
    _G.PrecastDebugState = flip_debug('PRECAST')
    local MessagePrecast = require('shared/utils/messages/formatters/magic/message_precast')
    if _G.PrecastDebugState then
        MessagePrecast.show_debug_enabled()
    else
        MessagePrecast.show_debug_disabled()
    end
    return true
end

--- //gs c automovedebug - toggle AutoMove timing debug. It needs its own
--- persistent field: writing only _G meant INIT_SYSTEMS overwrote it from
--- _gs_debug.UPDATE at the next load, so the toggle silently undid itself on
--- a subjob change.
--- @return boolean Always true
function DebugCommands.handle_automovedebug()
    _G.AUTOMOVE_DEBUG = flip_debug('AUTOMOVE')
    MessageFormatter.show_debug('AutoMove', 'Debug mode: ' .. (_G.AUTOMOVE_DEBUG and 'ON' or 'OFF'))
    return true
end

--- //gs c debugjobchange - toggle job change tracing, then dump the
--- JobChangeManager state when turning it on.
--- @return boolean Always true
function DebugCommands.handle_debugjobchange()
    _G.JOBCHANGE_DEBUG = flip_debug('JOBCHANGE')
    MessageFormatter.show_debug('JobChange', 'Debug mode: ' .. (_G.JOBCHANGE_DEBUG and 'ON' or 'OFF'))
    if _G.JOBCHANGE_DEBUG and _G.JobChangeManagerSTATE then
        local S = _G.JobChangeManagerSTATE
        MessageFormatter.show_debug('JobChange', string.format('counter=%d, current=%s/%s, target=%s/%s',
            S.debounce_counter or 0,
            tostring(S.current_main_job), tostring(S.current_sub_job),
            tostring(S.target_main_job), tostring(S.target_sub_job)))
    end
    return true
end

--- //gs c debugupdate - trace the full gs c update flow; also sets the
--- AutoMove trace to the same value.
--- @return boolean Always true
function DebugCommands.handle_debugupdate()
    _G.UPDATE_DEBUG = flip_debug('UPDATE')
    windower._gs_debug.AUTOMOVE = windower._gs_debug.UPDATE
    _G.AUTOMOVE_DEBUG = windower._gs_debug.AUTOMOVE
    MessageFormatter.show_debug('UPDATE', string.format('%s (traces: AutoMove > job_update > UI.update > customize_set)',
        _G.UPDATE_DEBUG and 'ON' or 'OFF'))
    return true
end

--- //gs c debugmsg - dump the current message display modes.
--- @return boolean Always true
function DebugCommands.handle_debugmsg()
    local settings = _G.MESSAGE_SETTINGS
    if not settings then
        MessageFormatter.show_error('MSG', 'MESSAGE_SETTINGS is nil!')
        return true
    end
    MessageFormatter.show_debug('MSG', 'MESSAGE_SETTINGS:')
    MessageFormatter.show_debug('MSG', '  spell_mode: ' .. tostring(settings.spell_mode or 'nil'))
    MessageFormatter.show_debug('MSG', '  ja_mode: '    .. tostring(settings.ja_mode    or 'nil'))
    MessageFormatter.show_debug('MSG', '  ws_mode: '    .. tostring(settings.ws_mode    or 'nil'))
    return true
end

return DebugCommands
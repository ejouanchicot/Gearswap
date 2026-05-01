---  ═══════════════════════════════════════════════════════════════════════════
---   DebugCommands - Diagnostic / debug-toggle command handlers
---  ═══════════════════════════════════════════════════════════════════════════
---   Extracted from COMMON_COMMANDS.lua to keep that file under the 600-line
---   soft limit. These are command handlers for diagnostics, performance
---   profiling, and message-config toggles - none of them are user-facing
---   gameplay commands.
---
---   Public API (called by COMMON_COMMANDS.handle_command dispatcher):
---     DebugCommands.handle_perf(action)        - performance profiler control
---     DebugCommands.handle_fulltest(action)    - full system test runner
---     DebugCommands.handle_syscheck(action)    - system health check
---     DebugCommands.handle_lagdebug(action)    - lag debugger toggle
---     DebugCommands.handle_debugsubjob()       - dump player subjob info
---     DebugCommands.handle_jamsg(mode)         - JA messages display mode
---     DebugCommands.handle_spellmsg(mode)      - Spell messages display mode
---     DebugCommands.handle_wsmsg(mode)         - WS messages display mode
---     DebugCommands.handle_info(args)          - info command (JA/Spell/WS detail)
---
---   @file shared/utils/core/DEBUG_COMMANDS.lua
---  ═══════════════════════════════════════════════════════════════════════════

local DebugCommands = {}

local MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

---  ═══════════════════════════════════════════════════════════════════════════
---   PERFORMANCE PROFILER
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle //gs c perf [start|stop|toggle|status]
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
--- Usage: //gs c lagdebug [export|reset|status]  (no arg = toggle)
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
--- Generic handler eliminates 114 lines of duplication across 3 commands.

local MSG_CONFIG_MAP = {
    ja    = {path = 'shared/config/JA_MESSAGES_CONFIG',        prefix = 'jamsg'},
    spell = {path = 'shared/config/ENHANCING_MESSAGES_CONFIG', prefix = 'spellmsg'},
    ws    = {path = 'shared/config/WS_MESSAGES_CONFIG',        prefix = 'wsmsg'},
}

local function handle_message_config_generic(msg_type, mode_arg)
    local cfg = MSG_CONFIG_MAP[msg_type]
    if not cfg then return false end

    local config_success, Config = pcall(require, cfg.path)
    if not config_success then
        MessageCommands['show_' .. cfg.prefix .. '_config_error']()
        return false
    end

    if not mode_arg then
        MessageCommands['show_' .. cfg.prefix .. '_status_header']()
        MessageCommands['show_' .. cfg.prefix .. '_current_mode'](Config.display_mode)
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
function DebugCommands.handle_jamsg(mode_arg)
    return handle_message_config_generic('ja', mode_arg)
end

--- //gs c spellmsg <full|on|off>  (controls all non-Enfeebling spell categories)
function DebugCommands.handle_spellmsg(mode_arg)
    return handle_message_config_generic('spell', mode_arg)
end

--- //gs c wsmsg <full|on|off|tp>
function DebugCommands.handle_wsmsg(mode_arg)
    return handle_message_config_generic('ws', mode_arg)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INFO COMMAND  (JA/Spell/WS detail viewer)
---  ═══════════════════════════════════════════════════════════════════════════

function DebugCommands.handle_info(args)
    local InfoCommand = require('shared/utils/commands/info_command')
    return InfoCommand.handle(args)
end

return DebugCommands

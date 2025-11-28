---  ═══════════════════════════════════════════════════════════════════════════
---   Common Commands - Centralized Command Handler for All Jobs
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles universal commands that are identical across all jobs:
---   - reload: Force job change manager reload
---   - checksets: Run equipment validation
---   - warp: Warp system control + cast commands
---   - jamsg: Toggle Job Ability messages (full/on/off)
---   - spellmsg: Toggle Spell messages (full/on/off)
---   - info: Display detailed JA/Spell/WS information
---
---   @file    shared/utils/core/COMMON_COMMANDS.lua
---   @author  Tetsouo
---   @version 2.2 - Eliminated all duplication (generics + WARP_COMMANDS)
---   @date    Created: 2025-10-04 | Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════
local CommonCommands = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES
---  ═══════════════════════════════════════════════════════════════════════════

local MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

---  ═══════════════════════════════════════════════════════════════════════════
---   CONSTANTS - WARP COMMANDS LIST (50+ commands)
---  ═══════════════════════════════════════════════════════════════════════════

local WARP_COMMANDS = { -- System + BLM/WHM spells (original)
'warp', 'w', 'w2', 'warp2', 'ret', 'retrace', 'esc', 'escape', 'tph', 'tpholla', 'tpd', 'tpdem', 'tpm', 'tpmea', 'tpa',
'tpaltep', 'tpy', 'tpyhoat', 'tpv', 'tpvahzl', 'rj', 'recjugner', 'rp', 'recpashh', 'rm', 'recmeriph', -- Nations (3)
'sd', 'sandoria', 'bt', 'bastok', 'wd', 'windurst', -- Jeuno (1)
'jn', 'jeuno', -- Outpost Cities (5)
'sb', 'selbina', 'mh', 'mhaura', 'rb', 'rabao', 'kz', 'kazham', 'ng', 'norg', -- Expansion Cities (4)
'tv', 'tavnazia', 'au', 'wg', 'whitegate', 'ns', 'nashmau', 'ad', 'adoulin', -- Chocobo Stables (4)
'stsd', 'stable-sd', 'stbt', 'stable-bt', 'stwd', 'stable-wd', 'stjn', 'stable-jn', -- Conquest Outposts (1)
'op', 'outpost', -- Adoulin Frontier (7)
'cz', 'ceizak', 'ys', 'yahse', 'hn', 'hennetiel', 'mm', 'morimar', 'mj', 'marjami', 'yc', 'yorcia', 'km', 'kamihr',
-- Special Locations (13)
'wj', 'wajaom', 'ar', 'arrapago', 'pg', 'purgonorgo', 'rl', 'rulude', 'zv', 'zvahl', 'riv', 'riverne', 'yo', 'yoran',
'lf', 'leafallia', 'bh', 'behemoth', 'cc', 'chocircuit', 'pt', 'parting', 'cg', 'chocogirl', -- Unique Mechanics (2)
'ld', 'leader', 'td', 'tidal'}

---  ═══════════════════════════════════════════════════════════════════════════
---   RELOAD COMMAND
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle job reload command
--- @param job_name string Current job name (WAR, PLD, etc.)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_reload(job_name)
    local jcm_success, JobChangeManager = pcall(require, 'shared/utils/core/job_change_manager')
    if jcm_success and JobChangeManager then
        local main_job = player and player.main_job or job_name
        local sub_job = player and player.sub_job or "SAM"
        JobChangeManager.force_reload(main_job, sub_job)
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load job change manager")
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   JUMP COMMAND (SUB DRG)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle jump command for DRG subjob
--- @return boolean True if command was handled successfully
function CommonCommands.handle_jump()
    local drg_success, DRGJumpManager = pcall(require, 'shared/utils/drg/DRG_JUMP_MANAGER')
    if drg_success and DRGJumpManager then
        DRGJumpManager.execute_jump()
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load DRG jump manager")
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WALTZ COMMANDS (DNC MAIN/SUB)
---  ═══════════════════════════════════════════════════════════════════════════

--- Generic waltz handler (eliminates duplication between curing/divine)
--- @param waltz_type string Waltz type: 'curing' or 'divine'
--- @param error_msg string Error message if DNC not available
--- @return boolean True if command was handled successfully
local function handle_waltz_generic(waltz_type, error_msg)
    -- Check if DNC main or sub
    if player.main_job ~= 'DNC' and player.sub_job ~= 'DNC' then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error(error_msg)
        return false
    end

    -- Cancel Saber Dance if active
    if buffactive['Saber Dance'] then
        send_command('cancel Saber Dance')
    end

    local waltz_success, WaltzManager = pcall(require, 'shared/utils/dnc/waltz_manager')
    if waltz_success and WaltzManager then
        if waltz_type == 'curing' then
            WaltzManager.cast_curing_waltz('<stpc>')
        elseif waltz_type == 'divine' then
            WaltzManager.cast_divine_waltz()
        end
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load waltz manager")
        return false
    end
end

--- Handle curing waltz command (single target, intelligent tier selection)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_waltz()
    return handle_waltz_generic('curing', "Waltz requires DNC main or subjob")
end

--- Handle divine waltz command (AoE healing)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_aoewaltz()
    return handle_waltz_generic('divine', "Divine Waltz requires DNC main or subjob")
end

---  ═══════════════════════════════════════════════════════════════════════════
---   CHECKSETS COMMAND
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle equipment check command
--- @param job_name string Current job name (WAR, PLD, etc.)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_checksets(job_name)
    local equipment_success, EquipmentChecker = pcall(require, 'shared/utils/equipment/equipment_checker')
    if equipment_success and EquipmentChecker then
        EquipmentChecker.check_job_equipment(job_name)
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load equipment checker")
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   TESTCOLORS COMMAND
---  ═══════════════════════════════════════════════════════════════════════════

--- Display all FFXI color codes (001-509) to find which ones work
--- Uses dual-prefix system: 0x1F (codes 1-255), 0x1E (codes 256-509)
--- Filters out problematic codes that corrupt chat output
--- @return boolean True if command was handled successfully
function CommonCommands.handle_testcolors()
    MessageCommands.show_color_test_header()

    -- Build list of valid color codes (skip problematic ones)
    -- FFXI supports 509 colors total, but some are bugged/redundant
    local valid_codes = {}
    for code = 1, 509 do
        -- Skip problematic codes:
        --   10, 13: LF/CR (line breaks)
        --   30, 31: Conflict with color prefixes (0x1E, 0x1F)
        --   253-279: Bugged/redundant range (source: battlemod color_redundant)
        --   507-508: High codes with bugged offsets
        local is_problematic = (code >= 253 and code <= 279) or (code >= 507 and code <= 508) or code == 10 or code ==
            13 or code == 30 or code == 31

        if not is_problematic then
            table.insert(valid_codes, code)
        end
    end

    -- Display valid codes in rows of 14
    local row_count = 0
    for i = 1, #valid_codes, 14 do
        if row_count > 0 then
            MessageCommands.show_color_test_separator()
        end
        MessageCommands.show_color_sample_row(valid_codes[i], valid_codes[i + 1], valid_codes[i + 2],
            valid_codes[i + 3], valid_codes[i + 4], valid_codes[i + 5], valid_codes[i + 6], valid_codes[i + 7],
            valid_codes[i + 8], valid_codes[i + 9], valid_codes[i + 10], valid_codes[i + 11], valid_codes[i + 12],
            valid_codes[i + 13])
        row_count = row_count + 1
    end

    MessageCommands.show_color_test_footer()
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   LOCKSTYLE COMMAND
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle lockstyle reapply command (useful after dressup reload)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_lockstyle()
    -- Try to call the global lockstyle function (different per job)
    if select_default_lockstyle then
        MessageCommands.show_lockstyle_reapplying()
        select_default_lockstyle()
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Lockstyle function not available")
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DRESSUP TOGGLE COMMAND (Persistent)
---  ═══════════════════════════════════════════════════════════════════════════

--- Toggle DressUp management on/off (persistent across reloads)
--- When OFF: lockstyle commands won't try to unload/reload DressUp addon
--- Useful for players who don't have DressUp installed
--- Usage: //gs c dressup
--- @return boolean True if command was handled successfully
function CommonCommands.handle_dressup()
    local lockstyle_success, LockstyleManager = pcall(require, 'shared/utils/lockstyle/lockstyle_manager')
    if lockstyle_success and LockstyleManager and LockstyleManager.toggle_dressup then
        local enabled = LockstyleManager.toggle_dressup()
        MessageCommands.show_dressup_toggled(enabled)
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load lockstyle manager")
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PERFORMANCE PROFILER COMMAND
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle performance profiler commands
--- Usage: //gs c perf [start|stop|status]
--- @param action string Action to perform (start, stop, status)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_perf(action)
    local profiler_success, Profiler = pcall(require, 'shared/utils/debug/performance_profiler')
    if not profiler_success or not Profiler then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load performance profiler")
        return false
    end

    action = action and action:lower() or 'status'

    if action == 'start' or action == 'on' or action == 'enable' then
        Profiler.enable()
        return true
    elseif action == 'stop' or action == 'off' or action == 'disable' then
        Profiler.disable()
        return true
    elseif action == 'toggle' then
        Profiler.toggle()
        return true
    else
        -- Default: show status
        Profiler.status()
        return true
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WARP COMMANDS (Universal Warp/Teleport System)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle warp system commands (delegated to WarpCommands module)
--- @param cmdParams table All command parameters (including first param)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_warp_commands(cmdParams)
    local warp_success, WarpCommands = pcall(require, 'shared/utils/warp/warp_commands')
    if warp_success and WarpCommands then
        return WarpCommands.handle_command(cmdParams)
    else
        -- DETAILED ERROR REPORTING
        MessageCommands.show_warp_error_header()
        MessageCommands.show_warp_error(WarpCommands)
        MessageCommands.show_warp_error_footer()

        -- Also try to load each dependency separately to find the issue
        MessageCommands.show_warp_testing_modules()

        local test1, res1 = pcall(require, 'shared/utils/warp/warp_item_database')
        MessageCommands.show_warp_module_test('WarpItemDB', test1, res1)

        local test2, res2 = pcall(require, 'shared/utils/messages/message_warp')
        MessageCommands.show_warp_module_test('MessageWarp', test2, res2)

        local test3, res3 = pcall(require, 'shared/utils/warp/warp_equipment')
        MessageCommands.show_warp_module_test('WarpEquipment', test3, res3)

        MessageCommands.show_warp_error_footer()

        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEBUG SUBJOB COMMAND (Test for Odyssey subjob level = 0)
---  ═══════════════════════════════════════════════════════════════════════════

--- Display detailed subjob information for testing
--- Used to verify player.sub_job_level returns 0 in Odyssey Sheol Gaol
--- @return boolean True if command was handled successfully
function CommonCommands.handle_debugsubjob()
    if not player then
        MessageCommands.show_debugsubjob_no_player()
        return false
    end

    MessageCommands.show_debugsubjob_header()

    -- Job information
    MessageCommands.show_main_job_info(player.main_job or "NIL", player.main_job_level or "NIL")
    MessageCommands.show_sub_job_info(player.sub_job or "NIL", player.sub_job_level or "NIL")

    -- Zone information
    local info = windower.ffxi.get_info()
    if info then
        MessageCommands.show_zone_info_header()
        MessageCommands.show_zone_id(info.zone or "NIL")

        -- Try to get zone name from resources
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
---   MESSAGE CONFIG COMMANDS (Generic Handler - Eliminates Duplication)
---  ═══════════════════════════════════════════════════════════════════════════

--- Generic message config handler for JA/Spell/WS messages
--- Eliminates 114 lines of duplication across 3 identical functions
--- @param msg_type string Message type: 'ja', 'spell', or 'ws'
--- @param mode_arg string Display mode to set (full, on, off) or nil to show status
--- @return boolean True if command was handled successfully
local function handle_message_config_generic(msg_type, mode_arg)
    -- Map message types to config paths and function prefixes
    local config_map = {
        ja    = {path = 'shared/config/JA_MESSAGES_CONFIG',       prefix = 'jamsg'},
        spell = {path = 'shared/config/ENHANCING_MESSAGES_CONFIG', prefix = 'spellmsg'},
        ws    = {path = 'shared/config/WS_MESSAGES_CONFIG',        prefix = 'wsmsg'}
    }

    local cfg = config_map[msg_type]
    if not cfg then
        return false
    end

    -- Load config module
    local config_success, Config = pcall(require, cfg.path)
    if not config_success then
        MessageCommands['show_' .. cfg.prefix .. '_config_error']()
        return false
    end

    -- Show current mode if no argument
    if not mode_arg then
        MessageCommands['show_' .. cfg.prefix .. '_status_header']()
        MessageCommands['show_' .. cfg.prefix .. '_current_mode'](Config.display_mode)
        return true
    end

    -- Parse mode argument (with type-specific aliases)
    local mode = mode_arg:lower()
    local new_mode

    if mode == 'full' or mode == 'f' then
        new_mode = 'full'
    elseif mode == 'on' or mode == 'name' or mode == 'nameonly' or mode == 'name_only' or mode == 'n' or
           (msg_type == 'ws' and (mode == 'tp' or mode == 'tponly' or mode == 'tp_only' or mode == 't')) then
        new_mode = 'on'
    elseif mode == 'off' or mode == 'disabled' or mode == 'disable' or mode == 'd' then
        new_mode = 'off'
    else
        MessageCommands['show_' .. cfg.prefix .. '_invalid_mode'](mode_arg)
        return false
    end

    -- Set new mode
    if Config.set_display_mode(new_mode) then
        MessageCommands['show_' .. cfg.prefix .. '_mode_changed'](new_mode)
        return true
    else
        MessageCommands['show_' .. cfg.prefix .. '_set_failed']()
        return false
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   JA MESSAGES COMMAND (Toggle Job Ability messages)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle JA messages display mode command
--- Modes: full (name + description), on (name only), off (silent)
--- Usage: //gs c jamsg <full|on|off>
--- @param mode_arg string Display mode to set (full, on, off)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_jamsg(mode_arg)
    return handle_message_config_generic('ja', mode_arg)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INFO COMMAND (Display JA/Spell/WS Details)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle info command to display detailed information
--- @param args table Array of name parts (can be multi-word like "Last Resort")
--- @return boolean True if command was handled successfully
function CommonCommands.handle_info(args)
    local InfoCommand = require('shared/utils/commands/info_command')
    return InfoCommand.handle(args)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SPELL MESSAGES COMMAND (Toggle Spell messages - ALL categories)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle Spell messages display mode command
--- Controls ALL non-Enfeebling spells (Enhancing, Dark, Elemental, Healing, Divine, BRD, GEO, etc.)
--- Modes: full (name + description), on (name only), off (silent)
--- Usage: //gs c spellmsg <full|on|off>
--- @param mode_arg string Display mode to set (full, on, off)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_spellmsg(mode_arg)
    return handle_message_config_generic('spell', mode_arg)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   WEAPONSKILL MESSAGES COMMAND (Toggle WS messages)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle Weaponskill messages display mode command
--- Controls WS activation messages
--- Modes: full (name + description + TP), on (name + TP only), off (silent)
--- Usage: //gs c wsmsg <full|on|off|tp>
--- @param mode_arg string Display mode to set (full, on, off, tp)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_wsmsg(mode_arg)
    return handle_message_config_generic('ws', mode_arg)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MAIN COMMAND ROUTER
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle common commands (centralized for all jobs)
--- @param command string Command name (or cmdParams table for warp)
--- @param job_name string Current job name
--- @return boolean True if command was handled
function CommonCommands.handle_command(command, job_name, ...)
    if not command then
        return false
    end

    -- Support both string command and table cmdParams (for warp system)
    local cmd
    local cmdParams
    local varargs = {...} -- Capture varargs first (after job_name)

    if type(command) == "table" then
        -- Table format (used by warp system via job_self_command)
        cmdParams = command
        cmd = cmdParams[1] and cmdParams[1]:lower() or ""
    else
        -- String format (legacy)
        cmd = command:lower()
        -- Build cmdParams including command + all varargs
        cmdParams = {command}
        for i = 1, #varargs do
            table.insert(cmdParams, varargs[i])
        end
    end

    -- Extract arguments (everything after command, which is cmdParams[1])
    local args = {}
    for i = 2, #cmdParams do
        table.insert(args, cmdParams[i])
    end

    -- ==========================================================================
    -- WARP COMMANDS (50+ commands: spells + 40+ destinations)
    -- ==========================================================================
    -- Check warp commands first (includes: w, w2, ret, esc, tph, tpd, tpm, tpa,
    -- tpy, tpv, rj, rp, rm, warp [status|unlock|lock|test|help])

    -- Check exact matches first
    for _, warp_cmd in ipairs(WARP_COMMANDS) do
        if cmd == warp_cmd then
            return CommonCommands.handle_warp_commands(cmdParams)
        end
    end

    -- Check for "all" suffix (multi-boxing commands like warpall, tphall, sdall)
    if cmd:find('all$') then
        local base_cmd = cmd:gsub('all$', '')
        -- Verify base command is a valid warp command
        for _, warp_cmd in ipairs(WARP_COMMANDS) do
            if base_cmd == warp_cmd then
                return CommonCommands.handle_warp_commands(cmdParams)
            end
        end
    end

    -- ==========================================================================
    -- OTHER COMMON COMMANDS
    -- ==========================================================================
    if cmd == 'reload' then
        return CommonCommands.handle_reload(job_name)
    elseif cmd == 'checksets' then
        return CommonCommands.handle_checksets(job_name)
    elseif cmd == 'lockstyle' or cmd == 'ls' then
        return CommonCommands.handle_lockstyle()
    elseif cmd == 'dressup' then
        return CommonCommands.handle_dressup()
    elseif cmd == 'perf' then
        return CommonCommands.handle_perf(args[1])
    elseif cmd == 'testcolors' or cmd == 'colors' then
        return CommonCommands.handle_testcolors()
    elseif cmd == 'jump' then
        return CommonCommands.handle_jump()
    elseif cmd == 'waltz' then
        return CommonCommands.handle_waltz()
    elseif cmd == 'aoewaltz' then
        return CommonCommands.handle_aoewaltz()
    elseif cmd == 'debugsubjob' or cmd == 'dsj' then
        return CommonCommands.handle_debugsubjob()
    elseif cmd == 'debugwarp' then
        -- Toggle warp debug mode
        _G.WARP_DEBUG = not _G.WARP_DEBUG
        MessageCommands.show_warp_debug_toggled(_G.WARP_DEBUG)
        return true
    elseif cmd == 'debugprecast' then
        -- Toggle precast debug mode
        _G.PrecastDebugState = not _G.PrecastDebugState
        local MessagePrecast = require('shared/utils/messages/formatters/magic/message_precast')
        if _G.PrecastDebugState then
            MessagePrecast.show_debug_enabled()
        else
            MessagePrecast.show_debug_disabled()
        end
        return true
    elseif cmd == 'automovedebug' or cmd == 'amd' then
        -- Toggle AutoMove timing debug mode
        _G.AUTOMOVE_DEBUG = not _G.AUTOMOVE_DEBUG
        add_to_chat(207, '[AutoMove] Debug mode: ' .. (_G.AUTOMOVE_DEBUG and 'ON' or 'OFF'))
        return true
    elseif cmd == 'debugjobchange' or cmd == 'djc' then
        -- Toggle job change debug mode
        _G.JOBCHANGE_DEBUG = not _G.JOBCHANGE_DEBUG
        add_to_chat(207, '[JobChange] Debug mode: ' .. (_G.JOBCHANGE_DEBUG and 'ON' or 'OFF'))
        -- Show current state
        if _G.JOBCHANGE_DEBUG and _G.JobChangeManagerSTATE then
            local S = _G.JobChangeManagerSTATE
            add_to_chat(207, string.format('  counter=%d, current=%s/%s, target=%s/%s',
                S.debounce_counter or 0,
                tostring(S.current_main_job), tostring(S.current_sub_job),
                tostring(S.target_main_job), tostring(S.target_sub_job)))
        end
        return true
    elseif cmd == 'debugstate' or cmd == 'ds' then
        -- Show global state for debugging accumulated issues
        add_to_chat(207, '=== DEBUG STATE ===')
        add_to_chat(207, string.format('AUTOMOVE_RUNNING: %s', tostring(_G.AUTOMOVE_RUNNING)))
        add_to_chat(207, string.format('_automove_sequence: %s', tostring(_G._automove_sequence)))
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
    elseif cmd == 'debugupdate' or cmd == 'du' then
        -- Toggle UPDATE debug mode (traces full gs c update flow)
        _G.UPDATE_DEBUG = not _G.UPDATE_DEBUG
        _G.AUTOMOVE_DEBUG = _G.UPDATE_DEBUG  -- Also enable AutoMove debug
        add_to_chat(207, string.format('[UPDATE_DEBUG] %s (traces: AutoMove > job_update > UI.update > customize_set)',
            _G.UPDATE_DEBUG and 'ON' or 'OFF'))
        return true
    elseif cmd == 'jamsg' then
        return CommonCommands.handle_jamsg(args[1])
    elseif cmd == 'spellmsg' then
        return CommonCommands.handle_spellmsg(args[1])
    elseif cmd == 'wsmsg' then
        return CommonCommands.handle_wsmsg(args[1])
    elseif cmd == 'info' then
        return CommonCommands.handle_info(args)
    elseif cmd == 'debugmsg' then
        -- Debug message settings
        if _G.MESSAGE_SETTINGS then
            add_to_chat(159, '[DEBUG] MESSAGE_SETTINGS:')
            add_to_chat(159, '  spell_mode: ' .. tostring(_G.MESSAGE_SETTINGS.spell_mode or 'nil'))
            add_to_chat(159, '  ja_mode: ' .. tostring(_G.MESSAGE_SETTINGS.ja_mode or 'nil'))
            add_to_chat(159, '  ws_mode: ' .. tostring(_G.MESSAGE_SETTINGS.ws_mode or 'nil'))
        else
            add_to_chat(167, '[DEBUG] MESSAGE_SETTINGS is nil!')
        end
        return true
    elseif cmd == 'testmsg' or cmd == 'msgtest' then
        -- Test new message system
        -- Usage: //gs c testmsg [job]
        -- Examples: //gs c testmsg, //gs c testmsg brd, //gs c testmsg system
        local M = require('shared/utils/messages/api/messages')
        local job_filter = args[1] -- Optional job filter (e.g., "brd", "geo", "system")
        M.test(job_filter)
        return true
    elseif cmd == 'msgtests' then
        -- Validate entire message system
        local MessageValidator = require('shared/utils/messages/message_validator')
        MessageValidator.run_all_tests()
        return true
    elseif cmd == 'commands' or cmd == 'cmds' then
        -- Show list of all common commands
        MessageCommands.show_commands_list()
        return true
    elseif cmd == 'help' or cmd == '?' then
        -- Show quick help (redirects to main commands)
        MessageCommands.show_help()
        return true
    end

    return false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HELPER FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if command is a common command
--- @param command string The command to check
--- @return boolean True if this is a common command
function CommonCommands.is_common_command(command)
    if not command then
        return false
    end

    local cmd = command:lower()

    -- Check existing common commands
    if cmd == 'reload' or cmd == 'checksets' or cmd == 'lockstyle' or cmd == 'ls' or cmd == 'dressup' or
        cmd == 'perf' or cmd == 'testcolors' or cmd == 'colors' or cmd == 'jump' or cmd == 'waltz' or
        cmd == 'aoewaltz' or cmd == 'debugsubjob' or cmd == 'dsj' or cmd == 'debugwarp' or cmd == 'debugprecast' or
        cmd == 'automovedebug' or cmd == 'amd' or cmd == 'debugjobchange' or cmd == 'djc' or
        cmd == 'debugstate' or cmd == 'ds' or cmd == 'debugupdate' or cmd == 'du' or
        cmd == 'jamsg' or cmd == 'spellmsg' or cmd == 'wsmsg' or cmd == 'info' or cmd == 'testmsg' or
        cmd == 'msgtest' or cmd == 'msgtests' or cmd == 'commands' or cmd == 'cmds' or cmd == 'help' or cmd == '?' then
        return true
    end

    -- Check warp commands (50+ commands total)
    for _, warp_cmd in ipairs(WARP_COMMANDS) do
        if cmd == warp_cmd then
            return true
        end
    end

    -- Check for "all" suffix (multi-boxing commands)
    if cmd:find('all$') then
        local base_cmd = cmd:gsub('all$', '')
        for _, warp_cmd in ipairs(WARP_COMMANDS) do
            if base_cmd == warp_cmd then
                return true
            end
        end
    end

    return false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   STATE CHANGE HOOK (UI UPDATE)
---  ═══════════════════════════════════════════════════════════════════════════

--- Handle state changes and update UI
--- Call this from job_update() in all job files to keep UI synchronized
--- @return void
function CommonCommands.handle_state_change()
    local ui_success, KeybindUI = pcall(require, 'shared/utils/ui/UI_MANAGER')
    if ui_success and KeybindUI and KeybindUI.update then
        KeybindUI.update()
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return CommonCommands

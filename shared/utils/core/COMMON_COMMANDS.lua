---============================================================================
--- Common Commands - Centralized Command Handler for All Jobs
---============================================================================
--- Handles universal commands that are identical across all jobs:
--- - reload: Force job change manager reload
--- - checksets: Run equipment validation
--- - warp: Warp system control + cast commands
--- - jamsg: Toggle Job Ability messages (full/on/off)
--- - spellmsg: Toggle Spell messages (full/on/off)
--- - info: Display detailed JA/Spell/WS information
---
--- @file utils/core/COMMON_COMMANDS.lua
--- @author Tetsouo
--- @version 1.3 - Improved formatting
--- @date Created: 2025-10-04 | Updated: 2025-11-06
---============================================================================

local CommonCommands = {}

---============================================================================
--- DEPENDENCIES
---============================================================================

local MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

---============================================================================
--- RELOAD COMMAND
---============================================================================

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

---============================================================================
--- JUMP COMMAND (SUB DRG)
---============================================================================

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

---============================================================================
--- WALTZ COMMANDS (DNC MAIN/SUB)
---============================================================================

--- Handle curing waltz command (single target, intelligent tier selection)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_waltz()
    -- Check if DNC main or sub
    if player.main_job ~= 'DNC' and player.sub_job ~= 'DNC' then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Waltz requires DNC main or subjob")
        return false
    end

    -- Cancel Saber Dance if active
    if buffactive['Saber Dance'] then
        send_command('cancel Saber Dance')
    end

    local waltz_success, WaltzManager = pcall(require, 'shared/utils/dnc/waltz_manager')
    if waltz_success and WaltzManager then
        WaltzManager.cast_curing_waltz('<stpc>')
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load waltz manager")
        return false
    end
end

--- Handle divine waltz command (AoE healing)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_aoewaltz()
    -- Check if DNC main or sub
    if player.main_job ~= 'DNC' and player.sub_job ~= 'DNC' then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Divine Waltz requires DNC main or subjob")
        return false
    end

    -- Cancel Saber Dance if active
    if buffactive['Saber Dance'] then
        send_command('cancel Saber Dance')
    end

    local waltz_success, WaltzManager = pcall(require, 'shared/utils/dnc/waltz_manager')
    if waltz_success and WaltzManager then
        WaltzManager.cast_divine_waltz()
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load waltz manager")
        return false
    end
end

---============================================================================
--- CHECKSETS COMMAND
---============================================================================

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

---============================================================================
--- TESTCOLORS COMMAND
---============================================================================

--- Display all FFXI color codes (001-255) to find which ones work
--- @return boolean True if command was handled successfully
function CommonCommands.handle_testcolors()
    MessageCommands.show_color_test_header()

    -- Test all codes from 1 to 255 (14 per line for compact display)
    -- FFXI chat limit: 74 chars per line
    -- Format: "001 | 002 | ... | 014" = ~68 chars total (under 74 char limit)
    -- Each entry has its own inline color code to display its actual color
    local row_count = 0
    for i = 1, 255, 14 do
        if row_count > 0 then
            MessageCommands.show_color_test_separator()
        end
        MessageCommands.show_color_sample_row(i, i+1, i+2, i+3, i+4, i+5, i+6, i+7, i+8, i+9, i+10, i+11, i+12, i+13)
        row_count = row_count + 1
    end

    MessageCommands.show_color_test_footer()
    return true
end

---============================================================================
--- DETECTREGION COMMAND
---============================================================================

--- Detect FFXI region (EU vs US) automatically
--- @return boolean True if command was handled successfully
function CommonCommands.handle_detectregion()
    MessageCommands.show_detect_region_header()

    local detected_region = "UNKNOWN"
    local detection_method = "Unknown"
    local orange_code = 057  -- Default

    -- METHOD 1: Check Windower FFXI info
    if windower and windower.ffxi and windower.ffxi.get_info then
        local info = windower.ffxi.get_info()
        if info then
            -- Check for region indicators (no verbose output)
            for key, value in pairs(info) do
                local key_lower = tostring(key):lower()
                local val_lower = tostring(value):lower()

                if key_lower:find("region") or key_lower:find("locale") then
                    if val_lower:find("us") or val_lower:find("america") then
                        detected_region = "US"
                        detection_method = key .. " = " .. tostring(value)
                        orange_code = 057
                    elseif val_lower:find("eu") or val_lower:find("europe") then
                        detected_region = "EU"
                        detection_method = key .. " = " .. tostring(value)
                        orange_code = 002
                    end
                end
            end
        end
    end

    -- Display results directly (no intermediate info section)
    if detected_region ~= "UNKNOWN" then
        MessageCommands.show_region_detected(detected_region, detection_method, orange_code)
    else
        MessageCommands.show_region_detection_failed()
    end

    MessageCommands.show_detect_region_footer()

    -- Store detected region globally
    if detected_region ~= "UNKNOWN" then
        _G.DETECTED_FFXI_REGION = detected_region
        _G.ORANGE_COLOR_CODE = orange_code
        MessageCommands.show_region_saved()
    end

    return true
end

---============================================================================
--- SETREGION COMMAND
---============================================================================

--- Manually set FFXI region (EU or US)
--- @param region_arg string Region to set (eu or us)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_setregion(region_arg)
    if not region_arg then
        MessageCommands.show_setregion_usage()
        return false
    end

    local region = region_arg:lower()

    if region == "us" or region == "na" then
        _G.DETECTED_FFXI_REGION = "US"
        _G.ORANGE_COLOR_CODE = 057
        MessageCommands.show_region_set_us()
    elseif region == "eu" or region == "europe" then
        _G.DETECTED_FFXI_REGION = "EU"
        _G.ORANGE_COLOR_CODE = 002
        MessageCommands.show_region_set_eu()
    elseif region == "jp" or region == "japan" then
        _G.DETECTED_FFXI_REGION = "JP"
        _G.ORANGE_COLOR_CODE = 057
        MessageCommands.show_region_set_jp()
    else
        MessageCommands.show_invalid_region(region_arg)
        return false
    end

    MessageCommands.show_region_reload_required()

    return true
end

---============================================================================
--- LOCKSTYLE COMMAND
---============================================================================

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

---============================================================================
--- WARP COMMANDS (Universal Warp/Teleport System)
---============================================================================

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

---============================================================================
--- DEBUG SUBJOB COMMAND (Test for Odyssey subjob level = 0)
---============================================================================

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

---============================================================================
--- JA MESSAGES COMMAND (Toggle Job Ability messages)
---============================================================================

--- Handle JA messages display mode command
--- Modes: full (name + description), on (name only), off (silent)
--- Usage: //gs c jamsg <full|on|off>
--- @param mode_arg string Display mode to set (full, on, off)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_jamsg(mode_arg)
    local ja_config_success, JAConfig = pcall(require, 'shared/config/JA_MESSAGES_CONFIG')

    if not ja_config_success then
        MessageCommands.show_jamsg_config_error()
        return false
    end

    -- Show current mode if no argument
    if not mode_arg then
        MessageCommands.show_jamsg_status_header()
        MessageCommands.show_jamsg_current_mode(JAConfig.display_mode)
        return true
    end

    -- Parse mode argument
    local mode = mode_arg:lower()
    local new_mode

    if mode == 'full' or mode == 'f' then
        new_mode = 'full'
    elseif mode == 'on' or mode == 'name' or mode == 'nameonly' or mode == 'name_only' or mode == 'n' then
        new_mode = 'on'
    elseif mode == 'off' or mode == 'disabled' or mode == 'disable' or mode == 'd' then
        new_mode = 'off'
    else
        MessageCommands.show_jamsg_invalid_mode(mode_arg)
        return false
    end

    -- Set new mode
    if JAConfig.set_display_mode(new_mode) then
        MessageCommands.show_jamsg_mode_changed(new_mode)
        return true
    else
        MessageCommands.show_jamsg_set_failed()
        return false
    end
end

---============================================================================
--- INFO COMMAND (Display JA/Spell/WS Details)
---============================================================================

--- Handle info command to display detailed information
--- @param args table Array of name parts (can be multi-word like "Last Resort")
--- @return boolean True if command was handled successfully
function CommonCommands.handle_info(args)
    local InfoCommand = require('shared/utils/commands/info_command')
    return InfoCommand.handle(args)
end

---============================================================================
--- SPELL MESSAGES COMMAND (Toggle Spell messages - ALL categories)
---============================================================================

--- Handle Spell messages display mode command
--- Controls ALL non-Enfeebling spells (Enhancing, Dark, Elemental, Healing, Divine, BRD, GEO, etc.)
--- Modes: full (name + description), on (name only), off (silent)
--- Usage: //gs c spellmsg <full|on|off>
--- @param mode_arg string Display mode to set (full, on, off)
--- @return boolean True if command was handled successfully
function CommonCommands.handle_spellmsg(mode_arg)
    local spell_config_success, SpellConfig = pcall(require, 'shared/config/ENHANCING_MESSAGES_CONFIG')

    if not spell_config_success then
        MessageCommands.show_spellmsg_config_error()
        return false
    end

    -- Show current mode if no argument
    if not mode_arg then
        MessageCommands.show_spellmsg_status_header()
        MessageCommands.show_spellmsg_current_mode(SpellConfig.display_mode)
        return true
    end

    -- Parse mode argument
    local mode = mode_arg:lower()
    local new_mode

    if mode == 'full' or mode == 'f' then
        new_mode = 'full'
    elseif mode == 'on' or mode == 'name' or mode == 'nameonly' or mode == 'name_only' or mode == 'n' then
        new_mode = 'on'
    elseif mode == 'off' or mode == 'disabled' or mode == 'disable' or mode == 'd' then
        new_mode = 'off'
    else
        MessageCommands.show_spellmsg_invalid_mode(mode_arg)
        return false
    end

    -- Set new mode
    if SpellConfig.set_display_mode(new_mode) then
        MessageCommands.show_spellmsg_mode_changed(new_mode)
        return true
    else
        MessageCommands.show_spellmsg_set_failed()
        return false
    end
end

---============================================================================
--- MAIN COMMAND ROUTER
---============================================================================

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
    local varargs = {...}  -- Capture varargs first (after job_name)

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
    local warp_commands = {
        -- System + BLM/WHM spells (original)
        'warp', 'w', 'w2', 'warp2', 'ret', 'retrace', 'esc', 'escape',
        'tph', 'tpholla', 'tpd', 'tpdem', 'tpm', 'tpmea',
        'tpa', 'tpaltep', 'tpy', 'tpyhoat', 'tpv', 'tpvahzl',
        'rj', 'recjugner', 'rp', 'recpashh', 'rm', 'recmeriph',
        -- Nations (3)
        'sd', 'sandoria', 'bt', 'bastok', 'wd', 'windurst',
        -- Jeuno (1)
        'jn', 'jeuno',
        -- Outpost Cities (5)
        'sb', 'selbina', 'mh', 'mhaura', 'rb', 'rabao', 'kz', 'kazham', 'ng', 'norg',
        -- Expansion Cities (4)
        'tv', 'tavnazia', 'au', 'wg', 'whitegate', 'ns', 'nashmau', 'ad', 'adoulin',
        -- Chocobo Stables (4)
        'stsd', 'stable-sd', 'stbt', 'stable-bt', 'stwd', 'stable-wd', 'stjn', 'stable-jn',
        -- Conquest Outposts (1)
        'op', 'outpost',
        -- Adoulin Frontier (7)
        'cz', 'ceizak', 'ys', 'yahse', 'hn', 'hennetiel', 'mm', 'morimar',
        'mj', 'marjami', 'yc', 'yorcia', 'km', 'kamihr',
        -- Special Locations (13)
        'wj', 'wajaom', 'ar', 'arrapago', 'pg', 'purgonorgo', 'rl', 'rulude',
        'zv', 'zvahl', 'riv', 'riverne', 'yo', 'yoran', 'lf', 'leafallia',
        'bh', 'behemoth', 'cc', 'chocircuit', 'pt', 'parting', 'cg', 'chocogirl',
        -- Unique Mechanics (2)
        'ld', 'leader', 'td', 'tidal'
    }

    -- Check exact matches first
    for _, warp_cmd in ipairs(warp_commands) do
        if cmd == warp_cmd then
            return CommonCommands.handle_warp_commands(cmdParams)
        end
    end

    -- Check for "all" suffix (multi-boxing commands like warpall, tphall, sdall)
    if cmd:find('all$') then
        local base_cmd = cmd:gsub('all$', '')
        -- Verify base command is a valid warp command
        for _, warp_cmd in ipairs(warp_commands) do
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
    elseif cmd == 'testcolors' or cmd == 'colors' then
        return CommonCommands.handle_testcolors()
    elseif cmd == 'detectregion' or cmd == 'region' then
        return CommonCommands.handle_detectregion()
    elseif cmd == 'setregion' then
        return CommonCommands.handle_setregion(args[1])
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
    elseif cmd == 'jamsg' then
        return CommonCommands.handle_jamsg(args[1])
    elseif cmd == 'spellmsg' then
        return CommonCommands.handle_spellmsg(args[1])
    elseif cmd == 'info' then
        return CommonCommands.handle_info(args)
    elseif cmd == 'testmsg' or cmd == 'msgtest' then
        -- Test new message system
        local M = require('shared/utils/messages/api/messages')
        M.test()
        return true
    elseif cmd == 'msgtests' then
        -- Validate entire message system
        local MessageValidator = require('shared/utils/messages/message_validator')
        MessageValidator.run_all_tests()
        return true
    end

    return false
end

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if command is a common command
--- @param command string The command to check
--- @return boolean True if this is a common command
function CommonCommands.is_common_command(command)
    if not command then
        return false
    end

    local cmd = command:lower()

    -- Check existing common commands
    if cmd == 'reload' or cmd == 'checksets' or cmd == 'lockstyle' or cmd == 'ls' or
       cmd == 'testcolors' or cmd == 'colors' or cmd == 'detectregion' or cmd == 'region' or
       cmd == 'setregion' or cmd == 'jump' or cmd == 'waltz' or cmd == 'aoewaltz' or
       cmd == 'debugsubjob' or cmd == 'dsj' or cmd == 'debugwarp' or cmd == 'jamsg' or
       cmd == 'spellmsg' or cmd == 'info' or cmd == 'testmsg' or cmd == 'msgtest' or
       cmd == 'msgtests' then
        return true
    end

    -- Check warp commands (50+ commands total)
    local warp_commands = {
        -- System + BLM/WHM spells (original)
        'warp', 'w', 'w2', 'warp2', 'ret', 'retrace', 'esc', 'escape',
        'tph', 'tpholla', 'tpd', 'tpdem', 'tpm', 'tpmea',
        'tpa', 'tpaltep', 'tpy', 'tpyhoat', 'tpv', 'tpvahzl',
        'rj', 'recjugner', 'rp', 'recpashh', 'rm', 'recmeriph',
        -- Nations (3)
        'sd', 'sandoria', 'bt', 'bastok', 'wd', 'windurst',
        -- Jeuno (1)
        'jn', 'jeuno',
        -- Outpost Cities (5)
        'sb', 'selbina', 'mh', 'mhaura', 'rb', 'rabao', 'kz', 'kazham', 'ng', 'norg',
        -- Expansion Cities (4)
        'tv', 'tavnazia', 'au', 'wg', 'whitegate', 'ns', 'nashmau', 'ad', 'adoulin',
        -- Chocobo Stables (4)
        'stsd', 'stable-sd', 'stbt', 'stable-bt', 'stwd', 'stable-wd', 'stjn', 'stable-jn',
        -- Conquest Outposts (1)
        'op', 'outpost',
        -- Adoulin Frontier (7)
        'cz', 'ceizak', 'ys', 'yahse', 'hn', 'hennetiel', 'mm', 'morimar',
        'mj', 'marjami', 'yc', 'yorcia', 'km', 'kamihr',
        -- Special Locations (13)
        'wj', 'wajaom', 'ar', 'arrapago', 'pg', 'purgonorgo', 'rl', 'rulude',
        'zv', 'zvahl', 'riv', 'riverne', 'yo', 'yoran', 'lf', 'leafallia',
        'bh', 'behemoth', 'cc', 'chocircuit', 'pt', 'parting', 'cg', 'chocogirl',
        -- Unique Mechanics (2)
        'ld', 'leader', 'td', 'tidal'
    }

    for _, warp_cmd in ipairs(warp_commands) do
        if cmd == warp_cmd then
            return true
        end
    end

    -- Check for "all" suffix (multi-boxing commands)
    if cmd:find('all$') then
        local base_cmd = cmd:gsub('all$', '')
        for _, warp_cmd in ipairs(warp_commands) do
            if base_cmd == warp_cmd then
                return true
            end
        end
    end

    return false
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return CommonCommands

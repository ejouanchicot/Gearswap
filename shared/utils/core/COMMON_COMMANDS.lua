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
--- @version 1.3 - Added info command
--- @date Created: 2025-10-04 | Updated: 2025-11-04
---============================================================================

local CommonCommands = {}

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
    add_to_chat(159, '========================================')
    add_to_chat(159, 'FFXI Color Code Test (001-255)')
    add_to_chat(159, '========================================')

    -- Test all codes from 1 to 255
    for i = 1, 255 do
        local color_code = string.char(0x1F, i)
        local sample_text = color_code .. string.format("%03d - Sample Text", i)
        add_to_chat(121, sample_text)  -- Use channel 121 to preserve inline colors
    end

    add_to_chat(159, '========================================')
    add_to_chat(159, 'Color test complete!')
    add_to_chat(159, '========================================')
    return true
end

---============================================================================
--- DETECTREGION COMMAND
---============================================================================

--- Detect FFXI region (EU vs US) automatically
--- @return boolean True if command was handled successfully
function CommonCommands.handle_detectregion()
    add_to_chat(159, '========================================')
    add_to_chat(159, 'FFXI Region Auto-Detection')
    add_to_chat(159, '========================================')

    local detected_region = "UNKNOWN"
    local detection_method = "Unknown"
    local orange_code = 057  -- Default

    -- METHOD 1: Check Windower FFXI info
    if windower and windower.ffxi and windower.ffxi.get_info then
        local info = windower.ffxi.get_info()
        if info then
            add_to_chat(121, 'Windower FFXI Info:')

            -- Dump all fields to find differences
            for key, value in pairs(info) do
                local value_str = tostring(value)
                if type(value) == "table" then
                    value_str = "table"
                end
                add_to_chat(121, '  ' .. tostring(key) .. ': ' .. value_str)

                -- Check for region indicators
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

    -- Display results
    add_to_chat(121, ' ')
    add_to_chat(159, '========================================')
    add_to_chat(159, 'DETECTION RESULTS:')
    add_to_chat(159, '========================================')

    if detected_region ~= "UNKNOWN" then
        local result_color = string.char(0x1F, 158)  -- Green
        add_to_chat(121, result_color .. 'Region Detected: ' .. detected_region)
        add_to_chat(121, 'Detection Method: ' .. detection_method)
        add_to_chat(121, 'Recommended Orange Code: ' .. orange_code)
    else
        local warning_color = string.char(0x1F, 167)  -- Red
        add_to_chat(121, warning_color .. 'Region: AUTO-DETECTION FAILED')
        add_to_chat(121, ' ')
        add_to_chat(121, 'MANUAL TEST:')
        add_to_chat(121, 'Look at the line below:')

        local test_057 = string.char(0x1F, 057)
        add_to_chat(121, test_057 .. 'Code 057 SAMPLE - Is this ORANGE or CYAN?')

        add_to_chat(121, ' ')
        add_to_chat(121, 'If ORANGE = US (use code 057)')
        add_to_chat(121, 'If WHITE/NO COLOR = EU (use code 002 - Rose)')
        add_to_chat(121, ' ')
        add_to_chat(121, 'To set manually:')
        add_to_chat(121, '  //gs c setregion us')
        add_to_chat(121, '  //gs c setregion eu')
    end

    add_to_chat(159, '========================================')

    -- Store detected region globally
    if detected_region ~= "UNKNOWN" then
        _G.DETECTED_FFXI_REGION = detected_region
        _G.ORANGE_COLOR_CODE = orange_code
        add_to_chat(121, 'Region saved to _G.DETECTED_FFXI_REGION')
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
        add_to_chat(167, 'Usage: //gs c setregion <eu|us>')
        return false
    end

    local region = region_arg:lower()
    local orange_code = 057  -- Default

    if region == "us" or region == "na" then
        _G.DETECTED_FFXI_REGION = "US"
        _G.ORANGE_COLOR_CODE = 057
        orange_code = 057
        add_to_chat(158, 'Region set to: US')
        add_to_chat(121, 'Orange color code: 057')
    elseif region == "eu" or region == "europe" then
        _G.DETECTED_FFXI_REGION = "EU"
        _G.ORANGE_COLOR_CODE = 002
        orange_code = 002
        add_to_chat(158, 'Region set to: EU')
        add_to_chat(121, 'Warning color code: 002 (Rose - no orange on EU)')
    elseif region == "jp" or region == "japan" then
        _G.DETECTED_FFXI_REGION = "JP"
        _G.ORANGE_COLOR_CODE = 057
        orange_code = 057
        add_to_chat(158, 'Region set to: JP')
        add_to_chat(121, 'Orange color code: 057')
    else
        add_to_chat(167, 'Invalid region: ' .. region_arg)
        add_to_chat(121, 'Valid options: us, eu, jp')
        return false
    end

    add_to_chat(121, 'Region saved to _G.DETECTED_FFXI_REGION')
    add_to_chat(121, 'Reload GearSwap to apply changes')

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
        add_to_chat(158, 'Reapplying lockstyle...')
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
        add_to_chat(167, '========================================')
        add_to_chat(167, '[WARP] ERROR LOADING WARP COMMANDS:')
        add_to_chat(167, '========================================')
        add_to_chat(167, tostring(WarpCommands))
        add_to_chat(167, '========================================')

        -- Also try to load each dependency separately to find the issue
        add_to_chat(167, '[WARP] Testing individual modules...')

        local test1, res1 = pcall(require, 'shared/utils/warp/warp_item_database')
        add_to_chat(167, '  WarpItemDB: ' .. (test1 and '✓ OK' or ('✗ ' .. tostring(res1))))

        local test2, res2 = pcall(require, 'shared/utils/messages/message_warp')
        add_to_chat(167, '  MessageWarp: ' .. (test2 and '✓ OK' or ('✗ ' .. tostring(res2))))

        local test3, res3 = pcall(require, 'shared/utils/warp/warp_equipment')
        add_to_chat(167, '  WarpEquipment: ' .. (test3 and '✓ OK' or ('✗ ' .. tostring(res3))))

        add_to_chat(167, '========================================')

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
        add_to_chat(167, '[DEBUG] Player data not available')
        return false
    end

    add_to_chat(159, '========================================')
    add_to_chat(159, '[DEBUG] Subjob Information')
    add_to_chat(159, '========================================')

    -- Job information
    add_to_chat(121, 'Main Job: ' .. tostring(player.main_job or "NIL"))
    add_to_chat(121, 'Main Job Level: ' .. tostring(player.main_job_level or "NIL"))
    add_to_chat(121, 'Sub Job: ' .. tostring(player.sub_job or "NIL"))
    add_to_chat(121, 'Sub Job Level: ' .. tostring(player.sub_job_level or "NIL"))

    -- Zone information
    local info = windower.ffxi.get_info()
    if info then
        add_to_chat(121, ' ')
        add_to_chat(121, 'Zone ID: ' .. tostring(info.zone or "NIL"))

        -- Try to get zone name from resources
        local res_success, res = pcall(require, 'resources')
        if res_success and res and res.zones and res.zones[info.zone] then
            add_to_chat(121, 'Zone Name: ' .. tostring(res.zones[info.zone].en or "Unknown"))
        else
            add_to_chat(121, 'Zone Name: Unknown (resources not loaded)')
        end
    else
        add_to_chat(121, ' ')
        add_to_chat(121, 'Zone Info: Not available')
    end

    add_to_chat(159, '========================================')
    add_to_chat(121, ' ')
    add_to_chat(121, 'TEST INSTRUCTIONS:')
    add_to_chat(121, '1. Use this command OUTSIDE Odyssey')
    add_to_chat(121, '2. Note your Sub Job Level (should be 1-49)')
    add_to_chat(121, '3. Enter Odyssey Sheol Gaol')
    add_to_chat(121, '4. Use command again in Odyssey')
    add_to_chat(121, '5. Check if Sub Job Level = 0 (subjob disabled)')
    add_to_chat(159, '========================================')

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
        add_to_chat(167, '[JA_MSG] ERROR: Config file not found')
        add_to_chat(167, 'Path: shared/config/JA_MESSAGES_CONFIG.lua')
        return false
    end

    -- Show current mode if no argument
    if not mode_arg then
        add_to_chat(159, '========================================')
        add_to_chat(159, '[JA_MSG] Current Display Mode')
        add_to_chat(159, '========================================')
        add_to_chat(121, 'Mode: ' .. JAConfig.display_mode)
        add_to_chat(121, ' ')
        add_to_chat(121, 'Available modes:')
        add_to_chat(121, '  full   - Show name + description')
        add_to_chat(121, '  on     - Show name only')
        add_to_chat(121, '  off    - Disable all messages')
        add_to_chat(121, ' ')
        add_to_chat(121, 'Usage: //gs c jamsg <full|on|off>')
        add_to_chat(159, '========================================')
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
        add_to_chat(167, '[JA_MSG] Invalid mode: ' .. mode_arg)
        add_to_chat(121, 'Valid modes: full, on, off')
        return false
    end

    -- Set new mode
    if JAConfig.set_display_mode(new_mode) then
        add_to_chat(158, '[JA_MSG] Display mode changed to: ' .. new_mode)

        -- Show example
        add_to_chat(121, ' ')
        add_to_chat(121, 'Example output:')

        if new_mode == 'full' then
            add_to_chat(121, '  [DNC/SAM] Haste Samba activated! Attack speed +10%')
        elseif new_mode == 'on' then
            add_to_chat(121, '  [DNC/SAM] Haste Samba activated!')
        else
            add_to_chat(121, '  (no message displayed)')
        end

        return true
    else
        add_to_chat(167, '[JA_MSG] Failed to set display mode')
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
        add_to_chat(167, '[SPELL_MSG] ERROR: Config file not found')
        add_to_chat(167, 'Path: shared/config/ENHANCING_MESSAGES_CONFIG.lua')
        return false
    end

    -- Show current mode if no argument
    if not mode_arg then
        add_to_chat(159, '========================================')
        add_to_chat(159, '[SPELL_MSG] Current Display Mode')
        add_to_chat(159, '========================================')
        add_to_chat(121, 'Mode: ' .. SpellConfig.display_mode)
        add_to_chat(121, ' ')
        add_to_chat(121, 'Available modes:')
        add_to_chat(121, '  full   - Show name + description')
        add_to_chat(121, '  on     - Show name only')
        add_to_chat(121, '  off    - Disable all messages')
        add_to_chat(121, ' ')
        add_to_chat(121, 'Note: Controls ALL spell types (Enhancing,')
        add_to_chat(121, '      Dark, Elemental, Healing, Divine, BRD,')
        add_to_chat(121, '      GEO, BLU, SMN, etc.) EXCEPT Enfeebling')
        add_to_chat(121, ' ')
        add_to_chat(121, 'Usage: //gs c spellmsg <full|on|off>')
        add_to_chat(159, '========================================')
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
        add_to_chat(167, '[SPELL_MSG] Invalid mode: ' .. mode_arg)
        add_to_chat(121, 'Valid modes: full, on, off')
        return false
    end

    -- Set new mode
    if SpellConfig.set_display_mode(new_mode) then
        add_to_chat(158, '[SPELL_MSG] Display mode changed to: ' .. new_mode)

        -- Show example
        add_to_chat(121, ' ')
        add_to_chat(121, 'Example output:')

        if new_mode == 'full' then
            add_to_chat(121, '  [GEO] Aspir -> Absorbs MP (no undead).')
            add_to_chat(121, '  [BLM] Fire III -> Deals fire damage.')
        elseif new_mode == 'on' then
            add_to_chat(121, '  [GEO] Aspir')
            add_to_chat(121, '  [BLM] Fire III')
        else
            add_to_chat(121, '  (no message displayed)')
        end

        return true
    else
        add_to_chat(167, '[SPELL_MSG] Failed to set display mode')
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
        local status = _G.WARP_DEBUG and 'ENABLED' or 'DISABLED'
        add_to_chat(158, '[Warp] Debug mode: ' .. status)
        return true
    elseif cmd == 'jamsg' then
        return CommonCommands.handle_jamsg(args[1])
    elseif cmd == 'spellmsg' then
        return CommonCommands.handle_spellmsg(args[1])
    elseif cmd == 'info' then
        return CommonCommands.handle_info(args)
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
       cmd == 'spellmsg' or cmd == 'info' then
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

return CommonCommands

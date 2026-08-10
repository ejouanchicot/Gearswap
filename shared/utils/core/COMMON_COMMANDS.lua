-- CommonCommands: universal command handler shared across all 15 jobs.
local CommonCommands = {}

local MessageCommands  = require('shared/utils/messages/formatters/ui/message_commands')
local MessageFormatter = require('shared/utils/messages/message_formatter')
local MessageRenderer  = require('shared/utils/messages/core/message_renderer')

-- Warp shortcut list (single source of truth in warp_command_registry).
local WARP_COMMANDS = require('shared/utils/warp/warp_command_registry').COMMANDS

-- Alt commands are consulted on every unrecognised command, and `gs c update`
-- (sent by AutoMove on each move) is one of those - so resolve the module once
-- instead of pcall(require) per call. `false` means "tried and failed".
local AltCommandsModule = nil
local function alt_commands()
    if AltCommandsModule == nil then
        local ok, mod = pcall(require, 'shared/utils/dualbox/alt_commands')
        AltCommandsModule = (ok and mod) or false
    end
    return AltCommandsModule or nil
end

-- RELOAD COMMAND

--- Handle job reload command
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

-- JUMP COMMAND (SUB DRG)

--- Handle jump command for DRG subjob
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

-- WALTZ COMMANDS (DNC MAIN/SUB)

--- Generic waltz handler (eliminates duplication between curing/divine)
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
function CommonCommands.handle_waltz()
    return handle_waltz_generic('curing', "Waltz requires DNC main or subjob")
end

--- Handle divine waltz command (AoE healing)
function CommonCommands.handle_aoewaltz()
    return handle_waltz_generic('divine', "Divine Waltz requires DNC main or subjob")
end

-- MOUNT COMMAND (ALL JOBS)

--- Handle mount toggle command (dismount if riding, else random owned mount)
--- @return boolean Success status
function CommonCommands.handle_mount()
    local mount_success, MountManager = pcall(require, 'shared/utils/mount/mount_manager')
    if not mount_success or not MountManager then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load mount manager")
        return false
    end

    return MountManager.toggle()
end

-- CHECKSETS COMMAND

--- Handle equipment check command
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

-- WARDROBE AUDIT COMMAND

--- Handle wardrobe audit command (scan all jobs, find unused wardrobe items)
function CommonCommands.handle_wardrobeaudit()
    local audit_success, WardrobeAuditor = pcall(require, 'shared/utils/equipment/wardrobe_auditor')
    if audit_success and WardrobeAuditor then
        WardrobeAuditor.audit()
        return true
    else
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load wardrobe auditor: " .. tostring(WardrobeAuditor))
        return false
    end
end

-- WARDROBE ORGANIZE COMMAND

--- Reorganize wardrobes. Modes:
---   `//gs c wo`                  - per-active-job: move job's items to W1/W2
---   `//gs c wo preview`          - dry-run of per-job mode
---   `//gs c wo global`           - cross-job freq-based static layout
---   `//gs c wo global preview`   - dry-run of global mode
---   `//gs c wo verify`           - check current layout matches the plan
--- W7 (craft) and W8 (reserve) are always protected.
function CommonCommands.handle_wardrobeorganize(arg, arg2)
    local ok, WardrobeOrganizer = pcall(require, 'shared/utils/wardrobe/wardrobe_organizer')
    if not ok or not WardrobeOrganizer then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load wardrobe organizer: " .. tostring(WardrobeOrganizer))
        return false
    end
    if arg == 'scan' or arg == 'scanwarp' then
        -- Record which warp items this character owns, and write the list.
        if WardrobeOrganizer.scan_warp_items then
            WardrobeOrganizer.scan_warp_items()
        end
    elseif arg == 'keep' or arg == 'kept' or arg == 'items' then
        -- What survives overflow beyond what the sets name. Reads only.
        if WardrobeOrganizer.show_kept then
            WardrobeOrganizer.show_kept()
        end
    elseif arg == 'verify' or arg == 'check' then
        WardrobeOrganizer.verify_global()
    elseif arg == 'reset' then
        if WardrobeOrganizer.reset then WardrobeOrganizer.reset() end
    elseif arg == 'recover' or arg == 'unlock' then
        if WardrobeOrganizer.recover then WardrobeOrganizer.recover() end
    elseif arg == 'alt' or arg == 'kaories' then
        -- Alt-character mode: 4 wardrobes + Sack/Case, scans ALL jobs in sets/
        if WardrobeOrganizer.organize_alt then
            WardrobeOrganizer.organize_alt()
        else
            local MessageFormatter = require('shared/utils/messages/message_formatter')
            MessageFormatter.show_error("organize_alt not available in this version.")
        end
    elseif arg == 'global' then
        if arg2 == 'preview' or arg2 == 'dry' then
            WardrobeOrganizer.preview_global()
        else
            WardrobeOrganizer.organize_global()
        end
    elseif arg == 'preview' or arg == 'dry' then
        WardrobeOrganizer.preview()
    else
        WardrobeOrganizer.organize()
    end
    return true
end

-- REFILL COMMAND

--- Handle inventory refill command (pull consumables from Case/Sack).
--- Also broadcasts via DualBoxSyncIPC so the paired character refills its
--- own consumables in parallel (each instance reads its own Case/Sack).
function CommonCommands.handle_refill()
    local refill_success, RefillManager = pcall(require, 'shared/utils/inventory/refill_manager')
    if not refill_success or not RefillManager then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Failed to load refill manager: " .. tostring(RefillManager))
        return false
    end

    RefillManager.refill()

    -- Mirror to paired instance (no-op when solo).
    pcall(function()
        local SyncIPC = require('shared/utils/dualbox/dualbox_sync_ipc')
        SyncIPC.broadcast('rf')
    end)
    return true
end

-- AUTO MEDICINE COMMAND

--- Toggle automatic use of debuff cure items (Echo Drops / Remedy).
--- Off keeps the debuff block in place, it only stops consuming items - which
--- is what you want against unremovable debuff auras.
--- @param arg string|nil Optional explicit value ('on' / 'off')
--- @return boolean Success status
function CommonCommands.handle_automedicine(arg)
    local ok, AutoMedicine = pcall(require, 'shared/utils/debuff/auto_medicine')
    if not ok or not AutoMedicine then
        MessageFormatter.show_error("Failed to load auto medicine module: " .. tostring(AutoMedicine))
        return false
    end
    return AutoMedicine.handle_command(arg)
end

-- ALT COMMANDS (dual-box: drive the alt from the main)

--- Run a command defined in the alt's per-job config, or list them.
--- `//gs c altcmds` lists what the alt's current job offers.
--- `//gs c alt <name>` is the explicit form; bare `//gs c <name>` also works
--- for any name that does not collide with an existing command.
--- @param cmd string Command name
--- @param args table Arguments after the command
--- @return boolean Success status
function CommonCommands.handle_alt_command(cmd, args)
    local AltCommands = alt_commands()
    if not AltCommands then
        MessageFormatter.show_error("Failed to load alt commands module.")
        return false
    end
    return AltCommands.handle(cmd, args)
end

-- CRAFT / FISH COMMANDS - extracted to CRAFT_COMMANDS.lua, re-exposed here.
local CraftCommands = require('shared/utils/craft/craft_commands')
CommonCommands.handle_craft   = CraftCommands.handle_craft
CommonCommands.handle_fish    = CraftCommands.handle_fish
CommonCommands.handle_uncraft = CraftCommands.handle_uncraft

-- TESTCOLORS COMMAND

--- Display all FFXI color codes (001-509) to find which ones work
--- Uses dual-prefix system: 0x1F (codes 1-255), 0x1E (codes 256-509)
--- Filters out problematic codes that corrupt chat output
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

-- NAKED COMMAND (Strip all equipment)

--- Strip all equipment slots (//gs c naked or //gs c equip naked)
function CommonCommands.handle_naked()
    local all_slots = {
        'main', 'sub', 'range', 'ammo',
        'head', 'neck', 'ear1', 'ear2',
        'body', 'hands', 'ring1', 'ring2',
        'back', 'waist', 'legs', 'feet'
    }
    local naked_set = {}
    for _, slot in ipairs(all_slots) do
        naked_set[slot] = empty
    end
    equip(naked_set)
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    MessageFormatter.show_info('All slots cleared.')
    return true
end

-- LOCKSTYLE COMMAND

--- Handle lockstyle reapply command (useful after dressup reload).
--- Also broadcasts to other Windower instances via DualBoxSyncIPC so the
--- paired character (e.g. Kaories when Tetsouo runs //gs c ls) re-applies
--- ITS OWN lockstyle. Each instance runs its local select_default_lockstyle,
--- so no gear/lockstyle data is shared across the wire - only the trigger.
function CommonCommands.handle_lockstyle()
    if not select_default_lockstyle then
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_error("Lockstyle function not available")
        return false
    end

    MessageCommands.show_lockstyle_reapplying()
    select_default_lockstyle()

    -- Mirror to paired instance (no-op when solo: harmless if no listener).
    -- pcall: IPC is best-effort, never let it break the local lockstyle path.
    pcall(function()
        local SyncIPC = require('shared/utils/dualbox/dualbox_sync_ipc')
        SyncIPC.broadcast('ls')
    end)
    return true
end

-- DRESSUP TOGGLE COMMAND (Persistent)

--- Toggle DressUp management on/off (persistent across reloads)
--- When OFF: lockstyle commands won't try to unload/reload DressUp addon
--- Useful for players who don't have DressUp installed
--- Usage: //gs c dressup
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

-- PERFORMANCE PROFILER COMMAND

--- Handle performance profiler commands
--- Usage: //gs c perf [start|stop|status]
-- Diagnostic / debug-toggle handlers extracted to DEBUG_COMMANDS.lua.
-- Aliases preserve the existing CommonCommands.handle_X public surface.
local DebugCommands = require('shared/utils/core/DEBUG_COMMANDS')
CommonCommands.handle_perf        = DebugCommands.handle_perf
CommonCommands.handle_fulltest    = DebugCommands.handle_fulltest
CommonCommands.handle_syscheck    = DebugCommands.handle_syscheck
CommonCommands.handle_lagdebug    = DebugCommands.handle_lagdebug
CommonCommands.handle_debugsubjob = DebugCommands.handle_debugsubjob
CommonCommands.handle_jamsg       = DebugCommands.handle_jamsg
CommonCommands.handle_spellmsg    = DebugCommands.handle_spellmsg
CommonCommands.handle_wsmsg       = DebugCommands.handle_wsmsg
CommonCommands.handle_info        = DebugCommands.handle_info
CommonCommands.handle_debugstate  = DebugCommands.handle_debugstate

CommonCommands.handle_memcheck    = DebugCommands.handle_memcheck

-- WARP COMMANDS (Universal Warp/Teleport System)

--- Handle warp system commands (delegated to WarpCommands module)
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

-- (handle_debugsubjob, handle_jamsg, handle_spellmsg, handle_wsmsg, handle_info
--  moved to DEBUG_COMMANDS.lua and re-exposed via aliases above.)

-- MAIN COMMAND ROUTER

--- Handle common commands (centralized for all jobs)
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
    if cmd == 'naked' then
        return CommonCommands.handle_naked()
    elseif cmd == 'equip' and args[1] and args[1]:lower() == 'naked' then
        return CommonCommands.handle_naked()
    elseif cmd == 'mount' then
        return CommonCommands.handle_mount()
    elseif cmd == 'reload' then
        return CommonCommands.handle_reload(job_name)
    elseif cmd == 'checksets' then
        return CommonCommands.handle_checksets(job_name)
    elseif cmd == 'wardrobeaudit' or cmd == 'wa' then
        return CommonCommands.handle_wardrobeaudit()
    elseif cmd == 'worganize' or cmd == 'wo' then
        return CommonCommands.handle_wardrobeorganize(args[1], args[2])
    elseif cmd == 'refill' or cmd == 'rf' then
        return CommonCommands.handle_refill()
    elseif cmd == 'automedicine' or cmd == 'am' then
        return CommonCommands.handle_automedicine(args[1])
    elseif cmd == 'alt' or cmd == 'altcmds' or cmd == 'altlist' then
        return CommonCommands.handle_alt_command(cmd, args)
    elseif cmd == 'altbuff' then
        -- Sent by the ALT when a tracked buff goes up or down.
        local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if ok and AltBuffReporter then
            AltBuffReporter.receive(args)
        end
        return true
    elseif cmd == 'altbuffsync' then
        -- Sent BY the main TO the alt: resend every tracked buff.
        local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if ok and AltBuffReporter then
            AltBuffReporter.report_all()
        end
        return true
    elseif cmd == 'altsync' then
        -- Run on the main: ask the alt to resend its buff state.
        local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if ok and AltBuffReporter and AltBuffReporter.request_sync() then
            MessageFormatter.show_debug('ALTBUFF', 'Asked the alt to resync its buffs.')
        else
            MessageFormatter.show_error('Alt sync needs dual-boxing enabled as main.')
        end
        return true
    elseif cmd == 'altbuffs' then
        -- Diagnostic: what the main currently believes about the alt's buffs.
        local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if ok and AltBuffReporter then
            AltBuffReporter.show_state()
        end
        return true
    elseif cmd == 'altdebug' then
        -- Trace buff reporting on whichever character you run it on.
        local ok, AltBuffReporter = pcall(require, 'shared/utils/dualbox/alt_buff_reporter')
        if ok and AltBuffReporter then
            local on, path = AltBuffReporter.toggle_debug()
            MessageFormatter.show_debug('ALTBUFF', 'Tracing ' .. (on and 'ON' or 'OFF'))
            if on then
                MessageFormatter.show_debug('ALTBUFF', 'Log: ' .. path)
            end
        end
        return true
    elseif cmd == 'craft' then
        return CommonCommands.handle_craft(args[1])
    elseif cmd == 'fish' or cmd == 'fishing' then
        return CommonCommands.handle_fish(args[1])
    elseif cmd == 'uncraft' then
        return CommonCommands.handle_uncraft()
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
        MessageFormatter.show_debug('AutoMove', 'Debug mode: ' .. (_G.AUTOMOVE_DEBUG and 'ON' or 'OFF'))
        return true
    elseif cmd == 'debugjobchange' or cmd == 'djc' then
        -- Toggle job change debug mode
        _G.JOBCHANGE_DEBUG = not _G.JOBCHANGE_DEBUG
        MessageFormatter.show_debug('JobChange', 'Debug mode: ' .. (_G.JOBCHANGE_DEBUG and 'ON' or 'OFF'))
        -- Show current state
        if _G.JOBCHANGE_DEBUG and _G.JobChangeManagerSTATE then
            local S = _G.JobChangeManagerSTATE
            MessageFormatter.show_debug('JobChange', string.format('counter=%d, current=%s/%s, target=%s/%s',
                S.debounce_counter or 0,
                tostring(S.current_main_job), tostring(S.current_sub_job),
                tostring(S.target_main_job), tostring(S.target_sub_job)))
        end
        return true
    elseif cmd == 'debugstate' or cmd == 'ds' then
        return CommonCommands.handle_debugstate()
    elseif cmd == 'debugupdate' or cmd == 'du' then
        -- Toggle UPDATE debug mode (traces full gs c update flow)
        -- Use windower table for persistence across job changes
        windower._gs_debug = windower._gs_debug or {}
        windower._gs_debug.UPDATE = not windower._gs_debug.UPDATE
        _G.UPDATE_DEBUG = windower._gs_debug.UPDATE
        _G.AUTOMOVE_DEBUG = windower._gs_debug.UPDATE  -- Also enable AutoMove debug
        MessageFormatter.show_debug('UPDATE', string.format('%s (traces: AutoMove > job_update > UI.update > customize_set)',
            _G.UPDATE_DEBUG and 'ON' or 'OFF'))
        return true
    elseif cmd == 'fulltest' or cmd == 'ft' then
        return CommonCommands.handle_fulltest(args[1])
    elseif cmd == 'syscheck' or cmd == 'sc' then
        return CommonCommands.handle_syscheck(args[1])
    elseif cmd == 'lagdebug' or cmd == 'ldb' then
        return CommonCommands.handle_lagdebug(args[1])
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
            MessageFormatter.show_debug('MSG', 'MESSAGE_SETTINGS:')
            MessageFormatter.show_debug('MSG', '  spell_mode: ' .. tostring(_G.MESSAGE_SETTINGS.spell_mode or 'nil'))
            MessageFormatter.show_debug('MSG', '  ja_mode: '    .. tostring(_G.MESSAGE_SETTINGS.ja_mode    or 'nil'))
            MessageFormatter.show_debug('MSG', '  ws_mode: '    .. tostring(_G.MESSAGE_SETTINGS.ws_mode    or 'nil'))
        else
            MessageFormatter.show_error('MSG', 'MESSAGE_SETTINGS is nil!')
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
    elseif cmd == 'memcheck' or cmd == 'mem' then
        return CommonCommands.handle_memcheck(args[1])
    elseif cmd == 'commands' or cmd == 'cmds' then
        -- Show list of all common commands
        MessageCommands.show_commands_list()
        return true
    elseif cmd == 'help' or cmd == '?' then
        -- Show quick help (redirects to main commands)
        MessageCommands.show_help()
        return true
    end

    -- Alt commands are checked last so a native command always wins the name.
    local AltCommands = alt_commands()
    if AltCommands and AltCommands.is_alt_command(cmd) then
        return AltCommands.execute(cmd, args)
    end

    return false
end

-- HELPER FUNCTIONS

--- Check if command is a common command
function CommonCommands.is_common_command(command)
    if not command then
        return false
    end

    local cmd = command:lower()

    -- Check existing common commands
    if cmd == 'mount' or
        cmd == 'naked' or cmd == 'equip' or cmd == 'reload' or cmd == 'checksets' or cmd == 'wardrobeaudit' or cmd == 'wa' or cmd == 'worganize' or cmd == 'wo' or cmd == 'refill' or cmd == 'rf' or cmd == 'craft' or cmd == 'uncraft' or cmd == 'fish' or cmd == 'fishing' or
        cmd == 'automedicine' or cmd == 'am' or
        cmd == 'alt' or cmd == 'altcmds' or cmd == 'altlist' or
        cmd == 'altbuff' or cmd == 'altbuffs' or cmd == 'altdebug' or
        cmd == 'altsync' or cmd == 'altbuffsync' or
        cmd == 'lockstyle' or cmd == 'ls' or cmd == 'dressup' or
        cmd == 'perf' or cmd == 'testcolors' or cmd == 'colors' or cmd == 'jump' or cmd == 'waltz' or
        cmd == 'aoewaltz' or cmd == 'debugsubjob' or cmd == 'dsj' or cmd == 'debugwarp' or cmd == 'debugprecast' or
        cmd == 'automovedebug' or cmd == 'amd' or cmd == 'debugjobchange' or cmd == 'djc' or
        cmd == 'debugstate' or cmd == 'ds' or cmd == 'debugupdate' or cmd == 'du' or
        cmd == 'fulltest' or cmd == 'ft' or
        cmd == 'syscheck' or cmd == 'sc' or
        cmd == 'lagdebug' or cmd == 'ldb' or
        cmd == 'jamsg' or cmd == 'spellmsg' or cmd == 'wsmsg' or cmd == 'info' or cmd == 'debugmsg' or
        cmd == 'testmsg' or cmd == 'msgtest' or cmd == 'msgtests' or
        cmd == 'memcheck' or cmd == 'mem' or
        cmd == 'commands' or cmd == 'cmds' or cmd == 'help' or cmd == '?' then
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

    -- Alt commands last: every name above already won, so a config entry can
    -- never shadow a built-in command.
    local AltCommands = alt_commands()
    if AltCommands and AltCommands.is_alt_command(cmd) then
        return true
    end

    return false
end

return CommonCommands
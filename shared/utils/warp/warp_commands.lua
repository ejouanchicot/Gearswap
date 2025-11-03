---============================================================================
--- Warp Commands - REFACTORED (Uses Modular System)
---============================================================================
--- Command router for warp system. Now uses modular architecture:
---   - casting/spell_caster.lua - Spell casting logic
---   - casting/item_user.lua - Ring usage with auto-fix
---   - casting/cast_helpers.lua - Shared helpers
---   - database/warp_database_core.lua - Item database
---
--- @file warp_commands.lua
--- @author Tetsouo
--- @version 4.0 - Modular Architecture
--- @date 2025-10-28
---============================================================================

-- Load modular systems
local SpellCaster = require('shared/utils/warp/casting/spell_caster')
local ItemUser = require('shared/utils/warp/casting/item_user')
local WarpDatabase = require('shared/utils/warp/warp_item_database')
local MessageWarp = require('shared/utils/messages/message_warp')
local MessageCore = require('shared/utils/messages/message_core')

local WarpCommands = {}

-- Debounce protection against double command execution
local last_command_time = 0
local last_command_text = ""
local DEBOUNCE_THRESHOLD = 0.5  -- 500ms

---============================================================================
--- SYSTEM COMMANDS (Status, Unlock, Test, etc.)
---============================================================================

local function command_status()
    local WarpEquipment = require('shared/utils/warp/warp_equipment')
    local WarpInit = require('shared/utils/warp/warp_init')

    MessageWarp.show_status_header()
    MessageWarp.show_status_line('Initialized', WarpInit.is_initialized())
    MessageWarp.show_status_line('Equipment Locked', WarpEquipment.is_locked())

    local warp_type = WarpEquipment.get_warp_type()
    if warp_type then
        MessageWarp.show_status_line('Current Warp Type', warp_type)
    end

    if player then
        local has_blm = player.main_job == 'BLM' or player.sub_job == 'BLM'
        local has_whm = player.main_job == 'WHM' or player.sub_job == 'WHM'
        local job_text = has_blm and 'Yes (BLM)' or has_whm and 'Yes (WHM)' or 'No'
        MessageWarp.show_status_line('Can cast warp spells', job_text)
    end

    -- Show total items
    local total_items = WarpDatabase.count_total_items()
    MessageWarp.show_status_line('Database Items', total_items)
end

local function command_unlock()
    local WarpEquipment = require('shared/utils/warp/warp_equipment')

    if not WarpEquipment.is_locked() then
        MessageCore.error('[WARP] Equipment is not locked')
        return
    end

    MessageWarp.show_force_unlock()
    WarpEquipment.force_unlock()
end

local function command_fix()
    MessageWarp.show_fix_ring_start()
    enable('ring1')
    send_command('gs enable ring1')

    coroutine.schedule(function()
        if player then
            local set_to_equip = (player.status == 'Engaged') and 'sets.engaged' or 'sets.idle'
            windower.send_command('gs equip ' .. set_to_equip)
            MessageWarp.show_fix_ring_complete()
        end
    end, 1)
end

local function command_lock()
    local WarpEquipment = require('shared/utils/warp/warp_equipment')

    if WarpEquipment.is_locked() then
        MessageCore.error('[WARP] Equipment is already locked')
        return
    end

    MessageWarp.show_manual_lock()
    WarpEquipment.lock('manual', 10)
end

local function command_test()
    local WarpDetector = require('shared/utils/warp/warp_detector')

    MessageWarp.show_test_header()

    local warp_spells = WarpDetector.get_warp_spells()
    MessageWarp.show_test_line('Detected Warp Spells', #warp_spells)

    local warp_items = WarpDetector.get_warp_items()
    MessageWarp.show_test_line('Detected Warp Items', #warp_items)

    local total_db_items = WarpDatabase.count_total_items()
    MessageWarp.show_test_line('Database Total', total_db_items)
end

local function command_debugwarp()
    _G.WARP_DEBUG = not _G.WARP_DEBUG
    MessageWarp.show_debug_toggle(_G.WARP_DEBUG)
end

local function command_help()
    MessageWarp.show_help()
end

---============================================================================
--- SPELL + RING FALLBACK SYSTEM
---============================================================================

--- Cast spell with ring fallback
--- @param spell_name string Spell name
--- @param ring_names table Ring names to try as fallback
--- @return boolean True if cast or used
local function cast_with_fallback(spell_name, ring_names)
    if _G.WARP_DEBUG then
        add_to_chat(8, '[DEBUG] cast_with_fallback() called: ' .. spell_name)
    end

    -- Try spell first
    if SpellCaster.cast_spell(spell_name) then
        if _G.WARP_DEBUG then
            add_to_chat(8, '[DEBUG] Spell cast successful, returning true')
        end
        return true
    end

    if _G.WARP_DEBUG then
        add_to_chat(8, '[DEBUG] Spell failed, trying ring fallback')
    end

    -- Fallback to ring
    if ring_names then
        local result = ItemUser.use_ring(ring_names, spell_name)
        if _G.WARP_DEBUG then
            add_to_chat(8, '[DEBUG] Ring fallback result: ' .. tostring(result))
        end
        return result
    end

    return false
end

---============================================================================
--- DESTINATION ITEM USAGE
---============================================================================

--- Use item for destination
--- @param destination_key string Destination constant
--- @param destination_name string Display name
--- @return boolean True if used
local function use_warp_destination(destination_key, destination_name)
    local items = WarpDatabase.get_items_by_destination(destination_key)
    if not items or #items == 0 then
        MessageCore.error('[WARP] No items found for ' .. destination_name)
        return false
    end

    local first_item = items[1]
    if first_item then
        MessageWarp.show_using_destination(first_item.data.name, destination_name)
        send_command('input /item "' .. first_item.data.name .. '" <me>')
        return true
    end

    MessageCore.error('[WARP] No available items for ' .. destination_name)
    return false
end

---============================================================================
--- MAIN COMMAND ROUTER
---============================================================================

function WarpCommands.handle_command(cmdParams)
    if not cmdParams or #cmdParams == 0 then return false end

    local command = cmdParams[1]:lower()
    local subcommand = cmdParams[2] and cmdParams[2]:lower()

    -- Debounce: Prevent double execution of same command within 500ms
    local current_time = os.clock()
    local command_text = table.concat(cmdParams, " ")

    if command_text == last_command_text and (current_time - last_command_time) < DEBOUNCE_THRESHOLD then
        if _G.WARP_DEBUG then
            add_to_chat(8, '[DEBUG] Command debounced (duplicate within 500ms): ' .. command)
        end
        return true  -- Return true to prevent further processing
    end

    last_command_time = current_time
    last_command_text = command_text

    if _G.WARP_DEBUG then
        add_to_chat(8, '[DEBUG] WarpCommands.handle_command() executing: ' .. command)
    end

    -- SYSTEM COMMANDS (warp status, warp unlock, etc.)
    if command == 'warp' and subcommand then
        if subcommand == 'status' then command_status(); return true end
        if subcommand == 'unlock' then command_unlock(); return true end
        if subcommand == 'fix' then command_fix(); return true end
        if subcommand == 'lock' then command_lock(); return true end
        if subcommand == 'test' then command_test(); return true end
        if subcommand == 'help' then command_help(); return true end
        if subcommand == 'ipctest' then
            -- Test IPC system
            local ipc_success, WarpIPC = pcall(require, 'shared/utils/warp/warp_ipc')
            if ipc_success and WarpIPC then
                MessageWarp.show_ipc_test_sent()
                windower.send_ipc_message('tetsouo_warp_test_' .. (player and player.name or 'unknown'))
            else
                MessageCore.error('[WARP] IPC system not available')
            end
            return true
        end
    end

    -- DEBUG TOGGLE
    if command == 'debugwarp' then command_debugwarp(); return true end

    -- IPC BROADCAST: Commands ending with "all" (multi-boxing support)
    -- Examples: warpall, tphall, sdall, escall
    if command:find('all$') or (command:lower() ~= 'all' and subcommand == 'all') then
        local base_cmd = command:find('all$') and command:gsub('all$', '') or command
        local ipc_success, WarpIPC = pcall(require, 'shared/utils/warp/warp_ipc')
        if ipc_success and WarpIPC then
            return WarpIPC.send_to_all(base_cmd)
        else
            MessageCore.error('[WARP] IPC system not available')
            return false
        end
    end

    -- BLM SPELLS
    if command == 'w' or command == 'warp' then return cast_with_fallback('Warp', {'Warp Ring'}) end
    if command == 'w2' or command == 'warp2' then return cast_with_fallback('Warp II', {'Warp Ring'}) end
    if command == 'ret' or command == 'retrace' then return cast_with_fallback('Retrace', nil) end
    if command == 'esc' or command == 'escape' then return cast_with_fallback('Escape', nil) end

    -- WHM TELEPORTS
    if command == 'tph' or command == 'tpholla' then return cast_with_fallback('Teleport-Holla', {'Holla Ring', 'Dim. Ring (Holla)'}) end
    if command == 'tpd' or command == 'tpdem' then return cast_with_fallback('Teleport-Dem', {'Dem Ring', 'Dim. Ring (Dem)'}) end
    if command == 'tpm' or command == 'tpmea' then return cast_with_fallback('Teleport-Mea', {'Mea Ring', 'Dim. Ring (Mea)'}) end
    if command == 'tpa' or command == 'tpaltep' then return cast_with_fallback('Teleport-Altep', {'Altep Ring'}) end
    if command == 'tpy' or command == 'tpyhoat' then return cast_with_fallback('Teleport-Yhoat', {'Yhoat Ring'}) end
    if command == 'tpv' or command == 'tpvahzl' then return cast_with_fallback('Teleport-Vahzl', {'Vahzl Ring'}) end

    -- WHM RECALLS
    if command == 'rj' or command == 'recjugner' then return cast_with_fallback('Recall-Jugner', nil) end
    if command == 'rp' or command == 'recpashh' then return cast_with_fallback('Recall-Pashh', nil) end
    if command == 'rm' or command == 'recmeriph' then return cast_with_fallback('Recall-Meriph', nil) end

    -- DESTINATION COMMANDS (Nations)
    if command == 'sd' or command == 'sandoria' then return use_warp_destination(WarpDatabase.DESTINATIONS.SAN_DORIA, "San d'Oria") end
    if command == 'bt' or command == 'bastok' then return use_warp_destination(WarpDatabase.DESTINATIONS.BASTOK, "Bastok") end
    if command == 'wd' or command == 'windurst' then return use_warp_destination(WarpDatabase.DESTINATIONS.WINDURST, "Windurst") end

    -- DESTINATION COMMANDS (Jeuno)
    if command == 'jn' or command == 'jeuno' then return use_warp_destination(WarpDatabase.DESTINATIONS.JEUNO, "Jeuno") end

    -- DESTINATION COMMANDS (Outpost Cities)
    if command == 'sb' or command == 'selbina' then return use_warp_destination(WarpDatabase.DESTINATIONS.SELBINA, "Selbina") end
    if command == 'mh' or command == 'mhaura' then return use_warp_destination(WarpDatabase.DESTINATIONS.MHAURA, "Mhaura") end
    if command == 'rb' or command == 'rabao' then return use_warp_destination(WarpDatabase.DESTINATIONS.RABAO, "Rabao") end
    if command == 'kz' or command == 'kazham' then return use_warp_destination(WarpDatabase.DESTINATIONS.KAZHAM, "Kazham") end
    if command == 'ng' or command == 'norg' then return use_warp_destination(WarpDatabase.DESTINATIONS.NORG, "Norg") end

    -- DESTINATION COMMANDS (Expansion Cities)
    if command == 'tv' or command == 'tavnazia' then return use_warp_destination(WarpDatabase.DESTINATIONS.TAVNAZIA, "Tavnazian Safehold") end
    if command == 'au' or command == 'wg' or command == 'whitegate' then return use_warp_destination(WarpDatabase.DESTINATIONS.WHITEGATE, "Aht Urhgan Whitegate") end
    if command == 'ns' or command == 'nashmau' then return use_warp_destination(WarpDatabase.DESTINATIONS.NASHMAU, "Nashmau") end
    if command == 'ad' or command == 'adoulin' then return use_warp_destination(WarpDatabase.DESTINATIONS.ADOULIN, "Adoulin") end

    -- DESTINATION COMMANDS (Chocobo Stables)
    if command == 'stsd' or command == 'stable-sd' then return use_warp_destination(WarpDatabase.DESTINATIONS.STABLE_SANDORIA, "San d'Oria Chocobo Stables") end
    if command == 'stbt' or command == 'stable-bt' then return use_warp_destination(WarpDatabase.DESTINATIONS.STABLE_BASTOK, "Bastok Chocobo Stables") end
    if command == 'stwd' or command == 'stable-wd' then return use_warp_destination(WarpDatabase.DESTINATIONS.STABLE_WINDURST, "Windurst Chocobo Stables") end
    if command == 'stjn' or command == 'stable-jn' then return use_warp_destination(WarpDatabase.DESTINATIONS.STABLE_JEUNO, "Jeuno Chocobo Stables") end

    -- DESTINATION COMMANDS (Conquest Outpost)
    if command == 'op' or command == 'outpost' then return use_warp_destination(WarpDatabase.DESTINATIONS.CONQUEST_OUTPOST, "Conquest Outpost") end

    -- DESTINATION COMMANDS (Adoulin Frontier)
    if command == 'cz' or command == 'ceizak' then return use_warp_destination(WarpDatabase.DESTINATIONS.CEIZAK, "Ceizak Battlegrounds") end
    if command == 'ys' or command == 'yahse' then return use_warp_destination(WarpDatabase.DESTINATIONS.YAHSE, "Yahse Hunting Grounds") end
    if command == 'hn' or command == 'hennetiel' then return use_warp_destination(WarpDatabase.DESTINATIONS.HENNETIEL, "Foret de Hennetiel") end
    if command == 'mm' or command == 'morimar' then return use_warp_destination(WarpDatabase.DESTINATIONS.MORIMAR, "Morimar Basalt Fields") end
    if command == 'mj' or command == 'marjami' then return use_warp_destination(WarpDatabase.DESTINATIONS.MARJAMI, "Marjami Ravine") end
    if command == 'yc' or command == 'yorcia' then return use_warp_destination(WarpDatabase.DESTINATIONS.YORCIA, "Yorcia Weald") end
    if command == 'km' or command == 'kamihr' then return use_warp_destination(WarpDatabase.DESTINATIONS.KAMIHR, "Kamihr Drifts") end

    -- DESTINATION COMMANDS (Special Locations)
    if command == 'wj' or command == 'wajaom' then return use_warp_destination(WarpDatabase.DESTINATIONS.WAJAOM, "Wajaom Woodlands") end
    if command == 'ar' or command == 'arrapago' then return use_warp_destination(WarpDatabase.DESTINATIONS.ARRAPAGO, "Arrapago Reef") end
    if command == 'pg' or command == 'purgonorgo' then return use_warp_destination(WarpDatabase.DESTINATIONS.PURGONORGO, "Purgonorgo Isle") end
    if command == 'rl' or command == 'rulude' then return use_warp_destination(WarpDatabase.DESTINATIONS.RULUDE, "Ru'Lude Gardens") end
    if command == 'zv' or command == 'zvahl' then return use_warp_destination(WarpDatabase.DESTINATIONS.ZVAHL, "Castle Zvahl Keep") end
    if command == 'riv' or command == 'riverne' then return use_warp_destination(WarpDatabase.DESTINATIONS.RIVERNE, "Riverne Site #A01") end
    if command == 'yo' or command == 'yoran' then return use_warp_destination(WarpDatabase.DESTINATIONS.YORAN, "Yoran-Oran's Manor") end
    if command == 'lf' or command == 'leafallia' then return use_warp_destination(WarpDatabase.DESTINATIONS.LEAFALLIA, "Leafallia") end
    if command == 'bh' or command == 'behemoth' then return use_warp_destination(WarpDatabase.DESTINATIONS.BEHEMOTH, "Behemoth's Dominion") end
    if command == 'cc' or command == 'chocircuit' then return use_warp_destination(WarpDatabase.DESTINATIONS.CHOCOBO_CIRCUIT, "Chocobo Circuit") end
    if command == 'pt' or command == 'parting' then return use_warp_destination(WarpDatabase.DESTINATIONS.PARTING, "Place of Parting") end
    if command == 'cg' or command == 'chocogirl' then return use_warp_destination(WarpDatabase.DESTINATIONS.CHOCOGIRL, "Chocogirl (Home Nation)") end

    -- DESTINATION COMMANDS (Unique Mechanics)
    if command == 'ld' or command == 'leader' then return use_warp_destination(WarpDatabase.DESTINATIONS.PARTY_LEADER, "Party Leader Location") end
    if command == 'td' or command == 'tidal' then return use_warp_destination(WarpDatabase.DESTINATIONS.TIDAL, "Tidal Routes") end

    return false
end

---============================================================================
--- MODULE EXPORT
---============================================================================

function WarpCommands.register()
    local success, CommonCommands = pcall(require, 'utils/core/COMMON_COMMANDS')
    if success and CommonCommands then
        MessageWarp.show_registered_common()
    end
end

return WarpCommands

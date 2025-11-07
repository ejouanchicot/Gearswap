---============================================================================
--- PUP Commands Module - Command Handling
---============================================================================
--- Handles job-specific commands for Beastmaster:
---   • ecosystem - Cycle through 7 ecosystems
---   • species - Cycle through species for current ecosystem
---   • broth - Display broth counts in inventory
---   • pet engage - Manually engage pet
---   • pet disengage - Manually disengage pet
---   • rdylist - List all available Ready Moves with index numbers
---   • rdymove [1-6] - Execute Ready Move by index
---
--- Uses centralized MessageFormatter for all messages (professional multi-color).
---
--- @file jobs/pup/functions/PUP_COMMANDS.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-17
--- @date Updated: 2025-10-18 - Standardized all messages with MessageFormatter
---============================================================================

---============================================================================
--- DEPENDENCIES
---============================================================================

-- Message formatter
local MessageFormatter = require('shared/utils/messages/message_formatter')

-- Common commands (reload, checksets, etc.)
local success_cc, CommonCommands = pcall(require, 'shared/utils/core/COMMON_COMMANDS')
if not success_cc then
    MessageFormatter.error_pup_module_not_loaded('CommonCommands')
    CommonCommands = nil
end

-- Watchdog commands
local success_wd, WatchdogCommands = pcall(require, 'shared/utils/core/WATCHDOG_COMMANDS')
if not success_wd then
    WatchdogCommands = nil
end

-- UI commands (ui save, ui hide, etc.)
local success_ui, UICommands = pcall(require, 'shared/utils/ui/UI_COMMANDS')
if not success_ui then
    MessageFormatter.error_pup_module_not_loaded('UICommands')
    UICommands = nil
end

-- Message commands (for debug messages)
local MessageCommands = require('shared/utils/messages/formatters/ui/message_commands')

-- Ecosystem manager
local success_em, EcosystemManager = pcall(require, 'shared/jobs/pup/functions/logic/ecosystem_manager')
if not success_em then
    MessageFormatter.error_pup_module_not_loaded('EcosystemManager')
    EcosystemManager = nil
end

-- Pet manager
local success_pm, PetManager = pcall(require, 'shared/jobs/pup/functions/logic/pet_manager')
if not success_pm then
    MessageFormatter.error_pup_module_not_loaded('PetManager')
    PetManager = nil
end

---============================================================================
--- BROTH COUNT DISPLAY
---============================================================================

--- Display broth counts in inventory
--- @return void
local function display_broth_count()
    -- Load resources for item lookup
    local res = require('resources')

    -- Get player items
    local items = windower.ffxi.get_items()
    if not items or not items.inventory then
        MessageFormatter.show_error('Cannot access inventory')
        return
    end

    -- Collect broth counts
    local broth_counts = {}
    for slot = 1, items.max_inventory do
        local item = items.inventory[slot]
        if item and item.id ~= 0 then
            local item_name = res.items[item.id] and res.items[item.id].en or "Unknown"
            if item_name:find("Broth") then
                broth_counts[item_name] = (broth_counts[item_name] or 0) + item.count
            end
        end
    end

    -- Display header
    MessageFormatter.show_pup_broth_count_header()

    -- Display broth counts
    if next(broth_counts) then
        for broth_name, count in pairs(broth_counts) do
            MessageFormatter.show_pup_broth_count_line(broth_name, count)
        end
    else
        MessageFormatter.show_pup_no_broths()
    end
end

---============================================================================
--- COMMAND HOOK
---============================================================================

--- Handle job-specific commands
--- @param cmdParams table Command parameters (array of strings)
--- @param eventArgs table Event arguments (modified if command handled)
--- @return void
function job_self_command(cmdParams, eventArgs)
    if not cmdParams or #cmdParams == 0 then
        return
    end

    local command = cmdParams[1]:lower()

    ---========================================================================
    --- DUAL-BOXING: Receive alt job update
    ---========================================================================

    if command == 'altjobupdate' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        if cmdParams[2] and cmdParams[3] then
            DualBoxManager.receive_alt_job(cmdParams[2], cmdParams[3])
        end
        eventArgs.handled = true
        return
    end

    -- DUAL-BOXING: Handle job request from MAIN
    -- ==========================================================================
    if command == 'requestjob' then
        local DualBoxManager = require('shared/utils/dualbox/dualbox_manager')
        DualBoxManager.handle_job_request()
        eventArgs.handled = true
        return
    end

    ---========================================================================
    --- UI COMMANDS (ui save, ui hide, etc.)
    ---========================================================================

    if UICommands and UICommands.is_ui_command(command) then
        UICommands.handle_ui_command(cmdParams)
        eventArgs.handled = true
        return
    end

    -- ==========================================================================
    -- DEBUG COMMANDS
    -- ==========================================================================
    if command == 'debugmidcast' then
        -- Toggle MidcastManager debug mode
        local MidcastManager = require('shared/utils/midcast/midcast_manager')
        MidcastManager.toggle_debug()

        -- Confirmation message
        MessageCommands.show_debugmidcast_toggled('PUP', _G.MidcastManagerDebugState)

        eventArgs.handled = true
        return
    end


    ---========================================================================
    --- WATCHDOG COMMANDS
    ---========================================================================

    if WatchdogCommands and WatchdogCommands.is_watchdog_command(command) then
        if WatchdogCommands.handle_command(cmdParams, eventArgs) then
            eventArgs.handled = true
        end
        return
    end

    ---========================================================================
    --- COMMON COMMANDS (reload, checksets, etc.)
    ---========================================================================

    if CommonCommands and CommonCommands.is_common_command(command) then
        if CommonCommands.handle_command(command, 'PUP') then
            eventArgs.handled = true
        end
        return
    end

    ---========================================================================
    --- ECOSYSTEM COMMANDS
    ---========================================================================

    if command == 'ecosystem' then
        if EcosystemManager then
            EcosystemManager.change_ecosystem()
            eventArgs.handled = true
        else
            MessageFormatter.error_pup_module_not_loaded('EcosystemManager')
        end
        return
    end

    if command == 'species' then
        if EcosystemManager then
            EcosystemManager.change_species()
            eventArgs.handled = true
        else
            MessageFormatter.error_pup_module_not_loaded('EcosystemManager')
        end
        return
    end

    if command == 'broth' or command == 'broths' then
        display_broth_count()
        eventArgs.handled = true
        return
    end

    ---========================================================================
    --- PET COMMANDS
    ---========================================================================

    if command == 'pet' then
        if #cmdParams < 2 then
            MessageFormatter.show_info('Usage: //gs c pet [engage|disengage]')
            eventArgs.handled = true
            return
        end

        local pet_command = cmdParams[2]:lower()

        if pet_command == 'engage' then
            if PetManager then
                PetManager.engage_pet()
                eventArgs.handled = true
            else
                MessageFormatter.error_pup_module_not_loaded('PetManager')
            end
            return
        end

        if pet_command == 'disengage' then
            if PetManager then
                PetManager.disengage_pet()
                eventArgs.handled = true
            else
                MessageFormatter.error_pup_module_not_loaded('PetManager')
            end
            return
        end

        MessageFormatter.show_error('Unknown pet command: ' .. pet_command)
        eventArgs.handled = true
        return
    end

    ---========================================================================
    --- READY MOVE COMMANDS (RdyMove 1-6, RdyList)
    ---========================================================================

    if command == 'rdylist' then
        if not PetManager then
            MessageFormatter.error_pup_module_not_loaded('PetManager')
            eventArgs.handled = true
            return
        end

        -- Check if pet exists
        local pet = _G.pet
        if not pet or not pet.id or pet.id == 0 then
            MessageFormatter.error_pup_no_pet()
            eventArgs.handled = true
            return
        end

        -- Get ready moves list
        local ready_moves = PetManager.get_ready_moves()

        if not ready_moves or #ready_moves == 0 then
            MessageFormatter.error_pup_no_ready_moves()
            eventArgs.handled = true
            return
        end

        -- Display header
        MessageFormatter.show_pup_ready_moves_header(pet.name)

        -- Display moves
        for i, move in ipairs(ready_moves) do
            MessageFormatter.show_pup_ready_move_item(i, move.name)
        end

        MessageFormatter.show_pup_ready_moves_usage(#ready_moves)
        eventArgs.handled = true
        return
    end

    if command == 'rdymove' then
        if not PetManager then
            MessageFormatter.error_pup_module_not_loaded('PetManager')
            eventArgs.handled = true
            return
        end

        -- Check if index provided
        if #cmdParams < 2 then
            MessageFormatter.show_info('Usage: //gs c RdyMove [1-6]')
            eventArgs.handled = true
            return
        end

        -- Parse index
        local index = tonumber(cmdParams[2])
        if not index or index < 1 then
            MessageFormatter.error_pup_invalid_index(cmdParams[2])
            eventArgs.handled = true
            return
        end

        -- Check if pet exists
        local pet = _G.pet
        if not pet or not pet.id or pet.id == 0 then
            MessageFormatter.error_pup_no_pet()
            eventArgs.handled = true
            return
        end

        -- Get ready moves list
        local ready_moves = PetManager.get_ready_moves()
        if not ready_moves or #ready_moves == 0 then
            MessageFormatter.error_pup_no_ready_moves()
            eventArgs.handled = true
            return
        end

        -- Check if index is valid
        if index > #ready_moves then
            MessageFormatter.error_pup_index_out_of_range(index, #ready_moves)
            eventArgs.handled = true
            return
        end

        -- Get the move
        local move = ready_moves[index]
        if not move or not move.name then
            MessageFormatter.show_error('Invalid Ready Move at index ' .. index)
            eventArgs.handled = true
            return
        end

        -- Check pet and player engagement status
        local pet_engaged = (pet.status == 1 or pet.status == "Engaged")
        local player_engaged = (player and player.status == "Engaged")

        -- Capture move name in local variable for coroutine closure
        local move_name = move.name

        if pet_engaged then
            -- Pet is already fighting - just use the Ready Move
            MessageFormatter.show_pup_ready_move_use(index, move_name)
            send_command('input /pet "' .. move_name .. '" <me>')
        else
            -- Pet is idle - check if player is engaged
            if player_engaged then
                -- Player engaged + Pet idle → Fight + Ready Move (NO Heel)
                MessageFormatter.show_pup_ready_move_auto_engage(index, move_name)

                -- Step 1: Engage pet (0s delay)
                send_command('input /pet "Fight" <stnpc>')

                -- Step 2: Execute Ready Move (3.0s delay for pet to engage - increased for reliability)
                coroutine.schedule(function()
                    send_command('input /pet "' .. move_name .. '" <me>')
                end, 3.0)

                -- NO Step 3: Pet stays engaged (player is fighting)
            else
                -- Player idle + Pet idle → Fight + Ready Move + Heel
                MessageFormatter.show_pup_ready_move_auto_sequence(index, move_name)

                -- Step 1: Engage pet (0s delay)
                send_command('input /pet "Fight" <stnpc>')

                -- Step 2: Execute Ready Move (3.0s delay for pet to engage - increased for reliability)
                coroutine.schedule(function()
                    send_command('input /pet "' .. move_name .. '" <me>')
                end, 3.0)

                -- Step 3: Disengage pet (5.5s delay - 2.5s after Ready Move)
                coroutine.schedule(function()
                    send_command('input /pet "Heel" <me>')
                end, 5.5)
            end
        end

        eventArgs.handled = true
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_self_command = job_self_command

-- Export as module
return {
    job_self_command = job_self_command
}

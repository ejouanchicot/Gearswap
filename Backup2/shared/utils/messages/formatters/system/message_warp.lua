---============================================================================
--- Message Warp - Warp/Teleport System Messages (NEW SYSTEM - HYBRID)
---============================================================================
--- Provides formatted messages for warp and teleport system
--- Uses HYBRID approach:
---   - Templates for standard messages (via M.send())
---   - Direct MessageRenderer.send() for complex multi-line displays (help, status)
---   - Direct add_to_chat() for DEBUG messages with inline color codes
---
--- Migrated from old system to new system: 2025-11-06
---
--- @file utils/messages/message_warp.lua
--- @author Tetsouo
--- @version 2.0
--- @date Created: 2025-10-26 | Migrated: 2025-11-06
---============================================================================

local MessageWarp = {}

-- NEW message system
local M = require('shared/utils/messages/api/messages')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')
local MessageCore = require('shared/utils/messages/message_core')
local COLORS = MessageCore.COLORS

-- DEBUG chat channel constant (for direct add_to_chat calls)
local CHAT_DEBUG = 8

---============================================================================
--- WARP MESSAGES (Warp, Warp II, Warp Ring, Escape, Retrace)
---============================================================================

--- Show warp spell casting message
--- @param spell_name string Spell name being cast
function MessageWarp.show_warp_casting(spell_name)
    M.send('WARP', 'warp_casting', {spell_name = spell_name})
end

--- Show warp ring equipping message
--- @param ring_name string Ring name being equipped
function MessageWarp.show_warp_equipping(ring_name)
    M.send('WARP', 'warp_equipping', {ring_name = ring_name})
end

--- Show warp countdown
--- @param seconds number Seconds remaining
function MessageWarp.show_warp_countdown(seconds)
    M.send('WARP', 'warp_countdown', {seconds = tostring(seconds)})
end

--- Show warp ring usage
--- @param ring_name string Ring name being used
function MessageWarp.show_warp_using(ring_name)
    M.send('WARP', 'warp_using', {ring_name = ring_name})
end

--- Show warp level requirement error
--- @param spell_name string Spell that requires higher level
--- @param required_level number Required level
--- @param current_level number Current level
function MessageWarp.show_warp_level_error(spell_name, required_level, current_level)
    M.send('WARP', 'warp_level_error', {
        spell_name = spell_name,
        required_level = tostring(required_level),
        current_level = tostring(current_level)
    })
end

--- Show warp requires BLM job (no job requirement met)
--- @param spell_name string Spell name
--- @param required_level number Required level
function MessageWarp.show_warp_requires_blm(spell_name, required_level)
    M.send('WARP', 'warp_requires_blm', {
        spell_name = spell_name,
        required_level = tostring(required_level)
    })
end

--- Show warp not available error
--- @param ring_name string|nil Optional ring name that was checked
function MessageWarp.show_warp_unavailable(ring_name)
    local ring_text = ring_name or "Warp Ring"
    M.send('WARP', 'warp_unavailable', {ring_text = ring_text})
end

--- Show warp ring no charges
--- @param ring_name string Ring name that has no charges
function MessageWarp.show_warp_no_charges(ring_name)
    M.send('WARP', 'warp_no_charges', {ring_name = ring_name})
end

--- Show warp ring recast time
--- @param ring_name string Ring name on cooldown
--- @param seconds number Seconds until recast ready
function MessageWarp.show_warp_recast(ring_name, seconds)
    M.send('WARP', 'warp_recast', {
        ring_name = ring_name,
        seconds = tostring(seconds)
    })
end

--- Show warp ring charges remaining after usage
--- @param ring_name string Ring name
--- @param charges_remaining number Charges left after usage
function MessageWarp.show_warp_charges_remaining(ring_name, charges_remaining)
    M.send('WARP', 'warp_charges_remaining', {
        ring_name = ring_name,
        charges = tostring(charges_remaining)
    })
end

---============================================================================
--- TELEPORT MESSAGES (Teleport-*, Recall-*, Teleport Rings, Dim Rings)
---============================================================================

--- Show teleport spell casting message
--- @param spell_name string Spell name being cast
function MessageWarp.show_tele_casting(spell_name)
    M.send('WARP', 'tele_casting', {spell_name = spell_name})
end

--- Show teleport ring equipping message
--- @param ring_name string Ring name being equipped
function MessageWarp.show_tele_equipping(ring_name)
    M.send('WARP', 'tele_equipping', {ring_name = ring_name})
end

--- Show teleport countdown
--- @param seconds number Seconds remaining
function MessageWarp.show_tele_countdown(seconds)
    M.send('WARP', 'tele_countdown', {seconds = tostring(seconds)})
end

--- Show teleport ring usage
--- @param ring_name string Ring name being used
function MessageWarp.show_tele_using(ring_name)
    M.send('WARP', 'tele_using', {ring_name = ring_name})
end

--- Show teleport level requirement error
--- @param spell_name string Spell that requires higher level
--- @param required_level number Required level
--- @param current_level number Current level
function MessageWarp.show_tele_level_error(spell_name, required_level, current_level)
    M.send('WARP', 'tele_level_error', {
        spell_name = spell_name,
        required_level = tostring(required_level),
        current_level = tostring(current_level)
    })
end

--- Show teleport requires WHM job (no job requirement met)
--- @param spell_name string Spell name
--- @param required_level number Required level
function MessageWarp.show_tele_requires_whm(spell_name, required_level)
    M.send('WARP', 'tele_requires_whm', {
        spell_name = spell_name,
        required_level = tostring(required_level)
    })
end

--- Show spell cannot cast error
--- @param error_reason string Error reason
function MessageWarp.show_spell_cannot_cast(error_reason)
    M.send('WARP', 'spell_cannot_cast', {error_reason = error_reason})
end

--- Show teleport not available error
--- @param ring_names table|string Ring names that were checked
function MessageWarp.show_tele_unavailable(ring_names)
    local ring_text
    if type(ring_names) == 'table' then
        ring_text = table.concat(ring_names, ' or ')
    else
        ring_text = tostring(ring_names)
    end
    M.send('WARP', 'tele_unavailable', {ring_text = ring_text})
end

--- Show teleport ring no charges
--- @param ring_name string Ring name that has no charges
function MessageWarp.show_tele_no_charges(ring_name)
    M.send('WARP', 'tele_no_charges', {ring_name = ring_name})
end

--- Show teleport ring recast time
--- @param ring_name string Ring name on cooldown
--- @param seconds number Seconds until recast ready
function MessageWarp.show_tele_recast(ring_name, seconds)
    M.send('WARP', 'tele_recast', {
        ring_name = ring_name,
        seconds = tostring(seconds)
    })
end

--- Show teleport ring charges remaining after usage
--- @param ring_name string Ring name
--- @param charges_remaining number Charges left after usage
function MessageWarp.show_tele_charges_remaining(ring_name, charges_remaining)
    M.send('WARP', 'tele_charges_remaining', {
        ring_name = ring_name,
        charges = tostring(charges_remaining)
    })
end

---============================================================================
--- SYSTEM MESSAGES (HYBRID RENDERING - Multi-line complex displays)
---============================================================================

--- Show warp system status
--- @param initialized boolean System initialized
--- @param locked boolean Equipment locked
--- @param can_warp boolean Can cast warp spells
function MessageWarp.show_status(initialized, locked, can_warp)
    -- Multi-line display - use MessageRenderer.send() directly
    local header_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local label_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    MessageRenderer.send(1, string.format("%s=== Warp System Status ===%s", header_color, label_color))

    local init_color = initialized and success_color or error_color
    local init_text = initialized and "Yes" or "No"
    MessageRenderer.send(1, string.format("%sInitialized: %s%s", label_color, init_color, init_text))

    local lock_color = locked and success_color or label_color
    local lock_text = locked and "Yes" or "No"
    MessageRenderer.send(1, string.format("%sEquipment Locked: %s%s", label_color, lock_color, lock_text))

    if can_warp then
        MessageRenderer.send(1, string.format("%sCan cast warp spells: %sYes (BLM)", label_color, success_color))
    end
end

--- Show warp system help
function MessageWarp.show_help()
    -- Multi-line help menu - use MessageRenderer.send() directly
    local header_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local command_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local desc_color = MessageCore.create_color_code(COLORS.SEPARATOR)

    MessageRenderer.send(1, string.format("%s=== Warp System Commands ===%s", header_color, desc_color))
    MessageRenderer.send(1, string.format("%s--- System Commands ---%s", header_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c warp status%s  - Show system status", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c warp unlock%s  - Force unlock equipment (emergency)", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c warp lock%s    - Manually lock equipment (test)", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c warp test%s    - Test warp detection", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c warp debug%s   - Toggle debug messages (ON/OFF)", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s--- Cast Commands (BLM) ---%s", header_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c w, warp%s      - Cast Warp or use Warp Ring", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c w2, warp2%s    - Cast Warp II or use Warp Ring", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c ret, retrace%s - Cast Retrace", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c esc, escape%s  - Cast Escape", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s--- Cast Commands (WHM) ---%s", header_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c tph, tpholla%s - Teleport-Holla or use rings", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c tpd, tpdem%s   - Teleport-Dem or use rings", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c tpm, tpmea%s   - Teleport-Mea or use rings", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c tpa, tpaltep%s - Teleport-Altep or use ring", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c tpy, tpyhoat%s - Teleport-Yhoat or use ring", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c tpv, tpvahzl%s - Teleport-Vahzl or use ring", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c rj, recjugner%s - Recall-Jugner", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c rp, recpashh%s - Recall-Pashh", command_color, desc_color))
    MessageRenderer.send(1, string.format("%s//gs c rm, recmeriph%s - Recall-Meriph", command_color, desc_color))
end

---============================================================================
--- INIT/SYSTEM MESSAGES
---============================================================================

--- Show system initialization success
function MessageWarp.show_init_success()
    -- Silent init - no message displayed
end

--- Show warp commands registered
function MessageWarp.show_commands_registered()
    -- Silent init - no message displayed
end

--- Show initialization error
--- @param module_name string Module that failed to load
--- @param error_msg string Error message
function MessageWarp.show_init_error(module_name, error_msg)
    M.send('WARP', 'init_error', {
        module_name = module_name,
        error_msg = tostring(error_msg)
    })
end

--- Show IPC system unavailable
function MessageWarp.show_ipc_unavailable()
    -- Silent - no message displayed
end

---============================================================================
--- IPC MESSAGES
---============================================================================

--- Show IPC listener registered
function MessageWarp.show_ipc_registered()
    -- Silent init - no message displayed
end

--- Show IPC test message sent
function MessageWarp.show_ipc_test_sent()
    M.send('WARP', 'ipc_test_sent', {})
    M.send('WARP', 'ipc_test_sent_confirm', {})
end

--- Show IPC test message received
--- @param sender string Name of character who sent test
function MessageWarp.show_ipc_test_received(sender)
    M.send('WARP', 'ipc_test_received', {sender = sender})
    M.send('WARP', 'ipc_test_received_confirm', {})
end

--- Show IPC command broadcast
--- @param command string Command being broadcast
function MessageWarp.show_ipc_broadcasting(command)
    M.send('WARP', 'ipc_broadcasting', {command = command})
end

--- Show IPC command received
--- @param command string Command received
function MessageWarp.show_ipc_command_received(command)
    M.send('WARP', 'ipc_command_received', {command = command})
end

--- Show IPC executing command
--- @param command string Command being executed
function MessageWarp.show_ipc_executing(command)
    M.send('WARP', 'ipc_executing', {command = command})
end

--- Show IPC command not allowed
--- @param command string Command that was blocked
function MessageWarp.show_ipc_not_allowed(command)
    M.send('WARP', 'ipc_not_allowed', {command = command})
end

---============================================================================
--- EQUIPMENT MESSAGES
---============================================================================

--- Show equipment locked
--- @param tag string Tag (WARP/TELE)
--- @param duration string Duration string
function MessageWarp.show_equipment_locked(tag, duration)
    M.send('WARP', 'equipment_locked', {
        tag = tag,
        duration = duration
    })
end

--- Show equipment unlocked
--- @param tag string Tag (WARP/TELE)
--- @param duration string Duration string
function MessageWarp.show_equipment_unlocked(tag, duration)
    M.send('WARP', 'equipment_unlocked', {
        tag = tag,
        duration = duration
    })
end

--- Show equipment lock error
--- @param error_msg string Error message
function MessageWarp.show_equipment_lock_error(error_msg)
    M.send('WARP', 'equipment_lock_error', {error_msg = tostring(error_msg)})
end

--- Show equipment unlock error
--- @param error_msg string Error message
function MessageWarp.show_equipment_unlock_error(error_msg)
    M.send('WARP', 'equipment_unlock_error', {error_msg = tostring(error_msg)})
end

--- Show equipment manager initialized
function MessageWarp.show_equipment_initialized()
    -- Silent init - no message displayed
end

---============================================================================
--- COMMAND MESSAGES (Status, Unlock, Fix, Lock, Test, Debug)
---============================================================================

--- Show status header
function MessageWarp.show_status_header()
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Warp System Status")
    add_to_chat(121, gray .. separator)
end

--- Show status line
--- @param label string Status label
--- @param value string|boolean Status value
function MessageWarp.show_status_line(label, value)
    local label_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    if type(value) == 'boolean' then
        local value_color = value and success_color or error_color
        local value_text = value and 'Yes' or 'No'
        MessageRenderer.send(1, string.format('%s%s: %s%s', label_color, label, value_color, value_text))
    else
        MessageRenderer.send(1, string.format('%s%s: %s%s', label_color, label, success_color, tostring(value)))
    end
end

--- Show force unlock start
function MessageWarp.show_force_unlock()
    M.send('WARP', 'force_unlock', {})
end

--- Show fix ring start
function MessageWarp.show_fix_ring_start()
    M.send('WARP', 'fix_ring_start', {})
end

--- Show fix ring complete
function MessageWarp.show_fix_ring_complete()
    M.send('WARP', 'fix_ring_complete', {})
end

--- Show manual lock start
function MessageWarp.show_manual_lock()
    M.send('WARP', 'manual_lock', {})
end

--- Show test detection header
function MessageWarp.show_test_header()
    local gray = string.char(0x1F, 160)
    local yellow = string.char(0x1F, 50)
    local separator = string.rep("=", 74)
    add_to_chat(121, gray .. separator)
    add_to_chat(121, yellow .. "Warp Detection Test")
    add_to_chat(121, gray .. separator)
end

--- Show test detection line
--- @param label string Test label
--- @param count number Count value
function MessageWarp.show_test_line(label, count)
    local label_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local value_color = MessageCore.create_color_code(COLORS.SUCCESS)
    MessageRenderer.send(1, string.format('%s%s: %s%d', label_color, label, value_color, count))
end

--- Show debug toggle
--- @param enabled boolean Debug enabled status
function MessageWarp.show_debug_toggle(enabled)
    local status_color = enabled and "{green}" or "{red}"
    local status_text = enabled and 'ENABLED' or 'DISABLED'
    M.send('WARP', 'debug_toggle', {
        status_color = status_color,
        status_text = status_text
    })
end

--- Show using destination item
--- @param item_name string Item name
--- @param destination string Destination name
function MessageWarp.show_using_destination(item_name, destination)
    M.send('WARP', 'using_destination', {
        item_name = item_name,
        destination = destination
    })
end

--- Show registered with common commands
function MessageWarp.show_registered_common()
    M.send('WARP', 'registered_common', {})
end

---============================================================================
--- PRECAST MESSAGES
---============================================================================

--- Show precast FC warning
--- @param spell_name string Spell name that failed FC
function MessageWarp.show_precast_fc_warning(spell_name)
    M.send('WARP', 'precast_fc_warning', {spell_name = spell_name})
end

--- Show force FC applied
--- @param spell_name string Spell name
function MessageWarp.show_force_fc(spell_name)
    M.send('WARP', 'force_fc', {spell_name = spell_name})
end

--- Show precast system initialized
function MessageWarp.show_precast_initialized()
    -- Silent init - no message displayed
end

---============================================================================
--- ITEM COOLDOWN MESSAGES
---============================================================================

--- Show all items on cooldown header
function MessageWarp.show_all_items_cooldown()
    M.send('WARP', 'all_items_cooldown', {})
end

--- Show item cooldown with time remaining
--- @param item_name string Item name
--- @param time_msg string Time message (e.g., "30s", "2m 15s")
function MessageWarp.show_item_cooldown_time(item_name, time_msg)
    M.send('WARP', 'item_cooldown_time', {
        item_name = item_name,
        time_msg = time_msg
    })
end

--- Show item equip delay
--- @param item_name string Item name
function MessageWarp.show_item_equip_delay(item_name)
    M.send('WARP', 'item_equip_delay', {item_name = item_name})
end

--- Show next available item
--- @param item_name string Item name
--- @param time_msg string Time message
function MessageWarp.show_next_available_item(item_name, time_msg)
    M.send('WARP', 'next_available_item', {
        item_name = item_name,
        time_msg = time_msg
    })
end

---============================================================================
--- ITEM CASTING ERROR MESSAGES (HYBRID - Direct add_to_chat with inline colors)
---============================================================================
--- NOTE: These functions maintain direct add_to_chat() calls with inline color
---       codes because they are low-level technical debug/error messages from
---       item_user.lua that need precise color control and inline formatting.
---============================================================================

--- Show debug message for item casting
--- @param message string Debug message
function MessageWarp.show_item_casting_debug(message)
    add_to_chat(8, '[DEBUG] ' .. message)
end

--- Show extdata not available error
--- @param tag string Item tag (e.g., "WARP RING1")
function MessageWarp.show_extdata_error(tag)
    add_to_chat(167, '[' .. tag .. '] ERROR: extdata not available')
end

--- Show item disappeared from inventory error
--- @param tag string Item tag
function MessageWarp.show_item_disappeared(tag)
    add_to_chat(167, '[' .. tag .. '] Item disappeared from inventory!')
end

--- Show failed to read item data error
--- @param tag string Item tag
function MessageWarp.show_item_read_failed(tag)
    add_to_chat(167, '[' .. tag .. '] Failed to read item data')
end

--- Show item on cooldown error
--- @param tag string Item tag
--- @param cooldown_delay number Cooldown time remaining in seconds
function MessageWarp.show_item_on_cooldown(tag, cooldown_delay)
    add_to_chat(167, '[' .. tag .. '] Item is on cooldown (' .. math.floor(cooldown_delay) .. 's remaining)')
end

--- Show timeout during safety delay
--- @param tag string Item tag
--- @param max_wait number Max wait time
--- @param check_interval number Check interval
function MessageWarp.show_safety_timeout(tag, max_wait, check_interval)
    add_to_chat(167, string.format('[%s] Timeout during safety delay after %ds', tag, max_wait * check_interval))
end

--- Show waiting for safety delay
--- @param tag_color string Tag color code
--- @param tag string Item tag
--- @param action_color string Action color code
--- @param elapsed number Elapsed time
function MessageWarp.show_waiting_safety(tag_color, tag, action_color, elapsed)
    add_to_chat(8, string.format('%s[%s]%s Waiting... %ds',
        tag_color, tag, action_color, elapsed))
end

--- Show casting timeout error
--- @param timeout_msg string Timeout message
function MessageWarp.show_casting_timeout(timeout_msg)
    add_to_chat(167, timeout_msg)
end

--- Show item needs recharge
--- @param tag string Item tag
--- @param recast_delay number Recast delay
function MessageWarp.show_item_needs_recharge(tag, recast_delay)
    add_to_chat(122, '[' .. tag .. '] Item needs recharge (' .. recast_delay .. 's remaining)')
end

--- Show item recast not finished
--- @param tag string Item tag
--- @param recast_delay number Recast delay
function MessageWarp.show_item_recast_pending(tag, recast_delay)
    add_to_chat(122, '[' .. tag .. '] Item recast not finished (' .. recast_delay .. 's remaining)')
end

--- Show item equip delay
--- @param tag string Item tag
--- @param activation_delay number Activation delay
function MessageWarp.show_item_equip_delay(tag, activation_delay)
    add_to_chat(122, '[' .. tag .. '] Item equip delay (' .. activation_delay .. 's remaining)')
end

--- Show ring restored
--- @param tag_color string Tag color code
--- @param tag string Item tag
--- @param action_color string Action color code
--- @param slot_color string Slot color code
--- @param ring_name string Ring name
function MessageWarp.show_ring_restored(tag_color, tag, action_color, slot_color, ring_name)
    add_to_chat(122, string.format('%s[%s]%s Ring1 restored: %s',
        tag_color, tag, action_color, ring_name))
end

--- Show ring final state debug
--- @param ring_name string Ring name or "empty"
--- @param warp_item string Warp item name
function MessageWarp.show_ring_final_state(ring_name, warp_item)
    add_to_chat(8, string.format('[DEBUG] Ring1 final state: %s (warp item was: %s)',
        ring_name, warp_item))
end

--- Show equipment unlocked (ring1)
--- @param tag_color string Tag color code
--- @param tag string Item tag
--- @param action_color string Action color code
--- @param slot_color string Slot color code
function MessageWarp.show_equipment_unlocked_ring1(tag_color, tag, action_color, slot_color)
    add_to_chat(1, string.format('%s[%s]%s Equipment unlocked %s(ring1)',
        tag_color, tag, action_color, slot_color))
end

--- Show action interrupted
--- @param tag_color string Tag color code
--- @param tag string Item tag
--- @param action_color string Action color code
--- @param action_name string Action name
function MessageWarp.show_action_interrupted(tag_color, tag, action_color, action_name)
    add_to_chat(122, string.format('%s[%s]%s %s interrupted - restoring equipment...',
        tag_color, tag, action_color, action_name))
end

--- Show action did not complete
--- @param tag_color string Tag color code
--- @param tag string Item tag
--- @param action_color string Action color code
--- @param action_name string Action name
function MessageWarp.show_action_incomplete(tag_color, tag, action_color, action_name)
    add_to_chat(122, string.format('%s[%s]%s %s did not complete - restoring equipment...',
        tag_color, tag, action_color, action_name))
end

--- Show unknown cleanup reason debug
--- @param reason string Cleanup reason
function MessageWarp.show_unknown_cleanup_reason(reason)
    add_to_chat(167, '[DEBUG] Unknown cleanup reason: ' .. tostring(reason))
end

---============================================================================
--- IPC DEBUG MESSAGES (HYBRID - Direct add_to_chat with CHAT_DEBUG)
---============================================================================
--- NOTE: Debug messages use direct add_to_chat() with CHAT_DEBUG constant
---       to maintain precise control over debug channel and inline colors
---============================================================================

--- Show IPC raw message received debug
--- @param msg string Raw IPC message
function MessageWarp.show_ipc_raw_received(msg)
    add_to_chat(CHAT_DEBUG, '[DEBUG] IPC RAW received: ' .. tostring(msg))
end

--- Show IPC message debounced debug
--- @param msg string|nil Optional message (for warp_ipc.lua)
function MessageWarp.show_ipc_message_debounced(msg)
    if msg then
        add_to_chat(CHAT_DEBUG, '[DEBUG] IPC message debounced: ' .. msg)
    else
        add_to_chat(CHAT_DEBUG, '[DEBUG] IPC message debounced')
    end
end

--- Show IPC listener registered debug
function MessageWarp.show_ipc_listener_registered()
    add_to_chat(CHAT_DEBUG, '[DEBUG] IPC listener registered')
end

--- Show executing local command debug
--- @param cmd string Command to execute
function MessageWarp.show_executing_local_command(cmd)
    add_to_chat(CHAT_DEBUG, '[DEBUG] Executing local command: //gs c ' .. cmd)
end

--- Show sending IPC message debug
--- @param ipc_msg string IPC message to send
function MessageWarp.show_sending_ipc_message(ipc_msg)
    add_to_chat(CHAT_DEBUG, '[DEBUG] Sending IPC message: ' .. ipc_msg)
end

--- Show IPC message sent successfully debug
function MessageWarp.show_ipc_message_sent()
    add_to_chat(CHAT_DEBUG, '[DEBUG] IPC message sent successfully')
end

---============================================================================
--- COMMAND DEBUG MESSAGES (HYBRID - Direct add_to_chat with CHAT_DEBUG)
---============================================================================

--- Show cast_with_fallback called debug
--- @param spell_name string Spell name to cast
function MessageWarp.show_cast_with_fallback_called(spell_name)
    add_to_chat(CHAT_DEBUG, '[DEBUG] cast_with_fallback() called: ' .. spell_name)
end

--- Show spell cast successful debug
function MessageWarp.show_spell_cast_successful()
    add_to_chat(CHAT_DEBUG, '[DEBUG] Spell cast successful, returning true')
end

--- Show spell failed trying ring fallback debug
function MessageWarp.show_spell_failed_ring_fallback()
    add_to_chat(CHAT_DEBUG, '[DEBUG] Spell failed, trying ring fallback')
end

--- Show ring fallback result debug
--- @param result boolean Ring fallback result
function MessageWarp.show_ring_fallback_result(result)
    add_to_chat(CHAT_DEBUG, '[DEBUG] Ring fallback result: ' .. tostring(result))
end

--- Show command debounced debug
--- @param command string Command that was debounced
function MessageWarp.show_command_debounced(command)
    add_to_chat(CHAT_DEBUG, '[DEBUG] Command debounced (duplicate within 500ms): ' .. command)
end

--- Show WarpCommands.handle_command executing debug
--- @param command string Command being executed
function MessageWarp.show_handle_command_executing(command)
    add_to_chat(CHAT_DEBUG, '[DEBUG] WarpCommands.handle_command() executing: ' .. command)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWarp

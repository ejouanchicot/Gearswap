---============================================================================
--- Message Warp - Warp/Teleport System Messages
---============================================================================
--- Provides formatted messages for warp and teleport system using standard
--- MessageFormatter style and colors.
---
--- @file utils/messages/message_warp.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-26
---============================================================================

local MessageWarp = {}

-- Load message core for colors and utilities
local MessageCore = require('shared/utils/messages/message_core')
local COLORS = MessageCore.COLORS

---============================================================================
--- WARP MESSAGES (Warp, Warp II, Warp Ring, Escape, Retrace)
---============================================================================

--- Show warp spell casting message
--- @param spell_name string Spell name being cast
function MessageWarp.show_warp_casting(spell_name)
    -- Multi-color: [WARP](cyan) + Casting(white) + Spell(cyan)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local spell_color = MessageCore.create_color_code(COLORS.SPELL)

    local message = string.format(
        "%s[WARP]%s Casting %s%s%s...",
        tag_color,
        action_color,
        spell_color, spell_name, action_color
    )
    add_to_chat(1, message)
end

--- Show warp ring equipping message
--- @param ring_name string Ring name being equipped
function MessageWarp.show_warp_equipping(ring_name)
    -- Multi-color: [WARP](cyan) + Equipping(white) + Ring(yellow)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)

    local message = string.format(
        "%s[WARP]%s Equipping %s%s%s...",
        tag_color,
        action_color,
        item_color, ring_name, action_color
    )
    add_to_chat(1, message)
end

--- Show warp countdown
--- @param seconds number Seconds remaining
function MessageWarp.show_warp_countdown(seconds)
    -- Multi-color: [WARP](cyan) + Using in(white) + Time(green)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local time_color = MessageCore.create_color_code(COLORS.SUCCESS)

    local message = string.format(
        "%s[WARP]%s Using in %s%ds%s...",
        tag_color,
        action_color,
        time_color, seconds, action_color
    )
    add_to_chat(1, message)
end

--- Show warp ring usage
--- @param ring_name string Ring name being used
function MessageWarp.show_warp_using(ring_name)
    -- Multi-color: [WARP](cyan) + Using(white) + Ring(yellow)!
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)

    local message = string.format(
        "%s[WARP]%s Using %s%s%s!",
        tag_color,
        action_color,
        item_color, ring_name, action_color
    )
    add_to_chat(1, message)
end

--- Show warp level requirement error
--- @param spell_name string Spell that requires higher level
--- @param required_level number Required level
--- @param current_level number Current level
function MessageWarp.show_warp_level_error(spell_name, required_level, current_level)
    -- Multi-color: [WARP](cyan) + Error text(red) + Numbers(white)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)
    local number_color = MessageCore.create_color_code(COLORS.SEPARATOR)

    local message = string.format(
        "%s[WARP] %s%s requires BLM level %s%d%s (current: %s%d%s)",
        tag_color,
        error_color, spell_name,
        number_color, required_level, error_color,
        number_color, current_level, error_color
    )
    add_to_chat(1, message)
end

--- Show warp requires BLM job (no job requirement met)
--- @param spell_name string Spell name
--- @param required_level number Required level
function MessageWarp.show_warp_requires_blm(spell_name, required_level)
    -- Multi-color: [WARP](cyan) + Spell(cyan) + Warning(orange/rose) - REGION ADAPTIVE
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local spell_color = MessageCore.create_color_code(COLORS.SPELL)
    local warning_color = MessageCore.create_color_code(COLORS.WARNING)  -- 057 (US) / 206 (EU)

    local message = string.format(
        "%s[WARP] %s%s %srequires BLM lvl %d",
        tag_color,
        spell_color, spell_name,
        warning_color, required_level
    )
    add_to_chat(1, message)  -- IMPORTANT: add_to_chat(1, ...) pour codes inline!
end

--- Show warp not available error
--- @param ring_name string|nil Optional ring name that was checked
function MessageWarp.show_warp_unavailable(ring_name)
    -- Multi-color: [WARP](cyan) + Error(red)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    local message
    if ring_name then
        message = string.format("%s[WARP] %sCannot warp - Requires BLM main/sub or %s",
            tag_color, error_color, ring_name)
    else
        message = string.format("%s[WARP] %sCannot warp - Requires BLM main/sub or Warp Ring",
            tag_color, error_color)
    end
    add_to_chat(1, message)
end

--- Show warp ring no charges
--- @param ring_name string Ring name that has no charges
function MessageWarp.show_warp_no_charges(ring_name)
    -- Multi-color: [WARP](cyan) + Ring(yellow) + Error(red)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    local message = string.format(
        "%s[WARP] %s%s %s- No charges remaining",
        tag_color,
        item_color, ring_name,
        error_color
    )
    add_to_chat(1, message)
end

--- Show warp ring recast time
--- @param ring_name string Ring name on cooldown
--- @param seconds number Seconds until recast ready
function MessageWarp.show_warp_recast(ring_name, seconds)
    -- Multi-color: [WARP](cyan) + Ring(yellow) + Time(red)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    local message = string.format(
        "%s[WARP] %s%s %s- Recast: %ds",
        tag_color,
        item_color, ring_name,
        error_color, seconds
    )
    add_to_chat(1, message)
end

--- Show warp ring charges remaining after usage
--- @param ring_name string Ring name
--- @param charges_remaining number Charges left after usage
function MessageWarp.show_warp_charges_remaining(ring_name, charges_remaining)
    -- Multi-color: [WARP](cyan) + Ring(yellow) + Charges(white)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local info_color = MessageCore.create_color_code(COLORS.SEPARATOR)

    local message = string.format(
        "%s[WARP] %s%s %s- Charges remaining: %d",
        tag_color,
        item_color, ring_name,
        info_color, charges_remaining
    )
    add_to_chat(1, message)
end

---============================================================================
--- TELEPORT MESSAGES (Teleport-*, Recall-*, Teleport Rings, Dim Rings)
---============================================================================

--- Show teleport spell casting message
--- @param spell_name string Spell name being cast
function MessageWarp.show_tele_casting(spell_name)
    -- Multi-color: [TELE](cyan) + Casting(white) + Spell(cyan)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local spell_color = MessageCore.create_color_code(COLORS.SPELL)

    local message = string.format(
        "%s[TELE]%s Casting %s%s%s...",
        tag_color,
        action_color,
        spell_color, spell_name, action_color
    )
    add_to_chat(1, message)
end

--- Show teleport ring equipping message
--- @param ring_name string Ring name being equipped
function MessageWarp.show_tele_equipping(ring_name)
    -- Multi-color: [TELE](cyan) + Equipping(white) + Ring(yellow)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)

    local message = string.format(
        "%s[TELE]%s Equipping %s%s%s...",
        tag_color,
        action_color,
        item_color, ring_name, action_color
    )
    add_to_chat(1, message)
end

--- Show teleport countdown
--- @param seconds number Seconds remaining
function MessageWarp.show_tele_countdown(seconds)
    -- Multi-color: [TELE](cyan) + Using in(white) + Time(green)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local time_color = MessageCore.create_color_code(COLORS.SUCCESS)

    local message = string.format(
        "%s[TELE]%s Using in %s%ds%s...",
        tag_color,
        action_color,
        time_color, seconds, action_color
    )
    add_to_chat(1, message)
end

--- Show teleport ring usage
--- @param ring_name string Ring name being used
function MessageWarp.show_tele_using(ring_name)
    -- Multi-color: [TELE](cyan) + Using(white) + Ring(yellow)!
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)

    local message = string.format(
        "%s[TELE]%s Using %s%s%s!",
        tag_color,
        action_color,
        item_color, ring_name, action_color
    )
    add_to_chat(1, message)
end

--- Show teleport level requirement error
--- @param spell_name string Spell that requires higher level
--- @param required_level number Required level
--- @param current_level number Current level
function MessageWarp.show_tele_level_error(spell_name, required_level, current_level)
    -- Multi-color: [TELE](cyan) + Error text(red) + Numbers(white)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)
    local number_color = MessageCore.create_color_code(COLORS.SEPARATOR)

    local message = string.format(
        "%s[TELE] %s%s requires WHM level %s%d%s (current: %s%d%s)",
        tag_color,
        error_color, spell_name,
        number_color, required_level, error_color,
        number_color, current_level, error_color
    )
    add_to_chat(1, message)
end

--- Show teleport requires WHM job (no job requirement met)
--- @param spell_name string Spell name
--- @param required_level number Required level
function MessageWarp.show_tele_requires_whm(spell_name, required_level)
    -- Multi-color: [TELE](cyan) + Spell(cyan) + Warning(orange/rose) - REGION ADAPTIVE
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local spell_color = MessageCore.create_color_code(COLORS.SPELL)
    local warning_color = MessageCore.create_color_code(COLORS.WARNING)  -- 057 (US) / 206 (EU)

    local message = string.format(
        "%s[TELE] %s%s %srequires WHM lvl %d",
        tag_color,
        spell_color, spell_name,
        warning_color, required_level
    )
    add_to_chat(1, message)  -- IMPORTANT: add_to_chat(1, ...) pour codes inline!
end

--- Show spell cannot cast error
--- @param error_reason string Error reason
function MessageWarp.show_spell_cannot_cast(error_reason)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local warning_color = MessageCore.create_color_code(COLORS.WARNING)  -- 057 (US) / 206 (EU)
    add_to_chat(1, string.format('%s[WARP] %sCannot cast: %s',
        tag_color, warning_color, error_reason))
end

--- Show teleport not available error
--- @param ring_names table|string Ring names that were checked
function MessageWarp.show_tele_unavailable(ring_names)
    -- Multi-color: [TELE](cyan) + Error(red)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    local ring_text
    if type(ring_names) == 'table' then
        ring_text = table.concat(ring_names, ' or ')
    else
        ring_text = tostring(ring_names)
    end

    local message = string.format(
        "%s[TELE] %sCannot teleport - Requires WHM main/sub or %s",
        tag_color, error_color, ring_text
    )
    add_to_chat(1, message)
end

--- Show teleport ring no charges
--- @param ring_name string Ring name that has no charges
function MessageWarp.show_tele_no_charges(ring_name)
    -- Multi-color: [TELE](cyan) + Ring(yellow) + Error(red)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    local message = string.format(
        "%s[TELE] %s%s %s- No charges remaining",
        tag_color,
        item_color, ring_name,
        error_color
    )
    add_to_chat(1, message)
end

--- Show teleport ring recast time
--- @param ring_name string Ring name on cooldown
--- @param seconds number Seconds until recast ready
function MessageWarp.show_tele_recast(ring_name, seconds)
    -- Multi-color: [TELE](cyan) + Ring(yellow) + Time(red)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    local message = string.format(
        "%s[TELE] %s%s %s- Recast: %ds",
        tag_color,
        item_color, ring_name,
        error_color, seconds
    )
    add_to_chat(1, message)
end

--- Show teleport ring charges remaining after usage
--- @param ring_name string Ring name
--- @param charges_remaining number Charges left after usage
function MessageWarp.show_tele_charges_remaining(ring_name, charges_remaining)
    -- Multi-color: [TELE](cyan) + Ring(yellow) + Charges(white)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local info_color = MessageCore.create_color_code(COLORS.SEPARATOR)

    local message = string.format(
        "%s[TELE] %s%s %s- Charges remaining: %d",
        tag_color,
        item_color, ring_name,
        info_color, charges_remaining
    )
    add_to_chat(1, message)
end

---============================================================================
--- SYSTEM MESSAGES
---============================================================================

--- Show warp system status
--- @param initialized boolean System initialized
--- @param locked boolean Equipment locked
--- @param can_warp boolean Can cast warp spells
function MessageWarp.show_status(initialized, locked, can_warp)
    -- Multi-color: Headers(cyan) + Labels(white) + Values(green/red)
    local header_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local label_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)

    add_to_chat(1, string.format("%s=== Warp System Status ===%s", header_color, label_color))

    local init_color = initialized and success_color or error_color
    local init_text = initialized and "Yes" or "No"
    add_to_chat(1, string.format("%sInitialized: %s%s", label_color, init_color, init_text))

    local lock_color = locked and success_color or label_color
    local lock_text = locked and "Yes" or "No"
    add_to_chat(1, string.format("%sEquipment Locked: %s%s", label_color, lock_color, lock_text))

    if can_warp then
        add_to_chat(1, string.format("%sCan cast warp spells: %sYes (BLM)", label_color, success_color))
    end
end

--- Show warp system help
function MessageWarp.show_help()
    -- Multi-color: Headers(cyan) + Commands(yellow) + Descriptions(white)
    local header_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local command_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local desc_color = MessageCore.create_color_code(COLORS.SEPARATOR)

    add_to_chat(1, string.format("%s=== Warp System Commands ===%s", header_color, desc_color))
    add_to_chat(1, string.format("%s--- System Commands ---%s", header_color, desc_color))
    add_to_chat(1, string.format("%s//gs c warp status%s  - Show system status", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c warp unlock%s  - Force unlock equipment (emergency)", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c warp lock%s    - Manually lock equipment (test)", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c warp test%s    - Test warp detection", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c warp debug%s   - Toggle debug messages (ON/OFF)", command_color, desc_color))
    add_to_chat(1, string.format("%s--- Cast Commands (BLM) ---%s", header_color, desc_color))
    add_to_chat(1, string.format("%s//gs c w, warp%s      - Cast Warp or use Warp Ring", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c w2, warp2%s    - Cast Warp II or use Warp Ring", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c ret, retrace%s - Cast Retrace", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c esc, escape%s  - Cast Escape", command_color, desc_color))
    add_to_chat(1, string.format("%s--- Cast Commands (WHM) ---%s", header_color, desc_color))
    add_to_chat(1, string.format("%s//gs c tph, tpholla%s - Teleport-Holla or use rings", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c tpd, tpdem%s   - Teleport-Dem or use rings", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c tpm, tpmea%s   - Teleport-Mea or use rings", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c tpa, tpaltep%s - Teleport-Altep or use ring", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c tpy, tpyhoat%s - Teleport-Yhoat or use ring", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c tpv, tpvahzl%s - Teleport-Vahzl or use ring", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c rj, recjugner%s - Recall-Jugner", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c rp, recpashh%s - Recall-Pashh", command_color, desc_color))
    add_to_chat(1, string.format("%s//gs c rm, recmeriph%s - Recall-Meriph", command_color, desc_color))
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
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)
    add_to_chat(1, string.format('%s[Warp Init] %sFailed to load %s: %s',
        tag_color, error_color, module_name, tostring(error_msg)))
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
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local info_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('%s[WARP]%s Sending IPC test message...',
        tag_color, info_color))
    add_to_chat(1, string.format('%s[WARP]%s IPC test message sent!',
        tag_color, info_color))
end

--- Show IPC test message received
--- @param sender string Name of character who sent test
function MessageWarp.show_ipc_test_received(sender)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    local sender_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    add_to_chat(1, string.format('%s[Warp IPC]%s TEST message received from: %s%s',
        tag_color, success_color, sender_color, sender))
    add_to_chat(1, string.format('%s[Warp IPC] %s✓ IPC system is working!',
        tag_color, success_color))
end

--- Show IPC command broadcast
--- @param command string Command being broadcast
function MessageWarp.show_ipc_broadcasting(command)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local cmd_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    add_to_chat(1, string.format('%s[WARP]%s Broadcasting %s"%s"%s to other characters...',
        tag_color, action_color, cmd_color, command, action_color))
end

--- Show IPC command received
--- @param command string Command received
function MessageWarp.show_ipc_command_received(command)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local info_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local cmd_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    add_to_chat(1, string.format('%s[Warp IPC]%s Command received: %s%s',
        tag_color, info_color, cmd_color, command))
end

--- Show IPC executing command
--- @param command string Command being executed
function MessageWarp.show_ipc_executing(command)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    local cmd_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    add_to_chat(1, string.format('%s[Warp IPC]%s Executing: %s//gs c %s',
        tag_color, success_color, cmd_color, command))
end

--- Show IPC command not allowed
--- @param command string Command that was blocked
function MessageWarp.show_ipc_not_allowed(command)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)
    add_to_chat(1, string.format('%s[Warp IPC] %sCommand not allowed: %s',
        tag_color, error_color, command))
end

---============================================================================
--- EQUIPMENT MESSAGES
---============================================================================

--- Show equipment locked
--- @param tag string Tag (WARP/TELE)
--- @param duration string Duration string
function MessageWarp.show_equipment_locked(tag, duration)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s[%s]%s Equipment locked %s(%s)',
        tag_color, tag, action_color, success_color, duration))
end

--- Show equipment unlocked
--- @param tag string Tag (WARP/TELE)
--- @param duration string Duration string
function MessageWarp.show_equipment_unlocked(tag, duration)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s[%s]%s Equipment unlocked %s(%s)',
        tag_color, tag, action_color, success_color, duration))
end

--- Show equipment lock error
--- @param error_msg string Error message
function MessageWarp.show_equipment_lock_error(error_msg)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)
    add_to_chat(1, string.format('%s[WARP] %sFailed to lock equipment: %s',
        tag_color, error_color, tostring(error_msg)))
end

--- Show equipment unlock error
--- @param error_msg string Error message
function MessageWarp.show_equipment_unlock_error(error_msg)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local error_color = MessageCore.create_color_code(COLORS.ERROR)
    add_to_chat(1, string.format('%s[WARP] %sFailed to unlock equipment: %s',
        tag_color, error_color, tostring(error_msg)))
end

--- Show equipment manager initialized
function MessageWarp.show_equipment_initialized()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s[WARP]%s Equipment manager initialized %s[OK]',
        tag_color, action_color, success_color))
end

---============================================================================
--- COMMAND MESSAGES (Status, Unlock, Fix, Lock, Test, Debug)
---============================================================================

--- Show status header
function MessageWarp.show_status_header()
    local header_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local separator_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('%s=== Warp System Status ===%s', header_color, separator_color))
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
        add_to_chat(1, string.format('%s%s: %s%s', label_color, label, value_color, value_text))
    else
        add_to_chat(1, string.format('%s%s: %s%s', label_color, label, success_color, tostring(value)))
    end
end

--- Show force unlock start
function MessageWarp.show_force_unlock()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('%s[WARP]%s Force unlocking equipment...', tag_color, action_color))
end

--- Show fix ring start
function MessageWarp.show_fix_ring_start()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('%s[WARP]%s Fixing frozen ring slot...', tag_color, action_color))
end

--- Show fix ring complete
function MessageWarp.show_fix_ring_complete()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s[WARP]%s Ring slot fixed!', tag_color, success_color))
end

--- Show manual lock start
function MessageWarp.show_manual_lock()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('%s[WARP]%s Manually locking equipment for 10 seconds...', tag_color, action_color))
end

--- Show test detection header
function MessageWarp.show_test_header()
    local header_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local separator_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('%s=== Warp Detection Test ===%s', header_color, separator_color))
end

--- Show test detection line
--- @param label string Test label
--- @param count number Count value
function MessageWarp.show_test_line(label, count)
    local label_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local value_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s%s: %s%d', label_color, label, value_color, count))
end

--- Show debug toggle
--- @param enabled boolean Debug enabled status
function MessageWarp.show_debug_toggle(enabled)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local status_color = enabled and MessageCore.create_color_code(COLORS.SUCCESS) or MessageCore.create_color_code(COLORS.ERROR)
    local status_text = enabled and 'ENABLED' or 'DISABLED'
    add_to_chat(1, string.format('%s[WARP]%s Debug mode: %s%s', tag_color, MessageCore.create_color_code(COLORS.SEPARATOR), status_color, status_text))
end

--- Show using destination item
--- @param item_name string Item name
--- @param destination string Destination name
function MessageWarp.show_using_destination(item_name, destination)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    add_to_chat(1, string.format('%s[WARP]%s Using %s%s%s → %s',
        tag_color, action_color, item_color, item_name, action_color, destination))
end

--- Show registered with common commands
function MessageWarp.show_registered_common()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s[WARP]%s Registered with common commands',
        tag_color, success_color))
end

---============================================================================
--- PRECAST MESSAGES
---============================================================================

--- Show precast FC warning
--- @param spell_name string Spell name that failed FC
function MessageWarp.show_precast_fc_warning(spell_name)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local warning_color = MessageCore.create_color_code(COLORS.ERROR)
    local spell_color = MessageCore.create_color_code(COLORS.SPELL)
    add_to_chat(1, string.format('%s[WARP] %sWarning: sets.precast.FC not found for %s%s',
        tag_color, warning_color, spell_color, spell_name))
end

--- Show force FC applied
--- @param spell_name string Spell name
function MessageWarp.show_force_fc(spell_name)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local action_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local spell_color = MessageCore.create_color_code(COLORS.SPELL)
    add_to_chat(1, string.format('%s[WARP]%s Force FC for %s%s',
        tag_color, action_color, spell_color, spell_name))
end

--- Show precast system initialized
function MessageWarp.show_precast_initialized()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local success_color = MessageCore.create_color_code(COLORS.SUCCESS)
    add_to_chat(1, string.format('%s[Warp Precast]%s Initialized - FC will be forced for warp spells',
        tag_color, success_color))
end

---============================================================================
--- ITEM COOLDOWN MESSAGES
---============================================================================

--- Show all items on cooldown header
function MessageWarp.show_all_items_cooldown()
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local warning_color = MessageCore.create_color_code(COLORS.WARNING)  -- 057 (US) / 206 (EU)
    add_to_chat(1, string.format('%s[WARP]%s All items on cooldown',
        tag_color, warning_color))
end

--- Show item cooldown with time remaining
--- @param item_name string Item name
--- @param time_msg string Time message (e.g., "30s", "2m 15s")
function MessageWarp.show_item_cooldown_time(item_name, time_msg)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local separator_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('  %s%s%s - ready in %s',
        item_color, item_name, separator_color, time_msg))
end

--- Show item equip delay
--- @param item_name string Item name
function MessageWarp.show_item_equip_delay(item_name)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    local separator_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    add_to_chat(1, string.format('  %s%s%s - equip delay',
        item_color, item_name, separator_color))
end

--- Show next available item
--- @param item_name string Item name
--- @param time_msg string Time message
function MessageWarp.show_next_available_item(item_name, time_msg)
    local tag_color = MessageCore.create_color_code(COLORS.JOB_TAG)
    local separator_color = MessageCore.create_color_code(COLORS.SEPARATOR)
    local item_color = MessageCore.create_color_code(COLORS.ITEM_COLOR)
    add_to_chat(1, string.format('%s[WARP]%s Next available: %s%s%s in %s',
        tag_color, separator_color, item_color, item_name, separator_color, time_msg))
end

return MessageWarp

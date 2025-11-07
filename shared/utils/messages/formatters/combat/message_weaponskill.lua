---============================================================================
--- Weaponskill Message Formatter - WS Manager & TP Calculator (NEW SYSTEM)
---============================================================================
--- Uses template-based messaging via MessageRenderer
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_weaponskill.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageWeaponskill = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- WS MANAGER MESSAGES
---============================================================================

function MessageWeaponskill.show_ws_manager_initialized()
    M.send('WEAPONSKILL', 'ws_manager_initialized')
end

function MessageWeaponskill.show_invalid_spell_parameter()
    M.send('WEAPONSKILL', 'invalid_spell_parameter')
end

function MessageWeaponskill.show_target_info_missing()
    M.send('WEAPONSKILL', 'target_info_missing')
end

function MessageWeaponskill.show_missing_numeric_values()
    M.send('WEAPONSKILL', 'missing_numeric_values')
end

function MessageWeaponskill.show_too_far(spell_name, distance_info)
    M.send('WEAPONSKILL', 'too_far', {
        ws_name = spell_name,
        distance = distance_info
    })
end

function MessageWeaponskill.show_player_info_missing()
    M.send('WEAPONSKILL', 'player_info_missing')
end

function MessageWeaponskill.show_amnesia_error(ws_name)
    M.send('WEAPONSKILL', 'amnesia_error', {
        ws_name = ws_name or "WS"
    })
end

---============================================================================
--- TP CALCULATOR DEBUG MESSAGES
---============================================================================

function MessageWeaponskill.show_tp_validation_failed(current_tp, tp_config)
    M.send('WEAPONSKILL', 'tp_validation_failed', {
        current_tp = tostring(current_tp),
        tp_config = tostring(tp_config)
    })
end

function MessageWeaponskill.show_tp_calculation(current_tp, weapon_name, weapon_bonus, real_tp)
    M.send('WEAPONSKILL', 'tp_calculation', {
        current_tp = tostring(current_tp),
        weapon = tostring(weapon_name),
        weapon_bonus = tostring(weapon_bonus),
        real_tp = tostring(real_tp)
    })
end

function MessageWeaponskill.show_already_at_max()
    M.send('WEAPONSKILL', 'already_at_max')
end

function MessageWeaponskill.show_target_threshold(target_threshold, gap)
    M.send('WEAPONSKILL', 'target_threshold', {
        target_threshold = tostring(target_threshold),
        gap = tostring(gap)
    })
end

function MessageWeaponskill.show_gap_too_large(gap, total_available)
    M.send('WEAPONSKILL', 'gap_too_large', {
        gap = tostring(gap),
        total_available = tostring(total_available)
    })
end

function MessageWeaponskill.show_total_available(total_available)
    M.send('WEAPONSKILL', 'total_available', {
        total_available = tostring(total_available)
    })
end

function MessageWeaponskill.show_checking_piece(piece_name, slot, bonus, gap)
    M.send('WEAPONSKILL', 'checking_piece', {
        piece_name = piece_name,
        slot = slot,
        bonus = tostring(bonus),
        gap = tostring(gap)
    })
end

function MessageWeaponskill.show_equipping_piece(slot, piece_name, bonus, gap)
    M.send('WEAPONSKILL', 'equipping_piece', {
        slot = slot,
        piece_name = piece_name,
        bonus = tostring(bonus),
        gap = tostring(gap)
    })
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageWeaponskill

---============================================================================
--- Weaponskill Message Formatter - WS Manager & TP Calculator
---============================================================================
--- Messages of weaponskill_manager.lua and tp_bonus_calculator.lua, which
--- require this module directly (it is not exposed by MessageFormatter).
--- Templates: data/systems/weaponskill_messages.lua.
---
--- @file    shared/utils/messages/formatters/combat/message_weaponskill.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageWeaponskill = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- WS MANAGER MESSAGES
---============================================================================

--- Show the WEAPONSKILL.ws_manager_initialized message
function MessageWeaponskill.show_ws_manager_initialized()
    M.send('WEAPONSKILL', 'ws_manager_initialized')
end

--- Show the WEAPONSKILL.invalid_spell_parameter message
function MessageWeaponskill.show_invalid_spell_parameter()
    M.send('WEAPONSKILL', 'invalid_spell_parameter')
end

--- Show the WEAPONSKILL.target_info_missing message
function MessageWeaponskill.show_target_info_missing()
    M.send('WEAPONSKILL', 'target_info_missing')
end

--- Show the WEAPONSKILL.missing_numeric_values message
function MessageWeaponskill.show_missing_numeric_values()
    M.send('WEAPONSKILL', 'missing_numeric_values')
end

--- @param spell_name string Weapon skill name
--- @param distance_info string Distance text
function MessageWeaponskill.show_too_far(spell_name, distance_info)
    M.send('WEAPONSKILL', 'too_far', {
        ws_name = spell_name,
        distance = distance_info
    })
end

--- Show the WEAPONSKILL.player_info_missing message
function MessageWeaponskill.show_player_info_missing()
    M.send('WEAPONSKILL', 'player_info_missing')
end

--- @param ws_name string|nil Weapon skill name (defaults to "WS")
function MessageWeaponskill.show_amnesia_error(ws_name)
    M.send('WEAPONSKILL', 'amnesia_error', {
        ws_name = ws_name or "WS"
    })
end

---============================================================================
--- TP CALCULATOR DEBUG MESSAGES
---============================================================================

--- @param current_tp number Current TP
--- @param tp_config any TP bonus config that failed validation (printed with tostring)
function MessageWeaponskill.show_tp_validation_failed(current_tp, tp_config)
    M.send('WEAPONSKILL', 'tp_validation_failed', {
        current_tp = tostring(current_tp),
        tp_config = tostring(tp_config)
    })
end

--- @param current_tp number TP before bonus
--- @param weapon_name string Weapon giving the bonus
--- @param weapon_bonus number Weapon TP bonus
--- @param real_tp number TP after bonus
function MessageWeaponskill.show_tp_calculation(current_tp, weapon_name, weapon_bonus, real_tp)
    M.send('WEAPONSKILL', 'tp_calculation', {
        current_tp = tostring(current_tp),
        weapon = tostring(weapon_name),
        weapon_bonus = tostring(weapon_bonus),
        real_tp = tostring(real_tp)
    })
end

--- Show the WEAPONSKILL.already_at_max message
function MessageWeaponskill.show_already_at_max()
    M.send('WEAPONSKILL', 'already_at_max')
end

--- @param target_threshold number Next TP threshold
--- @param gap number TP missing to reach it
function MessageWeaponskill.show_target_threshold(target_threshold, gap)
    M.send('WEAPONSKILL', 'target_threshold', {
        target_threshold = tostring(target_threshold),
        gap = tostring(gap)
    })
end

--- @param gap number TP missing
--- @param total_available number TP bonus available from gear
function MessageWeaponskill.show_gap_too_large(gap, total_available)
    M.send('WEAPONSKILL', 'gap_too_large', {
        gap = tostring(gap),
        total_available = tostring(total_available)
    })
end

--- @param total_available number TP bonus available from gear
function MessageWeaponskill.show_total_available(total_available)
    M.send('WEAPONSKILL', 'total_available', {
        total_available = tostring(total_available)
    })
end

--- @param piece_name string Gear piece
--- @param slot string Slot
--- @param bonus number TP bonus of the piece
--- @param gap number TP still missing
function MessageWeaponskill.show_checking_piece(piece_name, slot, bonus, gap)
    M.send('WEAPONSKILL', 'checking_piece', {
        piece_name = piece_name,
        slot = slot,
        bonus = tostring(bonus),
        gap = tostring(gap)
    })
end

--- @param slot string Slot
--- @param piece_name string Gear piece
--- @param bonus number TP bonus of the piece
--- @param gap number TP still missing
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

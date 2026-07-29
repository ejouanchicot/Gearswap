---============================================================================
--- WS Slots - Weapon-aware weaponskill macro slots
---============================================================================
--- Turns "one FFXI macro per weaponskill" into a fixed set of slot macros
--- (//gs c ws1 .. wsN) whose content follows the equipped weapon.
---
--- Each slot is a real Mote state (state.WS1, state.WS2, ...) rebuilt whenever
--- the weapon changes. Being real states means the HUD picks them up through
--- the normal keybind path, and each slot can be cycled in game to swap which
--- weaponskill it holds - the options are that weapon's whole list.
---
--- This mirrors how BST rebuilds state.species when the ecosystem changes.
---
--- Job-agnostic: the caller supplies the weapon key and its weaponskill list,
--- so any job with a weapon state can adopt it.
---
--- @file shared/utils/weaponskill/ws_slots.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-29
---============================================================================

local WSSlots = {}

--- Shown by a slot the current weapon does not fill.
local EMPTY = 'None'

--- Name of the Mote state backing a slot
--- @param index number Slot number
--- @return string
local function slot_state_name(index)
    return 'WS' .. index
end

--- Rebuild every slot state from a weaponskill list
--- Slot i defaults to entry i, but can be cycled through the whole list so the
--- player can reorder without touching the config.
--- @param ws_list table List of weaponskill names (may be shorter than max_slots)
--- @param max_slots number How many slots to (re)build
function WSSlots.rebuild(ws_list, max_slots)
    if not state then return end

    ws_list = ws_list or {}

    for i = 1, (max_slots or 0) do
        local name = slot_state_name(i)

        if ws_list[i] then
            state[name] = M { description = 'WS ' .. i, unpack(ws_list) }
            state[name]:set(ws_list[i])
        else
            state[name] = M { description = 'WS ' .. i, EMPTY }
        end
    end
end

--- Match the weapon actually equipped back to one of the weapon state's options
--- Each option names an equipment set (sets[key] = {main = ..., sub = ...}), so
--- the equipped main/sub pair identifies which option is really in hand.
--- Options sharing a main are told apart by the sub (Naegling vs NaeglingKC).
--- @param weapon_state table Mote state listing the weapon keys
--- @return string|nil Matching option, nil when nothing matches
function WSSlots.detect_weapon(weapon_state)
    if not (weapon_state and player and player.equipment and sets) then
        return nil
    end

    local equipped_main = player.equipment.main
    local equipped_sub = player.equipment.sub
    local same_main_only

    for i = 1, #weapon_state do
        local key = weapon_state[i]
        local weapon_set = sets[key]

        if type(weapon_set) == 'table' and weapon_set.main == equipped_main then
            if weapon_set.sub == equipped_sub then
                return key
            end
            same_main_only = same_main_only or key
        end
    end

    return same_main_only
end

--- Align the weapon state with what is equipped, then build the slots
--- Needed at load: a Mote state defaults to its first option, which has no
--- relation to the weapon actually in hand. Falls back to the state's current
--- value when the equipped weapon matches nothing (unknown weapon, empty hands).
--- @param weapon_state table Mote state listing the weapon keys
--- @param config table Config exposing get(weapon) and max_slots
--- @return string|nil Weapon key the slots were built for
function WSSlots.sync(weapon_state, config)
    if not (weapon_state and config) then
        return nil
    end

    local detected = WSSlots.detect_weapon(weapon_state)
    if detected and weapon_state.value ~= detected then
        weapon_state:set(detected)
    end

    local weapon = weapon_state.value
    WSSlots.rebuild(config.get(weapon), config.max_slots)

    return weapon
end

--- Weaponskill currently held by a slot
--- @param index number Slot number
--- @return string|nil Weaponskill name, nil when the slot is empty
function WSSlots.get(index)
    local slot = state and state[slot_state_name(index)]
    if not slot or slot.current == EMPTY then
        return nil
    end

    return slot.current
end

--- Fire the weaponskill held by a slot
--- @param index number Slot number
--- @return boolean True when a weaponskill was sent
function WSSlots.cast(index)
    local ws_name = WSSlots.get(index)

    if not ws_name then
        local ok, MessageFormatter = pcall(require, 'shared/utils/messages/message_formatter')
        if ok and MessageFormatter then
            MessageFormatter.show_warning('WS' .. tostring(index) .. ': no weaponskill for this weapon')
        end
        return false
    end

    send_command('input /ws "' .. ws_name .. '" <t>')

    return true
end

return WSSlots

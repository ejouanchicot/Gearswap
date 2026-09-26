---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Set Builder - idle and engaged set construction
---  ═══════════════════════════════════════════════════════════════════════════
---   Engaged, the same walk as Mote's get_melee_set for these sets:
---     sets.engaged, then .SW when single wielding (sets.engaged.SW exists),
---     then [OffenseMode] when that level defines it.
---   Single wield = nothing, a shield or a grip in the off hand
---   (WeaponResolver.is_offhand_weapon); the off hand is the SubWeapon
---   state's item, or the worn one while Combat Mode holds the weapons or
---   SubWeapon is 'Free' / has no item.
---   Idle: sets.idle[IdleMode] (Normal = sets.idle), sets.idle.Town /
---   sets.Adoulin in a city, then the weapons, then sets.MoveSpeed while
---   moving outside a city.
---   Weapons: MainWeapon / SubWeapon through WeaponResolver (a plain weapon
---   needs no set when config/WEAPON_CONFIG.lua turns equip_without_set on).
---   Mote's defense and Kiting layers (F10/F11, Alt+F10) are laid again on
---   the chosen base: Mote laid them on its own pick, which is replaced here.
---
---   @file    shared/jobs/blu/functions/logic/set_builder.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = {}

local BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
local WeaponResolver = require('shared/utils/equipment/weapon_resolver')
local MessageFormatter = require('shared/utils/messages/message_formatter')

---  ═══════════════════════════════════════════════════════════════════════════
---   WEAPONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Lay one weapon state's set over `result`.
--- @param result table
--- @param slot string 'main' or 'sub'
--- @param weapon_state table|nil Mote state
--- @return table
local function lay_weapon(result, slot, weapon_state)
    local weapon_set = weapon_state and WeaponResolver.set_for(slot, weapon_state.current)
    if not weapon_set then return result end
    local ok, combined = pcall(set_combine, result, weapon_set)
    if ok then return combined end
    MessageFormatter.show_error(('BLU: failed to apply %s weapon: %s'):format(slot, tostring(combined)))
    return result
end

--- Apply MainWeapon then SubWeapon.
--- @param result table
--- @return table
function SetBuilder.apply_weapon(result)
    result = lay_weapon(result, 'main', state.MainWeapon)
    return lay_weapon(result, 'sub', state.SubWeapon)
end

--- Mote's defense (sets.defense) and Kiting (sets.Kiting) layers.
--- @param result table
--- @return table
local function mote_layers(result)
    if apply_defense then result = apply_defense(result) end
    if apply_kiting then result = apply_kiting(result) end
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SINGLE WIELD
---  ═══════════════════════════════════════════════════════════════════════════

--- Item name of the off hand the engaged set is for.
--- @return string|nil
function SetBuilder.offhand_item()
    local worn = player and player.equipment and player.equipment.sub or nil
    local value = state.SubWeapon and state.SubWeapon.current
    if (state.CombatMode and state.CombatMode.current == 'On') or not value then
        return worn
    end
    local set = WeaponResolver.set_for('sub', value)
    local item = type(set) == 'table' and set.sub or nil
    if type(item) == 'table' then item = item.name end
    if type(item) ~= 'string' then return worn end
    return item
end

--- Whether that off hand leaves the player single wielding.
--- @param offhand string|nil Item name
--- @return boolean True for nothing, a shield or a grip
function SetBuilder.is_single_wield(offhand)
    if not offhand or offhand == '' or offhand == 'empty' then return true end
    return WeaponResolver.is_offhand_weapon(offhand) == false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ENGAGED
---  ═══════════════════════════════════════════════════════════════════════════

--- Mote's walk: sets.engaged -> .SW (single wield) -> [OffenseMode].
--- @param base_set table What Mote built
--- @return table set, string path (for the trace)
function SetBuilder.select_engaged_base(base_set)
    local result, path = sets.engaged or base_set, 'sets.engaged'
    local offhand = SetBuilder.offhand_item()
    if SetBuilder.is_single_wield(offhand) and result.SW then
        result, path = result.SW, path .. '.SW'
    end
    local mode = state.OffenseMode and state.OffenseMode.current
    if mode and result[mode] then
        result, path = result[mode], path .. '[' .. mode .. ']'
    end
    return result, path, offhand
end

--- Build the engaged set.
--- @param base_set table Engaged set from Mote
--- @return table
function SetBuilder.build_engaged_set(base_set)
    if not base_set then return {} end
    local result, path, offhand = SetBuilder.select_engaged_base(base_set)
    result = SetBuilder.apply_weapon(mote_layers(result))
    require('shared/utils/debug/trace_log').log('ENGAGED', 'offense %s, off hand %s -> %s',
        tostring(state.OffenseMode and state.OffenseMode.current), tostring(offhand), path)
    return result
end

---  ═══════════════════════════════════════════════════════════════════════════
---   IDLE
---  ═══════════════════════════════════════════════════════════════════════════

SetBuilder.apply_movement = BaseSetBuilder.apply_movement
SetBuilder.check_town = BaseSetBuilder.select_idle_base_town

--- sets.idle[IdleMode], or the base set.
--- @param base_set table
--- @return table
function SetBuilder.select_idle_base(base_set)
    local mode = state.IdleMode and state.IdleMode.current
    if mode and sets.idle and sets.idle[mode] then
        return sets.idle[mode]
    end
    return base_set
end

--- Build the idle set.
--- @param base_set table Idle set from Mote
--- @return table
function SetBuilder.build_idle_set(base_set)
    if not base_set then return {} end
    local result, in_town = SetBuilder.check_town(SetBuilder.select_idle_base(base_set))
    result = SetBuilder.apply_weapon(mote_layers(result))
    if not in_town then
        result = SetBuilder.apply_movement(result)
    end
    return result
end

return SetBuilder

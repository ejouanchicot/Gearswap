---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Idle Module - Idle Set Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Picks the active idle set based on IdleMode (Normal / DT / Avatar) and
---   the AvatarFavor toggle. When state.AvatarFavor == true, sets.idle.Avatar
---   overrides whatever IdleMode says. Otherwise the town set replaces the
---   IdleMode set in town, as on the other jobs. Outside town, sets.MoveSpeed
---   is laid over the result while moving.
---
---   @file    shared/jobs/smn/functions/SMN_IDLE.lua
---   @author  Tetsouo
---   @version 1.1 - Town and movement steps from BaseSetBuilder
---   @date    Created: 2026-05-28 | Updated: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local BaseSetBuilder = nil

--- The idle set chosen by IdleMode, or Mote's own choice when none matches.
--- @param idleSet table The base idle set Mote selected
--- @return table The IdleMode set
local function select_mode_set(idleSet)
    if state.IdleMode then
        if state.IdleMode.value == 'DT' and sets.idle.DT then
            return sets.idle.DT
        end
        if state.IdleMode.value == 'Avatar' and sets.idle.Avatar then
            return sets.idle.Avatar
        end
        if state.IdleMode.value == 'Normal' and sets.idle.Normal then
            return sets.idle.Normal
        end
    end
    return idleSet
end

--- Apply runtime decisions on top of the static idle set selected by Mote.
--- @param idleSet table The base idle set Mote selected
--- @return table The set to actually equip
function customize_idle_set(idleSet)
    if not idleSet then return {} end

    if not BaseSetBuilder then
        BaseSetBuilder = require('shared/utils/set_building/base_set_builder')
    end

    local result, in_town
    if state.AvatarFavor and state.AvatarFavor.value == true and sets.idle.Avatar then
        -- Avatar's Favor toggle ALWAYS wins (master idle while avatar is up)
        result, in_town = sets.idle.Avatar, BaseSetBuilder.is_in_town()
    else
        result, in_town = BaseSetBuilder.select_idle_base_town(select_mode_set(idleSet))
    end

    if in_town then
        return result
    end
    return BaseSetBuilder.apply_movement(result)
end

_G.customize_idle_set = customize_idle_set

---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Idle Module - Idle Set Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   With an avatar out, sets.idle.Avatar (perpetuation, pet DT...; its
---   IdleMode child when defined, e.g. sets.idle.Avatar.DT); without one,
---   sets.idle[IdleMode] (Normal / DT). Mote re-dresses on summon / release.
---   Avatar's Favor (state.AvatarFavor, kept in step with the buff by
---   SMN_BUFFS) lays sets.buff["Avatar's Favor"] on top. Then, as on every
---   job, the town set on top in town, sets.MoveSpeed outside town.
---
---   @file    shared/jobs/smn/functions/SMN_IDLE.lua
---   @author  ejouanchicot
---   @version 1.1 - Town and movement steps from BaseSetBuilder
---   @date    Created: 2026-05-28 | Updated: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local BaseSetBuilder = nil

--- The idle set: sets.idle.Avatar (or its IdleMode child) with an avatar
--- out, else sets.idle[IdleMode], else Mote's own choice.
--- @param idleSet table The base idle set Mote selected
--- @return table
local function select_mode_set(idleSet)
    local mode = state.IdleMode and state.IdleMode.value
    local avatar = sets.idle.Avatar
    if pet and pet.isvalid and type(avatar) == 'table' then
        return (mode and type(avatar[mode]) == 'table') and avatar[mode] or avatar
    end
    if mode and type(sets.idle[mode]) == 'table' then
        return sets.idle[mode]
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

    local idle = select_mode_set(idleSet)
    local favor = sets.buff and sets.buff["Avatar's Favor"]
    if state.AvatarFavor and state.AvatarFavor.value == true and favor then
        idle = set_combine(idle, favor)
    end
    local result, in_town = BaseSetBuilder.select_idle_base_town(idle)

    if in_town then
        return result
    end
    return BaseSetBuilder.apply_movement(result)
end

_G.customize_idle_set = customize_idle_set

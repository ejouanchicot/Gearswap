---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Idle Module - Idle Set Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Picks the active idle set based on IdleMode (Normal / DT / Avatar) and
---   the AvatarFavor toggle. When state.AvatarFavor == true, sets.idle.Avatar
---   overrides whatever IdleMode says.
---
---   @file    shared/jobs/smn/functions/SMN_IDLE.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

--- Apply runtime decisions on top of the static idle set selected by Mote.
--- @param idleSet table The base idle set Mote selected
--- @return table The set to actually equip
function customize_idle_set(idleSet)
    if not idleSet then return {} end

    -- Avatar's Favor toggle ALWAYS wins (master idle while avatar is up)
    if state.AvatarFavor and state.AvatarFavor.value == true and sets.idle.Avatar then
        return sets.idle.Avatar
    end

    -- IdleMode picks among Normal/DT
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

_G.customize_idle_set = customize_idle_set

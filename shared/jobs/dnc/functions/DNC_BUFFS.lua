---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Doom through the shared handler, then a gear refresh when Saber Dance or
---   Fan Dance starts or ends, since the engaged set is chosen from them.
---
---   @file    shared/jobs/dnc/functions/DNC_BUFFS.lua
---   @author  Tetsouo
---   @version 1.2 - Refresh engaged gear on dance gain/loss
---   @date    Updated: 2026-09-19
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

-- Buffs read by SetBuilder.select_engaged_base.
local DANCE_BUFFS = {
    ['Saber Dance'] = true,
    ['Fan Dance'] = true,
}

--- Re-equip the engaged set when a dance starts or ends.
--- Mote's buff_change equips nothing, so without this the dance set only
--- follows at the next action or status change.
--- @param buff string Buff name as GearSwap passes it (resource spelling)
local function on_dance_change(buff)
    if not DANCE_BUFFS[buff] then
        return
    end
    if not (player and player.status == 'Engaged') then
        return
    end
    -- Mid-action the aftercast re-equips anyway; equipping now would replace
    -- the gear of the action in progress.
    if midaction() then
        return
    end
    handle_equipping_gear(player.status)
end

job_buff_change = LifecycleManager.buff_change(on_dance_change)

-- Export to global scope (used by Mote-Include via include())
_G.job_buff_change = job_buff_change

---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Aftercast Module - Post-Action Cleanup
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared LifecycleManager handler (watchdog tick), plus the ammo
---   refill: after a ranged attack, when the ammo worn runs low, its own
---   quiver / pouch is opened (QuiverManager, which finds the container from
---   the ammo through item_index). Mote puts idle / engaged gear back itself.
---
---   @file    shared/jobs/rng/functions/RNG_AFTERCAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

-- Ammo left (inventory + wardrobes) at or under which the container is
-- opened. A Barrage fires several arrows at once, hence COR's margin
-- rather than THF's 5.
local AMMO_REFILL_AT = 15

--- Open the worn ammo's container when the stack runs low after a shot.
--- @param spell table
local function refill_ammo(spell)
    local ok, QuiverManager = pcall(require, 'shared/utils/inventory/quiver_manager')
    if ok and QuiverManager then
        QuiverManager.after_ranged_attack(spell, nil, nil, AMMO_REFILL_AT)
    end
end

job_aftercast = LifecycleManager.aftercast(function(spell, action, spellMap, eventArgs)
    refill_ammo(spell)
end)

_G.job_aftercast = job_aftercast

return { job_aftercast = job_aftercast }

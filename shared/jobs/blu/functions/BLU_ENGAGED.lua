---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_melee_set delegates to logic/set_builder.lua: sets.engaged,
---   .SW when single wielding, [OffenseMode], then the weapons.
---
---   @file    shared/jobs/blu/functions/BLU_ENGAGED.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

--- Build the engaged set (Mote hook)
--- @param meleeSet table The engaged set Mote built
--- @return table Modified engaged set
function customize_melee_set(meleeSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/blu/functions/logic/set_builder')
    end
    if not meleeSet then
        return {}
    end
    return SetBuilder.build_engaged_set(meleeSet)
end

_G.customize_melee_set = customize_melee_set

return { customize_melee_set = customize_melee_set }

---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_melee_set delegates to logic/set_builder.lua: sets.engaged,
---   [OffenseMode], .DT under Hybrid Mode DT, Mote's defense / Kiting
---   layers, then the weapons (main, sub, range).
---
---   @file    shared/jobs/rng/functions/RNG_ENGAGED.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

--- Build the engaged set (Mote hook)
--- @param meleeSet table The engaged set Mote built
--- @return table Modified engaged set
function customize_melee_set(meleeSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/rng/functions/logic/set_builder')
    end
    if not meleeSet then
        return {}
    end
    return SetBuilder.build_engaged_set(meleeSet)
end

_G.customize_melee_set = customize_melee_set

return { customize_melee_set = customize_melee_set }

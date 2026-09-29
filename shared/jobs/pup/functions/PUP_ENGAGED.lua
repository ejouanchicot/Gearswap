---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Engaged Module - Combat State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   customize_melee_set delegates to logic/set_builder.lua: sets.engaged
---   (or sets.engaged.Pet while the automaton fights too), [OffenseMode],
---   .DT, Overdrive, pet WS, then the weapon.
---
---   @file    shared/jobs/pup/functions/PUP_ENGAGED.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2026-09-29
---  ═══════════════════════════════════════════════════════════════════════════

local SetBuilder = nil

--- Build the engaged set (Mote hook)
--- @param meleeSet table The engaged set Mote built
--- @return table Modified engaged set
function customize_melee_set(meleeSet)
    if not SetBuilder then
        SetBuilder = require('shared/jobs/pup/functions/logic/set_builder')
    end
    if not meleeSet then
        return {}
    end
    return SetBuilder.build_engaged_set(meleeSet)
end

_G.customize_melee_set = customize_melee_set

return { customize_melee_set = customize_melee_set }

---============================================================================
--- BRD Engaged Module - Combat Gear Customization
---============================================================================
--- Handles engaged set customization for Bard job.
--- BRD rarely melees, but supports melee mode for subjobs like NIN/DNC.
---
--- @file BRD_ENGAGED.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

-- Load SetBuilder logic module
local SetBuilder = require('shared/jobs/brd/functions/logic/set_builder')

--- Customize engaged set based on conditions
--- @param meleeSet table Base engaged set from Mote
--- @return table Customized engaged set
function customize_melee_set(meleeSet)
    if not meleeSet then
        return {}
    end

    -- Use SetBuilder to apply modes
    return SetBuilder.build_engaged_set(meleeSet)
end

-- Export to global scope
_G.customize_melee_set = customize_melee_set

-- Export module
local BRD_ENGAGED = {}
BRD_ENGAGED.customize_melee_set = customize_melee_set

return BRD_ENGAGED

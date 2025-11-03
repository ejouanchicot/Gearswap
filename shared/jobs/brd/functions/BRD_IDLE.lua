---============================================================================
--- BRD Idle Module - Idle Gear Customization
---============================================================================
--- Handles idle set customization for Bard job.
--- Uses SetBuilder for mode selection and town detection.
---
--- @file BRD_IDLE.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-13
---============================================================================

-- Load SetBuilder logic module
local SetBuilder = require('shared/jobs/brd/functions/logic/set_builder')

--- Customize idle set based on conditions
--- @param idleSet table Base idle set from Mote
--- @return table Customized idle set
function customize_idle_set(idleSet)
    if not idleSet then
        return {}
    end

    -- Use SetBuilder to apply modes and conditions
    return SetBuilder.build_idle_set(idleSet)
end

-- Export to global scope
_G.customize_idle_set = customize_idle_set

-- Export module
local BRD_IDLE = {}
BRD_IDLE.customize_idle_set = customize_idle_set

return BRD_IDLE

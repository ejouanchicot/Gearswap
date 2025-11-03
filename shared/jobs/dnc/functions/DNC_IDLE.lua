---============================================================================
--- DNC Idle Module - Idle State Management
---============================================================================
--- Handles all idle state logic for Dancer job with dynamic gear selection.
---
--- Features:
---   • Idle set selection based on conditions (PDT/Normal)
---   • Movement speed optimization (Skadi's Jambeaux +1)
---   • Town gear management (Refresh/Regen priority)
---   • AFK safety measures (auto-PDT when idle)
---   • Dynamic weapon application to idle sets
---   • SetBuilder integration for modular set construction
---
--- Dependencies:
---   • SetBuilder (logic) - shared idle set construction
---
--- @file    DNC_IDLE.lua
--- @author  Tetsouo
--- @version 2.0 - Logic Extracted to logic/
--- @date    Created: 2025-10-04
--- @date    Updated: 2025-10-06
---============================================================================

-- Load DNC logic modules
local SetBuilder = require('shared/jobs/dnc/functions/logic/set_builder')

---============================================================================
--- IDLE HOOKS
---============================================================================

--- Called when player goes idle
--- @param new_status string New player status
--- @param old_status string Previous player status
function job_status_change(new_status, old_status)
    -- DNC-specific idle logic here
    -- Example: auto-PDT in dangerous areas, movement gear, etc.

    -- Placeholder for DNC idle implementation
end

--- Apply weapon sets and movement gear to all idle configurations
--- @param idleSet table The idle set to customize
--- @return table Modified idle set with current weapon and movement gear
function customize_idle_set(idleSet)
    -- Validate input
    if not idleSet then
        return {}
    end

    -- Build complete idle set using SetBuilder logic
    return SetBuilder.build_idle_set(idleSet)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make functions available globally for GearSwap
_G.job_status_change = job_status_change
_G.customize_idle_set = customize_idle_set

-- Also export as module for potential future use
local DNC_IDLE = {}
DNC_IDLE.job_status_change = job_status_change
DNC_IDLE.customize_idle_set = customize_idle_set

return DNC_IDLE

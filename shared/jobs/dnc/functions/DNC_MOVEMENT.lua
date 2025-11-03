---============================================================================
--- DNC Movement Management Module
---============================================================================
--- Handles movement-based buff management for Dancer with AutoMove integration.
---
--- Features:
---   • Movement status API (delegates to centralized AutoMove)
---   • Distance tracking (determines movement speed gear triggers)
---   • Position tracking (X/Y/Z coordinates)
---   • Haste Samba auto-off when moving (avoids wasting TP)
---   • Speed gear integration (Skadi's Jambeaux +1)
---
--- Dependencies:
---   • AutoMove - centralized position tracking system
---
--- @file    jobs/dnc/functions/DNC_MOVEMENT.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-04
---============================================================================

---============================================================================
--- MOVEMENT STATUS API
---============================================================================

--- Get current movement status (delegates to AutoMove)
--- @return table movement_info
function get_dnc_movement_status()
    if not AutoMove then
        return {
            is_moving = false,
            distance = 0,
            position = { x = 0, y = 0, z = 0 }
        }
    end

    return {
        is_moving = AutoMove.is_moving(),
        distance = AutoMove.get_last_distance(),
        position = AutoMove.get_position()
    }
end

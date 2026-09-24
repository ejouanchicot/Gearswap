---  ═══════════════════════════════════════════════════════════════════════════
---   THF Movement Management Module - Movement Detection & Speed Gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles movement-based equipment optimization for Thief using centralized
---   AutoMove position tracking for performance.
---
---   Features:
---   • Movement status API (delegates to AutoMove)
---   • Empty AutoMove callback (placeholder, does nothing)
---   Movement speed gear itself is laid by logic/set_builder.lua (idle only).
---
---   Dependencies:
---   • AutoMove (centralized movement tracking system)
---
---   @file    shared/jobs/thf/functions/THF_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-06
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTOMOVE REGISTRATION
---  ═══════════════════════════════════════════════════════════════════════════

-- Placeholder callback: registered but has no body.
if AutoMove then
    AutoMove.register_callback(function(is_moving, distance, player_status)
    end)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MOVEMENT STATUS API
---  ═══════════════════════════════════════════════════════════════════════════

---   Get current movement status (delegates to AutoMove)
---   @return table movement_info
function get_thf_movement_status()
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

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Make functions available globally
_G.get_thf_movement_status = get_thf_movement_status


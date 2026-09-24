---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Movement Management Module - Movement Detection & Speed Gear
---  ═══════════════════════════════════════════════════════════════════════════
---   Placeholder kept for the 12-module layout: movement is handled by the
---   shared AutoMove system.
---
---   @file    shared/jobs/drk/functions/DRK_MOVEMENT.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-23
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTOMOVE INTEGRATION (PERFORMANCE OPTIMIZED - No Startup Cost)
---  ═══════════════════════════════════════════════════════════════════════════
-- This file defines nothing. AutoMove sets state.Moving and triggers a gear
-- update; logic/set_builder.lua lays sets.MoveSpeed over the idle set.
-- If AutoMove is not loaded, movement speed gear is simply not available.

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════


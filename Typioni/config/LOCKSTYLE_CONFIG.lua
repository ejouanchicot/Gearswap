---============================================================================
--- Lockstyle Configuration - Centralized Lockstyle Timing Settings
---============================================================================
--- User-configurable settings for lockstyle application timing.
--- These delays are critical to prevent FFXI "Style lock mode disabled" errors.
---
--- FFXI enforces a cooldown on /lockstyleset commands. Through testing, 8 seconds
--- has been determined as the optimal delay that:
--- - Prevents "Style lock mode disabled" errors
--- - Allows rapid job switching without conflicts
--- - Provides enough time for DressUp addon management
---
--- @file config/LOCKSTYLE_CONFIG.lua
--- @author Typioni
--- @version 1.0
--- @date Created: 2025-10-03
---============================================================================
local LockstyleConfig = {}

---============================================================================
--- TIMING SETTINGS
---============================================================================

-- Initial load delay (when first loading job file or changing main job)
-- Applied when Typioni_WAR.lua or Typioni_PLD.lua loads
-- Recommended: 8.0 seconds (tested and validated)
LockstyleConfig.initial_load_delay = 8.0

-- Job change delay (when changing subjob via JobChangeManager)
-- Applied by job_change_manager.lua for subjob changes
-- Recommended: 8.0 seconds (tested and validated)
LockstyleConfig.job_change_delay = 8.0

-- Global lockstyle cooldown (minimum time between lockstyle commands)
-- Used by JobChangeManager to track when last lockstyle was applied
-- Recommended: 15.0 seconds (conservative safety margin)
LockstyleConfig.cooldown = 15.0

---============================================================================
--- NOTES
---============================================================================

-- Testing Results (2025-10-03):
-- - 5 seconds: Too short, causes "Style lock mode disabled" errors
-- - 7 seconds: Still too short for rapid job switching
-- - 8 seconds: Optimal - works even with rapid WAR → PLD → WAR switching
-- - 10+ seconds: Safe but unnecessarily slow

-- DressUp Addon Management:
-- Lockstyle application sequence with DressUp:
--   1. Unload DressUp addon (0.5s delay)
--   2. Apply /lockstyleset command
--   3. Reload DressUp addon (1.0s delay)
-- Total internal processing: ~2 seconds (handled by job lockstyle modules)

return LockstyleConfig

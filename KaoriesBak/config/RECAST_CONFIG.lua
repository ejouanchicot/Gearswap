---============================================================================
--- Recast Tolerance Configuration
---============================================================================
--- Centralized configuration for recast checks across all jobs and systems.
---
--- Problem: FFXI server and GearSwap client have synchronization lag.
--- When an ability appears "ready" in-game, GearSwap may still see 0.5-1.5s
--- remaining cooldown due to server/client latency.
---
--- Solution: Allow abilities/spells to be used when recast <= tolerance threshold
--- instead of strictly checking recast == 0.
---
--- @file config/RECAST_CONFIG.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-06
---============================================================================
local RECAST_CONFIG = {}

---============================================================================
--- CONFIGURATION
---============================================================================

--- Global recast tolerance in seconds
--- Abilities/spells are considered "ready" if recast <= this value
---
--- Recommended values:
--- - 1.0s: Conservative, safe for most scenarios
--- - 1.5s: Balanced, covers most lag situations (RECOMMENDED)
--- - 2.0s: Aggressive, rarely blocks but may trigger too early
RECAST_CONFIG.tolerance = 1.5

--- Enable/disable tolerance globally
--- If false, reverts to strict recast == 0 checks
RECAST_CONFIG.enabled = true

---============================================================================
--- HELPER FUNCTIONS
---============================================================================

--- Check if an ability/spell is ready based on recast time
--- @param recast number The recast time in seconds
--- @param custom_tolerance number|nil Optional custom tolerance (overrides global)
--- @return boolean True if ready (recast <= tolerance), false otherwise
function RECAST_CONFIG.is_ready(recast, custom_tolerance)
    if not recast then
        return false
    end

    -- If tolerance disabled, use strict check
    if not RECAST_CONFIG.enabled then
        return recast == 0
    end

    -- Use custom tolerance if provided, otherwise use global
    local threshold = custom_tolerance or RECAST_CONFIG.tolerance

    return recast <= threshold
end

--- Check if an ability/spell is on cooldown
--- @param recast number The recast time in seconds
--- @param custom_tolerance number|nil Optional custom tolerance
--- @return boolean True if on cooldown, false if ready
function RECAST_CONFIG.on_cooldown(recast, custom_tolerance)
    return not RECAST_CONFIG.is_ready(recast, custom_tolerance)
end

---============================================================================
--- BACKWARD COMPATIBILITY HELPERS
---============================================================================

--- Convert existing "recast == 0" checks to tolerance-aware checks
--- Usage: Replace "if recast == 0" with "if is_recast_ready(recast)"
--- @param recast number The recast time
--- @return boolean True if ready
function is_recast_ready(recast)
    return RECAST_CONFIG.is_ready(recast)
end

--- Convert existing "recast > 0" checks to tolerance-aware checks
--- Usage: Replace "if recast > 0" with "if is_on_cooldown(recast)"
--- @param recast number The recast time
--- @return boolean True if on cooldown
function is_on_cooldown(recast)
    return RECAST_CONFIG.on_cooldown(recast)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for easy access
_G.RECAST_CONFIG = RECAST_CONFIG
_G.is_recast_ready = is_recast_ready
_G.is_on_cooldown = is_on_cooldown

return RECAST_CONFIG

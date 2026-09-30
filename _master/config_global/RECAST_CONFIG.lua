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
--- Required by every job entry file; also exposes the global helpers
--- is_recast_ready() and is_on_cooldown() used by the shared job modules.
---
--- @file common/combat/RECAST_CONFIG.lua
--- @author ejouanchicot
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
--- - 1.5s: Balanced, covers most lag situations
--- - 2.0s: Aggressive, rarely blocks but may trigger too early (value in use)
RECAST_CONFIG.tolerance = 2.0

--- Enable/disable tolerance globally
--- If false, reverts to strict recast == 0 checks
RECAST_CONFIG.enabled = true

--- Party message when an ability or spell is refused on recast. Key = its
--- name, or the name of a recast several share ('Phantom Roll' covers every
--- roll). Value = the text sent with /p, where the game replaces
--- <recast=Name> with the time left, and {action} becomes the action tried
--- ("Bolter's Roll"); true = "<key> ready in <recast=<key>>".
--- Examples:
---   ['Phantom Roll'] = true,
---   ['Phantom Roll'] = '{action} : roll ready in <recast=Phantom Roll>',
---   ['Provoke'] = 'Provoke in <recast=Provoke>',
RECAST_CONFIG.party_announce = {
}

--- Seconds before the same message can be sent again (the game already
--- limits chat spam; this only drops a double press)
RECAST_CONFIG.party_announce_every = 1

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

--- Tolerance-aware replacement for "recast == 0"
--- @param recast number The recast time in seconds
--- @return boolean True if ready
function is_recast_ready(recast)
    return RECAST_CONFIG.is_ready(recast)
end

--- Tolerance-aware replacement for "recast > 0"
--- @param recast number The recast time in seconds
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

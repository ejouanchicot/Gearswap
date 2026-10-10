---============================================================================
--- Warp - the warp and teleport rings (//gs c warp...)
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file _common/travel/WARP_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- Seconds held once the ring reads ready, before it is used. The ring's own
    -- wait after it is equipped is the game's and cannot be shortened; lower this
    -- margin if your connection is good, raise it if the ring is used too early
    ring_safety = 3.5,
}

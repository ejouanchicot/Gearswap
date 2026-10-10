---============================================================================
--- Summoner - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file smn/combat/SMN_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- //gs c skillup: the avatar summoned, and the seconds before the Release
    -- (summon cast time + a margin)
    skillup = {avatar = 'Siren', release_after = 5.0},
}

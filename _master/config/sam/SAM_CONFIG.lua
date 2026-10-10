---============================================================================
--- Samurai - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file sam/combat/SAM_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- Your chosen stance (Hasso, or Seigan after //gs c seigan) when you engage,
    -- unless Hasso or Seigan is up
    auto_hasso = false,

    -- Third Eye before a weaponskill
    auto_third_eye_ws = true,

    -- Idle: sets.idle.Weak under this HP %, else sets.idle.Regen under that one
    idle_hp = {weak_below = 50, regen_below = 80},
}

---============================================================================
--- Black Mage - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file blm/combat/BLM_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- With a SCH subjob: Dark Arts before a nuke
    auto_dark_arts = true,

    -- With a SCH subjob: Klimaform before a storm (//gs c storm)
    auto_klimaform = true,
}

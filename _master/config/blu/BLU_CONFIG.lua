---============================================================================
--- Blue Mage - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file blu/combat/BLU_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- An unbridled spell cast without Unbridled Learning / Wisdom gets Unbridled
    -- Learning first, then goes again
    auto_unbridled = false,

    -- With Tizona, no Aftermath: Lv.3 and under 3000 TP, Expiacion is cancelled
    -- once; pressed again within 3 s, it goes
    expiacion_window = false,
}

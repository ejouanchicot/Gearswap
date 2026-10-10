---============================================================================
--- Geomancer - the job's own switches and thresholds
---============================================================================
--- The values below are the defaults. Change what you want; a line removed
--- (or commented out) goes back to its default, and in a table the keys you
--- give are enough.
---
--- @file geo/combat/GEO_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-10-10
---============================================================================

return {
    -- An Indi- cast on a party member gets Entrust first
    auto_entrust = false,

    -- A Geo- cast while a luopan is out gets Full Circle first
    auto_full_circle = false,

    -- //gs c escort with no Indi- named
    escort_indi = 'Indi-Regen',
}

---============================================================================
--- BLM MP Conservation Configuration
---============================================================================
--- Configures MP thresholds for automatic MP conservation gear switching.
--- When current MP falls below the threshold, sets.midcast.MPConservation
--- is automatically combined with the base elemental magic set.
---
--- @file BLM_MP_CONFIG.lua
--- @author Kaories
--- @version 1.0
--- @date Created: 2025-10-25
---============================================================================

local BLMMPConfig = {}

---============================================================================
--- MP THRESHOLD CONFIGURATION
---============================================================================

--- MP threshold for triggering MP conservation gear
--- When current MP < mp_threshold, sets.midcast.MPConservation is applied
--- Default: 1000 MP
--- @type number
BLMMPConfig.mp_threshold = 1000

---============================================================================
--- USAGE NOTES
---============================================================================
--- How MP Conservation Works:
---   1. When casting Elemental Magic, current MP is checked
---   2. If MP < mp_threshold:
---      - Base set is selected (Normal or MagicBurst)
---      - sets.midcast.MPConservation is combined with base set
---      - Result: Base set + MP conservation overrides (e.g., Spaekona's Coat +4)
---   3. If MP >= mp_threshold:
---      - Base set is used without modifications
---
--- To change the threshold:
---   BLMMPConfig.mp_threshold = 1500  -- Trigger at 1500 MP instead of 1000
---
--- To configure which gear is equipped:
---   Edit sets.midcast.MPConservation in blm_sets.lua
---============================================================================

return BLMMPConfig

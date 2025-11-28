---============================================================================
--- BLM TP Configuration - TP Bonus Calculation for Weaponskills
---============================================================================
--- Configures TP bonus gear for weaponskills.
--- BLM rarely uses weaponskills, but configuration provided for completeness.
---
--- @file config/blm/BLM_TP_CONFIG.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-15
--- @requires utils/weaponskill/tp_bonus_calculator
---============================================================================

local BLMTPConfig = {}

---============================================================================
--- TP BONUS CONFIGURATION
---============================================================================

-- Moonshade Earring (+250 TP bonus at 1750-1999 TP)
BLMTPConfig.moonshade = {
    name = "Moonshade Earring",
    tp_bonus = 250
}

-- Minimal configuration (BLM rarely melees)
-- If BLM does use weaponskills, Moonshade is the only TP bonus gear

---============================================================================
--- MODULE EXPORT
---============================================================================

return BLMTPConfig

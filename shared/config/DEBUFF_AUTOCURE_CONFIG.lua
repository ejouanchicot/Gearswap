---============================================================================
--- Debuff Auto-Cure Configuration
---============================================================================
--- Configuration for automatic debuff curing system.
--- Controls which debuffs trigger auto-cure and testing options.
---
--- @file config/DEBUFF_AUTOCURE_CONFIG.lua
--- @author Tetsouo GearSwap Project
--- @version 1.0
--- @date Created: 2025-10-22
---============================================================================

local DebuffAutoCureConfig = {}

---============================================================================
--- TEST MODE CONFIGURATION
---============================================================================

-- Enable test mode (use Berserk to simulate Silence for testing)
-- When true: Berserk will trigger auto-cure system like Silence does
-- When false: Only real Silence triggers auto-cure
DebuffAutoCureConfig.test_mode = false

-- Test debuff to use (when test_mode = true)
-- Default: "Berserk" (easy to trigger with WAR subjob)
DebuffAutoCureConfig.test_debuff = "Berserk"

---============================================================================
--- AUTO-CURE SETTINGS
---============================================================================

-- Enable auto-cure for Silence
-- When true: Automatically use Echo Drops/Remedy when silenced
-- When false: Block spells but don't auto-cure
DebuffAutoCureConfig.auto_cure_silence = true

-- Silence cure items (in priority order)
-- System will try items in this order until one succeeds
DebuffAutoCureConfig.silence_cure_items = {
    { name = "Echo Drops", id = 4151 },  -- Priority 1
    { name = "Remedy", id = 4155 }       -- Priority 2 (fallback)
}

---============================================================================
--- PARALYSIS AUTO-CURE SETTINGS
---============================================================================

-- Enable auto-cure for Paralysis (blocks JA and WS)
-- When true: Automatically use Remedy/Panacea when paralyzed
-- When false: Block JA/WS but don't auto-cure
DebuffAutoCureConfig.auto_cure_paralysis = true

-- Paralysis cure items (in priority order)
-- System will try items in this order until one succeeds
-- NOTE: Both Paralysis (ID 4) and Paralyzed (ID 566) are curable with Remedy
DebuffAutoCureConfig.paralysis_cure_items = {
    { name = "Remedy", id = 4155 }       -- Remedy cures paralysis
}

---============================================================================
--- FUTURE EXPANSIONS (not yet implemented)
---============================================================================

-- Auto-cure for other debuffs (placeholder for future)
DebuffAutoCureConfig.auto_cure_poison = false
DebuffAutoCureConfig.auto_cure_blind = false

---============================================================================
--- DEBUG SETTINGS
---============================================================================

-- Show debug messages for auto-cure system
DebuffAutoCureConfig.debug = false

---============================================================================
--- MODULE EXPORT
---============================================================================

return DebuffAutoCureConfig

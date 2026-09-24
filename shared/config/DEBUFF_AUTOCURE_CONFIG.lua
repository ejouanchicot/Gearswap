---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff Auto-Cure Configuration - Automatic Debuff Removal System
---  ═══════════════════════════════════════════════════════════════════════════
---   Configuration for automatic debuff curing system.
---   Controls which debuffs trigger auto-cure and testing options.
---
---   Features:
---     • Auto-cure Silence (Echo Drops, Remedy)
---     • Auto-cure Paralysis (Remedy, Panacea)
---     • Test mode for development
---     • Debug logging support
---
---   Priority System:
---     • Silence: Echo Drops (Priority 1) → Remedy (Priority 2)
---     • Paralysis: Remedy (Priority 1) → Panacea (Priority 2)
---
---   @file    shared/config/DEBUFF_AUTOCURE_CONFIG.lua
---   @author  Tetsouo
---   @version 1.3 - Panacea added as paralysis fallback
---   @date    Updated: 2026-08-18
---  ═══════════════════════════════════════════════════════════════════════════

local DebuffAutoCureConfig = {}

---  ═══════════════════════════════════════════════════════════════════════════
---   TEST MODE CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

DebuffAutoCureConfig.test_mode   = false      -- Use test debuff instead of real debuffs
DebuffAutoCureConfig.test_debuff = "Berserk"  -- Test debuff (easy to trigger with WAR subjob)

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTO-CURE CONFIGURATION
---  ═══════════════════════════════════════════════════════════════════════════

---  ─────────────────────────────────────────────────────────────────────────
---   SILENCE (Blocks Magic Casting)
---  ─────────────────────────────────────────────────────────────────────────
DebuffAutoCureConfig.auto_cure_silence    = true
DebuffAutoCureConfig.silence_cure_items   = {
    { name = "Echo Drops", id = 4151 },  -- Priority 1: Cheapest, single-purpose
    { name = "Remedy",     id = 4155 }   -- Priority 2: Universal fallback
}

---  ─────────────────────────────────────────────────────────────────────────
---   PARALYSIS (Blocks JA/WS)
---  ─────────────────────────────────────────────────────────────────────────
DebuffAutoCureConfig.auto_cure_paralysis  = true
DebuffAutoCureConfig.paralysis_cure_items = {
    { name = "Remedy",     id = 4155 },  -- Priority 1: cures Paralysis (ID 4) + Paralyzed (ID 566)
    { name = "Panacea",    id = 4145 }   -- Priority 2: fallback when Remedy runs out
}

---  ─────────────────────────────────────────────────────────────────────────
---   FUTURE DEBUFFS (Not Implemented - nothing reads these two flags)
---  ─────────────────────────────────────────────────────────────────────────
DebuffAutoCureConfig.auto_cure_poison     = false
DebuffAutoCureConfig.auto_cure_blind      = false

---  ═══════════════════════════════════════════════════════════════════════════
---   DEBUG SETTINGS
---  ═══════════════════════════════════════════════════════════════════════════

DebuffAutoCureConfig.debug = false  -- Show debug messages for auto-cure system

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

return DebuffAutoCureConfig

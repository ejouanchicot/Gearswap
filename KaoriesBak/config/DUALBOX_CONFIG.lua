---============================================================================
--- Dual-Boxing Configuration - Kaories
---============================================================================
--- Configuration for dual-boxing system (inter-character communication).
---
--- Role: ALT
--- Envoie les mises à jour au personnage MAIN
---
--- @file config/DUALBOX_CONFIG.lua
--- @author Tetsouo GearSwap Project
--- @version 2.0
--- @date Created: 2025-10-22
---============================================================================

local DualBoxConfig = {}

---============================================================================
--- CHARACTER ROLE CONFIGURATION
---============================================================================

-- Role: "main" (receives updates) or "alt" (sends updates)
DualBoxConfig.role = "alt"

-- This character's name
DualBoxConfig.character_name = "Kaories"

-- MAIN character to send updates to
DualBoxConfig.main_character = "Tetsouo"

---============================================================================
--- SYSTEM SETTINGS
---============================================================================

-- Enable/disable dual-boxing system
DualBoxConfig.enabled = true

-- Timeout (seconds) - ALT considered offline after this delay
DualBoxConfig.timeout = 30

-- Debug mode (shows communication messages)
DualBoxConfig.debug = false

---============================================================================
--- LEGACY ALIASES (for backward compatibility)
---============================================================================

-- Old variable names (deprecated but kept for compatibility)
DualBoxConfig.main_name = DualBoxConfig.character_name
DualBoxConfig.alt_name = DualBoxConfig.main_character

---============================================================================
--- MODULE EXPORT
---============================================================================

return DualBoxConfig

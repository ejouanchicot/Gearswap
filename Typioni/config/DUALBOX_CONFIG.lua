---============================================================================
--- Dual-Boxing Configuration - Typioni
---============================================================================
--- Configuration for dual-boxing system (inter-character communication).
---
--- Role: MAIN
--- Reçoit les mises à jour des personnages ALT
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
DualBoxConfig.role = "main"

-- This character's name
DualBoxConfig.character_name = "Typioni"

-- ALT character to receive updates from
DualBoxConfig.alt_character = "None"

---============================================================================
--- SYSTEM SETTINGS
---============================================================================

-- Enable/disable dual-boxing system
DualBoxConfig.enabled = false

-- Timeout (seconds) - ALT considered offline after this delay
DualBoxConfig.timeout = 30

-- Debug mode (shows communication messages)
DualBoxConfig.debug = false

---============================================================================
--- LEGACY ALIASES (for backward compatibility)
---============================================================================

-- Old variable names (deprecated but kept for compatibility)
DualBoxConfig.main_name = DualBoxConfig.character_name
DualBoxConfig.alt_name = DualBoxConfig.alt_character

---============================================================================
--- MODULE EXPORT
---============================================================================

return DualBoxConfig

---============================================================================
--- Dual-Boxing Configuration - Tetsouo (Main Character)
---============================================================================
--- Centralized configuration for dual-boxing support between main and alt.
--- This file defines the role, character names, and communication settings.
---
--- @file DUALBOX_CONFIG.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-22
---============================================================================

local DualBoxConfig = {}

---============================================================================
--- ROLE CONFIGURATION
---============================================================================

-- Character role: "main" or "alt"
-- MAIN: Receives job updates from alt, selects appropriate macrobooks
-- ALT: Sends job updates to main when job changes
DualBoxConfig.role = "main"

---============================================================================
--- CHARACTER NAMES
---============================================================================

-- This character's name (the MAIN)
DualBoxConfig.character_name = "Tetsouo"

-- The ALT character to receive job updates from
DualBoxConfig.alt_character = "Kaories"

---============================================================================
--- COMMUNICATION SETTINGS
---============================================================================

-- Enable/disable dual-boxing system
DualBoxConfig.enabled = true

-- Timeout in seconds - if no update received within this time, assume alt offline
DualBoxConfig.timeout = 30

-- Debug mode - show detailed messages in chat
DualBoxConfig.debug = false

---============================================================================
--- EXPORT
---============================================================================

return DualBoxConfig

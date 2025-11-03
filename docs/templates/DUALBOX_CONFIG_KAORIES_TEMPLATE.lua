---============================================================================
--- Dual-Boxing Configuration - Kaories (Alt Character) - TEMPLATE
---============================================================================
--- Centralized configuration for dual-boxing support between main and alt.
--- This file defines the role, character names, and communication settings.
---
--- IMPORTANT: This is a TEMPLATE file!
--- After cloning Kaories character with clone_character.py, copy this file to:
---   Kaories/config/DUALBOX_CONFIG.lua
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
DualBoxConfig.role = "alt"  -- Kaories is the ALT character

---============================================================================
--- CHARACTER NAMES
---============================================================================

-- This character's name (the ALT)
DualBoxConfig.character_name = "Kaories"

-- The MAIN character to send job updates to
DualBoxConfig.main_character = "Tetsouo"

---============================================================================
--- COMMUNICATION SETTINGS
---============================================================================

-- Enable/disable dual-boxing system
DualBoxConfig.enabled = true

-- Timeout in seconds - if no update received within this time, assume main offline
-- (Not really used on ALT side, but kept for consistency)
DualBoxConfig.timeout = 30

-- Debug mode - show detailed messages in chat (set to true for troubleshooting)
DualBoxConfig.debug = false

---============================================================================
--- EXPORT
---============================================================================

return DualBoxConfig

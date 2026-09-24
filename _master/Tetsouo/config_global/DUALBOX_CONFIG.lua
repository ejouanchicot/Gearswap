---============================================================================
--- Dual-Boxing Configuration - Tetsouo (Main Character)
---============================================================================
--- Centralized configuration for dual-boxing support between main and alt.
--- This file defines the role, character names, and communication settings.
---
--- Loaded by shared/utils/dualbox/dualbox_manager.lua as
--- <Char>/config/DUALBOX_CONFIG and exposed as _G.DualBoxConfig.
---
--- @file Tetsouo/config/DUALBOX_CONFIG.lua
--- @author Tetsouo
--- @version 1.0.0
--- @date Created: 2025-10-22
---============================================================================

local DualBoxConfig = {}

---============================================================================
--- ROLE CONFIGURATION
---============================================================================

-- Character role: "main" or "alt"
-- Both boxes send and receive job updates and pick macrobooks from the other
-- box's job. The role decides which name below is the other box, and which
-- side sends buff reports (alt) and runs the alt commands (main).
DualBoxConfig.role = "main"

---============================================================================
--- CHARACTER NAMES
---============================================================================

-- This character's name (the MAIN)
DualBoxConfig.character_name = "Tetsouo"

-- The ALT character (the other box)
DualBoxConfig.alt_character = "Kaories"

---============================================================================
--- COMMUNICATION SETTINGS
---============================================================================

-- Enable/disable dual-boxing system
-- Characters of this box group. //gs c alts sends its orders to every one
-- but the character pressing the key, whichever of them is main today.
DualBoxConfig.group = {"Tetsouo", "Kaories"}
DualBoxConfig.enabled = true

-- Timeout in seconds - if no update received within this time, assume alt offline
DualBoxConfig.timeout = 30

-- Debug mode - show detailed messages in chat
DualBoxConfig.debug = false

---============================================================================
--- EXPORT
---============================================================================

return DualBoxConfig

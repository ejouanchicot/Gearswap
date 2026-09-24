---============================================================================
--- Dual-Boxing Configuration - Kaories
---============================================================================
--- Role: ALT - Sends state updates to the MAIN character
---
--- @file config/DUALBOX_CONFIG.lua
--- @version 2.0
---============================================================================

local DualBoxConfig = {}

DualBoxConfig.role = "alt"
DualBoxConfig.character_name = "Kaories"
DualBoxConfig.main_character = "Tetsouo"

-- Characters of this box group. //gs c alts sends its orders to every one
-- but the character pressing the key, whichever of them is main today.
DualBoxConfig.group = {"Tetsouo", "Kaories"}
DualBoxConfig.enabled = true
DualBoxConfig.timeout = 30
DualBoxConfig.debug = false

-- Legacy aliases
DualBoxConfig.main_name = DualBoxConfig.character_name
DualBoxConfig.alt_name = DualBoxConfig.main_character

return DualBoxConfig

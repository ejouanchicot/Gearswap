---  ═══════════════════════════════════════════════════════════════════════════
---   Craft Configuration - Per-Character Craft/Fish Lockstyle Numbers
---  ═══════════════════════════════════════════════════════════════════════════
---   Loaded by shared/utils/craft/craft_commands.lua via:
---       require(player.name .. '/config/CRAFT_CONFIG')
---
---   If this file is missing, defaults (craft=19, fish=17) are used.
---   Each cloned character can override by editing their own CRAFT_CONFIG.lua.
---
---   @file    Tetsouo/config/CRAFT_CONFIG.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-11
---  ═══════════════════════════════════════════════════════════════════════════

local CraftConfig = {}

-- Lockstyle number applied when //gs c craft is invoked
CraftConfig.craft_lockstyle = 19

-- Lockstyle number applied when //gs c fish is invoked
CraftConfig.fish_lockstyle  = 17

return CraftConfig

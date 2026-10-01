---  ═══════════════════════════════════════════════════════════════════════════
---   Craft Configuration - which craft / fishing set, and their lockstyles
---  ═══════════════════════════════════════════════════════════════════════════
---   Read by shared/utils/craft/craft_commands.lua on //gs c craft and
---   //gs c fish. After editing: //lua reload gearswap.
---
---   craft_file: the set file //gs c craft reads, in _common/sets/.
---       CraftConfig.craft_file = 'craft'         -> _common/sets/craft_sets.lua
---       CraftConfig.craft_file = 'goldsmithing'  -> _common/sets/goldsmithing_sets.lua
---       CraftConfig.craft_file = 'bonecraft'     -> _common/sets/bonecraft_sets.lua
---   fish_file: the same for //gs c fish ('fishing' -> _common/sets/fishing_sets.lua).
---   Left out, they read bonecraft_sets.lua and fishing_sets.lua.
---
---   craft_lockstyle / fish_lockstyle: the lockstyle set shown while crafting
---   or fishing (defaults 19 and 17); false: the job's lockstyle stays.
---
---   The food and items the refill keeps while crafting are in
---   _common/inventory/CRAFT_REFILL.lua; the bags it uses in _common/inventory/REFILL_CONFIG.lua.
---
---   @file    _common/inventory/CRAFT_CONFIG.lua
---   @author  ejouanchicot
---   @version 1.1 - craft_file / fish_file
---   @date    Created: 2026-05-11 | Updated: 2026-09-30
---  ═══════════════════════════════════════════════════════════════════════════

local CraftConfig = {}

-- Set file read by //gs c craft (_common/sets/<name>_sets.lua)
CraftConfig.craft_file = 'craft'

-- Set file read by //gs c fish (_common/sets/<name>_sets.lua)
CraftConfig.fish_file = 'fishing'

-- Lockstyle number applied when //gs c craft is invoked
CraftConfig.craft_lockstyle = 19

-- Lockstyle number applied when //gs c fish is invoked
CraftConfig.fish_lockstyle  = 17

return CraftConfig

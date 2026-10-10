---============================================================================
--- Addons - the Windower addons a job loads or unloads for you
---============================================================================
--- COR unloads rolltracker while you are COR (its own roll tracker replaces
--- it) and loads it back when you leave; BST loads bst-hud, GEO pettp, BLU
--- AzureSets, each unloaded when you leave the job.
--- All of them allowed below (the default). Set a name to false and the
--- job leaves that addon alone, e.g. you do not have it:
---     rolltracker = false,
---
--- @file _common/tools/ADDONS_CONFIG.lua
--- @author ejouanchicot
--- @date Created: 2026-09-30
---============================================================================

return {
    rolltracker = true,   -- COR (unloaded on COR, loaded back after)
    ['bst-hud'] = true,   -- BST
    pettp = true,         -- GEO
    AzureSets = true,     -- BLU
}

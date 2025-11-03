---============================================================================
--- DRG Job Abilities - Wyvern Pet Commands
---============================================================================
--- Dragoon wyvern pet commands (4 total)
---
--- Contents:
---   - Dismiss (Lv1) - Send wyvern away
---   - Smiting Breath (Lv90) - Order wyvern to attack with breath
---   - Restoring Breath (Lv90) - Order wyvern to heal with breath
---   - Steady Wing (Lv95) - Create damage barrier for wyvern
---
--- @file drg_pet_commands.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-31
--- @source https://www.bg-wiki.com/ffxi/Dragoon
---============================================================================

local DRG_PET_COMMANDS = {}

DRG_PET_COMMANDS.abilities = {
    ['Dismiss'] = {
        description = "Sends wyvern away",
        level = 1,
        recast = 0,
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Smiting Breath'] = {
        description = "Orders wyvern to attack with breath",
        level = 90,
        recast = 60,  -- 1 minute
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Restoring Breath'] = {
        description = "Orders wyvern to heal with breath",
        level = 90,
        recast = 60,  -- 1 minute
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    },
    ['Steady Wing'] = {
        description = "Create barrier that absorbs damage to wyvern",
        level = 95,
        recast = 180,  -- 3 minutes
        main_job_only = true,
        cumulative_enmity = 0,
        volatile_enmity = 80
    }
}

---============================================================================
--- MODULE EXPORT
---============================================================================

return DRG_PET_COMMANDS

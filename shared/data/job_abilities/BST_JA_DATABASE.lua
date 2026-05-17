---  ═══════════════════════════════════════════════════════════════════════════
---   BST Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads subjob/mainjob/sp + pet command modules into a flat
---   {ability_name = ability_data} table.
---
---   @file    BST_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based
---   @date    Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

local Factory = require('shared/data/job_abilities/JA_DATABASE_FACTORY')

return Factory.create('BST', {
    modules = {'subjob', 'mainjob', 'pet_commands_mainjob', 'pet_commands_subjob', 'sp'}
})

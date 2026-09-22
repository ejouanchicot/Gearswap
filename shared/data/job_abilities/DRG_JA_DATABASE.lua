---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads subjob/mainjob/sp ability modules into a flat
---   {ability_name = ability_data} table.
---
---   @file    DRG_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based
---   @date    Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

local Factory = require('shared/data/job_abilities/JA_DATABASE_FACTORY')

-- The pet commands live in their own module, so they have to be asked for:
-- the factory's default list is subjob/mainjob/sp only, and leaving it at
-- that meant the pet commands never had a job ability message.
return Factory.create('DRG', {
    modules = {'subjob', 'mainjob', 'sp', 'pet_commands'}
})

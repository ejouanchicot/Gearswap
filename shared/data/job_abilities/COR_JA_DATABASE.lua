---  ═══════════════════════════════════════════════════════════════════════════
---   COR Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads standard JA modules + Phantom
---   Rolls (subjob and mainjob variants) into a flat table.
---
---   Note (v2.0): The legacy wrapper required `cor/cor_rolls` which does not
---   exist on disk; the rolls live in `cor_rolls_subjob.lua` and
---   `cor_rolls_mainjob.lua`. The factory load now wires them in correctly.
---
---   @file    COR_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based + rolls path fix
---   @date    Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

local Factory = require('shared/data/job_abilities/JA_DATABASE_FACTORY')

return Factory.create('COR', {
    modules = {'subjob', 'mainjob', 'sp', 'rolls_subjob', 'rolls_mainjob'}
})

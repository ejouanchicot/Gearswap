---  ═══════════════════════════════════════════════════════════════════════════
---   DNC Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads 15 ability modules (waltzes, sambas, steps, flourishes, jigs) into a flat
---   {ability_name = ability_data} table.
---
---   @file    DNC_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based
---   @date    Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

local Factory = require('shared/data/job_abilities/JA_DATABASE_FACTORY')

return Factory.create('DNC', {
    modules = {
        'subjob', 'mainjob', 'sp',
        'waltzes_subjob', 'waltzes_mainjob',
        'sambas_subjob', 'sambas_mainjob',
        'steps_subjob', 'steps_mainjob',
        'flourishes1_subjob',
        'flourishes2_subjob', 'flourishes2_mainjob',
        'flourishes3_mainjob',
        'jigs_subjob', 'jigs_mainjob',
    }
})

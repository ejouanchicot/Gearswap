---  ═══════════════════════════════════════════════════════════════════════════
---   RUN Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads subjob/mainjob/sp ability modules into a flat
---   {ability_name = ability_data} table.
---
---   @file    shared/data/job_abilities/RUN_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based
---   @date    Created: 2025-11-03 | Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

return require('shared/data/job_abilities/JA_DATABASE_FACTORY').create('RUN')

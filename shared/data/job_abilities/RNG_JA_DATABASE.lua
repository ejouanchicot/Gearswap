---  ═══════════════════════════════════════════════════════════════════════════
---   RNG Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads subjob/mainjob/sp ability modules into a flat
---   {ability_name = ability_data} table.
---
---   @file    RNG_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based
---   @date    Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

return require('shared/data/job_abilities/JA_DATABASE_FACTORY').create('RNG')

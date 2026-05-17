---  ═══════════════════════════════════════════════════════════════════════════
---   SCH Job Ability Database
---  ═══════════════════════════════════════════════════════════════════════════
---   Wrapper around JA_DATABASE_FACTORY. Loads subjob/mainjob/sp + grimoire
---   modules (white & black, both subjob and mainjob variants) into a flat table.
---
---   Note (v2.0): Legacy wrapper only loaded `_subjob` grimoire variants. The
---   `_mainjob` grimoire files exist on disk and contain SCH-main-only abilities
---   (Altruism, Tranquility, Perpetuance, etc.). They are now wired in.
---
---   @file    SCH_JA_DATABASE.lua
---   @author  Tetsouo
---   @version 2.0 - Factory-based + mainjob grimoires fix
---   @date    Updated: 2026-05-06
---  ═══════════════════════════════════════════════════════════════════════════

local Factory = require('shared/data/job_abilities/JA_DATABASE_FACTORY')

return Factory.create('SCH', {
    modules = {
        'subjob', 'mainjob', 'sp',
        'white_grimoire_subjob', 'white_grimoire_mainjob',
        'black_grimoire_subjob', 'black_grimoire_mainjob',
    }
})

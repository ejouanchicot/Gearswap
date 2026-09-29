---  ═══════════════════════════════════════════════════════════════════════════
---   NIN Movement Module
---  ═══════════════════════════════════════════════════════════════════════════
---   AutoMove (started for every job by INIT_SYSTEMS) tracks movement; the
---   speed gear itself (sets.MoveSpeed, sets.MoveSpeed.Night from dusk to
---   dawn) is laid by logic/set_builder.lua, idle only. Nothing NIN-specific
---   here: the file stays for the 12-module layout.
---
---   @file    shared/jobs/nin/functions/NIN_MOVEMENT.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

return {}

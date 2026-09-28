---  ═══════════════════════════════════════════════════════════════════════════
---   DRK Status Module - Player Status Change Management
---  ═══════════════════════════════════════════════════════════════════════════
---   The shared status handler (LifecycleManager.status_change): Doom slot
---   unlock on death / raise, and the engaged / idle set held back while an
---   action is under way, like every other job. Until 2026-09-28 this file
---   only called DoomManager, so an engage in the middle of a spell swapped
---   the gear at once.
---
---   @file    shared/jobs/drk/functions/DRK_STATUS.lua
---   @author  ejouanchicot
---   @version 2.0
---   @date    Created: 2025-10-23 | Updated: 2026-09-28
---  ═══════════════════════════════════════════════════════════════════════════

local LifecycleManager = require('shared/utils/core/lifecycle_manager')

--- Status change hook, the shared one: DoomManager unlocks Doom slots on
--- death / raise, and an engage or disengage that lands during an action
--- (a spell, a weaponskill) waits for its aftercast instead of replacing the
--- action's gear at once. Mote-Include does the gear swaps.
job_status_change = LifecycleManager.status_change()

-- Export to global scope (Mote-Include) and to require()
_G.job_status_change = job_status_change

return {job_status_change = job_status_change}

---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Movement Management Module
---  ═══════════════════════════════════════════════════════════════════════════
---   Nothing BLM-specific: AutoMove tracks movement for every job
---   (INIT_SYSTEMS), and Impact's cloak is kept on through the cast by the
---   shared Impact lock (shared/utils/equipment/impact_lock.lua), which
---   replaced the job_handle_equipping_gear hook that lived here.
---
---   @file    shared/jobs/blm/functions/BLM_MOVEMENT.lua
---   @author  ejouanchicot
---   @version 1.1
---   @date    Created: 2025-10-15 | Updated: 2026-09-30
---   @requires shared/utils/movement/automove.lua
---  ═══════════════════════════════════════════════════════════════════════════

return {}

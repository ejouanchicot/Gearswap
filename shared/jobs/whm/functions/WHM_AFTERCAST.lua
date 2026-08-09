---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Aftercast Module - Aftercast State Management
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all aftercast logic for White Mage job:
---   • Return to idle/engaged state after spell completion
---   • Buff management and state updates
---   • Post-spell cleanup
---
---   @file    WHM_AFTERCAST.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   AFTERCAST HOOK
---  ═══════════════════════════════════════════════════════════════════════════

--- WHM adds nothing of its own: the shared handler is the whole
--- behaviour. Pass a function to aftercast() to extend it.
local LifecycleManager = require('shared/utils/core/lifecycle_manager')

job_aftercast = LifecycleManager.aftercast()

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_aftercast = job_aftercast

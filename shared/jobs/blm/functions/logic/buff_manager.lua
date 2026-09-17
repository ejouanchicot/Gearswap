---  ═══════════════════════════════════════════════════════════════════════════
---   BLM Buff Manager - Self-buff list for //gs c buff
---  ═══════════════════════════════════════════════════════════════════════════
---   The order is the casting order. SelfBuffManager drops the entries the
---   current job and subjob cannot cast, skips the buffs already up and the
---   spells still on recast, then sends the rest as one queue.
---
---   @file    jobs/blm/functions/logic/buff_manager.lua
---   @author  Tetsouo
---   @version 3.0 - Casting engine extracted to utils/buffs/self_buff_manager
---   @date    Created: 2025-10-15 | Updated: 2026-09-17
---  ═══════════════════════════════════════════════════════════════════════════

local SelfBuffManager = require('shared/utils/buffs/self_buff_manager')

--- Each delay is the wait the queue keeps after that cast, long enough for it
--- to finish. Stoneskin is a 7 second cast; the others take the default.
local BUFF_SPELLS = {
    { spell = 'Stoneskin',  delay = 8 },
    { spell = 'Blink' },
    { spell = 'Aquaveil' },
    { spell = 'Ice Spikes' }
}

local engine = SelfBuffManager.create({ buffs = BUFF_SPELLS, action_type = 'Magic' })

local BuffManager = {}

--- Cast every buff of the list that is missing and available
--- @return boolean True when casts were queued or a status was displayed
function BuffManager.BuffSelf()
    return engine.buff_self()
end

return BuffManager

---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Status Module - Player Status Change Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Delegates to DoomManager so Doom-locked slots are unlocked on death/raise.
---
---   @file    shared/jobs/smn/functions/SMN_STATUS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

--- Status change hook: lets DoomManager unlock Doom slots on death/raise.
--- @param newStatus string New player status
--- @param oldStatus string Previous player status
--- @param eventArgs table Event arguments
function job_status_change(newStatus, oldStatus, eventArgs)
    if not DoomManager then
        local dm_ok, dm = pcall(require, 'shared/utils/debuff/doom_manager')
        if not dm_ok then dm = nil end
        DoomManager = dm
    end
    if DoomManager then
        DoomManager.handle_status_change(newStatus, oldStatus)
    end
end

_G.job_status_change = job_status_change

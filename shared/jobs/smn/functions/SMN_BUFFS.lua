---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Delegates to DoomManager, and mirrors the Avatar's Favor buff into
---   state.AvatarFavor then sends `gs c update`, so sets.idle.Avatar swaps
---   in/out without the player toggling anything.
---
---   @file    shared/jobs/smn/functions/SMN_BUFFS.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

local DoomManager = nil

local function ensure_loaded()
    if DoomManager then return end
    local dm_ok, dm = pcall(require, 'shared/utils/debuff/doom_manager')
    if not dm_ok then dm = nil end
    DoomManager = dm
end

--- Buff change hook: Doom first, then Avatar's Favor sync.
--- @param buff string Buff name
--- @param gain boolean True on gain, false on loss
--- @param eventArgs table Event arguments
function job_buff_change(buff, gain, eventArgs)
    ensure_loaded()

    if DoomManager and DoomManager.handle_buff_change(buff, gain) then
        return
    end

    -- Avatar's Favor: keep state.AvatarFavor in sync with the actual buff.
    -- This lets sets.idle.Avatar swap automatically without a manual toggle.
    if buff == "Avatar's Favor" and state.AvatarFavor then
        state.AvatarFavor:set(gain)
        send_command('gs c update')
    end
end

_G.job_buff_change = job_buff_change

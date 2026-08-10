---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Buffs Module - Buff Gain/Loss Handler
---  ═══════════════════════════════════════════════════════════════════════════
---   Delegates to DoomManager and re-equips idle when Avatar's Favor toggles
---   (so sets.idle.Avatar swaps in/out without an explicit `gs c update`).
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

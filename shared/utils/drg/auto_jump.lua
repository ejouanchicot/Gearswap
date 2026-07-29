---============================================================================
--- Auto Jump - Trigger Jump before a Weapon Skill when TP is short
---============================================================================
--- Shared by every job that can sub /DRG. When a WS is attempted below the TP
--- threshold, the WS is cancelled, Jump (then High Jump if still short) is
--- fired to build TP, and the original WS is replayed automatically.
---
--- Gated by state.JumpAuto ('On' / 'Off') on the calling job.
---
--- Features:
---   • Chaining: Jump >> High Jump when TP is still under the threshold
---   • Auto-recast of the original WS once the sequence completes
---   • Re-entrancy guard so the replayed WS cannot start a second sequence
---   • Silent: the job's precast displays the normal JA messages
---   • Odyssey Sheol Gaol safe (subjob disabled reports level 0)
---
--- Timing:
---   • Single Jump: ~2.0s (1.0s animation + 1.0s gear swap)
---   • Double Jump: ~3.0s
---
--- @file shared/utils/drg/auto_jump.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2026-07-29
---============================================================================

local AutoJump = {}

-- is_recast_ready resolved as a global from RECAST_CONFIG.lua
-- (loaded by the entry point before job functions). Do not redeclare locally.

local JUMP_RECAST_ID = 158
local HIGH_JUMP_RECAST_ID = 159

--- Auto-jump only fires below this TP value.
local TP_THRESHOLD = 1000

--- Wait after a Jump so FFXI has credited the TP before it is read again.
local JUMP_ANIMATION_DELAY = 1.0

--- Wait before replaying the WS so the gear swap has completed.
local WS_DELAY_AFTER_JUMP = 1.0

--- Guard against re-entry: the replayed WS runs through precast again.
--- Global so it survives the coroutine boundaries of the sequence.
_G.AUTO_JUMP_SEQUENCE_ACTIVE = _G.AUTO_JUMP_SEQUENCE_ACTIVE or false

---============================================================================
--- AVAILABILITY
---============================================================================

local function is_jump_ready()
    local recasts = windower.ffxi.get_ability_recasts()
    return is_recast_ready(recasts[JUMP_RECAST_ID] or 0)
end

local function is_high_jump_ready()
    local recasts = windower.ffxi.get_ability_recasts()
    return is_recast_ready(recasts[HIGH_JUMP_RECAST_ID] or 0)
end

--- Pick the jump to use, preferring Jump over High Jump
--- @return string|nil Ability name, nil when both are on cooldown
local function get_available_jump()
    if is_jump_ready() then
        return 'Jump'
    elseif is_high_jump_ready() then
        return 'High Jump'
    end

    return nil
end

--- Whether /DRG is active and usable (level 0 means disabled, e.g. Sheol Gaol)
--- @return boolean
function AutoJump.is_drg_subjob()
    if not player or player.sub_job ~= 'DRG' then
        return false
    end

    return (player.sub_job_level or 0) > 0
end

--- Whether an auto-jump should fire for this spell
--- @param spell table Spell data
--- @return boolean
local function should_auto_jump(spell)
    if not spell or spell.type ~= 'WeaponSkill' then return false end
    if not AutoJump.is_drg_subjob() then return false end
    if not player.tp or player.tp >= TP_THRESHOLD then return false end

    return get_available_jump() ~= nil
end

---============================================================================
--- SEQUENCE
---============================================================================

--- Replay the original WS, then clear the re-entrancy guard
--- @param ws_name string
--- @param ws_target string
local function replay_ws(ws_name, ws_target)
    coroutine.schedule(function()
        send_command('input /ws "' .. ws_name .. '" ' .. ws_target)
        coroutine.schedule(function()
            _G.AUTO_JUMP_SEQUENCE_ACTIVE = false
        end, 0.5)
    end, WS_DELAY_AFTER_JUMP)
end

--- Fire the second jump when TP is still short, then replay the WS
--- @param first_jump string Ability already used
--- @param ws_name string
--- @param ws_target string
local function chain_second_jump(first_jump, ws_name, ws_target)
    if not player or player.tp >= TP_THRESHOLD then
        replay_ws(ws_name, ws_target)
        return
    end

    local second
    if first_jump == 'Jump' and is_high_jump_ready() then
        second = 'High Jump'
    elseif first_jump == 'High Jump' and is_jump_ready() then
        second = 'Jump'
    end

    if not second then
        replay_ws(ws_name, ws_target)
        return
    end

    send_command('input /ja "' .. second .. '" <t>')
    coroutine.schedule(function()
        replay_ws(ws_name, ws_target)
    end, JUMP_ANIMATION_DELAY)
end

--- Cancel the WS, build TP with Jump(s), then replay the WS
--- No-op unless /DRG, TP is short, a jump is ready and state.JumpAuto is On.
--- @param spell table     Spell data from job_precast
--- @param eventArgs table Event args (.cancel is set when the sequence starts)
function AutoJump.auto_trigger_jump(spell, eventArgs)
    if state and state.JumpAuto and state.JumpAuto.value == 'Off' then
        return
    end

    if _G.AUTO_JUMP_SEQUENCE_ACTIVE then
        return
    end

    if not should_auto_jump(spell) then
        return
    end

    local jump_ability = get_available_jump()
    if not jump_ability then
        return
    end

    _G.AUTO_JUMP_SEQUENCE_ACTIVE = true
    eventArgs.cancel = true

    local ws_name = spell.name
    local ws_target = (spell.target and spell.target.raw) or '<t>'

    send_command('input /ja "' .. jump_ability .. '" <t>')
    coroutine.schedule(function()
        chain_second_jump(jump_ability, ws_name, ws_target)
    end, JUMP_ANIMATION_DELAY)
end

---============================================================================
--- DIAGNOSTICS
---============================================================================

--- TP value below which auto-jump fires
--- @return number
function AutoJump.get_tp_threshold()
    return TP_THRESHOLD
end

--- Delay applied after each jump animation
--- @return number Seconds
function AutoJump.get_animation_delay()
    return JUMP_ANIMATION_DELAY
end

--- Snapshot of why auto-jump would or would not fire right now
--- @return table
function AutoJump.get_status()
    if not player then
        return { active = false, reason = 'No player data' }
    end

    local status = {
        active = false,
        subjob = player.sub_job,
        tp = player.tp,
        tp_threshold = TP_THRESHOLD,
        jump_ready = is_jump_ready(),
        high_jump_ready = is_high_jump_ready(),
        available_jump = get_available_jump(),
    }

    if player.sub_job ~= 'DRG' then
        status.reason = 'Not /DRG'
    elseif (player.sub_job_level or 0) == 0 then
        status.reason = 'Subjob disabled (Odyssey/level 0)'
    elseif player.tp >= TP_THRESHOLD then
        status.reason = 'TP >= ' .. TP_THRESHOLD
    elseif not status.available_jump then
        status.reason = 'No Jump available (cooldown)'
    else
        status.active = true
        status.reason = 'Auto-Jump active'
    end

    return status
end

return AutoJump

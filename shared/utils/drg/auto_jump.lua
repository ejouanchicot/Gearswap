---============================================================================
--- Auto Jump - Trigger Jump before a Weapon Skill when TP is short
---============================================================================
--- Every job on /DRG. When a WS is attempted below the TP
--- threshold, the WS is cancelled, Jump (then High Jump if still short) is
--- fired to build TP, and the original WS is replayed automatically.
---
--- Called by WSPrecastHandler.handle, after the range check and before the
--- TP check, so no job wires it by hand.
---
--- Gated by state.JumpAuto: fires only when it is 'On'. Every job gets the
--- state (attach, called by KeybindManager.create): Off by default, its row in
--- the HUD and its key shown only on /DRG. A job whose STATES file defines
--- JumpAuto keeps its own default; a job whose KEYBINDS file has a JumpAuto
--- row keeps its own key.
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
--- @file    shared/utils/drg/auto_jump.lua
--- @author  ejouanchicot
--- @version 1.0
--- @date    Created: 2026-07-29
---============================================================================

local AutoJump = {}

--- Key of the Jump Auto row on a job whose keybind file has none (free on
--- every job of the project).
local DEFAULT_KEY = '!numpad-'

-- is_recast_ready resolved as a global from RECAST_CONFIG.lua
-- (loaded by the entry point before job functions). Do not redeclare locally.

local JUMP_RECAST_ID = 158
local HIGH_JUMP_RECAST_ID = 159

--- Auto-jump only fires below this TP value.
local TP_THRESHOLD = 1000

-- TP read from the game: GearSwap's player.tp trails it, and is never
-- refreshed inside the coroutines that chain the second jump
local live_tp = require('shared/utils/core/live_tp')

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

--- @return boolean True when Jump is off cooldown
local function is_jump_ready()
    local recasts = windower.ffxi.get_ability_recasts()
    return is_recast_ready(recasts[JUMP_RECAST_ID] or 0)
end

--- @return boolean True when High Jump is off cooldown
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
    if live_tp() >= TP_THRESHOLD then return false end

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
    if live_tp() >= TP_THRESHOLD then
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
    if not (state and state.JumpAuto and state.JumpAuto.value == 'On') then
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
--- STATE AND KEY
---============================================================================

--- Give the job its Jump Auto state and row. Creates state.JumpAuto (Off)
--- when the job's STATES file has none, adds a row with DEFAULT_KEY when the
--- job's KEYBINDS file has none, and shows the row only on /DRG.
--- @param job string Job code (unused, same signature as the other attach)
--- @param binds table The job's bind list
function AutoJump.attach(job, binds)
    if state and not rawget(state, 'JumpAuto') then
        state.JumpAuto = M {['description'] = 'Jump Auto', 'Off', 'On'}
    end
    local entry = nil
    for _, bind in ipairs(binds) do
        if type(bind) == 'table' and bind.state == 'JumpAuto' then entry = bind break end
    end
    if not entry then
        entry = {key = DEFAULT_KEY, command = 'cyclestate JumpAuto', desc = 'Jump Auto', state = 'JumpAuto'}
        binds[#binds + 1] = entry
    end
    entry.subjob = entry.subjob or 'DRG'
end

---============================================================================
--- DIAGNOSTICS
---============================================================================

return AutoJump

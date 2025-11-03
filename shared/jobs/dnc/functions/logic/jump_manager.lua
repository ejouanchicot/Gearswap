---============================================================================
--- Jump Manager - Auto-Jump Integration for DNC/DRG (Logic Module)
---============================================================================
--- Manages automatic Jump/High Jump trigger before Weapon Skills when TP < 1000.
--- Provides TP gain optimization with intelligent chaining.
---
--- Features:
---   • Auto-trigger Jump if TP < 1000 before WS (controllable via JumpAuto state)
---   • Intelligent chaining: Jump → High Jump if TP still < 1000 after first Jump
---   • Auto-recast WS after Jump sequence completes (no manual re-launch needed)
---   • Ultra-fast timing: 0.5s animation delay (quasi-instant like in-game)
---   • Silent execution: No messages (job_precast displays normal JA messages)
---   • Odyssey Sheol Gaol fix (detects subjob disabled, level = 0)
---   • DRG subjob validation (must be active with level > 0)
---   • Diagnostic API for debugging (get_status, is_drg_subjob)
---
--- Performance:
---   • Single Jump: ~1.7s total (0.5s anim + 1.2s gear swap delay)
---   • Double Jump: ~2.2s total (2x 0.5s anim + 1.2s gear swap delay)
---
--- @file    jobs/dnc/functions/logic/jump_manager.lua
--- @author  Tetsouo
--- @version 3.0 - Silent Execution (Messages in job_precast)
--- @date    Created: 2025-10-08
--- @date    Updated: 2025-10-29 (Silent: removed all messages, job_precast handles display)
---============================================================================

local JumpManager = {}

-- Load dependencies
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrapper for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        -- Fallback: simple check (no tolerance)
        return (recast == 0)
    end
end

-- Jump ability recast IDs
local JUMP_RECAST_ID = 158
local HIGH_JUMP_RECAST_ID = 159

-- Configuration
local TP_THRESHOLD = 1000  -- Auto-Jump if TP below this value
local JUMP_ANIMATION_DELAY = 1.0  -- Seconds to wait after Jump animation (allow TP update)
local WS_DELAY_AFTER_JUMP = 1.0  -- Delay before WS after Jump (allow gear swap completion)

---============================================================================
--- JUMP AVAILABILITY CHECKS
---============================================================================

--- Check if Jump ability is available (not on cooldown)
--- @return boolean True if Jump is ready
local function is_jump_ready()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local jump_recast = ability_recasts[JUMP_RECAST_ID] or 0
    return is_recast_ready(jump_recast)
end

--- Check if High Jump ability is available (not on cooldown)
--- @return boolean True if High Jump is ready
local function is_high_jump_ready()
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local high_jump_recast = ability_recasts[HIGH_JUMP_RECAST_ID] or 0
    return is_recast_ready(high_jump_recast)
end

--- Determine which Jump ability to use (prioritize Jump over High Jump)
--- @return string|nil Jump ability name or nil if none available
local function get_available_jump()
    if is_jump_ready() then
        return "Jump"
    elseif is_high_jump_ready() then
        return "High Jump"
    end
    return nil
end

---============================================================================
--- AUTO-JUMP LOGIC
---============================================================================

--- Check if auto-jump should trigger for this WS
--- @param spell table Spell data (WeaponSkill)
--- @return boolean True if should auto-jump
local function should_auto_jump(spell)
    -- Must be a WeaponSkill
    if not spell or spell.type ~= 'WeaponSkill' then
        return false
    end

    -- Must have player data
    if not player then
        return false
    end

    -- Must be DNC/DRG subjob
    if player.sub_job ~= 'DRG' then
        return false
    end

    -- ODYSSEY FIX: Subjob must be active (level > 0)
    -- In Odyssey Sheol Gaol, player.sub_job_level = 0 (subjob disabled)
    if not player.sub_job_level or player.sub_job_level == 0 then
        return false
    end

    -- TP must be below threshold
    if player.tp >= TP_THRESHOLD then
        return false
    end

    -- At least one Jump ability must be available
    if not get_available_jump() then
        return false
    end

    return true
end

--- Execute auto-jump with chaining: Triggers Jump, then High Jump if TP still < 1000
--- Automatically recasts the original WS after Jump sequence completes
--- @param spell table Spell data (WeaponSkill)
--- @param eventArgs table Event arguments (will set cancel = true)
function JumpManager.auto_trigger_jump(spell, eventArgs)
    -- Check if auto-trigger is enabled (state.JumpAuto)
    if state and state.JumpAuto and state.JumpAuto.value == 'Off' then
        return  -- Auto-trigger disabled by user
    end

    -- Prevent infinite loop: Check if we're in a Jump sequence already
    if _G.DNC_JUMP_SEQUENCE_ACTIVE then
        return  -- Already in Jump sequence, don't trigger again
    end

    -- Check if auto-jump should trigger
    if not should_auto_jump(spell) then
        return
    end

    -- Get available jump ability
    local jump_ability = get_available_jump()
    if not jump_ability then
        return
    end

    -- Set flag to prevent re-triggering during this sequence
    _G.DNC_JUMP_SEQUENCE_ACTIVE = true

    -- Cancel the original WS (will auto-recast after Jump sequence)
    eventArgs.cancel = true

    -- Store WS name and target for auto-recast
    local ws_name = spell.name
    local ws_target = spell.target and spell.target.raw or '<t>'

    -- Execute first Jump (messages handled by job_precast normally)
    send_command('input /ja "' .. jump_ability .. '" <t>')

    -- Schedule TP check after first Jump animation
    coroutine.schedule(function()
        if not player then
            return
        end

        -- Check if TP still below threshold
        if player.tp < TP_THRESHOLD then
            -- Determine second Jump (opposite of first)
            local second_jump = nil
            if jump_ability == "Jump" and is_high_jump_ready() then
                second_jump = "High Jump"
            elseif jump_ability == "High Jump" and is_jump_ready() then
                second_jump = "Jump"
            end

            -- Execute second Jump if available
            if second_jump then
                -- Execute Jump (messages handled by job_precast normally)
                send_command('input /ja "' .. second_jump .. '" <t>')

                -- Auto-recast WS after second Jump animation completes
                coroutine.schedule(function()
                    -- Delay for gear swap completion before WS
                    coroutine.schedule(function()
                        send_command('input /ws "' .. ws_name .. '" ' .. ws_target)
                        -- Reset flag AFTER WS command sent (small delay to ensure WS processes)
                        coroutine.schedule(function()
                            _G.DNC_JUMP_SEQUENCE_ACTIVE = false
                        end, 0.5)
                    end, WS_DELAY_AFTER_JUMP)
                end, JUMP_ANIMATION_DELAY)
                return
            end
        end

        -- Single Jump completed - auto-recast WS after delay
        coroutine.schedule(function()
            send_command('input /ws "' .. ws_name .. '" ' .. ws_target)
            -- Reset flag AFTER WS command sent (small delay to ensure WS processes)
            coroutine.schedule(function()
                _G.DNC_JUMP_SEQUENCE_ACTIVE = false
            end, 0.5)
        end, WS_DELAY_AFTER_JUMP)
    end, JUMP_ANIMATION_DELAY)
end

---============================================================================
--- CONFIGURATION
---============================================================================

--- Get current TP threshold
--- @return number TP threshold value
function JumpManager.get_tp_threshold()
    return TP_THRESHOLD
end

--- Get Jump animation delay
--- @return number Delay in seconds
function JumpManager.get_animation_delay()
    return JUMP_ANIMATION_DELAY
end

--- Check if DNC/DRG subjob is active and available (not disabled in Odyssey)
--- @return boolean True if DNC/DRG with level > 0
function JumpManager.is_drg_subjob()
    if not player or player.sub_job ~= 'DRG' then
        return false
    end

    -- ODYSSEY FIX: Check subjob level (0 = disabled in Odyssey)
    if not player.sub_job_level or player.sub_job_level == 0 then
        return false
    end

    return true
end

---============================================================================
--- DIAGNOSTICS
---============================================================================

--- Get Jump system status for debugging
--- @return table Status information
function JumpManager.get_status()
    if not player then
        return { active = false, reason = "No player data" }
    end

    local status = {
        active = false,
        subjob = player.sub_job,
        tp = player.tp,
        tp_threshold = TP_THRESHOLD,
        jump_ready = is_jump_ready(),
        high_jump_ready = is_high_jump_ready(),
        available_jump = get_available_jump()
    }

    if player.sub_job ~= 'DRG' then
        status.reason = "Not DNC/DRG subjob"
    elseif not player.sub_job_level or player.sub_job_level == 0 then
        status.reason = "Subjob disabled (Odyssey/level 0)"
    elseif player.tp >= TP_THRESHOLD then
        status.reason = "TP >= " .. TP_THRESHOLD
    elseif not get_available_jump() then
        status.reason = "No Jump available (cooldown)"
    else
        status.active = true
        status.reason = "Auto-Jump active"
    end

    return status
end

return JumpManager

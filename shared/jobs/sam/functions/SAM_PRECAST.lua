---  ═══════════════════════════════════════════════════════════════════════════
---   SAM Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Guard >> Cooldown >> auto-Seigan before Third Eye (Seigan stance) >>
---   WSPrecastHandler >> auto-Third Eye before an accepted weaponskill.
---   Post-precast adds TP gear and the Sekkanoki / Meikyo Shisui WS layers.
---
---   @file    shared/jobs/sam/functions/SAM_PRECAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2025-10-21
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local SAMTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local cc_ok, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    if not cc_ok then cc = nil end
    CooldownChecker = cc

    local pg_ok, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    if not pg_ok then pg = nil end
    PrecastGuard = pg

    local wph_ok, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    if not wph_ok then wph = nil end
    WSPrecastHandler = wph

    SAMTPConfig = _G.SAMTPConfig or {}

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   SAM-SPECIFIC HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

-- Anti-loop guard: if Seigan is still down when the replayed Third Eye
-- arrives, let it through instead of queueing Seigan again. Cleared as soon
-- as Seigan is seen up, so the next Third Eye gets Seigan again.
local seigan_cast_attempted = false

--- The stance the player chose (state.Stance, set by //gs c hasso / seigan
--- and by any Hasso or Seigan used). A config without the state follows the
--- stance up: Hasso when Hasso is active, Seigan otherwise.
--- @return string 'Hasso' or 'Seigan'
local function chosen_stance()
    if state.Stance and state.Stance.value then
        return state.Stance.value
    end
    return buffactive.Hasso and 'Hasso' or 'Seigan'
end

--- Remember a Hasso or Seigan the player uses as the chosen stance.
--- @param spell table Spell data
local function remember_stance(spell)
    if state.Stance and (spell.english == 'Hasso' or spell.english == 'Seigan') then
        state.Stance:set(spell.english)
    end
end

---   Auto-cast Seigan before Third Eye when Seigan is the chosen stance and down.
---   Hasso chosen: Third Eye goes out alone (Seigan would replace Hasso).
---   @param spell table Spell data
---   @param eventArgs table Event arguments
---   @return boolean True when Third Eye was cancelled and re-queued after Seigan
local function try_seigan_before_third_eye(spell, eventArgs)
    if spell.english ~= 'Third Eye' or chosen_stance() ~= 'Seigan' then
        return false
    end

    if buffactive.Seigan then
        seigan_cast_attempted = false
        return false
    end

    if not seigan_cast_attempted then
        eventArgs.cancel = true
        seigan_cast_attempted = true
        send_command('input /ja Seigan <me>')
        send_command('@wait 1;input /ja "Third Eye" <me>')
        return true
    end

    seigan_cast_attempted = false
    return false
end

---   Auto-cast Third Eye before a weaponskill, when Third Eye is known, ready
---   (RECAST_CONFIG tolerance, like every other recast check) and not up.
---   Called only once WSPrecastHandler accepted the weaponskill: a weaponskill
---   out of range or under 1000 TP must not spend Third Eye.
---   @param spell table Spell data
---   @param eventArgs table Event arguments
---   @return boolean True when the WS was cancelled to cast Third Eye first
local function try_third_eye_ws(spell, eventArgs)
    if spell.type ~= 'WeaponSkill' or buffactive['Third Eye'] then
        return false
    end
    local AbilityHelper = require('shared/utils/precast/ability_helper')
    if not (AbilityHelper.can_use_ability('Third Eye') and AbilityHelper.is_ability_ready('Third Eye')) then
        return false
    end
    eventArgs.cancel = true
    -- The weaponskill is cancelled above, so the follow-up is the only thing
    -- left that will fire it: it goes out whether Third Eye lands or not,
    -- just sooner when the game refuses the ability outright.
    send_command('input /ja "Third Eye" <me>')
    AbilityHelper.follow_up('Third Eye',
        'input /ws "' .. spell.name .. '" ' .. spell.target.raw, 1.5)
    return true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Handle precast actions
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- FIRST: Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Cooldown check
    if CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        return
    end

    remember_stance(spell)

    -- SAM-SPECIFIC: Auto-cast Seigan before Third Eye (Seigan stance only)
    if try_seigan_before_third_eye(spell, eventArgs) then
        return
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, SAMTPConfig) then
        return
    end

    -- SAM-SPECIFIC: Third Eye before the WS, only for a WS the handler accepted
    if try_third_eye_ws(spell, eventArgs) then
        return
    end
end

---   Apply TP gear and the Sekkanoki / Meikyo Shisui layers for weaponskills
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Apply TP gear via unified handler
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- SAM-SPECIFIC: Apply buff gear for WS
    -- Read the buffs themselves: Mote sets state.Buff[name] true on the JA
    -- press, and a press cancelled on recast never gains the buff, so no
    -- buff_change ever sets it back to false.
    if spell.type == 'WeaponSkill' then
        -- Apply Sekkanoki buff gear
        if buffactive['Sekkanoki'] and sets.buff and sets.buff.Sekkanoki then
            equip(sets.buff.Sekkanoki)
        end

        -- Apply Meikyo Shisui buff gear
        if buffactive['Meikyo Shisui'] and sets.buff and sets.buff['Meikyo Shisui'] then
            equip(sets.buff['Meikyo Shisui'])
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}

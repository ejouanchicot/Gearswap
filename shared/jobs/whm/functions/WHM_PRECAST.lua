---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for White Mage job:
---   • Cure re-tiering by the target's need (CureManager)
---   • Paralyna on self while paralyzed: no gear swap
---   • Weaponskill validation and range checking
---   Fast Cast and job ability sets are left to Mote-Include.
---
---   Processing order:
---   1. PrecastGuard - Block casting under debuffs (Amnesia, Silence, Stun, etc.)
---   2. CureManager re-tier (before the cooldown check, see job_precast)
---   3. CooldownChecker - Universal ability/spell recast validation
---   4. Paralyna on self
---   5. WSPrecastHandler - Weaponskill range, validity and TP checks
---
---   @file    shared/jobs/whm/functions/WHM_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0.0
---   @date    Created: 2025-10-21
---   @requires shared/utils/messages/message_formatter, shared/utils/precast/cooldown_checker
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local WHMTPConfig = nil
local MessageWHM = nil
local CureManager = nil

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

    WHMTPConfig = _G.WHMTPConfig or {}

    local msg_ok, msg = pcall(require, 'shared/utils/messages/formatters/jobs/message_whm')
    if not msg_ok then msg = nil end
    MessageWHM = msg

    local cm_ok, cm = pcall(require, 'shared/utils/whm/cure_manager')
    if not cm_ok then cm = nil end
    CureManager = cm

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Swap a cure for the tier the target actually needs.
---
--- Casting Cure VI into a scratch wastes the MP and the cast time both. The
--- replacement goes out as a fresh command rather than editing the spell,
--- because by precast the tier is already fixed.
--- @param spell table Spell data from GearSwap
--- @param eventArgs table Event arguments (cancel is set when replaced)
--- @return boolean True when the cast was replaced
local function retier_cure(spell, eventArgs)
    if not (CureManager and spell.action_type == 'Magic') then
        return false
    end
    if not (spell.name:find('Cure') or spell.name:find('Curaga')) then
        return false
    end

    local target = spell.target and windower.ffxi.get_mob_by_id(spell.target.id)
    local new_spell = CureManager.select_cure_tier(spell, target)
    if not new_spell or new_spell == spell.name then
        return false
    end

    eventArgs.cancel = true
    send_command('input /ma "' .. new_spell .. '" ' .. spell.target.raw)
    return true
end

--- Curing your own paralysis: cast in whatever is worn, swap nothing.
---
--- Paralysis blocks the spell, never the equipment change - so this is not
--- about protecting the cast. It is about the blinking: a paralyzed Paralyna
--- is retried until it lands, and each attempt would swap the set on and off
--- again. (Timara WHM pattern.)
--- @param spell table Spell data from GearSwap
--- @param eventArgs table Event arguments (handled is set when it applies)
--- @return boolean True when this case applies
local function paralyna_on_self(spell, eventArgs)
    if spell.english == 'Paralyna' and buffactive['paralysis'] then
        eventArgs.handled = true
        return true
    end
    return false
end

--- Precast hook: guard, cure re-tier, cooldown, Paralyna on self, WS.
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- Cures are re-tiered before the recast check: the checker would cancel
    -- a tier on recast before CureManager could swap it for a ready one.
    -- A cure left as it is still goes through the check below.
    if retier_cure(spell, eventArgs) then
        return
    end

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

    if paralyna_on_self(spell, eventArgs) then
        return
    end

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, WHMTPConfig) then
        return
    end
end

---   Post-precast hook: TP gear for weaponskills.
---   Called after main precast set selection but before gear is equipped.
---
---   @param spell table Spell/ability data
---   @param action string Action type (not used)
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
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

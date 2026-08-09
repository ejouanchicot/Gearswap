---  ═══════════════════════════════════════════════════════════════════════════
---   WHM Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for White Mage job:
---   • Fast Cast optimization (all spell types)
---   • Job Abilities (Benediction, Devotion, Divine Seal, Asylum, etc.)
---   • Cure spell precast (fast cast + special gear)
---   • Enhancing magic precast (fast cast + duration gear preparation)
---   • Divine/Enfeebling magic precast
---   • Weaponskill validation and range checking
---   • Security layers (debuff guard >> cooldown check >> job logic)
---
---   Follows 4-layer PRECAST security architecture:
---   1. PrecastGuard - Block casting under debuffs (Amnesia, Silence, Stun, etc.)
---   2. CooldownChecker - Universal ability/spell recast validation
---   3. WSValidator - Weaponskill range and validity checks
---   4. WHM-specific logic - Job-specific enhancements
---
---   @file    WHM_PRECAST.lua
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

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    WHMTPConfig = _G.WHMTPConfig or {}

    local _, msg = pcall(require, 'shared/utils/messages/formatters/jobs/message_whm')
    MessageWHM = msg

    local _, cm = pcall(require, 'shared/utils/whm/cure_manager')
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
--- @return boolean True when this case applies
local function paralyna_on_self(spell, eventArgs)
    if spell.english == 'Paralyna' and buffactive.Paralyzed then
        eventArgs.handled = true
        return true
    end
    return false
end

function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
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

    if retier_cure(spell, eventArgs) then
        return
    end

    if paralyna_on_self(spell, eventArgs) then
        return
    end

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, WHMTPConfig) then
        return
    end
end

---   Post-precast hook for additional customizations
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

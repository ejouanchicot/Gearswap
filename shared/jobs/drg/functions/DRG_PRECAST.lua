---  ═══════════════════════════════════════════════════════════════════════════
---   DRG Precast Module - Precast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Processing order (do not reorder):
---   1. PrecastGuard       blocks under Silence / Amnesia / Stun..., cures
---                         with Remedy / Echo Drops when it can
---   2. CooldownChecker    ability / spell still on recast
---   3. WSPrecastHandler   range, 1000 TP minimum, TP bonus gear
---   Fast Cast, job ability and weaponskill sets are Mote's own picks
---   (sets.precast.FC, sets.precast.JA[name], sets.precast.WS[name]). The
---   wyvern orders (Restoring Breath, Smiting Breath...) are PetCommand in
---   the game's data: Mote looks for sets.precast.PetCommand, then falls
---   back to sets.precast.JA[name]. No DRG action drops a tier, so there is
---   no exception before the cooldown check.
---
---   @file    shared/jobs/drg/functions/DRG_PRECAST.lua
---   @author  ejouanchicot
---   @version 1.0
---   @date    Created: 2026-09-29
---   @requires PrecastGuard, CooldownChecker, WSPrecastHandler
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local DRGTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local cc_ok, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc_ok and cc or nil

    local pg_ok, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg_ok and pg or nil

    local wph_ok, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph_ok and wph or nil

    DRGTPConfig = _G.DRGTPConfig or {}
    modules_loaded = true
end

--- Cancel an ability or spell still on recast.
--- @param spell table Spell/ability data
--- @param eventArgs table Event arguments (cancel set when on recast)
local function check_cooldown(spell, eventArgs)
    if not CooldownChecker then return end
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Called before any action (WS, JA, spell, item)
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- 1. Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- 2. Cooldown check
    check_cooldown(spell, eventArgs)
    if eventArgs.cancel then
        return
    end

    -- 3. Weaponskill validation and TP bonus gear
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, DRGTPConfig) then
        return
    end
end

---   Called after Mote's precast set, before it is equipped
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
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

return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}

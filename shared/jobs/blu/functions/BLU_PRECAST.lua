---  ═══════════════════════════════════════════════════════════════════════════
---   BLU Precast Module - Precast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Processing order (do not reorder):
---   1. PrecastGuard       blocks under Silence / Amnesia / Stun..., cures
---                         with Remedy / Echo Drops when it can
---   2. CooldownChecker    ability / spell still on recast
---   3. Unbridled Learning before an unbridled spell (option blu_unbridled,
---                         logic/unbridled.lua)
---   4. Expiacion guard    held back under 3000 TP without Aftermath: Lv.3
---                         (option blu_expiacion_window, logic/expiacion_guard.lua)
---   5. WSPrecastHandler   range, 1000 TP minimum, TP bonus gear
---   Fast Cast, job ability and weaponskill sets are Mote's own picks
---   (sets.precast.FC['Blue Magic'], sets.precast.WS[name][WeaponskillMode]).
---
---   @file    shared/jobs/blu/functions/BLU_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-09-26
---   @requires PrecastGuard, CooldownChecker, WSPrecastHandler
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local BLUUnbridled = nil
local BLUExpiacionGuard = nil
local BLUTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local cc_ok, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc_ok and cc or nil

    local pg_ok, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg_ok and pg or nil

    local wph_ok, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph_ok and wph or nil

    local ul_ok, ul = pcall(require, 'shared/jobs/blu/functions/logic/unbridled')
    BLUUnbridled = ul_ok and ul or nil

    local ex_ok, ex = pcall(require, 'shared/jobs/blu/functions/logic/expiacion_guard')
    BLUExpiacionGuard = ex_ok and ex or nil

    BLUTPConfig = _G.BLUTPConfig or {}
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

    -- 3. Unbridled Learning first (config/AUTO_ABILITIES.lua)
    if BLUUnbridled then
        BLUUnbridled.apply(spell, eventArgs)
        if eventArgs.cancel or eventArgs.handled then
            return
        end
    end

    -- 4. Expiacion held back for the Aftermath: Lv.3 window (config/AUTO_ABILITIES.lua)
    if BLUExpiacionGuard and spell.type == 'WeaponSkill' and BLUExpiacionGuard.check(spell, eventArgs) then
        return
    end

    -- 5. Weaponskill validation and TP bonus gear
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BLUTPConfig) then
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

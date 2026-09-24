---  ═══════════════════════════════════════════════════════════════════════════
---   SMN Precast Module - Precast Action Handling
---  ═══════════════════════════════════════════════════════════════════════════
---   Pipeline: PrecastGuard >> CooldownChecker >> WS
---
---   Blood Pacts are geared in MIDCAST (SMN_MIDCAST / SMN_PET_MIDCAST).
---   In precast Mote looks for sets.precast[spell.type] then sets.precast.JA
---   by name; with neither defined, a Blood Pact gets no precast gear.
---
---   @file    shared/jobs/smn/functions/SMN_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2026-05-28
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil

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

    modules_loaded = true
end

--- True when the master fires a /pet Blood Pact command.
--- @param spell table Spell/ability data
--- @return boolean
local function is_blood_pact(spell)
    return spell.type == 'BloodPactRage' or spell.type == 'BloodPactWard'
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Pipeline order: PrecastGuard >> CooldownChecker >> WS >> job-specific
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- 1. PrecastGuard (FIRST - blocks if debuffed/dead/silenced/amnesia)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- 2. CooldownChecker (cancel if on cooldown)
    --    Blood Pacts use a master recast that GearSwap surfaces via recast_id;
    --    let CooldownChecker handle them like any other ability.
    if CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end
    if eventArgs.cancel then return end

    -- 3. Weaponskill handling (master rarely WSes but supported)
    if spell.type == 'WeaponSkill' then
        if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, {}) then
            return
        end
    end

    -- 4. Blood Pact: nothing to do here, the gear is equipped in midcast
    --    via blood_pact_classifier.
    if is_blood_pact(spell) then
        return
    end
end

--- Apply TP gear for weaponskills (SMN passes no TP config)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
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

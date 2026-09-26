---  ═══════════════════════════════════════════════════════════════════════════
---   COR Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for Corsair job (precast gear itself comes
---   from the sets through Mote):
---   • Phantom Roll: CorsairRoll class + last roll name for Double-Up
---   • Ranged attack: sets.precast.RA.Flurry1 / Flurry2 under Flurry
---     (shared/utils/precast/flurry_tracker.lua)
---   • Double-Up: wears the set of the roll it doubles; a roll already up
---     becomes a Double-Up (logic/double_up.lua)
---   • Quick Draw: CorsairShot class
---   • Crooked Cards: timestamp read by the roll tracker
---   • Luzaf's Ring on Phantom Roll and Double-Up (LuzafRing state, sets
---     precast.LuzafRing / LuzafRingOff of each character)
---
---   Processing Order (CRITICAL):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. COR-specific logic (Rolls, Double-Up, Quick Draw, Crooked Cards)
---   4. WS handling (WSPrecastHandler)
---   5. job_post_precast: WS TP gear, roll ring
---
---   @file    shared/jobs/cor/functions/COR_PRECAST.lua
---   @author  Tetsouo
---   @version 2.0
---   @date    Created: 2025-10-07
---   @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local CORTPConfig = nil

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

    CORTPConfig = _G.CORTPConfig or {}

    modules_loaded = true
end

-- Note: _G.cor_last_roll is initialized in roll_tracker.lua
-- Used for Double-Up gear matching via .name field

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Phantom Roll: remember the roll name so a following Double-Up can wear the
--- same set. Mote finds sets.precast.CorsairRoll[<roll>] by itself.
--- @param spell table Spell information from GearSwap
local function job_precast_corsairroll(spell)
    -- Track roll name for Double-Up to use same gear (using table structure)
    if not _G.cor_last_roll then
        _G.cor_last_roll = {}
    end
    _G.cor_last_roll.name = spell.english
end

--- Double-Up: equip the set of the last roll, or the base CorsairRoll set.
local function job_precast_double_up()
    -- Check if there's a specific set for this roll
    if sets.precast.CorsairRoll[_G.cor_last_roll.name] then
        equip(sets.precast.CorsairRoll[_G.cor_last_roll.name])
    else
        -- Fallback to base CorsairRoll set
        equip(sets.precast.CorsairRoll)
    end
end

--- COR's own precast handling.
---
--- Nothing in here stops the precast - the weaponskill handling still runs
--- afterwards, so none of these checks may return early.
--- @param spell table Spell information from GearSwap
local function apply_cor_precast(spell)
    -- Crooked Cards is recorded rather than acted on: the buff is consumed the
    -- moment the next roll goes out, so the roll tracker needs the timestamp
    -- to know it applied.
    if spell.type == 'JobAbility' and spell.english == 'Crooked Cards' then
        _G.cor_crooked_timestamp = os.time()
    end

    if spell.type == 'CorsairRoll' then
        job_precast_corsairroll(spell)
    end

    -- Ranged attack: Mote picks sets.precast.RA.Flurry1 / Flurry2 through
    -- classes.CustomRangedGroups while that Flurry is up
    if spell.action_type == 'Ranged Attack' then
        require('shared/utils/precast/flurry_tracker').apply_ranged_groups()
    end

    -- Double-Up wears the gear of the roll it is doubling, so it needs the
    -- last roll on record to know which that was.
    if spell.english == 'Double-Up' and _G.cor_last_roll and _G.cor_last_roll.name then
        job_precast_double_up()
    end
end

--- Precast hook: guard, Double-Up redirect, cooldown, COR logic, weaponskill.
--- @param spell table Spell information from GearSwap
--- @param action table Action information from GearSwap
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments (eventArgs.cancel for cancellation)
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- Before the cooldown check: a roll already up becomes a Double-Up,
    -- which the Phantom Roll recast must not cancel first
    if require('shared/jobs/cor/functions/logic/double_up').redirect(spell, eventArgs) then
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

    apply_cor_precast(spell)

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, CORTPConfig) then
        return
    end
end

--- Luzaf's Ring on a Phantom Roll or Double-Up (16 yalms instead of 8). Each
--- character's sets say where it goes and what replaces it:
---   ON   sets.precast.LuzafRing, else {left_ring = "Luzaf's Ring"}
---   OFF  sets.precast.LuzafRingOff, else nothing: the roll set's own ring
--- @param spell table Spell information from GearSwap
local function apply_luzaf(spell)
    if not (spell.type == 'CorsairRoll' or spell.english == 'Double-Up') then return end
    if not (state and state.LuzafRing) then return end
    if state.LuzafRing.value == 'ON' then
        equip(sets.precast.LuzafRing or {left_ring = "Luzaf's Ring"})
    elseif sets.precast.LuzafRingOff then
        equip(sets.precast.LuzafRingOff)
    end
end

---   Called after precast gear is equipped
---   @param spell table Spell/ability data
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    apply_luzaf(spell)
    -- //gs c rolldebug: note the gear this roll is sent in
    require('shared/jobs/cor/functions/logic/roll_debug').note_precast(spell)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Flurry I / II landing on this character (flurry_tracker.lua), once per load
require('shared/utils/precast/flurry_tracker').start()

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}


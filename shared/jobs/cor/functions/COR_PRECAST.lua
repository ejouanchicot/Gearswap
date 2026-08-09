---  ═══════════════════════════════════════════════════════════════════════════
---   COR Precast Module - Precast Action Handling & Cooldown Monitoring
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for Corsair job:
---   • Weaponskill precast (Fast Cast, TP bonus optimization)
---   • Phantom Roll precast (gear selection + roll tracking for Double-Up)
---   • Quick Draw precast (element-based shots)
---   • Ranged Attack precast (Snapshot gear)
---   • Job ability precast (Crooked Cards tracking)
---   • Fast Cast for subjob spells (NIN/DNC/RDM/etc.)
---   • Security layers (debuff guard, cooldown check, range validation)
---   • Luzaf's Ring management (16y vs 8y roll range)
---
---   Processing Order (CRITICAL):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. WS validation (WSPrecastHandler) - TP check + range check
---   4. COR-specific logic (Rolls, Quick Draw, Crooked Cards)
---   5. TP bonus calculation (TPBonusCalculator) - ranged WS optimization
---
---   @file    COR_PRECAST.lua
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

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    CORTPConfig = _G.CORTPConfig or {}

    modules_loaded = true
end

-- Note: _G.cor_last_roll is initialized in roll_tracker.lua
-- Used for Double-Up gear matching via .name field

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

--- Extracted from job_precast: the `spell.type == 'CorsairRoll'` branch.
local function job_precast_corsairroll(spell)
    -- Set custom class so Mote looks in sets.precast.CorsairRoll
    classes.CustomClass = 'CorsairRoll'

    -- Track roll name for Double-Up to use same gear (using table structure)
    if not _G.cor_last_roll then
        _G.cor_last_roll = {}
    end
    _G.cor_last_roll.name = spell.english
end

--- Extracted from job_precast: the `spell.english == 'Double-Up' and _G.cor_last_roll and _G.cor` branch.
local function job_precast_double_up()
    -- Check if there's a specific set for this roll
    if sets.precast.CorsairRoll[_G.cor_last_roll.name] then
        equip(sets.precast.CorsairRoll[_G.cor_last_roll.name])
    else
        -- Fallback to base CorsairRoll set
        equip(sets.precast.CorsairRoll)
    end
end

-- Spell type to the class name Mote looks the precast set up under.
local CUSTOM_CLASS_BY_TYPE = {
    ['CorsairShot']   = 'CorsairShot',
    ['Ranged Attack'] = 'RA',
}

--- COR's own precast handling.
---
--- Written as independent checks, not a chain, and it has to stay that way.
--- These are not alternatives: Double-Up is matched by name while the roll
--- sets are matched by type, and a spell can satisfy both. An `elseif` here
--- would silently drop one of them.
---
--- Nothing in here stops the precast either - the weaponskill handling still
--- runs afterwards, which an earlier automated split got wrong by making
--- these return.
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

    -- Double-Up wears the gear of the roll it is doubling, so it needs the
    -- last roll on record to know which that was.
    if spell.english == 'Double-Up' and _G.cor_last_roll and _G.cor_last_roll.name then
        job_precast_double_up()
    end

    local custom_class = CUSTOM_CLASS_BY_TYPE[spell.type]
    if custom_class then
        classes.CustomClass = custom_class
    end
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

    apply_cor_precast(spell)

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, CORTPConfig) then
        return
    end
end

---   Called after precast gear is equipped
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- Phantom Roll: Adjust ring based on Luzaf Ring state
    if spell.type == 'CorsairRoll' then
        if state and state.LuzafRing then
            if state.LuzafRing.value == 'ON' then
                -- Keep Luzaf's Ring (16y range)
                equip({left_ring = "Luzaf's Ring"})
            elseif state.LuzafRing.value == 'OFF' then
                -- Use Gurebu's Ring instead (8y range)
                equip({left_ring = "Gurebu's Ring"})
            end
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}


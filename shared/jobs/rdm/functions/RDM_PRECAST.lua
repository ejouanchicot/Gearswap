---  ═══════════════════════════════════════════════════════════════════════════
---   RDM Precast Module - Precast Action Handling & Fast Cast Optimization
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles all precast actions for Red Mage job:
---     • Fast Cast optimization (cap 80%)
---     • Weaponskills preparation & TP display
---     • Job ability precast (Convert, Chainspell, Saboteur, Composure)
---     • Enfeebling/Elemental spell precast
---     • Security layers (debuff guard, cooldown check, range validation)
---
---   @file    shared/jobs/rdm/functions/RDM_PRECAST.lua
---   @author  Tetsouo
---   @version 2.1 - Refactored header style
---   @date    Updated: 2025-11-12
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════
-- All modules are loaded on first action (lazy loading)

local MessageFormatter = nil
local MessagePrecast = nil
local CooldownChecker = nil
local AbilityHelper = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local TierRefiner = nil
local RDMEnfeebleTiers = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    -- Load all modules on first action
    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local _, mp = pcall(require, 'shared/utils/messages/formatters/magic/message_precast')
    MessagePrecast = mp

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, ah = pcall(require, 'shared/utils/precast/ability_helper')
    AbilityHelper = ah

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    local _, tr = pcall(require, 'shared/utils/precast/tier_refiner')
    TierRefiner = tr

    local _, tiers = pcall(require, 'shared/data/spells/RDM_ENFEEBLE_TIERS')
    RDMEnfeebleTiers = tiers

    modules_loaded = true
end

--- Resolve the tier mapping for a spell whose family has several tiers on RDM
--- @param spell table Spell from job_precast
--- @return table|nil Tier mapping, nil when the family has no tiers
local function get_enfeeble_tiers(spell)
    if not (TierRefiner and RDMEnfeebleTiers and spell and spell.name) then
        return nil
    end

    return RDMEnfeebleTiers.get(spell.name:match('^(%a+)'))
end

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - RDM SPECIFIC
---  ═══════════════════════════════════════════════════════════════════════════

-- RDM configuration
local RDMTPConfig = _G.RDMTPConfig or {}  -- Loaded from character main file

-- RDM Saboteur configuration (character-specific)
local RDMSaboteurConfig = _G.RDMSaboteurConfig or {
    auto_trigger_spells = {},
    wait_time = 2
}

---  ═══════════════════════════════════════════════════════════════════════════
---   DEBUG STATE (Global persist across reloads)
---  ═══════════════════════════════════════════════════════════════════════════

-- Initialize global debug state if not exists
if _G.PrecastDebugState == nil then
    _G.PrecastDebugState = false
end

local function is_precast_debug_enabled()
    return _G.PrecastDebugState == true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   PRECAST HOOKS
---  ═══════════════════════════════════════════════════════════════════════════

---   Called before any action (WS, JA, spell, etc.)
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---  ─────────────────────────────────────────────────────────────────────────
---   PRECAST STAGES
---  ─────────────────────────────────────────────────────────────────────────
---   Each stage returns true when the action must stop there. The order they
---   run in is the documented precast contract, and job_precast below is short
---   enough that the order is now the first thing you see.

---   Stage 1 - blocking debuffs: Amnesia, Silence, dead, and so on.
---   @return boolean True when the action is blocked
local function stage_guard(spell, eventArgs, debug_enabled)
    if debug_enabled then
        MessagePrecast.show_debug_step(1, 'PrecastGuard', 'info', 'Checking debuffs...')
    end

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        if debug_enabled then
            MessagePrecast.show_debug_step(1, 'PrecastGuard', 'fail', 'BLOCKED by debuff!')
        end
        return true
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(1, 'PrecastGuard', 'ok', 'No blocking debuffs')
    end
    return false
end

---   Stage 2 - recast, or a tier downgrade for enfeebles that have one.
---   @return boolean True when the action was cancelled
local function stage_cooldown(spell, eventArgs, debug_enabled)
    if debug_enabled then
        MessagePrecast.show_debug_step(2, 'Cooldown', 'info', 'Checking cooldown...')
    end

    -- Tiered enfeebles go through the refiner instead of the cooldown check:
    -- the checker would cancel the cast before any downgrade could happen.
    if spell.action_type == 'Ability' then
        if CooldownChecker then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        end
    elseif spell.action_type == 'Magic' then
        local correspondence = get_enfeeble_tiers(spell)

        if correspondence then
            TierRefiner.refine(spell, eventArgs, correspondence)
        elseif CooldownChecker then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        if debug_enabled then
            MessagePrecast.show_debug_step(2, 'Cooldown', 'fail', 'CANCELLED (on cooldown or blocked)')
        end
        return true
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(2, 'Cooldown', 'ok', 'Ready to use')
    end
    return false
end

---   Stage 3 - Phalanx picks its own tier by target.
---   Phalanx II on yourself is worse than Phalanx; on anyone else it is better.
---   @return boolean True when the cast was swapped for the other tier
local function stage_phalanx(spell, eventArgs)
    if not (spell.action_type == 'Magic' and spell.skill == 'Enhancing Magic') then
        return false
    end

    local spell_name = spell.english or spell.name
    if spell_name ~= 'Phalanx' and spell_name ~= 'Phalanx II' then
        return false
    end

    local target = spell.target
    local is_self = (target and target.name == player.name)
    local new_spell = nil

    if spell_name == 'Phalanx II' and is_self then
        new_spell = 'Phalanx'
        MessageFormatter.show_phalanx_downgrade()
    elseif spell_name == 'Phalanx' and not is_self then
        new_spell = 'Phalanx II'
        MessageFormatter.show_phalanx_upgrade()
    end

    if not new_spell then
        return false
    end

    eventArgs.cancel = true
    send_command('input /ma "' .. new_spell .. '" ' .. spell.target.raw)
    return true
end

---   Stage 4 - fire Saboteur ahead of the enfeebles configured for it.
---   Never stops the chain: the enfeeble still goes out either way.
local function stage_saboteur(spell, eventArgs, debug_enabled)
    if spell.action_type ~= 'Magic' then
        return
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(5, 'Magic (Fast Cast)', 'info', 'Skill: ' .. (spell.skill or 'Unknown'))
    end

    if spell.skill ~= 'Enfeebling Magic' then
        return
    end

    if not (state.SaboteurMode and state.SaboteurMode.current == 'On') then
        if debug_enabled then
            MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'info', 'Mode is Off')
        end
        return
    end

    if not RDMSaboteurConfig.auto_trigger_spells[spell.english] then
        if debug_enabled then
            MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'info', 'Not in auto-trigger list')
        end
        return
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'ok', 'Will trigger before ' .. spell.english)
    end
    AbilityHelper.try_ability_smart(spell, eventArgs, 'Saboteur', RDMSaboteurConfig.wait_time)
end

function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first action
    ensure_modules_loaded()

    -- Lock the weapon slots BEFORE any precast gear goes on, or midcast will
    -- happily equip a weapon out of a set.
    if state.CombatMode and state.CombatMode.current == "On" then
        disable('main', 'sub', 'range')
    end

    local debug_enabled = is_precast_debug_enabled()

    if debug_enabled then
        local action_type = spell.type or 'Unknown'
        local action_name = spell.english or spell.name or 'Unknown'
        MessagePrecast.show_debug_header(action_name, action_type)
    end

    -- Guard >> Cooldown >> job logic >> WS. This order is the contract; moving
    -- a line here changes behaviour even though nothing looks broken.
    if stage_guard(spell, eventArgs, debug_enabled) then return end
    if stage_cooldown(spell, eventArgs, debug_enabled) then return end
    if stage_phalanx(spell, eventArgs) then return end

    stage_saboteur(spell, eventArgs, debug_enabled)

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, RDMTPConfig) then
        return
    end

    if debug_enabled then
        MessagePrecast.show_completion()
    end
end

---   Apply final gear adjustments before equipping
---   NOTE: TP display now integrated in job_precast WS message
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
---   Name the set precast just equipped, for `//gs c debugprecast`.
---
---   This mirrors the resolution Mote does rather than observing it, so it is
---   a description and not a measurement: if a set stops matching what is
---   actually worn, this is the thing that drifted.
---   @param spell table Spell information from GearSwap
---   @return string Set name, table|nil The set itself when there is one
local function describe_equipped_set(spell)
    if spell.type == 'WeaponSkill' then
        if sets.precast.WS and sets.precast.WS[spell.english] then
            return "sets.precast.WS[" .. spell.english .. "]", sets.precast.WS[spell.english]
        elseif sets.precast.WS then
            return "sets.precast.WS (base)", sets.precast.WS
        end

    elseif spell.type == 'JobAbility' then
        if sets.precast.JA and sets.precast.JA[spell.english] then
            return "sets.precast.JA[" .. spell.english .. "]", sets.precast.JA[spell.english]
        elseif sets.precast.JA then
            return "sets.precast.JA (base)", sets.precast.JA
        end

    elseif spell.action_type == 'Magic' then
        if buffactive['Chainspell'] then
            return "No FC (Chainspell active)", nil
        elseif sets.precast.FC and sets.precast.FC[spell.english] then
            return "sets.precast.FC[" .. spell.english .. "]", sets.precast.FC[spell.english]
        elseif sets.precast.FC and spell.skill and sets.precast.FC[spell.skill] then
            return "sets.precast.FC[" .. spell.skill .. "]", sets.precast.FC[spell.skill]
        elseif sets.precast.FC then
            return "sets.precast.FC (base)", sets.precast.FC
        end

    elseif spell.type == 'RangedAttack' then
        return "sets.precast.RA", sets.precast.RA
    end

    return "Unknown", nil
end

function job_post_precast(spell, action, spellMap, eventArgs)
    local debug_enabled = is_precast_debug_enabled()

    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- Spell-specific Fast Cast sets (PRIORITY over generic FC)
    -- Example: sets.precast.FC["Stoneskin"] overrides sets.precast.FC
    if spell.action_type == 'Magic' and sets.precast.FC and sets.precast.FC[spell.english] then
        equip(sets.precast.FC[spell.english])
    end

    if debug_enabled then
        local set_name, gear_set = describe_equipped_set(spell)
        MessagePrecast.show_equipped_set(set_name)
        if gear_set then
            MessagePrecast.show_equipment(gear_set)
        end
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

-- Export to global scope for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}

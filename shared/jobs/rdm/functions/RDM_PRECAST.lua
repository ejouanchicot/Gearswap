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
-- All modules are loaded on first action (job_precast call)
-- This reduces startup time from ~150ms to ~5ms

local MessageFormatter = nil
local MessagePrecast = nil
local CooldownChecker = nil
local AbilityHelper = nil
local PrecastGuard = nil
local WSPrecastHandler = nil

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

    modules_loaded = true
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

--- Called before any action (WS, JA, spell, etc.)
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first action (saves ~150ms at startup)
    ensure_modules_loaded()

    -- ==========================================================================
    -- COMBAT MODE WEAPON LOCKING (SAFETY GUARD)
    -- ==========================================================================
    -- Ensure weapon slots are locked BEFORE precast gear is applied
    -- This prevents midcast from equipping weapons from sets
    if state.CombatMode and state.CombatMode.current == "On" then
        disable('main', 'sub', 'range')
    end

    local debug_enabled = is_precast_debug_enabled()

    -- DEBUG: Show precast entry
    if debug_enabled then
        local action_type = spell.type or 'Unknown'
        local action_name = spell.english or spell.name or 'Unknown'
        MessagePrecast.show_debug_header(action_name, action_type)
    end

    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if debug_enabled then
        MessagePrecast.show_debug_step(1, 'PrecastGuard', 'info', 'Checking debuffs...')
    end

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        if debug_enabled then
            MessagePrecast.show_debug_step(1, 'PrecastGuard', 'fail', 'BLOCKED by debuff!')
        end
        return -- Action blocked, exit immediately
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(1, 'PrecastGuard', 'ok', 'No blocking debuffs')
    end

    -- SECOND: Universal cooldown check
    if debug_enabled then
        MessagePrecast.show_debug_step(2, 'Cooldown', 'info', 'Checking cooldown...')
    end

    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if action was cancelled
    if eventArgs.cancel then
        if debug_enabled then
            MessagePrecast.show_debug_step(2, 'Cooldown', 'fail', 'CANCELLED (on cooldown or blocked)')
        end
        return
    end

    if debug_enabled then
        MessagePrecast.show_debug_step(2, 'Cooldown', 'ok', 'Ready to use')
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   PHALANX OPTIMIZATION (Auto-swap between Phalanx/Phalanx II)
    ---  ─────────────────────────────────────────────────────────────────────────
    -- Logic:
    --   - Phalanx II on self → Downgrade to Phalanx (better for self)
    --   - Phalanx on others → Upgrade to Phalanx II (better for others)
    if spell.action_type == 'Magic' and spell.skill == 'Enhancing Magic' then
        local spell_name = spell.english or spell.name

        if spell_name == 'Phalanx' or spell_name == 'Phalanx II' then
            local target = spell.target
            local is_self = (target and target.name == player.name)
            local new_spell = nil

            if spell_name == 'Phalanx II' and is_self then
                -- Phalanx II on self → Cast Phalanx instead
                new_spell = 'Phalanx'
                MessageFormatter.show_phalanx_downgrade()
            elseif spell_name == 'Phalanx' and not is_self then
                -- Phalanx on others → Cast Phalanx II instead
                new_spell = 'Phalanx II'
                MessageFormatter.show_phalanx_upgrade()
            end

            if new_spell then
                -- Cancel current spell and cast optimal tier
                eventArgs.cancel = true
                send_command('input /ma "' .. new_spell .. '" ' .. spell.target.raw)
                return
            end
        end
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   MAGIC PRECAST (Fast Cast)
    ---  ─────────────────────────────────────────────────────────────────────────
    if spell.action_type == 'Magic' then
        if debug_enabled then
            MessagePrecast.show_debug_step(5, 'Magic (Fast Cast)', 'info', 'Skill: ' .. (spell.skill or 'Unknown'))
        end

        -- Auto-trigger Saboteur before configured enfeebling spells
        if spell.skill == 'Enfeebling Magic' then
            -- Check if SaboteurMode is On
            if state.SaboteurMode and state.SaboteurMode.current == 'On' then
                -- Check if this spell is in the auto-trigger list
                if RDMSaboteurConfig.auto_trigger_spells[spell.english] then
                    if debug_enabled then
                        MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'ok', 'Will trigger before ' .. spell.english)
                    end
                    AbilityHelper.try_ability_smart(spell, eventArgs, 'Saboteur', RDMSaboteurConfig.wait_time)
                else
                    if debug_enabled then
                        MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'info', 'Not in auto-trigger list')
                    end
                end
            else
                if debug_enabled then
                    MessagePrecast.show_debug_step(5, 'Saboteur Auto', 'info', 'Mode is Off')
                end
            end
        end
    end

    ---  ─────────────────────────────────────────────────────────────────────────
    ---   WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    ---  ─────────────────────────────────────────────────────────────────────────
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, RDMTPConfig) then
        return
    end

    -- DEBUG: Show completion
    if debug_enabled then
        MessagePrecast.show_completion()
    end
end

--- Apply final gear adjustments before equipping
--- NOTE: TP display now integrated in job_precast WS message
--- @param spell table Spell/ability data
--- @param action string Action type
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
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

    -- Chainspell active - no need for Fast Cast gear
    if buffactive['Chainspell'] then
        -- Keep precast gear as-is (instant cast)
    end

    -- DEBUG: Display equipped set and gear
    if debug_enabled then
        -- Determine which set was equipped and get the actual set table
        local set_name = "Unknown"
        local gear_set = nil

        if spell.type == 'WeaponSkill' then
            if sets.precast.WS and sets.precast.WS[spell.english] then
                set_name = "sets.precast.WS[" .. spell.english .. "]"
                gear_set = sets.precast.WS[spell.english]
            elseif sets.precast.WS then
                set_name = "sets.precast.WS (base)"
                gear_set = sets.precast.WS
            end
        elseif spell.type == 'JobAbility' then
            if sets.precast.JA and sets.precast.JA[spell.english] then
                set_name = "sets.precast.JA[" .. spell.english .. "]"
                gear_set = sets.precast.JA[spell.english]
            elseif sets.precast.JA then
                set_name = "sets.precast.JA (base)"
                gear_set = sets.precast.JA
            end
        elseif spell.action_type == 'Magic' then
            if buffactive['Chainspell'] then
                set_name = "No FC (Chainspell active)"
                gear_set = nil
            elseif sets.precast.FC and sets.precast.FC[spell.english] then
                set_name = "sets.precast.FC[" .. spell.english .. "]"
                gear_set = sets.precast.FC[spell.english]
            elseif sets.precast.FC and spell.skill and sets.precast.FC[spell.skill] then
                set_name = "sets.precast.FC[" .. spell.skill .. "]"
                gear_set = sets.precast.FC[spell.skill]
            elseif sets.precast.FC then
                set_name = "sets.precast.FC (base)"
                gear_set = sets.precast.FC
            end
        elseif spell.type == 'RangedAttack' then
            set_name = "sets.precast.RA"
            gear_set = sets.precast.RA
        end

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

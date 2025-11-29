---============================================================================
--- DNC Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Dancer job with auto-buff systems:
---   • Weaponskill precast (Fast Cast, TP bonus optimization)
---   • Auto-Jump integration (DRG subjob - ultra-fast 0.5s timing)
---   • Auto-Climactic Flourish (optimized 1s timing before configured WS)
---   • Job ability precast (Steps, Sambas, Jigs, Waltzes, Flourishes)
---   • Fast cast for subjob spells (NIN/SAM/WAR/etc.)
---   • Cooldown tracking with formatted messages
---   • Debuff guard integration (blocks actions if silenced/amnesia)
---   • WS range validation (6y melee, 15y ranged)
---   • TP bonus calculation (Moonshade Earring automation)
---   • Mote refine_waltz override (allows waltzes on full HP targets)
---
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. Climactic timestamp tracking (instant detection before buff appears)
---   4. Auto-Jump trigger (JumpManager) - if DNC/DRG and TP < 1000
---   5. Auto-Climactic trigger (ClimaticManager) - if configured WS
---   6. WS validation (WeaponSkillManager) - range check + validation
---   7. TP bonus calculation (TPBonusCalculator) - optimize WS gear
---
--- @file    DNC_PRECAST.lua
--- @author  Tetsouo
--- @version 3.2 - Ultra-Fast Jump (0.5s) + Optimized Climactic (1s)
--- @date    Created: 2025-10-04 | Updated: 2025-10-10
--- @requires Tetsouo architecture, DNC logic modules, TPBonusCalculator
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MessageFormatter = nil
local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local ClimaticManager = nil
local WSVariantSelector = nil
local JumpManager = nil
local DNCTPConfig = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    -- DNC logic modules
    ClimaticManager = require('shared/jobs/dnc/functions/logic/climactic_manager')
    WSVariantSelector = require('shared/jobs/dnc/functions/logic/ws_variant_selector')
    JumpManager = require('shared/jobs/dnc/functions/logic/jump_manager')

    DNCTPConfig = _G.DNCTPConfig or {}

    modules_loaded = true
end

---============================================================================
--- MOTE OVERRIDES
---============================================================================

--- Override Mote's refine_waltz to allow waltzes even when target is full HP
--- This is needed for wake-up utility (removing sleep from party members)
--- Mote calls this function during precast for all waltz abilities
function refine_waltz(spell, action, spellMap, eventArgs)
    -- Do nothing - let our WaltzManager handle everything via //gs c waltz commands
    -- This disables Mote's automatic waltz blocking/refinement when target is full HP
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- FIRST: Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Cooldown check (exclude Utsusemi)
    if CooldownChecker then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' and not (spell.english == 'Utsusemi: Ni' or spell.english == 'Utsusemi: Ichi') then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        return
    end

    -- DNC-SPECIFIC: Samba TP requirement (350 TP)
    if spell.type == 'Samba' and MessageFormatter then
        local current_tp = player and player.tp or 0
        if current_tp < 350 then
            MessageFormatter.show_ability_tp_error(spell.name, current_tp, 350)
            eventArgs.cancel = true
            return
        end
    end

    -- DNC-SPECIFIC: Climactic Flourish timestamp
    if spell.type == 'Flourish3' and spell.english == 'Climactic Flourish' then
        _G.dnc_climactic_timestamp = os.time()
    end

    -- DNC-SPECIFIC: Auto-triggers for WS
    if spell.type == 'WeaponSkill' then
        -- Auto-trigger Jump before WS (DRG subjob)
        if JumpManager then
            JumpManager.auto_trigger_jump(spell, eventArgs)
            if eventArgs.cancel then
                return
            end
        end

        -- Auto-trigger Climactic Flourish
        if ClimaticManager then
            ClimaticManager.auto_trigger(spell, eventArgs)
            if eventArgs.cancel then
                return
            end
        end

        -- Reset auto-recast flag
        _G.DNC_AUTO_WS_RECAST = false
    end

    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, DNCTPConfig) then
        return
    end
end

---============================================================================
--- POST-PRECAST HOOK (Called AFTER set selection, BEFORE equipping)
---============================================================================

--- Apply any final gear adjustments before equipping
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if spell.type == 'WeaponSkill' then
        -- DNC-SPECIFIC: Apply WS set variant based on buffs (Fan Dance/Climactic)
        -- MUST happen BEFORE TP bonus gear to avoid overwriting Moonshade
        if WSVariantSelector then
            WSVariantSelector.apply_variant(spell)
        end
    end

    -- Apply TP gear via unified handler
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Make job_precast available globally for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Also export as module for potential future use
local DNC_PRECAST = {}
DNC_PRECAST.job_precast = job_precast
DNC_PRECAST.job_post_precast = job_post_precast

return DNC_PRECAST

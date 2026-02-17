---============================================================================
--- BLM Precast Module - Precast Action Handling & Intelligent Spell Refinement
---============================================================================
--- Handles precast gear for Black Mage job:
---   • Fast Cast for all spells (cap 80%)
---   • Job Abilities (Manafont, Manawall, Elemental Seal)
---   • Intelligent Spell Refinement (automatic tier downgrading)
---     - Elemental Magic: Fire VI >> V >> IV >> III >> II >> I
---     - AOE Spells: Firaja >> Firaga III >> II >> I
---     - Enfeebling: Sleep III >> II >> I, Sleepga II >> I, etc.
---     - Dark Magic: Bio V >> IV >> III >> II >> I, Drain III >> II >> I, etc.
---   • Death spell handling (HP-based damage)
---   • Security layers (debuff guard, cooldown check for non-tiered spells)
---
--- @file    BLM_PRECAST.lua
--- @author  Tetsouo
--- @version 2.0 - Universal Refinement Integration
--- @date    Created: 2025-10-15 | Updated: 2025-10-15
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker, spell_refiner
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local BLMTPConfig = nil
local BLM_SPELL_FILTERS = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    BLMTPConfig = _G.BLMTPConfig or {}

    -- Load BLM spell filters (cached by Lua after first require)
    local _, filters = pcall(require, 'shared/data/spells/BLM_SPELL_FILTERS')
    BLM_SPELL_FILTERS = filters

    modules_loaded = true
end

-- NOTE: BLM logic functions are loaded globally via blm_functions.lua:
--   • refine_various_spells() - Spell tier downgrading
--   • checkArts() - Scholar subjob Dark Arts automation
-- These functions are available in _G scope and called directly

---============================================================================
--- HELPER FUNCTIONS (Lazy Loaded - Safe to Call After ensure_modules_loaded)
---============================================================================

--- Check if an ability has multiple charges (bypass cooldown check)
--- @param spell table Spell object
--- @return boolean true if ability has charges
local function has_charges(spell)
    return BLM_SPELL_FILTERS and BLM_SPELL_FILTERS.CHARGE_ABILITIES[spell.english] or false
end

--- Check if a spell should use refinement instead of cooldown check
--- @param spell table Spell object
--- @return boolean true if spell uses refinement
local function uses_refinement(spell)
    if not BLM_SPELL_FILTERS then return false end

    -- Check by skill first (Elemental Magic), but exclude Storm/Klimaform (no tiers)
    if spell.skill == 'Elemental Magic' then
        if BLM_SPELL_FILTERS.ELEMENTAL_NO_TIERS[spell.english] then
            return false
        end
        return true
    end

    -- Check by spell name for other tiered spells
    return BLM_SPELL_FILTERS.REFINEMENT_SPELLS[spell.english] or false
end

---============================================================================
--- PRECAST HOOKS
---============================================================================

function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first action
    ensure_modules_loaded()

    -- FIRST: Check for blocking debuffs (Amnesia, Silence, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- SECOND: Universal cooldown check OR refinement
    -- IMPORTANT: Spells with tier systems use refinement instead of cooldown check
    -- IMPORTANT: Abilities with charges (Stratagems) bypass cooldown check
    if spell.action_type == 'Ability' then
        -- Skip cooldown check for abilities with multiple charges (FFXI handles blocking)
        if not has_charges(spell) and CooldownChecker then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        end
    elseif spell.action_type == 'Magic' then
        if uses_refinement(spell) then
            -- Use refinement system for tiered spells
            -- Refinement handles cooldown checking internally and downgrades tiers
            if refine_various_spells then
                refine_various_spells(spell, eventArgs)
            end
        elseif CooldownChecker then
            -- Use standard cooldown check for non-tiered spells
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: BLM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- BLM-SPECIFIC PRECAST LOGIC

    -- Check Arts for Scholar subjob (Dark Arts automation for Elemental Magic)
    if spell.skill == 'Elemental Magic' then
        -- Function loaded globally via blm_functions.lua
        if checkArts then
            checkArts(spell, eventArgs)
        end
    end

    -- Handle Death spell (special gear)
    if spell.english == 'Death' then
        -- Death uses HP for damage calculation
        -- Special precast gear with high HP
    end

    -- ==========================================================================
    -- IMPACT BODY LOCK (Twilight Cloak Required - like Marsyas for BRD)
    -- ==========================================================================
    -- Impact requires Twilight Cloak equipped to cast - must stay equipped
    -- throughout entire cast or the spell fails
    if spell.english == 'Impact' then
        -- Equip Twilight Cloak immediately
        equip({body = 'Twilight Cloak'})

        -- Set global flags to protect body during cast
        _G.casting_impact = true
        _G.impact_body = 'Twilight Cloak'
    end

    -- ==========================================================================
    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    -- ==========================================================================
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BLMTPConfig) then
        return
    end
end

function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export global for GearSwap (Mote-Include)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export module
local BLM_PRECAST = {}
BLM_PRECAST.job_precast = job_precast
BLM_PRECAST.job_post_precast = job_post_precast

return BLM_PRECAST

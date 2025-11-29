---============================================================================
--- WHM Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for White Mage job:
---   • Fast Cast optimization (all spell types)
---   • Job Abilities (Benediction, Devotion, Divine Seal, Asylum, etc.)
---   • Cure spell precast (fast cast + special gear)
---   • Enhancing magic precast (fast cast + duration gear preparation)
---   • Divine/Enfeebling magic precast
---   • Weaponskill validation and range checking
---   • Security layers (debuff guard >> cooldown check >> job logic)
---
--- Follows 4-layer PRECAST security architecture:
---   1. PrecastGuard - Block casting under debuffs (Amnesia, Silence, Stun, etc.)
---   2. CooldownChecker - Universal ability/spell recast validation
---   3. WSValidator - Weaponskill range and validity checks
---   4. WHM-specific logic - Job-specific enhancements
---
--- @file    WHM_PRECAST.lua
--- @author  Tetsouo
--- @version 1.0.0
--- @date    Created: 2025-10-21
--- @requires shared/utils/messages/message_formatter, shared/utils/precast/cooldown_checker
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

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

---============================================================================
--- PRECAST HOOKS
---============================================================================

--- Main precast hook for all spells/abilities
--- Implements 4-layer security: PrecastGuard >> CooldownChecker >> WSValidator >> WHM Logic
---
--- @param spell table Spell/ability data from Mote-Include
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments (contains .handled, .cancel flags)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first action
    ensure_modules_loaded()

    -- ==========================================================================
    -- LAYER 1: DEBUFF GUARD (Highest Priority)
    -- ==========================================================================
    -- Block casting if player has blocking debuffs (Amnesia, Silence, Stun, etc.)
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return  -- Action blocked, exit immediately
    end

    -- ==========================================================================
    -- LAYER 2: COOLDOWN CHECK (Universal)
    -- ==========================================================================
    -- Check ability/spell recast timers (prevent premature casting)
    if spell.action_type == 'Ability' then
        CooldownChecker.check_ability_cooldown(spell, eventArgs)
    elseif spell.action_type == 'Magic' then
        CooldownChecker.check_spell_cooldown(spell, eventArgs)
    end

    -- Exit if cooldown check cancelled the action
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- JOB ABILITIES MESSAGES (universal - supports main + subjob)
    -- DISABLED: WHM Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' and JA_DB[spell.english] then
    --     MessageFormatter.show_ja_activated(spell.english, JA_DB[spell.english].description)
    -- end

    -- ==========================================================================
    -- LAYER 3: WHM-SPECIFIC LOGIC
    -- ==========================================================================

    -- Auto-tier Cure selection (downgrade Cure tier if target doesn't need full heal)
    if CureManager and spell.action_type == 'Magic' then
        if spell.name:find('Cure') or spell.name:find('Curaga') then
            local target = spell.target and windower.ffxi.get_mob_by_id(spell.target.id)
            local new_spell = CureManager.select_cure_tier(spell, target)

            if new_spell and new_spell ~= spell.name then
                -- Cancel current spell and cast optimal tier instead
                eventArgs.cancel = true
                send_command('input /ma "' .. new_spell .. '" ' .. spell.target.raw)
                return
            end
        end
    end

    -- Handle Paralyna when self is paralyzed (Timara WHM pattern)
    if spell.english == 'Paralyna' and buffactive.Paralyzed then
        -- No gear swaps to avoid blinking while paralyzed
        eventArgs.handled = true
        return
    end

    -- WHM-specific precast enhancements can go here
    -- Examples:
    --   • Auto-trigger Divine Seal before Cure spells (if configured)
    --   • Auto-trigger Afflatus Solace before party Cures
    --   • Devotion automation before long fights

    -- ==========================================================================
    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    -- ==========================================================================
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, WHMTPConfig) then
        return
    end
end

--- Post-precast hook for additional customizations
--- Called after main precast set selection but before gear is equipped.
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping
--- @param eventArgs table Event arguments
--- @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end

    -- WHM-specific post-precast adjustments
    -- Examples:
    --   • Adjust Fast Cast gear based on spell type
    --   • Apply special weapon sets for certain abilities
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap (include() compatibility)
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export as module (require() compatibility)
local WHM_PRECAST = {}
WHM_PRECAST.job_precast = job_precast
WHM_PRECAST.job_post_precast = job_post_precast

return WHM_PRECAST

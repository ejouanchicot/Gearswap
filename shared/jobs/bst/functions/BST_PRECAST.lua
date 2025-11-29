---============================================================================
--- BST Precast Module - Precast Action Handling & Cooldown Monitoring
---============================================================================
--- Handles all precast actions for Beastmaster job:
---   • Debuff blocking (Amnesia, Silence, Stun)
---   • Universal cooldown checking (abilities/spells)
---   • Weaponskill validation and range checking
---   • Ready move categorization (for midcast)
---
--- Uses centralized systems for validation and messaging consistency.
---
--- @file jobs/bst/functions/BST_PRECAST.lua
--- @author Tetsouo
--- @version 1.0
--- @date Created: 2025-10-17
--- @requires Tetsouo architecture, MessageFormatter, CooldownChecker
---============================================================================

---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

-- Initialize BST debug flag if not exists
if _G.BST_DEBUG_PRECAST == nil then
    _G.BST_DEBUG_PRECAST = false  -- Toggle: //gs c debugbst
end

-- Debug helper to show current equipment
local function show_current_equipment(label)
    if not _G.BST_DEBUG_PRECAST then return end

    -- Lazy load MessageFormatter if needed
    if not MessageFormatter then
        MessageFormatter = require('shared/utils/messages/message_formatter')
    end

    local eq = player.equipment
    MessageFormatter.show_debug('BST', '========================================================')
    MessageFormatter.show_debug('BST', label)
    MessageFormatter.show_debug('BST', '--------------------------------------------------------')
    MessageFormatter.show_debug('BST', '  main: ' .. (eq.main or 'empty'))
    MessageFormatter.show_debug('BST', '  hands: ' .. (eq.hands or 'empty'))
    MessageFormatter.show_debug('BST', '  legs: ' .. (eq.legs or 'empty'))
    MessageFormatter.show_debug('BST', '========================================================')
end

local MessageFormatter = nil
local MessagePrecast = nil  -- Debug formatter
local CooldownChecker = nil
local PrecastGuard = nil
local WSPrecastHandler = nil
local BSTTPConfig = nil
local ReadyMoveCategorizer = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local _, mf = pcall(require, 'shared/utils/messages/message_formatter')
    MessageFormatter = mf

    local _, mp = pcall(require, 'shared/utils/messages/formatters/magic/message_precast')
    MessagePrecast = mp

    local _, cc = pcall(require, 'shared/utils/precast/cooldown_checker')
    CooldownChecker = cc

    local _, pg = pcall(require, 'shared/utils/debuff/precast_guard')
    PrecastGuard = pg

    local _, wph = pcall(require, 'shared/utils/precast/ws_precast_handler')
    WSPrecastHandler = wph

    BSTTPConfig = _G.BSTTPConfig or {}

    -- BST specific
    local _, rmc = pcall(require, 'shared/jobs/bst/functions/logic/ready_move_categorizer')
    ReadyMoveCategorizer = rmc

    modules_loaded = true
end

---============================================================================
--- PRECAST HOOK
---============================================================================

--- Called before any action (WS, JA, spell, etc.)
--- Processing order (CRITICAL - do not reorder):
---   1. Debuff guard (PrecastGuard) - blocks if silenced/amnesia/stunned
---   2. Cooldown check (CooldownChecker) - validates ability/spell ready
---   3. WS validation (WSValidator) - range check + validation
---   4. Ready move categorization (for Pet abilities)
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping (not used)
--- @param eventArgs table Event arguments (cancel flag, etc.)
--- @return void
function job_precast(spell, action, spellMap, eventArgs)
    -- Lazy load all dependencies on first precast
    ensure_modules_loaded()

    -- ==========================================================================
    -- STEP 1: DEBUFF BLOCKING
    -- ==========================================================================
    -- Check for blocking debuffs (Amnesia, Silence, Stun, etc.)
    -- Prevents unnecessary equipment swaps when actions are blocked
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return -- Action blocked by debuff, exit immediately
    end

    -- ==========================================================================
    -- STEP 2: COOLDOWN VALIDATION
    -- ==========================================================================
    -- Universal cooldown check - works for ALL abilities and spells
    -- EXCEPT Ready Moves (they use Charges system, not recast)
    local is_ready_move = false
    local ready_move_category = nil
    if ReadyMoveCategorizer and spell.action_type == 'Ability' then
        ready_move_category = ReadyMoveCategorizer.get_category(spell.name)
        -- Only TRUE Ready Moves (not "Default" which includes Fight/Heel/etc)
        is_ready_move = (ready_move_category ~= nil and ready_move_category ~= 'Default')
    end

    if CooldownChecker and not is_ready_move then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end

    -- Exit if action cancelled due to cooldown
    if eventArgs.cancel then
        return
    end

    -- ==========================================================================
    -- DISABLED: BST Job Abilities Messages
    -- Messages now handled by universal ability_message_handler (init_ability_messages.lua)
    -- This prevents duplicate messages from job-specific + universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.type == 'JobAbility' then
    --     if spell.english == 'Familiar' then
    --         MessageFormatter.show_ja_activated("Familiar", "Enhance pet stats +10% HP, extend charm")
    --     elseif spell.english == 'Reward' then
    --         MessageFormatter.show_ja_activated("Reward", "Restore pet HP with regen")
    --     ... (8 more abilities)
    --     end
    -- end
    --
    -- DISABLED: BST Pet Commands Messages
    -- Pet commands (Fight, Heel, Stay, Sic, Ready, Leave, Snarl, Spur) also handled by universal system
    --
    -- LEGACY CODE (commented out to prevent duplicates):
    -- if spell.action_type == 'Ability' and spell.type ~= 'JobAbility' then
    --     if spell.english == 'Fight' then
    --         MessageFormatter.show_ja_activated("Fight", "Command pet to attack target")
    --     ... (8 more commands)
    --     end
    -- end

    -- ==========================================================================
    -- WEAPONSKILL HANDLING (Unified via WSPrecastHandler)
    -- ==========================================================================
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BSTTPConfig) then
        return
    end

    -- ==========================================================================
    -- STEP 4: CALL BEAST / BESTIAL LOYALTY (equip summonSet + broth)
    -- ==========================================================================
    if spell.name == 'Call Beast' or spell.name == 'Bestial Loyalty' then
        -- Debug header (BST-specific flag for JA debug)
        if _G.BST_DEBUG_PRECAST then
            MessagePrecast.show_debug_header(spell.name, 'Pet Summon')
        end

        -- Equip base summon set
        if sets.precast.JA['Call Beast'] then
            equip(sets.precast.JA['Call Beast'])
            if _G.BST_DEBUG_PRECAST then
                MessagePrecast.show_equipped_set('precast.JA["Call Beast"]')
                MessagePrecast.show_equipment(sets.precast.JA['Call Beast'])
            end
        end

        -- Equip broth from state (forced separate to override any ammo in summonSet)
        if state.ammoSet and state.ammoSet.value and sets[state.ammoSet.value] then
            local broth_set = sets[state.ammoSet.value]
            if broth_set and broth_set.ammo then
                equip({ammo = broth_set.ammo})
                if _G.BST_DEBUG_PRECAST then
                    MessagePrecast.show_debug_step(1, 'Broth Override', 'ok', broth_set.ammo)
                end
            end
        end

        if _G.BST_DEBUG_PRECAST then
            MessagePrecast.show_completion()
        end

        return -- Exit early (handled)
    end

    -- ==========================================================================
    -- STEP 5: READY MOVE DETECTION (use ReadyMoveCategorizer for ALL moves)
    -- ==========================================================================
    -- Use ReadyMoveCategorizer to detect ALL Ready Moves (not just patterns)
    if is_ready_move and ready_move_category and ready_move_category ~= 'Default' then
        -- Store category for aftercast
        spell.ready_move_category = ready_move_category
        spell.bst_is_ready_move = true

        -- EQUIP GLETI'S BREECHES NOW (Ready Recast -5s snapshots at PRECAST like Fast Cast)
        if sets.precast.JA['Sic'] then
            equip(sets.precast.JA['Sic'])
        end
    end
end

---============================================================================
--- POST-PRECAST HOOK
---============================================================================

--- Called after precast set selection, before gear is equipped
--- Handles:
---   • Call Beast / Bestial Loyalty - equip pet broth
---   • Weaponskill TP display
---
--- @param spell table Spell/ability data
--- @param action string Action type (not used)
--- @param spellMap string Spell mapping (not used)
--- @param eventArgs table Event arguments (not used)
--- @return void
function job_post_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()
    if WSPrecastHandler then
        WSPrecastHandler.apply_tp_gear(spell)
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

-- Export globally for GearSwap
_G.job_precast = job_precast
_G.job_post_precast = job_post_precast

-- Export as module (for future require() usage)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast
}

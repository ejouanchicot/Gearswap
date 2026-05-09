---  ═══════════════════════════════════════════════════════════════════════════
---   BST Precast Module - Precast Action Handling & Pet Commands
---  ═══════════════════════════════════════════════════════════════════════════
---   Debuff guard, cooldown check, WS handling, Call Beast/Bestial Loyalty,
---   Ready moves.
---
---   @file    BST_PRECAST.lua
---   @author  Tetsouo
---   @version 1.0
---   @date    Created: 2025-10-05
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

-- Initialize BST debug flag if not exists
if _G.BST_DEBUG_PRECAST == nil then
    _G.BST_DEBUG_PRECAST = false  -- Toggle: //gs c debugbst
end

-- Debug helper to show current equipment
local function show_current_equipment(label)
    if not _G.BST_DEBUG_PRECAST then return end

    -- Lazy load MessageFormatter if needed
    if not MessageFormatter then
        local _, mod = pcall(require, 'shared/utils/messages/message_formatter')
        MessageFormatter = mod
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

--- Precast order: debuff guard → cooldown → WS handler → Call Beast → Ready moves
---   @param spell table Spell/ability data
---   @param action string Action type
---   @param spellMap string Spell mapping
---   @param eventArgs table Event arguments
function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    -- Debuff guard
    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    -- Cooldown check (skip Ready Moves - they use charges, not recast)
    local is_ready_move = false
    local ready_move_category = nil
    if ReadyMoveCategorizer and spell.action_type == 'Ability' then
        ready_move_category = ReadyMoveCategorizer.get_category(spell.name)
        is_ready_move = (ready_move_category ~= nil and ready_move_category ~= 'Default')
    end

    if CooldownChecker and not is_ready_move then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end
    if eventArgs.cancel then return end

    -- WS handling
    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BSTTPConfig) then
        return
    end

    -- Call Beast / Bestial Loyalty: equip summon set + broth
    if spell.name == 'Call Beast' or spell.name == 'Bestial Loyalty' then
        if _G.BST_DEBUG_PRECAST then
            MessagePrecast.show_debug_header(spell.name, 'Pet Summon')
        end

        if sets.precast.JA['Call Beast'] then
            equip(sets.precast.JA['Call Beast'])
            if _G.BST_DEBUG_PRECAST then
                MessagePrecast.show_equipped_set('precast.JA["Call Beast"]')
                MessagePrecast.show_equipment(sets.precast.JA['Call Beast'])
            end
        end

        if state.ammoSet and state.ammoSet.value and sets[state.ammoSet.value] then
            local broth_set = sets[state.ammoSet.value]
            if broth_set and broth_set.ammo then
                equip({ammo = broth_set.ammo})
                if _G.BST_DEBUG_PRECAST then
                    MessagePrecast.show_debug_step(1, 'Broth Override', 'ok', broth_set.ammo)
                end
            end
        end

        if _G.BST_DEBUG_PRECAST then MessagePrecast.show_completion() end
        return
    end

    -- Ready move: equip Gleti's Breeches (recast snaps at precast), store category for midcast
    if is_ready_move and ready_move_category and ready_move_category ~= 'Default' then
        spell.ready_move_category = ready_move_category
        spell.bst_is_ready_move = true
        if sets.precast.JA['Sic'] then
            equip(sets.precast.JA['Sic'])
        end
    end
end

---   Apply final gear adjustments before equipping
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

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_precast = job_precast,
    job_post_precast = job_post_precast,
}


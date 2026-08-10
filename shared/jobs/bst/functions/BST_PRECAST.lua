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

--- Is this a pet Ready move, and which category?
---
--- Ready moves spend charges rather than a recast, so FFXI blocks them itself
--- and a cooldown check would refuse a move the game would have allowed.
--- 'Default' means the categoriser recognised nothing, which is not a Ready
--- move as far as this is concerned.
--- @return boolean is a ready move, string|nil category
local function ready_move_info(spell)
    if not (ReadyMoveCategorizer and spell.action_type == 'Ability') then
        return false, nil
    end

    local category = ReadyMoveCategorizer.get_category(spell.name)
    if category == nil or category == 'Default' then
        return false, nil
    end
    return true, category
end

--- Summon gear, then the broth on top.
---
--- The broth goes on last and by itself: it decides which pet appears, and the
--- Call Beast set has its own ammo that would otherwise win and summon the
--- wrong one.
local function equip_for_summon(spell)
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

    if _G.BST_DEBUG_PRECAST then
        MessagePrecast.show_completion()
    end
end

--- Mark the move for midcast and put the precast piece on.
---
--- The category is carried on the spell because midcast cannot work it out
--- again: by then the ability has resolved and the name alone does not say
--- which kind of move it was.
local function prepare_ready_move(spell, category)
    spell.ready_move_category = category
    spell.bst_is_ready_move = true
    if sets.precast.JA['Sic'] then
        equip(sets.precast.JA['Sic'])
    end
end

function job_precast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then
        return
    end

    local is_ready_move, ready_move_category = ready_move_info(spell)

    if CooldownChecker and not is_ready_move then
        if spell.action_type == 'Ability' then
            CooldownChecker.check_ability_cooldown(spell, eventArgs)
        elseif spell.action_type == 'Magic' then
            CooldownChecker.check_spell_cooldown(spell, eventArgs)
        end
    end
    if eventArgs.cancel then
        return
    end

    if WSPrecastHandler and not WSPrecastHandler.handle(spell, eventArgs, BSTTPConfig) then
        return
    end

    if spell.name == 'Call Beast' or spell.name == 'Bestial Loyalty' then
        equip_for_summon(spell)
        return
    end

    if is_ready_move then
        prepare_ready_move(spell, ready_move_category)
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


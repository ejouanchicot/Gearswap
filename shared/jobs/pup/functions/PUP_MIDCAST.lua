---  ═══════════════════════════════════════════════════════════════════════════
---   PUP Midcast Module - Midcast Gear Selection
---  ═══════════════════════════════════════════════════════════════════════════
---   Handles midcast for Puppetmaster with specialized Ready Move handling.
---
---   Features:
---   - Ready Moves: 4 categories (Physical, PhysicalMulti, MagicAtk, MagicAcc)
---   - Pet Abilities: Call Beast, Reward, Spur, etc.
---   - Subjob Spells: Healing/Enhancing/Enfeebling/Elemental/Blue Magic
---
---   Note: Ready Move logic is PUP-specific and NOT handled by MidcastManager.
---
---   @file    PUP_MIDCAST.lua
---   @author  Tetsouo
---   @version 3.0 - Added spell_family database support
---   @date    Created: 2025-10-17 | Updated: 2025-11-05
---  ═══════════════════════════════════════════════════════════════════════════
---   DEPENDENCIES - LAZY LOADING (Performance Optimization)
---  ═══════════════════════════════════════════════════════════════════════════

local MidcastManager = nil
local MessageFormatter = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local ReadyMoveCategorizer = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    local mm_ok, mm = pcall(require, 'shared/utils/midcast/midcast_manager')
    if not mm_ok then mm = nil end
    MidcastManager = mm
    local mf_ok, mf = pcall(require, 'shared/utils/messages/message_formatter')
    if not mf_ok then mf = nil end
    MessageFormatter = mf

    -- Load ENHANCING_MAGIC_DATABASE for spell_family routing
    EnhancingSPELLS_success, EnhancingSPELLS = pcall(require, 'shared/data/magic/ENHANCING_MAGIC_DATABASE')

    -- Ready move categorizer
    local success_rmc
    success_rmc, ReadyMoveCategorizer = pcall(require, 'shared/jobs/pup/functions/logic/ready_move_categorizer')
    if not success_rmc then
        MessageFormatter.error_pup_module_not_loaded('ReadyMoveCategorizer')
        ReadyMoveCategorizer = nil
    end

    modules_loaded = true
end

-- Pet commands that precast has already dressed. Midcast must leave them
-- alone or it undoes the set precast just chose.
local PRECAST_ONLY = {
    ['Call Beast'] = true, ['Bestial Loyalty'] = true, ['Reward'] = true,
    ['Killer Instinct'] = true, ['Spur'] = true,
    ['Fight'] = true, ['Heel'] = true, ['Stay'] = true,
}

--- Which Ready move category this is, if any.
---
--- precast stores it on the spell because by midcast the name alone no longer
--- says which kind of move it was. The categoriser is the fallback for paths
--- that did not go through precast.
--- @return string|nil Category, nil when this is not a Ready move
local function ready_move_category(spell)
    local category = spell.ready_move_category
    if not category and ReadyMoveCategorizer and spell.action_type == 'Ability' then
        category = ReadyMoveCategorizer.get_category(spell.name)
    end

    -- 'Default' is the categoriser saying it recognised nothing.
    if category == 'Default' then
        return nil
    end
    return category
end

--- The set for a Ready move category.
---
--- The magic categories have a separate _ww set for when the master is
--- engaged. Why the two differ is a gear decision that lives in the sets, not
--- here; this only picks between them.
--- @param category string From ready_move_category
--- @param engaged boolean Whether the master is fighting
--- @return table|nil Set to equip
local function set_for_category(category, engaged)
    local m = sets.midcast

    -- Set existence is part of the condition, not an afterthought: a
    -- PhysicalMulti move on a job that never defined a multi set falls through
    -- to the physical one rather than equipping nothing. The magic categories
    -- deliberately do NOT fall back - melee gear on a magic move is worse than
    -- leaving what precast chose.
    if category == 'Physical' and m.pet_physical_moves then
        return m.pet_physical_moves
    elseif category == 'PhysicalMulti' and m.pet_physicalMulti_moves then
        return m.pet_physicalMulti_moves
    elseif category == 'MagicAtk' then
        return engaged and m.pet_magicAtk_moves_ww or m.pet_magicAtk_moves
    elseif category == 'MagicAcc' then
        return engaged and m.pet_magicAcc_moves_ww or m.pet_magicAcc_moves
    end

    -- Unknown category: physical is the safe guess for a pet ability.
    return m.pet_physical_moves
end

---   Midcast hook - Ready moves only; everything else is precast's business
---   @param spell table Spell information from GearSwap
---   @param action table Action information from GearSwap
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments
function job_midcast(spell, action, spellMap, eventArgs)
    ensure_modules_loaded()

    if PRECAST_ONLY[spell.name] then
        return
    end

    local category = ready_move_category(spell)
    if not category then
        return
    end

    local engaged = (player and player.status == 'Engaged')
    local set = set_for_category(category, engaged)
    if set then
        equip(set)
    end

    eventArgs.handled = true
end

---  ─────────────────────────────────────────────────────────────────────────
---   PER-BRANCH HANDLERS
---  ─────────────────────────────────────────────────────────────────────────
---   Extracted from job_post_midcast, which dispatched on spell.skill.
---   Each returns true once it has handled the call. Bodies unchanged.

--- Handle Healing Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_healing_magic(spell)
    MidcastManager.select_set({
        skill = 'Healing Magic',
        spell = spell
    })
    return true
end

--- Handle Enhancing Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_enhancing_magic(spell)
    MidcastManager.select_set({
        skill = 'Enhancing Magic',
        spell = spell,
        target_func = MidcastManager.get_enhancing_target,
        database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
    })
    return true
end

--- Handle Enfeebling Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_enfeebling_magic(spell)
    MidcastManager.select_set({
        skill = 'Enfeebling Magic',
        spell = spell
    })
    return true
end

--- Handle Elemental Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_elemental_magic(spell)
    MidcastManager.select_set({
        skill = 'Elemental Magic',
        spell = spell
    })
    return true
end

--- Handle Blue Magic.
--- @return boolean True when this handler took the action
local function job_post_midcast_blue_magic(spell)
    MidcastManager.select_set({
        skill = 'Blue Magic',
        spell = spell
    })
    return true
end

local JOB_POST_MIDCAST_HANDLERS = {
    ['Healing Magic'] = job_post_midcast_healing_magic,
    ['Enhancing Magic'] = job_post_midcast_enhancing_magic,
    ['Enfeebling Magic'] = job_post_midcast_enfeebling_magic,
    ['Elemental Magic'] = job_post_midcast_elemental_magic,
    ['Blue Magic'] = job_post_midcast_blue_magic,
}

---   Post-midcast hook (MidcastManager routing and gear selection)
---   @param spell table Spell information from GearSwap
---   @param action string Action type
---   @param spellMap string Spell mapping from Mote-Include
---   @param eventArgs table Event arguments for cancellation/customization
function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Skip if already handled (Ready Moves)
    if eventArgs.handled then
        return
    end

    ---══════════════════════════════════════════════════════════════════════════
    --- SUBJOB SPELLS (Handled by MidcastManager)
    ---══════════════════════════════════════════════════════════════════════════

    -- Healing Magic (Cure, Cura, etc.)

    local handler = JOB_POST_MIDCAST_HANDLERS[spell.skill]
    if handler and handler(spell) then
        return
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   MODULE EXPORT
---  ═══════════════════════════════════════════════════════════════════════════

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

-- Module table for require() compatibility (parity with _G exports above)
return {
    job_midcast = job_midcast,
    job_post_midcast = job_post_midcast,
}

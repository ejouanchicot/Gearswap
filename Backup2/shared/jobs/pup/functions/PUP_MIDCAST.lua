---============================================================================
--- PUP Midcast Module - Powered by MidcastManager (Subjob Spells Only)
---============================================================================
--- Handles midcast for Beastmaster with specialized Ready Move handling.
---
--- Features:
---   - Ready Moves: 4 categories (Physical, PhysicalMulti, MagicAtk, MagicAcc)
---   - Pet Abilities: Call Beast, Reward, Spur, etc.
---   - Subjob Spells: Healing/Enhancing/Enfeebling/Elemental/Blue Magic
---
--- Note: Ready Move logic is PUP-specific and NOT handled by MidcastManager.
---
--- @file PUP_MIDCAST.lua
--- @author Tetsouo
--- @version 3.0 - Added spell_family database support
--- @date Created: 2025-10-17 | Updated: 2025-11-05
---============================================================================
--- DEPENDENCIES - LAZY LOADING (Performance Optimization)
---============================================================================

local MidcastManager = nil
local MessageFormatter = nil
local EnhancingSPELLS = nil
local EnhancingSPELLS_success = false
local ReadyMoveCategorizer = nil

local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then return end

    MidcastManager = require('shared/utils/midcast/midcast_manager')
    MessageFormatter = require('shared/utils/messages/message_formatter')

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

function job_midcast(spell, action, spellMap, eventArgs)
    -- Lazy load modules on first cast
    ensure_modules_loaded()

    ---========================================================================
    --- SKIP NON-READY MOVES (Call Beast, Fight, Heel, etc.)
    ---========================================================================
    -- These are handled in precast ONLY (no midcast override needed)
    if
        spell.name == 'Call Beast' or spell.name == 'Bestial Loyalty' or spell.name == 'Reward' or
        spell.name == 'Killer Instinct' or
        spell.name == 'Spur' or
        spell.name == 'Fight' or
        spell.name == 'Heel' or
        spell.name == 'Stay'
    then
        return -- Don't override precast set
    end

    ---========================================================================
    --- READY MOVES (Pet Abilities) - 4 CATEGORIES
    ---========================================================================
    -- PUP-SPECIFIC LOGIC: Not handled by MidcastManager (pet-specific)

    -- Detect Ready Moves: check if category was set in precast OR use categorizer
    local category = spell.ready_move_category
    if not category and ReadyMoveCategorizer and spell.action_type == 'Ability' then
        category = ReadyMoveCategorizer.get_category(spell.name)
    end

    -- If we have a VALID category (not "Default" = Fight/Heel/etc), this is a Ready Move
    if category and category ~= 'Default' then
        -- Check if player is engaged (for _ww variants)
        local player_engaged = (player and player.status == 'Engaged')

        -- Equip appropriate set based on category
        if category == 'Physical' and sets.midcast.pet_physical_moves then
            equip(sets.midcast.pet_physical_moves)
        elseif category == 'PhysicalMulti' and sets.midcast.pet_physicalMulti_moves then
            equip(sets.midcast.pet_physicalMulti_moves)
        elseif category == 'MagicAtk' then
            -- Choose between normal and _ww (with weapon) variant
            local set = player_engaged and sets.midcast.pet_magicAtk_moves_ww or sets.midcast.pet_magicAtk_moves
            if set then
                equip(set)
            end
        elseif category == 'MagicAcc' then
            -- Choose between normal and _ww (with weapon) variant
            local set = player_engaged and sets.midcast.pet_magicAcc_moves_ww or sets.midcast.pet_magicAcc_moves
            if set then
                equip(set)
            end
        elseif sets.midcast.pet_physical_moves then
            -- Fallback to physical set
            equip(sets.midcast.pet_physical_moves)
        end

        eventArgs.handled = true
        return
    end
end

function job_post_midcast(spell, action, spellMap, eventArgs)
    -- Watchdog: Track midcast start
    if _G.MidcastWatchdog then
        _G.MidcastWatchdog.on_midcast_start(spell)
    end

    -- Skip if already handled (Ready Moves)
    if eventArgs.handled then
        return
    end

    ---========================================================================
    --- SUBJOB SPELLS (Handled by MidcastManager)
    ---========================================================================

    -- Healing Magic (Cure, Cura, etc.)
    if spell.skill == 'Healing Magic' then
        MidcastManager.select_set({
            skill = 'Healing Magic',
            spell = spell
        })
        return
    end

    -- Enhancing Magic (Protect, Shell, Bar spells, etc.)
    if spell.skill == 'Enhancing Magic' then
        MidcastManager.select_set({
            skill = 'Enhancing Magic',
            spell = spell,
            target_func = MidcastManager.get_enhancing_target,
            database_func = EnhancingSPELLS_success and EnhancingSPELLS and EnhancingSPELLS.get_spell_family or nil
        })
        return
    end

    -- Enfeebling Magic (if RDM subjob)
    if spell.skill == 'Enfeebling Magic' then
        MidcastManager.select_set({
            skill = 'Enfeebling Magic',
            spell = spell
        })
        return
    end

    -- Elemental Magic (if BLU subjob)
    if spell.skill == 'Elemental Magic' then
        MidcastManager.select_set({
            skill = 'Elemental Magic',
            spell = spell
        })
        return
    end

    -- Blue Magic (if BLU subjob)
    if spell.skill == 'Blue Magic' then
        MidcastManager.select_set({
            skill = 'Blue Magic',
            spell = spell
        })
        return
    end
end

---============================================================================
--- MODULE EXPORT
---============================================================================

_G.job_midcast = job_midcast
_G.job_post_midcast = job_post_midcast

local PUP_MIDCAST = {}
PUP_MIDCAST.job_midcast = job_midcast
PUP_MIDCAST.job_post_midcast = job_post_midcast

return PUP_MIDCAST

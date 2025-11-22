---  ═══════════════════════════════════════════════════════════════════════════
---   Precast Guard - Action Blocking Prevention System
---  ═══════════════════════════════════════════════════════════════════════════
---   Prevents actions from executing when blocked by debuffs, avoiding
---   unnecessary equipment swaps and providing clear feedback to the player.
---
---   @file    shared/utils/debuff/precast_guard.lua
---   @author  Tetsouo
---   @version 1.2 - DRY refactor: Merge try_cure + normalize helper (-18 lines)
---   @date    Created: 2025-10-02 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local MessageCore = require('shared/utils/messages/message_core')

local PrecastGuard = {}

-- Load dependencies
local DebuffChecker = require('shared/utils/debuff/debuff_checker')
local MessageDebuffs = require('shared/utils/messages/formatters/magic/message_debuffs')

-- Load configuration
local config_success, AutoCureConfig = pcall(require, 'shared/config/DEBUFF_AUTOCURE_CONFIG')
if not config_success then
    -- Fallback to defaults if config not found
    AutoCureConfig = {
        test_mode = false,
        test_debuff = "Berserk",
        auto_cure_silence = true,
        auto_cure_paralysis = true,
        silence_cure_items = {
            { name = "Echo Drops", id = 4151 },
            { name = "Remedy", id = 4155 }
        },
        paralysis_cure_items = {
            { name = "Remedy", id = 4155 },
            { name = "Panacea", id = 4145 }
        },
        debug = false
    }
end

-- Silence cure items (from config with validation)
local SILENCE_CURE_ITEMS = AutoCureConfig.silence_cure_items or {}

-- Paralysis cure items (from config with validation)
local PARALYSIS_CURE_ITEMS = AutoCureConfig.paralysis_cure_items or {}

---  ═══════════════════════════════════════════════════════════════════════════
---   AUTO-CURE FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if an item exists in inventory
--- @param item_id number Item ID to check
--- @return boolean has_item True if item is in inventory with count > 0
local function has_item_in_inventory(item_id)
    local items = windower.ffxi.get_items()
    if not items or not items.inventory then
        return false
    end

    for i = 1, items.max_inventory do
        local item = items.inventory[i]
        if item and type(item) == 'table' and item.id == item_id and item.count > 0 then
            return true
        end
    end

    return false
end

--- Normalize debuff name to lowercase for consistent comparison
--- @param debuff_name string|nil Debuff name to normalize
--- @return string Lowercase debuff name or empty string if nil
local function normalize_debuff_name(debuff_name)
    return debuff_name and debuff_name:lower() or ""
end

--- Try to use debuff cure item (Echo Drops, Remedy, Panacea, etc.)
--- @param cure_items table List of cure items to try (in priority order)
--- @param action_name string The action that was blocked
--- @param debuff_message string The debuff message to display
--- @param success_msg_func function Message function to call on success
--- @return boolean used True if item was used successfully
local function try_cure_debuff(cure_items, action_name, debuff_message, success_msg_func)
    -- Try each cure item in priority order
    for _, cure_item in ipairs(cure_items) do
        if has_item_in_inventory(cure_item.id) then
            -- Use the item
            windower.send_command('input /item "' .. cure_item.name .. '" <me>')

            -- Display success message using MessageDebuffs module
            success_msg_func(cure_item.name, action_name, debuff_message)

            return true
        end
    end

    return false
end

--- Try to use silence cure item (Echo Drops or Remedy)
--- @param spell_name string The spell that was blocked
--- @param debuff_message string The debuff message to display (e.g., "Silenced")
--- @return boolean used True if item was used successfully
local function try_cure_silence(spell_name, debuff_message)
    return try_cure_debuff(SILENCE_CURE_ITEMS, spell_name, debuff_message, MessageDebuffs.show_silence_cure_success)
end

--- Try to use paralysis cure item (Remedy or Panacea)
--- @param action_name string The action that was blocked (JA or WS)
--- @param debuff_message string The debuff message to display (e.g., "Paralyzed")
--- @return boolean used True if item was used successfully
local function try_cure_paralysis(action_name, debuff_message)
    return try_cure_debuff(PARALYSIS_CURE_ITEMS, action_name, debuff_message, MessageDebuffs.show_paralysis_cure_success)
end

---  ═══════════════════════════════════════════════════════════════════════════
---   ACTION BLOCKING FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if action should be blocked and cancel if necessary
--- @param spell table Spell/action object from GearSwap
--- @param eventArgs table Event arguments with cancel flag
--- @return boolean blocked True if action was blocked
function PrecastGuard.check_and_block(spell, eventArgs)
    if not spell or not eventArgs then
        return false
    end

    -- Use action_type which is more reliable for action detection
    local action_type = spell.action_type or spell.type

    -- Check if action is blocked by debuffs
    local blocked, debuff_name, debuff_message = DebuffChecker.check_action_blocked(action_type)

    if blocked then
        -- Normalize debuff name to lowercase for consistent comparison
        local debuff_lower = normalize_debuff_name(debuff_name)

        -- Check if this debuff should trigger auto-cure
        local should_auto_cure = false
        local cure_type = nil  -- "silence" or "paralysis"

        -- Real Silence always triggers auto-cure (if enabled)
        if debuff_lower == "silence" and AutoCureConfig.auto_cure_silence then
            should_auto_cure = true
            cure_type = "silence"
        end

        -- Real Paralysis always triggers auto-cure (if enabled)
        if debuff_lower == "paralysis" and AutoCureConfig.auto_cure_paralysis then
            should_auto_cure = true
            cure_type = "paralysis"
        end

        -- Test mode: Berserk simulates Silence
        if AutoCureConfig.test_mode and debuff_lower == "berserk" then
            should_auto_cure = true
            cure_type = "silence"
            if AutoCureConfig.debug then
                MessageCore.show_test_mode('Using Berserk to simulate Silence')
            end
        end

        -- Test mode: Defender simulates Paralysis
        if AutoCureConfig.test_mode and debuff_lower == "defender" then
            should_auto_cure = true
            cure_type = "paralysis"
            if AutoCureConfig.debug then
                MessageCore.show_test_mode('Using Defender to simulate Paralysis')
            end
        end

        -- Auto-cure handling
        if should_auto_cure then
            local cure_success = false

            if cure_type == "silence" and action_type == "Magic" then
                -- Try to use Echo Drops or Remedy for Silence
                cure_success = try_cure_silence(spell.name, debuff_message)
                if not cure_success then
                    eventArgs.cancel = true
                    MessageDebuffs.show_no_silence_cure(spell.name, debuff_message)
                    return true
                end
            elseif cure_type == "paralysis" and (action_type == "Ability" or action_type == "JobAbility") and not (action_type == "WeaponSkill" or action_type == "Weaponskill") then
                -- Try to use Remedy or Panacea for Paralysis (ONLY for Job Abilities, NOT WeaponSkills)
                cure_success = try_cure_paralysis(spell.name, debuff_message)
                if not cure_success then
                    eventArgs.cancel = true
                    MessageDebuffs.show_no_paralysis_cure(spell.name, debuff_message)
                    return true
                end
            end

            if cure_success then
                eventArgs.cancel = true
                return true
            end
        end

        -- Cancel the action to prevent equipment swap
        eventArgs.cancel = true

        -- Display appropriate message with the detected action type
        MessageDebuffs.show_action_blocked(spell.name, action_type, debuff_message or debuff_name)

        return true
    end

    return false
end

--- Check magic spells specifically
--- @param spell table Spell object
--- @param eventArgs table Event arguments
--- @return boolean blocked True if spell was blocked
function PrecastGuard.check_magic(spell, eventArgs)
    if spell.type ~= "Magic" then
        return false
    end

    local blocked, debuff_name, debuff_message = DebuffChecker.check_magic_blocked()

    if blocked then
        -- Normalize debuff name to lowercase for consistent comparison
        local debuff_lower = normalize_debuff_name(debuff_name)

        -- Check if this debuff should trigger auto-cure
        local should_auto_cure = false

        -- Real Silence always triggers auto-cure (if enabled)
        if debuff_lower == "silence" and AutoCureConfig.auto_cure_silence then
            should_auto_cure = true
        end

        -- Test mode: use configured test debuff to simulate Silence
        local test_debuff_lower = AutoCureConfig.test_debuff and AutoCureConfig.test_debuff:lower() or ""
        if AutoCureConfig.test_mode and debuff_lower == test_debuff_lower then
            should_auto_cure = true
            if AutoCureConfig.debug then
                MessageCore.show_test_mode('Using ' .. AutoCureConfig.test_debuff .. ' to simulate Silence')
            end
        end

        -- Special handling for Silence (or test mode) - try to auto-cure
        if should_auto_cure then
            -- Try to use Echo Drops or Remedy
            if try_cure_silence(spell.name, debuff_message) then
                -- Successfully used cure item, don't cancel the action
                -- GearSwap will retry the spell after item use
                eventArgs.cancel = true  -- Cancel this attempt, player can retry after cure
                return true
            else
                -- No cure items available, show error and block
                eventArgs.cancel = true
                MessageDebuffs.show_no_silence_cure(spell.name, debuff_message)
                return true
            end
        end

        -- Other debuffs (Mute, Omerta, etc.) - block normally
        eventArgs.cancel = true
        MessageDebuffs.show_spell_blocked(spell.name, debuff_message or debuff_name)
        return true
    end

    return false
end

--- Check job abilities specifically
--- @param spell table Ability object
--- @param eventArgs table Event arguments
--- @return boolean blocked True if ability was blocked
function PrecastGuard.check_ja(spell, eventArgs)
    if spell.type ~= "JobAbility" and spell.type ~= "Ability" and spell.type ~= "PetCommand" then
        return false
    end

    local blocked, debuff_name, debuff_message = DebuffChecker.check_ja_blocked()

    if blocked then
        -- Normalize debuff name to lowercase for consistent comparison
        local debuff_lower = normalize_debuff_name(debuff_name)

        -- Check if this is Paralysis/Paralyzed and should trigger auto-cure
        local should_auto_cure = false

        -- Real Paralysis always triggers auto-cure (if enabled)
        if debuff_lower == "paralysis" and AutoCureConfig.auto_cure_paralysis then
            should_auto_cure = true
        end

        -- Test mode: use configured test debuff (e.g., Defender) to simulate Paralysis
        if AutoCureConfig.test_mode and debuff_lower == "defender" then
            should_auto_cure = true
            if AutoCureConfig.debug then
                MessageCore.show_test_mode('Using Defender to simulate Paralysis')
            end
        end

        -- Special handling for Paralysis (or test mode) - try to auto-cure
        if should_auto_cure then
            -- Try to use Remedy or Panacea
            if try_cure_paralysis(spell.name, debuff_message) then
                -- Successfully used cure item, don't cancel the action
                -- GearSwap will retry the JA after item use
                eventArgs.cancel = true  -- Cancel this attempt, player can retry after cure
                return true
            else
                -- No cure items available, show error and block
                eventArgs.cancel = true
                MessageDebuffs.show_no_paralysis_cure(spell.name, debuff_message)
                return true
            end
        end

        -- Other debuffs (Amnesia, Impairment, etc.) - block normally
        eventArgs.cancel = true
        MessageDebuffs.show_ja_blocked(spell.name, debuff_message or debuff_name)
        return true
    end

    return false
end

--- Check weapon skills specifically
--- @param spell table WeaponSkill object
--- @param eventArgs table Event arguments
--- @return boolean blocked True if WS was blocked
function PrecastGuard.check_ws(spell, eventArgs)
    if spell.type ~= "WeaponSkill" and spell.type ~= "Weaponskill" then
        return false
    end

    -- WeaponSkills are NOT blocked by paralysis - let FFXI handle it naturally
    -- Other debuffs (Amnesia, Terror, etc.) still block WS
    local blocked, debuff_name, debuff_message = DebuffChecker.check_ws_blocked()

    if blocked then
        -- Normalize debuff name to lowercase for consistent comparison
        local debuff_lower = normalize_debuff_name(debuff_name)

        -- Skip blocking if it's just paralysis (FFXI will handle WS proc/fail)
        if debuff_lower == "paralysis" then
            return false  -- Don't block, let FFXI handle
        end

        -- Block for other debuffs (Amnesia, Terror, etc.)
        eventArgs.cancel = true
        MessageDebuffs.show_ws_blocked(spell.name, debuff_message or debuff_name)
        return true
    end

    return false
end

--- Check item usage specifically
--- @param spell table Item object
--- @param eventArgs table Event arguments
--- @return boolean blocked True if item was blocked
function PrecastGuard.check_item(spell, eventArgs)
    if spell.type ~= "Item" then
        return false
    end

    local blocked, debuff_name, debuff_message = DebuffChecker.check_item_blocked()

    if blocked then
        eventArgs.cancel = true
        MessageDebuffs.show_item_blocked(spell.name, debuff_message or debuff_name)
        return true
    end

    return false
end

---  ═══════════════════════════════════════════════════════════════════════════
---   INTEGRATION HELPERS
---  ═══════════════════════════════════════════════════════════════════════════

--- Main guard function to be called at start of precast
--- Checks all action types and blocks if necessary
--- @param spell table Spell/action object
--- @param eventArgs table Event arguments
--- @return boolean blocked True if action was blocked
function PrecastGuard.guard_precast(spell, eventArgs)
    -- Check specific action type using dedicated functions
    -- WeaponSkills get special handling (no auto-cure, no blocking for paralysis)
    -- JobAbilities get auto-cure for paralysis
    -- Magic gets auto-cure for silence
    if spell.type == "WeaponSkill" or spell.type == "Weaponskill" then
        return PrecastGuard.check_ws(spell, eventArgs)
    elseif spell.type == "JobAbility" or spell.type == "Ability" or spell.type == "PetCommand" then
        return PrecastGuard.check_ja(spell, eventArgs)
    elseif spell.type == "Magic" then
        return PrecastGuard.check_magic(spell, eventArgs)
    elseif spell.type == "Item" then
        return PrecastGuard.check_item(spell, eventArgs)
    else
        -- Fallback for unknown types - use generic check
        return PrecastGuard.check_and_block(spell, eventArgs)
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   UTILITY FUNCTIONS
---  ═══════════════════════════════════════════════════════════════════════════

--- Check if action would be blocked without actually blocking it
--- Useful for UI indicators or pre-validation
--- @param action_type string Type of action to check
--- @return boolean blocked True if action would be blocked
--- @return string|nil debuff_name Name of blocking debuff
function PrecastGuard.would_block(action_type)
    local blocked, debuff_name = DebuffChecker.check_action_blocked(action_type)
    return blocked, debuff_name
end

--- Get status of all current blocking debuffs
--- @return table List of active blocking debuffs
function PrecastGuard.get_active_blocks()
    return DebuffChecker.get_all_active_blocks()
end

return PrecastGuard

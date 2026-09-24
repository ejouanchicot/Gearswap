---  ═══════════════════════════════════════════════════════════════════════════
---   Precast Guard - Action Blocking Prevention System
---  ═══════════════════════════════════════════════════════════════════════════
---   Prevents actions from executing when blocked by debuffs, avoiding
---   unnecessary equipment swaps and providing clear feedback to the player.
---
---   @file    shared/utils/debuff/precast_guard.lua
---   @author  Tetsouo
---   @version 1.4 - Cure lock remembers its item, so a second debuff is not
---                  silently swallowed while a cure for the first is in flight
---   @date    Created: 2025-10-02 | Updated: 2026-09-18
---  ═══════════════════════════════════════════════════════════════════════════

local MessageCore = require('shared/utils/messages/message_core')

local PrecastGuard = {}

local DebuffChecker = require('shared/utils/debuff/debuff_checker')
local MessageDebuffs = require('shared/utils/messages/formatters/magic/message_debuffs')
local AutoMedicine = require('shared/utils/debuff/auto_medicine')

local config_success, AutoCureConfig = pcall(require, 'shared/config/DEBUFF_AUTOCURE_CONFIG')
if not config_success then
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

-- Cure item lists, tried in order (empty list when the config omits them)
local SILENCE_CURE_ITEMS = AutoCureConfig.silence_cure_items or {}
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

--- How long a cure item stays "in flight" before another one may be sent.
---
--- FFXI locks the character for the item animation, then the debuff takes a
--- moment to drop. Without this window every press during that time sent a
--- fresh /item that the server refused, while the success message claimed it
--- had worked - the feature looked unreliable when it was only being spammed.
local CURE_LOCK_DURATION = 3.0

--- Delay inserted between the precast cancel and the /item line.
---
--- Both land in the same packet-handler tick otherwise, and the client drops
--- the command often enough to notice.
local CURE_INPUT_DELAY = 0.4

--- os.clock() timestamp until which no further cure item may be sent.
---
--- One lock for every debuff, not one per debuff: the item animation locks the
--- whole character, so a Remedy sent for Paralysis while Echo Drops are still
--- in flight for Silence would be refused just the same.
local cure_lock_until = 0

--- Name of the item the lock is waiting on.
local cure_in_flight = nil

--- try_cure_debuff outcomes. Callers must tell BUSY from SENT: with Silence and
--- Paralysis at once, the Echo Drops in flight do nothing for the Paralysis,
--- and treating that as "handled" cancelled the JA without a word.
local CURE_SENT    = 'sent'     -- An item was sent for this debuff
local CURE_PENDING = 'pending'  -- The item in flight also cures this debuff
local CURE_BUSY    = 'busy'     -- An item for another debuff holds the lock
local CURE_NONE    = 'none'     -- No cure item in inventory

--- Is a cure item still on its way?
--- @return boolean pending True while the previous item use is unresolved
local function cure_pending()
    return os.clock() < cure_lock_until
end

--- Does this cure list contain the named item?
--- @param cure_items table List of { name, id } entries
--- @param item_name string|nil Item name to look for
--- @return boolean listed True if the item cures this debuff
local function cure_list_has(cure_items, item_name)
    for _, cure_item in ipairs(cure_items) do
        if cure_item.name == item_name then
            return true
        end
    end
    return false
end

--- Try to use debuff cure item (Echo Drops, Remedy, Panacea, etc.)
--- @param cure_items table List of cure items to try (in priority order)
--- @param action_name string The action that was blocked
--- @param debuff_message string The debuff message to display
--- @param success_msg_func function Message function to call on success
--- @return string status CURE_SENT, CURE_PENDING, CURE_BUSY or CURE_NONE
local function try_cure_debuff(cure_items, action_name, debuff_message, success_msg_func)
    if cure_pending() then
        -- Stay quiet only when the item on its way fixes this debuff too.
        if cure_list_has(cure_items, cure_in_flight) then
            return CURE_PENDING
        end
        return CURE_BUSY
    end

    for _, cure_item in ipairs(cure_items) do
        if has_item_in_inventory(cure_item.id) then
            cure_lock_until = os.clock() + CURE_LOCK_DURATION
            cure_in_flight = cure_item.name

            windower.send_command(
                'wait ' .. CURE_INPUT_DELAY ..
                '; input /item "' .. cure_item.name .. '" <me>'
            )

            success_msg_func(cure_item.name, action_name, debuff_message)

            return CURE_SENT
        end
    end

    return CURE_NONE
end

--- Try to use silence cure item (Echo Drops or Remedy)
--- @param spell_name string The spell that was blocked
--- @param debuff_message string The debuff message to display (e.g., "Silenced")
--- @return string status See try_cure_debuff
local function try_cure_silence(spell_name, debuff_message)
    return try_cure_debuff(SILENCE_CURE_ITEMS, spell_name, debuff_message, MessageDebuffs.show_silence_cure_success)
end

--- Try to use paralysis cure item (Remedy or Panacea)
--- @param action_name string The action that was blocked (JA or WS)
--- @param debuff_message string The debuff message to display (e.g., "Paralyzed")
--- @return string status See try_cure_debuff
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

    -- action_type is the engine's broad category (Magic/Ability/Item...), set
    -- for every action, whereas spell.type is the resource sub-type.
    local action_type = spell.action_type or spell.type

    local blocked, debuff_name, debuff_message = DebuffChecker.check_action_blocked(action_type)

    if blocked then
        local debuff_lower = normalize_debuff_name(debuff_name)

        local should_auto_cure = false
        local cure_type = nil  -- "silence" or "paralysis"

        if debuff_lower == "silence" and AutoCureConfig.auto_cure_silence then
            should_auto_cure = true
            cure_type = "silence"
        end

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

        -- AutoMedicine Off only skips the item use - the action stays blocked,
        -- since firing a JA while paralyzed burns its recast on a failed use.
        if should_auto_cure and AutoMedicine.is_enabled() then
            local cure_status = nil

            if cure_type == "silence" and action_type == "Magic" then
                cure_status = try_cure_silence(spell.name, debuff_message)
                if cure_status == CURE_NONE then
                    eventArgs.cancel = true
                    MessageDebuffs.show_no_silence_cure(spell.name, debuff_message)
                    return true
                end
            elseif cure_type == "paralysis"
                and (action_type == "Ability" or action_type == "JobAbility")
                and spell.type ~= "WeaponSkill" and spell.type ~= "Weaponskill" then
                -- Remedy or Panacea for Paralysis, job abilities only.
                -- The weaponskill test reads spell.type, not action_type:
                -- weaponskills report action_type 'Ability' like any other, so
                -- testing action_type for 'WeaponSkill' never matches anything.
                -- guard_precast routes weaponskills to check_ws long before
                -- here, which lets paralysis through on purpose, so this only
                -- guards the fallback path for action types we do not know.
                cure_status = try_cure_paralysis(spell.name, debuff_message)
                if cure_status == CURE_NONE then
                    eventArgs.cancel = true
                    MessageDebuffs.show_no_paralysis_cure(spell.name, debuff_message)
                    return true
                end
            end

            if cure_status == CURE_SENT or cure_status == CURE_PENDING then
                eventArgs.cancel = true
                return true
            end
            -- CURE_BUSY falls through to the plain blocked message below.
        end

        -- Cancel before any gear is swapped for an action that cannot happen
        eventArgs.cancel = true
        MessageDebuffs.show_action_blocked(spell.name, action_type, debuff_message or debuff_name)

        return true
    end

    return false
end

--- Check magic spells specifically.
--- Only acts when spell.type is 'Magic'. GearSwap sets spell.type to the
--- resource sub-type (WhiteMagic, BlackMagic, Ninjutsu, BardSong...), so real
--- spells never match here and reach check_and_block through guard_precast.
--- @param spell table Spell object
--- @param eventArgs table Event arguments
--- @return boolean blocked True if spell was blocked
function PrecastGuard.check_magic(spell, eventArgs)
    if spell.type ~= "Magic" then
        return false
    end

    local blocked, debuff_name, debuff_message = DebuffChecker.check_magic_blocked()

    if blocked then
        local debuff_lower = normalize_debuff_name(debuff_name)
        local should_auto_cure = false

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

        if should_auto_cure and AutoMedicine.is_enabled() then
            local cure_status = try_cure_silence(spell.name, debuff_message)
            if cure_status == CURE_SENT or cure_status == CURE_PENDING then
                eventArgs.cancel = true  -- Cancel this attempt, player can retry after cure
                return true
            elseif cure_status == CURE_NONE then
                eventArgs.cancel = true
                MessageDebuffs.show_no_silence_cure(spell.name, debuff_message)
                return true
            end
            -- CURE_BUSY falls through to the plain blocked message below.
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
        local debuff_lower = normalize_debuff_name(debuff_name)
        local should_auto_cure = false

        if debuff_lower == "paralysis" and AutoCureConfig.auto_cure_paralysis then
            should_auto_cure = true
        end

        -- Test mode: Defender simulates Paralysis (hardcoded, unlike test_debuff)
        if AutoCureConfig.test_mode and debuff_lower == "defender" then
            should_auto_cure = true
            if AutoCureConfig.debug then
                MessageCore.show_test_mode('Using Defender to simulate Paralysis')
            end
        end

        if should_auto_cure and AutoMedicine.is_enabled() then
            local cure_status = try_cure_paralysis(spell.name, debuff_message)
            if cure_status == CURE_SENT or cure_status == CURE_PENDING then
                eventArgs.cancel = true  -- Cancel this attempt, player can retry after cure
                return true
            elseif cure_status == CURE_NONE then
                eventArgs.cancel = true
                MessageDebuffs.show_no_paralysis_cure(spell.name, debuff_message)
                return true
            end
            -- CURE_BUSY falls through to the plain blocked message below.
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
        local debuff_lower = normalize_debuff_name(debuff_name)

        if debuff_lower == "paralysis" then
            return false
        end

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
    -- WeaponSkills: no auto-cure, paralysis not blocked.
    -- JobAbilities: auto-cure for paralysis.
    -- Spells (spell.type WhiteMagic, BlackMagic, ... never 'Magic') and other
    -- ability sub-types (CorsairRoll, Waltz, ...) fall through to
    -- check_and_block, which routes on action_type: auto-cure for silence
    -- (magic) and paralysis (abilities).
    if spell.type == "WeaponSkill" or spell.type == "Weaponskill" then
        return PrecastGuard.check_ws(spell, eventArgs)
    elseif spell.type == "JobAbility" or spell.type == "Ability" or spell.type == "PetCommand" then
        return PrecastGuard.check_ja(spell, eventArgs)
    elseif spell.type == "Magic" then
        return PrecastGuard.check_magic(spell, eventArgs)
    elseif spell.type == "Item" then
        return PrecastGuard.check_item(spell, eventArgs)
    else
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

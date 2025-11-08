---============================================================================
--- Debuff Checker - Action Blocking Detection System
---============================================================================
--- Detects status ailments that block actions (spells, abilities, items, etc.)
--- and provides detailed information about what is blocked and why.
---
--- TEST MODE: Set TEST_MODE = false on line 24 for production use
--- Test buff mappings (WAR buffs simulate debuffs):
---   - Berserk   >> Silence (blocks magic)
---   - Aggressor >> Amnesia (blocks JA/WS)
---   - Warcry    >> Stun (blocks EVERYTHING)
---
--- @file utils/debuff/debuff_checker.lua
--- @author Tetsouo
--- @version 1.1
--- @date Created: 2025-10-02
--- @date Updated: 2025-10-02 - Multi-buff test system
---============================================================================

local DebuffChecker = {}

-- Load configuration
local config_success, AutoCureConfig = pcall(require, 'shared/config/DEBUFF_AUTOCURE_CONFIG')
local TEST_MODE = config_success and AutoCureConfig.test_mode or false

---============================================================================
--- DEBUFF DEFINITIONS
---============================================================================

-- TEST MODE: Use WAR buffs to simulate blocking debuffs for easy testing
-- Controlled by shared/config/DEBUFF_AUTOCURE_CONFIG.lua
-- local TEST_MODE = false  -- Now loaded from config

-- Test buff mappings (WAR buffs simulate debuffs)
local TEST_DEBUFF_MAPPINGS = {
    ['Berserk'] = "Silence",      -- Berserk simulates Silence (blocks magic)
    ['Aggressor'] = "Amnesia",    -- Aggressor simulates Amnesia (blocks JA/WS)
    ['Warcry'] = "Stun",          -- Warcry simulates Stun (blocks EVERYTHING)
    ['Defender'] = "Paralysis"    -- Defender simulates Paralysis (blocks JA/WS)
}

-- Real debuff definitions (TEST_MODE uses these to map buffs to debuffs)
local DEBUFF_DEFINITIONS = {
    -- Magic blocking
    Silence = { category = "magic", priority = 1, message = "Silenced" },
    Mute = { category = "magic", priority = 2, message = "Muted" },
    Omerta = { category = "magic", priority = 3, message = "Omerta" },

    -- JA blocking
    Amnesia = { category = "ja", priority = 1, message = "Amnesia" },
    Impairment = { category = "ja", priority = 2, message = "Impaired" },

    -- Paralysis blocking (blocks JA and WS, two IDs use same buffactive name)
    Paralysis = { category = "paralysis", priority = 1, message = "Paralyzed" },      -- ID 4 and ID 566 (both curable)

    -- Universal blocking (blocks EVERYTHING: spells, JA, WS, items, ranged)
    Stun = { category = "universal", priority = 1, message = "Stunned" },        -- Highest priority
    Sleep = { category = "universal", priority = 2, message = "Asleep" },
    Petrification = { category = "universal", priority = 3, message = "Petrified" },
    Terror = { category = "universal", priority = 4, message = "Terrified" },

    -- Item blocking
    Encumbrance = { category = "item", priority = 1, message = "Encumbered" }
}

-- Build active detection lists based on TEST_MODE
local MAGIC_BLOCKING_DEBUFFS = {}
local JA_BLOCKING_DEBUFFS = {}
local UNIVERSAL_BLOCKING_DEBUFFS = {}
local WS_BLOCKING_DEBUFFS = {}
local ITEM_BLOCKING_DEBUFFS = {}

if TEST_MODE then
    -- Map each test buff to its simulated debuff
    for test_buff, debuff_type in pairs(TEST_DEBUFF_MAPPINGS) do
        local def = DEBUFF_DEFINITIONS[debuff_type]
        if def then
            local entry = { priority = def.priority, message = def.message }

            if def.category == "magic" then
                MAGIC_BLOCKING_DEBUFFS[test_buff] = entry
            elseif def.category == "ja" then
                JA_BLOCKING_DEBUFFS[test_buff] = entry
                WS_BLOCKING_DEBUFFS[test_buff] = entry  -- JA debuffs also block WS
            elseif def.category == "paralysis" then
                JA_BLOCKING_DEBUFFS[test_buff] = entry  -- Paralysis blocks JA
                WS_BLOCKING_DEBUFFS[test_buff] = entry  -- Paralysis also blocks WS
            elseif def.category == "universal" then
                -- Universal blocks ALL action types
                UNIVERSAL_BLOCKING_DEBUFFS[test_buff] = entry
            elseif def.category == "item" then
                ITEM_BLOCKING_DEBUFFS[test_buff] = entry
            end
        end
    end
else
    -- Production mode: use real debuffs (buffactive uses lowercase names)
    MAGIC_BLOCKING_DEBUFFS = {
        ['silence'] = { priority = 1, message = "Silenced" },
        ['mute'] = { priority = 2, message = "Muted" },
        ['omerta'] = { priority = 3, message = "Omerta" }
    }

    JA_BLOCKING_DEBUFFS = {
        ['amnesia'] = { priority = 1, message = "Amnesia" },
        ['impairment'] = { priority = 2, message = "Impaired" },
        ['paralysis'] = { priority = 3, message = "Paralyzed" }     -- ID 4 and ID 566 (both curable)
    }

    -- Universal blocking debuffs (checked FIRST for all action types)
    UNIVERSAL_BLOCKING_DEBUFFS = {
        ['stun'] = { priority = 1, message = "Stunned" },           -- Blocks EVERYTHING
        ['sleep'] = { priority = 2, message = "Asleep" },           -- Blocks EVERYTHING
        ['petrification'] = { priority = 3, message = "Petrified" }, -- Blocks EVERYTHING
        ['terror'] = { priority = 4, message = "Terrified" }         -- Blocks EVERYTHING
    }

    WS_BLOCKING_DEBUFFS = {
        ['amnesia'] = { priority = 1, message = "Amnesia" },
        ['impairment'] = { priority = 2, message = "Impaired" },
        ['paralysis'] = { priority = 3, message = "Paralyzed" }     -- ID 4 and ID 566 (both curable)
    }

    ITEM_BLOCKING_DEBUFFS = {
        ['encumbrance'] = { priority = 1, message = "Encumbered" }
    }
end

---============================================================================
--- DETECTION FUNCTIONS
---============================================================================

--- Get the highest priority debuff from a list
--- @param debuff_list table List of debuffs to check
--- @return string|nil debuff_name The debuff blocking the action (or nil)
--- @return string|nil message User-friendly message
local function get_active_blocking_debuff(debuff_list)
    if not buffactive then
        return nil, nil
    end

    local highest_priority = 999
    local blocking_debuff = nil
    local blocking_message = nil

    for debuff_name, debuff_info in pairs(debuff_list) do
        if buffactive[debuff_name] then
            if debuff_info.priority < highest_priority then
                highest_priority = debuff_info.priority
                blocking_debuff = debuff_name
                blocking_message = debuff_info.message
            end
        end
    end

    return blocking_debuff, blocking_message
end

--- Check if magic casting is blocked
--- @return boolean blocked True if magic is blocked
--- @return string|nil debuff_name The debuff blocking magic
--- @return string|nil message User-friendly message
function DebuffChecker.check_magic_blocked()
    -- Check universal blocks first
    local universal_debuff, universal_msg = get_active_blocking_debuff(UNIVERSAL_BLOCKING_DEBUFFS)
    if universal_debuff then
        return true, universal_debuff, universal_msg
    end

    -- Check magic-specific blocks
    local magic_debuff, magic_msg = get_active_blocking_debuff(MAGIC_BLOCKING_DEBUFFS)
    if magic_debuff then
        return true, magic_debuff, magic_msg
    end

    return false, nil, nil
end

--- Check if job abilities are blocked
--- @return boolean blocked True if JA is blocked
--- @return string|nil debuff_name The debuff blocking JA
--- @return string|nil message User-friendly message
function DebuffChecker.check_ja_blocked()
    -- Check universal blocks first
    local universal_debuff, universal_msg = get_active_blocking_debuff(UNIVERSAL_BLOCKING_DEBUFFS)
    if universal_debuff then
        return true, universal_debuff, universal_msg
    end

    -- Check JA-specific blocks
    local ja_debuff, ja_msg = get_active_blocking_debuff(JA_BLOCKING_DEBUFFS)
    if ja_debuff then
        return true, ja_debuff, ja_msg
    end

    return false, nil, nil
end

--- Check if weapon skills are blocked
--- @return boolean blocked True if WS is blocked
--- @return string|nil debuff_name The debuff blocking WS
--- @return string|nil message User-friendly message
function DebuffChecker.check_ws_blocked()
    -- Check universal blocks first
    local universal_debuff, universal_msg = get_active_blocking_debuff(UNIVERSAL_BLOCKING_DEBUFFS)
    if universal_debuff then
        return true, universal_debuff, universal_msg
    end

    -- Check WS-specific blocks
    local ws_debuff, ws_msg = get_active_blocking_debuff(WS_BLOCKING_DEBUFFS)
    if ws_debuff then
        return true, ws_debuff, ws_msg
    end

    return false, nil, nil
end

--- Check if item usage is blocked
--- @return boolean blocked True if items are blocked
--- @return string|nil debuff_name The debuff blocking items
--- @return string|nil message User-friendly message
function DebuffChecker.check_item_blocked()
    -- Check universal blocks first
    local universal_debuff, universal_msg = get_active_blocking_debuff(UNIVERSAL_BLOCKING_DEBUFFS)
    if universal_debuff then
        return true, universal_debuff, universal_msg
    end

    -- Check item-specific blocks
    local item_debuff, item_msg = get_active_blocking_debuff(ITEM_BLOCKING_DEBUFFS)
    if item_debuff then
        return true, item_debuff, item_msg
    end

    return false, nil, nil
end

--- Check if ANY action is blocked (catch-all)
--- @param action_type string Type of action ("Magic", "Ability", "WeaponSkill", "Item", "Ranged")
--- @return boolean blocked True if action is blocked
--- @return string|nil debuff_name The debuff blocking the action
--- @return string|nil message User-friendly message
function DebuffChecker.check_action_blocked(action_type)
    if action_type == "Magic" then
        return DebuffChecker.check_magic_blocked()
    elseif action_type == "Ability" or action_type == "JobAbility" or action_type == "PetCommand" then
        return DebuffChecker.check_ja_blocked()
    elseif action_type == "WeaponSkill" or action_type == "Weaponskill" then
        return DebuffChecker.check_ws_blocked()
    elseif action_type == "Item" then
        return DebuffChecker.check_item_blocked()
    elseif action_type == "Ranged" then
        -- Ranged attacks have same restrictions as WS generally
        return DebuffChecker.check_ws_blocked()
    else
        -- Unknown action type, check universal blocks only
        local universal_debuff, universal_msg = get_active_blocking_debuff(UNIVERSAL_BLOCKING_DEBUFFS)
        if universal_debuff then
            return true, universal_debuff, universal_msg
        end
    end

    return false, nil, nil
end

---============================================================================
--- UTILITY FUNCTIONS
---============================================================================

--- Get all currently active blocking debuffs
--- @return table List of active blocking debuffs {name, message, blocks}
function DebuffChecker.get_all_active_blocks()
    if not buffactive then
        return {}
    end

    local active_blocks = {}

    -- Check universal blocks
    for debuff_name, debuff_info in pairs(UNIVERSAL_BLOCKING_DEBUFFS) do
        if buffactive[debuff_name] then
            table.insert(active_blocks, {
                name = debuff_name,
                message = debuff_info.message,
                blocks = "All Actions"
            })
        end
    end

    -- Check magic blocks
    for debuff_name, debuff_info in pairs(MAGIC_BLOCKING_DEBUFFS) do
        if buffactive[debuff_name] and not UNIVERSAL_BLOCKING_DEBUFFS[debuff_name] then
            table.insert(active_blocks, {
                name = debuff_name,
                message = debuff_info.message,
                blocks = "Magic"
            })
        end
    end

    -- Check JA blocks
    for debuff_name, debuff_info in pairs(JA_BLOCKING_DEBUFFS) do
        if buffactive[debuff_name] and not UNIVERSAL_BLOCKING_DEBUFFS[debuff_name] then
            table.insert(active_blocks, {
                name = debuff_name,
                message = debuff_info.message,
                blocks = "Job Abilities"
            })
        end
    end

    return active_blocks
end

--- Check if player is currently incapacitated (any blocking debuff active)
--- @return boolean incapacitated True if any blocking debuff is active
function DebuffChecker.is_incapacitated()
    local universal_debuff = get_active_blocking_debuff(UNIVERSAL_BLOCKING_DEBUFFS)
    return universal_debuff ~= nil
end

return DebuffChecker

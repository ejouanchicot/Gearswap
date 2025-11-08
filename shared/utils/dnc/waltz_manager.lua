---============================================================================
--- Waltz Manager - Centralized Waltz Management for DNC main/sub
---============================================================================
--- Provides intelligent waltz casting for both Curing (single target) and
--- Divine (AoE) waltzes with HP-based tier selection, TP management, and
--- professional message formatting.
---
--- Features:
---   • Curing Waltz (single target) - HP-based tier selection (V > IV > III > II > I)
---   • Divine Waltz (AoE) - Highest tier available (II > I)
---   • Intelligent tier selection based on target missing HP
---   • TP threshold checking (200-800 TP depending on tier)
---   • Recast validation (uses RECAST_CONFIG tolerance)
---   • Level detection (main job vs subjob effective level)
---   • Target HP estimation (exact for self, estimated for party members)
---   • Priority fallback (preferred tier >> lower tiers if unavailable)
---   • Professional status messages (cooldown/TP with job tag)
---   • Centralized for all jobs with DNC main/sub
---
--- @file    utils/dnc/waltz_manager.lua
--- @author  Tetsouo
--- @version 1.0
--- @date    Created: 2025-10-05
---============================================================================

local WaltzManager = {}

-- Load recast tolerance configuration
local RECAST_CONFIG = _G.RECAST_CONFIG or {}  -- Loaded from character main file

-- Safe wrappers for RECAST_CONFIG methods (with fallback if config not loaded)
local function is_recast_ready(recast)
    if RECAST_CONFIG and RECAST_CONFIG.is_ready then
        return RECAST_CONFIG.is_ready(recast)
    else
        return (recast == 0)
    end
end

local function is_on_cooldown(recast)
    if RECAST_CONFIG and RECAST_CONFIG.on_cooldown then
        return RECAST_CONFIG.on_cooldown(recast)
    else
        return (recast > 0)
    end
end

--- Waltz configuration (from res/job_abilities.lua)
local WALTZ_CONFIG = {
    -- Curing Waltz (Single Target) - Priority order V > IV > III > II > I
    curing = {
        { name = "Curing Waltz V",   tp = 800, recast_id = 189, level = 87 }, -- ID 311
        { name = "Curing Waltz IV",  tp = 650, recast_id = 188, level = 70 }, -- ID 193
        { name = "Curing Waltz III", tp = 500, recast_id = 187, level = 45 }, -- ID 192
        { name = "Curing Waltz II",  tp = 350, recast_id = 186, level = 35 }, -- ID 191
        { name = "Curing Waltz",     tp = 200, recast_id = 217, level = 15 } -- ID 190
    },
    -- Divine Waltz (AOE) - Priority order II > I
    divine = {
        { name = "Divine Waltz II", tp = 800, recast_id = 190, level = 78 }, -- ID 195
        { name = "Divine Waltz",    tp = 400, recast_id = 225, level = 40 } -- ID 194
    }
}

--- Calculate missing HP for target
--- @param target table Target info from windower
--- @return number|nil Missing HP or nil if cannot determine
local function get_missing_hp(target)
    if not target then return nil end

    -- Self: exact missing HP
    if target.name == player.name then
        return player.max_hp - player.hp
    end

    -- Party/alliance member: estimate from HPP
    if target.isallymember then
        local ally = find_player_in_alliance(target.name)
        if ally and ally.hpp then
            local est_max_hp = ally.hp / (ally.hpp / 100)
            return math.floor(est_max_hp - ally.hp)
        end
    end

    return nil
end

--- Cast Curing Waltz with intelligent tier selection based on HP needs
--- @param target_type string Target type (<stpc>, <t>, <me>, etc.)
function WaltzManager.cast_curing_waltz(target_type)
    target_type = target_type or '<stpc>'

    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local MessageCore = require('shared/utils/messages/message_core')
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local current_tp = player.tp
    local job_tag = MessageFormatter.get_job_tag()

    -- Determine effective level (main job or subjob)
    local effective_level = player.main_job == 'DNC' and player.main_job_level or player.sub_job_level

    -- Get target info
    local target = windower.ffxi.get_mob_by_target('st') or windower.ffxi.get_mob_by_target('me')
    local missing_hp = get_missing_hp(target)

    -- Determine optimal waltz tier based on missing HP
    local preferred_waltz = nil
    if missing_hp then
        for _, waltz in ipairs(WALTZ_CONFIG.curing) do
            if effective_level >= waltz.level then
                if (waltz.name == "Curing Waltz" and missing_hp < 200) or
                    (waltz.name == "Curing Waltz II" and missing_hp >= 200 and missing_hp < 600) or
                    (waltz.name == "Curing Waltz III" and missing_hp >= 600 and missing_hp < 1100) or
                    (waltz.name == "Curing Waltz IV" and missing_hp >= 1100 and missing_hp < 1500) or
                    (waltz.name == "Curing Waltz V" and missing_hp >= 1500) then
                    preferred_waltz = waltz
                    break
                end
            end
        end
    end

    -- Build priority list
    local waltz_priority = {}
    if preferred_waltz then
        table.insert(waltz_priority, preferred_waltz)
    end
    for _, waltz in ipairs(WALTZ_CONFIG.curing) do
        if waltz ~= preferred_waltz and effective_level >= waltz.level then
            table.insert(waltz_priority, waltz)
        end
    end

    -- Try each waltz in priority order
    for _, waltz in ipairs(waltz_priority) do
        local recast = ability_recasts[waltz.recast_id] or 0
        if is_recast_ready(recast) and current_tp >= waltz.tp then
            send_command('input /ja "' .. waltz.name .. '" ' .. target_type)
            if missing_hp then
                MessageFormatter.show_waltz_heal(waltz.name, missing_hp, nil, job_tag)
            end
            return
        end
    end

    -- No waltz available - collect blocking reasons
    local messages = {}
    local tp_message_added = false

    for _, waltz in ipairs(WALTZ_CONFIG.curing) do
        if effective_level >= waltz.level then
            local recast = ability_recasts[waltz.recast_id] or 0
            if is_on_cooldown(recast) then
                table.insert(messages, { type = "cooldown", name = waltz.name, value = recast })
            elseif current_tp < waltz.tp and not tp_message_added then
                table.insert(messages, { type = "tp", name = waltz.name, value = current_tp, extra = waltz.tp })
                tp_message_added = true
            end
        end
    end

    if #messages > 0 then
        MessageFormatter.show_multi_status(messages, job_tag)
    end
end

--- Cast Divine Waltz (AoE)
function WaltzManager.cast_divine_waltz()
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local MessageCore = require('shared/utils/messages/message_core')
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local current_tp = player.tp
    local job_tag = MessageFormatter.get_job_tag()

    -- Determine effective level
    local effective_level = player.main_job == 'DNC' and player.main_job_level or player.sub_job_level

    -- Try each Divine Waltz from highest to lowest
    for _, waltz in ipairs(WALTZ_CONFIG.divine) do
        if effective_level >= waltz.level then
            local recast = ability_recasts[waltz.recast_id] or 0

            if is_recast_ready(recast) and current_tp >= waltz.tp then
                -- Execute Divine Waltz directly
                if waltz.name == "Divine Waltz II" then
                    send_command('input /ja "Divine Waltz II" <me>')
                else
                    send_command('input /ja "Divine Waltz" <me>')
                end

                -- Display success message
                MessageFormatter.show_waltz_heal(waltz.name, nil, nil, job_tag)
                return
            end
        end
    end

    -- No Divine Waltz available - collect blocking reasons
    local messages = {}
    local tp_message_added = false

    for _, waltz in ipairs(WALTZ_CONFIG.divine) do
        if effective_level >= waltz.level then
            local recast = ability_recasts[waltz.recast_id] or 0

            if is_on_cooldown(recast) then
                table.insert(messages, { type = "cooldown", name = waltz.name, value = recast })
            elseif current_tp < waltz.tp and not tp_message_added then
                table.insert(messages, { type = "tp", name = waltz.name, value = current_tp, extra = waltz.tp })
                tp_message_added = true
            end
        end
    end

    if #messages > 0 then
        MessageFormatter.show_multi_status(messages, job_tag)
    end
end

return WaltzManager

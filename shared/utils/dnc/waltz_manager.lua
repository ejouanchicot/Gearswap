---  ═══════════════════════════════════════════════════════════════════════════
---   Waltz Manager - Centralized Waltz Management for DNC main/sub
---  ═══════════════════════════════════════════════════════════════════════════
---   Provides intelligent waltz casting for both Curing (single target) and
---   Divine (AoE) waltzes with HP-based tier selection, TP management, and
---   professional message formatting.
---
---   Features:
---     • Curing Waltz (single target) - HP-based tier selection (V > IV > III > II > I)
---     • Divine Waltz (AoE) - Highest tier available (II > I)
---     • Intelligent tier selection based on target missing HP
---     • TP threshold checking (200-800 TP depending on tier)
---     • Recast validation (uses RECAST_CONFIG tolerance)
---     • Level detection (main job vs subjob effective level)
---     • Target HP estimation (exact for self, estimated for party members)
---     • Priority fallback (preferred tier >> lower tiers if unavailable)
---     • Professional status messages (cooldown/TP with job tag)
---     • Centralized for all jobs with DNC main/sub
---
---   @file    shared/utils/dnc/waltz_manager.lua
---   @author  Tetsouo
---   @version 1.2 - Critical fixes: division/0 + sub_job nil + Divine Waltz hardcode
---   @date    Created: 2025-10-05 | Updated: 2025-11-13
---  ═══════════════════════════════════════════════════════════════════════════

local WaltzManager = {}

-- is_recast_ready / is_on_cooldown resolved as globals from RECAST_CONFIG.lua
-- (loaded by entry point before job functions). Do not redeclare locally.

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
        local party = windower.ffxi.get_party()
        if party then
            -- Search in party members (0-5)
            for i = 0, 5 do
                local member = party['p' .. i]
                if member and member.name == target.name and member.hpp and member.hpp > 0 then
                    local est_max_hp = member.hp / (member.hpp / 100)
                    return math.floor(est_max_hp - member.hp)
                end
            end

            -- Search in alliance members (a10-a15, a20-a25)
            for alliance_idx = 1, 2 do
                for member_idx = 0, 5 do
                    local member = party['a' .. alliance_idx .. member_idx]
                    if member and member.name == target.name and member.hpp and member.hpp > 0 then
                        local est_max_hp = member.hp / (member.hpp / 100)
                        return math.floor(est_max_hp - member.hp)
                    end
                end
            end
        end
    end

    return nil
end

-- Each curing tier owns a band of missing HP. The bands are contiguous and the
-- top one is open-ended; the bottom one has no floor, so a target that somehow
-- reads as negative still lands on Tier I rather than on nothing.
local CURING_HP_BRACKET = {
    ["Curing Waltz"]     = { max = 200 },
    ["Curing Waltz II"]  = { min = 200,  max = 600 },
    ["Curing Waltz III"] = { min = 600,  max = 1100 },
    ["Curing Waltz IV"]  = { min = 1100, max = 1500 },
    ["Curing Waltz V"]   = { min = 1500 },
}

--- Missing HP of whoever the waltz will land on, when that can be known.
--- The <stpc> prompt only fires AFTER /ja is sent, so there is no 'st' target
--- to read here. The player's CURRENT target is used instead: if a party member
--- is already focused (F2/F3, click) the waltz can be sized correctly. A mob
--- target tells us nothing - the real target comes from the prompt - and with
--- no target at all the waltz is for the player.
--- @return number|nil Missing HP, or nil when it cannot be known yet
local function resolve_missing_hp()
    local cur_target = windower.ffxi.get_mob_by_target('t')

    if cur_target and (cur_target.name == player.name or cur_target.isallymember) then
        local missing_hp = get_missing_hp(cur_target)
        if missing_hp then return missing_hp end
    end

    if not cur_target then
        return get_missing_hp(windower.ffxi.get_mob_by_target('me'))
    end

    return nil
end

--- The tier to try first.
--- With HP known it is the one whose band the missing HP falls in. With HP
--- unknown it is the highest castable: the priority list still falls back on
--- recast or TP, and defaulting low used to read a full-HP self as "0 missing"
--- and pick Tier I while a party member was dying.
--- @param effective_level number DNC level, main or sub
--- @param missing_hp number|nil
--- @return table|nil Entry from WALTZ_CONFIG.curing
local function preferred_curing_waltz(effective_level, missing_hp)
    for _, waltz in ipairs(WALTZ_CONFIG.curing) do
        if effective_level >= waltz.level then
            if not missing_hp then
                return waltz
            end
            local bracket = CURING_HP_BRACKET[waltz.name]
            if bracket
                and (not bracket.min or missing_hp >= bracket.min)
                and (not bracket.max or missing_hp < bracket.max) then
                return waltz
            end
        end
    end
    return nil
end

--- The preferred tier first, then every other castable one as fallback.
--- @return table Array of WALTZ_CONFIG.curing entries
local function curing_priority(effective_level, preferred_waltz)
    local priority = {}
    if preferred_waltz then
        table.insert(priority, preferred_waltz)
    end
    for _, waltz in ipairs(WALTZ_CONFIG.curing) do
        if waltz ~= preferred_waltz and effective_level >= waltz.level then
            table.insert(priority, waltz)
        end
    end
    return priority
end

--- Why nothing fired: a cooldown per tier, and the TP shortfall once.
--- @return table Array of message descriptors for show_multi_status
local function curing_blockers(effective_level, ability_recasts, current_tp)
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

    return messages
end

--- Cast Curing Waltz with intelligent tier selection based on HP needs
--- @param target_type string Target type (<stpc>, <t>, <me>, etc.)
function WaltzManager.cast_curing_waltz(target_type)
    target_type = target_type or '<stpc>'

    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local current_tp = player.tp
    local job_tag = MessageFormatter.get_job_tag()

    local effective_level = player.main_job == 'DNC' and player.main_job_level or (player.sub_job_level or 0)
    local missing_hp = resolve_missing_hp()
    local preferred_waltz = preferred_curing_waltz(effective_level, missing_hp)

    for _, waltz in ipairs(curing_priority(effective_level, preferred_waltz)) do
        local recast = ability_recasts[waltz.recast_id] or 0
        if is_recast_ready(recast) and current_tp >= waltz.tp then
            send_command('input /ja "' .. waltz.name .. '" ' .. target_type)
            -- Always show which waltz fired; missing_hp may be nil when the
            -- target is chosen via the upcoming <stpc> prompt.
            MessageFormatter.show_waltz_heal(waltz.name, missing_hp, nil, job_tag)
            return
        end
    end

    local messages = curing_blockers(effective_level, ability_recasts, current_tp)
    if #messages > 0 then
        MessageFormatter.show_multi_status(messages, job_tag)
    end
end

--- Cast Divine Waltz (AoE)
function WaltzManager.cast_divine_waltz()
    local MessageFormatter = require('shared/utils/messages/message_formatter')
    local ability_recasts = windower.ffxi.get_ability_recasts()
    local current_tp = player.tp
    local job_tag = MessageFormatter.get_job_tag()

    -- Determine effective level
    local effective_level = player.main_job == 'DNC' and player.main_job_level or (player.sub_job_level or 0)

    -- Try each Divine Waltz from highest to lowest
    for _, waltz in ipairs(WALTZ_CONFIG.divine) do
        if effective_level >= waltz.level then
            local recast = ability_recasts[waltz.recast_id] or 0

            if is_recast_ready(recast) and current_tp >= waltz.tp then
                -- Execute Divine Waltz
                send_command('input /ja "' .. waltz.name .. '" <me>')

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

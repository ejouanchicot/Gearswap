---============================================================================
--- Universal Weapon Skill Messages Hook - Auto-Inject for All Jobs
---============================================================================
--- Automatically wraps user_post_precast to show WS messages for ALL jobs.
--- Simply include this file in get_sets() and it works automatically.
---
--- Usage in TETSOUO_JOB.lua:
---   function get_sets()
---       include('Mote-Include.lua')
---       include('shared/hooks/init_ws_messages.lua')  -- ← Add this line
---       include('jobs/[job]/functions/[job]_functions.lua')
---   end
---
--- Features:
---   - Works for ALL jobs (WAR, SAM, DNC, THF, etc.)
---   - Works for ALL subjobs
---   - Zero modification to job modules needed
---   - Automatically detects WS database
---   - Displays WS name + description + TP
---   - Respects WS_MESSAGES_CONFIG settings
---
--- Examples:
---   - [Upheaval] Four hits. Damage varies with TP. (2290 TP)
---   - [Rudra's Storm] Delivers a fourfold attack. (3000 TP)
---   - [Tachi: Fudo] Five-hit attack. (1850 TP)
---
--- @file init_ws_messages.lua
--- @author Tetsouo
--- @version 1.0 - Universal WS Messages Hook
--- @date Created: 2025-11-06
---============================================================================

local MessageFormatter = require('shared/utils/messages/message_formatter')
local WS_MESSAGES_CONFIG = require('shared/config/WS_MESSAGES_CONFIG')

---============================================================================
--- LOAD WS DATABASE
---============================================================================

local WS_DB_success, WS_DB = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
if not WS_DB_success then
    WS_DB = nil
end

---============================================================================
--- HOOK INJECTION
---============================================================================

-- Save original user_post_precast (if exists)
local original_user_post_precast = _G.user_post_precast

--- Wrapped user_post_precast with WS message handling
--- @param spell table Spell/Ability object from GearSwap
--- @param action table Action information
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function user_post_precast(spell, action, spellMap, eventArgs)
    -- Call original user_post_precast (if exists)
    if original_user_post_precast then
        original_user_post_precast(spell, action, spellMap, eventArgs)
    end

    -- Show universal WS message (only for weaponskills that weren't canceled)
    if spell and spell.type == 'WeaponSkill' and WS_MESSAGES_CONFIG.is_enabled() then
        -- Don't show message if WS was canceled (not enough TP, out of range, etc.)
        if eventArgs and eventArgs.cancel then
            return
        end

        -- Get current TP
        local player = windower.ffxi.get_player()
        local current_tp = player and player.vitals and player.vitals.tp or 0

        -- Don't show message if not enough TP (minimum 1000 TP for all WS)
        if current_tp < 1000 then
            return
        end

        -- Get WS data from database
        local ws_data = WS_DB and WS_DB.weaponskills and WS_DB.weaponskills[spell.english]

        -- Show WS message
        if ws_data and WS_MESSAGES_CONFIG.show_description() then
            -- Full mode: show description + TP
            MessageFormatter.show_ws_activated(spell.english, ws_data.description, current_tp)
        elseif WS_MESSAGES_CONFIG.is_tp_only() then
            -- TP only mode: show name + TP (use show_ws_tp for templates without description)
            MessageFormatter.show_ws_tp(spell.english, current_tp)
        end
    end
end

-- Export to global scope
_G.user_post_precast = user_post_precast

---============================================================================
--- INITIALIZATION MESSAGE
---============================================================================

-- Silent initialization (no spam in chat)
-- Message will appear when player uses a WS with message system active

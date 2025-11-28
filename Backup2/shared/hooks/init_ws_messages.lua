---  ═══════════════════════════════════════════════════════════════════════════
---   Universal Weapon Skill Messages Hook - Auto-Inject for All Jobs
---  ═══════════════════════════════════════════════════════════════════════════
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
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: All modules loaded on first WS usage (saves ~300ms at startup)
---
--- Examples:
---   - [Upheaval] Four hits. Damage varies with TP. (2290 TP)
---   - [Rudra's Storm] Delivers a fourfold attack. (3000 TP)
---   - [Tachi: Fudo] Five-hit attack. (1850 TP)
---
---   @file    shared/hooks/init_ws_messages.lua
---   @author  Tetsouo
---   @version 1.2 - Lazy Loading for performance
---   @date    Updated: 2025-11-15
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   LAZY LOADING - All modules loaded on first WS usage
---  ═══════════════════════════════════════════════════════════════════════════

local MessageFormatter = nil
local WS_MESSAGES_CONFIG = nil
local UniversalWS = nil
local modules_loaded = false

local function ensure_modules_loaded()
    if modules_loaded then
        return
    end

    -- Load MessageFormatter
    MessageFormatter = require('shared/utils/messages/message_formatter')

    -- Load WS Messages Config
    WS_MESSAGES_CONFIG = require('shared/config/WS_MESSAGES_CONFIG')

    -- Load WS database wrapper (not the full database)
    local UniversalWS_success
    UniversalWS_success, UniversalWS = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
    if not UniversalWS_success then
        UniversalWS = nil
    end

    modules_loaded = true
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOK INJECTION
---  ═══════════════════════════════════════════════════════════════════════════

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

    -- Lazy load modules on first WS usage
    if spell and spell.type == 'WeaponSkill' then
        ensure_modules_loaded()
    end

    -- Show universal WS message (only for Weapon Skills that weren't canceled)
    if spell and spell.type == 'WeaponSkill' and WS_MESSAGES_CONFIG and WS_MESSAGES_CONFIG.is_enabled() then
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

        -- LAZY LOAD: Load WS database on first WS usage (saves 260-650ms at startup)
        if UniversalWS then
            local WS_DB = UniversalWS.load()  -- ← Lazy load here
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
end

-- Export to global scope (allows chaining with other hooks)
_G.user_post_precast = user_post_precast

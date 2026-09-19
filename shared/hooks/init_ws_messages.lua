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
---   • Lazy-loaded: All modules loaded on first WS usage
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

    -- PROFILING: Measure lazy-load time on first WS
    local start_time = os.clock()
    local profiling_enabled = _G.PERFORMANCE_PROFILING and _G.PERFORMANCE_PROFILING.enabled

    -- Load MessageFormatter
    local mf_ok, mf_mod = pcall(require, 'shared/utils/messages/message_formatter')
    if mf_ok then MessageFormatter = mf_mod end

    -- Load WS Messages Config
    local cfg_ok, cfg_mod = pcall(require, 'shared/config/WS_MESSAGES_CONFIG')
    if cfg_ok then WS_MESSAGES_CONFIG = cfg_mod end

    -- Load WS database wrapper (not the full database)
    local UniversalWS_success
    UniversalWS_success, UniversalWS = pcall(require, 'shared/data/weaponskills/UNIVERSAL_WS_DATABASE')
    if not UniversalWS_success then
        UniversalWS = nil
    end

    modules_loaded = true

    -- PROFILING: Show lazy-load time
    if profiling_enabled then
        local elapsed = (os.clock() - start_time) * 1000
        local MessageFormatter = require('shared/utils/messages/message_formatter')
        MessageFormatter.show_debug('PERF', string.format('ws_message_handler loaded: %.0fms', elapsed))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOK INJECTION
---  ═══════════════════════════════════════════════════════════════════════════

-- Track wrap count (persists in windower table for syscheck diagnostics)
windower._hook_wraps = windower._hook_wraps or {ability = 0, ws = 0, midcast = 0}
windower._hook_wraps.ws = windower._hook_wraps.ws + 1

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

        if WS_MESSAGES_CONFIG.show_description() then
            -- Full mode: description + TP. Only this mode reads the database,
            -- and only the file of the weaponskill's own skill (spell.skill):
            -- the main hand is not always the weapon the WS belongs to.
            local ws_data = UniversalWS and UniversalWS.resolve(spell.english, spell.skill)
            if ws_data then
                MessageFormatter.show_ws_activated(spell.english, ws_data.description, current_tp)
            end
        elseif WS_MESSAGES_CONFIG.is_tp_only() then
            -- TP only mode: show name + TP (use show_ws_tp for templates without description)
            MessageFormatter.show_ws_tp(spell.english, current_tp)
        end
    end
end

-- Export to global scope (allows chaining with other hooks)
_G.user_post_precast = user_post_precast

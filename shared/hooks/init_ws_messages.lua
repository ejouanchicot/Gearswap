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
        add_to_chat(158, string.format('[PERF:LAZY] ws_message_handler loaded: %.0fms', elapsed))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   EQUIPPED WEAPON TYPE (for per-weapon lazy WS loading)
---  ═══════════════════════════════════════════════════════════════════════════

--- Get the FFXI resources table (cached global, windower.res, or require).
--- @return table|nil Resources table, or nil if unavailable
local function get_resources()
    local r = rawget(_G, 'res') or windower.res
    if r then return r end
    local ok, mod = pcall(require, 'resources')
    return ok and mod or nil
end

--- Resolve the equipped main weapon's skill type (e.g. 'Sword', 'Dagger').
--- Lets the first weaponskill load ONLY the matching WS database instead of all.
--- @return string|nil Weapon type name, or nil if it cannot be determined
local function get_equipped_weapon_type()
    if not (player and player.equipment and player.equipment.main) then
        return nil
    end
    local res = get_resources()
    if not (res and res.items and res.skills) then
        return nil
    end
    local item = res.items:with('en', player.equipment.main)
    if not (item and item.skill) then
        return nil
    end
    local skill = res.skills[item.skill]
    return skill and skill.en or nil
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

        -- LAZY LOAD: load ONLY the equipped weapon's WS database on first WS
        if UniversalWS then
            local weapon_type = get_equipped_weapon_type()
            local ws_data = UniversalWS.resolve(spell.english, weapon_type)

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

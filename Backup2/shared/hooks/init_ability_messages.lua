---  ═══════════════════════════════════════════════════════════════════════════
---   Universal Ability Messages Hook - Auto-Inject for All Jobs
---  ═══════════════════════════════════════════════════════════════════════════
--- Automatically wraps user_post_precast to show ability messages for ALL jobs.
--- Simply include this file in get_sets() and it works automatically.
---
--- Usage in TETSOUO_JOB.lua:
---   function get_sets()
---       include('Mote-Include.lua')
---       include('shared/hooks/init_ability_messages.lua')  -- ← Add this line
---       include('jobs/[job]/functions/[job]_functions.lua')
---   end
---
--- Features:
---   - Works for ALL jobs (WAR, DNC, PLD, BLM, RDM, etc.)
---   - Works for ALL subjobs (WAR/RUN, DNC/WAR, etc.)
---   - Zero modification to job modules needed
---   - Automatically detects ability database
---   - Displays messages for: Runes, Job Abilities, SP abilities, etc.
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Handler loaded on first ability usage (saves ~250ms at startup)
---
--- Examples:
---   - WAR/RUN using Ignis >> "[Ignis] Fire rune, resist ice"
---   - DNC/WAR using Provoke >> "[Provoke] Provokes enemy."
---   - PLD using Sentinel >> "[Sentinel] Reduces damage taken."
---
---   @file    shared/hooks/init_ability_messages.lua
---   @author  Tetsouo
---   @version 1.2 - Lazy Loading for performance
---   @date    Updated: 2025-11-15
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   LAZY LOADING - Handler loaded on first ability usage
---  ═══════════════════════════════════════════════════════════════════════════

local AbilityMessageHandler = nil
local handler_loaded = false

local function ensure_handler_loaded()
    if handler_loaded then
        return
    end

    -- PROFILING: Measure lazy-load time on first ability
    local start_time = os.clock()
    local profiling_enabled = _G.PERFORMANCE_PROFILING and _G.PERFORMANCE_PROFILING.enabled

    AbilityMessageHandler = require('shared/utils/messages/handlers/ability_message_handler')
    handler_loaded = true

    -- PROFILING: Show lazy-load time
    if profiling_enabled then
        local elapsed = (os.clock() - start_time) * 1000
        add_to_chat(158, string.format('[PERF:LAZY] ability_message_handler loaded: %.0fms', elapsed))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOK INJECTION
---  ═══════════════════════════════════════════════════════════════════════════

-- Save original user_post_precast (if exists)
local original_user_post_precast = _G.user_post_precast

--- Wrapped user_post_precast with ability message handling
--- @param spell table Spell/Ability object from GearSwap
--- @param action table Action information
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function user_post_precast(spell, action, spellMap, eventArgs)
    -- Call original user_post_precast (if exists)
    if original_user_post_precast then
        original_user_post_precast(spell, action, spellMap, eventArgs)
    end

    -- Lazy load handler on first ability usage
    if spell and spell.action_type == 'Ability' then
        ensure_handler_loaded()

        -- Show universal ability message
        if AbilityMessageHandler then
            AbilityMessageHandler.show_message(spell)
        end
    end
end

-- Export to global scope (allows chaining with other hooks)
_G.user_post_precast = user_post_precast

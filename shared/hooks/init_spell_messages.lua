---  ═══════════════════════════════════════════════════════════════════════════
---   Universal Spell Messages Hook - Auto-Inject for All Jobs
---  ═══════════════════════════════════════════════════════════════════════════
--- Automatically wraps user_post_midcast to show spell messages for ALL jobs.
--- Simply include this file in get_sets() and it works automatically.
---
--- Usage in TETSOUO_JOB.lua:
---   function get_sets()
---       include('Mote-Include.lua')
---       include('shared/hooks/init_spell_messages.lua')  -- ← Add this line
---       include('jobs/[job]/functions/[job]_functions.lua')
---   end
---
--- Features:
---   - Works for ALL jobs (WAR, DNC, PLD, BLM, RDM, etc.)
---   - Works for ALL subjobs (WAR/RDM, DNC/WHM, etc.)
---   - Zero modification to job modules needed
---   - Automatically detects spell database
---   - Respects ENFEEBLING_MESSAGES_CONFIG and ENHANCING_MESSAGES_CONFIG
---
--- **PERFORMANCE OPTIMIZATION:**
---   • Lazy-loaded: Handler loaded on first spell cast (saves ~200ms at startup)
---
---   @file    shared/hooks/init_spell_messages.lua
---   @author  Tetsouo
---   @version 1.2 - Lazy Loading for performance
---   @date    Updated: 2025-11-15
---  ═══════════════════════════════════════════════════════════════════════════

---  ═══════════════════════════════════════════════════════════════════════════
---   LAZY LOADING - Handler loaded on first spell cast
---  ═══════════════════════════════════════════════════════════════════════════

local SpellMessageHandler = nil
local handler_loaded = false

local function ensure_handler_loaded()
    if handler_loaded then
        return
    end

    -- PROFILING: Measure lazy-load time on first spell
    local start_time = os.clock()
    local profiling_enabled = _G.PERFORMANCE_PROFILING and _G.PERFORMANCE_PROFILING.enabled

    SpellMessageHandler = require('shared/utils/messages/handlers/spell_message_handler')
    handler_loaded = true

    -- PROFILING: Show lazy-load time
    if profiling_enabled then
        local elapsed = (os.clock() - start_time) * 1000
        add_to_chat(158, string.format('[PERF:LAZY] spell_message_handler loaded: %.0fms', elapsed))
    end
end

---  ═══════════════════════════════════════════════════════════════════════════
---   HOOK INJECTION
---  ═══════════════════════════════════════════════════════════════════════════

-- Save original user_post_midcast (if exists)
local original_user_post_midcast = _G.user_post_midcast

--- Wrapped user_post_midcast with spell message handling
--- @param spell table Spell object from GearSwap
--- @param action table Action information
--- @param spellMap string Spell mapping from Mote-Include
--- @param eventArgs table Event arguments
function user_post_midcast(spell, action, spellMap, eventArgs)
    -- Call original user_post_midcast (if exists)
    if original_user_post_midcast then
        original_user_post_midcast(spell, action, spellMap, eventArgs)
    end

    -- Lazy load handler on first spell cast
    if spell and spell.action_type == 'Magic' then
        ensure_handler_loaded()

        -- Show universal spell message
        if SpellMessageHandler then
            SpellMessageHandler.show_message(spell)
        end
    end
end

-- Export to global scope (allows chaining with other hooks)
_G.user_post_midcast = user_post_midcast

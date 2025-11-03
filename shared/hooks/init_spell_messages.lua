---============================================================================
--- Universal Spell Messages Hook - Auto-Inject for All Jobs
---============================================================================
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
--- @file init_spell_messages.lua
--- @author Tetsouo
--- @version 1.0 - Universal Spell Messages Hook
--- @date Created: 2025-10-30
---============================================================================

local SpellMessageHandler = require('shared/utils/messages/spell_message_handler')

---============================================================================
--- HOOK INJECTION
---============================================================================

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

    -- Show universal spell message
    SpellMessageHandler.show_message(spell)
end

-- Export to global scope
_G.user_post_midcast = user_post_midcast

---============================================================================
--- INITIALIZATION MESSAGE
---============================================================================

-- Silent initialization (no spam in chat)
-- Message will appear when player casts a spell with message system active

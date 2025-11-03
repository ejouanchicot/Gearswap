---============================================================================
--- Universal Ability Messages Hook - Auto-Inject for All Jobs
---============================================================================
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
--- Examples:
---   - WAR/RUN using Ignis → "[Ignis] Fire rune, resist ice"
---   - DNC/WAR using Provoke → "[Provoke] Provokes enemy."
---   - PLD using Sentinel → "[Sentinel] Reduces damage taken."
---
--- @file init_ability_messages.lua
--- @author Tetsouo
--- @version 1.0 - Universal Ability Messages Hook
--- @date Created: 2025-11-01
---============================================================================

local AbilityMessageHandler = require('shared/utils/messages/ability_message_handler')

---============================================================================
--- HOOK INJECTION
---============================================================================

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

    -- Show universal ability message (only for abilities, not spells/weaponskills)
    if spell and spell.action_type == 'Ability' then
        AbilityMessageHandler.show_message(spell)
    end
end

-- Export to global scope
_G.user_post_precast = user_post_precast

---============================================================================
--- INITIALIZATION MESSAGE
---============================================================================

-- Silent initialization (no spam in chat)
-- Message will appear when player uses an ability with message system active

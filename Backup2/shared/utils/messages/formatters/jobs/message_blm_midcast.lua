---============================================================================
--- BLM Midcast Message Formatter - BLM Midcast Debug (NEW SYSTEM)
---============================================================================
--- Provides formatted debug messages for the BLM Midcast system.
--- Handles all debug output for Elemental/Dark/Enfeebling Magic routing.
--- Includes BLM-specific features: MP Conservation, Elemental Matching
--- Migrated from old system to new system: 2025-11-06
---
--- @file    messages/message_blm_midcast.lua
--- @author  Tetsouo
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageBLMMidcast = {}
local M = require('shared/utils/messages/api/messages')

---============================================================================
--- ELEMENTAL MAGIC MESSAGES
---============================================================================

--- Show elemental routing header
--- @param magic_burst_mode string MagicBurstMode value (current state)
function MessageBLMMidcast.show_elemental_routing(magic_burst_mode)
    M.send('BLM_MIDCAST', 'elemental_routing')
    M.send('BLM_MIDCAST', 'elemental_magic_burst_mode', {magic_burst_mode = magic_burst_mode})
end

--- Show mode value (direct mode passed to MidcastManager)
--- @param mode_value string Mode value ('MagicBurst' or 'nil (base set)')
function MessageBLMMidcast.show_mode_value(mode_value)
    M.send('BLM_MIDCAST', 'mode_value', {mode_value = mode_value})
end

--- Show MP conservation applied
--- @param current_mp number Current MP
--- @param mp_threshold number MP threshold
function MessageBLMMidcast.show_mp_conservation(current_mp, mp_threshold)
    M.send('BLM_MIDCAST', 'mp_conservation', {
        current_mp = tostring(current_mp),
        mp_threshold = tostring(mp_threshold)
    })
end

--- Show normal MP (no conservation)
--- @param current_mp number Current MP
--- @param mp_threshold number MP threshold
function MessageBLMMidcast.show_normal_mp(current_mp, mp_threshold)
    M.send('BLM_MIDCAST', 'normal_mp', {
        current_mp = tostring(current_mp),
        mp_threshold = tostring(mp_threshold)
    })
end

--- Show elemental match detected
--- @param reason string Match reason (storm/day/weather)
function MessageBLMMidcast.show_elemental_match(reason)
    M.send('BLM_MIDCAST', 'elemental_match', {reason = reason})
end

--- Show MidcastManager return (Elemental)
function MessageBLMMidcast.show_elemental_return()
    M.send('BLM_MIDCAST', 'elemental_return')
end

---============================================================================
--- DARK MAGIC MESSAGES
---============================================================================

--- Show dark magic routing header
function MessageBLMMidcast.show_dark_routing()
    M.send('BLM_MIDCAST', 'dark_routing')
end

--- Show MidcastManager return (Dark Magic)
function MessageBLMMidcast.show_dark_return()
    M.send('BLM_MIDCAST', 'dark_return')
end

---============================================================================
--- ENFEEBLING MAGIC MESSAGES
---============================================================================

--- Show enfeebling routing header
function MessageBLMMidcast.show_enfeebling_routing()
    M.send('BLM_MIDCAST', 'enfeebling_routing')
end

--- Show MidcastManager return (Enfeebling)
function MessageBLMMidcast.show_enfeebling_return()
    M.send('BLM_MIDCAST', 'enfeebling_return')
end

---============================================================================
--- GENERAL MESSAGES
---============================================================================

--- Show skill not handled warning
--- @param spell_skill string Spell skill that was not handled
function MessageBLMMidcast.show_skill_not_handled(spell_skill)
    M.send('BLM_MIDCAST', 'skill_not_handled', {spell_skill = spell_skill})
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageBLMMidcast

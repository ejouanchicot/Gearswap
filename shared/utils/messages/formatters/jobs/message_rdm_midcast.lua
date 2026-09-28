---============================================================================
--- RDM Midcast Message Formatter - RDM Midcast Debug
---============================================================================
--- Provides formatted debug messages for the RDM Midcast system.
--- Handles all debug output for Enfeebling/Enhancing/Elemental Magic routing.
--- Separators come from the RDM_MIDCAST templates; the debug lines are sent
--- straight to MessageRenderer.send(text, CHAT_*), in the CHAT_* colors.
---
--- @file    shared/utils/messages/formatters/jobs/message_rdm_midcast.lua
--- @author  ejouanchicot
--- @version 2.0
--- @date    Created: 2025-11-06
---============================================================================

local MessageRDMMidcast = {}
local M = require('shared/utils/messages/api/messages')
local MessageRenderer = require('shared/utils/messages/core/message_renderer')

---============================================================================
--- CONSTANTS
---============================================================================

local CHAT_HEADER  = 8    -- Dark gray
local CHAT_SUCCESS = 158  -- Green
local CHAT_ERROR   = 167  -- Red
local CHAT_INFO    = 206  -- Light purple/info

---============================================================================
--- MAIN FUNCTION ENTRY MESSAGES
---============================================================================

--- Show job_post_midcast entry header
--- @param spell_name string Spell name
--- @param spell_skill string Spell skill
function MessageRDMMidcast.show_function_entry(spell_name, spell_skill)
    M.send('RDM_MIDCAST', 'separator')
    MessageRenderer.send('[RDM_MIDCAST] job_post_midcast() called', CHAT_HEADER)
    MessageRenderer.send('  Spell: ' .. spell_name, CHAT_HEADER)
    MessageRenderer.send('  Skill: ' .. spell_skill, CHAT_HEADER)
    M.send('RDM_MIDCAST', 'separator')
end

--- Show skill not handled warning
--- @param spell_skill string Spell skill that was not handled
function MessageRDMMidcast.show_skill_not_handled(spell_skill)
    MessageRenderer.send('[RDM_MIDCAST] !! Spell skill not handled by MidcastManager: ' .. spell_skill, CHAT_INFO)
end

---============================================================================
--- ENFEEBLING MAGIC MESSAGES
---============================================================================

--- Show enfeebling routing header
--- @param spell_name string Spell name
--- @param enfeeble_mode string EnfeebleMode value
--- @param database_loaded boolean Whether ENFEEBLING_MAGIC_DATABASE is loaded
function MessageRDMMidcast.show_enfeebling_routing(spell_name, enfeeble_mode, database_loaded)
    MessageRenderer.send('[RDM_MIDCAST] >> Routing to MidcastManager (Enfeebling)', CHAT_SUCCESS)
    MessageRenderer.send('[RDM_MIDCAST]   * Spell: ' .. spell_name, CHAT_SUCCESS)
    MessageRenderer.send('[RDM_MIDCAST]   * EnfeebleMode: ' .. enfeeble_mode, CHAT_SUCCESS)
    MessageRenderer.send('[RDM_MIDCAST]   * Database: ' .. (database_loaded and 'ENFEEBLING_MAGIC_DATABASE Loaded' or 'Not Loaded'), CHAT_SUCCESS)
end

--- Show enfeebling type detection
--- @param spell_name string Spell name
--- @param enfeebling_type string|nil Detected enfeebling type
function MessageRDMMidcast.show_enfeebling_type_detection(spell_name, enfeebling_type)
    MessageRenderer.send('[RDM_MIDCAST] 🔍 Enfeebling Type Detection:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   * Spell: ' .. spell_name, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   * enfeebling_type: ' .. tostring(enfeebling_type or 'nil'), CHAT_INFO)
end

--- Show enfeebling database not loaded warning
function MessageRDMMidcast.show_enfeebling_database_not_loaded()
    MessageRenderer.send('[RDM_MIDCAST] ⚠️ Database not loaded - cannot detect enfeebling_type', CHAT_ERROR)
end

--- Show expected nested set priority (with mode)
--- @param enfeebling_type string Enfeebling type
--- @param mode_value string Mode value
function MessageRDMMidcast.show_enfeebling_priority_with_mode(enfeebling_type, mode_value)
    MessageRenderer.send('[RDM_MIDCAST] 📊 Expected Nested Set Priority:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   1. sets.midcast[\'Enfeebling Magic\'].' .. enfeebling_type .. '.' .. mode_value, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   2. sets.midcast[\'Enfeebling Magic\'].' .. enfeebling_type, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   3. sets.midcast[\'Enfeebling Magic\'].' .. mode_value, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   FALLBACK: sets.midcast[\'Enfeebling Magic\']', CHAT_INFO)
end

--- Show expected nested set priority (no mode)
--- @param enfeebling_type string Enfeebling type
function MessageRDMMidcast.show_enfeebling_priority_no_mode(enfeebling_type)
    MessageRenderer.send('[RDM_MIDCAST] 📊 Expected Nested Set Priority:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   1. sets.midcast[\'Enfeebling Magic\'].' .. enfeebling_type, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   FALLBACK: sets.midcast[\'Enfeebling Magic\']', CHAT_INFO)
end

--- Show MidcastManager return result (Enfeebling)
--- @param success boolean Whether MidcastManager succeeded
function MessageRDMMidcast.show_enfeebling_result(success)
    local color = success and CHAT_SUCCESS or CHAT_ERROR
    MessageRenderer.send('[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success), color)
    if not success then
        MessageRenderer.send('[RDM_MIDCAST] WARNING: MidcastManager failed to select set - using Mote-Include default', CHAT_ERROR)
    end
end

--- Show Saboteur override message
function MessageRDMMidcast.show_saboteur_override()
    MessageRenderer.send('[RDM_MIDCAST] ** SABOTEUR ACTIVE >> Equipping sets.midcast[\'Enfeebling Magic\'].Saboteur', CHAT_INFO)
end

---============================================================================
--- ENHANCING MAGIC MESSAGES
---============================================================================

--- Show enhancing routing header
--- @param enhancing_mode string EnhancingMode value
--- @param target_name string Target name
function MessageRDMMidcast.show_enhancing_routing(enhancing_mode, target_name)
    MessageRenderer.send('[RDM_MIDCAST] >> Routing to MidcastManager (Enhancing)', CHAT_SUCCESS)
    MessageRenderer.send('[RDM_MIDCAST]   * EnhancingMode: ' .. enhancing_mode, CHAT_SUCCESS)
    MessageRenderer.send('[RDM_MIDCAST]   * Target: ' .. target_name, CHAT_SUCCESS)
end

--- Show spell family detection
--- @param spell_name string Spell name
--- @param spell_family string|nil Detected spell family
function MessageRDMMidcast.show_spell_family_detection(spell_name, spell_family)
    MessageRenderer.send('[RDM_MIDCAST] Spell Family Detection:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   * Spell: ' .. spell_name, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   * spell_family: ' .. tostring(spell_family or 'nil'), CHAT_INFO)
end

--- Show enhancing database not loaded warning
function MessageRDMMidcast.show_enhancing_database_not_loaded()
    MessageRenderer.send('[RDM_MIDCAST] WARNING: ENHANCING_MAGIC_DATABASE not loaded - cannot detect spell_family', CHAT_ERROR)
end

--- Show expected nested set priority (Enhancing - full)
--- @param spell_family string Spell family
--- @param target_value string Target value (self/others)
--- @param mode_value string Mode value
function MessageRDMMidcast.show_enhancing_priority_full(spell_family, target_value, mode_value)
    MessageRenderer.send('[RDM_MIDCAST] Expected Nested Set Priority:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   1. sets.midcast[\'Enhancing Magic\'].' .. spell_family .. '.' .. target_value .. '.' .. mode_value, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   2. sets.midcast[\'Enhancing Magic\'].' .. spell_family .. '.' .. target_value, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   3. sets.midcast[\'Enhancing Magic\'].' .. spell_family .. '.' .. mode_value, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   4. sets.midcast[\'Enhancing Magic\'].' .. spell_family, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   FALLBACK: sets.midcast[\'Enhancing Magic\']', CHAT_INFO)
end

--- Show expected nested set priority (Enhancing - target only)
--- @param spell_family string Spell family
--- @param target_value string Target value (self/others)
function MessageRDMMidcast.show_enhancing_priority_target_only(spell_family, target_value)
    MessageRenderer.send('[RDM_MIDCAST] Expected Nested Set Priority:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   1. sets.midcast[\'Enhancing Magic\'].' .. spell_family .. '.' .. target_value, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   2. sets.midcast[\'Enhancing Magic\'].' .. spell_family, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   FALLBACK: sets.midcast[\'Enhancing Magic\']', CHAT_INFO)
end

--- Show expected nested set priority (Enhancing - family only)
--- @param spell_family string Spell family
function MessageRDMMidcast.show_enhancing_priority_family_only(spell_family)
    MessageRenderer.send('[RDM_MIDCAST] Expected Nested Set Priority:', CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   1. sets.midcast[\'Enhancing Magic\'].' .. spell_family, CHAT_INFO)
    MessageRenderer.send('[RDM_MIDCAST]   FALLBACK: sets.midcast[\'Enhancing Magic\']', CHAT_INFO)
end

--- Show MidcastManager return result (Enhancing)
--- @param success boolean Whether MidcastManager succeeded
function MessageRDMMidcast.show_enhancing_result(success)
    local color = success and CHAT_SUCCESS or CHAT_ERROR
    MessageRenderer.send('[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success), color)
    if not success then
        MessageRenderer.send('[RDM_MIDCAST] WARNING: MidcastManager failed to select set - using Mote-Include default', CHAT_ERROR)
    end
end

---============================================================================
--- ELEMENTAL MAGIC MESSAGES
---============================================================================

--- Show elemental routing header
--- @param nuke_mode string NukeMode value
function MessageRDMMidcast.show_elemental_routing(nuke_mode)
    MessageRenderer.send('[RDM_MIDCAST] >> Routing to MidcastManager (Elemental)', CHAT_SUCCESS)
    MessageRenderer.send('[RDM_MIDCAST]   * NukeMode: ' .. nuke_mode, CHAT_SUCCESS)
end

--- Show MidcastManager return result (Elemental)
--- @param success boolean Whether MidcastManager succeeded
function MessageRDMMidcast.show_elemental_result(success)
    local color = success and CHAT_SUCCESS or CHAT_ERROR
    MessageRenderer.send('[RDM_MIDCAST] <- MidcastManager returned: ' .. tostring(success), color)
end

---============================================================================
--- MODULE EXPORT
---============================================================================

return MessageRDMMidcast

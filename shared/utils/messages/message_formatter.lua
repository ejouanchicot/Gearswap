---============================================================================
--- MessageFormatter - Facade for all message modules
---============================================================================
--- Single entry point for chat messages. Every show_* function is a thin
--- wrapper that requires its formatter module on first call, so a job only
--- loads the formatters it actually uses.
---
--- Some formatter functions are exposed under two names (show_bst_* and the
--- unprefixed name, *_new aliases for BRD). //gs c msgtests requires every
--- job formatter function to be exported here under its own name.
---
--- @file shared/utils/messages/message_formatter.lua
--- @author ejouanchicot
--- @version 2.0
--- @date Created: 2025-11-03
---============================================================================

local MessageFormatter = {}

-- Core module
local _MessageCore = nil
local function get_MessageCore()
    if not _MessageCore then _MessageCore = require('shared/utils/messages/message_core') end
    return _MessageCore
end

-- UI modules
local _MessageKeybinds, _MessageSystem, _MessageStatus = nil, nil, nil
local function get_MessageKeybinds()
    if not _MessageKeybinds then _MessageKeybinds = require('shared/utils/messages/formatters/ui/message_keybinds') end
    return _MessageKeybinds
end
local function get_MessageSystem()
    if not _MessageSystem then _MessageSystem = require('shared/utils/messages/formatters/system/message_system') end
    return _MessageSystem
end
local function get_MessageStatus()
    if not _MessageStatus then _MessageStatus = require('shared/utils/messages/formatters/ui/message_status') end
    return _MessageStatus
end

-- Combat modules
local _MessageCooldowns, _MessageCombat, _JABuffs = nil, nil, nil
local function get_MessageCooldowns()
    if not _MessageCooldowns then _MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns') end
    return _MessageCooldowns
end
local function get_MessageCombat()
    if not _MessageCombat then _MessageCombat = require('shared/utils/messages/formatters/combat/message_combat') end
    return _MessageCombat
end
local function get_JABuffs()
    if not _JABuffs then _JABuffs = require('shared/utils/messages/formatters/combat/message_ja_buffs') end
    return _JABuffs
end

-- Magic modules
local _MessageBuffs, _MessageDebuffs = nil, nil
local function get_MessageBuffs()
    if not _MessageBuffs then _MessageBuffs = require('shared/utils/messages/formatters/magic/message_buffs') end
    return _MessageBuffs
end
local function get_MessageDebuffs()
    if not _MessageDebuffs then _MessageDebuffs = require('shared/utils/messages/formatters/magic/message_debuffs') end
    return _MessageDebuffs
end

-- System modules
local _MessageEquipment = nil
local function get_MessageEquipment()
    if not _MessageEquipment then _MessageEquipment = require('shared/utils/messages/formatters/system/message_equipment') end
    return _MessageEquipment
end

-- Utility modules
local _RollMessages, _PartyMessages = nil, nil
local function get_RollMessages()
    if not _RollMessages then _RollMessages = require('shared/utils/messages/utilities/roll_messages') end
    return _RollMessages
end
local function get_PartyMessages()
    if not _PartyMessages then _PartyMessages = require('shared/utils/messages/utilities/party_messages') end
    return _PartyMessages
end

-- Job-specific modules (LAZY LOADED for performance)
-- These modules are only loaded when their functions are first called
local _BRDMessages, _RDMMessages, _BLMMessages, _MessageBST = nil, nil, nil, nil
local _GEOMessages, _MessageCOR = nil, nil

local function get_BRDMessages()
    if not _BRDMessages then _BRDMessages = require('shared/utils/messages/formatters/jobs/message_brd') end
    return _BRDMessages
end
local function get_RDMMessages()
    if not _RDMMessages then _RDMMessages = require('shared/utils/messages/formatters/jobs/message_rdm') end
    return _RDMMessages
end
local function get_BLMMessages()
    if not _BLMMessages then _BLMMessages = require('shared/utils/messages/formatters/jobs/message_blm') end
    return _BLMMessages
end
local function get_MessageBST()
    if not _MessageBST then _MessageBST = require('shared/utils/messages/formatters/jobs/message_bst') end
    return _MessageBST
end
local function get_GEOMessages()
    if not _GEOMessages then _GEOMessages = require('shared/utils/messages/formatters/jobs/message_geo') end
    return _GEOMessages
end
local function get_MessageCOR()
    if not _MessageCOR then _MessageCOR = require('shared/utils/messages/formatters/jobs/message_cor') end
    return _MessageCOR
end

-- Public API (lazy wrappers - loaded on first call)

-- Expose colors for external use (lazy)
MessageFormatter.COLORS = setmetatable({}, {
    __index = function(_, key) return get_MessageCore().COLORS[key] end
})

-- Core utilities (lazy wrappers)
MessageFormatter.convert_key_display = function(...) return get_MessageCore().convert_key_display(...) end
MessageFormatter.show_separator = function(...) return get_MessageCore().show_separator(...) end
MessageFormatter.get_job_tag = function(...) return get_MessageCore().get_job_tag(...) end

-- Job Ability Buffs (Global - Works for ALL jobs)
MessageFormatter.show_ja_activated = function(...) return get_JABuffs().show_activated(...) end

-- Keybind functions
MessageFormatter.show_keybind_list = function(...) return get_MessageKeybinds().show_keybind_list(...) end
MessageFormatter.format_keybind_line = function(...) return get_MessageKeybinds().format_keybind_line(...) end
MessageFormatter.show_no_binds_error = function(...) return get_MessageKeybinds().show_no_binds_error(...) end
MessageFormatter.show_bind_failed_error = function(...) return get_MessageKeybinds().show_bind_failed_error(...) end

-- System functions
MessageFormatter.show_system_intro = function(...) return get_MessageSystem().show_system_intro(...) end
MessageFormatter.show_system_intro_complete = function(...) return get_MessageSystem().show_system_intro_complete(...) end
MessageFormatter.show_color_test_header = function(...) return get_MessageSystem().show_color_test_header(...) end
MessageFormatter.show_color_test_sample = function(...) return get_MessageSystem().show_color_test_sample(...) end
MessageFormatter.show_color_test_footer = function(...) return get_MessageSystem().show_color_test_footer(...) end

-- Status functions
MessageFormatter.show_error = function(...) return get_MessageStatus().show_error(...) end
MessageFormatter.show_warning = function(...) return get_MessageStatus().show_warning(...) end
MessageFormatter.show_success = function(...) return get_MessageStatus().show_success(...) end
MessageFormatter.show_info = function(...) return get_MessageStatus().show_info(...) end
MessageFormatter.show_state_display = function(...) return get_MessageStatus().show_state_display(...) end
MessageFormatter.show_tp_ready = function(...) return get_MessageStatus().show_tp_ready(...) end

-- Cooldown functions
MessageFormatter.show_spell_cooldown = function(...) return get_MessageCooldowns().show_spell_cooldown(...) end
MessageFormatter.show_ability_cooldown = function(...) return get_MessageCooldowns().show_ability_cooldown(...) end
MessageFormatter.show_cooldown_message = function(...) return get_MessageCooldowns().show_cooldown_message(...) end
MessageFormatter.show_multi_status = function(...) return get_MessageCooldowns().show_multi_status(...) end

MessageFormatter.get_spell_recast_seconds = function(...) return get_MessageCooldowns().get_spell_recast_seconds(...) end
MessageFormatter.get_ability_recast_seconds = function(...) return get_MessageCooldowns().get_ability_recast_seconds(...) end

-- Combat functions
MessageFormatter.show_range_error = function(...) return get_MessageCombat().show_range_error(...) end
MessageFormatter.show_ws_validation_error = function(...) return get_MessageCombat().show_ws_validation_error(...) end
MessageFormatter.show_ability_tp_error = function(...) return get_MessageCombat().show_ability_tp_error(...) end
MessageFormatter.show_target_error = function(...) return get_MessageCombat().show_target_error(...) end
MessageFormatter.show_ws_tp = function(...) return get_MessageCombat().show_ws_tp(...) end
MessageFormatter.show_ws_activated = function(...) return get_MessageCombat().show_ws_activated(...) end
MessageFormatter.show_spell_activated = function(...) return get_MessageCombat().show_spell_activated(...) end
MessageFormatter.show_spell_cast = function(...) return get_MessageCombat().show_spell_cast(...) end
MessageFormatter.show_waltz_heal = function(...) return get_MessageCombat().show_waltz_heal(...) end

-- Buff functions
MessageFormatter.show_buff_status = function(...) return get_MessageBuffs().show_buff_status(...) end

-- Equipment check functions
MessageFormatter.show_check_header = function(...) return get_MessageEquipment().show_check_header(...) end
MessageFormatter.show_missing_item = function(...) return get_MessageEquipment().show_missing_item(...) end
MessageFormatter.show_storage_item = function(...) return get_MessageEquipment().show_storage_item(...) end
MessageFormatter.show_check_summary = function(...) return get_MessageEquipment().show_check_summary(...) end
MessageFormatter.show_check_error = function(...) return get_MessageEquipment().show_check_error(...) end
MessageFormatter.show_no_sets_found = function(...) return get_MessageEquipment().show_no_sets_found(...) end

-- Debuff blocking functions
MessageFormatter.show_spell_blocked = function(...) return get_MessageDebuffs().show_spell_blocked(...) end
MessageFormatter.show_ja_blocked = function(...) return get_MessageDebuffs().show_ja_blocked(...) end
MessageFormatter.show_ws_blocked = function(...) return get_MessageDebuffs().show_ws_blocked(...) end
MessageFormatter.show_item_blocked = function(...) return get_MessageDebuffs().show_item_blocked(...) end
MessageFormatter.show_action_blocked = function(...) return get_MessageDebuffs().show_action_blocked(...) end
MessageFormatter.show_silence_cure_success = function(...) return get_MessageDebuffs().show_silence_cure_success(...) end
MessageFormatter.show_no_silence_cure = function(...) return get_MessageDebuffs().show_no_silence_cure(...) end

-- Roll functions (COR)
MessageFormatter.show_roll_result = function(...) return get_RollMessages().show_roll_result(...) end
MessageFormatter.show_roll_bust = function(...) return get_RollMessages().show_roll_bust(...) end
MessageFormatter.show_roll_double_up_window = function(...) return get_RollMessages().show_roll_double_up_window(...) end
MessageFormatter.show_roll_double_up_expired = function(...) return get_RollMessages().show_roll_double_up_expired(...) end
MessageFormatter.show_no_active_roll = function(...) return get_RollMessages().show_no_active_roll(...) end
MessageFormatter.show_active_rolls = function(...) return get_RollMessages().show_active_rolls(...) end
MessageFormatter.show_rolls_cleared = function(...) return get_RollMessages().show_rolls_cleared(...) end
MessageFormatter.show_invalid_roll_value = function(...) return get_RollMessages().show_invalid_roll_value(...) end

-- Party Tracking (Universal - usable by any job)
MessageFormatter.show_party_members = function(...) return get_PartyMessages().show_party_members(...) end

MessageFormatter.show_marcato_used = function(...) return get_BRDMessages().show_marcato_used(...) end
MessageFormatter.show_pianissimo_used = function(...) return get_BRDMessages().show_pianissimo_used(...) end
MessageFormatter.show_pianissimo_target = function(...) return get_BRDMessages().show_pianissimo_target(...) end
MessageFormatter.show_ability_command = function(...) return get_BRDMessages().show_ability_command(...) end
MessageFormatter.show_instrument_locked = function(...) return get_BRDMessages().show_instrument_locked(...) end
MessageFormatter.show_instrument_released = function(...) return get_BRDMessages().show_instrument_released(...) end
MessageFormatter.show_daurdabla_dummy = function(...) return get_BRDMessages().show_daurdabla_dummy(...) end
MessageFormatter.show_songs_casting = function(...) return get_BRDMessages().show_songs_casting(...) end
MessageFormatter.show_song_pack = function(...) return get_BRDMessages().show_song_pack(...) end
MessageFormatter.show_dummy_casting = function(...) return get_BRDMessages().show_dummy_casting(...) end
MessageFormatter.show_lullaby_cast = function(...) return get_BRDMessages().show_lullaby_cast(...) end
MessageFormatter.show_elegy_cast = function(...) return get_BRDMessages().show_elegy_cast(...) end
MessageFormatter.show_requiem_cast = function(...) return get_BRDMessages().show_requiem_cast(...) end
MessageFormatter.show_threnody_cast = function(...) return get_BRDMessages().show_threnody_cast(...) end
MessageFormatter.show_carol_cast = function(...) return get_BRDMessages().show_carol_cast(...) end
MessageFormatter.show_etude_cast = function(...) return get_BRDMessages().show_etude_cast(...) end
MessageFormatter.show_song_refinement = function(...) return get_BRDMessages().show_song_refinement(...) end
MessageFormatter.show_song_refinement_failed = function(...) return get_BRDMessages().show_song_refinement_failed(...) end
MessageFormatter.show_no_element_selected = function(...) return get_BRDMessages().show_no_element_selected(...) end
MessageFormatter.show_no_carol_element = function(...) return get_BRDMessages().show_no_carol_element(...) end
MessageFormatter.show_no_etude_type = function(...) return get_BRDMessages().show_no_etude_type(...) end
MessageFormatter.show_no_song_in_slot = function(...) return get_BRDMessages().show_no_song_in_slot(...) end
MessageFormatter.show_pack_not_found = function(...) return get_BRDMessages().show_pack_not_found(...) end

MessageFormatter.show_element_list = function(...) return get_RDMMessages().show_element_list(...) end
MessageFormatter.show_storm_current = function(...) return get_RDMMessages().show_storm_current(...) end
MessageFormatter.show_no_enspell_selected = function(...) return get_RDMMessages().show_no_enspell_selected(...) end
MessageFormatter.show_gain_spell_not_configured = function(...) return get_RDMMessages().show_gain_spell_not_configured(...) end
MessageFormatter.show_bar_element_not_configured = function(...) return get_RDMMessages().show_bar_element_not_configured(...) end
MessageFormatter.show_bar_ailment_not_configured = function(...) return get_RDMMessages().show_bar_ailment_not_configured(...) end
MessageFormatter.show_spike_not_configured = function(...) return get_RDMMessages().show_spike_not_configured(...) end
MessageFormatter.show_storm_requires_sch = function(...) return get_RDMMessages().show_storm_requires_sch(...) end
MessageFormatter.show_phalanx_downgrade = function(...) return get_RDMMessages().show_phalanx_downgrade(...) end
MessageFormatter.show_phalanx_upgrade = function(...) return get_RDMMessages().show_phalanx_upgrade(...) end

-- GEO functions (Geomancer) - LAZY LOADED
MessageFormatter.show_indi_cast = function(...) return get_GEOMessages().show_indi_cast(...) end
MessageFormatter.show_geo_cast = function(...) return get_GEOMessages().show_geo_cast(...) end
MessageFormatter.show_spell_refined = function(...) return get_GEOMessages().show_spell_refined(...) end
MessageFormatter.show_no_tier_available = function(...) return get_GEOMessages().show_no_tier_available(...) end

-- BLM functions (Black Mage) - LAZY LOADED
MessageFormatter.show_element_cycle = function(...) return get_BLMMessages().show_element_cycle(...) end
MessageFormatter.show_storm_cycle = function(...) return get_BLMMessages().show_storm_cycle(...) end
MessageFormatter.show_spell_refinement = function(...) return get_BLMMessages().show_spell_refinement(...) end
MessageFormatter.show_mp_conservation = function(...) return get_BLMMessages().show_mp_conservation(...) end
MessageFormatter.show_arts_already_active = function(...) return get_BLMMessages().show_arts_already_active(...) end
MessageFormatter.show_stratagem_no_charges = function(...) return get_BLMMessages().show_stratagem_no_charges(...) end
MessageFormatter.show_spell_replacement_error = function(...) return get_BLMMessages().show_spell_replacement_error(...) end
MessageFormatter.show_spell_refinement_error = function(...) return get_BLMMessages().show_spell_refinement_error(...) end
MessageFormatter.show_spell_recasts_error = function(...) return get_BLMMessages().show_spell_recasts_error(...) end
MessageFormatter.show_breakga_blocked = function(...) return get_BLMMessages().show_breakga_blocked(...) end

-- BST functions (Beastmaster) - LAZY LOADED
-- Legacy names with show_bst_ prefix (backward compatibility)

-- Ecosystem Messages
MessageFormatter.show_bst_ecosystem_change = function(...) return get_MessageBST().show_ecosystem_change(...) end
MessageFormatter.show_bst_species_change = function(...) return get_MessageBST().show_species_change(...) end

-- Broth/Jug Messages
MessageFormatter.show_bst_broth_equip = function(...) return get_MessageBST().show_broth_equip(...) end
MessageFormatter.show_bst_broth_list = function(...) return get_MessageBST().show_broth_list(...) end
MessageFormatter.show_bst_ready_moves_list = function(...) return get_MessageBST().show_ready_moves_list(...) end

MessageFormatter.show_bst_pet_engage = function(...) return get_MessageBST().show_pet_engage(...) end
MessageFormatter.show_bst_pet_disengage = function(...) return get_MessageBST().show_pet_disengage(...) end

MessageFormatter.show_bst_ready_move_use = function(...) return get_MessageBST().show_ready_move_use(...) end
MessageFormatter.show_bst_ready_move_auto_engage = function(...) return get_MessageBST().show_ready_move_auto_engage(...) end
MessageFormatter.show_bst_ready_move_auto_sequence = function(...) return get_MessageBST().show_ready_move_auto_sequence(...) end

-- Error Messages
MessageFormatter.show_error_no_pet = function(...) return get_MessageBST().show_error_no_pet(...) end
MessageFormatter.show_error_no_ready_moves = function(...) return get_MessageBST().show_error_no_ready_moves(...) end
MessageFormatter.show_error_invalid_index = function(...) return get_MessageBST().show_error_invalid_index(...) end
MessageFormatter.show_error_index_out_of_range = function(...) return get_MessageBST().show_error_index_out_of_range(...) end
MessageFormatter.show_error_module_not_loaded = function(...) return get_MessageBST().show_error_module_not_loaded(...) end

MessageFormatter.show_ecosystem_change = function(...) return get_MessageBST().show_ecosystem_change(...) end
MessageFormatter.show_species_change = function(...) return get_MessageBST().show_species_change(...) end
MessageFormatter.show_broth_equip = function(...) return get_MessageBST().show_broth_equip(...) end
MessageFormatter.show_pet_engage = function(...) return get_MessageBST().show_pet_engage(...) end
MessageFormatter.show_pet_disengage = function(...) return get_MessageBST().show_pet_disengage(...) end
MessageFormatter.show_ready_move_use = function(...) return get_MessageBST().show_ready_move_use(...) end
MessageFormatter.show_ready_move_auto_engage = function(...) return get_MessageBST().show_ready_move_auto_engage(...) end
MessageFormatter.show_ready_move_auto_sequence = function(...) return get_MessageBST().show_ready_move_auto_sequence(...) end

-- COR functions (Corsair) - LAZY LOADED
MessageFormatter.show_rolltracker_load_failed = function(...) return get_MessageCOR().show_rolltracker_load_failed(...) end
MessageFormatter.show_packets_load_failed = function(...) return get_MessageCOR().show_packets_load_failed(...) end
MessageFormatter.show_resources_load_failed = function(...) return get_MessageCOR().show_resources_load_failed(...) end

--- Print a gray debug line tagged with a prefix.
--- @param prefix string Tag shown in brackets (e.g. 'PERF', job code)
--- @param message string Debug text
function MessageFormatter.show_debug(prefix, message)
    local MessageRenderer = require('shared/utils/messages/core/message_renderer')
    local formatted = string.format('[%s] %s', prefix, message)
    MessageRenderer.send(formatted, 8)  -- Color 8 = gray debug
end

return MessageFormatter

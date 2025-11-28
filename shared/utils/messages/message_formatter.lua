---============================================================================
--- Message Formatter - Main facade for all message modules
---============================================================================
--- Centralized interface that loads and exposes all message formatting modules.
--- This maintains the same API while providing modular architecture underneath.
---
--- @file utils/message_formatter.lua
--- @author Tetsouo
--- @version 3.0
--- @date Created: 2025-09-29
---============================================================================

local MessageFormatter = {}

---============================================================================
--- LAZY-LOADED MODULES (Performance Optimization)
--- Modules only loaded when their functions are first called
---============================================================================

-- Core module (loaded on first use)
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
local _MessageBuffs, _MessageDebuffs, _SongMessages = nil, nil, nil
local function get_MessageBuffs()
    if not _MessageBuffs then _MessageBuffs = require('shared/utils/messages/formatters/magic/message_buffs') end
    return _MessageBuffs
end
local function get_MessageDebuffs()
    if not _MessageDebuffs then _MessageDebuffs = require('shared/utils/messages/formatters/magic/message_debuffs') end
    return _MessageDebuffs
end
local function get_SongMessages()
    if not _SongMessages then _SongMessages = require('shared/utils/messages/formatters/magic/message_songs') end
    return _SongMessages
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
local _GEOMessages, _MessageCOR, _MessageDRG, _MessageWHM = nil, nil, nil, nil

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
local function get_MessageDRG()
    if not _MessageDRG then _MessageDRG = require('shared/utils/messages/formatters/jobs/message_drg') end
    return _MessageDRG
end
local function get_MessageWHM()
    if not _MessageWHM then _MessageWHM = require('shared/utils/messages/formatters/jobs/message_whm') end
    return _MessageWHM
end

---============================================================================
--- PUBLIC API - Maintains backward compatibility (LAZY-LOADED)
---============================================================================

-- Expose colors for external use (lazy)
MessageFormatter.COLORS = setmetatable({}, {
    __index = function(_, key) return get_MessageCore().COLORS[key] end
})

-- Core utilities (lazy wrappers)
MessageFormatter.convert_key_display = function(...) return get_MessageCore().convert_key_display(...) end
MessageFormatter.show_separator = function(...) return get_MessageCore().show_separator(...) end
MessageFormatter.get_job_tag = function(...) return get_MessageCore().get_job_tag(...) end

---============================================================================
--- NEW GLOBAL FUNCTIONS - Universal Job Ability Messages (LAZY-LOADED)
---============================================================================
-- These functions work for ALL jobs (replaces job-specific implementations)

-- Job Ability Buffs (Global - Works for ALL jobs)
MessageFormatter.show_ja_activated = function(...) return get_JABuffs().show_activated(...) end
MessageFormatter.show_ja_active = function(...) return get_JABuffs().show_active(...) end
MessageFormatter.show_ja_ended = function(...) return get_JABuffs().show_ended(...) end
MessageFormatter.show_ja_with_description = function(...) return get_JABuffs().show_with_description(...) end
MessageFormatter.show_ja_using = function(...) return get_JABuffs().show_using(...) end
MessageFormatter.show_ja_using_double = function(...) return get_JABuffs().show_using_double(...) end

-- Song Messages (BRD-specific but organized by TYPE not JOB)
MessageFormatter.show_song_rotation = function(...) return get_SongMessages().show_songs_casting(...) end
MessageFormatter.show_song_pack_select = function(...) return get_SongMessages().show_song_pack(...) end
MessageFormatter.show_song_honor_march_locked = function(...) return get_SongMessages().show_honor_march_locked(...) end
MessageFormatter.show_song_honor_march_released = function(...) return get_SongMessages().show_honor_march_released(...) end
MessageFormatter.show_song_daurdabla_dummy = function(...) return get_SongMessages().show_daurdabla_dummy(...) end
MessageFormatter.show_song_pianissimo_used = function(...) return get_SongMessages().show_pianissimo_used(...) end
MessageFormatter.show_song_pianissimo_target = function(...) return get_SongMessages().show_pianissimo_target(...) end
MessageFormatter.show_song_marcato_honor_march = function(...) return get_SongMessages().show_marcato_honor_march(...) end
MessageFormatter.show_song_marcato_skip_buffs = function(...) return get_SongMessages().show_marcato_skip_buffs(...) end
MessageFormatter.show_song_marcato_skip_soul_voice = function(...) return get_SongMessages().show_marcato_skip_soul_voice(...) end

-- Dance Messages removed - DNC now uses global JABuffs system (show_ja_activated)

---============================================================================
--- BACKWARD COMPATIBILITY WRAPPERS (LAZY-LOADED)
---============================================================================
-- Maintain old BRD function names but use new global system
MessageFormatter.show_soul_voice_activated_new = function(...) return get_JABuffs().show_soul_voice_activated(...) end
MessageFormatter.show_nightingale_activated_new = function(...) return get_JABuffs().show_nightingale_activated(...) end
MessageFormatter.show_troubadour_activated_new = function(...) return get_JABuffs().show_troubadour_activated(...) end
MessageFormatter.show_marcato_used_new = function(...) return get_JABuffs().show_marcato_used(...) end

-- Keybind functions
MessageFormatter.show_keybind_list = function(...) return get_MessageKeybinds().show_keybind_list(...) end
MessageFormatter.format_keybind_line = function(...) return get_MessageKeybinds().format_keybind_line(...) end
MessageFormatter.show_no_binds_error = function(...) return get_MessageKeybinds().show_no_binds_error(...) end
MessageFormatter.show_invalid_bind_error = function(...) return get_MessageKeybinds().show_invalid_bind_error(...) end
MessageFormatter.show_bind_failed_error = function(...) return get_MessageKeybinds().show_bind_failed_error(...) end

-- System functions
MessageFormatter.show_system_intro = function(...) return get_MessageSystem().show_system_intro(...) end
MessageFormatter.show_system_intro_with_macros = function(...) return get_MessageSystem().show_system_intro_with_macros(...) end
MessageFormatter.show_system_intro_complete = function(...) return get_MessageSystem().show_system_intro_complete(...) end
MessageFormatter.show_color_test_header = function(...) return get_MessageSystem().show_color_test_header(...) end
MessageFormatter.show_color_test_sample = function(...) return get_MessageSystem().show_color_test_sample(...) end
MessageFormatter.show_color_test_footer = function(...) return get_MessageSystem().show_color_test_footer(...) end

-- Status functions
MessageFormatter.show_error = function(...) return get_MessageStatus().show_error(...) end
MessageFormatter.show_warning = function(...) return get_MessageStatus().show_warning(...) end
MessageFormatter.show_success = function(...) return get_MessageStatus().show_success(...) end
MessageFormatter.show_info = function(...) return get_MessageStatus().show_info(...) end
MessageFormatter.show_tp_ready = function(...) return get_MessageStatus().show_tp_ready(...) end
MessageFormatter.show_tp_required = function(...) return get_MessageStatus().show_tp_required(...) end

-- Cooldown functions (professional system ready)
MessageFormatter.show_spell_cooldown = function(...) return get_MessageCooldowns().show_spell_cooldown(...) end
MessageFormatter.show_ability_cooldown = function(...) return get_MessageCooldowns().show_ability_cooldown(...) end
MessageFormatter.show_ws_cooldown = function(...) return get_MessageCooldowns().show_ws_cooldown(...) end
MessageFormatter.show_item_recast = function(...) return get_MessageCooldowns().show_item_recast(...) end
MessageFormatter.show_stratagem_cooldown = function(...) return get_MessageCooldowns().show_stratagem_cooldown(...) end
MessageFormatter.show_song_duration = function(...) return get_MessageCooldowns().show_song_duration(...) end
MessageFormatter.show_compact_status = function(...) return get_MessageCooldowns().show_compact_status(...) end
MessageFormatter.show_cooldown_message = function(...) return get_MessageCooldowns().show_cooldown_message(...) end
MessageFormatter.show_multi_status = function(...) return get_MessageCooldowns().show_multi_status(...) end

-- Convenience functions with automatic windower API handling
MessageFormatter.show_spell_cooldown_by_id = function(...) return get_MessageCooldowns().show_spell_cooldown_by_id(...) end
MessageFormatter.show_ability_cooldown_by_id = function(...) return get_MessageCooldowns().show_ability_cooldown_by_id(...) end
MessageFormatter.get_spell_recast_seconds = function(...) return get_MessageCooldowns().get_spell_recast_seconds(...) end
MessageFormatter.get_ability_recast_seconds = function(...) return get_MessageCooldowns().get_ability_recast_seconds(...) end

-- Combat functions
MessageFormatter.show_range_error = function(...) return get_MessageCombat().show_range_error(...) end
MessageFormatter.show_ws_validation_error = function(...) return get_MessageCombat().show_ws_validation_error(...) end
MessageFormatter.show_ability_tp_error = function(...) return get_MessageCombat().show_ability_tp_error(...) end
MessageFormatter.show_target_error = function(...) return get_MessageCombat().show_target_error(...) end
MessageFormatter.show_state_change = function(...) return get_MessageCombat().show_state_change(...) end
MessageFormatter.show_ws_tp = function(...) return get_MessageCombat().show_ws_tp(...) end
MessageFormatter.show_ws_activated = function(...) return get_MessageCombat().show_ws_activated(...) end
MessageFormatter.show_spell_activated = function(...) return get_MessageCombat().show_spell_activated(...) end
MessageFormatter.show_spell_cast = function(...) return get_MessageCombat().show_spell_cast(...) end
MessageFormatter.show_ability_use = function(...) return get_MessageCombat().show_ability_use(...) end
MessageFormatter.show_waltz_heal = function(...) return get_MessageCombat().show_waltz_heal(...) end
MessageFormatter.show_jump_activated = function(...) return get_MessageCombat().show_jump_activated(...) end
MessageFormatter.show_jump_chaining = function(...) return get_MessageCombat().show_jump_chaining(...) end
MessageFormatter.show_jump_complete = function(...) return get_MessageCombat().show_jump_complete(...) end
MessageFormatter.show_jump_relaunch = function(...) return get_MessageCombat().show_jump_relaunch(...) end

-- Buff functions
MessageFormatter.show_buff_status = function(...) return get_MessageBuffs().show_buff_status(...) end

-- Equipment check functions
MessageFormatter.show_check_header = function(...) return get_MessageEquipment().show_check_header(...) end
MessageFormatter.show_set_valid = function(...) return get_MessageEquipment().show_set_valid(...) end
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
MessageFormatter.show_incapacitated = function(...) return get_MessageDebuffs().show_incapacitated(...) end
MessageFormatter.show_silence_cure_success = function(...) return get_MessageDebuffs().show_silence_cure_success(...) end
MessageFormatter.show_no_silence_cure = function(...) return get_MessageDebuffs().show_no_silence_cure(...) end

-- Roll functions (COR)
MessageFormatter.show_roll_result = function(...) return get_RollMessages().show_roll_result(...) end
MessageFormatter.show_roll_natural_eleven = function(...) return get_RollMessages().show_roll_natural_eleven(...) end
MessageFormatter.show_roll_bust_rate = function(...) return get_RollMessages().show_roll_bust_rate(...) end
MessageFormatter.show_roll_bust = function(...) return get_RollMessages().show_roll_bust(...) end
MessageFormatter.show_roll_double_up_window = function(...) return get_RollMessages().show_roll_double_up_window(...) end
MessageFormatter.show_roll_double_up_expired = function(...) return get_RollMessages().show_roll_double_up_expired(...) end
MessageFormatter.show_no_active_roll = function(...) return get_RollMessages().show_no_active_roll(...) end
MessageFormatter.show_active_rolls = function(...) return get_RollMessages().show_active_rolls(...) end
MessageFormatter.show_rolls_cleared = function(...) return get_RollMessages().show_rolls_cleared(...) end
MessageFormatter.show_roll_not_found = function(...) return get_RollMessages().show_roll_not_found(...) end
MessageFormatter.show_invalid_roll_value = function(...) return get_RollMessages().show_invalid_roll_value(...) end

-- Party Tracking (Universal - usable by any job)
MessageFormatter.show_party_members = function(...) return get_PartyMessages().show_party_members(...) end

-- BRD functions (Bard) - LAZY LOADED
MessageFormatter.show_soul_voice_activated = function(...) return get_BRDMessages().show_soul_voice_activated(...) end
MessageFormatter.show_soul_voice_ended = function(...) return get_BRDMessages().show_soul_voice_ended(...) end
MessageFormatter.show_nightingale_activated = function(...) return get_BRDMessages().show_nightingale_activated(...) end
MessageFormatter.show_nightingale_active = function(...) return get_BRDMessages().show_nightingale_active(...) end
MessageFormatter.show_troubadour_activated = function(...) return get_BRDMessages().show_troubadour_activated(...) end
MessageFormatter.show_troubadour_active = function(...) return get_BRDMessages().show_troubadour_active(...) end
MessageFormatter.show_marcato_used = function(...) return get_BRDMessages().show_marcato_used(...) end
MessageFormatter.show_marcato_honor_march = function(...) return get_BRDMessages().show_marcato_honor_march(...) end
MessageFormatter.show_marcato_skip_buffs = function(...) return get_BRDMessages().show_marcato_skip_buffs(...) end
MessageFormatter.show_marcato_skip_soul_voice = function(...) return get_BRDMessages().show_marcato_skip_soul_voice(...) end
MessageFormatter.show_pianissimo_used = function(...) return get_BRDMessages().show_pianissimo_used(...) end
MessageFormatter.show_pianissimo_target = function(...) return get_BRDMessages().show_pianissimo_target(...) end
MessageFormatter.show_ability_command = function(...) return get_BRDMessages().show_ability_command(...) end
MessageFormatter.show_instrument_locked = function(...) return get_BRDMessages().show_instrument_locked(...) end
MessageFormatter.show_instrument_released = function(...) return get_BRDMessages().show_instrument_released(...) end
MessageFormatter.show_honor_march_locked = function(...) return get_BRDMessages().show_honor_march_locked(...) end
MessageFormatter.show_honor_march_released = function(...) return get_BRDMessages().show_honor_march_released(...) end
MessageFormatter.show_daurdabla_dummy = function(...) return get_BRDMessages().show_daurdabla_dummy(...) end
MessageFormatter.show_songs_casting = function(...) return get_BRDMessages().show_songs_casting(...) end
MessageFormatter.show_song_pack = function(...) return get_BRDMessages().show_song_pack(...) end
MessageFormatter.show_songs_refresh = function(...) return get_BRDMessages().show_songs_refresh(...) end
MessageFormatter.show_dummy_casting = function(...) return get_BRDMessages().show_dummy_casting(...) end
MessageFormatter.show_dummy_cast = function(...) return get_BRDMessages().show_dummy_cast(...) end
MessageFormatter.show_tank_casting = function(...) return get_BRDMessages().show_tank_casting(...) end
MessageFormatter.show_tank_refresh = function(...) return get_BRDMessages().show_tank_refresh(...) end
MessageFormatter.show_healer_casting = function(...) return get_BRDMessages().show_healer_casting(...) end
MessageFormatter.show_healer_refresh = function(...) return get_BRDMessages().show_healer_refresh(...) end
MessageFormatter.show_song_cast = function(...) return get_BRDMessages().show_song_cast(...) end
MessageFormatter.show_song_guidance = function(...) return get_BRDMessages().show_song_guidance(...) end
MessageFormatter.show_clarion_required = function(...) return get_BRDMessages().show_clarion_required(...) end
MessageFormatter.show_lullaby_cast = function(...) return get_BRDMessages().show_lullaby_cast(...) end
MessageFormatter.show_elegy_cast = function(...) return get_BRDMessages().show_elegy_cast(...) end
MessageFormatter.show_requiem_cast = function(...) return get_BRDMessages().show_requiem_cast(...) end
MessageFormatter.show_threnody_cast = function(...) return get_BRDMessages().show_threnody_cast(...) end
MessageFormatter.show_carol_cast = function(...) return get_BRDMessages().show_carol_cast(...) end
MessageFormatter.show_etude_cast = function(...) return get_BRDMessages().show_etude_cast(...) end
MessageFormatter.show_song_refinement = function(...) return get_BRDMessages().show_song_refinement(...) end
MessageFormatter.show_song_refinement_failed = function(...) return get_BRDMessages().show_song_refinement_failed(...) end
MessageFormatter.show_doom_gained = function(...) return get_BRDMessages().show_doom_gained(...) end
MessageFormatter.show_doom_removed = function(...) return get_BRDMessages().show_doom_removed(...) end
MessageFormatter.show_no_pack_configured = function(...) return get_BRDMessages().show_no_pack_configured(...) end
MessageFormatter.show_tank_not_configured = function(...) return get_BRDMessages().show_tank_not_configured(...) end
MessageFormatter.show_healer_not_configured = function(...) return get_BRDMessages().show_healer_not_configured(...) end
MessageFormatter.show_no_element_selected = function(...) return get_BRDMessages().show_no_element_selected(...) end
MessageFormatter.show_no_carol_element = function(...) return get_BRDMessages().show_no_carol_element(...) end
MessageFormatter.show_no_etude_type = function(...) return get_BRDMessages().show_no_etude_type(...) end
MessageFormatter.show_no_song_in_slot = function(...) return get_BRDMessages().show_no_song_in_slot(...) end
MessageFormatter.show_pack_not_found = function(...) return get_BRDMessages().show_pack_not_found(...) end

-- RDM functions (Red Mage) - LAZY LOADED
MessageFormatter.show_convert_activated = function(...) return get_RDMMessages().show_convert_activated(...) end
MessageFormatter.show_convert_used = function(...) return get_RDMMessages().show_convert_used(...) end
MessageFormatter.show_chainspell_activated = function(...) return get_RDMMessages().show_chainspell_activated(...) end
MessageFormatter.show_chainspell_ended = function(...) return get_RDMMessages().show_chainspell_ended(...) end
MessageFormatter.show_composure_activated = function(...) return get_RDMMessages().show_composure_activated(...) end
MessageFormatter.show_composure_active = function(...) return get_RDMMessages().show_composure_active(...) end
MessageFormatter.show_doom_warning = function(...) return get_RDMMessages().show_doom_warning(...) end
MessageFormatter.show_rdm_doom_removed = function(...) return get_RDMMessages().show_doom_removed(...) end
MessageFormatter.show_spell_casting = function(...) return get_RDMMessages().show_spell_casting(...) end
MessageFormatter.show_element_list = function(...) return get_RDMMessages().show_element_list(...) end
MessageFormatter.show_enspell_current = function(...) return get_RDMMessages().show_enspell_current(...) end
MessageFormatter.show_storm_current = function(...) return get_RDMMessages().show_storm_current(...) end
MessageFormatter.show_no_enspell_selected = function(...) return get_RDMMessages().show_no_enspell_selected(...) end
MessageFormatter.show_gain_spell_not_configured = function(...) return get_RDMMessages().show_gain_spell_not_configured(...) end
MessageFormatter.show_bar_element_not_configured = function(...) return get_RDMMessages().show_bar_element_not_configured(...) end
MessageFormatter.show_bar_ailment_not_configured = function(...) return get_RDMMessages().show_bar_ailment_not_configured(...) end
MessageFormatter.show_spike_not_configured = function(...) return get_RDMMessages().show_spike_not_configured(...) end
MessageFormatter.show_storm_requires_sch = function(...) return get_RDMMessages().show_storm_requires_sch(...) end
MessageFormatter.show_phalanx_detected = function(...) return get_RDMMessages().show_phalanx_detected(...) end
MessageFormatter.show_phalanx_downgrade = function(...) return get_RDMMessages().show_phalanx_downgrade(...) end
MessageFormatter.show_phalanx_upgrade = function(...) return get_RDMMessages().show_phalanx_upgrade(...) end

-- GEO functions (Geomancer) - LAZY LOADED
MessageFormatter.show_indi_cast = function(...) return get_GEOMessages().show_indi_cast(...) end
MessageFormatter.show_geo_cast = function(...) return get_GEOMessages().show_geo_cast(...) end
MessageFormatter.show_spell_refined = function(...) return get_GEOMessages().show_spell_refined(...) end
MessageFormatter.show_no_tier_available = function(...) return get_GEOMessages().show_no_tier_available(...) end

-- BLM functions (Black Mage) - LAZY LOADED
MessageFormatter.show_dark_arts_activated = function(...) return get_BLMMessages().show_dark_arts_activated(...) end
MessageFormatter.show_element_cycle = function(...) return get_BLMMessages().show_element_cycle(...) end
MessageFormatter.show_aja_cycle = function(...) return get_BLMMessages().show_aja_cycle(...) end
MessageFormatter.show_storm_cycle = function(...) return get_BLMMessages().show_storm_cycle(...) end
MessageFormatter.show_tier_cycle = function(...) return get_BLMMessages().show_tier_cycle(...) end
MessageFormatter.show_buff_activated = function(...) return get_BLMMessages().show_buff_activated(...) end
MessageFormatter.show_buff_cast = function(...) return get_BLMMessages().show_buff_cast(...) end
MessageFormatter.show_magic_burst_on = function(...) return get_BLMMessages().show_magic_burst_on(...) end
MessageFormatter.show_magic_burst_off = function(...) return get_BLMMessages().show_magic_burst_off(...) end
MessageFormatter.show_free_nuke_on = function(...) return get_BLMMessages().show_free_nuke_on(...) end
MessageFormatter.show_spell_refinement = function(...) return get_BLMMessages().show_spell_refinement(...) end
MessageFormatter.show_spell_refinement_failed = function(...) return get_BLMMessages().show_spell_refinement_failed(...) end
MessageFormatter.show_mp_conservation = function(...) return get_BLMMessages().show_mp_conservation(...) end
MessageFormatter.show_arts_already_active = function(...) return get_BLMMessages().show_arts_already_active(...) end
MessageFormatter.show_stratagem_no_charges = function(...) return get_BLMMessages().show_stratagem_no_charges(...) end
MessageFormatter.show_buffself_error = function(...) return get_BLMMessages().show_buffself_error(...) end
MessageFormatter.show_spell_replacement_error = function(...) return get_BLMMessages().show_spell_replacement_error(...) end
MessageFormatter.show_spell_refinement_error = function(...) return get_BLMMessages().show_spell_refinement_error(...) end
MessageFormatter.show_spell_recasts_error = function(...) return get_BLMMessages().show_spell_recasts_error(...) end
MessageFormatter.show_insufficient_mp_error = function(...) return get_BLMMessages().show_insufficient_mp_error(...) end
MessageFormatter.show_breakga_blocked = function(...) return get_BLMMessages().show_breakga_blocked(...) end
MessageFormatter.show_buffself_recasts_error = function(...) return get_BLMMessages().show_buffself_recasts_error(...) end
MessageFormatter.show_buffself_resources_error = function(...) return get_BLMMessages().show_buffself_resources_error(...) end
MessageFormatter.show_buff_casting = function(...) return get_BLMMessages().show_buff_casting(...) end
MessageFormatter.show_unknown_buff_error = function(...) return get_BLMMessages().show_unknown_buff_error(...) end
MessageFormatter.show_buff_already_active = function(...) return get_BLMMessages().show_buff_already_active(...) end
MessageFormatter.show_manual_buff_cast = function(...) return get_BLMMessages().show_manual_buff_cast(...) end

-- BST functions (Beastmaster) - LAZY LOADED
-- Legacy names with show_bst_ prefix (backward compatibility)

-- Job Ability Messages
MessageFormatter.show_bst_call_beast_used = function(...) return get_MessageBST().show_call_beast_used(...) end
MessageFormatter.show_bst_bestial_loyalty_used = function(...) return get_MessageBST().show_bestial_loyalty_used(...) end
MessageFormatter.show_bst_familiar_activated = function(...) return get_MessageBST().show_familiar_activated(...) end
MessageFormatter.show_bst_familiar_active = function(...) return get_MessageBST().show_familiar_active(...) end
MessageFormatter.show_bst_spur_used = function(...) return get_MessageBST().show_spur_used(...) end
MessageFormatter.show_bst_run_wild_used = function(...) return get_MessageBST().show_run_wild_used(...) end
MessageFormatter.show_bst_tame_used = function(...) return get_MessageBST().show_tame_used(...) end
MessageFormatter.show_bst_reward_used = function(...) return get_MessageBST().show_reward_used(...) end
MessageFormatter.show_bst_reward_no_food = function(...) return get_MessageBST().show_reward_no_food(...) end
MessageFormatter.show_bst_feral_howl_used = function(...) return get_MessageBST().show_feral_howl_used(...) end
MessageFormatter.show_bst_killer_instinct_activated = function(...) return get_MessageBST().show_killer_instinct_activated(...) end

-- Ecosystem Messages
MessageFormatter.show_bst_ecosystem_change = function(...) return get_MessageBST().show_ecosystem_change(...) end
MessageFormatter.show_bst_species_change = function(...) return get_MessageBST().show_species_change(...) end

-- Broth/Jug Messages
MessageFormatter.show_bst_broth_equip = function(...) return get_MessageBST().show_broth_equip(...) end
MessageFormatter.show_bst_jug_equipped = function(...) return get_MessageBST().show_jug_equipped(...) end
MessageFormatter.show_bst_broth_count_header = function(...) return get_MessageBST().show_broth_count_header(...) end
MessageFormatter.show_bst_broth_count_line = function(...) return get_MessageBST().show_broth_count_line(...) end
MessageFormatter.show_bst_broth_count_footer = function(...) return get_MessageBST().show_broth_count_footer(...) end
MessageFormatter.show_bst_no_broths = function(...) return get_MessageBST().show_no_broths(...) end

-- Pet Management Messages
MessageFormatter.show_bst_pet_summoned = function(...) return get_MessageBST().show_pet_summoned(...) end
MessageFormatter.show_bst_pet_engage = function(...) return get_MessageBST().show_pet_engage(...) end
MessageFormatter.show_bst_pet_disengage = function(...) return get_MessageBST().show_pet_disengage(...) end
MessageFormatter.show_bst_pet_dismissed = function(...) return get_MessageBST().show_pet_dismissed(...) end
MessageFormatter.show_bst_auto_engage_enabled = function(...) return get_MessageBST().show_auto_engage_enabled(...) end
MessageFormatter.show_bst_auto_engage_disabled = function(...) return get_MessageBST().show_auto_engage_disabled(...) end
MessageFormatter.show_bst_auto_engage_status = function(...) return get_MessageBST().show_auto_engage_status(...) end
MessageFormatter.show_bst_pet_tp_status = function(...) return get_MessageBST().show_pet_tp_status(...) end
MessageFormatter.show_bst_pet_hp_status = function(...) return get_MessageBST().show_pet_hp_status(...) end

-- Ready Move Messages
MessageFormatter.show_bst_ready_move_precast = function(...) return get_MessageBST().show_ready_move_precast(...) end
MessageFormatter.show_bst_ready_move_physical = function(...) return get_MessageBST().show_ready_move_physical(...) end
MessageFormatter.show_bst_ready_move_magical = function(...) return get_MessageBST().show_ready_move_magical(...) end
MessageFormatter.show_bst_ready_move_breath = function(...) return get_MessageBST().show_ready_move_breath(...) end
MessageFormatter.show_bst_ready_move_tp_check = function(...) return get_MessageBST().show_ready_move_tp_check(...) end
MessageFormatter.show_bst_ready_moves_header = function(...) return get_MessageBST().show_ready_moves_header(...) end
MessageFormatter.show_bst_ready_move_item = function(...) return get_MessageBST().show_ready_move_item(...) end
MessageFormatter.show_bst_ready_moves_usage = function(...) return get_MessageBST().show_ready_moves_usage(...) end
MessageFormatter.show_bst_ready_move_use = function(...) return get_MessageBST().show_ready_move_use(...) end
MessageFormatter.show_bst_ready_move_auto_engage = function(...) return get_MessageBST().show_ready_move_auto_engage(...) end
MessageFormatter.show_bst_ready_move_auto_sequence = function(...) return get_MessageBST().show_ready_move_auto_sequence(...) end
MessageFormatter.show_bst_ready_move_recast = function(...) return get_MessageBST().show_ready_move_recast(...) end

-- Pet Status Messages
MessageFormatter.show_bst_pet_charmed = function(...) return get_MessageBST().show_pet_charmed(...) end
MessageFormatter.show_bst_pet_charm_failed = function(...) return get_MessageBST().show_pet_charm_failed(...) end
MessageFormatter.show_bst_pet_died = function(...) return get_MessageBST().show_pet_died(...) end
MessageFormatter.show_bst_pet_despawned = function(...) return get_MessageBST().show_pet_despawned(...) end

-- Error Messages
MessageFormatter.show_error_no_pet = function(...) return get_MessageBST().show_error_no_pet(...) end
MessageFormatter.show_error_no_ready_moves = function(...) return get_MessageBST().show_error_no_ready_moves(...) end
MessageFormatter.show_error_invalid_index = function(...) return get_MessageBST().show_error_invalid_index(...) end
MessageFormatter.show_error_index_out_of_range = function(...) return get_MessageBST().show_error_index_out_of_range(...) end
MessageFormatter.show_error_module_not_loaded = function(...) return get_MessageBST().show_error_module_not_loaded(...) end
MessageFormatter.show_error_no_target = function(...) return get_MessageBST().show_error_no_target(...) end
MessageFormatter.show_error_pet_too_far = function(...) return get_MessageBST().show_error_pet_too_far(...) end
MessageFormatter.show_error_no_jug_equipped = function(...) return get_MessageBST().show_error_no_jug_equipped(...) end
MessageFormatter.show_error_insufficient_hp = function(...) return get_MessageBST().show_error_insufficient_hp(...) end

-- Standard names (for validator and consistency)
MessageFormatter.show_call_beast_used = function(...) return get_MessageBST().show_call_beast_used(...) end
MessageFormatter.show_bestial_loyalty_used = function(...) return get_MessageBST().show_bestial_loyalty_used(...) end
MessageFormatter.show_familiar_activated = function(...) return get_MessageBST().show_familiar_activated(...) end
MessageFormatter.show_familiar_active = function(...) return get_MessageBST().show_familiar_active(...) end
MessageFormatter.show_spur_used = function(...) return get_MessageBST().show_spur_used(...) end
MessageFormatter.show_run_wild_used = function(...) return get_MessageBST().show_run_wild_used(...) end
MessageFormatter.show_tame_used = function(...) return get_MessageBST().show_tame_used(...) end
MessageFormatter.show_reward_used = function(...) return get_MessageBST().show_reward_used(...) end
MessageFormatter.show_reward_no_food = function(...) return get_MessageBST().show_reward_no_food(...) end
MessageFormatter.show_feral_howl_used = function(...) return get_MessageBST().show_feral_howl_used(...) end
MessageFormatter.show_killer_instinct_activated = function(...) return get_MessageBST().show_killer_instinct_activated(...) end
MessageFormatter.show_ecosystem_change = function(...) return get_MessageBST().show_ecosystem_change(...) end
MessageFormatter.show_species_change = function(...) return get_MessageBST().show_species_change(...) end
MessageFormatter.show_broth_equip = function(...) return get_MessageBST().show_broth_equip(...) end
MessageFormatter.show_jug_equipped = function(...) return get_MessageBST().show_jug_equipped(...) end
MessageFormatter.show_broth_count_header = function(...) return get_MessageBST().show_broth_count_header(...) end
MessageFormatter.show_broth_count_line = function(...) return get_MessageBST().show_broth_count_line(...) end
MessageFormatter.show_broth_count_footer = function(...) return get_MessageBST().show_broth_count_footer(...) end
MessageFormatter.show_no_broths = function(...) return get_MessageBST().show_no_broths(...) end
MessageFormatter.show_pet_summoned = function(...) return get_MessageBST().show_pet_summoned(...) end
MessageFormatter.show_pet_engage = function(...) return get_MessageBST().show_pet_engage(...) end
MessageFormatter.show_pet_disengage = function(...) return get_MessageBST().show_pet_disengage(...) end
MessageFormatter.show_pet_dismissed = function(...) return get_MessageBST().show_pet_dismissed(...) end
MessageFormatter.show_auto_engage_enabled = function(...) return get_MessageBST().show_auto_engage_enabled(...) end
MessageFormatter.show_auto_engage_disabled = function(...) return get_MessageBST().show_auto_engage_disabled(...) end
MessageFormatter.show_auto_engage_status = function(...) return get_MessageBST().show_auto_engage_status(...) end
MessageFormatter.show_pet_tp_status = function(...) return get_MessageBST().show_pet_tp_status(...) end
MessageFormatter.show_pet_hp_status = function(...) return get_MessageBST().show_pet_hp_status(...) end
MessageFormatter.show_ready_move_precast = function(...) return get_MessageBST().show_ready_move_precast(...) end
MessageFormatter.show_ready_move_physical = function(...) return get_MessageBST().show_ready_move_physical(...) end
MessageFormatter.show_ready_move_magical = function(...) return get_MessageBST().show_ready_move_magical(...) end
MessageFormatter.show_ready_move_breath = function(...) return get_MessageBST().show_ready_move_breath(...) end
MessageFormatter.show_ready_move_tp_check = function(...) return get_MessageBST().show_ready_move_tp_check(...) end
MessageFormatter.show_ready_moves_header = function(...) return get_MessageBST().show_ready_moves_header(...) end
MessageFormatter.show_ready_move_item = function(...) return get_MessageBST().show_ready_move_item(...) end
MessageFormatter.show_ready_moves_usage = function(...) return get_MessageBST().show_ready_moves_usage(...) end
MessageFormatter.show_ready_move_use = function(...) return get_MessageBST().show_ready_move_use(...) end
MessageFormatter.show_ready_move_auto_engage = function(...) return get_MessageBST().show_ready_move_auto_engage(...) end
MessageFormatter.show_ready_move_auto_sequence = function(...) return get_MessageBST().show_ready_move_auto_sequence(...) end
MessageFormatter.show_ready_move_recast = function(...) return get_MessageBST().show_ready_move_recast(...) end
MessageFormatter.show_pet_charmed = function(...) return get_MessageBST().show_pet_charmed(...) end
MessageFormatter.show_pet_charm_failed = function(...) return get_MessageBST().show_pet_charm_failed(...) end
MessageFormatter.show_pet_died = function(...) return get_MessageBST().show_pet_died(...) end
MessageFormatter.show_pet_despawned = function(...) return get_MessageBST().show_pet_despawned(...) end

-- COR functions (Corsair) - LAZY LOADED
MessageFormatter.show_rolltracker_load_failed = function(...) return get_MessageCOR().show_rolltracker_load_failed(...) end
MessageFormatter.show_packets_load_failed = function(...) return get_MessageCOR().show_packets_load_failed(...) end
MessageFormatter.show_resources_load_failed = function(...) return get_MessageCOR().show_resources_load_failed(...) end

-- DRG functions (Dragoon) - LAZY LOADED
MessageFormatter.show_drg_subjob_required = function(...) return get_MessageDRG().show_drg_subjob_required(...) end
MessageFormatter.show_subjob_disabled = function(...) return get_MessageDRG().show_subjob_disabled(...) end
MessageFormatter.show_jump_on_cooldown = function(...) return get_MessageDRG().show_jump_on_cooldown(...) end
MessageFormatter.show_high_jump_on_cooldown = function(...) return get_MessageDRG().show_high_jump_on_cooldown(...) end

-- WHM functions (White Mage) - LAZY LOADED
MessageFormatter.show_curemanager_not_loaded = function(...) return get_MessageWHM().show_curemanager_not_loaded(...) end

-- DNC functions removed - migrated to JABuffs (use show_ja_activated instead)


---============================================================================
--- DEBUG MESSAGES
---============================================================================

--- Show debug message (gray color, for conditional debug output)
--- @param prefix string Debug prefix (e.g., "BST", "PET_PRECAST", "RDM Midcast")
--- @param message string Debug message text
--- Show info message (cyan color, for user-facing command output)
--- @param prefix string Info prefix (e.g., "WAR", "Command")
--- @param message string Info message text
function MessageFormatter.show_info(prefix, message)
    local MessageRenderer = require('shared/utils/messages/core/message_renderer')
    local formatted = string.format('[%s] %s', prefix, message)
    MessageRenderer.send(formatted, 121)  -- Color 121 = cyan info
end

--- Show error message (red color, for error output)
--- @param prefix string Error prefix (e.g., "WAR", "ERROR")
--- @param message string Error message text
function MessageFormatter.show_error(prefix, message)
    local MessageRenderer = require('shared/utils/messages/core/message_renderer')
    local formatted = string.format('[%s] %s', prefix, message)
    MessageRenderer.send(formatted, 167)  -- Color 167 = red error
end

function MessageFormatter.show_debug(prefix, message)
    local MessageRenderer = require('shared/utils/messages/core/message_renderer')
    local formatted = string.format('[%s] %s', prefix, message)
    MessageRenderer.send(formatted, 8)  -- Color 8 = gray debug
end

return MessageFormatter

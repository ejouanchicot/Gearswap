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

-- Load all message modules
local MessageCore = require('shared/utils/messages/message_core')

-- UI modules
local MessageKeybinds = require('shared/utils/messages/formatters/ui/message_keybinds')
local MessageSystem = require('shared/utils/messages/formatters/system/message_system')
local MessageStatus = require('shared/utils/messages/formatters/ui/message_status')

-- Combat modules
local MessageCooldowns = require('shared/utils/messages/formatters/combat/message_cooldowns')
local MessageCombat = require('shared/utils/messages/formatters/combat/message_combat')
local JABuffs = require('shared/utils/messages/formatters/combat/message_ja_buffs')

-- Magic modules
local MessageBuffs = require('shared/utils/messages/formatters/magic/message_buffs')
local MessageDebuffs = require('shared/utils/messages/formatters/magic/message_debuffs')
local SongMessages = require('shared/utils/messages/formatters/magic/message_songs')

-- System modules
local MessageEquipment = require('shared/utils/messages/formatters/system/message_equipment')

-- Utility modules
local RollMessages = require('shared/utils/messages/utilities/roll_messages')
local PartyMessages = require('shared/utils/messages/utilities/party_messages')

-- Job-specific modules
local BRDMessages = require('shared/utils/messages/formatters/jobs/message_brd')
local RDMMessages = require('shared/utils/messages/formatters/jobs/message_rdm')
local BLMMessages = require('shared/utils/messages/formatters/jobs/message_blm')
local MessageBST = require('shared/utils/messages/formatters/jobs/message_bst')
local GEOMessages = require('shared/utils/messages/formatters/jobs/message_geo')
local MessageCOR = require('shared/utils/messages/formatters/jobs/message_cor')
local MessageDRG = require('shared/utils/messages/formatters/jobs/message_drg')
local MessageWHM = require('shared/utils/messages/formatters/jobs/message_whm')

---============================================================================
--- PUBLIC API - Maintains backward compatibility
---============================================================================

-- Expose colors for external use
MessageFormatter.COLORS = MessageCore.COLORS

-- Core utilities
MessageFormatter.convert_key_display = MessageCore.convert_key_display
MessageFormatter.show_separator = MessageCore.show_separator
MessageFormatter.get_job_tag = MessageCore.get_job_tag

---============================================================================
--- NEW GLOBAL FUNCTIONS - Universal Job Ability Messages
---============================================================================
-- These functions work for ALL jobs (replaces job-specific implementations)

-- Job Ability Buffs (Global - Works for ALL jobs)
MessageFormatter.show_ja_activated = JABuffs.show_activated                 -- [JOB] Ability activated! Description
MessageFormatter.show_ja_active = JABuffs.show_active                       -- [JOB] Ability active
MessageFormatter.show_ja_ended = JABuffs.show_ended                         -- [JOB] Ability ended
MessageFormatter.show_ja_with_description = JABuffs.show_with_description   -- [JOB] Ability: Description
MessageFormatter.show_ja_using = JABuffs.show_using                         -- [JOB] Using Ability
MessageFormatter.show_ja_using_double = JABuffs.show_using_double           -- [JOB] Using Ability1 + Ability2 (+ in gray)

-- Song Messages (BRD-specific but organized by TYPE not JOB)
MessageFormatter.show_song_rotation = SongMessages.show_songs_casting
MessageFormatter.show_song_pack_select = SongMessages.show_song_pack
MessageFormatter.show_song_honor_march_locked = SongMessages.show_honor_march_locked
MessageFormatter.show_song_honor_march_released = SongMessages.show_honor_march_released
MessageFormatter.show_song_daurdabla_dummy = SongMessages.show_daurdabla_dummy
MessageFormatter.show_song_pianissimo_used = SongMessages.show_pianissimo_used
MessageFormatter.show_song_pianissimo_target = SongMessages.show_pianissimo_target
MessageFormatter.show_song_marcato_honor_march = SongMessages.show_marcato_honor_march
MessageFormatter.show_song_marcato_skip_buffs = SongMessages.show_marcato_skip_buffs
MessageFormatter.show_song_marcato_skip_soul_voice = SongMessages.show_marcato_skip_soul_voice

-- Dance Messages removed - DNC now uses global JABuffs system (show_ja_activated)

---============================================================================
--- BACKWARD COMPATIBILITY WRAPPERS
---============================================================================
-- Maintain old BRD function names but use new global system
MessageFormatter.show_soul_voice_activated_new = JABuffs.show_soul_voice_activated
MessageFormatter.show_nightingale_activated_new = JABuffs.show_nightingale_activated
MessageFormatter.show_troubadour_activated_new = JABuffs.show_troubadour_activated
MessageFormatter.show_marcato_used_new = JABuffs.show_marcato_used

-- Keybind functions
MessageFormatter.show_keybind_list = MessageKeybinds.show_keybind_list
MessageFormatter.format_keybind_line = MessageKeybinds.format_keybind_line
MessageFormatter.show_no_binds_error = MessageKeybinds.show_no_binds_error
MessageFormatter.show_invalid_bind_error = MessageKeybinds.show_invalid_bind_error
MessageFormatter.show_bind_failed_error = MessageKeybinds.show_bind_failed_error

-- System functions
MessageFormatter.show_system_intro = MessageSystem.show_system_intro
MessageFormatter.show_system_intro_with_macros = MessageSystem.show_system_intro_with_macros
MessageFormatter.show_system_intro_complete = MessageSystem.show_system_intro_complete
MessageFormatter.show_color_test_header = MessageSystem.show_color_test_header
MessageFormatter.show_color_test_sample = MessageSystem.show_color_test_sample
MessageFormatter.show_color_test_footer = MessageSystem.show_color_test_footer

-- Status functions
MessageFormatter.show_error = MessageStatus.show_error
MessageFormatter.show_warning = MessageStatus.show_warning
MessageFormatter.show_success = MessageStatus.show_success
MessageFormatter.show_info = MessageStatus.show_info
MessageFormatter.show_tp_ready = MessageStatus.show_tp_ready
MessageFormatter.show_tp_required = MessageStatus.show_tp_required

-- Cooldown functions (professional system ready)
MessageFormatter.show_spell_cooldown = MessageCooldowns.show_spell_cooldown
MessageFormatter.show_ability_cooldown = MessageCooldowns.show_ability_cooldown
MessageFormatter.show_ws_cooldown = MessageCooldowns.show_ws_cooldown
MessageFormatter.show_item_recast = MessageCooldowns.show_item_recast
MessageFormatter.show_stratagem_cooldown = MessageCooldowns.show_stratagem_cooldown
MessageFormatter.show_song_duration = MessageCooldowns.show_song_duration
MessageFormatter.show_compact_status = MessageCooldowns.show_compact_status
MessageFormatter.show_cooldown_message = MessageCooldowns.show_cooldown_message
MessageFormatter.show_multi_status = MessageCooldowns.show_multi_status

-- Convenience functions with automatic windower API handling
MessageFormatter.show_spell_cooldown_by_id = MessageCooldowns.show_spell_cooldown_by_id
MessageFormatter.show_ability_cooldown_by_id = MessageCooldowns.show_ability_cooldown_by_id
MessageFormatter.get_spell_recast_seconds = MessageCooldowns.get_spell_recast_seconds
MessageFormatter.get_ability_recast_seconds = MessageCooldowns.get_ability_recast_seconds

-- Combat functions
MessageFormatter.show_range_error = MessageCombat.show_range_error
MessageFormatter.show_ws_validation_error = MessageCombat.show_ws_validation_error
MessageFormatter.show_ability_tp_error = MessageCombat.show_ability_tp_error
MessageFormatter.show_target_error = MessageCombat.show_target_error
MessageFormatter.show_state_change = MessageCombat.show_state_change
MessageFormatter.show_ws_tp = MessageCombat.show_ws_tp
MessageFormatter.show_ws_activated = MessageCombat.show_ws_activated  -- WS description display
MessageFormatter.show_spell_activated = MessageCombat.show_spell_activated  -- Spell description display (Enhancing/Enfeebling/Healing)
MessageFormatter.show_spell_cast = MessageCombat.show_spell_cast
MessageFormatter.show_ability_use = MessageCombat.show_ability_use
MessageFormatter.show_waltz_heal = MessageCombat.show_waltz_heal
MessageFormatter.show_jump_activated = MessageCombat.show_jump_activated
MessageFormatter.show_jump_chaining = MessageCombat.show_jump_chaining
MessageFormatter.show_jump_complete = MessageCombat.show_jump_complete
MessageFormatter.show_jump_relaunch = MessageCombat.show_jump_relaunch

-- Buff functions
MessageFormatter.show_buff_status = MessageBuffs.show_buff_status

-- Equipment check functions
MessageFormatter.show_check_header = MessageEquipment.show_check_header
MessageFormatter.show_set_valid = MessageEquipment.show_set_valid
MessageFormatter.show_missing_item = MessageEquipment.show_missing_item
MessageFormatter.show_storage_item = MessageEquipment.show_storage_item
MessageFormatter.show_check_summary = MessageEquipment.show_check_summary
MessageFormatter.show_check_error = MessageEquipment.show_check_error
MessageFormatter.show_no_sets_found = MessageEquipment.show_no_sets_found

-- Debuff blocking functions
MessageFormatter.show_spell_blocked = MessageDebuffs.show_spell_blocked
MessageFormatter.show_ja_blocked = MessageDebuffs.show_ja_blocked
MessageFormatter.show_ws_blocked = MessageDebuffs.show_ws_blocked
MessageFormatter.show_item_blocked = MessageDebuffs.show_item_blocked
MessageFormatter.show_action_blocked = MessageDebuffs.show_action_blocked
MessageFormatter.show_incapacitated = MessageDebuffs.show_incapacitated
MessageFormatter.show_silence_cure_success = MessageDebuffs.show_silence_cure_success
MessageFormatter.show_no_silence_cure = MessageDebuffs.show_no_silence_cure

-- Roll functions (COR)
MessageFormatter.show_roll_result = RollMessages.show_roll_result
MessageFormatter.show_roll_natural_eleven = RollMessages.show_roll_natural_eleven
MessageFormatter.show_roll_bust_rate = RollMessages.show_roll_bust_rate
MessageFormatter.show_roll_bust = RollMessages.show_roll_bust
MessageFormatter.show_roll_double_up_window = RollMessages.show_roll_double_up_window
MessageFormatter.show_roll_double_up_expired = RollMessages.show_roll_double_up_expired
MessageFormatter.show_no_active_roll = RollMessages.show_no_active_roll
MessageFormatter.show_active_rolls = RollMessages.show_active_rolls
MessageFormatter.show_rolls_cleared = RollMessages.show_rolls_cleared
MessageFormatter.show_roll_not_found = RollMessages.show_roll_not_found
MessageFormatter.show_invalid_roll_value = RollMessages.show_invalid_roll_value

-- Party Tracking (Universal - usable by any job)
MessageFormatter.show_party_members = PartyMessages.show_party_members

-- BRD functions (Bard)
MessageFormatter.show_soul_voice_activated = BRDMessages.show_soul_voice_activated
MessageFormatter.show_soul_voice_ended = BRDMessages.show_soul_voice_ended
MessageFormatter.show_nightingale_activated = BRDMessages.show_nightingale_activated
MessageFormatter.show_nightingale_active = BRDMessages.show_nightingale_active
MessageFormatter.show_troubadour_activated = BRDMessages.show_troubadour_activated
MessageFormatter.show_troubadour_active = BRDMessages.show_troubadour_active
MessageFormatter.show_marcato_used = BRDMessages.show_marcato_used
MessageFormatter.show_marcato_honor_march = BRDMessages.show_marcato_honor_march
MessageFormatter.show_marcato_skip_buffs = BRDMessages.show_marcato_skip_buffs
MessageFormatter.show_marcato_skip_soul_voice = BRDMessages.show_marcato_skip_soul_voice
MessageFormatter.show_pianissimo_used = BRDMessages.show_pianissimo_used
MessageFormatter.show_pianissimo_target = BRDMessages.show_pianissimo_target
MessageFormatter.show_ability_command = BRDMessages.show_ability_command
MessageFormatter.show_honor_march_locked = BRDMessages.show_honor_march_locked
MessageFormatter.show_honor_march_released = BRDMessages.show_honor_march_released
MessageFormatter.show_daurdabla_dummy = BRDMessages.show_daurdabla_dummy
MessageFormatter.show_songs_casting = BRDMessages.show_songs_casting
MessageFormatter.show_song_pack = BRDMessages.show_song_pack
MessageFormatter.show_songs_refresh = BRDMessages.show_songs_refresh
MessageFormatter.show_dummy_casting = BRDMessages.show_dummy_casting
MessageFormatter.show_dummy_cast = BRDMessages.show_dummy_cast
MessageFormatter.show_tank_casting = BRDMessages.show_tank_casting
MessageFormatter.show_tank_refresh = BRDMessages.show_tank_refresh
MessageFormatter.show_healer_casting = BRDMessages.show_healer_casting
MessageFormatter.show_healer_refresh = BRDMessages.show_healer_refresh
MessageFormatter.show_song_cast = BRDMessages.show_song_cast
MessageFormatter.show_song_guidance = BRDMessages.show_song_guidance
MessageFormatter.show_clarion_required = BRDMessages.show_clarion_required
MessageFormatter.show_lullaby_cast = BRDMessages.show_lullaby_cast
MessageFormatter.show_elegy_cast = BRDMessages.show_elegy_cast
MessageFormatter.show_requiem_cast = BRDMessages.show_requiem_cast
MessageFormatter.show_threnody_cast = BRDMessages.show_threnody_cast
MessageFormatter.show_carol_cast = BRDMessages.show_carol_cast
MessageFormatter.show_etude_cast = BRDMessages.show_etude_cast
MessageFormatter.show_song_refinement = BRDMessages.show_song_refinement
MessageFormatter.show_song_refinement_failed = BRDMessages.show_song_refinement_failed
MessageFormatter.show_doom_gained = BRDMessages.show_doom_gained
MessageFormatter.show_doom_removed = BRDMessages.show_doom_removed
MessageFormatter.show_no_pack_configured = BRDMessages.show_no_pack_configured
MessageFormatter.show_tank_not_configured = BRDMessages.show_tank_not_configured
MessageFormatter.show_healer_not_configured = BRDMessages.show_healer_not_configured
MessageFormatter.show_no_element_selected = BRDMessages.show_no_element_selected
MessageFormatter.show_no_carol_element = BRDMessages.show_no_carol_element
MessageFormatter.show_no_etude_type = BRDMessages.show_no_etude_type
MessageFormatter.show_no_song_in_slot = BRDMessages.show_no_song_in_slot
MessageFormatter.show_pack_not_found = BRDMessages.show_pack_not_found

-- RDM functions (Red Mage)
MessageFormatter.show_convert_activated = RDMMessages.show_convert_activated
MessageFormatter.show_convert_used = RDMMessages.show_convert_used
MessageFormatter.show_chainspell_activated = RDMMessages.show_chainspell_activated
MessageFormatter.show_chainspell_ended = RDMMessages.show_chainspell_ended
MessageFormatter.show_composure_activated = RDMMessages.show_composure_activated
MessageFormatter.show_composure_active = RDMMessages.show_composure_active
MessageFormatter.show_doom_warning = RDMMessages.show_doom_warning
MessageFormatter.show_rdm_doom_removed = RDMMessages.show_doom_removed
MessageFormatter.show_spell_casting = RDMMessages.show_spell_casting
MessageFormatter.show_element_list = RDMMessages.show_element_list
MessageFormatter.show_enspell_current = RDMMessages.show_enspell_current
MessageFormatter.show_storm_current = RDMMessages.show_storm_current
MessageFormatter.show_no_enspell_selected = RDMMessages.show_no_enspell_selected
MessageFormatter.show_gain_spell_not_configured = RDMMessages.show_gain_spell_not_configured
MessageFormatter.show_bar_element_not_configured = RDMMessages.show_bar_element_not_configured
MessageFormatter.show_bar_ailment_not_configured = RDMMessages.show_bar_ailment_not_configured
MessageFormatter.show_spike_not_configured = RDMMessages.show_spike_not_configured
MessageFormatter.show_storm_requires_sch = RDMMessages.show_storm_requires_sch

-- GEO functions (Geomancer)
MessageFormatter.show_indi_cast = GEOMessages.show_indi_cast
MessageFormatter.show_geo_cast = GEOMessages.show_geo_cast
MessageFormatter.show_spell_refined = GEOMessages.show_spell_refined
MessageFormatter.show_no_tier_available = GEOMessages.show_no_tier_available

-- BLM functions (Black Mage)
MessageFormatter.show_dark_arts_activated = BLMMessages.show_dark_arts_activated
MessageFormatter.show_element_cycle = BLMMessages.show_element_cycle
MessageFormatter.show_aja_cycle = BLMMessages.show_aja_cycle
MessageFormatter.show_storm_cycle = BLMMessages.show_storm_cycle
MessageFormatter.show_tier_cycle = BLMMessages.show_tier_cycle
MessageFormatter.show_buff_activated = BLMMessages.show_buff_activated
MessageFormatter.show_buff_cast = BLMMessages.show_buff_cast
MessageFormatter.show_magic_burst_on = BLMMessages.show_magic_burst_on
MessageFormatter.show_magic_burst_off = BLMMessages.show_magic_burst_off
MessageFormatter.show_free_nuke_on = BLMMessages.show_free_nuke_on
MessageFormatter.show_spell_refinement = BLMMessages.show_spell_refinement
MessageFormatter.show_spell_refinement_failed = BLMMessages.show_spell_refinement_failed
MessageFormatter.show_mp_conservation = BLMMessages.show_mp_conservation
MessageFormatter.show_arts_already_active = BLMMessages.show_arts_already_active
MessageFormatter.show_stratagem_no_charges = BLMMessages.show_stratagem_no_charges
MessageFormatter.show_buffself_error = BLMMessages.show_buffself_error
MessageFormatter.show_spell_replacement_error = BLMMessages.show_spell_replacement_error
MessageFormatter.show_spell_refinement_error = BLMMessages.show_spell_refinement_error
MessageFormatter.show_spell_recasts_error = BLMMessages.show_spell_recasts_error
MessageFormatter.show_insufficient_mp_error = BLMMessages.show_insufficient_mp_error
MessageFormatter.show_breakga_blocked = BLMMessages.show_breakga_blocked
MessageFormatter.show_buffself_recasts_error = BLMMessages.show_buffself_recasts_error
MessageFormatter.show_buffself_resources_error = BLMMessages.show_buffself_resources_error
MessageFormatter.show_buff_casting = BLMMessages.show_buff_casting
MessageFormatter.show_unknown_buff_error = BLMMessages.show_unknown_buff_error
MessageFormatter.show_buff_already_active = BLMMessages.show_buff_already_active
MessageFormatter.show_manual_buff_cast = BLMMessages.show_manual_buff_cast

-- BST functions (Beastmaster)
-- Legacy names with show_bst_ prefix
MessageFormatter.show_bst_ecosystem_change = MessageBST.show_ecosystem_change
MessageFormatter.show_bst_species_change = MessageBST.show_species_change
MessageFormatter.show_bst_broth_equip = MessageBST.show_broth_equip
MessageFormatter.show_bst_broth_count_header = MessageBST.show_broth_count_header
MessageFormatter.show_bst_broth_count_line = MessageBST.show_broth_count_line
MessageFormatter.show_bst_no_broths = MessageBST.show_no_broths
MessageFormatter.show_bst_pet_engage = MessageBST.show_pet_engage
MessageFormatter.show_bst_pet_disengage = MessageBST.show_pet_disengage
MessageFormatter.show_bst_auto_engage_status = MessageBST.show_auto_engage_status
MessageFormatter.show_bst_ready_move_precast = MessageBST.show_ready_move_precast
MessageFormatter.show_bst_ready_moves_header = MessageBST.show_ready_moves_header
MessageFormatter.show_bst_ready_move_item = MessageBST.show_ready_move_item
MessageFormatter.show_bst_ready_moves_usage = MessageBST.show_ready_moves_usage
MessageFormatter.show_bst_ready_move_use = MessageBST.show_ready_move_use
MessageFormatter.show_bst_ready_move_auto_engage = MessageBST.show_ready_move_auto_engage
MessageFormatter.show_bst_ready_move_auto_sequence = MessageBST.show_ready_move_auto_sequence
MessageFormatter.show_bst_broth_count_footer = MessageBST.show_broth_count_footer

-- Standard names (for validator)
MessageFormatter.show_ecosystem_change = MessageBST.show_ecosystem_change
MessageFormatter.show_species_change = MessageBST.show_species_change
MessageFormatter.show_broth_equip = MessageBST.show_broth_equip
MessageFormatter.show_broth_count_header = MessageBST.show_broth_count_header
MessageFormatter.show_broth_count_line = MessageBST.show_broth_count_line
MessageFormatter.show_no_broths = MessageBST.show_no_broths
MessageFormatter.show_pet_engage = MessageBST.show_pet_engage
MessageFormatter.show_pet_disengage = MessageBST.show_pet_disengage
MessageFormatter.show_auto_engage_status = MessageBST.show_auto_engage_status
MessageFormatter.show_ready_move_precast = MessageBST.show_ready_move_precast
MessageFormatter.show_ready_moves_header = MessageBST.show_ready_moves_header
MessageFormatter.show_ready_move_item = MessageBST.show_ready_move_item
MessageFormatter.show_ready_moves_usage = MessageBST.show_ready_moves_usage
MessageFormatter.show_ready_move_use = MessageBST.show_ready_move_use
MessageFormatter.show_ready_move_auto_engage = MessageBST.show_ready_move_auto_engage
MessageFormatter.show_ready_move_auto_sequence = MessageBST.show_ready_move_auto_sequence
MessageFormatter.show_broth_count_footer = MessageBST.show_broth_count_footer
MessageFormatter.show_error_no_pet = MessageBST.show_error_no_pet
MessageFormatter.show_error_no_ready_moves = MessageBST.show_error_no_ready_moves
MessageFormatter.show_error_invalid_index = MessageBST.show_error_invalid_index
MessageFormatter.show_error_index_out_of_range = MessageBST.show_error_index_out_of_range
MessageFormatter.show_error_module_not_loaded = MessageBST.show_error_module_not_loaded

-- COR functions (Corsair)
MessageFormatter.show_rolltracker_load_failed = MessageCOR.show_rolltracker_load_failed
MessageFormatter.show_packets_load_failed = MessageCOR.show_packets_load_failed
MessageFormatter.show_resources_load_failed = MessageCOR.show_resources_load_failed

-- DRG functions (Dragoon)
MessageFormatter.show_drg_subjob_required = MessageDRG.show_drg_subjob_required
MessageFormatter.show_subjob_disabled = MessageDRG.show_subjob_disabled
MessageFormatter.show_jump_on_cooldown = MessageDRG.show_jump_on_cooldown
MessageFormatter.show_high_jump_on_cooldown = MessageDRG.show_high_jump_on_cooldown

-- WHM functions (White Mage)
MessageFormatter.show_curemanager_not_loaded = MessageWHM.show_curemanager_not_loaded

-- DNC functions removed - migrated to JABuffs (use show_ja_activated instead)

return MessageFormatter

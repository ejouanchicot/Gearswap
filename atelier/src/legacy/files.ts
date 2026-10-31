// GearSwap Atelier · the old page's files (atelier/app/), in the order they are read: each script reads what the ones
// before it declare. A screen moved to Svelte takes its files out of these lists.
//
// @file    atelier/src/legacy/files.ts
// @author  ejouanchicot

/** The old page's styles (atelier/app/css/<name>.css), fit.css last: it keeps every box inside its frame */
export const LEGACY_STYLES: readonly string[] = ['base', 'sets', 'setlist', 'panels', 'combat', 'tabs', 'themes', 'motion',
  'moogle', 'guide', 'cursor', 'tips', 'config', 'fit'];

/** What the game writes for the page before its code: the targets, the list of the exports (atelier/index.js) and
 *  //gs c upgrade's call to the update screen (atelier/update_ask.js, shared/utils/core/release_info.lua) */
export const LEGACY_DATA: readonly string[] = ['atelier/targets.js', 'atelier/index.js', 'atelier/update_ask.js'];

/** The old page's scripts (atelier/app/js/<name>.js); events.js last: it reads the data and draws the page */
export const LEGACY_SCRIPTS: readonly string[] = ['i18n', 'job_icons', 'core', 'icon_hd', 'icon_cache', 'state_help_data', 'state_help_fr', 'player_words', 'game_icons', 'keys',
  'stats', 'stat_help', 'engine', 'optimizer', 'buffs', 'buff_panels', 'live', 'offline_export', 'simulate',
  'job_access_data', 'ws_access_data', 'job_access', 'list_prefs', 'sets_view', 'weapons', 'ws_page', 'opt_page',
  'nuke_layers', 'fight_stats', 'enh_jobs', 'stat_opt_texts', 'stat_figures', 'stat_opt', 'luopan', 'bst_pet', 'enfeeble', 'ele_debuff', 'porter', 'drawer', 'trial', 'push', 'push_view',
  'opt_all', 'add_set', 'layout2', 'usables_data', 'long_names_data','job_guide_data', 'job_guide_fr', 'module_catalog', 'module_items',
  'bags_view', 'bags_plan', 'bags_target', 'bags_place', 'module_rows', 'module_rest_fr', 'module_ux', 'modules', 'reg_special', 'hud_sources', 'hud_preview', 'macro_edit',
  'party_builder', 'profiles', 'target_pick', 'gear_pick', 'config_page', 'welcome', 'packages', 'add_job', 'update_core', 'update', 'motion', 'moogle',
  'tip_texts', 'guide_texts', 'guide_bags', 'guide_context', 'guide', 'tips', 'events'];

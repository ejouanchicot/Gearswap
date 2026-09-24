# Audit de nuit 2026-09-25 — Zone 5 : core, UI, keybinds, debug, config

Périmètre : `shared/utils/{core,ui,debug,keybinds,custom,sortie,commands,config}/**` et `shared/config/**`, soit 54 fichiers.

- **43 fichiers modifiés.** Il s'agit presque uniquement de commentaires, d'en-têtes et de doc `@param`/`@return`.
- **Code** : seulement 3 retraits sans effet sur le comportement (voir « Fait »).
- **Vérifications** : les 54 fichiers passent `lua5.1 loadfile`, aucune fin de ligne mélangée (les fichiers CRLF restent CRLF).
- **Rien n'a été commité.**

Les fichiers écrits aujourd'hui (keybinds, custom, sortie, SECTION_ALIASES, hook custom-states d'INIT_SYSTEMS, routes `sortie`/`tb`) ont été relus. Seuls quelques commentaires y ont changé, aucune logique.

## Fait

### shared/utils/core
- **INIT_SYSTEMS.lua** :
  - l'en-tête décrivait l'ancien ordre de démarrage (watchdog « immédiat », 5 systèmes) ; il donne maintenant l'ordre réel (immédiat, +0,5 s, +2 s, +3 s, +5 s) ;
  - commentaire AutoMedicine remis dans l'ordre logique ;
  - commentaire AutoMove corrigé : « BST a son propre système » est périmé, plus aucune entrée ne pose `DISABLE_AUTOMOVE` ;
  - le modèle « nouveau système » utilise maintenant `ensure_message_init()` ;
  - bloc « INITIALIZATION COMPLETE » retiré : il était placé au milieu du fichier.
- **COMMON_COMMANDS.lua** :
  - en-tête standard ajouté (il n'y en avait pas ; « 15 jobs » est corrigé) ;
  - doc `@param`/`@return` sur tous les handlers publics ;
  - doc de `wo` corrigée : **seul W7 est protégé**, pas W8 (`wardrobe/lib/config.lua` PROTECTED) ; les sous-commandes manquantes sont ajoutées ;
  - bloc de doc « perf » orphelin retiré, commentaires qui répétaient le code retirés ;
  - la longue condition de `is_common_command` a été reformatée sur plusieurs lignes, sans rien changer à ce qu'elle teste ;
  - local `MessageRenderer` inutilisé retiré : DEBUG_COMMANDS le charge de toute façon au même moment.
- **DEBUG_COMMANDS.lua** :
  - en-tête complété (author, version, date ; handle_debugstate et handle_memcheck ajoutés à la liste) ;
  - doc des handlers ajoutée ;
  - commentaire `spellmsg` faux corrigé : Enhancing et Enfeebling partagent `spell_mode`, donc la commande change les deux ;
  - le nom du fichier memcheck était faux (`data/memcheck.txt`), c'est `memcheck_<perso>_<job>.txt`.
- **job_change_manager.lua** :
  - en-tête réécrit : l'ancien « 3 s main / 0,5 s sub » était inexact ;
  - le commentaire sur `_G.JobChangeManagerSTATE` affirmait qu'il survit aux reloads, c'est faux ; il explique maintenant qu'il sert à partager l'état entre deux instances du module dans le même sandbox ;
  - retiré « le code après send_command ne s'exécute pas » (faux) ;
  - le commentaire sur `debounce_timer = nil` dit maintenant que c'est le compteur qui annule ;
  - variable de boucle `job_name` inutilisée remplacée par `_`.
- **midcast_watchdog.lua** :
  - en-tête standard ajouté ;
  - doc de toutes les fonctions publiques ;
  - précision que `_G.MIDCAST_WATCHDOG_TIMER` ne pilote pas la boucle ;
  - commentaires qui répétaient le code retirés.
- **state_display_override.lua (CRLF)** : l'en-tête et la doc affirmaient que Mote appelle la fonction « à chaque changement d'état », avec des arguments. En réalité Mote l'appelle sans argument, et seulement sur F12. La doc mal placée sur `init()` a été corrigée.
- **WATCHDOG_COMMANDS.lua (CRLF)** : le commentaire « 262 = Teleport-Holla, 20 s » était faux, 262 est Warp II (5 s). Le commentaire le dit maintenant, la valeur n'a pas changé. Commentaires qui répétaient le code retirés.
- Relus, rien à changer : CYCLE_HANDLER, keybind_guard, job_sync_watchdog, lifecycle_manager, module_cache.

### shared/utils/keybinds, custom, sortie (écrits aujourd'hui, commentaires seulement)
- **temp_binds.lua** :
  - `os.clock()` était décrit comme du « temps CPU » ; c'est le temps écoulé depuis le lancement du jeu ;
  - la liste RESERVED « touches liées par Mote » réserve en fait tout le bloc F9-F12, y compris des combinaisons que Mote ne lie pas ; le commentaire le précise.
- **temp_binds_parse.lua** :
  - un commentaire renvoyait à une note mémoire de Claude, absente du dépôt ; il est remplacé par l'explication elle-même ;
  - doc `@param` ajoutée sur `find_action`.
- **keybind_manager.lua** : commentaire `ctx` complété (champ `api`).
- **custom_states.lua** : l'en-tête ajoute le moment `ability`, précise que precast/midcast ne concernent que les sorts, et mentionne les « rules » (entrées sans state). Une ligne de doc trop longue a été coupée.
- Relus, rien à changer : key_validator, custom_conditions, custom_guards, custom_states_validate, sortie_commands.

### shared/utils/ui (17 fichiers)
- **UI_MANAGER.lua** :
  - @file et @date corrigés ;
  - le commentaire « persiste entre les reloads » était faux (`_G` est reconstruit) ;
  - précision que le bloc de secours tourne vraiment pour WAR, BST et PUP.
- **ui_lifecycle.lua (CRLF)** : en-tête et doc. Un `local success, error_msg =` jamais lu devant `pcall` a été retiré, sans effet sur le comportement.
- **ui_visibility.lua** : c'est `KeybindSettings.save` qui fait persister le réglage, pas `ui_display_config`.
- **UI_LOADER.lua** :
  - description réécrite : c'est le pathsearch de GearSwap qui trouve le fichier du perso, pas une « détection » ;
  - le commentaire « aucune config trouvée » précise qu'une erreur *dans* le fichier donne le même échec.
- **ui_state_tracker.lua** : la boucle commentée « new states » détecte en réalité les states *disparus*.
- **ui_update_orchestrator.lua** : « appelé par JobChangeManager » était faux, cette fonction n'a aucun appelant.
- **UI_SECTIONS.lua** : le séparateur n'apparaît que si l'en-tête ET la légende sont visibles.
- **COLOR_SYSTEM.lua** :
  - helper local `matches_patterns` supprimé (0 référence, non exporté) ;
  - `@return` de get_value_color corrigé ;
  - commentaires historiques « (fixed: was …) » retirés.
- **Les autres fichiers UI** (ui_display, UI_SETTINGS, ui_section_toggles, ui_appearance, ui_settings_resolver, ui_state_value, UI_COMMANDS, UI_DISPLAY_BUILDER hors SECTION_ALIASES, UI_FORMATTER) : en-têtes standard, doc `@param`/`@return`, commentaires historiques ou faux corrigés. Les bugs connus sont signalés par une NOTE en commentaire, sans toucher au code.

### shared/utils/debug, commands, config, shared/config (15 fichiers)
- **lag_debugger.lua** :
  - le commentaire disant que GearSwap ne désinscrit pas les events était faux : le moteur le fait (`refresh.lua`, unregister_event_user) ;
  - mention de `package.loaded` corrigée ;
  - doc de l'API ajoutée.
- **full_test.lua, system_checker.lua** :
  - en-têtes standard ajoutés, doc de run, display et export ;
  - system_checker : intertitre mal placé déplacé, commentaire de couleur faux corrigé.
- **performance_profiler.lua** : `perf toggle` ajouté à l'en-tête, format de @date corrigé, `@return` de la couleur corrigé.
- **global_probe.lua** : `@return` de `leaks()` précisé (peut rendre nil).
- **info_command.lua** : commentaire « lazy loaded » corrigé, une NOTE signale le bug de l'ordre sanitize/remplacement.
- **\*_MESSAGES_CONFIG.lua (x4)** : le chemin du fichier de réglages était faux ; c'est `<Perso>/config/message_modes.lua`. Doc ajoutée.
- **message_settings.lua** : les fonctions dites « legacy » sont en fait le chemin utilisé en jeu ; leur doc le dit maintenant.
- **message_modes.lua** : l'en-tête dit maintenant que rien ne lit ce fichier.
- **ui_settings.lua** :
  - commentaire DEFAULTS faux sur deux points, corrigé ;
  - il y a 19 paramètres, pas 14 ;
  - doc des 20 fonctions publiques.
- **DEBUFF_AUTOCURE_CONFIG.lua, config_loader.lua** : `@author` corrigé en Tetsouo, commentaires qui répétaient le code retirés.

## Bugs suspectés

Aucun n'a été corrigé : chaque correctif changerait le comportement.

1. **`keybind_manager.lua:250` et `custom_states.lua:70`** (écrits aujourd'hui) :
   - Ces deux lignes appellent `MessageFormatter.show_error(job .. '_CUSTOM', tostring(err))`. Or `show_error` ne prend qu'un argument (`message_status.lua:22`).
   - Résultat : si un `<JOB>_CUSTOM.lua` a une erreur de syntaxe, le joueur voit seulement « PLD_CUSTOM.lua », **sans la raison**.
   - Correctif : `show_error(job .. '_CUSTOM.lua: ' .. tostring(err))`.
   - Même défaut, déjà connu, dans `COMMON_COMMANDS.lua:681` et `DEBUG_COMMANDS.lua:480`.
2. **`ui_section_toggles.lua:42`** (connu) :
   - Le recalage Y est de signe inversé : quand on affiche ou masque en-tête, légende ou colonnes, le HUD saute au lieu de rester en place.
   - Correctif probable : `current_y + (new_offset - old_offset)`.
3. **`UI_MANAGER.lua:64-69` et `ui_lifecycle.lua:83-95`** (connu) : avec le HUD désactivé, `is_visible()` répond quand même vrai, donc le cycle d'un state par touche n'affiche plus rien dans le chat.
4. **`UI_DISPLAY_BUILDER.lua:132` et `UI_FORMATTER.lua:284`** (connu) : une keybind sans `desc` fait planter le premier rendu, et le chargement du job avorte.
   - Les binds custom ont toujours un `desc`, donc ils ne sont pas concernés.
5. **`COMMON_COMMANDS.lua:437`** (connu) : le diagnostic d'échec warp teste `shared/utils/messages/message_warp`, alors que le module est sous `messages/formatters/system/`. Le diagnostic affiche donc un faux échec.
6. **`WATCHDOG_COMMANDS.lua:87`** (connu) :
   - `watchdog test` utilise l'id 262 (Warp II, 5 s) mais l'annonce comme Teleport-Holla (122, 20 s).
   - Correctif : `or 122`.
7. **`state_display_override.lua`** (connu) : F12 avec le HUD désactivé affiche « State: Unknown », parce que Mote n'envoie aucun argument.
8. **`info_command.lua:52-61`** (connu) : les caractères non-ASCII sont supprimés avant le remplacement des guillemets et tirets typographiques, donc les apostrophes disparaissent de `//gs c info`.
9. **`lag_debugger.lua:108-111, 145-148`** :
   - Après un reload, le moteur a déjà désinscrit l'event ; le code désinscrit une seconde fois l'id gardé dans `windower._lagdebug`.
   - Si Windower réutilise ses ids (non vérifié), cela pourrait retirer l'écouteur de quelqu'un d'autre.
10. **`system_checker.lua:275`** : `score >= 70 and 167 or 167` donne toujours 167, il n'y a pas de couleur intermédiaire. Cosmétique.
11. **`ui_settings.lua:56-57`** (connu) : la position de secours est 1600/300, alors qu'UI_CONFIG donne 1857/-24. Sur WAR, BST et PUP, un `ui_settings` manquant est régénéré à la mauvaise position.
12. **`COMMON_COMMANDS.lua:190-222`** (connu) :
    - Les sous-commandes `wo` sont sensibles à la casse.
    - Une faute de frappe (`wo Global`) lance l'organisation **par défaut**, alors que l'utilisateur attendait l'aperçu ou le mode global.

## Doutes / à décider

- **`COLOR_SYSTEM.lua` get_gain_color** : Gain-DEX est coloré Vent et Gain-AGI Foudre, alors que `stat_colors` du même fichier fait l'inverse (DEX = Foudre). Les anciens commentaires « fixed » laissent penser que c'était voulu. Quelle convention garder ?
- **`UI_SETTINGS.lua:5`** : le `require(message_core)` n'est jamais utilisé. Il n'a pas été retiré, parce qu'un require charge un module ; le retirer est probablement sans risque.
- **`UI_DISPLAY_BUILDER.lua`** : le motif `"BRDRotation"` ne correspond à aucun state, et le motif `"Rotation"`, testé avant lui, le capterait de toute façon. Le supprimer ?
- **`temp_binds.lua` RESERVED** : `@f10`, `@f11`, `@f12` et `!f11` sont réservés alors que Mote ne les lie pas. Avec `force`, c'est sans conséquence, mais un message « déjà pris par Mote » peut surprendre. Garder la réserve large ?
- **`message_modes.lua`** : le fichier est orphelin et son défaut `ja_mode = 'full'` contredit le défaut réel (`'on'`). Supprimer ?
- **`config_loader.lua:41`** : le chemin est construit avec `windower.windower_path .. 'addons/GearSwap/data/'`, alors que le reste du projet utilise `windower.addon_path .. 'data/'`. Aligner ?
- **Dates `@date Created`** ajoutées d'après le premier commit git (souvent 2025-11-03, date de l'import) : pour les anciens fichiers, la vraie date est probablement antérieure.
- **`COMMON_COMMANDS.lua`** : une dizaine de handlers refont `local MessageFormatter = require(...)` alors que le module l'a déjà en haut du fichier. C'est redondant mais inoffensif ; laissé tel quel.

## Code mort probable

Grep sur tout `data/`, dossiers live Tetsouo/ et Kaories/ compris. Rien n'a été supprimé à part deux locaux : le helper `matches_patterns` et la variable `MessageRenderer`.

- **MidcastWatchdog.is_enabled / get_buffer / get_fallback_timeout / is_debug_enabled** : 0 appel hors du fichier (`grep -rn "MidcastWatchdog[.:]<nom>"` donne 0).
- **ModuleCache.stats()** : 0 appelant (`grep -rn "ModuleCache.stats"` ne trouve que la définition).
- **UI_MANAGER / ui_update_orchestrator** : `handle_job_configuration_change`, `needs_reinit`, `get_status`, `schedule_update` n'ont aucun appelant hors du module (`grep -rhoE "KeybindUI[.:][a-z_]+"`).
- **UI_LOADER** : `config_exists` et `get_config_path` n'ont que leur définition, et leur chemin est faux de toute façon.
- **ui_settings_resolver** : `default_ui_settings`, 0 appelant.
- **UIDisplayBuilder** : `validate_structure` et `get_categorization_stats` n'ont aucun appelant.
- **UISections** : `validate_configuration`, `get_section_statistics` et `render_commands_footer` n'ont aucun appelant hors du fichier.
- **UIFormatter** : `calculate_header_width`, `format_empty_section`, `validate_configuration`, `get_statistics` : 0 appelant.
- **ColorSystem** : `get_element_colors`, `get_stat_colors`, `add_custom_color` : 0 appelant. `special_colors.bar_ailment` est écrit mais jamais lu.
- **UISettings (shared/config/ui_settings.lua)** : `get_sections` et `set_section` n'ont aucun appelant.
- **LagDebugger.log, Profiler.profile_call, Profiler.measure** : 0 appelant (déjà connu).
- **DEBUFF_AUTOCURE_CONFIG** : les champs `auto_cure_poison` et `auto_cure_blind` ne sont lus par rien.
- **shared/config/message_modes.lua** (fichier entier) : aucun require/include/dofile ne vise ce chemin. `message_settings` lit `<Perso>/config/message_modes.lua`.

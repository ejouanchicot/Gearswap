# Audit de nuit 2026-09-25 — Zone 6 : warp, wardrobe, equipment, dualbox, inventory

Périmètre : `shared/utils/warp/**`, `shared/utils/wardrobe/**`, `shared/utils/equipment/**`,
`shared/utils/dualbox/**`, `shared/utils/inventory/**` (43 fichiers, ~10 700 lignes).

Contrôles faits sur **chaque** fichier modifié :

- `lua5.1 -e "assert(loadfile(...))"` : OK pour les 43 fichiers de la zone ;
- fins de ligne identiques à la sauvegarde (CRLF reste CRLF, LF reste LF) ;
- comparaison **jeton par jeton** (commentaires et espaces ignorés) avec la sauvegarde
  `backup_2026-09-24_night` : 32 fichiers modifiés ont exactement le même code qu'avant.
  Les 6 autres ne diffèrent que par la suppression de variables locales jamais lues
  (listées ci-dessous). Aucune logique, aucun message, aucun délai n'a changé.

Les modifications de travail en cours du propriétaire (`SEP_LEN = 69`, `WIDTH = 69`,
`string.rep("=", 69)` dans `wardrobe/lib/config.lua`, `refill/refill_panels.lua`,
`equipment/wardrobe_auditor.lua`) sont conservées telles quelles.

Non touchés volontairement : `equipment/hp_priority.lua`, `equipment/ampulla_lock.lua`
(récents, validés en jeu, déjà propres), `refill/bag_scanner.lua`, `refill/item_resolver.lua`
(en-têtes déjà complets, rien de faux).

Note : les numéros de ligne cités dans `docs/dev/systems/warp.md`,
`wardrobe-organizer.md`, `equipment-and-inventory.md` et `dualbox.md` sont décalés
de quelques lignes par ces changements de commentaires.

## Fait

### warp/
- `warp_commands.lua` : en-tête standard ; docs `@param/@return` sur `handle_command` et les deux routeurs internes (remplacent les commentaires « Extracted from… » tronqués) ; le bloc `debugwarp` est signalé comme inatteignable ; double ligne vide retirée.
- `warp_command_registry.lua` : en-tête standard ; l'étape 2 du mode d'emploi était fausse (« command_status() ») → `WarpCommands.handle_command()` ; `warp_ipc_register.lua` ajouté aux consommateurs.
- `warp_item_database.lua` : en-tête standard (alias vers `warp_database_core`).
- `warp_detector.lua` : en-tête corrigé (65 objets et non 68, plus de chemin absolu `D:\...`, plus de « MyHome detection » qui n'existe pas) ; doc de `clear_callbacks` corrigée (appelé à chaque chargement, pas au changement de job) ; notes « Known issue » sur `get_warp_items` (lève une erreur) et `get_all_destinations` (fonction inexistante).
- `warp_equipment.lua` : en-tête standard ; commentaires faux corrigés (l'ancien minuteur de déverrouillage n'est **pas** annulé ; le `equip()` après déverrouillage est ignoré car hors événement ; le callback enregistré par `init()` est effacé juste après) ; commentaires qui répètent le code retirés.
- `warp_init.lua` : en-tête réécrit (il n'est plus chargé depuis `user_setup`, il ne verrouille rien, il n'enregistre pas de commandes) ; commentaire faux « requires this module » → `warp_commands.lua`.
- `warp_ipc.lua` : en-tête réécrit (la réception est dans `warp_ipc_register.lua`) ; `init()`/`handle_ipc_message` signalés sans appelant ; **fonction locale morte `count_other_characters()` supprimée** (0 référence).
- `warp_ipc_register.lua` : en-tête réécrit (il n'est pas inclus par les fichiers de job mais par `WarpInit`) ; commentaire d'écho corrigé (fenêtre de 2,5 s).
- `warp_precast.lua` : en-tête réécrit (plus de justification « MyHome » invérifiable) ; **2 variables `warp_data` jamais lues retirées** ; `on_warp_spell()` signalé comme no-op.
- `casting/cast_helpers.lua`, `casting/spell_caster.lua` : en-têtes standard ; phrase d'historique retirée ; limites de `cast_spell` documentées (ni PM, ni recast, ni silence).
- `casting/item_user.lua` : en-tête standard ajouté (il n'en avait pas) ; docs `@param/@return` sur les 5 fonctions `ItemUser.*` ; commentaires faux corrigés (« most reliable method », « Category 1 = movement », « Equip delay (just equipped) », « JST vs local ») ; commentaires « Increased… » / « REMOVED… » retirés.
- `database/warp_database_core.lua` : en-tête (5 modules, pas 8) ; doc de `count_total_items` remise au-dessus de la bonne fonction.
- `database/warp_database_{home,teleports,nations,cities_chocobo_conquest,adoulin_special_mechanics}.lua` : en-têtes `@file/@date` ; docs des 3 fonctions d'API ; compteurs corrigés (cities : 14 destinations / 16 objets ; adoulin : 22 / 31).

### wardrobe/
- `lib/log.lua`, `lib/chat.lua`, `lib/items.lua`, `lib/config.lua`, `lib/warp_owned.lua`, `lib/moves.lua`, `lib/state.lua`, `lib/orchestrator_alt.lua`, `lib/reports.lua` : en-têtes standard (`@author/@version/@date`) ; docs `@param/@return` manquantes ajoutées ; listes de fonctions publiques complétées (`Chat.alert`, `Items.add_always_kept`, `Moves.all_pinned_bags`, `Moves.unclaimed_pins_first`) ; largeur « 74 » remplacée par `Config.SEP_LEN` ; `config.lua` : `KEEP_ITEMS` ajouté à la liste des clés surchargeables, note que `PROTECTED` n'est lu par personne ; `reports.lua` : « Reads nothing » était faux (lit la config).
- `lib/phases.lua` : en-tête corrigé (le burst loop n'est plus en « alternance stricte » mais mixte ; Phase 3.5 et mode alt listés) ; doc « Empty W1-W4… » qui était au-dessus de la mauvaise fonction remise sur `empty_alt` ; bannière « ALT MODE » déplacée au bon endroit, bannière « PHASE 3.5 » ajoutée ; **3 variables locales jamais lues retirées** (`bag_name`, `first_pinned_bag`, `all_pinned_bags`) ; quelques commentaires redondants retirés pour rester sous 800 lignes (798).
- `wardrobe_organizer.lua` : en-tête (Phase 0 = déshabiller **puis** verrouiller, Phase 3.5, modules manquants) ; commentaire faux « Keep slots locked through the retry » corrigé (la Phase 0 du retry déverrouille) ; **`require` de `Moves` jamais utilisé retiré** (le module est de toute façon chargé par `State`).

### equipment/
- `equipment_checker.lua` : en-tête standard ; deux docs qui étaient au-dessus de la mauvaise fonction remises en place (`build_item_cache`, `scan_sets_recursive`) ; note « Known issue » sur `add_equipped_items`.
- `wardrobe_auditor.lua` : en-tête standard ; doc de `audit()` remise au-dessus de `audit()` ; doc de `build_frequency_map` corrigée (utilisée par le rapport `wo scan`, pas par l'organiseur) ; **table locale `SLOT_NAMES` jamais lue supprimée** ; `local status, _err =` inutilisé retiré ; caractère non-ASCII « ∈ » retiré.

### dualbox/
- `dualbox_sync_ipc.lua` : en-tête (hooks `rf/refill` ajoutés, `@version/@date`) ; commentaire faux « les hooks survivent au reload grâce à `_G` » corrigé (c'est l'inverse, ils sont réenregistrés à chaque chargement) ; note : `_G.DUALBOX_SYNC_DEBUG` n'est jamais posé.
- `alt_buff_reporter.lua` : en-tête (l'exemple Entrust contredisait le comportement vérifié en jeu : `buff_change` ne part qu'à la perte) ; doc de `report_all` précisée.
- `dualbox_manager.lua` : en-tête standard ; commentaires « vers le MAIN / vers l'ALT » corrigés (les deux rôles envoient) ; `@param main_level/sub_level` ajoutés ; fonctions sans appelant signalées ; commentaire sur le re-`require` mis à jour depuis l'arrivée de `module_cache.lua`.
- `alt_commands.lua` : commentaire faux (« `last_update` écrit seulement au changement de job ») corrigé ; doc de `clear_cache` précisée.

### inventory/
- `refill_manager.lua` : en-tête (« ~150 lignes » faux → 315 ; plus de « 74-char ») ; la section « PUBLIC API » englobait des helpers locaux → renommée « PLANNING HELPERS », vraie section API avant `refill()`.
- `refill/refill_panels.lua` : en-tête (listait `section`/`divider` qui n'existent pas) ; **constante locale `SUBSEP` jamais lue supprimée**.
- `refill/config_resolver.lua` : commentaire sur le filtre des dossiers personnages précisé (les clones figés sont inclus).
- `quiver_manager.lua` : commentaire faux corrigé (`/ra` est reconnu par `action_type == 'Ranged Attack'` ; c'est `spell.type` qui vaut `'Misc'`) ; doc de `resolve_id`.

## Bugs suspectés

Non corrigés (changement de comportement). La plupart sont déjà dans les sections
« Known issues » de `docs/dev/systems/*.md` ; je liste ceux qui comptent le plus.

1. **`message_warp.lua` / `item_user.lua:292`** — `MessageWarp.show_item_equip_delay` est défini deux fois ; l'appel à un seul argument lève une erreur quand un anneau n'est pas prêt avec un délai 0 (extdata illisible, type inconnu…). Conséquence : `//gs c warp` plante au lieu d'afficher les recasts. Correctif : supprimer la définition en double ou passer le bon nombre d'arguments.
2. **`warp_detector.lua:229` (`get_warp_items`)** — lit `WarpItemDB.ITEMS` qui n'existe pas : `//gs c warp test` lève une erreur. Correctif : compter via `get_all_item_names()` / `count_total_items()`.
3. **`warp_equipment.lua:172-187` + `warp_detector.lua:176`** — le verrou automatique à l'utilisation d'un objet de warp ne s'enclenche jamais : `init_action_listener()` efface le callback juste enregistré, et l'id d'objet est lu dans `act.param` au lieu de `act.targets[1].actions[1].param`. Aujourd'hui inoffensif (rien ne dépend de ce verrou), mais c'est du code « vivant » qui ne fait rien.
4. **`item_user.lua:25-69` (`restore_equipment`)** — tous les appels viennent de `coroutine.schedule`, donc le `equip()` fait par `status_change()` est jeté. C'est `gs enable ring1` qui remet l'anneau. Même défaut dans `warp_equipment.lua` (ré-équipement 0,5 s après déverrouillage). Correctif : envoyer `gs c update` (ou `gs equip sets.idle`) au lieu d'appeler Mote directement.
5. **`equipment_checker.lua:140-148`** — `get_items().equipment` contient des index de sac, pas des ids d'objet : des objets au hasard sont marqués « équipés ». Impact faible (les pièces équipées sont aussi trouvées dans leur sac), mais `checksets` peut dire « OK » à tort pour un objet dont l'id égale un index.
6. **`wardrobe/lib/config.lua:48`** — `Config.PROTECTED` n'est lu nulle part : la W7 n'est protégée que parce qu'elle n'apparaît dans aucune liste de sacs. Un pin `bag='wardrobe 7'` dans un set y enverrait de l'équipement.
7. **`warp_database_core.lua:271-301` (`can_player_use_item`)** — sans appelant, mais faux s'il servait : `player.race` ne contient pas le sexe (« Hume » ≠ `HUME_M`), et les masques `races` des objets de Purgonorgo (2, 4, 8… 256) ne suivent pas le même codage que la table `RACES` (0x0001…0x0080).
8. **`wardrobe_organizer.lua:372`** — `Chat.phase(3.5, …)` formate avec `%d` : la phase s'affiche « Phase 3 ». Correctif : `%s` ou un libellé.
9. **`quiver_manager.lua:57-80`** — duplique l'index nom→id de `refill/item_resolver.lua` (deux index de ~30 000 entrées en mémoire). Correctif : réutiliser `ItemResolver.resolve_item_id`.

## Doutes / à décider

- `wardrobe_organizer.lua:118-121` — le « pourquoi » de `schedule_lockstyle` (« FFXI re-évalue le lockstyle d'après W1/W2 ») n'est pas vérifiable dans le code. Laissé tel quel : à confirmer ou reformuler.
- `item_user.lua:127-128` — l'offset 18000 s est le même que MyHome ; l'explication « JST vs heure locale » a été retirée faute de preuve. Garder le constat « même constante que MyHome » suffit-il ?
- `wardrobe/lib/phases.lua` fait 798 lignes (limite dure 800), `item_user.lua` 765, `wardrobe_organizer.lua` 704 : un découpage (ex. sortir le mode alt de `phases.lua`, `_setup_auto_fix` de `item_user.lua`) est à décider.
- Les 5 modules `warp_database_*` recopient les mêmes 3 fonctions (`get_items`, `get_item_by_id`, `count_items`) : factoriser dans `warp_database_core` ?
- `wardrobe_auditor.lua:36-40` — sans joueur, repli sur le dossier `Tetsouo/sets/` même sur Kaories. Voulu ?
- `refill/config_resolver.lua:115` — la détection « foreign » lit aussi les configs de Hysoka et Gabvanstronger (clones figés). Voulu ?
- `dualbox_sync_ipc.lua:124` — `_G.DUALBOX_SYNC_DEBUG` n'est jamais posé : une erreur dans un hook `ls`/`rf` reste silencieuse. Brancher sur `windower._gs_debug` ?

## Code mort probable

Preuve : `grep -rn "<nom>" --include=*.lua` sur tout `data/` (live Tetsouo/Kaories compris,
Hysoka/Gabvanstronger/scripts exclus). « 0 appel » = seule la définition (et ses commentaires) sort.
**Rien n'a été supprimé** parmi ces fonctions exportées.

| Élément | Fichier | Preuve |
|---|---|---|
| `WarpIPC.init`, `WarpIPC.is_initialized`, `WarpIPC.get_allowed_commands` (+ `handle_ipc_message`, joignable seulement via `init`) | `warp/warp_ipc.lua` | 0 appel ; l'écouteur réel est `warp_ipc_register.lua` |
| `WarpDetector.has_blm`, `has_whm`, `get_items_by_destination`, `get_all_destinations`, `count_warp_items`, `ItemDB` | `warp/warp_detector.lua` | 0 appel (les `has_blm` trouvés ailleurs sont des variables locales homonymes) |
| `SpellCaster.can_cast`, `get_required_level`, `is_blm_spell`, `is_whm_spell` | `warp/casting/spell_caster.lua` | 0 appel |
| `CastHelpers.has_ring` | `warp/casting/cast_helpers.lua` | 0 appel |
| `WarpInit.handle_warp_spell` | `warp/warp_init.lua` | 0 appel |
| `WarpPrecast.global_precast_hook` | `warp/warp_precast.lua` | 0 appel |
| `WarpEquipment.on_warp_spell` | `warp/warp_equipment.lua` | appelé par `warp_precast.lua`, mais corps vide |
| `WarpDatabase.can_player_use_item` | `warp/database/warp_database_core.lua` | 0 appel |
| branche `debugwarp` | `warp/warp_commands.lua:270` | `COMMON_COMMANDS.lua` traite `debugwarp` avant de router ici |
| `Moves.find_inv_slot`, `Moves.first_pinned_bag` | `wardrobe/lib/moves.lua` | 0 appel (le seul alias de `first_pinned_bag`, dans `phases.lua`, était lui-même inutilisé et a été retiré) |
| `Chat.divider`, `Chat.kv` | `wardrobe/lib/chat.lua` | 0 appel |
| `Config.UNEQUIP_DELAY`, `EQUIP_SLOTS`, `BAG_NAME_TO_ID`, `SEP_CHAR`, `PROTECTED` | `wardrobe/lib/config.lua` | jamais lus (hors fichiers `WARDROBE_CONFIG.lua` qui posent `PROTECTED`) |
| `WardrobeAuditor.build_frequency_map` ≡ `collect_all_used_names` | `equipment/wardrobe_auditor.lua` | corps identiques (doublon, les deux ont un appelant) |
| `DualBoxManager.show_status`, `mark_alt_offline`, `get_alt_subjob` (+ `get_time_since_update`, utilisé seulement par `show_status`) | `dualbox/dualbox_manager.lua` | 0 appel |
| `DualBoxSyncIPC.unregister_hook` | `dualbox/dualbox_sync_ipc.lua` | 0 appel |
| `AltCommands.clear_cache` | `dualbox/alt_commands.lua` | 0 appel (le `clear_cache` de `messages.lua:324` est celui de `MessageEngine`) |

Supprimés cette nuit parce que **locaux et jamais lus** (vérifié par comparaison de jetons) :
`count_other_characters` (warp_ipc), `warp_data` ×2 (warp_precast), `bag_name` /
`first_pinned_bag` / `all_pinned_bags` (phases), `Moves` (wardrobe_organizer), `SLOT_NAMES` et
`status, _err` (wardrobe_auditor), `SUBSEP` (refill_panels).

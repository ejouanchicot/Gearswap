# Audit de nuit 2026-09-25 — Zone 1 : BLM, BRD, BST, COR

Périmètre : `shared/jobs/blm/**`, `shared/jobs/brd/**`, `shared/jobs/bst/**`,
`shared/jobs/cor/**` (74 fichiers `.lua`, tous relus).

Garanties de sécurité appliquées à chaque fichier :

- `lua5.1 -e "assert(loadfile(...))"` passe sur les 74 fichiers.
- Fins de ligne et encodage identiques à la sauvegarde (16 fichiers CRLF, 58 LF,
  UTF-8 sans BOM), dernier octet identique.
- Comparaison **jeton par jeton** (commentaires et blancs retirés) entre la
  sauvegarde et le fichier actuel : 69 fichiers ont un code **strictement
  identique** ; seuls 5 fichiers ont un changement de code, tous listés
  ci-dessous comme suppressions de code mort interne. Aucun message affiché au
  joueur, aucun nom exporté, aucune valeur par défaut n'a changé.

## Fait

Changements répétés sur presque tous les fichiers (pas redits ligne par ligne) :
`@file` réécrit en chemin relatif complet (`shared/jobs/...`) au lieu de
`jobs/...` ou du seul nom de fichier ; `@requires utils/...` → `shared/utils/...` ;
`@param action` corrigé de `string` en `table` ; doc `@param/@return` ajoutée sur
les hooks publics qui n'en avaient pas ; bandeaux de profilage `TIMER` en double
simplifiés en une ligne de commentaire.

### BLM
- `BLM_BUFFS.lua`, `BLM_STATUS.lua` : description fausse (« Chainspell »,
  « Idle/Engaged/Resting… ») remplacée par ce que fait vraiment le hook partagé (Doom).
- `BLM_AFTERCAST.lua` : retiré le commentaire « aucune logique BLM » (faux, il y a
  le verrou Impact) ; doc du hook ajoutée.
- `BLM_ENGAGED.lua`, `BLM_IDLE.lua` : en-têtes qui décrivaient des modes
  inexistants (EngagedMode DT/Enspell, dual wield NIN…) remplacés par le vrai
  contenu (armes, ville, mouvement, Mana Wall).
- `BLM_MACROBOOK.lua`, `BLM_LOCKSTYLE.lua` : chemins, doc des fonctions exportées.
- `BLM_MOVEMENT.lua` : commentaires-bruit retirés, doc du retour.
- `BLM_PRECAST.lua` : en-tête réécrit (il annonçait Fast Cast, sort Death, etc.,
  que ce fichier ne fait pas) ; doc de `job_precast`.
- `BLM_MIDCAST.lua` : doc des deux hooks.
- `BLM_COMMANDS.lua` : en-tête complété (klima, dispel, nukes, verrou CombatMode) ;
  liste des commandes dans la doc de `job_self_command` complétée (dispel, storm) ;
  séparateur manquant rétabli ; commentaire « cycle Aja » corrigé. **Code :**
  suppression d'un `local ScholarActions = require(...)` redondant dans la branche
  `dispel` (la même variable de module est déjà chargée par
  `ensure_commands_loaded()` juste avant, `require` est en cache → même objet).
- `blm_functions.lua` : en-tête et référence des modules corrigés (set_builder
  n'est pas chargé « au premier SaveMP() » mais par IDLE/ENGAGED ; SaveMP n'a aucun
  appelant) ; doc de `SaveMP` rendue honnête (elle réécrit le set sur lui-même car
  `blm_dynamic_sets` n'existe nulle part) ; `@return` ajoutés.
- `logic/set_builder.lua` : en-tête réécrit (pas de HybridMode ni de mouvement en
  engaged) ; famille SaveMP signalée comme sans appelant ; doc complétée.
- `logic/midcast_router.lua` : description des handlers corrigée (Burn/Frost ne
  sont pas de l'Enfeebling) ; `@param` ajoutés.
- `logic/elemental_matcher.lua`, `logic/buff_manager.lua` : chemins, doc de retour.
- `logic/spell_refiner.lua` : numéro de ligne périmé retiré, « job_midcast » retiré
  (seul job_precast appelle).
- `logic/refiner/timing_guards.lua` : « deux limiteurs » → trois ; API complétée
  (`is_announce_safe`, `update_announce_time`).
- `logic/refiner/replacement_logic.lua` : note historique hors sujet retirée,
  commentaire « Original logic » retiré.
- `logic/refiner/{correspondence,recast_display,special_handlers}.lua` : chemins.
- `logic/storm_manager.lua` : commentaire « Extracted from… » retiré ;
  « show both recasts » corrigé (un seul recast affiché).

### BRD
- `BRD_BUFFS.lua`, `BRD_STATUS.lua` : même correction que BLM.
- `BRD_AFTERCAST.lua` : en-tête réécrit (watchdog, Pianissimo, verrou instrument).
- `BRD_ENGAGED.lua`, `BRD_IDLE.lua` : en-têtes réécrits (Kraken Club → PDTKC,
  EngagedMode/IdleMode, armes, mouvement).
- `BRD_MACROBOOK.lua`, `BRD_LOCKSTYLE.lua` : chemins, doc.
- `BRD_MOVEMENT.lua` : commentaire « NE PAS exporter, ne doit pas être enregistré »
  corrigé : la déclaration `function job_handle_equipping_gear` crée déjà une
  globale, donc le hook EST enregistré (voir Bugs) ; commentaire orphelin final
  retiré.
- `BRD_PRECAST.lua` : en-tête réécrit ; les deux « Extracted from… » remplacés par
  une vraie description ; doc de `job_precast`. **Code :** suppression d'un
  `if buffactive['Nightingale'] and spell.skill == 'Singing' then end` vide
  (lecture de table sans effet de bord, déjà listé comme mort dans
  `docs/dev/jobs/brd.md`).
- `BRD_MIDCAST.lua` : doc des trois hooks.
- `BRD_COMMANDS.lua` : en-tête qui listait 8 commandes inexistantes (refresh, tank,
  healer…) corrigé ; promesses de « downgrade » fausses retirées ; commandes
  forceidle/debugmidcast mentionnées ; commentaires de `forceidle` corrigés (pas de
  « multiples essais », pas d'appelant) ; références BRD_MIDCAST → midcast_router.
- `brd_functions.lua` : liste des modules logiques complétée.
- `logic/set_builder.lua` : en-tête et commentaires d'étapes corrigés.
- `logic/instrument_lock_config.lua` : chaque étape du verrou rattachée à son
  fichier.
- `logic/song_refinement.lua` : en-tête précisé (familles concernées, config).
- `logic/midcast_router.lua` : « Composure target » (capacité RDM) remplacé par la
  vraie règle soi/autre ; `@param` ajoutés.
- `logic/song_rotation_manager.lua` : `use_marcato` documenté comme non utilisé ;
  commentaire « Marcato handled in cast_song helper » (helper inexistant) corrigé.
  **Code :** suppression de `local marcato_used = false`, jamais lu.

### BST
- `BST_BUFFS.lua`, `BST_STATUS.lua` : même correction que BLM.
- `BST_ENGAGED.lua`, `BST_IDLE.lua` : en-têtes réécrits (maître/familier/les deux,
  PDT, armes, MoveSpeed, pieds en ville).
- `BST_MACROBOOK.lua`, `BST_LOCKSTYLE.lua` : chemins, alignement des commentaires
  d'arguments, doc.
- `BST_MOVEMENT.lua` : en-tête contradictoire (« Registers with AutoMove » puis
  « no registration needed ») et note historique retirés.
- `BST_PRECAST.lua` : commentaire « Toggle: //gs c debugbst » corrigé en
  `debugprecast` (la vraie commande) ; doc de `job_precast`.
- `BST_MIDCAST.lua` : séparateur d'en-tête manquant ; « Gleti's Breeches » remplacé
  par « set Sic » (le code équipe `sets.precast.JA.Sic`) ; commentaire parasite
  « Healing Magic » retiré.
- `BST_AFTERCAST.lua` : en-tête réécrit ; commentaires périmés retirés
  (« unlock au début du midcast » : aucun verrou n'existe). **Code :** suppression
  de la fonction locale `monitor_pet_after_command` (0 appel, ni dans le fichier ni
  ailleurs). Le `require` de `pet_manager` est gardé tel quel.
- `BST_PET_PRECAST.lua` : en-tête dit maintenant la vérité : aucun événement
  `pet_precast` n'existe (ni moteur ni Mote), le hook ne tourne jamais.
- `BST_PET_MIDCAST.lua` : **Code :** suppression de la fonction locale de debug
  `show_equipment_pet_mid` (0 appel). Commentaire précisé : Mote lance ensuite
  `default_pet_midcast`.
- `BST_COMMANDS.lua` : en-tête complété ; commentaires « BLOCK background
  auto-engage » corrigés (le drapeau n'est lu nulle part, voir Bugs).
- `bst_functions.lua` : description des modules logiques corrigée.
- `logic/pet_manager.lua` : durées de cache fausses (0.1 s/5 s) corrigées
  (1.0 s / 0.5 s / 30 s) ; « spam de gs c update » corrigé ; `@return` de
  `monitor_pet_status` corrigé (il renvoie true/false/nil, pas void).
- `logic/set_builder.lua` : doc des deux builders et de `with_pdt`.
- `logic/ecosystem_manager.lua` : en-tête et doc `@param/@return` ; `cycle_ammo`
  signalé sans appelant ; « appelé dans job_setup » → appelé par l'entrée BST.
- `logic/ready_move_categorizer.lua` : doc de `get_midcast_set_name` corrigée ;
  note sur l'écrasement des globales `pet*Moves` des fichiers de sets.

### COR
- `COR_BUFFS.lua` : description corrigée (Doom + retrait d'un roll expiré).
- `COR_STATUS.lua` : même correction que BLM.
- `COR_AFTERCAST.lua` : en-tête réécrit (watchdog + ouverture de pochette de
  balles) ; commentaires périmés retirés.
- `COR_ENGAGED.lua`, `COR_IDLE.lua` : en-têtes réécrits (PDT, DW /NIN-/DNC,
  RangeWeapon, Refresh < 50 % MP).
- `COR_MACROBOOK.lua`, `COR_LOCKSTYLE.lua` : chemins, alignement, doc.
- `COR_MOVEMENT.lua` : commentaires-bruit retirés.
- `COR_MIDCAST.lua` : séparateur d'en-tête ; Enfeebling ajouté à la liste.
- `COR_PRECAST.lua` : en-tête réécrit (il décrivait une validation TP et un
  « TPBonusCalculator » qui ne sont pas là, et un ordre faux) ; deux « Extracted
  from… » remplacés par une vraie doc ; note d'historique retirée ; doc des hooks.
- `COR_COMMANDS.lua` : liste des commandes ajoutée dans l'en-tête ; « groups of
  10 » corrigé (la boucle teste 1 à 255).
- `cor_functions.lua` : `party_tracker` ajouté à la liste des modules logiques.
- `logic/party_tracker.lua` : `@module` → `@file` ; commentaire « Legacy… v1.x »
  faux (l'id est toujours utilisé) corrigé ; `_G.cor_pending_roll_*` signalés
  comme jamais posés ; doc de retour.
- `logic/roll_tracker.lua` : en-tête corrigé (la détection est dans party_tracker ;
  le Tricorne n'est PAS compté, contrairement à ce qu'il disait) ; deux
  commentaires « calculé seulement au premier roll » contredits par le code
  (« recompté à chaque cast ») corrigés ; `@param is_new_roll` ajouté.
- `logic/roll_data.lua` : chemin ; `player_job` documenté comme non lu.
- `logic/set_builder.lua` : en-tête complété ; justification inventée sur le DW
  /NIN remplacée par un constat factuel.

## Bugs suspectés

Non corrigés (changer le comportement était interdit). Les points marqués
« (connu) » figurent déjà dans `docs/dev/jobs/<job>.md`.

1. **`shared/jobs/bst/functions/BST_COMMANDS.lua:435 et 457`** —
   `_G.bst_rdymove_active` est posé pour « bloquer l'auto-engage en arrière-plan »,
   mais **aucun fichier ne le lit** (grep sur `shared/`, `_master/`, `Tetsouo/`,
   `Kaories/`). Pourquoi c'est important : pendant la séquence `rdymove`, le
   moniteur peut renvoyer « Fight » en même temps. Correctif : tester le drapeau
   dans le moniteur de l'entrée BST, ou supprimer le drapeau.
2. **`shared/jobs/bst/functions/BST_MIDCAST.lua:48`** (connu) — si le
   catégoriseur ne charge pas, appel à `MessageFormatter.error_bst_module_not_loaded`,
   fonction qui n'existe pas → erreur, et `modules_loaded` ne passe jamais à true.
   Correctif : `show_error_module_not_loaded` avec garde `if MessageFormatter`.
3. **`shared/jobs/brd/functions/BRD_PRECAST.lua:218 et 250`** —
   `SongRefinement.refine_song` et `InstrumentLockConfig.requires_lock` sont
   appelés sans vérifier que le `pcall(require)` a réussi. Si l'un échoue, chaque
   chanson lève une erreur en precast. Même chose pour `MessageFormatter` dans le
   chemin Pianissimo/Marcato. Correctif : `if SongRefinement and ...`.
4. **`shared/jobs/brd/functions/BRD_AFTERCAST.lua:54`** — si le `pcall(require)`
   du formatter échoue, `MessageFormatter.show_instrument_released` est appelé sur
   `nil`. Correctif : garde `if MessageFormatter then`.
5. **`shared/jobs/brd/functions/BRD_MOVEMENT.lua:39`** (connu) —
   `job_handle_equipping_gear` est bien enregistré (déclaration globale), alors que
   le commentaire d'origine disait qu'il perturbe le « warp ring fix ». Correctif :
   décider — soit le rendre `local`, soit accepter l'enregistrement.
6. **`shared/jobs/bst/functions/BST_PET_PRECAST.lua`** — `job_pet_precast` n'est
   jamais appelé : GearSwap n'a pas d'événement `pet_precast` (vérifié dans
   `triggers.lua`, `flow.lua`, `libs/Mote-Include.lua`). Sans conséquence en jeu
   (BST_PRECAST équipe le set Sic lui-même) mais trompeur. Correctif : supprimer
   le fichier et son `include` (déjà noté pour PUP).
7. **`shared/jobs/blm/functions/logic/elemental_matcher.lua:23-43`** (connu) —
   Obi jamais déclenché pour la foudre (nom `Thunder` vs `Lightning`) ni sous
   Aurorastorm/Voidstorm.
8. **`shared/jobs/blm/functions/logic/refiner/replacement_logic.lua:126`** (connu) —
   `should_cancel` ne peut jamais être vrai (`replacement` vaut nil ou un nom de
   sort, jamais `''`).
9. **`shared/jobs/blm/functions/BLM_COMMANDS.lua:546`** (connu) — le verrou
   d'armes CombatMode survit au reload/changement de job alors que l'état revient
   à Off.
10. **`shared/jobs/cor/functions/COR_PRECAST.lua` (job_post_precast)** (connu) —
    `LuzafRing = OFF` n'est pas appliqué à Double-Up (le test porte sur
    `spell.type == 'CorsairRoll'`).
11. **`shared/jobs/blm/functions/logic/storm_manager.lua:151`** et
    **`BRD_PRECAST.lua:195`** — chaînes `input …; wait N; input /ma …` : le
    projet dit les avoir éliminées (CODE_QUALITY §16, compteur à 0). Si la
    première action est refusée, la seconde part quand même. Correctif :
    `AbilityHelper.follow_up` comme pour checkArts.
12. **`shared/jobs/cor/functions/logic/roll_tracker.lua:755`** — `cleanup()`
    remplace la table `_G.cor_last_roll` alors que `record_last_roll` explique
    qu'il ne faut jamais la remplacer (d'autres modules en gardent la référence).
    Impact faible (à l'unload seulement).

## Doutes / à décider

- **En-têtes sans date de création** : 16 fichiers (`*_BUFFS`, `*_STATUS`,
  `*_ENGAGED`, `*_IDLE` des 4 jobs), plus `blm/logic/spell_refiner.lua`
  (« Migrated ») et `cor/logic/set_builder.lua`, n'ont qu'une date « Updated ».
  L'historique git commence au 2025-11-03 (import initial), donc la vraie date
  est inconnue : je n'en ai pas inventé. À décider : mettre « Created: inconnue »
  ou la date du premier commit.
- **`shared/jobs/bst/functions/BST_PRECAST.lua:121`** vs
  **`BST_AFTERCAST.lua:56`** : le precast dit que les champs posés sur `spell`
  (`ready_move_category`, `bst_is_ready_move`) servent au midcast ; l'aftercast dit
  que ces champs « ne persistent pas » et recalcule. Les deux ne peuvent pas être
  vrais pour le même objet `spell` : à vérifier en jeu (`debugprecast`). Si les
  champs ne persistent pas, les tests de BST_MIDCAST sur ces champs sont morts.
- **`shared/jobs/bst/functions/logic/ready_move_categorizer.lua` (fin)** : le
  module écrase `_G.petPhysicalMoves`, etc., que les fichiers de sets
  (`Tetsouo/sets/bst/bst_sets.lua:72`, `_master/sets/bst_sets.lua:251`) définissent
  aussi. Les listes des fichiers de sets sont donc ignorées. Laquelle doit faire
  foi ?
- **`shared/jobs/bst/functions/BST_AFTERCAST.lua`** et **`BST_PET_MIDCAST.lua`** :
  les locaux `PetManager` / `ReadyMoveCategorizer` ne sont plus lus après la
  suppression des helpers morts. Je les ai laissés pour ne pas changer l'ordre de
  chargement des modules ; ils peuvent partir si on accepte ce décalage.
- **`shared/jobs/brd/functions/logic/set_builder.lua:175`** : le mouvement est
  ajouté au set **engagé** (« BRD can move while singing »). Voulu ?
- **`shared/jobs/cor/functions/logic/roll_tracker.lua` et `party_tracker.lua:81`** :
  repli « ids 98-192 = Phantom Roll » quand les ressources ne répondent pas —
  déjà noté comme faiblesse dans la mémoire du projet.

## Code mort probable

Preuve : grep sur `shared/`, `_master/`, `Tetsouo/`, `Kaories/` (hors
`global_probe.lua`, qui ne fait que lister des noms). « 0 appel » = seule la
définition apparaît.

BLM
- `SetBuilder.get_dynamic_elemental_set`, `.validate_dynamic_sets`,
  `.get_mp_status`, `.get_recommended_set_name`, `.update_mp_threshold`,
  `.get_mp_threshold`, `.apply_buff_gear`, `.apply_all_buff_sets`
  (`blm/functions/logic/set_builder.lua`) : 0 appel externe.
- `SaveMP` (global, `blm_functions.lua`) et `SetBuilder.SaveMP` : aucun appelant ;
  `blm_dynamic_sets` n'est défini nulle part.
- `StormManager.cast_storm_only` : 0 appel.
- `ElementalMatcher.get_spell_element_name` : 0 appel.
- `get_blm_movement_status` (`BLM_MOVEMENT.lua:20`) : 0 appel.
- Branche `cycle TierSpell` (`BLM_COMMANDS.lua`) : déjà listée morte dans la doc.

BRD
- `InstrumentLockConfig.get_all_locked_songs` : 0 appel.
- `SongRefinement.get_downgrade`, `SongRefinement.is_enabled` : 0 appel.
- `get_brd_movement_status` (`BRD_MOVEMENT.lua:20`) : 0 appel.
- `job_customize_midcast_set` (`BRD_MIDCAST.lua`) : exporté, jamais appelé (doc).
- Commande `forceidle` : aucun `gs c forceidle` émis dans le projet.

BST
- `job_pet_precast` (fichier `BST_PET_PRECAST.lua` entier) : aucun événement ne
  l'appelle.
- `EcosystemManager.cycle_ammo` : 0 appel.
- `ReadyMoveCategorizer.is_physical`, `.is_magical`, `.get_midcast_set_name`,
  `.get_category_counts` : 0 appel.
- `SetBuilder.should_use_pet_sets`, `.is_pet_engaged`, `.get_current_mode`
  (`bst/logic/set_builder.lua`) : 0 appel.
- `PetManager.is_pet_valid`, `PetManager.get_pet_status` : 0 appel.
  `PetManager.monitor_pet_status` / `check_and_engage_pet` ne sont appelés que par
  le template `_master/entry/Tetsouo_BST.lua:334,338` (pas par le live).
- `_G.bst_rdymove_active` : écrit, jamais lu.

COR
- `job_post_aftercast` (`COR_AFTERCAST.lua`, vide).
- `get_cor_movement_status` (`COR_MOVEMENT.lua:20`) : 0 appel.
- `SetBuilder.apply_buff_gear` (`cor/logic/set_builder.lua`) : 0 appel.
- `RollTracker.has_job_bonus_proc_gear` : 0 appel.
- `RollData.get_roll_names` : 0 appel.
- `RollTracker.clear_natural_eleven` / `clear_last_roll` : appelés seulement par
  `clear_all`.
- `_G.cor_natural_eleven_active` : écrit (4 endroits), jamais lu.
- `_G.cor_pending_roll_value` / `_timestamp` : seulement remis à nil
  (`party_tracker.lua`, entrées COR), jamais posés.

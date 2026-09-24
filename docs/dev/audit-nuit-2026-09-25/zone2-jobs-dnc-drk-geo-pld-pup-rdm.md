# Audit de nuit 2026-09-25 — Zone 2 : jobs DNC, DRK, GEO, PLD, PUP, RDM

Périmètre : `shared/jobs/{dnc,drk,geo,pld,pup,rdm}/**` (88 fichiers `.lua`
modifiés sur 89). Rien n'a été commité.

Ce qui a été touché : les commentaires, les en-têtes et la doc des fonctions.
Il y a un seul changement de code. Quatre façades et un set builder
chargeaient un module dans une variable qui ne servait jamais
(`local DualBoxManager = require(...)`, et `MessageFormatter` dans
`pld/logic/set_builder`). La variable a été retirée, mais le `require(...)`
reste : le module se charge exactement comme avant.

Vérifications faites sur tous les fichiers :
- `lua5.1 loadfile` passe partout ;
- la fin de ligne d'origine (LF ou CRLF) est conservée dans chaque fichier, comparé à la sauvegarde ;
- hors commentaires, le code diffère de la sauvegarde sur ces seules lignes `require`.

Pour GEO et PLD, le bytecode compilé est en plus identique, aux lignes près.

Attention pour les autres zones : la plupart de ces fichiers sont en **LF**,
pas en CRLF. Sous Git Bash, `grep -c $'\r$'` compte toutes les lignes, CR ou
non, donc ce test ne distingue rien. Il faut vérifier avec
`git ls-files --eol` ou en Python.

## Fait

### DNC
- `dnc_functions.lua` : l'en-tête annonçait 6 modules logiques, il y en a 5.
  `jump_manager` est retiré de la liste, AutoJump est situé dans
  `shared/utils/drg/`. Commentaires d'`include` corrigés, variable locale inutilisée retirée.
- `DNC_PRECAST.lua` : l'en-tête décrivait du Fast Cast, des portées 6y/15y,
  des délais et TPBonusCalculator, rien de cela n'existe dans le code. Réécrit
  d'après le vrai code, doc ajoutée sur `refine_waltz` et `job_precast_weaponskill`.
- `DNC_MIDCAST.lua` : fonctions inventées retirées de l'en-tête, commentaire Utsusemi clarifié.
- `DNC_AFTERCAST.lua` : en-tête réécrit (le fichier ne fait que prévenir le watchdog).
- `DNC_IDLE.lua` / `DNC_ENGAGED.lua` : en-têtes copiés d'un autre job
  (IdleMode « DT », Enspell, dual wield NIN), réécrits.
- `DNC_STATUS.lua` / `DNC_BUFFS.lua` : `@date Created` ajouté.
- `DNC_COMMANDS.lua` : `@file` corrigé, séparateur rétabli.
- `DNC_MOVEMENT.lua` : l'en-tête annonçait un arrêt automatique de Haste Samba
  et des Skadi's, qui n'existent pas. Réécrit.
- `DNC_LOCKSTYLE.lua` / `DNC_MACROBOOK.lua` : chemins corrigés, doc des fonctions exportées.
- `logic/climactic_manager.lua` : le TP minimum vient de DNCWSConfig (pas un
  1000 fixe) et le WS repart dès que le buff apparaît (pas après 1 s). En-tête corrigé.
- `logic/step_manager.lua` : touches corrigées (Ctrl+Numpad3/4/5, et non Alt+3/4/5).
- `logic/set_builder.lua`, `ws_variant_selector.lua`, `smartbuff_manager.lua` :
  chemins corrigés, commentaires de debug morts retirés.

### DRK
- `drk_functions.lua` : liste des modules logiques remplie (elle disait « to
  be added »), variable locale inutilisée retirée.
- `DRK_PRECAST.lua` : en-tête complété (flags pending, JA, Fast Cast).
- `DRK_MIDCAST.lua` : `@param` ajoutés, titre « DARK MAGIC » erroné retiré, commentaire d'historique retiré.
- `DRK_AFTERCAST.lua` : l'en-tête reprenait un texte de WAR, réécrit.
- `DRK_IDLE.lua` / `DRK_ENGAGED.lua` : en-têtes d'un autre job, réécrits.
- `DRK_STATUS.lua` / `DRK_BUFFS.lua` : l'en-tête de BUFFS parlait de
  « Chainspell », remplacé par son vrai rôle. `@date` ajouté.
- `DRK_COMMANDS.lua` : liste des commandes rendue exacte.
- `DRK_MOVEMENT.lua` : le commentaire décrit maintenant le vrai fonctionnement
  (AutoMove règle `state.Moving`, le set builder ajoute MoveSpeed).
- `DRK_LOCKSTYLE.lua` / `DRK_MACROBOOK.lua` : mêmes corrections que pour DNC.
- `logic/drk_buff_anticipation.lua` : l'étape « le flag est effacé » était
  fausse : il l'est quand le buff tombe, dans DRK_BUFFS. Corrigé.
- `logic/set_builder.lua` : chemin et appelants corrigés.

### GEO
- `GEO_STATUS.lua` / `GEO_BUFFS.lua` : descriptions fausses (Chainspell)
  corrigées, `@date` et `@param` ajoutés.
- `GEO_MOVEMENT.lua`, `GEO_MACROBOOK.lua`, `GEO_LOCKSTYLE.lua` : chemins corrigés, doc `@return`.
- `GEO_IDLE.lua` / `GEO_ENGAGED.lua` : modes inexistants retirés, la vraie logique (luopan, HybridMode) est décrite.
- `GEO_AFTERCAST.lua` / `GEO_COMMANDS.lua` (modifiés aujourd'hui) : **en-tête
  et doc seulement**, aucune ligne de code touchée.
- `GEO_PRECAST.lua` : l'en-tête disait que ce fichier équipe le Fast Cast,
  alors que c'est Mote qui le fait. Réécrit. Commentaire Entrust explicité.
- `GEO_MIDCAST.lua` : chemin et `@param action` corrigés.
- `geo_functions.lua` : sections remises en ordre, variable locale inutilisée retirée.
- `logic/set_builder.lua`, `logic/geo_spell_refiner.lua` : commentaires
  « Idris/Genmei » retirés (les armes viennent des states), bruit retiré.

### PLD
- `PLD_STATUS.lua` / `PLD_BUFFS.lua` : descriptions corrigées, `@date` ajouté.
- `PLD_AFTERCAST.lua` : en-tête standard ajouté (il n'en avait aucun).
- `PLD_MOVEMENT.lua` : ligne de commentaire en double retirée, chemins corrigés.
- `PLD_MACROBOOK.lua` / `PLD_LOCKSTYLE.lua` : chemins, doc `@return`.
- `PLD_IDLE.lua` / `PLD_ENGAGED.lua` : modes inexistants retirés.
- `PLD_PRECAST.lua` : chemin et `@param` corrigés, `@return void` retiré.
- `PLD_MIDCAST.lua` : description de Phalanx corrigée (set SIRD), EnmityOverride ajouté à la liste.
- `PLD_COMMANDS.lua` : l'ordre réel du routeur est documenté, ainsi que les
  commandes ws/ws1/ws2 et le hook d'état.
- `pld_functions.lua` : descriptions des modules logiques corrigées
  (aoe_manager n'a ni ciblage auto ni montée de tier, cure_set_builder n'a
  pas de seuils de HP). Variable locale inutilisée retirée.
- `logic/set_builder.lua` : « requirement requirement » corrigé, priorités
  documentées. La variable `MessageFormatter` inutilisée est retirée, le
  `require` reste.
- `logic/aoe_manager.lua`, `cure_set_builder.lua`, `rune_manager.lua` :
  commentaires rendus exacts (repli `<stnpc>`, effet de bord sur `sets.midcast.Cure`).

### RDM
- `RDM_AFTERCAST.lua` / `RDM_BUFFS.lua` / `RDM_STATUS.lua` : en-têtes faux
  (« Doom, Chainspell »), ils décrivent maintenant LifecycleManager.
- `RDM_IDLE.lua` / `RDM_ENGAGED.lua` : modes corrigés d'après RDM_STATES
  (Engaged = DT/Acc/TP/Enspell, Idle = Refresh/DT).
- `RDM_MOVEMENT.lua`, `RDM_MACROBOOK.lua`, `RDM_LOCKSTYLE.lua` : chemins corrigés, doc ajoutée.
- `rdm_functions.lua` : ordre de chargement décrit corrigé, variable locale inutilisée retirée.
- `RDM_PRECAST.lua` : en-tête réécrit d'après les vraies étapes. Deux blocs
  de doc étaient sur la mauvaise fonction, remis en place. La persistance du
  debug passe par `windower._gs_debug`, c'est maintenant écrit.
- `RDM_MIDCAST.lua` : en-tête réécrit (« mnd_potency.Valeur », « NEW v6.2 »
  étaient faux), doc orpheline rattachée, commentaire expliquant que
  `midcast_subjob` n'est jamais atteint.
- `RDM_COMMANDS.lua` : 3 lignes de code mort **commentées** supprimées. La
  cible par défaut de l'exemple est `<me>` (il disait `<stpc>`).
- `logic/set_builder.lua` : le commentaire « RDM doesn't use sets.Adoulin »
  était faux, corrigé. Noms d'armes périmés retirés.

### PUP
- `PUP_AFTERCAST`, `BUFFS`, `STATUS`, `MACROBOOK`, `LOCKSTYLE`, `MOVEMENT` : chemins et en-têtes corrigés.
- `PUP_IDLE.lua` / `PUP_ENGAGED.lua` : en-têtes copiés de RDM, remplacés par
  une note qui signale que `logic/set_builder` n'existe pas.
- `pup_functions.lua` : les modules `logic/` et les configs absents sont
  signalés, variable locale inutilisée retirée.
- `PUP_PRECAST.lua`, `PUP_PET_PRECAST.lua`, `PUP_PET_MIDCAST.lua` : les
  descriptions parlaient de Deploy, Repair, Maneuvers. Le code est en fait
  celui de BST (Call Beast, Reward, Ready), c'est maintenant écrit.
- `PUP_MIDCAST.lua` / `PUP_COMMANDS.lua` : en-têtes réécrits avec la note sur le crash connu, `@param` ajoutés.

## Bugs suspectés

1. **`rdm/functions/RDM_COMMANDS.lua:50-55` — le lancement par nom ne marche probablement jamais.**
   - **Quoi** : `resolve_action_prefix` lit la variable globale `res`.
   - **Pourquoi** : l'environnement que GearSwap donne au job (`GearSwap/refresh.lua:114-146`) ne contient pas `res`, et aucun fichier du projet ne le crée en global.
   - **Conséquence** : la fonction renvoie toujours nil, et une touche qui lance « Refresh II » par son nom affiche sans doute « Command not recognized ».
   - **Correctif suggéré** : `local res = rawget(_G,'res') or windower.res or require('resources')`, comme dans BLM `spell_refiner.lua`.
   - **À tester en jeu avant de corriger.**
2. **`dnc/functions/logic/set_builder.lua` (~112-118, `apply_weapon`) — un set global est modifié en place.**
   - **Quoi** : si `sets[state.MainWeapon.current]` n'existe pas, `result.sub = ...` écrit directement dans le set global (engaged ou idle).
   - **Conséquence** : la modification reste jusqu'au prochain reload.
   - **Correctif** : `result = set_combine(result, {sub = ...})`.
3. **`dnc/functions/logic/climactic_manager.lua:29` — plantage si la config WS manque.**
   - **Quoi** : si `_G.DNCWSConfig` est absent, `player.tp >= nil` plante.
   - **Conséquence** : chaque précast de WS DNC plante.
   - **Correctif** : sortir tôt quand `min_tp` est nil.
4. **`drk/functions/DRK_STATUS.lua` (~22-27) — appel sur nil.**
   - **Quoi** : si le `pcall(require)` de doom_manager échoue, le code appelle quand même une fonction sur nil.
   - **Correctif** : ajouter une garde `if DoomManager then`.
5. **`geo/functions/logic/set_builder.lua:107-117` — lecture sans vérification.**
   - **Quoi** : `sets.luopan.engaged.DT` est lu sans vérifier que `sets.luopan.engaged` existe.
   - **Risque** : faible, les sets actuels la définissent.
6. **`geo/functions/GEO_MIDCAST.lua` (midcast_geomancy) — module peut-être absent.**
   - **Quoi** : `MessageFormatter.show_indi_cast` est appelé sans test, alors que le module est chargé par `pcall`.
   - **Risque** : très faible.
7. **`drk/functions/DRK_MIDCAST.lua` — overlay Dark Seal / Nether Void.**
   - **Quoi** : il lit seulement `buffactive`, jamais les flags pending, alors que ces flags existent pour un sort lancé juste après le JA.
   - **À décider** : corriger changerait le comportement.
8. **`rdm/functions/RDM_MIDCAST.lua:362` — `midcast_subjob` n'est jamais atteint.**
   - **Pourquoi** : `spell.type == 'Magic'` n'est jamais vrai.
   - Déjà dans la doc, toujours présent.
9. **PUP — le job ne peut pas tourner (connu).**
   - **Fonctions manquantes** : 14 fonctions MessageFormatter appelées n'existent pas (5 `error_pup_*`, 9 `show_pup_*`).
   - **Modules manquants** : `logic/set_builder`, `ready_move_categorizer`, `ecosystem_manager` et `pet_manager` sont absents.
   - Rien n'a été corrigé.

## Doutes / à décider

- `docs/dev/jobs/drk.md` (Known issues) : « pending flags are never cleared »
  est périmé. `DRK_BUFFS.lua:36-48` remet les flags à false quand le buff tombe.
- `docs/dev/jobs/geo.md` : « entrust lance l'Indi même si Entrust est refusé »
  est périmé. `follow_up_or_abort` est utilisé (`GEO_COMMANDS.lua:258-267`).
- `docs/dev/jobs/pld.md` : les points PLD_MOVEMENT (ligne en double),
  PLD_AFTERCAST (sans en-tête) et PLD_IDLE/ENGAGED:4 sont corrigés par cet
  audit. La doc est à mettre à jour.
- `PLD_COMMANDS.lua:91-93` : la branche Watchdog ne pose pas
  `eventArgs.handled`, alors que GEO le fait. À harmoniser ?
- `GEO_COMMANDS.lua:367` : `try_aoe_subcommand(cmdParams[2], nil)` ne passe
  pas de state SneakInviAOE, contrairement à PLD. Voulu ?
- `RDM_PRECAST.lua:268` : l'ordre suivi est Guard >> Cooldown >> logique du
  job (Phalanx, Saboteur) >> WS, alors que CODE_QUALITY §4.1 place le WS
  avant la logique du job. Faut-il documenter cette exception ?
- `RDM_MIDCAST.lua:139` : l'affirmation « +5 potency Lethargy Gants +3 », non
  vérifiable, a été retirée. À remettre si elle était voulue.
- `DRK_MIDCAST.lua:~68-80` : les valeurs de jeu citées (« Dark Seal +10% »,
  « Nether Void +45% ») ne sont pas vérifiées. Laissées telles quelles.
- `DRK_ENGAGED.lua` ignore le meleeSet de Mote : un mode Mote ajouté plus tard n'aurait aucun effet.
- **Dates `@date Created` ajoutées, approximatives** : 2025-10-04 (DNC),
  2025-10-23 (DRK), 2025-10-09 (GEO_IDLE/ENGAGED), 2025-11-03 (premier commit
  git) pour GEO_STATUS/BUFFS et PLD_STATUS/BUFFS/AFTERCAST. Côté RDM/PUP,
  aucune date n'a été inventée : ils gardent seulement leur « Updated ».

## Code mort probable

- `get_dnc_movement_status` (`DNC_MOVEMENT.lua:28`) et
  `get_geo_movement_status` (`GEO_MOVEMENT.lua:20`) : exportés en global, mais
  grep sur tout `data/` (dossiers personnages compris) ne les trouve que dans
  `shared/utils/debug/global_probe.lua:103`, une liste de noms. Aucun appelant.
- `SetBuilder.apply_buff_gear` (`geo/functions/logic/set_builder.lua:166`) :
  aucun appel côté GEO. Seul BLM appelle sa propre version.
- `job_post_aftercast` vide (`DRK_AFTERCAST.lua`, `PLD_AFTERCAST.lua`) :
  appelé par Mote, mais ne fait rien.
- `DRK_MOVEMENT.lua`, `PLD_MOVEMENT.lua` : aucun code, seulement des commentaires.
  Gardés pour respecter l'architecture à 12 modules.
- `DRKBuffAnticipation` chargé dans `DRK_AFTERCAST.lua:20-32` mais jamais lu
  dans ce fichier. Son vrai utilisateur est `logic/set_builder.lua:31`.
  Laissé, car le retirer changerait le moment du chargement.
- `job_pet_precast` (`PUP_PET_PRECAST.lua`) : Mote ne l'appelle pas
  (`libs/Mote-Include.lua` ne connaît que les hooks `pet_midcast`).
- `midcast_subjob` (`RDM_MIDCAST.lua`) : inatteignable (bug 8).
- Toujours vrai, déjà dans la doc :
  - `CombatWeaponMode` ;
  - `DNCStates.validate` et `DRKStates.validate` ;
  - l'include `message_buffs` dans `drk_functions.lua:29` ;
  - `check_off` de `castenspell` (RDM) ;
  - `sets.precast['Cure'/'Flash']` et `cooldown_exclusions` (PLD_PRECAST).

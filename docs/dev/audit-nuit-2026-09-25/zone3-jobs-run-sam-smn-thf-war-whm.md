# Audit de nuit 2026-09-25 — Zone 3 : jobs RUN, SAM, SMN, THF, WAR, WHM

Périmètre : `shared/jobs/{run,sam,smn,thf,war,whm}/**` (90 fichiers `.lua`,
80 modifiés). Rien n'a été commité.

Ce qui a été touché : les commentaires, les en-têtes et la doc des fonctions.
Deux changements de code, tous deux sans effet sur le comportement :

1. `RUN_PRECAST.lua` : la table `auto_abilities` était vide et la boucle qui la
   lisait ne pouvait donc jamais rien faire. Les deux ont été retirés.
2. Les six façades (`*_functions.lua`) chargeaient `dualbox_manager` dans une
   variable locale jamais lue (`local DualBoxManager = require(...)`). La
   variable est retirée, le `require(...)` reste : le module se charge
   exactement comme avant (même traitement que la zone 2).

Vérifications faites sur les 90 fichiers :
- `lua5.1 loadfile` passe partout ;
- la fin de ligne d'origine (LF ou CRLF) et l'encodage sont conservés, comparé
  à la sauvegarde ;
- comparaison jeton par jeton avec la sauvegarde, commentaires exclus : le code
  ne diffère que sur les deux points ci-dessus.

Aucun nom de fonction, global, champ de module, état, clé de message ou
commande `gs c` n'a été renommé. Aucun texte affiché au joueur n'a changé.

## Fait

Chemins `@file` : partout où ils étaient faux ou incomplets (`jobs/...`,
`utils/...`, nom de fichier seul, et même `pld_functions.lua` dans la façade
RUN), ils donnent maintenant le chemin complet `shared/jobs/...`, et
`@requires` pointe vers `shared/utils/...`. Ce n'est pas répété fichier par
fichier ci-dessous.

Beaucoup d'en-têtes IDLE/ENGAGED/BUFFS/STATUS étaient copiés d'un autre job
(« IdleMode DT/Refresh/Regain/Evasion », « EngagedMode Enspell », « dual wield
NIN », « Chainspell »). Ils sont réécrits d'après ce que fait vraiment le set
builder du job.

### RUN
- `run_functions.lua` : `@file` disait `pld_functions.lua`. La liste des
  modules logiques décrivait des choses inexistantes (escalade de tier AOE,
  seuils de PV et Light Arts pour les Cures, « auto-application » des runes).
  Réécrite. Variable `DualBoxManager` inutilisée retirée.
- `RUN_PRECAST.lua` : table/boucle `auto_abilities` mortes retirées. Ajout d'un
  commentaire « pourquoi » : l'entrée ne charge pas `RUN_TP_CONFIG`, donc
  aucun bonus de TP n'est calculé. Doc de `job_post_precast` corrigée.
- `RUN_MIDCAST.lua` : l'en-tête annonçait un « mode XP (SIRD / Potency) » pour
  Phalanx, qui n'existe pas sur RUN. Le commentaire disait que Phalanx « utilise
  toujours SIRD » : c'est en fait le set nommé `sets.midcast.Phalanx` qui est
  pris. Corrigé, doc `@param` ajoutée aux trois fonctions de branche.
- `RUN_AFTERCAST.lua` : il n'avait pas d'en-tête, il en a un.
- `RUN_BUFFS.lua` / `RUN_STATUS.lua` : description réécrite (gestionnaire
  partagé LifecycleManager).
- `RUN_IDLE.lua` / `RUN_ENGAGED.lua` : en-têtes recopiés d'un autre job, réécrits.
- `RUN_MOVEMENT.lua` : bloc de commentaire qui parlait d'une « version
  précédente » remplacé par une description exacte (le fichier ne définit rien).
- `RUN_COMMANDS.lua` : l'ordre de traitement documenté était faux. Le mot
  « RUN/RUN » (impossible) est retiré, un séparateur est rétabli.
- `RUN_LOCKSTYLE.lua` / `RUN_MACROBOOK.lua` : chemins d'en-tête seulement.
- `logic/set_builder.lua` : l'en-tête promettait un « pcall sur set_combine »
  qui n'existe pas, et « sub=empty » pour Lycurgos alors que le slot n'est pas
  vidé. Corrigé.
- `logic/cure_set_builder.lua` : il renvoyait à `pld_sets.lua`. L'effet de bord
  (réécriture de `sets.midcast.Cure`) est maintenant documenté.
- `logic/rune_manager.lua` / `logic/aoe_manager.lua` : en-têtes remis d'accord
  avec le code. Ajout d'un commentaire sur le moment où `_G.BluMagicConfig` est lu.

### SAM
- `sam_functions.lua` : chemin, commentaire trompeur retiré, variable inutilisée retirée.
- `SAM_PRECAST.lua` : un vrai en-tête de description est ajouté. Le rôle du
  drapeau `seigan_cast_attempted` est expliqué, avec `@return` sur les deux helpers.
- `SAM_COMMANDS.lua` : l'en-tête annonçait des commandes `hasso` / `seigan` /
  `thirdeye` qui n'existent pas. Corrigé, commentaire « ajouter ici » vide retiré.
- `SAM_MOVEMENT.lua` : l'en-tête parlait de « suivi de distance » qui
  déclencherait l'équipement de vitesse. Réécrit, doc ajoutée sur le hook vide.
- `SAM_IDLE.lua` / `SAM_ENGAGED.lua` : en-têtes réécrits (couches PV, Seigan,
  AM3, arc).
- `SAM_AFTERCAST.lua`, `SAM_MIDCAST.lua`, `SAM_BUFFS.lua`, `SAM_STATUS.lua` :
  description et chemin corrigés, séparateur ajouté.
- `logic/set_builder.lua` : chemin corrigé. « HP/MP critically low » devient
  « HP < 50% » (le code ne regarde pas les PM).

### SMN
- `smn_functions.lua` : `@file` pointait vers un dossier qui n'existe pas. Variable inutilisée retirée.
- `SMN_PRECAST.lua` : l'en-tête et deux commentaires affirmaient que Mote met
  le set Fast Cast sur les Blood Pacts. C'est faux : aucun set de precast n'est
  trouvé pour eux (docs/dev/jobs/smn.md le confirme). Corrigé, doc ajoutée.
- `SMN_MIDCAST.lua` : l'en-tête « SUMMONING MAGIC » surmontait en fait le
  dispatch de toutes les compétences. Le commentaire de refactor (« Bodies
  unchanged ») est remplacé, `@param` ajoutés.
- `SMN_PET_MIDCAST.lua` : l'en-tête donnait un « pourquoi » invérifiable sur
  l'instant où le jeu lit l'équipement. Il est remplacé par ce que fait le code.
- `SMN_AFTERCAST.lua` : l'en-tête disait que ce hook laisse DoomManager
  déverrouiller les slots, ce qu'il ne fait pas. Corrigé, doc ajoutée.
- `SMN_BUFFS.lua`, `SMN_STATUS.lua`, `SMN_ENGAGED.lua`, `SMN_MOVEMENT.lua` : doc `@param`/`@return` ajoutée.

### THF
- `thf_functions.lua` : il annonçait 3 modules logiques, il y en a 5. L'ordre
  de chargement documenté était faux, et les commentaires d'`include` aussi
  (Fast Cast, TH en precast, « DW tiers », PDT en idle). Tout est corrigé,
  variable inutilisée retirée.
- `THF_PRECAST.lua` : l'en-tête promettait du Fast Cast et un precast pour les
  abilities. C'est Mote qui s'en charge. Corrigé.
- `THF_MIDCAST.lua` : le commentaire sur le « cycle infini » de RangeLock est
  clarifié, séparateur ajouté.
- `THF_AFTERCAST.lua` : l'en-tête citait set_builder, qui n'est pas utilisé
  ici, et oubliait la recharge du carquois. Réécrit.
- `THF_BUFFS.lua` : description (« Chainspell ») corrigée, `@param eventArgs` ajouté.
- `THF_MOVEMENT.lua` : les lignes « Future: ... » et la fausse promesse
  d'équipement de vitesse sont retirées. Le callback vide est décrit comme tel.
- `THF_COMMANDS.lua` : lignes « Future » retirées. « Fighter's Buff Combo »
  devient « Feint / Bully / Conspirator ». Séparateur rétabli.
- `THF_IDLE.lua` / `THF_ENGAGED.lua` : en-têtes réécrits (Vajra AM3, AbyProc,
  SA/TA, TH).
- `logic/smartbuff_manager.lua` : libellé FBC corrigé, doc de `apply_fbc` ajoutée.
- `logic/set_builder.lua`, `logic/sa_ta_manager.lua` : chemin corrigé, puce d'en-tête inexacte retirée.
- `THF_STATUS.lua`, `THF_LOCKSTYLE.lua`, `THF_MACROBOOK.lua` : description et chemin.

### WAR
- `war_functions.lua` : la liste des modules logiques est mise à jour
  (Meditate, Haste Samba, stances, Kraken Club). Variable inutilisée retirée.
- `WAR_AFTERCAST.lua` : l'en-tête et le commentaire disaient que
  MidcastWatchdog s'occupe du rafraîchissement. WAR n'appelle **pas** le
  watchdog. Corrigé, avec une note explicite.
- `WAR_MIDCAST.lua` : même note sur le watchdog.
- `WAR_STATUS.lua` : il se disait « sans logique propre » alors qu'il gère le Doom. Corrigé.
- `WAR_BUFFS.lua` : en-tête complété (Doom, TP), `@param eventArgs`, séparateur.
- `WAR_IDLE.lua` / `WAR_ENGAGED.lua` : l'ordre de traitement documenté était
  faux. Il mentionnait l'AM3 en idle et la vitesse de déplacement en combat,
  deux choses que le code ne fait pas. Réécrit d'après le set builder.
- `WAR_PRECAST.lua` : les « 4 couches » omettaient AutoJump. L'en-tête parlait
  de Fast Cast. Corrigé.
- `WAR_COMMANDS.lua` : l'en-tête et la doc omettaient `tp`, `ws1..ws9`,
  `debugretaliation` et `retalstatus`, et l'ordre de traitement était faux.
  Ajout d'un commentaire : la branche `perf` est inatteignable (voir plus bas).
- `WAR_MOVEMENT.lua` : doc du helper de debug.
- `logic/set_builder.lua` : seuls des commentaires ont changé, aucune ligne de
  code n'a été touchée. Le titre de section « AFTERMATH » est renommé, l'en-tête
  est complété (stances, Kraken Club) et la doc de `build_engaged_set` /
  `build_idle_set` suit l'ordre réel.
- `logic/smartbuff_manager.lua` : la doc de `buff_war` flottait au-dessus de
  `MAIN_ABILITIES`. Elle est déplacée au-dessus de la fonction, qui a gardé
  exactement le même code. `@param` ajoutés aux helpers.
- `WAR_LOCKSTYLE.lua` / `WAR_MACROBOOK.lua` : chemins.

### WHM
- `whm_functions.lua` : chemin, variable inutilisée retirée.
- `WHM_PRECAST.lua` : l'en-tête décrivait Benediction, Devotion, des sets de
  durée et WSValidator. Rien de cela n'est dans le code. Il est réécrit avec
  l'ordre réel (re-tier des Cures avant le cooldown), et la doc `@param` est
  ajoutée aux helpers et à `job_precast`.
- `WHM_MIDCAST.lua` : deux commentaires inexacts sont corrigés.
  1. « job_midcast connaît les PV manquants de la cible » : faux, il choisit
     selon CureMode, Solace et CureMelee.
  2. La répartition des sorts d'affaiblissement suivait en réalité
     `job_get_spell_map` du job, et non Mote. La branche Repose est notée
     inatteignable, puisque Repose est de la Divine Magic.

  La doc des helpers « Extracted from » est réécrite avec `@param`.
- `WHM_COMMANDS.lua` : la branche `CombatMode` est notée inactive (WHM_STATES
  n'a pas de CombatMode), et `OffenseMode` n'est plus qualifié de « legacy »
  (c'est le vrai). La commande `afflatus` est citée dans l'en-tête.
- `WHM_AFTERCAST.lua`, `WHM_IDLE.lua`, `WHM_ENGAGED.lua`, `WHM_MOVEMENT.lua`,
  `WHM_BUFFS.lua`, `WHM_STATUS.lua` : en-têtes réécrits d'après le code.
- `logic/set_builder.lua` : « PDT mode support » (inexistant) est retiré.
  L'en-tête note maintenant que latent refresh et vitesse s'appliquent aussi en ville.

## Bugs suspectés

Non corrigés. Chacun change un comportement, donc la décision revient au propriétaire.

1. **`shared/jobs/sam/functions/SAM_PRECAST.lua:94`** : `res.job_abilities[ability_id]`.
   `res` n'est pas un global du sandbox. La table `user_env` de GearSwap
   (`addons/GearSwap/refresh.lua:114-147`) ne le contient pas, et aucun fichier
   du projet ne l'y met (grep sans résultat).
   *Conséquence probable* : chaque WS lancé sans Third Eye actif lève « attempt
   to index global 'res' » dans `job_precast`, donc pas de set de WS, ni
   d'auto-Third Eye. SAM n'est déployé nulle part, ce qui explique qu'on ne
   l'ait jamais vu.
   *Correctif proposé* : `local res = rawget(_G, 'res') or windower.res or require('resources')`
   en tête de `try_third_eye_ws`, comme BLM (`shared/jobs/blm/functions/logic/spell_refiner.lua:48`).
2. **`shared/jobs/run/functions/logic/aoe_manager.lua:116`** : `BluMagicConfig.get_rotation()`.
   Si `_G.BluMagicConfig` est absent au premier `require`, `BluMagicConfig`
   vaut `{}` et l'appel lève « attempt to call nil ». C'est sans conséquence
   aujourd'hui, car l'entrée RUN le définit avant.
   *Correctif* : garde `if not BluMagicConfig.get_rotation then show_error ... return end`.
3. **`shared/jobs/thf/functions/logic/smartbuff_manager.lua:51`** : le recast de
   Haste Samba est lu à l'id 191, alors que les Sambas utilisent 216. WAR,
   lui, utilise bien 216 (`war/.../smartbuff_manager.lua:124`). Le point est
   déjà connu dans docs/dev/jobs/thf.md.
   *Conséquence* : le cooldown n'est jamais vu, donc le /ja part même en recast.
   *Correctif* : 216.
4. **`shared/jobs/war/functions/WAR_STATUS.lua:41`** : `DoomManager` est chargé
   par `pcall` puis appelé sans vérifier qu'il existe. Si le `require` échoue,
   l'erreur se répète à chaque changement de statut (connu).
   *Correctif* : `if DoomManager then ... end`, ou passer à `LifecycleManager.status_change()`.
5. **`shared/jobs/run/functions/logic/cure_set_builder.lua:42`** : réécrit
   `sets.midcast.Cure` avec CureSelf/CureOther. Ensuite, Cure I/II
   (spellMap `Cure`) prennent le dernier set choisi. C'est sans effet sur RUN,
   qui n'a pas ces sets. La copie PLD du même fichier est dans une autre zone
   et mérite un œil.
6. **`shared/jobs/run/functions/RUN_PRECAST.lua:141`** : le bloc de debug
   precast appelle `MessagePrecast.*` sans vérifier que le `pcall(require)` a
   réussi. Ne se produit qu'avec `//gs c debugprecast`.
7. **`shared/jobs/run/functions/logic/set_builder.lua:62-70`** : Lycurgos
   (hache à deux mains) laisse en place le grip précédent (connu).
8. **`shared/jobs/sam/functions/SAM_PRECAST.lua:66-71` et `:99`** : le drapeau
   anti-boucle de Seigan alterne après un Seigan réussi, et le recast est testé
   par `== 0` strict au lieu de `is_recast_ready` (tolérance 2 s). Les deux
   sont connus (sam.md).
9. **`shared/jobs/thf/functions/logic/set_builder.lua:50`** : PDTAFM3 teste le
   buff 272 (Aftermath Lv.3) avec Vajra, alors qu'une relique donne le buff
   273. Le set est probablement inatteignable (connu).
10. **`shared/jobs/whm/functions/WHM_COMMANDS.lua:152`** : `state.AfflatusMode.value`
    n'a pas de garde. Si l'état n'existe pas, `//gs c afflatus` lève une erreur.
    Risque faible : WHM_STATES le crée.

## Doutes / à décider

- `shared/jobs/whm/functions/logic/set_builder.lua:49` : `in_town` est calculé
  puis ignoré, donc latent refresh et MoveSpeed s'appliquent **aussi en ville**,
  alors que tous les autres jobs s'arrêtent là. Voulu ou oubli ?
- `shared/jobs/thf/functions/THF_COMMANDS.lua:167` : `//gs c range` équipe
  `Exalted Crossbow` / `Acid Bolt` en dur dans le code, pas via un set. À
  déplacer dans `sets` (par ex. `sets.RangeLock`) ?
- `shared/jobs/thf/functions/THF_MOVEMENT.lua:26` : le callback AutoMove est
  enregistré au chargement de la façade, avec la condition `if AutoMove`. Or
  AutoMove n'est chargé qu'à +0,5 s par INIT_SYSTEMS
  (`shared/utils/core/INIT_SYSTEMS.lua:16`), donc le callback n'est
  probablement jamais enregistré. Il est vide de toute façon : on le supprime ?
- `shared/jobs/war/functions/WAR_AFTERCAST.lua` / `WAR_MIDCAST.lua` : WAR est le
  seul job de la zone à ne pas prévenir MidcastWatchdog. C'est aussi le job qui
  a servi à valider le retrait du `gs c update`. Aligner sur
  `LifecycleManager.aftercast()`, ou garder tel quel ?
- `shared/jobs/smn/functions/SMN_STATUS.lua`, `SMN_BUFFS.lua`,
  `SMN_AFTERCAST.lua` : ils réimplémentent LifecycleManager, avec en plus la
  synchro Avatar's Favor pour BUFFS (connu). Migrer vers `LifecycleManager.*(extra)` ?
- `shared/jobs/war/functions/WAR_STATUS.lua`, `WAR_BUFFS.lua` : même question,
  car ils recopient le corps de LifecycleManager (connu).
- `shared/jobs/run/functions/logic/aoe_manager.lua:143` : le message d'aide
  liste 5 sorts en dur, qui peuvent différer de `RUN_BLU_MAGIC`.
- `shared/jobs/run/functions/RUN_PRECAST.lua:49-75` : la liste d'exclusion
  « Scholar » est redondante avec CooldownChecker et dupliquée avec PLD (connu).

## Code mort probable

Rien n'a été supprimé : ce sont des exports, ou des fichiers entiers.

- `get_sam_movement_status` (`SAM_MOVEMENT.lua:19`), `get_thf_movement_status`
  (`THF_MOVEMENT.lua:37`), `get_war_movement_status` (`WAR_MOVEMENT.lua:139`) :
  `grep -rn "get_[a-z]*_movement_status" --include=*.lua .` ne trouve que leurs
  définitions et la liste `EXPECTED` de `shared/utils/debug/global_probe.lua:103-105`.
  Aucun appelant.
- `_G.DEBUG_RUN_WEAPONS` (`run/.../logic/set_builder.lua:65,75`) : lu mais
  jamais écrit. `grep -rn DEBUG_RUN_WEAPONS` ne trouve que ces deux lectures,
  donc les deux blocs de debug ne s'exécutent jamais.
- `MessageWHM` (`WHM_PRECAST.lua:32,56`) : chargé et jamais utilisé. Hors de
  `message_formatter.lua`, grep ne trouve que ces deux lignes (connu).
- Callback AutoMove vide de THF (`THF_MOVEMENT.lua:26-29`), voir « Doutes ».
- Branche `perf` de `WAR_COMMANDS.lua:194-214` : `perf` fait partie de
  `CommonCommands.is_common_command` (`shared/utils/core/COMMON_COMMANDS.lua:702`),
  qui est testé avant. La branche est inatteignable (connu, commentaire ajouté).
- Branche `CombatMode` de `WHM_COMMANDS.lua:197` : WHM_STATES ne définit que
  `OffenseMode` (`_master/config/whm/WHM_STATES.lua:46`).
- Branche Repose de `enfeeble_skill_for` (`WHM_MIDCAST.lua:140`) : Repose est
  de la Divine Magic, routée avant l'affaiblissement (connu).
- `job_handle_equipping_gear` vide dans SAM, SMN et WHM : ce sont des hooks
  Mote, donc pas du code mort à proprement parler, mais ils ne font rien.

# Plan de maintenabilité — 2026-09-22

Registre de travail, en français, à la différence des pages de référence de
`docs/dev/` qui sont en anglais. Chaque point porte sa preuve (`fichier:ligne`
et une mesure), le coût qu'il fait payer, le correctif, et l'effort estimé.
Le classement suit le **coût de maintenance**, pas la gravité en jeu : un bug
qui se voit tout de suite coûte moins cher qu'un silence qui se diagnostique
pendant des mois.

Sources : lecture du moteur (`D:\Windower Tetsouo\addons\GearSwap\*.lua`),
mesures sur l'arbre au commit `7015832`, et deux audits automatisés dont les
affirmations ont été revérifiées une par une — cinq ne se reproduisent pas et
sont listées en §6 pour qu'on ne les rechasse pas.

## Taille réelle du projet

| Périmètre | Fichiers | Lignes |
|---|---:|---:|
| Suivi par git (tout) | 975 | 167 497 |
| Suivi, `.lua` seulement | 884 | 140 304 |
| dont `shared/` | 654 | 99 580 |
| dont `_master/` | 229 | 40 515 |
| `.lua` sur disque, dossiers personnages gitignorés compris | 1 308 | 205 241 |

---

## 1. Ce qui peut faire perdre du travail

### 1.1 Le travail PLD de cette session n'existe que dans un dossier gitignoré

**Preuve.** `_master/Tetsouo/sets/pld/` est l'overlay *suivi* qui alimente le
clone de Tetsouo. Comparé au live :

| | live | overlay suivi |
|---|---:|---:|
| `sets.engaged.DPS` | 3 occurrences | **0** |
| `sets.engaged.Hoxne` | 2 | **0** |
| `Knights of Round` | 5 | **0** |
| `Excalibur` (weapons.lua) | 2 | **0** |

`pld_sets.lua` diffère de 303 lignes. Même écart côté config : `Excalibur`
manque dans `WEAPON_OPTIONS` du `_master/config/pld/PLD_STATES.lua`.

**Coût.** Un `clone_character.py` sur Tetsouo efface le système à trois stances
livré aujourd'hui. Et comme `Tetsouo/` est gitignoré (`.gitignore:56`), git ne
peut pas le rendre.

**Correctif.** Recopier les 4 fichiers de `Tetsouo/sets/pld/` vers
`_master/Tetsouo/sets/pld/`, ajouter `'Excalibur'` au template de states, puis
committer. Vérifier ensuite que les 8 autres jobs restent identiques — ils le
sont aujourd'hui (§1.2).

**Effort.** 15 min. ✅ **Fait le 2026-09-22, commit `51fe4c4`** — les 9 jobs de
Tetsouo sont maintenant identiques entre le live et `_master/Tetsouo/`.

### 1.2 Rien ne vérifie que la chaîne d'overlays est complète

**Preuve.** La résolution est à trois niveaux : `Tetsouo/X` ←
`_master/Tetsouo/X` ← `_master/X`, avec un renommage au passage
(`config/` live ↔ `config_global/` côté template). `CharDB.validate()`
(`character_db.lua:178-207`) vérifie seulement l'affectation job ↔ personnage
et conclut « OK - all 16 jobs assigned » ; il ne regarde **jamais** si un
fichier existe. Résultat mesuré, overlays correctement chaînés :

- `_master/Tetsouo/` est **identique au live** pour BLM, BRD, BST, COR, DNC,
  THF, WAR, SMN. Seul PLD diverge (§1.1). Le système marche.
- Quatre fichiers n'ont malgré tout aucune contrepartie suivie :
  `Tetsouo/config/CRAFT_CONFIG.lua` (24 l.),
  `Tetsouo/config/WARP_ITEMS_OWNED.lua` (10 l.),
  `Kaories/config/WARP_ITEMS_OWNED.lua` (8 l.),
  et `REGION_CONFIG` / `DUALBOX_CONFIG` de Tetsouo (117 + 51 l.) dont seule la
  variante Kaories est versionnée.
- `Kaories/config/pld/` (7 fichiers) n'a pas d'overlay
  `_master/Kaories/config/pld/`, alors que le template
  `_master/Kaories/entry/Kaories_PLD.lua:97,98,162,168` les référence : un
  redéploiement retomberait sur la config PLD de Tetsouo. C'est exactement le
  défaut corrigé en mai pour les *sets* (P2-8), jamais refermé pour la *config*.

**Coût.** Ce trou se rouvre à chaque job ou personnage ajouté, et il n'est
visible qu'au moment du redéploiement — c'est-à-dire trop tard. Preuve par
l'exemple : en écrivant ce plan je me suis trompé **deux fois** sur ce qui est
couvert, en lisant directement le dépôt.

**Correctif.** Un script `scripts/check_overlay.py` (~40 lignes) qui, pour
chaque `.lua` des dossiers live, résout la chaîne et liste ce qui n'atterrit
nulle part. À appeler depuis `CharDB.validate()` ou à la main avant un clone.

**Effort.** 1 h, et ça remplace une vigilance permanente par une commande.

### 1.3 Les standards et tous les audits sont hors de git

**Preuve.** `CLAUDE.md` → ignoré par `.gitignore:104` ; tout `.claude/` →
`.gitignore:77`, donc `CODE_QUALITY.md`, `standards.md`,
`MIDCAST_STANDARD.md` et `.claude/audits/*`. Seul `docs/dev/` est suivi.

**Coût.** Les règles que le projet s'impose, et l'historique des audits qui les
justifie, n'ont ni versions ni sauvegarde. On ne peut pas savoir *quand* une
règle a changé, ni pourquoi — ce qui est précisément l'information qui manque
quand une règle paraît absurde trois mois plus tard.

**Correctif.** Suivre `CLAUDE.md`, `.claude/CODE_QUALITY.md`,
`.claude/MIDCAST_STANDARD.md`, `.claude/rules/` et `.claude/audits/` ; laisser
ignorés `CLAUDE.local.md` (préférences perso) et `.claude/settings.local.json`.
`.claude/standards.md` est périmé (§4.2) : le supprimer plutôt que le suivre.

**Effort.** 10 min.

---

## 2. Ce qui casse en silence

C'est le poste de dépense principal du projet : non pas le temps de corriger,
mais le temps de **comprendre** qu'il y a quelque chose à corriger.

### 2.1 Les binds morts — propager la branche `else` de PLD aux 9 entrées restantes

**Preuve.** `Tetsouo/Tetsouo_PLD.lua:194-206` remonte désormais l'erreur réelle.
Le même bloc **sans `else`** subsiste :

| Fichier | Ligne | Portée |
|---|---|---|
| `Tetsouo/Tetsouo_BRD.lua` | 169-173 | live |
| `Tetsouo/Tetsouo_COR.lua` | 250-254 | live |
| `Tetsouo/Tetsouo_DNC.lua` | 204-208 | live |
| `Tetsouo/Tetsouo_THF.lua` | 170-174 | live |
| `_master/entry/Tetsouo_DRK.lua` | 167 | template + Hysoka |
| `_master/entry/Tetsouo_RDM.lua` | 216 | template |
| `_master/entry/Tetsouo_RUN.lua` | 165 | template + Hysoka |
| `_master/entry/Tetsouo_SAM.lua` | 129 | template |
| `_master/entry/Tetsouo_WHM.lua` | 165 | template |

**Coût.** C'est le bug que tu as chassé longtemps. Le job charge, `//gs c`
répond, et seules les touches sont mortes — sans un mot. Et le mécanisme est
plus large qu'il n'y paraît : dans le sandbox, `require` est `include_user`
(`refresh.lua:118`), qui lève aussi bien pour un fichier absent que pour une
erreur *dans une dépendance transitive* (`user_functions.lua:316,328,331`).
Donc `pcall(require, ...)` faux ne veut **jamais** dire « fichier absent », et
n'importe quelle erreur passagère en profondeur tue les binds en silence. Ça
explique le caractère intermittent : « j'ai changé un truc, unload, reload, et
là ça a buggé ».

**Correctif.** Recopier les 5 lignes de PLD dans les 9 fichiers, en affichant
`tostring(err)`. Corollaire à passer en règle : partout où un `pcall(require)`
échoue, le message doit dire *ce que* Lua a répondu, jamais « configuration
introuvable » — un diagnostic que le code ne peut pas établir (contre-exemple à
corriger : `shared/utils/ui/UI_LOADER.lua:30-49`).

**Effort.** 45 min. **Le meilleur rapport valeur/effort du plan.**

### 2.2 Le verrou de craft devient orphelin, et 16 slots restent morts

**Preuve.** Le verrou passe par `gs disable all` → `disable_table`, qui vit dans
`statics.lua:194-197`, **portée addon** : il survit à `gs reload` et au
changement de sous-job. La mémoire du verrou, `_G.__CraftManagerState`
(`shared/utils/craft/craft_manager.lua:49`), vit sur le `_G` du sandbox, qui est
**reconstruit à chaque chargement** (`refresh.lua:83,114,149`). Le commentaire
`craft_manager.lua:47-48` affirme l'inverse.

**Coût.** Après un changement de sous-job en session craft : plus aucun swap
d'équipement, sur aucune action, sans message ; et `//gs c uncraft` répond
« No craft set is currently active » (`craft_manager.lua:148-150`) sans
déverrouiller. Seule sortie : `//gs enable all` tapé à la main. Second chemin
vers le même état : `//gs c craft` puis `//gs c uncraft` en moins de 2 s, le
verrou différé de `craft_commands.lua:158-166` n'ayant pas de compteur de
génération.

**Correctif.** Déplacer l'état sur `windower.*`, qui persiste réellement — le
projet le fait déjà correctement six fois (`windower._midcast_wd_seq`,
`_job_sync_seq`, `_sch_cast_seq`, `_automove_seq`, `_ability_follow_seq`,
`_gs_reload_count`). Ajouter la génération sur `lock_after_delay`, et faire que
`uncraft` déverrouille inconditionnellement.

**Effort.** 2 h. C'est le seul défaut qui immobilise tout l'équipement d'un job.

### 2.3 Trois drapeaux qui ne redescendent jamais

- **DRK.** `_G.drk_dark_seal_pending` et `_G.drk_nether_void_pending` ne sont
  **jamais** remis à `false` (grep exhaustif). La seule fonction candidate en
  est structurellement incapable :
  `drk_buff_anticipation.lua:131` fait `if not X then X = false end`, vrai
  seulement si c'est déjà faux. Dark Seal est à charge unique : dès la première
  pression, `has_dark_seal()` (`:45`) rend `true` pour toujours et tous les
  Absorb/Drain/Aspir suivants partent en variante Dark Seal.
  *Correctif* : remettre à `false` sur perte de buff dans `DRK_BUFFS.lua`,
  comme `THF_BUFFS.lua:50-55` le fait déjà ; supprimer `initialize_flags()`.
- **GEO.** `_G.geo_entrust_pending` n'est effacé que si un `Indi-` non
  interrompu suit (`GEO_AFTERCAST.lua:39-41`). Si Entrust expire sans être
  consommé, le prochain `Indi-` part en variante Entrust sans le buff.
  *Correctif* : une branche Entrust dans `GEO_BUFFS.lua`.
- **BRD.** `_G.pianissimo_in_progress` est posé `true` juste avant
  `cancel_spell()` (`BRD_PRECAST.lua:99,101`), donc sans midcast ni aftercast :
  si le `/ja Pianissimo` ne part pas, le drapeau reste `true` et **toute**
  chanson visant un allié saute Pianissimo jusqu'à la prochaine chanson sur
  soi-même.
  *Correctif* : c'est la famille déjà traitée cette session — remplacer le
  `wait 2` aveugle de `:103` par `AbilityHelper.follow_up`.

**Effort.** 1 h 30 les trois.

### 2.4 Les gardes de sécurité se désactivent sans le dire, pour la session

**Preuve.** Motif identique dans **les 16** `[JOB]_PRECAST.lua` (réf.
`WAR_PRECAST.lua:33-62`) : `PrecastGuard = nil` en cas d'échec, puis
`modules_loaded = true` posé **hors** de toute condition de succès — donc aucun
réessai avant `//lua reload gearswap`. Or `precast_guard.lua:14,19,20,21` fait
quatre `require()` **non-pcall** au niveau module : une erreur dans n'importe
lequel (ou dans `message_colors.lua`, requis non-pcall par
`message_core.lua:13`) éteint PrecastGuard **sur les 16 jobs à la fois**, et
comme le même `message_core` porte MessageFormatter, le seul canal qui aurait
pu le dire tombe avec. Même verrou dans `DRK_AFTERCAST.lua:24-33`.

Variante plus vicieuse encore : `ws_precast_handler.lua:18-40`. Si
`ws_validator` tombe, la vérification de portée disparaît et le WS part quand
même ; si `tp_bonus_handler` tombe, aucun gear TP bonus n'est équipé. L'échec
ne se manifeste pas par une inaction mais par **une action plausible et
mauvaise** — le pire cas à diagnostiquer.

**Correctif.** Ne poser `modules_loaded = true` que si le chargement a réussi,
et transformer « module de sécurité nil » en une ligne de chat au premier usage.
Le coût de l'inverse est déjà chiffré ailleurs dans le projet : quand
`ModuleCache.install()` échoue en silence (`INIT_SYSTEMS.lua:47-52`, double
`pcall` sans `else`), on paie 1 018 ms de chargements redondants sur 1 180
(`module_cache.lua:4-16`), et ça se présente comme un lag diffus au premier JA.

**Effort.** 3 h (16 fichiers, mais mécanique).

---

## 3. Ce qui coûte à chaque modification

### 3.1 Code mort mesuré dans `shared/data/`

| Constat | Mesure | Preuve |
|---|---|---|
| Helpers WS dupliqués | **77 fonctions** (11 fichiers × 7) | `SWORD_WS_DATABASE.lua:407-489` et ses 10 jumeaux ; `DAGGER` et `GREATAXE` n'en ont **aucun** et fonctionnent — la preuve qu'ils sont inutiles. Le seul consommateur ne lit que `.weaponskills` (`UNIVERSAL_WS_DATABASE.lua:99-109`). |
| API `UniversalWS` | 17 fonctions, **1 appelée** | Seul `resolve()` a un appelant (`init_ws_messages.lua:126`). |
| Champs d'enmité | **302** `cumulative_enmity`, 0 lecteur | grep hors `shared/data/` : zéro. Idem `main_job_only` (695 occurrences) et `fm_cost` (9). |

**Coût.** Ce n'est pas le poids qui gêne, c'est l'imitation : chaque nouvelle
ability recopie ce gabarit mort par mimétisme, donc le volume croît à chaque job
touché. Et une API à 17 fonctions publiques dont une seule est câblée fait
légitimement croire qu'un mécanisme existe.

**Correctif.** Supprimer les 77 helpers et les 16 fonctions `UniversalWS`
inutilisées. Pour `main_job_only`, vérifier d'abord le générateur `config/alt/*`
qui n'est pas dans le dépôt. Pour l'enmité : soit la brancher sur un vrai
calcul, soit la retirer et documenter que le schéma n'a que 4 champs utiles.

**Effort.** 2 h, mécanique, à faire avec un `//gs c checksets` après.

### 3.2 PUP et DRG : des données écrites que rien ne charge

**Preuve.** `PUP_JA_DATABASE.lua:13` et `DRG_JA_DATABASE.lua:13` appellent
`create('PUP')` / `create('DRG')` sans `opts.modules`, donc la liste par défaut
`{'subjob','mainjob','sp'}` (`JA_DATABASE_FACTORY.lua:36`). Or
`pup_pet_commands_subjob.lua` et `drg_pet_commands.lua` existent sur le disque
et ne sont dans aucune liste. Les 11 commandes de pet PUP (Deploy, Retrieve,
Deactivate, les 8 Maneuvers) n'existent **que** dans ce module jamais chargé —
vérifié : « Fire Maneuver » n'apparaît nulle part ailleurs. BST le fait
correctement (`BST_JA_DATABASE.lua:15`).

**Coût.** Aucun message JA sur les commandes de pet, sur un job listé comme
supporté. Et c'est une faute qu'un lecteur ne peut pas voir : le fichier de
données est là, bien écrit, avec son en-tête.

**Correctif.** Deux lignes :
`create('PUP', {modules = {'subjob','mainjob','sp','pet_commands_subjob'}})` et
l'équivalent DRG.

**Effort.** 10 min.

### 3.3 Sept copies d'un état interne que son propriétaire n'expose pas

**Preuve.** `CraftManager` expose `mark_active()` et `active_gear()` mais pas
`is_active()`. Du coup chaque appelant lit le global brut :
`_master/entry/Tetsouo_GEO.lua:246`, `Tetsouo_RDM.lua:272`,
`_master/Kaories/entry/Kaories_GEO.lua:245`, `Kaories_RDM.lua:270`, les deux
copies live correspondantes, et `shared/jobs/blm/functions/BLM_COMMANDS.lua:541`.

**Coût.** Tout job qui veut respecter le garde doit connaître le nom d'un global
interne. Deux `enable()` l'ignorent déjà : `WHM_COMMANDS.lua:199,211` et
`_master/entry/Tetsouo_RDM.lua:171` — alors que `job_update` du *même fichier*
(`:272`) a le garde, avec le commentaire qui explique pourquoi. Le prochain job
ajouté oubliera aussi.

**Correctif.** `CraftManager.is_active()`, sept appels à la place, et les deux
`enable()` manquants gardés.

**Effort.** 45 min.

### 3.4 L'outillage de vérification est ignoré par git, et il pourrit

**Preuve.** `scripts/audit/` : 6 933 lignes, gitignoré. État réel, mesuré en
l'exécutant :

| Outil | État |
|---|---|
| `check_pcall_require.py` | fonctionne — 532 sites, 0 drapeau jeté |
| `check_argorder.py` | fonctionne — 0 trouvaille |
| `check_arity.py` | fonctionne, mais ses 5 trouvailles sont **toutes** des faux positifs (paramètres optionnels en fin de signature) |
| `check.py` | **cassé** — lit `UNIVERSAL_JA_DATABASE.lua`, supprimé le 2026-09-19 |
| 50 `difftest_*.lua` | comparateurs à deux versions (`difftest X <old.lua> <new.lua>`), un par refactor passé ; **30 rebâtissent chacun leur propre stub `_G.windower`** |

**Coût.** Un outil qu'on n'exécute pas pourrit, et un outil qui sort 5 faux
positifs sur 5 ne sera plus exécuté — les deux se renforcent. Et le vrai gâchis
est ailleurs : le harnais de stubs qui permet de charger un fichier de job hors
du jeu (`difftest_pld_midcast.lua:37-63` : `_G.state`, `_G.sets`, `_G.equip`,
`_G.windower`, `package.loaded[...]`) est réécrit à la main à chaque fois. C'est
ce harnais qui a de la valeur, pas les 50 comparateurs.

**Correctif.** (a) suivre `scripts/audit/` dans git ; (b) extraire le harnais en
`scripts/lib/gs_stub.lua` réutilisable, ce qui rend testable n'importe quel
`[JOB]_PRECAST`/`MIDCAST` en quelques lignes ; (c) réparer `check.py` ou le
supprimer ; (d) ajouter à `check_arity.py` la notion de paramètre optionnel,
sinon le retirer ; (e) archiver les 50 difftests dans un sous-dossier qui dit
qu'ils sont ponctuels.

**Effort.** 3 h, et ça transforme « j'espère n'avoir rien cassé » en une
commande. C'est l'investissement qui rapporte le plus à long terme sur un dépôt
de cette taille.

### 3.5 La politique de fins de ligne n'est pas dans le dépôt, seulement sur cette machine

**Preuve, et démenti d'une fausse piste.** Sur disque, 455 `.lua` suivis sont en
CRLF et 429 en LF, ce qui ressemble à un dépôt incohérent. Ce n'en est pas un :
`core.autocrlf` vaut `true` et **l'index est uniformément en LF** (0 CRLF sur
120 fichiers échantillonnés). Git stocke LF et restitue CRLF ; la « mixité » ne
vit que dans la copie de travail et ne produit aucun diff parasite. Il n'y a
donc **pas** de problème de fins de ligne à corriger ici.

**Coût réel, plus étroit.** `core.autocrlf` est une configuration **locale**,
non versionnée. Un clone sur une autre machine — ou par quelqu'un d'autre, ce
qui est un objectif affiché du projet — sort les fichiers en LF ; un éditeur
qui réécrit en CRLF y produirait alors des diffs de fichiers entiers. La
politique ne voyage pas avec le dépôt.

**Correctif.** Un `.gitattributes` d'une ligne (`*.lua text`) fige la
normalisation au niveau du dépôt et rend `core.autocrlf` inutile. Aucune
renormalisation nécessaire : l'index est déjà propre.

**Effort.** 5 min. À faire avant toute distribution, sans urgence avant.

---

## 4. Documentation qui induit en erreur

### 4.1 `docs/dev` décrit l'ancien `AbilityHelper` — et pourrait faire réintroduire le bug corrigé aujourd'hui

**Preuve.** `docs/dev/systems/precast-pipeline.md:30,209-227` et
`docs/dev/jobs/blm.md:176` décrivent le modèle « lancer le JA, attendre N
secondes, renvoyer le sort », avec le fichier annoncé à 138 lignes. Le code
actuel (`shared/utils/precast/ability_helper.lua`, 259 lignes, commits
`439bea4` et `06fa5c1`) **poll** l'apparition du buff ou la preuve que
l'ability a été refusée, avec un garde sur les recasts partagés (`:94-118`).
`blm.md:176` documente encore la chaîne `wait 2` supprimée de `BLM_PRECAST.lua`.

**Coût.** Quelqu'un qui lit la doc pour câbler un nouveau job copiera le modèle
« attendre puis renvoyer » — c'est-à-dire le bug qu'on vient de corriger. C'est
le seul mensonge de doc qui peut *produire* une régression.

**Correctif.** Mettre à jour `precast-pipeline.md` §AbilityHelper, puis les call
sites cités dans `blm.md`, `dnc.md`, `sam.md`, `geo.md`, `rdm.md`. Garder
`ampulla_lock.lua` et `scholar_actions.lua:110-130` comme exemples canoniques.

**Effort.** 1 h. **À faire tant que le nouveau modèle est frais.**

### 4.2 `CLAUDE.md` §16 est faux dans les deux sens

**Preuve.** La table « post-audit 2026-05-18 » annonce *3* fonctions de plus de
30 lignes hors dispatchers ; mesure actuelle sur 2 736 fonctions : **263**
(9,6 %). Elle annonce *11* `add_to_chat` directs dans `COMMON_COMMANDS.lua` ;
mesure actuelle : **0**. Bonne nouvelle jamais répercutée, mauvaise nouvelle
sous-estimée d'un facteur 90.

**Preuve, suite.** Aucun des trois documents de référence (`CLAUDE.md`,
`.claude/CODE_QUALITY.md`, `.claude/standards.md`) ne mentionne `docs/dev/` —
zéro occurrence — alors que c'est la seule documentation versionnée, citée
`fichier:ligne` et vérifiée. Et le chiffre « 9 systèmes centralisés » cohabite
avec 26 modules `*_manager` / `*_checker` / `*_handler` sous `shared/utils/`
qui n'apparaissent nulle part dans la section ARCHITECTURE.

**Correctif.** Retirer la table de métriques plutôt que la maintenir à la main
(ou la générer par script) ; ajouter un lien vers `docs/dev/README.md` dans
§REFERENCES DETAILLEES ; remplacer « 9 systèmes » par « 9 systèmes obligatoires
+ N modules de support, voir `docs/dev/` » ; supprimer `.claude/standards.md`,
périmé et contredit par `CODE_QUALITY.md` qui se déclare lui-même prioritaire.

Point de méthode, plus important que la table elle-même : une métrique tenue à
la main est un mensonge à retardement. `.claude/CODE_QUALITY.md` §6 le montre
aussi — sa liste d'exemptions `add_to_chat` énumère 11 fichiers alors que 19 en
utilisent légitimement, tous sous `shared/utils/messages/`. La règle générale
(« autorisé sous `shared/utils/messages/`, plus telle liste d'outils de
diagnostic ») ne vieillit pas ; l'énumération vieillit à chaque ajout.

**Effort.** 45 min.

### 4.3 Des commentaires affirment ce que le moteur ne fait pas

**Preuve.** `CLAUDE.md` et `.claude/MIDCAST_STANDARD.md` affirment que l'état de
debug « persiste via `_G.MidcastManagerDebugState` et survit aux reloads ».
Faux : `_G` est reconstruit à chaque chargement (`refresh.lua:83,114,149`), et
rien ne le sauvegarde. Même situation pour `_G.PrecastDebugState`,
`_G.WARP_DEBUG`, `_G.JOBCHANGE_DEBUG`, `_G.BST_DEBUG_PRECAST`. Le seul drapeau
réellement persistant est `windower._gs_debug.UPDATE` : c'est le modèle.

Même famille : `craft_manager.lua:47-48` (« survives »),
`UI_MANAGER.lua:64-68` (« Persist across module reloads », garde toujours vraie
donc HUD annoncé visible alors qu'il ne l'est pas), et
`Tetsouo/Tetsouo_COR.lua:59-60`.

**Coût.** `//gs c debugmidcast` est perdu à chaque changement de sous-job —
exactement quand on l'utilise pour instrumenter un problème de job change. On
croit la trace active, on voit du silence, et on conclut que le code tracé ne
s'exécute pas. C'est du temps de diagnostic dépensé sur un faux indice.

**Correctif.** Porter les drapeaux de debug sur `windower.*`, et corriger les
commentaires. Règle à retenir dans `CODE_QUALITY.md` : *dans le sandbox, `_G`
meurt à chaque chargement ; `windower.*` et `disable_table` survivent.* La
plupart des défauts de §2 découlent de cette seule asymétrie.

**Effort.** 1 h.

### 4.4 Deux petits mensonges sans gravité, à corriger en passant

- `BRD_COMMANDS.lua:115` — `cast_song(song_name, auto_pianissimo)` déclare un
  second paramètre que le corps n'utilise pas ; six appels passent `true` avec
  le commentaire `-- Enable auto-Pianissimo` (`:471,483,495,507,520`). Le
  docstring dit bien « Reserved (currently unused) », mais les call sites
  affirment le contraire. Retirer le paramètre et les commentaires.
- `shared/utils/warp/warp_commands.lua:355` —
  `pcall(require, 'utils/core/COMMON_COMMANDS')` : ce chemin n'existe pas (le
  bon est `shared/utils/...`), donc `WarpCommands.register()` est un no-op
  permanent qui a l'air vivant. Sans conséquence (le routage réel passe par
  `COMMON_COMMANDS.lua:391`), mais à supprimer.
- `_G.DNC_AUTO_WS_RECAST` — posé par `ability_helper.lua:251`, remis à zéro par
  `DNC_PRECAST.lua:136`, **lu par personne**. Le dédoublonnage de message qu'il
  annonce n'existe pas.

**Effort.** 30 min les trois.

---

## 5. Vérifié sain — ne pas y passer de temps

Utile à écrire noir sur blanc, pour ne pas « corriger » ce qui va bien :

- **Le système de messages tient.** 176 `add_to_chat` directs, **100 %** sous
  `shared/utils/messages/` ou dans la liste d'outils de diagnostic. **Zéro
  fuite** dans `shared/jobs/`. L'invariant est réellement respecté.
- **Aucun `pcall(require)` avec drapeau jeté** dans tout le dépôt (532 sites
  vérifiés) — le projet est discipliné là-dessus.
- **`ampulla_lock.lua` et `range_lock.lua` sont les modèles à recopier** : ils
  polent l'état réel du slot au lieu d'un délai, échouent du côté sûr (slot
  laissé ouvert), et leur `release()` est idempotente. Leur seule fragilité est
  leur *position* dans `file_unload` — à déplacer en tête, avant
  `cancel_all()` et `unbind_all()`, car un seul `pcall` entoure toute la
  fonction (`flow.lua:339-348`) : la première erreur annule les nettoyages
  suivants, dont le relâchement du slot.
- **Les compteurs de génération sur `windower.*` sont au bon endroit** et bien
  utilisés (6 modules).
- **`shared/data/` est justifié** : comparé à `D:\Windower Tetsouo\res\`, il
  apporte les descriptions, les familles de sorts et les recasts lisibles dont
  `res/` est dépourvu. Ce n'est pas une duplication du jeu.
- **`midcast_manager.lua` (753 l.) et `roll_tracker.lua` (787 l.) n'ont pas
  besoin d'être découpés** : dispatchers courts, helpers bornés. Les vrais gros
  morceaux sont `item_user.lua:570` (`_setup_auto_fix`, **191 lignes**, 3-4
  closures imbriquées) et `phases.lua:460` (`cleanup_inv`, 135 lignes).
- **La taille des `*_sets.lua` n'est pas un défaut** : données pures.
- **Le système d'overlays fonctionne** : 8 jobs sur 9 identiques entre live et
  `_master/Tetsouo/`.

---

## 6. Affirmations non reproduites — ne pas les rechasser

Cinq points remontés par les audits automatisés de ce jour ne tiennent pas à la
vérification. Ils sont consignés pour éviter qu'on les reprenne :

1. **« `is_recast_ready` dupliquée dans 7 fichiers »** (audit 2026-05-18, §P2-1)
   — périmé : c'est centralisé dans
   `_master/config_global/RECAST_CONFIG.lua:77`.
2. **« COR absent de `character_db`  »** (audit 2026-05-18, §P2-6) — corrigé :
   `character_db.lua:39` liste 9 jobs pour Tetsouo, COR et SMN compris, et une
   notion explicite d'`ARCHIVE_JOBS`.
3. **« `_master/Kaories/sets/pld_sets.lua` manquant »** (§P2-8) — corrigé ;
   reste le trou côté *config* (§1.2).
4. **« Chocobo/Raptor Mazurka définis deux fois »** — faux : ce sont deux
   chansons distinctes (`song_buffs.lua:865,875`). Scan complet de
   `shared/data/` : **aucune** clé dupliquée.
5. **« `docs/dev/jobs/pld.md` a un travail non committé »** — périmé, committé
   en `7015832`.

Leçon à en tirer, et c'est un argument de plus pour §3.4 : une trouvaille
d'audit qu'une machine ne peut pas revérifier se périme en silence, puis coûte
une deuxième fois quand quelqu'un la reprend.

---

## 7. Ordre d'exécution proposé

| # | Action | Effort | Pourquoi à ce rang |
|---|---|---|---|
| 1 | §1.1 Verser le PLD de cette session dans l'overlay | 15 min | Risque de perte, créé aujourd'hui |
| 2 | §1.3 Suivre les standards et les audits dans git | 10 min | Trivial, et tout le reste en dépend |
| 3 | §2.1 Propager la branche `else` des keybinds (9 fichiers) | 45 min | Le bug chassé depuis longtemps |
| 4 | §3.2 PUP/DRG `opts.modules` | 10 min | Deux lignes, un job réparé |
| 5 | §4.1 Remettre `docs/dev` d'accord avec `AbilityHelper` | 1 h | Tant que le modèle est frais |
| 6 | §2.2 Verrou de craft sur `windower.*` + génération | 2 h | Le seul défaut qui gèle tout l'équipement |
| 7 | §2.3 Les trois drapeaux qui ne redescendent pas | 1 h 30 | Silencieux, reproductible |
| 8 | §1.2 `check_overlay.py` | 1 h | Ferme la classe de défauts §1 |
| 9 | §3.4 Harnais de stubs + réparer les checkers | 3 h | Le plus rentable à long terme |
| 10 | §2.4 `modules_loaded` conditionnel, gardes bavardes | 3 h | 16 fichiers, mécanique |
| 11 | §3.1 / §3.3 / §4.2 / §4.3 / §4.4 | ~5 h | Friction, à faire par lots |
| 12 | §3.5 `.gitattributes` d'une ligne | 5 min | Sans urgence, avant distribution |

Total : environ 19 h. Les quatre premières lignes (1 h 20) couvrent tout ce qui
peut faire perdre du travail ou coûter un nouveau mois de diagnostic.

**Note sur la ligne 1 : faite le 2026-09-22** (commit `51fe4c4`) — les 4
fichiers de `Tetsouo/sets/pld/` sont versés dans l'overlay, `Excalibur` est
dans le template de states, et les 9 jobs de Tetsouo sont désormais identiques
entre live et `_master/Tetsouo/`.

**Règle transverse à ajouter à `.claude/CODE_QUALITY.md`**, dont découle la
moitié de ce plan : *dans le sandbox GearSwap, `_G` est reconstruit à chaque
chargement de job ; `windower.*` et `disable_table` survivent. Un état qui doit
survivre va sur `windower.*`. Un verrou posé sur `disable_table` doit avoir un
propriétaire qui survit aussi, sinon il devient orphelin. Et `pcall(require)`
faux ne signifie jamais « fichier absent » : toujours afficher l'erreur réelle.*

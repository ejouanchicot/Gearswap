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

> **Statuts : voir §7, puis §8 pour l'audit du 2026-09-25.** Les constats de §1
> à §4 sont conservés tels qu'écrits, avec les preuves telles qu'elles étaient
> au moment de la mesure (numéros de ligne compris : ils ont bougé depuis) ;
> c'est §7 qui dit ce qui a été livré et sous quel commit. §5 et §6 sont tenus à
> jour (dernière relecture : 2026-09-25). La plupart des points sont faits.

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

- **Le système de messages tient.** Les `add_to_chat` directs sont tous sous
  `shared/utils/messages/` ou dans les exceptions de `CODE_QUALITY.md` §6
  (outils de diagnostic, `whm_message_formatter.lua`, `trace_log.lua`, repli
  d'`INIT_SYSTEMS`). **Zéro fuite** dans `shared/jobs/` (revérifié le
  2026-09-25 : `grep -rn "add_to_chat(" shared/jobs` ne trouve rien). L'invariant
  est réellement respecté.
- **Aucun `pcall(require)` avec drapeau jeté** dans tout le dépôt (532 sites
  vérifiés) — le projet est discipliné là-dessus.
- **`ampulla_lock.lua` (`shared/utils/equipment/`, partagé depuis `a810d92`) et
  `range_lock.lua` (`shared/jobs/thf/functions/logic/`) sont les modèles à
  recopier** : ils
  polent l'état réel du slot au lieu d'un délai, échouent du côté sûr (slot
  laissé ouvert), et leur `release()` est idempotente. Leur seule fragilité est
  leur *position* dans `file_unload` — déplacée en tête depuis `2ad2a0d`, car
  un seul `pcall` entoure toute la fonction (`flow.lua:339-348`) : la première
  erreur annule les nettoyages suivants, dont le relâchement du slot. Depuis le
  2026-09-25, `//gs c wo` appelle aussi leur `release()` quand il déverrouille
  tous les slots (`wardrobe_organizer.lua` `release_stance_locks`).
- **Les compteurs de génération sur `windower.*` sont au bon endroit** et bien
  utilisés (6 modules).
- **`shared/data/` est justifié** : comparé à `D:\Windower Tetsouo\res\`, il
  apporte les descriptions, les familles de sorts et les recasts lisibles dont
  `res/` est dépourvu. Ce n'est pas une duplication du jeu.
- **`midcast_manager.lua` (777 l.) et `roll_tracker.lua` (778 l.) n'ont pas
  besoin d'être découpés** : dispatchers courts, helpers bornés. Les vrais gros
  morceaux sont `item_user.lua` `ItemUser._setup_auto_fix` (3-4 closures
  imbriquées) et `phases.lua` `Phases.cleanup_inv`. (Tailles de fichier
  mesurées le 2026-09-25 avec `wc -l`.)
- **La taille des `*_sets.lua` n'est pas un défaut** : données pures.
- **Le système d'overlays fonctionne** : `python scripts/check_overlay.py
  Tetsouo` (2026-09-25) donne 147 fichiers identiques à leur overlay, 10 sur
  le modèle générique (écart attendu), aucun divergent ; seuls
  `config/alt_state.lua`, `alt_window.lua` et `dualbox_role.lua` n'ont pas de
  modèle, et ce sont des fichiers écrits en jeu (un re-clone reprend les deux
  premiers, voir `KEPT_ON_RECLONE` dans `clone_character.py` ;
  `dualbox_role.lua` est exclu exprès).

---

## 6. Affirmations non reproduites — ne pas les rechasser

Cinq points remontés par les audits automatisés de ce jour ne tiennent pas à la
vérification. Ils sont consignés pour éviter qu'on les reprenne :

1. **« `is_recast_ready` dupliquée dans 7 fichiers »** (audit 2026-05-18, §P2-1)
   — périmé : c'est centralisé dans
   `_master/config_global/RECAST_CONFIG.lua:79`.
2. **« COR absent de `character_db`  »** (audit 2026-05-18, §P2-6) — corrigé :
   `character_db.lua:39` liste 9 jobs pour Tetsouo, COR et SMN compris, et une
   notion explicite d'`ARCHIVE_JOBS`.
3. **« `_master/Kaories/sets/pld_sets.lua` manquant »** (§P2-8) — corrigé ;
   reste le trou côté *config* (§1.2).
4. **« Chocobo/Raptor Mazurka définis deux fois »** — faux : ce sont deux
   chansons distinctes (`song_buffs.lua:865,875`). Scan complet de
   `shared/data/` : **aucune** clé dupliquée dans un même fichier. (Les deux
   Mazurkas existent aussi dans `song_special.lua`, qui l'emporte à la fusion ;
   leurs champs `effect` ont été alignés le 2026-09-25.)
5. **« `docs/dev/jobs/pld.md` a un travail non committé »** — périmé, committé
   en `7015832`.

Leçon à en tirer, et c'est un argument de plus pour §3.4 : une trouvaille
d'audit qu'une machine ne peut pas revérifier se périme en silence, puis coûte
une deuxième fois quand quelqu'un la reprend.

---

## 7. Ordre d'exécution proposé

| # | Action | Effort | Statut |
|---|---|---|---|
| 1 | §1.1 Verser le PLD de cette session dans l'overlay | 15 min | ✅ `51fe4c4` |
| 2 | §2.1 Propager la branche `else` des keybinds | 45 min | ✅ `6969e3b` — 19 entrées, couverture 100 % |
| 3 | §3.2 PUP/DRG `opts.modules` | 10 min | ✅ `45e28d9` — PUP 10→21 abilities, DRG 14→18 |
| 4 | §4.1 Remettre `docs/dev` d'accord avec `AbilityHelper` | 1 h | ✅ `7bd1a07` |
| 5 | §2.3 Les drapeaux qui ne redescendent pas | 1 h 30 | ✅ DRK `89ea984`, GEO `a4e6d05`, BRD `c93bd1f` |
| 6 | §3.3 `CraftManager.is_active()` + les 2 gardes manquants | 45 min | ✅ `e43ef55`, `34ba527` |
| 7 | §3.1 Code mort de `shared/data/` | 2 h | ✅ `72e135d` — 1 562 lignes retirées |
| 8 | §4.4 Les petits mensonges | 30 min | ✅ `f5a0976` |
| 9 | §4.3 Drapeaux de debug sur `windower.*` | 1 h | ✅ `11ff91e` |
| 10 | §1.2 Contrôle de la chaîne d'overlays | 1 h | ✅ `fd34a2c` — `scripts/check_overlay.py`, Tetsouo couvert à 100 % |
| 11 | §3.4 Harnais de vérification versionné | 3 h | ◐ `a7c8c34` — `check_syntax.py` livré (1 344 fichiers sans erreur le 2026-09-25) ; restent : `check.py` plante toujours (`FileNotFoundError` sur `UNIVERSAL_JA_DATABASE.lua`, via `model.json`), `scripts/lib/gs_stub.lua` n'existe pas, les 50 `difftest_*.lua` sont toujours à la racine de `scripts/audit/` |
| 12 | §2.4 Gardes PRECAST bavardes | 3 h | ◐ `d07265c` — l'échec est signalé et le rapporteur ne plante plus ; le verrou `modules_loaded` reste volontairement en place (le lever ferait réessayer un `require` cassé à chaque action) |
| 13 | §2.2 Verrou de craft sur `windower.*` | 2 h | ☐ préparé : tous les appelants passent par `is_active()`, la migration ne touche plus qu'un fichier ; toujours ouvert le 2026-09-25 (`craft_manager.lua:59` `_G.__CraftManagerState`) |
| 14 | §1.3 Suivre les standards et les audits dans git | 10 min | ☐ **décision à prendre** : le dépôt distant est public, et `.gitignore` s'ignore lui-même (ligne 79) donc la politique n'est pas versionnée non plus |
| 15 | §3.5 `.gitattributes` | 5 min | ☐ dépend du 14 (le `.gitignore` non suivi) |
| 16 | §4.2 Métriques de `CLAUDE.md` | 45 min | ◐ remesurées le 2026-09-25, cette fois avec la commande de chaque mesure dans la table (`CLAUDE.md` §METRIQUES, `CODE_QUALITY.md` §16) ; `CLAUDE.md` renvoie à `docs/dev/README.md` ; `CODE_QUALITY.md` §6 énonce la règle générale au lieu d'une liste. Reste à décider si la table est générée par script |

### Corrigés en plus, hors plan initial

Trouvés en vérifiant les points ci-dessus :

- **`a6dcd81`** — `DoomManager.is_doom_locked()` sondait le verrou en appelant
  `enable('neck')` : dans le sandbox `enable` rend une **table** (toujours vraie),
  donc la fonction rendait toujours `false` **et déverrouillait le collier** au
  passage. Une lecture qui détruit ce qu'elle lit, sur le verrou qui garde le
  joueur en vie. Zéro appelant, mais documentée comme utilisable. Supprimée.
- **`2ad2a0d`** — dans `file_unload`, PLD et THF relâchaient leur verrou de slot
  en **dernier**, derrière deux appels qui peuvent lever. Un seul `pcall` entoure
  toute la fonction (`flow.lua:339-348`), donc une erreur avant laissait le slot
  verrouillé dans le job suivant, qui n'a aucun moyen de le savoir. Remonté en tête.
- **`033846e`** — `//gs c entrust` envoyait l'Indi- à un allié 1,5 s plus tard quoi
  qu'il arrive, alors qu'Entrust a 5 min de recast. `AbilityHelper` gagne
  `follow_up_or_abort` pour le cas symétrique de `follow_up` : quand rien n'a été
  annulé, le bon comportement à l'échec est d'abandonner avec un message.
- **`d07265c`** — `ensure_message_init()` pouvait rendre `nil` et ses 8 appelants
  l'indexent sans garde, dont 5 dans des `coroutine.schedule` : le plantage y
  emportait les initialisations suivantes du même bloc. Le cas où ce rapporteur
  sert le plus — la chaîne de messages cassée — était le seul où il aggravait.

### Ce qui reste, et pourquoi

Trois points seulement, tous en attente d'un arbitrage plutôt que de travail :

1. **Kaories diverge de son propre overlay sur 3 fichiers, par des commentaires
   seulement.** `pld_sets`, `rdm_sets` et `RDM_STATES` ont été resynchronisés en
   `f6f1683`. `python scripts/check_overlay.py Kaories` (2026-09-25) liste encore
   `config/DUALBOX_CONFIG.lua`, `REGION_CONFIG.lua` et `WARDROBE_CONFIG.lua` ;
   un `diff` sans les commentaires est vide : ce sont les en-têtes réécrits la
   nuit du 2026-09-24 dans le live et pas dans l'overlay. Copier live → overlay,
   sans risque de perte.
2. **Suivre `CLAUDE.md`, `.claude/` et `scripts/audit/` dans git** (§1.3) revient à
   les publier sur un dépôt public. Et `.gitignore` s'ignore lui-même, donc la
   politique d'exclusion elle-même n'est pas sauvegardée : un clone ailleurs n'a
   aucune règle et committerait les dossiers personnages.
3. **Le verrou de craft sur `windower.*`** (§2.2) est le dernier défaut qui
   immobilise tout l'équipement d'un job sans message. Le travail préparatoire est
   fait : plus aucun appelant ne lit le global interne, donc la migration se joue
   dans `craft_manager.lua` seul.

**Règle transverse à ajouter à `.claude/CODE_QUALITY.md`** (toujours absente
comme règle générale le 2026-09-25 : seule la note sur l'état de debug midcast,
§4.2, dit que `_G` est reconstruit à chaque chargement), dont découle la
moitié de ce plan : *dans le sandbox GearSwap, `_G` est reconstruit à chaque
chargement de job ; `windower.*` et `disable_table` survivent. Un état qui doit
survivre va sur `windower.*`. Un verrou posé sur `disable_table` doit avoir un
propriétaire qui survit aussi, sinon il devient orphelin. Et `pcall(require)`
faux ne signifie jamais « fichier absent » : toujours afficher l'erreur réelle.*

---

## 8. Audit du 2026-09-25 — ce qui a été corrigé, ce qui reste

Audit par zones (le prompt est `docs/dev/audit-prompt.md`), chaque trouvaille
revérifiée avant correction. Les correctifs du jour **ne sont pas commités** au
moment de cette relecture et **n'ont pas été testés en jeu** : ils sont passés
`luac5.1 -p` et des tests `lua5.1` hors jeu (stubs), rien de plus. Les pages
`docs/dev` les marquent « fixed 2026-09-25 ».

### Corrigé le 2026-09-25 (résumé)

- **Jobs** : COR ne compte plus un Quick Draw ou une Waltz comme un Phantom Roll
  (`party_tracker.lua`, `ability.type == 'CorsairRoll'`) ; chien de garde DressUp
  et « FORCE GEAR RE-EQUIP » COR retirés ; GEO `//gs c geo` ne vise plus un allié
  avec Geo-Poison ; RUN/PLD `//gs c aoe` refuse sans /BLU ; WHM (`Melee ON`) et
  BLM (`CombatMode On`) relâchent leur verrou d'armes dans `file_unload` (pas au
  changement de sous-job) ; `JobChangeManager.initialize({...})` retiré de
  `job_sub_job_change` ; message d'échec des binds avec l'erreur réelle (12
  entrées) ; `REGION_CONFIG` posé avant `config_loader` (orange de Kaories COR) ;
  commentaires faux corrigés (DRK, PLD, GEO, DNC, THF, SMN, WAR, BST, BLM).
- **Cœur** : AbilityHelper ne boucle plus quand l'ability automatique ne peut
  pas partir (marqueur `windower._ability_replay`, pas d'essai sous Amnesia /
  Impairment) ; HUD « fantôme » d'un ancien chargement bloqué
  (`windower._ui_live_state`) ; toggles de debug déplacés dans
  `DEBUG_COMMANDS.lua` ; `//gs c equip` sans `naked` affiche l'usage ; fabrique
  `shared/config/message_mode_config.lua` pour les 4 `*_MESSAGES_CONFIG.lua` ;
  Waltz sur un membre du groupe dimensionnée ; séparateurs à 69, couleur des
  avertissements unifiée, clés de message mortes retirées.
- **Dual-box / clone** : `//gs c main` écrit aussi le rôle de l'alt (partenaire
  hors ligne) ; `altjobupdate` porte l'expéditeur, filtré à la réception (16
  COMMANDS) ; messages `not_ready`, `window_main_only`, `no_follower` ;
  `alt_state.lua` d'avant un redémarrage ignoré ; `_ALT_CUSTOM` repris de
  `_master` ; `//gs c sortie` ne plante plus sur une valeur de mode absente ;
  écouteur warp sur `raw_register_event` ; `//gs c wo` relâche les verrous
  Hoxne et THF ; le clone garde les fichiers écrits en jeu
  (`KEPT_ON_RECLONE`), génère `DualBoxConfig.group`, n'offre plus PUP, avertit
  pour un job sans entrée (SMN), affiche l'overlay à la confirmation.
- **Données** : runes Gelus/Tellus/Unda, 15 recasts de JA, descriptions de sorts
  relues sur BG-Wiki, Bio retiré de la copie Enfeebling, en-tête et compteurs de
  `UNIVERSAL_WS_DATABASE.lua`.
- **Règles et docs** : `.claude/rules/*`, `CLAUDE.md`, `CODE_QUALITY.md`,
  `MIDCAST_STANDARD.md`, skills ; `docs/dev` recalé sur le code (nouvelle page
  `systems/keybinds-and-custom.md`, section priorités HP, espaces de messages
  `altgroup` / `sortie` / `tempbind`).

### À tester en jeu (livré, non confirmé)

1. PLD stance Hoxne puis `//gs c wo` : ligne d'avertissement, slot ammo libre,
   Hoxne reverrouille ensuite. THF `//gs c range` puis `wo` : HUD RangeLock Off.
2. `//gs c alts on` juste après `//lua r gearswap` : « not initialised yet ».
   `//gs c alts window` sur l'alt : refusé. `//gs c main` avec l'autre boîte hors
   ligne, puis à sa connexion : une seule fenêtre des alts.
3. Changement de job d'une boîte : l'autre met bien à jour son job d'alt
   (nouveau format à 5 arguments).
4. BRD song1..5 et Marcato automatique : aucune erreur Lua.
5. `//gs c sortie farm` sur WAR : avertissement, pas d'erreur, l'alt charge son
   profil.
6. Kaories COR avec `//gs c trace on` : `trace.log` doit montrer l'orange 2 ;
   ensuite retirer la sonde `trace_region` de `message_colors.lua` et couper
   `trace` sur Kaories.
7. BLM `CombatMode On` puis `//gs reload` ou changement de job : armes libres.
   RDM : changer d'arme (cycle et `gs c set MainWeapon …`) rééquipe l'arme.
8. COR/DNC : un Phantom Roll suivi d'une Curing Waltz ou d'un Quick Draw, seul le
   roll est rapporté. Waltz sur un membre du groupe : le palier choisi.
9. Couleur des avertissements (orange EU) ; message de rune en PLD/RUN
   (`ja_mode full`) ; `//gs c info` sur un recast corrigé ; l'échec des binds
   BLM/BST/GEO affiche l'erreur.

### Encore ouvert

| Point | Pourquoi ouvert |
|---|---|
| L'intro de job n'affiche jamais le livre de macros ni le lockstyle (Z2-09) | décision : deux correctifs possibles, les deux changent l'affichage |
| Ancre HUD RUN `RuneElement` au lieu de `RuneMode` (Z05-4, fix 3) | change le rythme du HUD RUN ; RUN n'est joué que par les clones figés |
| `wo` Phase 0, `/equip <slot> empty` avec les noms de slot de l'API (Z07-P3-14) | vérifier en jeu si `/equip left_ear empty` marche |
| Deux résolutions de « les autres membres du groupe » (z06 P3-9) | touche `//gs c main`, à refaire avec un test en jeu |
| `temp_binds.lua` n'a pas l'horodatage ajouté à `alt_state.lua` | non traité ; effet réel non vérifié |
| RUN : binds différés sans compteur de génération (z09 P3-5) | aucun personnage géré ne joue RUN |
| Double rafraîchissement du HUD par changement d'état (Z2-13, transverse) | non traité |
| Fonctions longues (rolls, cooldowns, handlers, cycle de vie : Z04-8f, Z05-10) | refactor sans urgence, demande un test en jeu |
| `"JP"` contre valeur numérique pour les dons de Job Points (z08 P3-5) | change des helpers `can_learn` : à décider |
| Passe BG-Wiki complète sur les 361 fiches de sorts (z08 P2-1) | décision du propriétaire |
| Livre PLD/BLU, livres par défaut BRD/BLM/BST (z10 P3-1, P3-2) | données du joueur |
| `ui_settings.lua` du modèle : x = 1600 reste hors écran sur une fenêtre de 1600 px ou moins | le commentaire du fichier le dit (déplacer puis `//gs c ui save`) |
| `WardrobeOrganizer.reset()` ne relâche pas les verrous de posture | `//gs c wo reset` laisse un drapeau périmé ; la posture ou `//lua r gearswap` le remet |
| Hygiène du dépôt (zone 11 F9-F16) : `.gitignore` non suivi, notes `.txt` du joueur non ignorées, `.bak`, captures jamais référencées, aucun lien public vers `docs/dev` | hors `docs/dev` ; voir aussi §7 points 14 et 15 |
| Verrou de craft sur `windower.*` | §7 point 13 |

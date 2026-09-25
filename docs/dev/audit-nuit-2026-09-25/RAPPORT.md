# Audit de nuit — 2026-09-24/25 (version revérifiée)

Cette version remplace la première. Chaque point a été **revérifié dans le code**, avec des consignes sceptiques, et classé selon ce que ça change vraiment pour toi en jeu.

Le détail, fichier par fichier, est dans les 10 rapports de zone. Attention : ces rapports contiennent des affirmations qui se sont révélées fausses. Ce document fait foi.

## En bref

- Le projet a été relu en entier, sur 10 zones :
  - `shared/` ;
  - `_master/` ;
  - les dossiers live `Tetsouo/` et `Kaories/`.

  Hysoka et Gabvanstronger n'ont pas été touchés.
- Environ **900 fichiers ont été retouchés**, presque uniquement dans les commentaires : en-têtes, commentaires faux corrigés, documentation des fonctions, mise en forme.
- **Rien n'a été commité et rien n'a été testé en jeu.**

## Ce qui garantit que rien n'est cassé

1. Avant de commencer, tout a été sauvegardé (11 Mo) dans un dossier temporaire
   local, hors du dépôt. L'historique git en tient lieu : le nettoyage lui-même
   est le commit `b6c7dc6`, l'état d'avant est son parent `a73afff`.
2. Les **1 120 fichiers** se chargent sans erreur.
3. Le **code compilé** de chaque fichier a été comparé à celui de la sauvegarde. **46 fichiers** diffèrent, et chaque différence a été relue :
   - **40 fichiers** : on a retiré des choses jamais utilisées (variables et fonctions locales, un `if` vide, un `else` vide). Quand une variable recevait un `require`, le `require` est resté, donc le module se charge comme avant.
   - **`COMMON_COMMANDS`** : une liste reformatée, avec les mêmes commandes dans le même ordre.
   - **`SAM_TP_CONFIG`** : une condition écrite deux fois (`buffactive.Hagakure or buffactive['Hagakure']`) ne l'est plus qu'une fois.
   - **4 fichiers** : mes corrections de bugs (voir plus bas).
4. Les tests hors-jeu d'hier (binds, modes perso, `tb`, messages Sortie) donnent exactement les mêmes résultats.
5. Les fins de ligne (CRLF ou LF) de chaque fichier sont conservées.

**Annuler :** recopie le dossier de sauvegarde, en entier ou pour un seul fichier.

## Un défaut de la nuit, et ce que j'ai fait

L'outil de recherche utilisé par les agents (ripgrep) **ignore les dossiers gitignorés**, c'est-à-dire tes dossiers live `Tetsouo/` et `Kaories/`. Certaines affirmations du type « jamais utilisé » ne tenaient donc pas compte de ces dossiers.

- **Un commentaire faux avait été ajouté** dans `BST_COMMANDS.lua` : il disait que « rien ne lit » `_G.bst_rdymove_active`. Or ton entrée BST le lit. **Corrigé.**
- J'ai revérifié **toutes** les affirmations de ce type ajoutées cette nuit (« jamais appelé », « aucun appelant ») avec une recherche classique sur tout `data/`, dossiers live et clones compris. Les autres tiennent : les fonctions concernées ne sont réellement appelées nulle part.
- J'ai retiré les renvois « (see audit report) » ajoutés dans le code. Un commentaire doit se suffire à lui-même.

## Ce que j'ai corrigé moi-même

| Fichier | Problème | À tester |
|---|---|---|
| `shared/jobs/rdm/functions/RDM_COMMANDS.lua` | Lancer un sort par son nom lisait `res` comme variable globale, qui n'existe pas dans le job : la commande répondait « Command not recognized ». Même correctif que l'escort GEO d'hier (validé en jeu). | En jeu sur RDM |
| `shared/jobs/sam/functions/SAM_PRECAST.lua` | Même bug `res` : l'auto-Third Eye avant une WS plantait. Personne ne joue SAM, c'est pour ça que personne ne l'a vu. | Si tu joues SAM |
| `shared/utils/keybinds/keybind_manager.lua`, `shared/utils/custom/custom_states.lua` | Mon code d'hier : l'erreur d'un `_CUSTOM.lua` cassé s'affichait sans sa raison. | — |
| `shared/jobs/bst/functions/BST_COMMANDS.lua` | Le commentaire faux de la nuit, voir plus haut. | — |

J'ai aussi resynchronisé **88 copies** qui étaient identiques à leur modèle avant la nuit : 76 copies live et 12 overlays Kaories. Leur code compilé est identique à avant.

## Corrigé après la relecture (points 2, 3, 4, 5 et 7 ci-dessous)

**Validé en jeu le 2026-09-25**, avec le journal `//gs c trace` (`shared/utils/debug/trace_log.lua`) :
- **HUD** : une ligne fait 16 px, apprise dès le premier basculement. Ensuite, 0 px d'erreur. Au bord de l'écran, le HUD reste affiché à 0 et revient exactement à sa place.
- **Moonshade THF** (Vajra + Centovente) :
  - 1965 TP → Moonshade ;
  - 2017 TP → rien ;
  - 1232 TP → rien.
- **Warp** : `warp test` fonctionne sans erreur. Sur un warp interrompu, la bague normale est revenue ; la remise de l'équipement ne s'est déclenchée qu'une fois.
- **Haste Samba THF** : le recast 216 renvoie la vraie valeur (43 s après une Drain Samba), et le smartbuff affiche le cooldown au lieu de tenter le sort.
- **HUD désactivé** : après `//gs c ui off` puis `//lua r gearswap`, les touches de mode affichent de nouveau leur message. Confirmé par le joueur ; le journal ne l'a pas enregistré, parce qu'il se coupait au `//lua r` (corrigé depuis).

- **RDM, sort par son nom** (Kaories) : le journal indique `res global false`, donc le bug était bien réel. `Refresh II` est maintenant reconnu comme `/ma` et part.
- **`tb`** : fonctionne. L'horloge utilisée pour détecter un redémarrage augmente bien au fil de la session.

**Pas encore vérifié en jeu :**
- les règles `when` des modes perso ;
- SAM (auto-Third Eye) ;
- la couleur EU de Kaories COR.

| Point | Fichier(s) | Correctif |
|---|---|---|
| 2 — HUD désactivé : plus de message de cycle | `shared/utils/ui/ui_visibility.lua` | `is_visible()` exige maintenant que le HUD existe vraiment. HUD désactivé, les touches de cycle réaffichent « X is now Y ». |
| 3 — Le HUD saute | `ui_section_toggles.lua`, `ui_visibility.lua`, `ui_settings_resolver.lua` | Le décalage estimé (lignes mal comptées, hauteur de ligne devinée) est remplacé par la vraie différence de hauteur du HUD, mesurée avant et après, puis corrigée une fois le texte redessiné. La position enregistrée est désormais la position réelle, sauvegardée à chaque bascule. |
| 4 — Moonshade inutile sur DNC/THF | `shared/utils/weaponskill/tp_bonus_calculator.lua` (et le commentaire des `*_TP_CONFIG`) | Le bonus TP de l'arme en main secondaire compte aussi (Centovente, compté une seule fois si la même arme est dans les deux mains). Test : à 2750 et 2900 TP avec Centovente, plus de Moonshade ; à 1800 TP, Moonshade reste mis pour atteindre 3000. BRD et RDM en profitent aussi. |
| 5a — `//gs c warp test` plantait | `shared/utils/warp/warp_detector.lua` | La liste est reconstruite depuis la base, destination par destination : 65 objets, le total de la base. |
| 5b — Erreur Lua possible sur `//gs c warp` | `message_warp.lua`, `warp_messages.lua`, `item_user.lua` | Les deux messages qui portaient le même nom sont séparés. La ligne d'un anneau « pas prêt » affiche maintenant « … - not ready ». |
| 5c — Remise de l'équipement après un warp | `item_user.lua`, `warp_equipment.lua` | `gs c update` au lieu d'un `equip()` que GearSwap ignorait, 1 s après la libération de la bague. Idem pour la fin de `//gs c warp lock`. |
| 7 — Haste Samba (THF) | `shared/jobs/thf/functions/logic/smartbuff_manager.lua` | Recast 216 au lieu de 191. |

**Non activé, volontairement : la protection automatique des objets de warp utilisés à la main.** Elle n'a jamais tourné, et elle est cassée à trois endroits :
1. elle lit l'objet au mauvais endroit du paquet ;
2. la base utilise des noms de slot que GearSwap ne connaît pas (`ears`, `item`) ;
3. pour les anneaux, elle doublerait le verrou que `//gs c warp` pose déjà.

L'activer serait une nouvelle fonctionnalité à écrire et à tester. Le commentaire dans `warp_equipment.lua` l'explique.

---

## Les bugs, revérifiés

Les verdicts : **Confirmé**, **Partiel** (vrai, mais moins grave qu'annoncé), **Faux**. Pour chaque point : ce qui se passe réellement en jeu.

### Ce qui peut te gêner en jeu

**1. Livre de macros par défaut : Confirmé.** Les fichiers le disent eux-mêmes ; c'est surtout une question de choix.
- `macrobook_manager.lua:75` remplace toujours `solo['default']` par la valeur `.default` du fichier. La ligne `solo['default']` de chaque fichier ne sert donc à rien.
- Ce que ça donne pour un sous-job qui n'est pas listé :

  | Job (Tetsouo) | Livre ouvert (`.default`) | Ligne ignorée (`solo['default']`) |
  |---|---|---|
  | **DNC** | **5** | 6 |
  | PLD | 15 | 1 |
  | THF | 1 | 10 |

- **DNC est le plus touché** : seul /DRG est listé, donc DNC/NIN, DNC/WAR et DNC/SAM ouvrent tous le livre 5.
- **À décider** : quel livre tu veux pour chacun de ces trois jobs. Je supprime ensuite la ligne inutile.

**2. HUD désactivé, plus aucun message quand tu changes un mode : Confirmé.**
- Quand le HUD est désactivé dans la config, `is_visible()` répond quand même « visible » après chaque rechargement (`UI_MANAGER.lua:69-72`, puis `ui_lifecycle.lua:87-88`).
- Changer un mode par une touche ne l'annonce alors plus dans le chat, et il n'y a pas de HUD pour le voir non plus.
- Ça ne concerne que toi si tu joues avec le HUD désactivé.
- **Correctif en une ligne**, dans `ui_visibility.lua:119`.

**3. Le HUD saute quand on masque ou affiche l'en-tête, la légende ou les colonnes : Confirmé.**
- `ui_section_toggles.lua:44` soustrait la différence de hauteur alors qu'il faudrait l'ajouter.
- C'est purement visuel.
- **Correctif en un signe.**

**4. Bonus TP des WS (Moonshade) : Partiel.**
- Le calcul ne regarde que l'arme principale. Il ne compte donc ni Centovente en main secondaire (THF, DNC), ni le fusil de COR.
- **Effet réel, seulement pour DNC et THF** : quand tu es entre **2750 et 2999 TP**, le calcul croit qu'il te manque du TP et met Moonshade pour rien. Tu perds une oreille de dégâts. DNC est le plus concerné : son set WS laisse le calcul décider de Moonshade.
- **Aucun effet** pour COR et BLM, dont les sets WS portent déjà Moonshade en dur. RUN n'est joué que par Hysoka, qui est figé.
- **Doute de jeu non vérifié** : le bonus TP d'un fusil compte-t-il pour une WS au corps à corps (Savage Blade) ? Avant de toucher COR, il faut le savoir.

**5. Warp : Confirmé, deux erreurs visibles, mais rares.**
- **`//gs c warp test` plante à chaque fois** (« bad argument to pairs ») : `warp_detector.lua:219` lit `WarpItemDB.ITEMS`, qui n'existe pas.
- **`//gs c warp` peut afficher une erreur Lua** dans un cas limite : un anneau jugé « pas prêt » avec un délai de 0 (données de l'anneau illisibles, sac désactivé…). La fonction de message est définie deux fois, et c'est la seconde, qui attend deux arguments, qui est utilisée. Un vrai temps de recharge s'affiche correctement.
- **Remise de l'équipement après un warp : Partiel.** Les `equip()` lancés depuis une coroutine sont bien ignorés par GearSwap. Mais `gs enable ring1` remet en général ta bague. Si rien ne se déclenche pendant le verrou, l'anneau de warp reste porté jusqu'au prochain changement d'équipement.
- **Protection automatique d'un objet de warp utilisé à la main : Confirmé.** Elle ne s'active jamais, parce que la fonction est effacée juste après avoir été enregistrée. Les commandes `//gs c warp` ont leur propre verrou et ne sont pas concernées.

**6. WS refusée sous 1000 TP : Confirmé. C'est à toi de décider.**
- `ws_precast_handler.lua:63-64` annule la WS quand le TP lu est sous 1000, avec « Not enough TP ».
- Or un commentaire (`weaponskill_manager.lua:110`) et la règle du projet disent que ce contrôle a été retiré à cause du lag. Les deux se contredisent.
- En pratique : si le TP lu a un léger retard, la WS est refusée et tu dois rappuyer. Aucun mauvais gear.
- **À décider** : on garde le contrôle (et on corrige la règle et le commentaire), ou on le retire.

**7. THF : recast de Haste Samba lu au mauvais id (191 au lieu de 216) : Confirmé, effet faible.**
- Smartbuff croit la Samba toujours prête.
- Si elle est en recast sans le buff, il l'envoie quand même, et la vérification de recast l'annule avec un message.
- **Correctif : un chiffre.**

### Vrai, mais sans effet pour toi aujourd'hui

- **Wardrobe, la W7 n'est protégée que par hasard : Confirmé, sans effet aujourd'hui.** Rien ne lit `Config.PROTECTED`. Aucun set ne demande actuellement `bag='wardrobe 7'`.
- **Vérificateur d'équipement : Confirmé, sans effet.** Il confond index de case et id d'objet. Les objets équipés sont quand même trouvés par un autre chemin, donc `checksets` reste juste.
- **BST, `BST_PET_PRECAST.lua` ne s'exécute jamais : Confirmé, sans effet sur le gear.** GearSwap n'a pas d'événement `pet_precast`. Le gear correspondant est déjà posé ailleurs. C'est un fichier mort (idem pour PUP).
- **WHM (personne ne le joue) :**
  - Recherche des membres d'alliance pour les Cure : **Partiel**. Le bug existe, mais le résultat du calcul est identique, donc aucun effet.
  - Refresh latent et vitesse de déplacement appliqués en ville : **Confirmé**, visuel seulement.
- **« Plantages si un module ne se charge pas » (BRD, DNC, DRK, WAR) : le défaut de code existe, mais le plantage est impossible aujourd'hui.** Tous les modules concernés existent et se chargent.

### Faux

- **« La pause de l'auto-engage BST pendant `rdymove` n'est jamais lue » : Faux.** Ton entrée BST la lit. Le commentaire faux est corrigé.
- **« La couleur orange EU n'est jamais appliquée à Kaories » : Faux pour GEO, RDM et PLD**, qui posent la région au bon moment. Pour Kaories COR, ce n'est probablement pas un problème non plus, mais ça ne se vérifie qu'en jeu : regarde si un message orange de Kaories COR a la même couleur que sur Kaories GEO.

---

## Les données de jeu (`shared/data`)

Aucune de ces erreurs ne change ton gear. Elles n'apparaissent que dans des messages et dans `//gs c info`.

| Point | Verdict | Effet réel |
|---|---|---|
| Bio III : deux fiches se contredisent (SCH 75 et RDM 75 ; le jeu dit RDM 75) | Confirmé | Aucun. Le niveau n'est lu nulle part. |
| Mazurkas en double (+25 %/+100 % et +10 %/+20 %) | Confirmé | Seule la description dans `info` change. |
| Helix II (le jeu : Job Points), Refresh, Refresh II, Protect IV | Niveaux faux, confirmé | Aucun. |
| Klimaform rangée en Enhancing (le jeu : Dark) | Confirmé | Gear correct. Le message dit « Enhancing Magic ». |
| Inundation rangée en Enhancing (le jeu : Enfeebling) | Confirmé | **Le seul effet sur le gear, et il est mineur :** sur RDM, le set Enfeebling générique est pris au lieu d'un set plus précis. |
| Banish IV « absent du jeu » | Pas prouvé | Le jeu le donne à WHM 90. La fiche est commentée. |
| BLM : filtres « Sleep III » et « Bind II » (sorts qui n'existent pas) | Confirmé | Aucun. |

## Les modèles `_master` en retard sur ton live : Confirmé

- **BST :** ton entrée live a un moniteur de familier refait et d'autres changements.
- **WAR :** ton live a les modes SubtleBlow et Hoxne. Le modèle n'a pas les sets Hoxne ni Naegling/Ukonvasara par arme, ni les priorités HP.
- **THF :** seule différence, `Cacoethic Ring` au lieu de `Cacoethic Ring +1`.
- **Si on relançait `clone_character.py` pour Tetsouo :** ton dossier actuel serait déplacé dans `clone_backups/` (rien n'est supprimé). Mais le nouveau dossier aurait l'ancien BST, des sets WAR sans Hoxne et des states WAR sans SubtleBlow ni Hoxne.
  → **Il faut d'abord recopier ces fichiers du live vers `_master`.** Je peux le faire.
- **Kaories PLD** (`PLD_KEYBINDS.lua`, `PLD_STATES.lua`) : ce sont de vieilles versions. Le rapport de la zone 10 dit comment les convertir.

## Documentation périmée

- **`CODE_QUALITY.md`** décrit une chaîne midcast « à 7 niveaux » qui n'existe pas. CLAUDE.md et MIDCAST_STANDARD.md n'en parlent pas, contrairement à ce que disait la première version de ce rapport.
- **La vraie chaîne** est dans `midcast_manager.lua:563-605`. Elle cherche, dans l'ordre :
  - P0 : le nom exact du sort ;
  - P1 : le nom sans tier ;
  - P2 à P5 : les combinaisons type / cible / mode ;
  - P6 et P7 : le type ;
  - P8 : le mode ;
  - P9 : `sets.midcast[skill]`.
- **Piège à connaître :** si `sets.midcast[skill]` n'existe pas, la fonction s'arrête **avant** de chercher le nom exact du sort. Un set qui porte le nom d'un sort est alors ignoré.
- **`CODE_QUALITY.md` §6** donne `MessageCore.raw(color, text)`. La vraie signature est `raw(message)`, avec une couleur fixe.

## Code mort

- **Échantillon de 10 éléments vérifiés à la main, sur tout `data/` : 10 sur 10 sont réellement morts.** Exemples :
  - `get_war_movement_status` ;
  - `ModuleCache.stats` ;
  - `DataLoader.load_all` ;
  - `AutoMove.reinit_position` ;
  - `shared/config/message_modes.lua` (la vraie copie est dans le dossier de chaque personnage).
- Le total d'environ 250 éléments n'a pas été recompté un par un.
- **Rien n'a été supprimé.** Aucun effet en jeu : c'est seulement du code à maintenir pour rien.

---

## Ce qu'il te reste à décider

1. ~~**Macrobooks**~~ : **fait.** Livre par défaut : DNC 6/1, PLD 1/1, THF 10/1 (dans le live `Tetsouo/`). Les lignes `solo['default']`, écrasées par le gestionnaire, sont retirées.
2. ~~**WS sous 1000 TP**~~ : **fait.** Le seuil reste à 1000, mais le contrôle et le choix de Moonshade lisent maintenant le TP directement dans le jeu (`TPBonusHandler.live_tp`), et plus la copie de GearSwap, qui peut être en retard. Le journal (`WSTP`) note les deux valeurs à chaque WS.
3. **Recopier le live vers `_master`** (BST, WAR, THF) avant tout futur clone.
4. **La protection automatique des objets de warp :** on l'écrit proprement, ou on la supprime ?
5. **Commits** : le nettoyage de nuit d’un côté, le travail d’hier de l’autre.

## Les rapports de zone

Détail fichier par fichier. **Attention, ils contiennent des affirmations corrigées ci-dessus.**

| Zone | Fichier |
|---|---|
| 1 — Jobs BLM, BRD, BST, COR | `zone1-jobs-blm-brd-bst-cor.md` |
| 2 — Jobs DNC, DRK, GEO, PLD, PUP, RDM | `zone2-jobs-dnc-drk-geo-pld-pup-rdm.md` |
| 3 — Jobs RUN, SAM, SMN, THF, WAR, WHM | `zone3-jobs-run-sam-smn-thf-war-whm.md` |
| 4 — Messages et hooks | `zone4-messages-hooks.md` |
| 5 — Cœur, HUD, binds, modes perso, Sortie | `zone5-core-ui-keybinds.md` |
| 6 — Warp, wardrobe, équipement, dualbox | `zone6-warp-wardrobe-equipment-dualbox.md` |
| 7 — Autres utilitaires | `zone7-utils-divers.md` |
| 8 — Données de jeu | `zone8-data.md` |
| 9 — Modèles `_master` | `zone9-master-templates.md` |
| 10 — Dossiers live Tetsouo et Kaories | `zone10-live-tetsouo-kaories.md` |

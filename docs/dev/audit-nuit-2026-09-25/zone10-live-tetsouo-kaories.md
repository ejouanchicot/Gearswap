# Zone 10 - Fichiers live Tetsouo / Kaories (nuit du 2026-09-24 au 25)

Périmètre : les 21 fichiers qui n'existent que dans les dossiers live, et les
37 fichiers live qui diffèrent de leur modèle `_master`.

Règle suivie : **commentaires, en-têtes et documentation seulement**. Aucune
valeur, aucune touche, aucun numéro de macrobook/lockstyle, aucun équipement
n'a été touché.

Contrôle fait après chaque fichier :
- `lua5.1 loadfile` : le fichier se charge ;
- **le code compilé est identique à la sauvegarde** : le listing `luac -l`
  (sans les numéros de ligne) de chaque fichier modifié a été comparé à celui
  de la sauvegarde `backup_2026-09-24_night`. Les 46 fichiers modifiés donnent
  un code identique. Seuls les commentaires ont changé ;
- les fins de ligne (CRLF ou LF) sont conservées fichier par fichier.

Note : là où le modèle `_master` avait déjà reçu cette nuit des commentaires
corrigés (par l'autre agent), je les ai repris dans le live après vérification
dans le code, en gardant ce qui est propre au live (sets modulaires, etc.).

---

## Fait

### Configs globales (`<Perso>/config/`)
- `Tetsouo/config/UI_CONFIG.lua`, `Kaories/config/UI_CONFIG.lua` : l'en-tête explique que position/visibilité/fond/police/sections ne sont que des valeurs par défaut (`config/ui_settings.lua` gagne dès qu'il existe) ; le commentaire sur `ui_position.lua` (fichier qui n'existe plus) est corrigé ; `colors`, `auto_save_*`, `debug`, `update_throttle` et `validate()` sont marqués « lus par aucun module » ; @file et @return corrigés.
- `Tetsouo/config/LOCKSTYLE_CONFIG.lua`, `Kaories/...` : seul `initial_load_delay` est lu ; `job_change_delay` et `cooldown` ne sont lus nulle part (le commentaire disait le contraire) ; la séquence DressUp décrite est celle du code (déchargement, `/lockstyleset` 0,3 s après, rechargement à 3 s) ; « WAR/PLD seulement » remplacé par « tous les fichiers d'entrée ».
- `Tetsouo/config/RECAST_CONFIG.lua`, `Kaories/...` : « 1.5 s RECOMMANDÉ » n'était plus vrai (la valeur est 2.0) ; commentaires des deux helpers globaux simplifiés ; @file.
- `Tetsouo/config/REGION_CONFIG.lua` : @file ; `region_info` marqué documentation seule.
- `Kaories/config/REGION_CONFIG.lua` : en-tête standard ajouté (description, @author, @date prise sur le système de fichiers), @param/@return sur les 3 fonctions.
- `Tetsouo/config/DUALBOX_CONFIG.lua` : le rôle est décrit tel que le code le fait (les deux boîtes s'envoient leur job ; le rôle décide qui est « l'autre », qui envoie les buffs, qui lance les commandes alt) ; @file.
- `Kaories/config/DUALBOX_CONFIG.lua` : en-tête traduit en anglais et complété ; `timeout`/`debug` commentés ; les alias « legacy » expliqués (`alt_name` = l'autre boîte).
- `Tetsouo/config/WARDROBE_CONFIG.lua`, `Kaories/...` : titres de section en français passés en anglais ; en-tête complété (@author/@version/@date) ; le chemin réel des objets de warp épinglés (`WARP_ITEMS_OWNED.lua` d'abord, base complète sinon) corrigé chez Kaories.
- `Tetsouo/config/UI_COLOR_CONFIG.lua`, `Kaories/...` : liste des tables réellement lues par `COLOR_SYSTEM.lua` ; la table `runes` (non lue) expliquée ; les fonctions d'aide marquées « jamais appelées » ; `get_bar_element_color` signalée comme cassée si on l'appelait ; @file et @return.
- Non modifiés volontairement : `CRAFT_CONFIG.lua` (déjà juste), et les fichiers **générés par le jeu** `message_modes.lua`, `ui_settings.lua`, `WARP_ITEMS_OWNED.lua` (réécrits à chaque sauvegarde, toute retouche serait perdue).

### Fichiers d'entrée `Tetsouo/Tetsouo_<JOB>.lua`
- BLM, BRD, BST, COR, DNC, PLD, THF, WAR : doc ajoutée sur `get_sets`, `user_setup`, `job_update` (@param/@return), `init_gear_sets`, `file_unload`, `job_sub_job_change` (@return) ; les commentaires « le macrobook/lockstyle est géré par JobChangeManager » corrigés (c'est `user_setup()` qui le lance) ; « (must load before message system) » corrigé sur BLM/BRD/BST/COR/DNC/PLD/THF (voir bug 1) ; @file avec le chemin complet ; arbre de modules pointant vers `sets/<job>/<job>_sets.lua` (modulaire).
- BLM : « Elemental Staff swapping » remplacé par Hachirin-no-Obi (c'est ce que fait le code).
- BRD : liste des fonctionnalités mise à jour (packs de 5 chansons, délais, Pianissimo, protection Marsyas).
- BST : le moniteur de familier décrit tel qu'il est (événement prerender, familier seulement, le mouvement c'est AutoMove à 0,12 s et non 80 ms) ; doc sur `start/stop_pet_monitoring` ; séparateur vide en double retiré.
- DNC : 5 modules logiques (il n'y a pas de `jump_manager`).
- PLD : 11 hooks + 5 modules logiques (l'en-tête disait 12 + 5 puis 11 + 4).
- THF : liste des modules logiques complétée (`smartbuff_manager`, `range_lock`).
- WAR : `user_setup` n'est pas appelé « après get_sets » mais pendant `include('Mote-Include.lua')` ; docs de `file_unload` qui étaient collées au-dessus de `job_update` remises à leur place.

### Configs par job (`Tetsouo/config/<job>/`)
- `BLM/BRD/BST/COR/DNC/PLD/THF/WAR_MACROBOOK.lua` : @file ; explication du tableau dualbox ; commentaires faux corrigés (BRD `SCH` noté « Bard/Dancer », PLD `RDM`/`SCH` notés « PLD/WAR », DNC `+ RUN` au lieu de `+ RDM`, THF « Book 23 » au lieu de 10, plage de livres 1-40) ; `solo['default']` marqué « remplacé par `.default` au chargement » (voir doute 1) ; auteur `Kaories` remplacé par `Tetsouo` dans COR.
- `BRD_STATES.lua` : packs de 5 chansons, commentaires des packs Dirge/Tank/Healer/Arebati alignés sur `BRD_SONG_CONFIG.lua`, états manquants listés dans l'en-tête, doc des fonctions.
- `BST_STATES.lua` : le commentaire « AutoMove désactivé sur BST, Moving manuel » était faux (AutoMove tourne et tient `state.Moving`).
- `COR_STATES.lua`, `COR_LOCKSTYLE.lua`, `COR_TP_CONFIG.lua` : auteur `Kaories` remplacé par `Tetsouo` ; exemples de lockstyle faux (« utilise le lockstyle 1/2/3/4 » alors que tout vaut 3) ; `.style` marqué « plus lu » ; Fomalhaut = arme Aeonic ; avertissement sur le bug du bonus TP du fusil (voir bug 2).
- `THF_STATES.lua` : nombre d'options d'armes (7 / 4), alignement, @return.
- `WAR_STATES.lua` : touches réelles (Ctrl+Pavé 1 et 9, pas Alt+1/Alt+2), HybridMode à 4 valeurs, Shining One est une hast (pas une grande épée), @file.
- `WAR_TP_CONFIG.lua` : @file, mise en forme de la liste des boucliers (valeurs identiques).
- `WAR_CUSTOM.lua` : non modifié (fichier créé hier, système en cours).

### Sets (`Tetsouo/sets/`) - en-têtes/commentaires seulement
- `war/capes.lua` : alignement du tableau d'en-tête.
- `war/armor.lua`, `war/weapons.lua`, `war/war_sets.lua`, `thf/thf_sets.lua` : relus, rien à corriger dans les commentaires (le live est plus récent que le modèle).

### Kaories
- `Kaories/config/pld/PLD_LOCKSTYLE.lua` : exemples faux (« lockstyle 3 » alors que la valeur est 4) ; `.style` marqué « plus lu ».
- `Kaories/config/pld/PLD_MACROBOOK.lua` : commentaires `RDM` = PLD/RDM ; le tableau dualbox chez Kaories est indexé par le job de **Tetsouo** (les commentaires disaient « Kaories playing RDM ») ; `solo['default']` expliqué.
- `Kaories/config/pld/PLD_STATES.lua` : validate() non appelé, ligne vide en double.
- `Kaories/config/rdm/RDM_STATES.lua` : en-tête réécrit pour coller aux états réels (IdleMode sans Regen, NukeMode FreeNuke/Magic Burst, pas de RefreshMode, armes réelles, noms de Barspell) ; Ammurapi/Genmei sont des boucliers, Malevolence une dague, Colada une épée ; doc de `configure`/`validate`.
- `Kaories/sets/pld_sets.lua`, `Kaories/sets/rdm_sets.lua` : @file corrigé (ils pointaient vers `jobs/.../sets/`).
- `Kaories/config/pld/PLD_KEYBINDS.lua` : @file seulement (le fichier est une ancienne version, voir plus bas).

---

## Restes / fichiers live périmés par rapport au modèle

1. **`Kaories/config/pld/PLD_KEYBINDS.lua` - ancienne version.** Il fait
   lui-même bind/unbind/intro (180 lignes de code) au lieu de n'être que des
   données passées à `KeybindManager`. Pour le convertir : garder la table
   `binds`, supprimer `get_active_binds`, `bind_all`, `unbind_all`,
   `show_intro`, `show_binds` et la ligne `require(message_formatter)`, et finir
   par `return require('shared/utils/keybinds/keybind_manager').create('PLD', PLDKeybinds)`.
   Différences de contenu avec le modèle à trancher en même temps :
   - le modèle exclut `^numpad2` (PhalanxSIRD) sous /SCH, cache MainWeapon en
     stance Tanking, ajoute WS1/WS2 (`^numpad5/6`) et la ligne Regen, et
     déclare `^numpad7` en `retired_keys` ;
   - le live lie encore `^numpad7` à `SneakInviAOE` (sous /SCH).
   Sans `refresh()`, `PLD_COMMANDS.lua:296` ne rafraîchit pas les touches
   (c'est protégé par un test, donc pas d'erreur).
2. **`Kaories/config/pld/PLD_STATES.lua` - ancienne version** sans le profil
   /SCH (stances DPS/Tanking/Hoxne), sans Excalibur, sans `state.Regen`, sans
   les emplacements WS1/WS2. Marche pour les sous-jobs classiques ; PLD/SCH chez
   Kaories n'aurait pas les stances Sortie. À aligner sur le modèle si Kaories
   joue PLD/SCH.
3. **`Tetsouo/Tetsouo_BST.lua` - le live est plus récent que le modèle** :
   moniteur de familier en événement `prerender` (le modèle a encore la boucle
   `coroutine.schedule` avec suivi de mouvement), IPC dualbox dans
   `user_setup`, hooks `LagDebugger`. C'est le **modèle** qui est en retard ici.
4. **`Tetsouo/sets/war/*` et `Tetsouo/config/war/WAR_STATES.lua`** : même cas,
   le live (stances SubtleBlow/Hoxne, priorités HP, `LessEnmity`) est plus
   récent que `_master/Tetsouo/sets/war/` et `_master/config/war/WAR_STATES.lua`.
5. **`Kaories/config/UI_CONFIG.lua`** garde `UIConfig.print_config()` (code
   mort, jamais appelé, avec `add_to_chat` direct). Tetsouo ne l'a plus. À
   supprimer (non fait : c'est du code, pas un commentaire).
6. **Fichiers générés** : `Kaories/config/message_modes.lua` a été retouché à
   la main (chemin relatif, « Weaponskills ») et sera réécrit à la prochaine
   sauvegarde. Le chemin écrit par le générateur dans
   `Tetsouo/config/message_modes.lua` est bancal
   (`D:\Windower Tetsouo\/addons/...`) : c'est le code qui écrit le fichier
   (hors zone) qui colle `windower_path` et `'/addons'`.
7. **`Tetsouo/config/war/WAR_CUSTOM.lua`** contient un bloc actif marqué
   « Test » (`FullEmpy`, Ctrl+Pavé 8, met tout l'Empyrean). À retirer si ce
   test est fini.
8. **`print()` restants dans des fichiers de sets live** (anti-pattern n° 19) :
   `Tetsouo/sets/war/war_sets.lua:575` et `Tetsouo/sets/thf/thf_sets.lua:745`.
   `Tetsouo/Tetsouo_BST.lua` (moniteur de familier) fait aussi un `print()` en
   cas d'erreur.

---

## Bugs suspectés

1. **La couleur « orange » par région n'est jamais appliquée**
   (`Tetsouo/Tetsouo_BLM.lua`, `_BRD`, `_BST`, `_COR`, `_DNC`, `_PLD`, `_THF`, et
   les 4 `Kaories/Kaories_*.lua`). `message_colors.lua:31` lit
   `_G.RegionConfig` **une seule fois**, au moment où il est chargé ; or
   `config_loader.lua:14-16` le charge dès `require('shared/utils/config/config_loader')`,
   qui passe **avant** la ligne qui remplit `_G.RegionConfig`. Résultat : la
   région n'est jamais lue et tout le monde reçoit le code 057 (US). Pour
   Kaories (compte EU, où 057 n'existe pas selon `REGION_CONFIG`), les
   messages orange peuvent sortir dans la mauvaise couleur. Seul
   `Tetsouo_WAR.lua` charge la région avant ConfigLoader et fonctionne.
   Correction proposée : dans chaque fichier d'entrée, remonter le bloc
   `REGION_CONFIG` au-dessus de `require(config_loader)` (comme WAR), ou faire
   lire `_G.RegionConfig` par `message_colors` au moment de l'appel plutôt
   qu'au chargement (une seule correction dans `shared/`).
2. **Le bonus TP du fusil COR n'est jamais compté**
   (`Tetsouo/config/cor/COR_TP_CONFIG.lua:45`). `tp_bonus_handler.lua:57` passe
   l'arme **principale** (`player.equipment.main`) à `get_weapon_bonus()`, qui
   compare à la liste des **fusils** (`Anarchy +2` = +1000). Ça ne correspond
   jamais : le calcul sous-estime le TP de 1000 et peut mettre la Moonshade
   pour rien sur les WS à distance. Correction : pour COR, passer
   `player.equipment.range` (dans `tp_bonus_handler`) ou faire lire le slot
   range par `get_weapon_bonus`.
3. **Macrobook par défaut probablement faux sur PLD et THF (Tetsouo)**
   (`Tetsouo/config/pld/PLD_MACROBOOK.lua:33`, `Tetsouo/config/thf/THF_MACROBOOK.lua:32`).
   `macrobook_manager.lua:75` remplace `solo['default']` par `.default` au
   chargement. PLD : `default = {book = 15}` alors que tous les sous-jobs
   listés sont en livres 1-4 et `solo['default']` vaut 1 → un sous-job non
   listé (PLD/WAR, PLD/NIN...) ouvre le livre 15. THF : `default = {book = 1}`
   alors que tout le reste est en livre 10 → un sous-job non listé ouvre le
   livre 1. DNC : même mécanisme (`default = 5`, `solo['default'] = 6`).
   Correction : mettre `.default` à la valeur voulue (je ne l'ai pas fait, ce
   sont des numéros de macrobook).
4. **`UIColorConfig.get_bar_element_color()` planterait si on l'appelait**
   (`Tetsouo/config/UI_COLOR_CONFIG.lua` et Kaories) : elle lit
   `bar_spells.element[...]` qui n'existe pas. Personne ne l'appelle
   aujourd'hui, donc sans effet. À supprimer avec les autres helpers morts.

---

## Doutes / à décider

1. Les trois cas de macrobook ci-dessus (bug 3) : quel livre veux-tu
   réellement pour un sous-job non listé ?
2. Les réglages `UI_CONFIG` jamais lus (`colors`, `auto_save_position`,
   `auto_save_delay`, `debug`, `update_throttle`, `validate()`) et
   `LOCKSTYLE_CONFIG.job_change_delay/cooldown` : les supprimer, ou les laisser
   pour plus tard ? (Commentés comme « non lus » pour l'instant.)
3. Les `@date Created` que j'ai ajoutés sur `Kaories/config/REGION_CONFIG.lua`,
   `Kaories/config/DUALBOX_CONFIG.lua` (2026-05-01) et les deux
   `WARDROBE_CONFIG.lua` (2026-08-10) viennent de la date de création du
   fichier sur le disque, pas d'un historique : à corriger si tu connais la
   vraie date.
4. `Tetsouo/config/cor/COR_STATES.lua:65` décrit Anarchy comme « REMA gun » ;
   Anarchy n'est pas une REMA, mais je n'ai pas pu vérifier quelle version tu
   portes (la config TP dit `Anarchy +2`) : laissé tel quel.
5. `Tetsouo/sets/war/war_sets.lua` et `thf/thf_sets.lua` n'ont qu'un
   `@date Updated` (pas de `Created`) : je n'ai pas inventé de date.

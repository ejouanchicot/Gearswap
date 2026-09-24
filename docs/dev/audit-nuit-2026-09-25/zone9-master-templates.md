# Audit de nuit 2026-09-25 — Zone 9 : modèles `_master/`

Périmètre : tout `_master/` (248 `.lua` + 6 `.example`) : entrées, configs par job, `config_global`, sets plats, overlays Tetsouo et Kaories.

**Résultat : 149 fichiers modifiés, uniquement commentaires, en-têtes, doc `@param`/`@return` et mise en forme.**

Contrôles faits sur chacun des 149 fichiers (la sauvegarde de référence est `scratchpad/backup_2026-09-24_night/`) :

- `lua5.1 loadfile` OK sur les 248 `.lua` de `_master/`.
- Fins de ligne identiques à la sauvegarde (CRLF reste CRLF, LF reste LF).
- Le code, commentaires et espaces retirés, est identique à la sauvegarde. Une seule exception, sans effet : `_master/config/sam/SAM_TP_CONFIG.lua:95`, où `buffactive.Hagakure or buffactive['Hagakure']` devient `buffactive['Hagakure']` (les deux écritures désignent la même valeur en Lua).
- Rien d'autre n'a changé : aucun objet, augment, priorité, sac, touche, nom ou valeur de state, numéro de lockstyle ou de macrobook.
- Aucune suppression, aucun `git`.
- Les 22 `*_ALT_COMMANDS.lua` (générés, « do not edit ») n'ont pas été modifiés ; leurs en-têtes sont corrects.
- Les 16 `*_CUSTOM.lua` et les `*_KEYBINDS.lua` écrits aujourd'hui : texte manuel intact, seules quelques lignes de commentaire fausses ont été corrigées dans les KEYBINDS.

**Hors de cette zone, à ne pas rechasser** : SMN n'a pas de modèle générique et PUP ne charge pas (connus, voir CLAUDE.md). Les sets de plus de 800 lignes ne sont pas un problème.

### Les points les plus importants

1. **Des modèles sont en retard sur le live, donc un clone ferait régresser.**
   - `_master/entry/Tetsouo_BST.lua` : 196 lignes de différence avec `Tetsouo/Tetsouo_BST.lua`, et pas d'overlay Tetsouo pour BST.
   - `_master/Tetsouo/sets/war/*` et `_master/Tetsouo/sets/thf/thf_sets.lua` : plus anciens que le live du 2026-09-23.
   - Conséquence : un `clone_character.py` sur Tetsouo effacerait ce travail.
2. **Calculs de bonus TP faussés sur trois jobs (COR, BLM, THF)**, donc Moonshade est posé pour rien ou n'est jamais posé :
   - COR : les fusils ne sont jamais reconnus, car le calcul lit l'arme principale au lieu de l'arme de tir.
   - BLM : Moonshade est déclaré dans un champ que le calcul ne lit pas.
   - THF : le bonus de Centovente, l'arme secondaire par défaut, n'est probablement pas compté.
   - RUN : `RUN_TP_CONFIG` n'est jamais chargé.
3. **La couleur orange de région est ignorée dans 18 entrées sur 20.** L'ordre de chargement est en cause : `REGION_CONFIG` est posé après la lecture de la couleur par le système de messages. Aucun effet pour un compte US.

## Fait

### Sous-zone A — fichiers d'entrée (`_master/entry/`, `_master/Tetsouo/entry/`, `_master/Kaories/entry/`)

Sous-zone A : fichiers d'entrée (`_master/entry/`, `_master/Tetsouo/entry/`, `_master/Kaories/entry/`). 20/20 fichiers modifiés, **commentaires seulement** : une comparaison du code avec et sans commentaires confirme que le code est identique à la sauvegarde. `loadfile` passe partout, et les fins de ligne (CRLF ou LF) sont conservées.

Changements communs à presque tous les fichiers :
- Doc ajoutée (`@param` / `@return`) sur `get_sets`, `user_setup`, `job_update`, `init_gear_sets`, `file_unload` et `job_sub_job_change`.
- La doc de `user_setup` dit maintenant la vérité : cette fonction est appelée **pendant** `include('Mote-Include.lua')`, avant `init_gear_sets`, puis de nouveau à chaque changement de sous-job. L'ancienne doc disait « après get_sets ».
- « Update UI when states change (F9, F10, etc.) » est remplacé par une description exacte.
- « Toggle with: //gs c perf start » devient « enable with » : la commande active, elle ne bascule pas.
- La note « Initial load will be handled by JobChangeManager » est corrigée : le chargement initial du macrobook et du lockstyle part de `user_setup()`.
- Le commentaire « region config must load before message system » est corrigé : il était faux, voir Bugs n°1.
- Les doubles lignes `---====` en fin d'en-tête sont séparées, et `--- Load global configurations` (un doc-comment orphelin) devient un simple commentaire `--`.

Détail par fichier :
- `_master/entry/Tetsouo_BLM.lua` : fonctionnalité inventée « Elemental Staff swapping » remplacée par « Hachirin-no-Obi » (le seul code qui existe) ; plus les docs des hooks.
- `_master/entry/Tetsouo_BRD.lua` : liste de fonctionnalités corrigée (« Song duration tracking » et « Party buff monitoring » n'existent pas) ; ligne vide ajoutée avant le bloc DUALBOX ; docs.
- `_master/entry/Tetsouo_BST.lua` : l'en-tête « PET MONITORING » était faux. Il annonçait « toutes les 3 s, seulement avec un pet, s'arrête sans pet » ; en réalité c'est toutes les 1 s, avec ou sans pet. Docs de `start_pet_monitoring` et `stop_pet_monitoring` corrigées (vrais appelants). Le commentaire sur `select_default_*` explique maintenant pourquoi ils existent déjà (effet de bord de `bind_all()`). Séparateur orphelin retiré.
- `_master/entry/Tetsouo_COR.lua` et `_master/Kaories/entry/Kaories_COR.lua` : `file_unload` disait « registered in user_setup » ; c'est en fait PartyTracker, depuis `get_sets`. « CORKeybinds.show_intro() » devient « KeybindManager's show_intro() ». Docs.
- `_master/entry/Tetsouo_DNC.lua` : les comptes étaient faux. On annonçait « 12 hooks + 6 logic modules » ; il y a 11 hooks et 5 modules logiques (`jump_manager` n'existe nulle part). Docs.
- `_master/entry/Tetsouo_DRK.lua` : « 12 hooks » devient 11. « Logic: To be added as needed » est remplacé par les vrais modules (`drk_buff_anticipation`, `set_builder`). Docs.
- `_master/entry/Tetsouo_GEO.lua` et `_master/Kaories/entry/Kaories_GEO.lua` : « Full Radial/Ecliptic Attrition tracking » retiré (aucun code), PetTP mentionné. La doc de `job_update` mentionne le verrou d'armes CombatMode. Docs.
- `_master/entry/Tetsouo_PLD.lua` et `_master/Kaories/entry/Kaories_PLD.lua` : « 12 hooks » devient 11, « 4 Logic » devient 5, « Blu Magic » devient « Blue Magic AOE (PLD/BLU) ». Docs. `@author` était déjà Tetsouo dans l'overlay Kaories (le `@author Kaories` connu n'y est plus).
- `_master/entry/Tetsouo_PUP.lua` : avertissement ajouté dans l'en-tête (« template inachevé, copié de BST, ne charge pas »). L'en-tête parlait de « species/ammoSet » (des notions BST). Docs.
- `_master/entry/Tetsouo_RDM.lua` et `_master/Kaories/entry/Kaories_RDM.lua` : la note sur Storm était fausse (« created in job_sub_job_change ») ; `configure()` le crée aussi. Bloc de titre dupliqué retiré. Docs.
- `_master/entry/Tetsouo_RUN.lua` : les fonctionnalités et modules logiques cités étaient inventés (`ward_manager`, `rune_buff_tracker`, `gambit_manager`, Dark Magic) ; remplacés par les vrais (`aoe_manager`, `cure_set_builder`, `rune_manager`, `set_builder`). Le commentaire WarpInit (« no job uses WarpInit anymore ») est corrigé : `INIT_SYSTEMS` l'appelle pour tous les jobs. Le commentaire « DISABLED FOR TESTING » est expliqué, voir Bugs n°4. Docs.
- `_master/entry/Tetsouo_SAM.lua` : description ajoutée à l'en-tête, qui n'en avait pas. Doc ajoutée sur `job_sub_job_change`. Phrase de remplissage retirée. Docs.
- `_master/entry/Tetsouo_THF.lua` : liste des modules logiques complétée (`smartbuff_manager` et `range_lock` manquaient). Docs.
- `_master/entry/Tetsouo_WAR.lua` : la doc de `file_unload` était collée au-dessus de `job_update` ; elle est remise à sa place. Titre de section corrigé. Docs.
- `_master/entry/Tetsouo_WHM.lua` : « 12 Hooks … SETUP » devient 11 (`WHM_SETUP` n'existe pas). « cure_optimizer, bar_element_manager » n'existent pas ; remplacés par `set_builder` et `shared/utils/whm/cure_manager.lua`. Docs.
- `_master/Tetsouo/entry/Tetsouo_SMN.lua` : docs ajoutées sur tous les hooks, qui n'en avaient aucune. Commentaire Carbuncle précisé : l'invocation part aussi à chaque changement de sous-job, pas seulement au premier chargement. Commentaire DUALBOX ajouté.

Copies live concernées (commentaires seulement, code identique) :
- `Tetsouo/Tetsouo_{BLM,BRD,BST,COR,DNC,PLD,THF,WAR,SMN}.lua`
- `Kaories/Kaories_{COR,GEO,PLD,RDM}.lua`
- `Hysoka/Hysoka_{DRK,GEO,RUN}.lua` (clone figé : ne pas toucher sans demander)

### Sous-zone B — `_master/config/{blm,brd,bst,cor,dnc,drk,geo}/`

Méthode de contrôle : pour chaque fichier modifié, `lua5.1 loadfile` OK, fins de ligne
identiques à la sauvegarde, et **flux de jetons Lua identique à la sauvegarde**
(commentaires et espaces ignorés) : aucun code, clé, valeur, numéro de lockstyle ou de
macrobook n'a bougé. 38 fichiers modifiés sur 49. Les 7 `*_CUSTOM.lua` et
`COR/DNC/DRK_KEYBINDS.lua` n'ont pas été touchés (déjà justes).


- `blm/BLM_ELEMENTAL_CONFIG.lua` : @file complet ; l'obi est `sets.midcast.ElementalMatch` (pas un waist codé en dur) ; logique OU dans `elemental_matcher.lua` (pas BLM_MIDCAST) ; exemple « double weather » corrigé.
- `blm/BLM_MP_CONFIG.lua` : @file complet ; « combined » → « equipped over » (c'est un equip() par-dessus).
- `blm/BLM_TP_CONFIG.lua` : @requires avec le vrai chemin `shared/utils/...`.
- `blm/BLM_KEYBINDS.lua` : la touche Apps+0 (AutoMedicine) manquait dans le résumé.
- `blm/BLM_LOCKSTYLE.lua`, `brd/BRD_LOCKSTYLE.lua` : commentaire « par sous-job » faux → signale que `by_subjob` n'est pas lu (pas de `get_style`).
- `cor/COR_LOCKSTYLE.lua`, `dnc/DNC_LOCKSTYLE.lua`, `geo/GEO_LOCKSTYLE.lua`, `drk/DRK_LOCKSTYLE.lua` : commentaires « uses lockstyle 1/2/4 » qui contredisaient les valeurs, « uncomment » alors que c'est déjà actif, « role » non supporté, champ `.style` marqué inutilisé.
- `*_MACROBOOK.lua` (BLM, BRD, BST, COR, DNC, DRK, GEO) : « Uncomment » sur des entrées déjà actives retiré, structure `dualbox[ALT_JOB][TON_SOUS_JOB]` expliquée, plage de livres 1-40 (pas 1-20), DNC « + RUN » → « + RDM » (la clé est RDM), GEO « Book 1, Page 2… » faux retiré, COR `get_macrobook` marqué non appelé, entrée `solo['default']` DNC/DRK signalée comme écrasée par `.default`.
- `blm/BLM_STATES.lua` : MagicBurstMode a 3 valeurs (Off/On/Acc), AOETier inclut Aja, états manquants listés, @return.
- `brd/BRD_STATES.lua` : packs de 5 chansons (pas 4), contenu des packs Dirge/Tank/Healer/Arebati corrigé d'après BRD_SONG_CONFIG, doc de configure()/validate().
- `brd/BRD_SONG_CONFIG.lua` : commentaires des packs Arebati et Ngai (numéros et effets mélangés), Gold Capriccio = résistance pétrification (pas « Enmity -50 »), touches Alt+5/Alt+8 → Ctrl+Numpad7 / Apps+Numpad1, description du raffinement de tier.
- `brd/BRD_TIMING_CONFIG.lua` : indique ce qui est réellement lu ; résumé final faux (délai initial 1.0 s alors que la valeur est 2.5, refresh nitro 2.5 alors que 3.5) remplacé par les vraies valeurs.
- `brd/BRD_KEYBINDS.lua` : tous les « Alt+1…Alt+= » remplacés par les vraies touches Ctrl/Apps+Numpad ; bloc de 11 « Ctrl+1: Soul Voice… » sans aucun bind derrière remplacé par une ligne.
- `brd/BRD_TP_CONFIG.lua`, `dnc/DNC_TP_CONFIG.lua` : Aeneas n'est pas une REMA ; « config partagée » → chaque job a sa copie.
- `bst/BST_KEYBINDS.lua` : explication « Number keys / Alt+Numbers » fausse → cyclestate vs commandes BST ; section « PET MANAGEMENT » vide retirée.
- `bst/BST_STATES.lua` : « AutoMove désactivé sur BST, toggle manuel » était périmé (AutoMove actif, cf. entrée BST) ; @return.
- `bst/BST_TP_CONFIG.lua` : commentaire Fencer aligné sur ce que fait le code (voir bug) ; export `_G` expliqué.
- `bst/BST_PET_DATA.lua` : @usage/@see avec les vrais chemins ; « IN DEFINITION ORDER » faux (voir bug).
- `bst/BST_ECOSYSTEM_DATA.lua` : en-tête dit que le fichier n'est chargé par personne.
- `cor/COR_STATES.lua`, `cor/COR_TP_CONFIG.lua` : Anarchy n'est pas une REMA, Fomalhaut = arme Aeonic ; avertissement sur la liste `ranged_weapons` (voir bug).
- `dnc/DNC_STATES.lua` : tous les « Alt+N / Ctrl+1 » → vraies touches Ctrl+Numpad ; défaut MainWeapon mal commenté ; Twashtar = Empyrean ; CombatWeaponMode marqué non lu.
- `dnc/DNC_WS_CONFIG.lua` : seuil TP par défaut 900 (pas 1000).
- `drk/DRK_STATES.lua` : HybridMode = PDT/Accu, touches Alt+1/Alt+2 → Ctrl+Numpad9 / Ctrl+Numpad1, typo « Empyrrean ».
- `drk/DRK_TP_CONFIG.lua` : Anguta = faux Aeonic (pas « REMA Great Axe »).
- `geo/GEO_STATES.lua` : nombre de sorts (30 Indi / 28 Geo, pas 27/26), Idris est une masse (club), effets faux corrigés (Frailty = Défense-, Wilt = Attaque-, Fend et Attunement sont des buffs).
- `geo/GEO_TP_CONFIG.lua` : Dunna est une clochette, pas une masse.
- `geo/GEO_KEYBINDS.lua` : commentaire orphelin « Cast Spells (Ctrl+1/2) » retiré.

### Sous-zone C — `_master/config/{pld,rdm,run,sam,thf,war,whm}/`

Uniquement des commentaires, en-têtes et lignes vides. Aucun changement de touche, de nom ou valeur de state, de numéro de lockstyle ou de macrobook. Chaque fichier modifié a été rechargé avec `lua5.1 loadfile` (OK), et ses fins de ligne (CRLF ou LF) sont identiques à la sauvegarde.


- `pld/PLD_STATES.lua` : la liste des armes documente maintenant Excalibur (relique), et Burtgang passe de « relic » à « mythic ». Le commentaire de Regen disait « Ctrl+Numpad7 » : faux, Regen n'a pas de touche et se règle par macro `gs c set Regen`. WS1..WSn au lieu de « WS1, WS2 ». Doc de validate() corrigée, double ligne vide et ligne vide parasite supprimées.
- `pld/PLD_MACROBOOK.lua` : l'entrée `['RDM']` était commentée « PLD/WAR », corrigé en « PLD/RDM ». Plage de livres 1-20 → 1-40 (le fichier utilise déjà 15-20, et d'autres jobs 22-30). « Uncomment… » supprimé : rien n'est commenté. Double bandeau fusionné.
- `pld/PLD_TP_CONFIG.lua`, `rdm/RDM_TP_CONFIG.lua`, `run/RUN_TP_CONFIG.lua`, `sam/SAM_TP_CONFIG.lua`, `thf/THF_TP_CONFIG.lua`, `war/WAR_TP_CONFIG.lua`, `whm/WHM_TP_CONFIG.lua` : le commentaire « for legacy code / backward compatibility » était faux. `_G.<JOB>TPConfig` est lu par `<JOB>_PRECAST`, le commentaire le dit maintenant.
  - SAM : `buffactive.Hagakure or buffactive['Hagakure']` réduit à `buffactive['Hagakure']`. C'est la même expression écrite deux fois, sans effet sur le comportement.
  - WHM : bandeau « USER CONFIGURATION » vide supprimé.
- `pld/PLD_LOCKSTYLE.lua`, `run/RUN_LOCKSTYLE.lua`, `war/WAR_LOCKSTYLE.lua` : « -- Examples: » supprimé devant des valeurs réelles.
- `rdm/RDM_STATES.lua` : l'en-tête décrivait des options qui n'existent pas. Il annonçait IdleMode Regen, MainWeapon Crocea Mors, NukeMode LowTierNuke/Accuracy, NukeTier VI, EnSpell Off, RefreshMode, Barfira et Barparalysis. Il est aligné sur le code. Commentaires d'armes corrigés : les trois « Enfeebling sword » sont deux boucliers et une dague, et Colada n'est pas un « Enspell shield ». Doc ajoutée sur configure() et validate().
- `rdm/RDM_KEYBINDS.lua` : les titres parlaient d'« Alt+Numpad (1-5 / 6-9, 0) » alors que tout est en Ctrl+Numpad, plus Apps+Numpad pour Storm et AutoMedicine. Titre vide « Cast Enhancement Spells » supprimé.
- `rdm/RDM_SABOTEUR_CONFIG.lua` : « +5 potency/duration, 60s, 5min » n'est pas vérifiable, remplacé par une phrase neutre et l'indication de qui lit le fichier.
- `run/RUN_STATES.lua` : touches « Alt+1..4 » → Ctrl+Numpad1/2/3/9 (vérifiées dans RUN_KEYBINDS). Doc de configure()/validate() alignée.
- `run/RUN_MACROBOOK.lua` : « RUN/WAR » → « RUN/RDM », 1-20 → 1-40, « Uncomment » supprimé, double bandeau fusionné.
- `sam/SAM_STATES.lua` : touches Alt → Ctrl+Numpad1/9. « Buff updates handled by WHM_BUFFS.lua » était faux : c'est Mote-Include qui met à jour state.Buff. Doc alignée.
- `sam/SAM_KEYBINDS.lua` : commentaires « (Alt+1) »/« (Alt+2) » → Ctrl+Numpad1/9. `@file` complété avec le chemin.
- `sam/SAM_LOCKSTYLE.lua` : `@file` complété avec le chemin.
- `sam/SAM_MACROBOOK.lua` : `@file` complété. L'exemple « SAM/SAM » devient « SAM/WAR » (le sous-job SAM est impossible sur SAM). Double ligne vide supprimée.
- `thf/THF_STATES.lua` : « 8 options / 8 options » → 7 / 3. Malevolence est une dague, pas une massue. Kraken Club est une arme multi-attaque. L'état ancre de l'interface est bien lu par `ui_lifecycle.are_states_ready()`, pas par UI_MANAGER.
- `thf/THF_LOCKSTYLE.lua` : les commentaires annonçaient « lockstyle 2 / 3 » alors que les valeurs valent 1. « Uncomment » supprimé.
- `thf/THF_MACROBOOK.lua` : les commentaires annonçaient « Book 23, Page 1/2/3 » alors que les valeurs valent 1.
- `war/WAR_STATES.lua` : touches Alt+1/Alt+2 → Ctrl+Numpad1/9. Ukonvasara est une Empyrean (et non une Relic), Chango une Aeonic (et non une Empyrean), Shining One une lance (et non une Great Sword). En-tête et doc complétés (slots WS, JumpAuto, FastCast, AutoMedicine).
- `war/WAR_MACROBOOK.lua` : plage de livres 1-20 → 1-40.
- `whm/WHM_STATES.lua` : 7 commentaires de touches faux (« = or Alt+K », Alt+0/1/3/4/5, Ctrl+=) remplacés par les touches réelles de WHM_KEYBINDS. OffenseMode n'a aucune touche, c'est maintenant écrit. L'en-tête annonçait IdleMode « Normal/PDT », le code dit PDT/Refresh.
- `whm/WHM_KEYBINDS.lua` : 6 commentaires Alt/Ctrl+= faux → Ctrl+Numpad réels. Exemple « CastingMode cycling » retiré, puisque CastingMode est déjà lié.
- `whm/WHM_CURE_CONFIG.lua` : la commande `//gs c cure max` citée n'existe pas. Le vrai contournement est `state.CureAutoTier` sur Off. Le fichier est chargé par `shared/utils/whm/cure_manager.lua`, et non par WHM_PRECAST.
- `whm/WHM_LOCKSTYLE.lua`, `whm/WHM_MACROBOOK.lua` : mention « from Timara WHM » retirée. « macrobooks table » → « solo table ». Double ligne vide supprimée.

Non modifiés : les `*_CUSTOM.lua` (manuel joueur), `PLD_BLU_MAGIC.lua` et `RUN_BLU_MAGIC.lua`, `PLD/RUN/THF/WAR_KEYBINDS.lua`, `PLD_WS_CONFIG.lua` et `WAR_WS_CONFIG.lua` (déjà justes).

Copies live concernées : seuls `Tetsouo/config/{pld,thf,war}/` existent pour ces templates. `Kaories/config/rdm/` vient de l'overlay `_master/Kaories/config/rdm/`, et `Kaories/config/pld/` n'a pas d'overlay. RUN, SAM et WHM n'ont pas de copie live.

### Sous-zone D — `_master/config/alt/`, `config_global/`, configs des overlays Kaories/Tetsouo

Toutes les modifications sont des commentaires/en-têtes/indentation. Chaque fichier modifié :
`loadfile` OK, fins de ligne identiques à la sauvegarde, et contenu chargé (tables) identique
à la sauvegarde (comparaison récursive des valeurs).


- `_master/config/alt/{BLM,GEO,RDM,SCH,SMN}_ALT_CUSTOM.lua` : en-tête complété (`@version 1.0`, `@date Created: 2026-08-09`).
- `_master/config/alt/{BLM,COR,GEO,RDM,SCH,WHM}_ALT_CUSTOM.lua.example` : idem.
- `_master/config/alt/*_ALT_COMMANDS.lua` (22 fichiers générés) : en-têtes vérifiés, corrects, **non modifiés**.
- `_master/config_global/LOCKSTYLE_CONFIG.lua` : commentaires faux corrigés — le délai initial est lu par *toutes* les entrées (pas seulement WAR/PLD) ; `job_change_delay` et `cooldown` signalés comme non lus ; séquence DressUp réelle (lockstyle à 0,3 s, rechargement à 3,0 s) au lieu de « 0,5 s / 1,0 s / ~2 s ».
- `_master/config_global/UI_CONFIG.lua` : le commentaire citait un fichier `ui_position.lua` qui n'existe pas → c'est `config/ui_settings.lua` ; la commande `//gs c uisave` n'existe pas → `//gs c ui save` ; clés jamais lues signalées (`colors`, `auto_save_position`, `auto_save_delay`, `debug`, `update_throttle`).
- `_master/config_global/UI_COLOR_CONFIG.lua` : commentaire `runes` faux (la table n'est pas lue ; pour changer la couleur d'une rune il faut ajouter son nom latin dans `elements`) ; note que `bar_spells.ailment` n'a pas d'effet visible (les Bar-ailment sont colorés par élément) ; note que les fonctions d'aide du fichier ne sont appelées par personne.
- `_master/Tetsouo/config_global/WARDROBE_CONFIG.lua` : en-tête complété (@author/@version/@date) ; « see Kaories » faux (Kaories utilise aussi `active_job`) retiré ; titre de section français traduit.
- `_master/Kaories/config_global/WARDROBE_CONFIG.lua` : en-tête complété ; titre de section français traduit.
- `_master/Tetsouo/config/{brd,thf,war}/*_REFILL.lua` : indentation de la dernière ligne du bloc DNC corrigée.
- `_master/Tetsouo/config/pld/PLD_REFILL.lua` : commentaire faux (« /SCH ajoute Echo Drops » alors qu'ils sont déjà dans la liste par défaut) → décrit les vraies surcharges /SCH, /RDM, /RUN.
- `_master/Kaories/config/pld/PLD_REFILL.lua` : même commentaire faux (ici /SCH *retire* les Echo Drops) corrigé ; en-tête aligné sur les autres REFILL Kaories.
- `_master/Tetsouo/config/cor/COR_REFILL.lua` : l'en-tête disait « (Kaories) » dans l'overlay de Tetsouo → corrigé.
- `_master/Tetsouo/config/craft/CRAFT_REFILL.lua` : la détection passe par `_G.CraftManager.is_active()` dans `refill/config_resolver.lua`, pas par `refill_manager` lisant `__CraftManagerState`.
- `_master/Tetsouo/config/smn/SMN_MACROBOOK.lua` : format de la table `dualbox` documenté (`dualbox[job de l'alt][sous-job SMN]`, vérifié dans macrobook_manager.lua:120).
- `_master/Tetsouo/config/smn/SMN_STATES.lua` : doc `configure()` complétée.

#### Copies live concernées (à resynchroniser)

| Template modifié | Copie live |
|---|---|
| `_master/Tetsouo/config/{brd,cor,craft,pld,thf,war}/*_REFILL.lua` | `Tetsouo/config/<même chemin>` (identiques avant cette nuit) |
| `_master/Tetsouo/config/smn/SMN_{MACROBOOK,STATES}.lua` | `Tetsouo/config/smn/…` (identiques avant) |
| `_master/Kaories/config/pld/PLD_REFILL.lua` | `Kaories/config/pld/PLD_REFILL.lua` (identique avant) |
| `_master/config/alt/{BLM,GEO,RDM,SCH,SMN}_ALT_CUSTOM.lua` | `Tetsouo/config/alt/…` (identiques avant ; le clone ne copie pas `alt/`) |
| `_master/config/alt/*.example` | `Tetsouo/config/alt/*.example` (déjà différents avant) |
| `_master/config_global/{LOCKSTYLE,UI,UI_COLOR}_CONFIG.lua` | `Tetsouo/config/…` et `Kaories/config/…` — **déjà différents** : un autre agent a réécrit les commentaires côté live cette nuit ; fusionner à la main |
| `_master/{Tetsouo,Kaories}/config_global/WARDROBE_CONFIG.lua` | `Tetsouo/config/`, `Kaories/config/` — déjà différents (même raison) |

**Attention, overlays Kaories identiques au générique** : `_master/Kaories/config/{cor,geo,rdm}/*` (hors REFILL, 15 fichiers)
ont exactement le même contenu que `_master/config/{cor,geo,rdm}/*` (seules les fins de ligne diffèrent).
Je ne les ai pas touchés pour ne pas entrer en conflit avec les zones qui corrigent les génériques :
**une fois ces zones terminées, recopier les corrections des génériques dans ces 15 overlays** (en gardant leurs fins de ligne LF).

### Sous-zone E — sets plats (`_master/sets/`, `_master/Kaories/sets/`)

Règle suivie : **seulement des en-têtes et des commentaires**. Aucun objet, augment, priorité, sac ou ligne de code touché. Chaque fichier a été vérifié après modification : chargement `lua5.1` OK, fins de ligne identiques (CRLF ou LF comme avant) et **lignes de code identiques à la sauvegarde** (comparaison hors lignes de commentaire).

Note sur les dates : quand un fichier n'avait pas de date de création, j'ai mis la date de sa première apparition dans git (`2025-11-03`, `2025-11-22` pour PUP, `2026-02-17` pour WAR). C'est la date d'entrée dans `_master/`, pas forcément celle de l'écriture initiale. Pour WHM la date « Updated » (2025-10-21) est antérieure à cette date git ; j'ai donc écrit « creation date not recorded ».


- `_master/sets/blm_sets.lua` — en-tête au format standard, `@file` corrigé (`jobs/blm/sets/...` → `sets/blm_sets.lua`), seuil MP Conservation relié à `BLM_MP_CONFIG` (1000 par défaut), commentaires « PDT MODE » corrigés (les deux sets sont des copies vides de Normal).
- `_master/sets/brd_sets.lua` — en-tête standard ; retrait de « Ayanmo +2 » (absent du fichier) ; ajout de Loughnashade, Evisceration, Ruthless Stroke ; liste des sets engagés réelle (base/STP/Acc/SB/PDTKC) ; commentaire Soul Voice (était un copier-coller « Troubadour ») ; Ruthless Stroke marqué Dagger (était « Sword ») ; PDTKC indiqué comme placeholder (il ne réduit pas le Store TP, set vide) ; March/Paeon/Dirge complétés.
- `_master/sets/bst_sets.lua` — en-tête : `@file` corrigé, alignement.
- `_master/sets/cor_sets.lua` — en-tête standard ; idle réels (Normal/PDT/Refresh, pas de Regen), engagés réels (Normal/PDT, le DW est géré par SetBuilder), sets d'armes réels (Naegling/Anarchy/Compensator), Lanun +3/+4.
- `_master/Kaories/sets/cor_sets.lua` — même en-tête (contenu identique au template générique).
- `_master/sets/dnc_sets.lua` — en-tête standard ; ordre réel des variantes WS (SaberDance inclus), Dancing Edge ajouté, anneaux Moonlight en wardrobe 1/2 (pas 2/4), « 4 tiers » → 6 variantes ; commentaire Twashtar (était une copie « Mpu Gandring >> Centovente ») ; Moonshade : n'est pas « équipée à 1750-1999 TP » mais seulement si elle permet d'atteindre le palier suivant (2000/3000), comme le fait `tp_bonus_calculator.lua` ; « (4 variants » → « (6 variants ».
- `_master/sets/drk_sets.lua` — en-tête standard ; liste réelle des armes et WS ; pas de set Adoulin (retiré de l'en-tête) ; références « set_builder.lua:53 » remplacées par le nom de fonction ; commentaire idle : les armes passent par `SetBuilder.build_idle_set`.
- `_master/sets/geo_sets.lua` et `_master/Kaories/sets/geo_sets.lua` — en-tête standard ; retrait de « Metamorph Ring +1 » et « Telchine +3 » (absents) ; « Geomancy Sandals +3 » → « Geo. Sandals +4 » (ce qui est équipé) ; mot français « perso » retiré d'un commentaire.
- `_master/sets/pld_sets.lua` — en-tête standard ; liste d'armes réelle (Excalibur, KC, BurtgangKC ajoutés) ; Sortie = `sets.engaged.TP` précisé ; commentaire « Requiescat » au-dessus du set WS générique précisé.
- `_master/Kaories/sets/pld_sets.lua` — en-tête standard, liste d'armes et de sets engagés réelle.
- `_master/sets/pup_sets.lua` — en-tête complété (@file/@version/@date) ; retrait de la phrase « permet à Tetsouo_PUP.lua de charger sans erreur » (faux, voir bugs).
- `_master/sets/rdm_sets.lua` et `_master/Kaories/sets/rdm_sets.lua` — en-tête standard ; retrait de « Navigation tables (self/others) » (n'existent pas) ; sets d'armes réels ; renvoi « (line 419) » périmé retiré.
- `_master/sets/run_sets.lua` — en-tête standard, liste des WS et midcast (Blue Magic) mise à jour.
- `_master/sets/sam_sets.lua` — en-tête standard avec description et contenu réel du fichier.
- `_master/sets/thf_sets.lua` — en-tête standard ; pas de set engagé « Acc » (retiré), ajout de TH ; liste d'armes réelle ; Moonshade (même correction que DNC) ; Shark Bite = DEX/AGI (était « DEX/MND »).
- `_master/sets/war_sets.lua` — en-tête : `@file` corrigé, date ajoutée, « Souverain » → « Souveran », liste réelle des sets engagés (PDT, PDTAFM3, PDTKC).
- `_master/sets/whm_sets.lua` — en-tête : « Telchine full set » → les 4 pièces réellement portées ; buffs Afflatus Solace et Doom ajoutés à la liste.

Le reste P2-10 (require MessageFormatter en fin de fichier de sets) : **déjà corrigé**, plus aucun `require` dans ces 19 fichiers.

### Sous-zone F — sets modulaires Tetsouo (`_master/Tetsouo/sets/**`)

Aucune ligne de code touchée : pour chaque fichier, le contenu sans commentaires est identique à la sauvegarde (vérifié par diff), `loadfile` passe, et les fins de ligne (LF) ne changent pas.

La plupart des corrections portent sur les étiquettes AF / Relic / Empyrean, qui étaient inversées dans les commentaires. Pour chaque job, on a vérifié que l'étiquette correspond bien au set de base réforgé :
- BLM : Spaekona = AF, Archmage = Relic, Wicce = Empyrean.
- BST : Totemic = AF, Ankusa = Relic, Nukumi = Empyrean.
- COR : Laksamana = AF, Lanun = Relic, Chasseur = Empyrean.
- DNC : Maxixi = AF, Horos = Relic, Maculele = Empyrean.
- PLD : Reverence = AF, Caballarius = Relic, Chevalier = Empyrean.
- THF : Pillager = AF, Plunderer = Relic, Skulker = Empyrean.

Fichiers modifiés :
- `blm/armor.lua` : Spaekona passe de « Relic +4 » à « Artifact +4 », et Archmage de « Relic +3 » à « Relic +1/+3 » (le Coat est en +1). Corrigé dans l'en-tête et dans les titres de section.
- `blm/blm_sets.lua` : `@date Updated` devient `@date Created: 2026-05-11 (modular split)`.
- `brd/brd_sets.lua` : même correction du `@date` (2026-05-10).
- `brd/instruments.lua` : Carnwenhan était classé parmi les instruments à cordes. C'est une dague mythique, portée en main dans les sets de chant (brd_sets.lua:278). Commentaire corrigé.
- `bst/armor.lua` : Ankusa passe à Relic et Totemic à Artifact. On précise aussi que `Totemic.body_fh` est en réalité une Ankusa Jackcoat.
- `bst/bst_sets.lua` : correction du `@date`.
- `cor/armor.lua` : Lanun passe de « Empyrean » à « Relic +3/+4 », et Chasseur de « Relic » à « Empyrean ».
- `cor/cor_sets.lua` : `@author Kaories / Tetsouo` devient `@author Tetsouo`. « Nyame +2 » devient « Nyame Path B », car Nyame n'a pas de +2. Correction du `@date`.
- `dnc/armor.lua` : Etoile est le cou JSE (seulement le Gorget), pas un AF. Maculele passe à Empyrean, Maxixi à Artifact +3/+4, Horos à Relic.
- `dnc/capes.lua` : l'en-tête parlait d'un « Toetapper plain ». La clé `plain` est en fait une Senuna's Mantle sans augment.
- `dnc/dnc_sets.lua` : la note sur la Moonshade disait « 1750-1999 TP ». En réalité, TPBonusCalculator vise le prochain palier de TP, 2000 **ou** 3000 (tp_bonus_calculator.lua:44). Correction du `@date`.
- `pld/armor.lua` : Reverence passe de « Relic » à « Artifact +4 », et Caballarius de « AF » à « Relic +3/+4 ».
- `pld/pld_sets.lua` : ajout de `Created: 2026-05-11 (modular split)` devant `Updated: 2026-09-21`.
- `pld/weapons.lua` : Malevolence était décrite comme une épée. C'est une dague (clé `Malevo`).
- `thf/armor.lua` : Plunderer passe à Relic, Pillager à Artifact. Adhemar était décrit comme « Mythic Reforged », ce qui est faux : c'est de l'équipement augmenté.
- `thf/weapons.lua` : l'en-tête citait Aeneas, qui n'est défini nulle part. Il est remplacé par Mpu Gandring, qui est bien défini. Le Telopanos Knife était commenté « club sub » : c'est une dague.

Tous ces fichiers étaient identiques à `Tetsouo/sets/...` (live). **Il faut donc recopier les 16 fichiers ci-dessus vers le live** (même chemin, sans le préfixe `_master/`).

Volontairement pas touchés : `war/armor.lua`, `war/capes.lua`, `war/war_sets.lua`, `war/weapons.lua` et `thf/thf_sets.lua`. Leur copie live est **plus récente** que le template (voir la section suivante). Les modifier des deux côtés aurait compliqué la resynchronisation.

## Copies live à resynchroniser

Chaque fichier ci-dessous a un modèle dans `_master/` modifié cette nuit (commentaires et en-têtes seulement ; le code est identique). Le fichier live garde les anciens commentaires : il marche tel quel, mais il n'est plus identique au modèle. Pour resynchroniser, recopier le modèle vers le live, en remplaçant `Tetsouo` par `Kaories` pour les fichiers de Kaories.

| Modèle `_master/` modifié | Copie live |
|---|---|
| `_master/config_global/LOCKSTYLE_CONFIG.lua` | `Kaories/config/LOCKSTYLE_CONFIG.lua` |
| `_master/config/pld/PLD_LOCKSTYLE.lua` | `Kaories/config/pld/PLD_LOCKSTYLE.lua` |
| `_master/config/pld/PLD_MACROBOOK.lua` | `Kaories/config/pld/PLD_MACROBOOK.lua` |
| `_master/Kaories/config/pld/PLD_REFILL.lua` | `Kaories/config/pld/PLD_REFILL.lua` |
| `_master/config/pld/PLD_STATES.lua` | `Kaories/config/pld/PLD_STATES.lua` |
| `_master/config/pld/PLD_TP_CONFIG.lua` | `Kaories/config/pld/PLD_TP_CONFIG.lua` |
| `_master/config_global/UI_COLOR_CONFIG.lua` | `Kaories/config/UI_COLOR_CONFIG.lua` |
| `_master/config_global/UI_CONFIG.lua` | `Kaories/config/UI_CONFIG.lua` |
| `_master/Kaories/config_global/WARDROBE_CONFIG.lua` | `Kaories/config/WARDROBE_CONFIG.lua` |
| `_master/entry/Tetsouo_COR.lua` | `Kaories/Kaories_COR.lua` |
| `_master/Kaories/entry/Kaories_COR.lua` | `Kaories/Kaories_COR.lua` |
| `_master/entry/Tetsouo_GEO.lua` | `Kaories/Kaories_GEO.lua` |
| `_master/Kaories/entry/Kaories_GEO.lua` | `Kaories/Kaories_GEO.lua` |
| `_master/entry/Tetsouo_PLD.lua` | `Kaories/Kaories_PLD.lua` |
| `_master/Kaories/entry/Kaories_PLD.lua` | `Kaories/Kaories_PLD.lua` |
| `_master/entry/Tetsouo_RDM.lua` | `Kaories/Kaories_RDM.lua` |
| `_master/Kaories/entry/Kaories_RDM.lua` | `Kaories/Kaories_RDM.lua` |
| `_master/Kaories/sets/cor_sets.lua` | `Kaories/sets/cor_sets.lua` |
| `_master/Kaories/sets/geo_sets.lua` | `Kaories/sets/geo_sets.lua` |
| `_master/Kaories/sets/pld_sets.lua` | `Kaories/sets/pld_sets.lua` |
| `_master/Kaories/sets/rdm_sets.lua` | `Kaories/sets/rdm_sets.lua` |
| `_master/config/blm/BLM_ELEMENTAL_CONFIG.lua` | `Tetsouo/config/blm/BLM_ELEMENTAL_CONFIG.lua` |
| `_master/config/blm/BLM_KEYBINDS.lua` | `Tetsouo/config/blm/BLM_KEYBINDS.lua` |
| `_master/config/blm/BLM_LOCKSTYLE.lua` | `Tetsouo/config/blm/BLM_LOCKSTYLE.lua` |
| `_master/config/blm/BLM_MACROBOOK.lua` | `Tetsouo/config/blm/BLM_MACROBOOK.lua` |
| `_master/config/blm/BLM_MP_CONFIG.lua` | `Tetsouo/config/blm/BLM_MP_CONFIG.lua` |
| `_master/config/blm/BLM_STATES.lua` | `Tetsouo/config/blm/BLM_STATES.lua` |
| `_master/config/blm/BLM_TP_CONFIG.lua` | `Tetsouo/config/blm/BLM_TP_CONFIG.lua` |
| `_master/config/brd/BRD_KEYBINDS.lua` | `Tetsouo/config/brd/BRD_KEYBINDS.lua` |
| `_master/config/brd/BRD_LOCKSTYLE.lua` | `Tetsouo/config/brd/BRD_LOCKSTYLE.lua` |
| `_master/config/brd/BRD_MACROBOOK.lua` | `Tetsouo/config/brd/BRD_MACROBOOK.lua` |
| `_master/Tetsouo/config/brd/BRD_REFILL.lua` | `Tetsouo/config/brd/BRD_REFILL.lua` |
| `_master/config/brd/BRD_SONG_CONFIG.lua` | `Tetsouo/config/brd/BRD_SONG_CONFIG.lua` |
| `_master/config/brd/BRD_STATES.lua` | `Tetsouo/config/brd/BRD_STATES.lua` |
| `_master/config/brd/BRD_TIMING_CONFIG.lua` | `Tetsouo/config/brd/BRD_TIMING_CONFIG.lua` |
| `_master/config/brd/BRD_TP_CONFIG.lua` | `Tetsouo/config/brd/BRD_TP_CONFIG.lua` |
| `_master/config/bst/BST_ECOSYSTEM_DATA.lua` | `Tetsouo/config/bst/BST_ECOSYSTEM_DATA.lua` |
| `_master/config/bst/BST_KEYBINDS.lua` | `Tetsouo/config/bst/BST_KEYBINDS.lua` |
| `_master/config/bst/BST_MACROBOOK.lua` | `Tetsouo/config/bst/BST_MACROBOOK.lua` |
| `_master/config/bst/BST_PET_DATA.lua` | `Tetsouo/config/bst/BST_PET_DATA.lua` |
| `_master/config/bst/BST_STATES.lua` | `Tetsouo/config/bst/BST_STATES.lua` |
| `_master/config/bst/BST_TP_CONFIG.lua` | `Tetsouo/config/bst/BST_TP_CONFIG.lua` |
| `_master/config/cor/COR_LOCKSTYLE.lua` | `Tetsouo/config/cor/COR_LOCKSTYLE.lua` |
| `_master/config/cor/COR_MACROBOOK.lua` | `Tetsouo/config/cor/COR_MACROBOOK.lua` |
| `_master/Tetsouo/config/cor/COR_REFILL.lua` | `Tetsouo/config/cor/COR_REFILL.lua` |
| `_master/config/cor/COR_STATES.lua` | `Tetsouo/config/cor/COR_STATES.lua` |
| `_master/config/cor/COR_TP_CONFIG.lua` | `Tetsouo/config/cor/COR_TP_CONFIG.lua` |
| `_master/Tetsouo/config/craft/CRAFT_REFILL.lua` | `Tetsouo/config/craft/CRAFT_REFILL.lua` |
| `_master/config/dnc/DNC_LOCKSTYLE.lua` | `Tetsouo/config/dnc/DNC_LOCKSTYLE.lua` |
| `_master/config/dnc/DNC_MACROBOOK.lua` | `Tetsouo/config/dnc/DNC_MACROBOOK.lua` |
| `_master/config/dnc/DNC_STATES.lua` | `Tetsouo/config/dnc/DNC_STATES.lua` |
| `_master/config/dnc/DNC_TP_CONFIG.lua` | `Tetsouo/config/dnc/DNC_TP_CONFIG.lua` |
| `_master/config/dnc/DNC_WS_CONFIG.lua` | `Tetsouo/config/dnc/DNC_WS_CONFIG.lua` |
| `_master/config_global/LOCKSTYLE_CONFIG.lua` | `Tetsouo/config/LOCKSTYLE_CONFIG.lua` |
| `_master/config/pld/PLD_LOCKSTYLE.lua` | `Tetsouo/config/pld/PLD_LOCKSTYLE.lua` |
| `_master/config/pld/PLD_MACROBOOK.lua` | `Tetsouo/config/pld/PLD_MACROBOOK.lua` |
| `_master/Tetsouo/config/pld/PLD_REFILL.lua` | `Tetsouo/config/pld/PLD_REFILL.lua` |
| `_master/config/pld/PLD_STATES.lua` | `Tetsouo/config/pld/PLD_STATES.lua` |
| `_master/config/pld/PLD_TP_CONFIG.lua` | `Tetsouo/config/pld/PLD_TP_CONFIG.lua` |
| `_master/Tetsouo/config/smn/SMN_MACROBOOK.lua` | `Tetsouo/config/smn/SMN_MACROBOOK.lua` |
| `_master/Tetsouo/config/smn/SMN_STATES.lua` | `Tetsouo/config/smn/SMN_STATES.lua` |
| `_master/config/thf/THF_LOCKSTYLE.lua` | `Tetsouo/config/thf/THF_LOCKSTYLE.lua` |
| `_master/config/thf/THF_MACROBOOK.lua` | `Tetsouo/config/thf/THF_MACROBOOK.lua` |
| `_master/Tetsouo/config/thf/THF_REFILL.lua` | `Tetsouo/config/thf/THF_REFILL.lua` |
| `_master/config/thf/THF_STATES.lua` | `Tetsouo/config/thf/THF_STATES.lua` |
| `_master/config/thf/THF_TP_CONFIG.lua` | `Tetsouo/config/thf/THF_TP_CONFIG.lua` |
| `_master/config_global/UI_COLOR_CONFIG.lua` | `Tetsouo/config/UI_COLOR_CONFIG.lua` |
| `_master/config_global/UI_CONFIG.lua` | `Tetsouo/config/UI_CONFIG.lua` |
| `_master/config/war/WAR_LOCKSTYLE.lua` | `Tetsouo/config/war/WAR_LOCKSTYLE.lua` |
| `_master/config/war/WAR_MACROBOOK.lua` | `Tetsouo/config/war/WAR_MACROBOOK.lua` |
| `_master/Tetsouo/config/war/WAR_REFILL.lua` | `Tetsouo/config/war/WAR_REFILL.lua` |
| `_master/config/war/WAR_STATES.lua` | `Tetsouo/config/war/WAR_STATES.lua` |
| `_master/config/war/WAR_TP_CONFIG.lua` | `Tetsouo/config/war/WAR_TP_CONFIG.lua` |
| `_master/Tetsouo/config_global/WARDROBE_CONFIG.lua` | `Tetsouo/config/WARDROBE_CONFIG.lua` |
| `_master/Tetsouo/sets/blm/armor.lua` | `Tetsouo/sets/blm/armor.lua` |
| `_master/Tetsouo/sets/blm/blm_sets.lua` | `Tetsouo/sets/blm/blm_sets.lua` |
| `_master/Tetsouo/sets/brd/brd_sets.lua` | `Tetsouo/sets/brd/brd_sets.lua` |
| `_master/Tetsouo/sets/brd/instruments.lua` | `Tetsouo/sets/brd/instruments.lua` |
| `_master/Tetsouo/sets/bst/armor.lua` | `Tetsouo/sets/bst/armor.lua` |
| `_master/Tetsouo/sets/bst/bst_sets.lua` | `Tetsouo/sets/bst/bst_sets.lua` |
| `_master/Tetsouo/sets/cor/armor.lua` | `Tetsouo/sets/cor/armor.lua` |
| `_master/Tetsouo/sets/cor/cor_sets.lua` | `Tetsouo/sets/cor/cor_sets.lua` |
| `_master/Tetsouo/sets/dnc/armor.lua` | `Tetsouo/sets/dnc/armor.lua` |
| `_master/Tetsouo/sets/dnc/capes.lua` | `Tetsouo/sets/dnc/capes.lua` |
| `_master/Tetsouo/sets/dnc/dnc_sets.lua` | `Tetsouo/sets/dnc/dnc_sets.lua` |
| `_master/Tetsouo/sets/pld/armor.lua` | `Tetsouo/sets/pld/armor.lua` |
| `_master/Tetsouo/sets/pld/pld_sets.lua` | `Tetsouo/sets/pld/pld_sets.lua` |
| `_master/Tetsouo/sets/pld/weapons.lua` | `Tetsouo/sets/pld/weapons.lua` |
| `_master/Tetsouo/sets/thf/armor.lua` | `Tetsouo/sets/thf/armor.lua` |
| `_master/Tetsouo/sets/thf/weapons.lua` | `Tetsouo/sets/thf/weapons.lua` |
| `_master/entry/Tetsouo_BLM.lua` | `Tetsouo/Tetsouo_BLM.lua` |
| `_master/entry/Tetsouo_BRD.lua` | `Tetsouo/Tetsouo_BRD.lua` |
| `_master/entry/Tetsouo_BST.lua` | `Tetsouo/Tetsouo_BST.lua` |
| `_master/entry/Tetsouo_COR.lua` | `Tetsouo/Tetsouo_COR.lua` |
| `_master/entry/Tetsouo_DNC.lua` | `Tetsouo/Tetsouo_DNC.lua` |
| `_master/entry/Tetsouo_PLD.lua` | `Tetsouo/Tetsouo_PLD.lua` |
| `_master/Tetsouo/entry/Tetsouo_SMN.lua` | `Tetsouo/Tetsouo_SMN.lua` |
| `_master/entry/Tetsouo_THF.lua` | `Tetsouo/Tetsouo_THF.lua` |
| `_master/entry/Tetsouo_WAR.lua` | `Tetsouo/Tetsouo_WAR.lua` |
| `_master/config/alt/BLM_ALT_CUSTOM.lua` | `Tetsouo/config/alt/BLM_ALT_CUSTOM.lua` |
| `_master/config/alt/GEO_ALT_CUSTOM.lua` | `Tetsouo/config/alt/GEO_ALT_CUSTOM.lua` |
| `_master/config/alt/RDM_ALT_CUSTOM.lua` | `Tetsouo/config/alt/RDM_ALT_CUSTOM.lua` |
| `_master/config/alt/SCH_ALT_CUSTOM.lua` | `Tetsouo/config/alt/SCH_ALT_CUSTOM.lua` |
| `_master/config/alt/SMN_ALT_CUSTOM.lua` | `Tetsouo/config/alt/SMN_ALT_CUSTOM.lua` |
| `_master/config/alt/BLM_ALT_CUSTOM.lua.example` | `Tetsouo/config/alt/BLM_ALT_CUSTOM.lua.example` |
| `_master/config/alt/COR_ALT_CUSTOM.lua.example` | `Tetsouo/config/alt/COR_ALT_CUSTOM.lua.example` |
| `_master/config/alt/GEO_ALT_CUSTOM.lua.example` | `Tetsouo/config/alt/GEO_ALT_CUSTOM.lua.example` |
| `_master/config/alt/RDM_ALT_CUSTOM.lua.example` | `Tetsouo/config/alt/RDM_ALT_CUSTOM.lua.example` |
| `_master/config/alt/SCH_ALT_CUSTOM.lua.example` | `Tetsouo/config/alt/SCH_ALT_CUSTOM.lua.example` |
| `_master/config/alt/WHM_ALT_CUSTOM.lua.example` | `Tetsouo/config/alt/WHM_ALT_CUSTOM.lua.example` |

À noter :

- **Hysoka** : `Hysoka/Hysoka_{DRK,GEO,RUN}.lua` viennent aussi des entrées modifiées (`_master/entry/Tetsouo_{DRK,GEO,RUN}.lua`). C'est un clone figé : ne rien faire sans décision.
- **Overlays Kaories en retard sur les modèles génériques** : les 15 fichiers `_master/Kaories/config/{cor,geo,rdm}/*` (hors REFILL) avaient **exactement** le même contenu que les modèles génériques (seules les fins de ligne différaient : LF côté overlay). 12 d'entre eux ont maintenant des commentaires en retard sur le générique corrigé cette nuit : COR `LOCKSTYLE, MACROBOOK, STATES, TP_CONFIG`, GEO `KEYBINDS, LOCKSTYLE, MACROBOOK, STATES, TP_CONFIG`, RDM `KEYBINDS, SABOTEUR_CONFIG, STATES, TP_CONFIG`. Je n'ai pas pu recopier automatiquement (écriture refusée par le garde-fou d'outils). Correctif proposé : pour chacun, recopier `_master/config/<job>/<fichier>` vers `_master/Kaories/config/<job>/<fichier>` en gardant les fins de ligne LF, puis vers `Kaories/config/<job>/`. Vérification : `diff <(tr -d '\r' < A) <(tr -d '\r' < B)` doit être vide.
- Les sets plats de `_master/sets/` n'ont pas de copie live chez Tetsouo, qui utilise les sets modulaires. Chez Kaories, les sets viennent de l'overlay `_master/Kaories/sets/`, qui a été corrigé lui aussi (listé ci-dessus).


### Sous-zone B — `_master/config/{blm,brd,bst,cor,dnc,drk,geo}/`

Tetsouo : tous les fichiers modifiés de blm, brd, bst, cor, dnc sous `Tetsouo/config/...`.
Kaories : `Kaories/config/cor/COR_{LOCKSTYLE,MACROBOOK,STATES,TP_CONFIG}.lua`, `Kaories/config/geo/GEO_{KEYBINDS,LOCKSTYLE,MACROBOOK,STATES,TP_CONFIG}.lua` (mais Kaories est construit depuis l'overlay `_master/Kaories/`, à vérifier). DRK : pas de copie live Tetsouo/Kaories.

## Bugs suspectés

### Sous-zone A — fichiers d'entrée (`_master/entry/`, `_master/Tetsouo/entry/`, `_master/Kaories/entry/`)

1. **La couleur « orange » liée à la région est ignorée dans 18 des 20 entrées.** Fichiers : toutes les entrées sauf WAR et SMN. Exemple : `_master/entry/Tetsouo_BLM.lua:57-66`.
   - Le module `message_colors` lit `_G.RegionConfig` une seule fois, au moment où il est chargé (`shared/utils/messages/message_colors.lua:31`).
   - Or `ConfigLoader` (`config_loader.lua:16`) le charge **avant** que l'entrée ne pose `_G.RegionConfig`. Pour COR et SAM, c'est encore plus tard, dans `get_sets`.
   - Effet : `REGION_CONFIG` n'est jamais pris en compte, donc un personnage EU reçoit le code orange US (057).
   - Aucun effet visible pour Tetsouo, qui est US.
   - Correctif : charger `REGION_CONFIG` avant `ConfigLoader`, comme le font WAR et SMN.
2. **Le template BST est en retard sur le live.** `_master/entry/Tetsouo_BST.lua` diffère de 196 lignes de `Tetsouo/Tetsouo_BST.lua`.
   - Le live surveille le pet via un événement `prerender`, laisse AutoMove gérer le mouvement, et fait l'appel dualbox depuis `user_setup`.
   - Le template garde l'ancienne boucle `coroutine.schedule`, qui gère aussi `state.Moving`. Or son propre commentaire (l.55-57) dit que seul AutoMove maintient `state.Moving` : deux écrivains se disputeraient cet état.
   - Un `clone_character.py` de Tetsouo **régresserait** BST, car il n'y a pas d'overlay `_master/Tetsouo/entry/Tetsouo_BST.lua`.
   - Correctif : copier le live dans `_master/Tetsouo/entry/` (ou dans le template générique).
3. **PUP ne peut pas charger.** `_master/entry/Tetsouo_PUP.lua:59-60` fait un `require` sans `pcall` de `config/pup/PUP_PET_DATA` et `PUP_TP_CONFIG`, alors que `_master/config/pup/` n'existe pas.
   - Le fichier référence aussi `shared/jobs/pup/functions/logic/ecosystem_manager` et `pet_manager`, qui n'existent pas.
   - Déjà connu. À finir ou à retirer.
4. **La config TP de RUN n'est jamais chargée.** `_master/entry/Tetsouo_RUN.lua:100` : la ligne est commentée, et le nom de global y est faux (`RUNTPCONFIG` au lieu de `RUNTPConfig`).
   - `RUN_PRECAST` reçoit donc `{}` : pas de bonus TP ni de réglages WS de `RUN_TP_CONFIG.lua`. C'est documenté dans `RUN_PRECAST.lua:42`.
   - Correctif : `require('Tetsouo/config/run/RUN_TP_CONFIG')` (le fichier pose lui-même `_G.RUNTPConfig`).
5. **Macrobook et lockstyle déclenchés deux fois au chargement de COR.** `_master/entry/Tetsouo_COR.lua:283-287` puis `:308-318`.
   - Deux appels de `select_default_macro_book()` et deux lockstyles planifiés (le second avec le flag du watchdog).
   - Probablement absorbé par le délai de 15 s du lockstyle, mais c'est du travail en double.
   - Correctif : garder un seul bloc.
6. **Message d'erreur différent entre template et live.** `_master/entry/Tetsouo_PLD.lua:204` affiche `'PLD keybinds failed to load: '` ; le live affiche `'[PLD] Keybinds failed to load: '`.
   - Petite divergence de chaîne affichée ; non modifiée, car c'est du comportement.

### Sous-zone B — `_master/config/{blm,brd,bst,cor,dnc,drk,geo}/`

- `cor/COR_TP_CONFIG.lua:33-54` — `get_weapon_bonus()` cherche le nom dans `ranged_weapons`, mais `shared/utils/precast/tp_bonus_handler.lua:56` lui passe l'arme **main** (`player.equipment.main`). Anarchy/Fomalhaut ne sont donc jamais reconnus : le calcul croit qu'il manque du TP et peut mettre Moonshade pour rien. Correctif : dans la config COR, tester aussi `player.equipment.range`, ou faire passer l'arme de tir par le handler pour les WS à distance.
- `blm/BLM_TP_CONFIG.lua:21` — Moonshade est déclaré en `BLMTPConfig.moonshade`, alors que le calculateur ne lit que `tp_config.pieces` (`tp_bonus_calculator.lua:109`). Sur BLM, Moonshade n'est jamais ajouté automatiquement. Correctif : `pieces = { { slot = 'ear1', name = 'Moonshade Earring', bonus = 250 } }` comme les autres jobs.
- `bst/BST_PET_DATA.lua:118-170` — les listes d'espèces et de familiers sont construites avec `pairs()` sur une table à clés texte : l'ordre n'est **pas** celui du fichier (le commentaire disait le contraire). Le cycle `species`/familier dans le HUD suit donc un ordre arbitraire. Correctif : une liste ordonnée des noms (tableau) à côté de la table.
- `bst/BST_TP_CONFIG.lua:112-121` — en /NIN ou /DNC, tout objet en main gauche (même un bouclier comme Adapa Shield ou Diamond Aspis, présents dans `state.SubSet`) coupe le bonus Fencer. Or Fencer s'applique avec un bouclier. Correctif : tester si l'objet en sub est un bouclier (catégorie via `res.items`) avant de conclure au dual-wield.
- `blm/BLM_LOCKSTYLE.lua` et `brd/BRD_LOCKSTYLE.lua` — `by_subjob` n'est jamais lu : `LockstyleManager` n'utilise que `.default` et `.get_style()`. Sans effet aujourd'hui (toutes les valeurs = défaut), mais changer une valeur ne ferait rien. Correctif : ajouter `get_style()` comme BST/COR/DNC.

### Sous-zone C — `_master/config/{pld,rdm,run,sam,thf,war,whm}/`

- **`pld/PLD_BLU_MAGIC.lua:104` et `run/RUN_BLU_MAGIC.lua:104`** : `windower.ffxi.get_mjob_data()` lit les données du job **principal**. Sur PLD/BLU ou RUN/BLU, BLU est le sous-job : il faudrait `get_sjob_data()`. Conséquence probable : la détection « dynamique » des sorts bleus équipés ne trouve jamais rien, et la rotation manuelle sert toujours. Sans gravité, puisque cette rotation contient les mêmes 5 sorts, mais tout le code dynamique ne sert à rien. Correctif suggéré : `get_sjob_data()`, à tester en jeu.
- **`shared/utils/ui/ui_lifecycle.lua:59`** (hors zone, trouvé en vérifiant THF) : l'état ancre de RUN est `state.RuneElement`, alors que RUN_STATES crée `state.RuneMode`. L'interface RUN attend donc son délai maximal (~3 s de temps CPU `os.clock`) avant de s'initialiser. Correctif : remplacer `RuneElement` par `RuneMode` (vérifier aussi `UI_DISPLAY_BUILDER.lua:27`).
- **`run/RUN_MACROBOOK.lua:38,57,63,69` et `run/RUN_LOCKSTYLE.lua:35`** : copiés de PLD. On y trouve un sous-job `['RUN']` (RUN/RUN est impossible) et les mêmes livres que PLD (15-20), donc RUN et PLD partagent leurs macros. Aucun changement fait, car ce sont des numéros. À décider par le propriétaire.
- **`thf/THF_TP_CONFIG.lua:46`** : Centovente figure dans `weapons`, que le calculateur ne compare qu'à l'arme **principale** (`tp_bonus_calculator.lua:63`). Or Centovente est l'arme secondaire par défaut de THF (`THF_STATES` SubWeapon). Son bonus de TP n'est donc probablement jamais compté. À vérifier : quel slot donne le bonus de Centovente.

### Sous-zone D — `_master/config/alt/`, `config_global/`, configs des overlays Kaories/Tetsouo

- `_master/config_global/UI_COLOR_CONFIG.lua` `get_bar_element_color()` : lit `bar_spells.element`, qui n'existe pas → planterait si appelée. Sans effet aujourd'hui (personne ne l'appelle). Correctif : supprimer les fonctions d'aide (voir code mort).
- Live `Tetsouo/config/UI_CONFIG.lua` et `Kaories/config/UI_CONFIG.lua` (hors zone, réécrits cette nuit) citent `//gs c uisave` : cette commande n'a pas de gestionnaire (seul `//gs c ui save` / `ui s` existe, `UI_COMMANDS.lua:47`). Même erreur dans `shared/utils/ui/UI_MANAGER.lua:28`. Correctif : remplacer par `//gs c ui save`.
- `_master/config_global/ui_settings.lua` : fichier « auto-généré » qui contient la position écran et le chemin absolu de Tetsouo (`pos_x = 1946`, `D:\Windower Tetsouo\...`). Le clone le copie tel quel à tout nouveau personnage : le HUD d'un clone démarre à la position de Tetsouo. Peu grave. Correctif : soit ne pas le livrer dans `config_global/` (il est recréé au premier réglage), soit y mettre les valeurs de `UI_CONFIG.lua`.

### Sous-zone E — sets plats (`_master/sets/`, `_master/Kaories/sets/`)

- `_master/sets/blm_sets.lua:239-245` — `sets.precast.FC.Stoneskin = set_combine(sets.MoveSpeed, {body = "Councilor's Garb"})`. Deux problèmes : `sets.MoveSpeed` n'est défini qu'à la ligne 580, il vaut donc `nil` à ce moment-là, et même défini ce serait un set de déplacement. Résultat : le précast de Stoneskin n'a **aucun** équipement Fast Cast, juste le Councilor's Garb. Le live Tetsouo (`Tetsouo/sets/blm/blm_sets.lua:145`) fait `set_combine(sets.precast.FC, {...})`, ce qui confirme l'intention. Correctif : remplacer `sets.MoveSpeed` par `sets.precast.FC` dans le template (à valider par le joueur, c'est du gear).
- `_master/sets/pup_sets.lua:13` — le fichier ne fait que définir `define_pup_sets()`, que personne n'appelle (0 appelant). Même si PUP chargeait, aucun set ne serait créé par ce fichier. Sans conséquence aujourd'hui (PUP ne charge pas, fait connu).

### Sous-zone F — sets modulaires Tetsouo (`_master/Tetsouo/sets/**`)

- **Overlay WAR et THF périmé : un clone effacerait du travail.** `Tetsouo/sets/war/*.lua` (4 fichiers, modifiés le 2026-09-23) et `Tetsouo/sets/thf/thf_sets.lua` (2026-09-23) sont plus récents que leur copie dans `_master/Tetsouo/sets/`. Les écarts sont les suivants :
  - `war_sets.lua` : 636 lignes de diff (sets engagés par arme et par stance, Hoxne).
  - `capes.lua` : clé renommée de `LessEnmnity` en `LessEnmity`.
  - `thf_sets.lua` : Cacoethic Ring devient Cacoethic Ring +1, aux lignes 236 et 644.

  C'est exactement le scénario du §1.1 du plan de maintenabilité, cette fois pour WAR et THF. Un `clone_character.py` sur Tetsouo remettrait l'ancienne version. **Correctif :** copier le live vers `_master/Tetsouo/sets/war/` et `thf/thf_sets.lua`, puis committer. Vérifier aussi `_master/config/war/` et les autres fichiers WAR, que cette zone n'a pas examinés.

## Doutes / à décider

### Sous-zone A — fichiers d'entrée (`_master/entry/`, `_master/Tetsouo/entry/`, `_master/Kaories/entry/`)

- `_master/Kaories/entry/Kaories_PLD.lua` : n'a ni `PLD_WS_CONFIG`, ni `pld_rebuild_ws_slots`, ni `AmpullaLock` (le template Tetsouo les a). Voulu pour Kaories ou en retard ?
- `_master/entry/Tetsouo_PUP.lua:244-249` : le nettoyage de `_G.pup_time_change_event_id` « si rechargement » ne peut rien trouver, car `_G` est neuf à chaque chargement. C'est GearSwap qui désenregistre les événements utilisateur. Sans effet, mais le commentaire est trompeur (non modifié, fichier inachevé).
- `_master/entry/Tetsouo_BLM.lua:14-22` et `_master/entry/Tetsouo_RDM.lua:14-22` : « Fast Cast cap 80% », « Convert HP/MP management » et « Chainspell burst mode » restent non vérifiés (conservés).
- La DNC live garde `[Equipment Sets - Modular]` dans son en-tête, la template `[Equipment Sets]` : divergence voulue (sets plats contre modulaires).

### Sous-zone B — `_master/config/{blm,brd,bst,cor,dnc,drk,geo}/`

- `dnc/DNC_MACROBOOK.lua` et `drk/DRK_MACROBOOK.lua` (`solo['default']`) — `macrobook_manager.lua:73` écrase `solo['default']` par `.default`. Aujourd'hui les deux valeurs sont égales ; supprimer l'entrée `solo['default']` pour éviter la confusion ?
- `geo/GEO_STATES.lua` (Languor, Vex, Fade) — commentaires d'effet laissés tels quels : de mémoire Languor = Évasion magique-, Vex = Précision magique-, Fade = Attaque magique-, mais la base `shared/data/magic/geomancy/geomancy_indi.lua` dit autre chose (et semble elle-même fausse pour Attunement/Fend). À vérifier sur BG-wiki avant de toucher.
- `drk/DRK_STATES.lua:58` — « Caladbolg (Great Sword REMA) » : non vérifié, laissé.
- Tous les `*_CUSTOM.lua` n'ont pas le bloc d'en-tête standard (@file/@author/@version/@date). Laissés car générés (`gen_custom.py`) : l'ajouter dans le générateur plutôt qu'à la main.
- Les overlays Kaories (`_master/Kaories/config/cor|geo/`) ont probablement les mêmes commentaires périmés que les templates génériques corrigés ici (hors de ma sous-zone).

### Sous-zone C — `_master/config/{pld,rdm,run,sam,thf,war,whm}/`

- `pld/PLD_CUSTOM.lua:104` : l'exemple commenté utilise `^numpad7`, qui figure dans `PLD_KEYBINDS.retired_keys`, une liste désassociée à chaque chargement. Un joueur qui active cet exemple risque de voir sa touche désassociée, selon l'ordre de traitement. Choisir une autre touche d'exemple ? Je n'y ai pas touché, c'est le manuel du jour.
- Les en-têtes `*_CUSTOM.lua` n'ont ni `@file`, ni `@author`, ni `@date`. C'est voulu (manuel joueur), donc je les ai laissés.
- `WAR_KEYBINDS.lua`, `PLD_KEYBINDS.lua`, `RUN_KEYBINDS.lua` : mise en forme irrégulière. Les commentaires de section sont collés après `},` et l'indentation mélange entrées sur une ligne et sur plusieurs. Je ne l'ai pas reformatée, les fichiers ayant été écrits aujourd'hui.
- `sam/SAM_STATES.lua:55-60` et `run/RUN_STATES.lua:58-62` : les commentaires sur les effets d'arme (Aftermath, +40 % Impulse Drive…) ne sont pas vérifiables depuis le code. Laissés tels quels. `RUN_STATES` qualifie Lycurgos de « Great Axe », ce qui est probablement faux (épée à deux mains ?). À confirmer.
- `pld/PLD_WS_CONFIG.lua:16-17` : « Chant du Cygne, a weaponskill any sword can swing » n'est vrai qu'une fois la WS débloquée (quête Magian). Laissé tel quel.
- `rdm/RDM_TP_CONFIG.lua:122,155-159` : Crocea Mors est qualifiée de « REMA rapier », ce qui est douteux. Ce ne sont que des lignes commentées, je les ai laissées.

### Sous-zone D — `_master/config/alt/`, `config_global/`, configs des overlays Kaories/Tetsouo

- `_master/config_global/RECAST_CONFIG.lua:29` : le commentaire recommande 1,5 s « (RECOMMENDED) » et qualifie 2,0 s d'« agressif », alors que la valeur choisie est 2,0 (décision de l'audit 2026-06-09). Mettre à jour le commentaire pour refléter ce choix ?
- `_master/Kaories/config_global/{DUALBOX,REGION}_CONFIG.lua` et `_master/Tetsouo/config_global/{DUALBOX,REGION}_CONFIG.lua` : toujours écrasés par l'étape 6 du clone ; ceux de Kaories sont la sortie exacte du générateur, donc laissés tels quels (sans @author/@date). Faut-il garder ces overlays, puisqu'ils ne servent jamais ?
- Couleur orange EU : l'overlay Tetsouo `REGION_CONFIG.lua` renvoie `003`, le générateur du clone (et donc Kaories) renvoie `002`. Laquelle est juste ? (déjà noté dans docs/dev/architecture/characters-and-templates.md).
- `_master/Tetsouo/config/smn/SMN_KEYBINDS.lua` : deux titres de section vides (« JOB ABILITIES », « AVATAR SUMMONS ») — espaces réservés voulus ou à retirer ? Laissé (fichier écrit aujourd'hui).
- `*_CUSTOM.lua` (dont `SMN_CUSTOM.lua`) : pas de balises `@file/@author/@version/@date`. Laissé volontairement (manuel joueur généré aujourd'hui).
- `_master/Tetsouo/config/smn/SMN_LOCKSTYLE.lua` : doc « Lockstyle number (1-200) » alors que `lockstyle_manager.lua` dit « 0-99 ». Quelle borne est juste ?
- `_master/config/alt/*_ALT_COMMANDS.lua` : le générateur n'est pas dans le dépôt suivi (`scripts/` est gitignoré) — en cas de perte, on ne peut plus régénérer.

### Sous-zone E — sets plats (`_master/sets/`, `_master/Kaories/sets/`)

- `_master/sets/sam_sets.lua` — `shared/jobs/sam/functions/logic/set_builder.lua:100` lit `sets.seigan` (Seigan en mode Normal), qui n'est défini nulle part dans le template. Le code est protégé (`if sets.seigan`), donc rien ne casse, mais la branche ne fait rien. Faut-il un set Seigan ?
- `_master/sets/sam_sets.lua:~350-420` — les commentaires WS (« Tachi: Mumei (magic-based) », « Tachi: Shoha (light skillchain) », « Tachi: Koki (darkness skillchain) ») me semblent douteux côté jeu, mais je ne les ai pas changés sans certitude.
- `_master/sets/rdm_sets.lua:~209`, `drk_sets.lua:573`, `rdm_sets.lua:531`, `sam_sets.lua:494`, `war_sets.lua:538` — affirmations de jeu non vérifiables dans le code (« Viti. Tabard double la durée de Chainspell », « Nicander's retire Doom à 100 % (10/10) »). Laissées telles quelles.
- `_master/sets/brd_sets.lua`, `blm_sets.lua`, `run_sets.lua`, `whm_sets.lua` — plusieurs variantes sont des copies vides (`set_combine(x, {})` : BRD STP/Acc/SB/PDTKC, RUN PDT, WHM engaged PDT...). Voulu comme emplacements, ou à remplir ?
- Clone : quand Kaories est cloné depuis la source par défaut, `@author Tetsouo` devient `@author Kaories` dans les copies live (substitution texte de `clone_character.py`). Connu, hors de ma zone.

### Sous-zone F — sets modulaires Tetsouo (`_master/Tetsouo/sets/**`)

- `pld/armor.lua:47-53` : l'étiquette Relic de Caballarius et l'étiquette Artifact de Reverence sont corrigées, mais le commentaire « JA enhancement bodies » (ligne 9) reste vague. À laisser tel quel.
- `brd/armor.lua:8` : Mousai est décrit comme « Mythic Reforged », sans doute à tort. Pas corrigé, car l'origine exacte n'est pas certaine.
- En-têtes des `*_sets.lua` modulaires : le `@version` va de 2.0 à 4.1 et continue la numérotation des anciens fichiers plats. Le `Created` retenu est la date du découpage modulaire. À ajuster si le propriétaire préfère la date d'origine du fichier plat.
- `pld/pld_sets.lua:339-340` : « Focuses on Store TP reduction to leverage Kraken Club » est ambigu. On ne sait pas si l'intention est de réduire le Store TP. Pas modifié.

## Code mort probable

### Sous-zone A — fichiers d'entrée (`_master/entry/`, `_master/Tetsouo/entry/`, `_master/Kaories/entry/`)

- `_master/entry/Tetsouo_RUN.lua:222-230` : appel `WarpInit.init()` commenté. `grep -n WarpInit shared/utils/core/INIT_SYSTEMS.lua` montre que l'init globale se fait à la ligne 213, donc ce bloc ne servira plus.
- `_master/entry/Tetsouo_RUN.lua:100-101` : `--_G.WardConfig = require('.../RUN_WARD_CONFIG')`. `ls _master/config/run` montre qu'il n'y a aucun `RUN_WARD_CONFIG.lua` ; le fichier n'existe pas.
- `_master/config/run/RUN_TP_CONFIG.lua` : `grep -rn RUN_TP_CONFIG shared _master` ne trouve que la ligne commentée de l'entrée. Le fichier n'est jamais chargé (voir Bugs n°4).
- `_master/entry/Tetsouo_PUP.lua` (fichier entier) : aucun personnage ne déploie PUP (`character_db`), et le fichier ne peut pas charger.

### Sous-zone B — `_master/config/{blm,brd,bst,cor,dnc,drk,geo}/`

- `*States.validate()` (BLM, BRD, COR, DNC, DRK, GEO) — `grep -rn "States\.validate\|\.validate()" shared _master/entry _master/Kaories/entry _master/Tetsouo/entry` : 0 appel.
- `bst/BST_ECOSYSTEM_DATA.lua` (fichier entier) — `grep -rln "ECOSYSTEM_DATA\|BSTEcosystemData"` sur tout `data/` (.lua et .py) : aucun autre fichier.
- `cor/COR_MACROBOOK.lua:57` `get_macrobook()` — seules occurrences : ses 4 définitions (template, overlay Kaories, 2 live), 0 appel.
- Champ `.style` des lockstyles COR/DNC/DRK/GEO — `grep -rn "LockstyleConfig\.style\|Config\.style\b" shared` : 0.
- `dnc/DNC_STATES.lua` `state.CombatWeaponMode` — `grep -rn CombatWeaponMode shared` : 0.
- `brd/BRD_TIMING_CONFIG.lua` — seuls `SONG_DELAYS` (via `get_song_delay`) et `ABILITY_DELAYS.nt_combo_delay` sont lus ; `ROTATION_DELAYS`, `ADJUSTMENTS`, `get_initial_delay`, `apply_adjustments`, et les autres `ABILITY_DELAYS` : 0 lecture (`grep -rn "ROTATION_DELAYS\|ADJUSTMENTS\|apply_adjustments\|get_initial_delay\|marcato_initial\|pianissimo_delay" shared`).
- `blm/BLM_TP_CONFIG.lua` `BLMTPConfig.moonshade` — champ jamais lu (voir bug).

### Sous-zone C — `_master/config/{pld,rdm,run,sam,thf,war,whm}/`

- **`<JOB>States.validate()`** dans PLD, RDM, RUN, SAM, THF, WAR et WHM : aucun appelant. `grep -rn "States.validate(" shared _master Tetsouo Kaories` ne trouve que des commentaires d'en-tête.
- **`<JOB>LockstyleConfig.style`** (« BACKWARD COMPATIBILITY »), dans `PLD/RUN/WAR_LOCKSTYLE.lua` : personne ne le lit. `grep -rn "LockstyleConfig\.style\|Config\.style" shared _master Tetsouo Kaories` ne trouve que les affectations. `lockstyle_manager.lua:180-186` passe par `default` et `get_style()`.
- **`PLD_BLU_MAGIC.get_info()` et `is_dynamic()`** (idem RUN) : `get_info` n'a aucun appelant externe. Les seuls `get_info()` trouvés par grep sont `windower.ffxi.get_info` et `lockstyle.get_info` : ce sont d'autres fonctions, pas celle de BLU_MAGIC. `is_dynamic` n'est appelé que par `get_info`. Seul `get_rotation()` est utilisé (`pld|run/functions/logic/aoe_manager.lua:114`).
- **`WHM_CURE_CONFIG.auto_tier_enabled` et `.message_color`** : jamais lus. `grep -o "WHMCureConfig\.[a-z_]*" shared/utils/whm/cure_manager.lua` ne renvoie que `cure_tiers`, `curaga_tiers`, `safety_margin` et `debug_messages`. L'activation de l'auto-tier passe par `state.CureAutoTier`.
- **Duplication** : `RUN_BLU_MAGIC.lua` est identique à `PLD_BLU_MAGIC.lua`, au nom du module près (vérifié avec `diff` après substitution du nom).

### Sous-zone D — `_master/config/alt/`, `config_global/`, configs des overlays Kaories/Tetsouo

- `LOCKSTYLE_CONFIG.job_change_delay` et `.cooldown` : `grep -rn "job_change_delay\|LockstyleConfig\.cooldown" shared` → 0 lecture ; seuls les tableaux de secours des fichiers d'entrée les définissent.
- `UI_CONFIG` : `colors`, `auto_save_position`, `auto_save_delay`, `debug`, `update_throttle`, `UIConfig.validate()`, `UIConfig.print_config()` → 0 référence dans `shared/` (`print_config` avait déjà été annoncée supprimée le 2026-05-17 : elle est toujours dans le template).
- `UI_COLOR_CONFIG` : `rgb_to_code`, `get_element_color`, `get_stat_color`, `get_bar_element_color`, `get_bar_ailment_color`, `get_mode_color`, `get_special_color`, `validate`, et la table `jobs.runes` → `grep -rn "UIColorConfig\." shared` ne trouve que `COLOR_SYSTEM.lua`, qui lit uniquement les tables de données.
- `_master/Tetsouo/config_global/REGION_CONFIG.lua` `region_info` → `grep -rn region_info shared` = 0.
- `COLOR_SYSTEM.lua` `special_colors.bar_ailment` (donc `bar_spells.ailment`) : écrit mais jamais utilisé pour colorer les Bar-ailment (hors zone, à confirmer).

### Sous-zone E — sets plats (`_master/sets/`, `_master/Kaories/sets/`)

- `define_pup_sets()` — `_master/sets/pup_sets.lua` : `grep -rn define_pup_sets` → seule la définition, aucun appel.
- `sets.AeolianTH` — `_master/sets/thf_sets.lua:~909` : `grep -rln AeolianTH shared` → aucun résultat.
- `sets.midcast.EnhancingMagic` — `_master/sets/thf_sets.lua:~830` : `grep -rln "EnhancingMagic" shared` → aucun résultat (MidcastManager cherche la clé `'Enhancing Magic'` avec un espace).
- Hors zone, en passant : fichier parasite `shared/utils/midcast/midcast_manager.lua.preref.bak`.

### Sous-zone F — sets modulaires Tetsouo (`_master/Tetsouo/sets/**`)

Il s'agit d'entrées déclarées dans les fichiers compagnons mais jamais utilisées par le `<job>_sets.lua` du même job. Recherche `grep -c "\b<clé>\b" <job>/<job>_sets.lua`, résultat 0 pour chacune, et aucun autre fichier de `_master/`, `Tetsouo/` ou `shared/` ne les lit via ce module.

Sans danger en jeu, mais **l'auditeur de garde-robe (`//gs c wa`) scanne ces fichiers** (wardrobe_auditor.lua:77-86, 210-225). Ces pièces y apparaissent donc comme « utilisées » alors qu'aucun set ne les porte.

| Fichier | Clé(s) inutilisée(s) |
|---|---|
| `brd/armor.lua` | `Nyame.body_b` |
| `bst/armor.lua` | `EliteRoyal`, `Ferine`, `Ilabrat` |
| `cor/armor.lua` | `Nyame.body_b`, `Nyame.hands_b` |
| `dnc/armor.lua` | `Misc.BlisteringSallet`, `chausses_p2`, `knife`, `wrist_p1` |
| `dnc/capes.lua` | `Senuna.plain` |
| `pld/armor.lua` | `Misc.SapienceOrb` |
| `thf/armor.lua` | `Misc.SamnuhaTights` |

À décider : les retirer, ou les garder comme réserve d'équipement. Ils n'ont pas été supprimés, puisque les fichiers de sets ne contiennent que des données de gear.

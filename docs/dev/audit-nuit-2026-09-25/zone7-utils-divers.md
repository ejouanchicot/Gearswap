# Audit de nuit 2026-09-25 — Zone 7 : `shared/utils/` divers

Périmètre : `shared/utils/{debuff, precast, midcast, weaponskill, whm, craft, scholar, movement, lockstyle, macrobook, drg, dnc, buffs, mount, set_building, smartbuff, data}` — 31 fichiers.

Règle suivie : **aucun changement de comportement**. Seuls les commentaires, les en-têtes, la doc `@param`/`@return` et trois variables locales jamais utilisées ont été touchés. Chaque fichier modifié a été revérifié avec `lua5.1 loadfile` (31/31 OK), et les fins de ligne d'origine (CRLF ou LF) sont conservées. Rien n'a été commité.

Pour contrôler : `git diff -- shared/utils/<dossier>`. Toutes les lignes de code modifiées se résument à : suppression de `DOOM_SLOTS` (doom_manager), de `get_formatter` et de son `MessageFormatter` (tp_bonus_handler), et de `hpp` dans `select_cure_tier` (cure_manager), plus le déplacement d'une ligne `local shared_recast_cache = {}` au-dessus de son bloc de doc (ability_helper).

---

## Fait

**debuff/**
- `doom_manager.lua` : variable locale `DOOM_SLOTS` jamais utilisée retirée ; commentaires qui répétaient le code retirés ; le « pourquoi » de l'ordre `equip` → `disable` (et `enable` → ré-équipement) est désormais expliqué ; « 15 jobs » corrigé.
- `auto_medicine.lua` : la doc de `init()` disait « appelée par INIT_SYSTEMS ». En réalité, ce sont les `[JOB]_STATES.lua` qui l'appellent, et INIT_SYSTEMS n'appelle que `ensure()`. Doubles lignes vides retirées.
- `precast_guard.lua` : « from config with validation » était faux (aucune validation n'a lieu) ; commentaires-bruit retirés ; doc de `check_magic` / `guard_precast` : `spell.type` ne vaut jamais `'Magic'` (voir Bugs).
- `debuff_checker.lua` : l'en-tête listait 3 buffs de test sur 4 (Defender manquait) ; la doc de `is_incapacitated` (bloquants universels seulement) et de `get_all_active_blocks` (ignore WS et objets) est corrigée ; « buffactive uses lowercase names » remplacé par « insensible à la casse ».

**precast/**
- `ws_validator.lua`, `ws_precast_handler.lua`, `cooldown_checker.lua`, `ability_helper.lua` : en-tête standard rétabli (l'ancien avait été supprimé par le commit e8b6f57, dates retrouvées dans git) ; doc de toutes les fonctions publiques ; commentaires-bruit retirés.
- `cooldown_checker.lua` : le commentaire « SCH Stratagems (5 charges) - All variants » était faux (voir Doutes). Le rôle de `suppress_cooldown_messages` est précisé : c'est la commande FBC du THF qui l'active, et le drapeau saute tout le contrôle, pas seulement le message.
- `ability_helper.lua` : le bloc de doc de `has_shared_recast` était collé sur la variable de cache, il est remis sur la fonction ; le commentaire sur les stratagèmes est précisé (tous les stratagèmes partagent recast 231, vérifié dans res).
- `tp_bonus_handler.lua` : en-tête complété ; la fonction locale `get_formatter` et son `MessageFormatter`, jamais utilisés, sont retirés.
- `tier_refiner.lua` : les chemins de l'en-tête sont corrigés (`shared/jobs/...`, `shared/data/...`).

**midcast/**
- `midcast_manager.lua` : l'en-tête annonçait une « 9-level fallback chain : spell name > skill > type > target > mode > base », ce qui est faux. Il décrit maintenant la vraie chaîne P0 à P9 (table `RESOLVERS`) et la chaîne Singing. « 9-PRIORITY » devient « P0-P9 ». Doc `@param`/`@return` ajoutée.
- `midcast_deps.lua` : rien à changer (le « sept jobs » est vérifié : COR, DNC, DRK, SAM, THF, WAR, WHM).

**weaponskill/**
- `weaponskill_manager.lua` : `@module` devient `@file` ; la mention « Based on RANGE_MANAGER » (obsolète) est retirée. Le commentaire « MessageFormatter will be set by the caller » était faux : rien ne l'assigne jamais. `distance_check_enabled` est signalé comme jamais lu.
- `tp_bonus_calculator.lua` : `@module` devient `@file`. La doc de `calculate()` était collée sur `effective_tp()`, elle est remise au bon endroit. Il est noté que `get_final_tp` ne compte pas Fencer.
- `ws_slots.lua` : alignement de l'en-tête.

**whm/**
- `cure_manager.lua` : l'en-tête disait « Stoneskin : force le tier MAX », or le code force le tier le PLUS BAS quand la cible a tous ses PV. L'exemple utilisait `cast_spell`, qui n'existe pas, et `@file` était faux. La variable locale `hpp` inutilisée est retirée ; les docs « Extracted from… » sont réécrites.
- `whm_message_formatter.lua` : `@file` corrigé ; note sur l'exception `add_to_chat` (CODE_QUALITY §6.3).

**Autres**
- `craft/craft_manager.lua` : en-tête complété. Le commentaire « package.loaded peut être invalidé » était faux : c'est le `require` de GearSwap qui ne met rien en cache sans ModuleCache. Doc `@param`/`@return` ajoutée.
- `craft/craft_commands.lua` : en-tête complété ; la doc de `handle_craft` (variante par défaut = `default` du fichier, pas « hq ») et de `handle_uncraft` est corrigée.
- `scholar/scholar_actions.lua` : l'en-tête ne décrivait que Light Arts/Sneak, il couvre maintenant tout le module ; `@return void` retiré.
- `scholar/stratagem_charges.lua`, `mount/mount_manager.lua`, `smartbuff/subjob_war_buffs.lua`, `drg/auto_jump.lua` : alignement de l'en-tête et petites docs.
- `movement/automove.lua` : `@file` corrigé. « C++ object field » était faux : c'est un champ de la table `windower`, qui survit au sandbox. Le commentaire du self-heal, qui prêtait à confusion, est clarifié ; doc des helpers ajoutée.
- `lockstyle/lockstyle_manager.lua` et `macrobook/macrobook_manager.lua` : le commentaire de `last_registered_globals` (« survit au changement de job car package.loaded… ») était faux, puisque chaque chargement crée un nouveau sandbox (voir module_cache.lua). En-têtes mis à jour. Macrobook : le commentaire du compteur d'invalidation disait protéger contre les coroutines d'avant un `gs reload`, c'est faux (voir Bugs).
- `drg/DRG_JUMP_MANAGER.lua` : « délai optimisé 0,8 s » était faux, le code attend 1,0 s. Commentaires-bruit retirés.
- `dnc/waltz_manager.lua` : docs `@param` des helpers ; bruit retiré.
- `buffs/self_buff_manager.lua` : le commentaire disait « fenêtre anti-spam sous la seconde » alors que `CAST_COOLDOWN` vaut 2,0 s. Il est corrigé.
- `set_building/base_set_builder.lua` : `@file` corrigé. Les listes « Used by » étaient fausses (« 9/9 jobs », « BRD/RDM ne l'utilisent pas ») ; elles sont remplacées par la liste réelle trouvée par grep.
- `data/data_loader.lua` : doc `@return` ajoutée sur les fonctions de chargement.

---

## Bugs suspectés (non corrigés)

1. **`debuff/precast_guard.lua` ~l.480 (`guard_precast`) et ~l.300 (`check_magic`)** : le code teste `spell.type == "Magic"`, ce qui n'arrive jamais. GearSwap met dans `spell.type` le sous-type de la ressource (`WhiteMagic`, `BlackMagic`, `Ninjutsu`…, cf. `../statics.lua` et `triggers.lua`).
   - *Conséquences* : `check_magic` ne s'exécute jamais. Les sorts passent par `check_and_block` (routage par `action_type`), ce qui fonctionne, avec trois écarts :
     - le mode test du silence utilise « berserk » écrit en dur au lieu de `AutoCureConfig.test_debuff` ;
     - Mute/Omerta affichent `show_action_blocked` au lieu de `show_spell_blocked` ;
     - `check_magic` est du code mort de fait.
   - *Correctif proposé* : tester `spell.action_type == 'Magic'` dans `guard_precast`, à valider en jeu.
   - Même motif **hors zone** : `shared/jobs/rdm/functions/RDM_MIDCAST.lua:347` (`spell.type == 'Magic' and … midcast_subjob(...)`), qui ne serait donc jamais vrai.
2. **`whm/cure_manager.lua` ~l.150 (alliance)** : les clés cherchées sont `'a'..i..'p'..j` (a1p1…). `windower.ffxi.get_party()` utilise `a10..a15` / `a20..a25` (c'est ce que fait `dnc/waltz_manager.lua:73-75`).
   - *Conséquence* : un membre d'alliance n'est jamais trouvé, et l'auto-tier retombe sur l'estimation par HPP sur 2000 PV.
   - *Correctif* : reprendre la boucle de waltz_manager. La doc de `get_hp_missing_party` répète elle aussi « a1p1.. ».
3. **`macrobook/macrobook_manager.lua` ~l.98 (`set_macro_with_delay`)** : le compteur `_macrobook_schedule_id` est rangé sur le `_G` du sandbox. Après un `gs reload`, une coroutine planifiée avant compare avec son ancien `_G` et n'est donc jamais annulée, contrairement à ce que disait le commentaire.
   - *Impact faible* : au pire, un `set_macro_page` en double.
   - *Correctif* : le ranger sur `windower._macrobook_schedule_id`, comme le font AutoMove, AbilityHelper et ScholarActions.
4. **`weaponskill/weaponskill_manager.lua` l.47-80 (`check_weaponskill_range`)** : `spell.type` est lu avant le test `if not spell`, donc le garde-fou ne sert à rien. De plus, quand `target`, `model_size` ou `distance` manquent, la fonction renvoie `false` et `ws_validator` annule le WS **sans aucun message** (`debug_mode` étant à false).
   - *Correctif* : inverser l'ordre des tests, et soit afficher un message, soit laisser passer quand les données manquent.
5. **`whm/cure_manager.lua` ~l.395** : la branche `elseif WHMCureConfig.debug_messages and WHMMessageFormatter` ne peut jamais être atteinte, car le `if` précédent teste déjà `WHMMessageFormatter`.
6. **`whm/cure_manager.lua` ~l.38** : un `print()` s'exécute si `WHM_CURE_CONFIG` ne se charge pas (anti-pattern). Le remplacer changerait un message, donc ce n'est pas fait.
7. **`craft/craft_manager.lua` ~l.120** : le message d'erreur « invalid format » cite `config/craft/<nom>.lua`, alors que le vrai chemin est `<perso>/sets/<nom>_sets.lua`. C'est un message affiché au joueur, il n'a pas été modifié.

---

## Doutes / à décider

- **`precast/ws_precast_handler.lua` ~l.45** : `handle()` annule le WS si le TP est sous 1000, et ce depuis 01c5411. Cela contredit la règle « validation TP retirée à cause du lag » (CODE_QUALITY §4.1 et §9 n°5, commentaire de `weaponskill_manager.lua`). Faut-il garder ou retirer ce contrôle ?
- **`precast/cooldown_checker.lua` `MULTI_CHARGE_ABILITIES`** : la liste exempte aussi des capacités qui ne fonctionnent PAS par charges : Light Arts (recast 228), Dark Arts (232), Sublimation (234), Enlightenment (235), Tabula Rasa. Leur recast n'est donc jamais contrôlé. « Accretion » et « Stormsurge » n'existent pas dans `res.job_abilities`. Est-ce voulu ?
- **`whm/cure_manager.lua`** : `WHMCureConfig.auto_tier_enabled` et `force_max_cure` ne sont jamais lus, le code lit `state.CureAutoTier`. `_master/config/whm/WHM_CURE_CONFIG.lua:79` définit donc une option qui ne fait rien. Faut-il la supprimer ou la brancher ?
- **`precast/ability_helper.lua`** : `try_ability` et `try_ability_smart` donnent le même résultat, seul l'ordre des tests change. Peut-on les fusionner ?
- **`dnc/waltz_manager.lua`** : le bloc « raisons de blocage » de `cast_divine_waltz` duplique `curing_blockers`. Peut-on factoriser ?
- **`buffs/self_buff_manager.lua` `send_queue`** et **`smartbuff/subjob_war_buffs.lua` `cast`** : ils utilisent des chaînes `wait N; input …`. La métrique CODE_QUALITY §16 annonce 0 chaîne `input /ja X; wait N; input /ma Y`. Ici, les buffs sont indépendants les uns des autres, ce qui semble acceptable, mais c'est à confirmer.
- **`drg/auto_jump.lua` l.141** : le commentaire « Global so it survives the coroutine boundaries » est douteux, une locale capturée survivrait aussi. Il n'a pas été modifié faute de certitude sur l'intention.
- **`weaponskill/tp_bonus_calculator.lua` `get_final_tp`** : ignore Fencer alors que `calculate()` le compte (fonction morte de toute façon, voir plus bas).
- **Docs hors zone** (à corriger par qui a la main) :
  - CLAUDE.md, CODE_QUALITY §4.2 et MIDCAST_STANDARD décrivent une « fallback chain 7 niveaux : spell name > spell map > skill+mode > skill > type > default midcast > idle ». C'est **faux**. La vraie chaîne est `midcast_manager.lua` `RESOLVERS` (l.~555-565) :
    - P0 : nom exact ;
    - P1 : nom sans tier croisé avec cible et skill ;
    - P2 : type.cible.mode ;
    - P3 : type.mode ;
    - P4 : cible.mode ;
    - P5 : cible ;
    - P6 : type à la racine ;
    - P7 : type sous le skill ;
    - P8 : mode sous le skill ;
    - P9 : set du skill.
    Il n'y a ni « spell map » ni « idle ». Singing a sa propre chaîne.
  - CODE_QUALITY §6 donne `MessageCore.raw(color_code, text)`, alors que la vraie signature est `MessageCore.raw(message)` (message_core.lua:108, couleur 001 fixe).

---

## Code mort probable

Recherche faite par grep sur `shared/`, `_master/`, `Tetsouo/`, `Kaories/` et `scripts/`. Seul le fichier de définition fait référence à ces éléments. Rien n'a été supprimé.

| Élément | Fichier | Preuve |
|---|---|---|
| `DebuffChecker.is_incapacitated` | debuff/debuff_checker.lua | 0 appelant |
| `PrecastGuard.would_block`, `PrecastGuard.get_active_blocks` | debuff/precast_guard.lua | 0 appelant. Du coup, `DebuffChecker.get_all_active_blocks` n'est appelée que par du code mort |
| `PrecastGuard.check_magic` | debuff/precast_guard.lua | jamais atteinte (voir Bug 1) |
| `DoomManager.validate_doom_set` | debuff/doom_manager.lua | 0 appelant |
| `MidcastManager.get_element`, `.rdm_enfeebling`, `.enhancing`, `.elemental`, `.cure`, table `MidcastManager.debug` | midcast/midcast_manager.lua | 0 appelant (`get_element` n'apparaît que sous la forme `DARK_MAGIC_DATABASE.get_element`, une autre fonction) |
| `WeaponSkillManager.initialize`, champ `WeaponSkillManager.MessageFormatter` (jamais assigné, ce qui rend mortes les branches `show_range_error` et `show_ws_validation_error`), `config.distance_check_enabled` | weaponskill/weaponskill_manager.lua | 0 appelant / 0 écriture / 0 lecture |
| `TPBonusCalculator.get_final_tp` | weaponskill/tp_bonus_calculator.lua | 0 appelant |
| `WHMMessageFormatter.show_cure_heal`, `show_cure_stoneskin`, `show_benediction`, `show_devotion`, `show_martyr`, `show_cursna`, `show_status_removal`, `show_auto_tier_toggle`, `warning`, `error` | whm/whm_message_formatter.lua | 0 appelant (seuls `show_cure_tier_change`, `show_afflatus_change` et les `show_debug_*` sont utilisés) |
| `ScholarActions.chain` | scholar/scholar_actions.lua | 0 appelant |
| `AutoJump.get_status`, `get_tp_threshold`, `get_animation_delay` | drg/auto_jump.lua | 0 appelant |
| `AutoMove.reinit_position` | movement/automove.lua | 0 appelant |
| `DataLoader.load_all` | data/data_loader.lua | 0 appelant |

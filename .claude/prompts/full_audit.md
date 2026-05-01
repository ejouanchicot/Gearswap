# AUDIT TECHNIQUE COMPLET - GearSwap Tetsouo v3.2.0

## CONTEXTE

Projet GearSwap FFXI : architecture modulaire Lua, 15 jobs, 612 fichiers Lua.
Structure : `shared/jobs/` (228 fichiers), `shared/utils/` (164 fichiers), `shared/data/` (209 fichiers), `shared/hooks/` (3 fichiers).
Lis CLAUDE.md, .claude/MIDCAST_STANDARD.md et .claude/standards.md AVANT de commencer.

## MISSION

Audit technique exhaustif de TOUT le code. Tu dois trouver les vrais problèmes, pas juste valider. Sois critique et précis.

## PHASES D'AUDIT

### PHASE 1 : Systèmes centralisés (shared/utils/)

Auditer chaque système central en vérifiant :

1. **midcast_manager.lua** (658 lignes) — Fallback chain correcte ? Tous les edge cases couverts ? Pas de code mort ?
2. **ws_precast_handler.lua** (115 lignes) — Logique WS complète ? Intégration AbilityHelper correcte ?
3. **ability_helper.lua** (122 lignes) — Toutes les abilities pre-WS gérées ? Pas de hardcoded values ?
4. **cooldown_checker.lua** (136 lignes) — Couvre abilities ET spells ? Gestion recast_id fiable ?
5. **precast_guard.lua** — Debuff blocking complet (Amnesia, Silence, Stun, Mute, Impairment) ?
6. **message_formatter.lua** (499 lignes) — Facade cohérente ? Pas de fonctions orphelines ?
7. **COMMON_COMMANDS.lua** (740 lignes) — Trop gros ? Candidat au split ? Logique de dispatch propre ?
8. **automove.lua** (320 lignes) — Logique movement speed correcte ? Conditions bien couvertes ?
9. **INIT_SYSTEMS.lua** (174 lignes) — Ordre d'init correct ? Dépendances circulaires ?
10. **job_change_manager.lua** (209 lignes) — Debouncing fiable ? Race conditions ?
11. **lockstyle_manager.lua** / **macrobook_manager.lua** — Factories conformes au pattern ?

Pour chaque fichier : lire le code, identifier les bugs potentiels, code mort, logique redondante, edge cases non gérés.

### PHASE 2 : Cross-job consistency (shared/jobs/)

Pour CHACUN des 15 jobs (BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, THF, WAR, WHM), vérifier :

1. **PRECAST** — Ordre correct : PrecastGuard → CooldownChecker → WSPrecastHandler → job logic ?
2. **MIDCAST** — Utilise MidcastManager.select_set() pour TOUS les skills ? Pas de fallback manuel ?
3. **AFTERCAST** — Gère idle ET engaged correctement ?
4. **COMMANDS** — Utilise CommonCommands ? Pas de dispatch dupliqué ?
5. **LOCKSTYLE/MACROBOOK** — Utilise les factories ? Pas de code manuel ?
6. **MOVEMENT** — Utilise AutoMove ? Configuration correcte ?
7. **Facade** ([job]_functions.lua) — Include dans le bon ordre ? Exports _G corrects ?
8. **Exports** — Chaque module exporte via `_G.function_name` ET `return` ?

Signaler toute divergence entre jobs (un job qui fait différemment des autres).

### PHASE 3 : Qualité du code Lua

Chercher dans TOUT le projet :

1. **Bugs potentiels** — Variables nil non vérifiées, pcall manquants sur require(), index sur nil tables
2. **Code mort** — Fonctions définies mais jamais appelées, variables assignées mais jamais lues, blocs commentés
3. **Duplication** — Même logique copiée entre fichiers au lieu d'être centralisée
4. **Violations des standards** :
   - Fichiers > 600 lignes
   - Fonctions > 30 lignes (sauf job_self_command dispatchers)
   - `add_to_chat()` direct au lieu de MessageFormatter
   - `require()` sans pcall pour modules optionnels
   - Lockstyle/macrobook manuel au lieu des factories
5. **Naming conventions** — snake_case fonctions, CamelCase modules, CamelCase equipment vars
6. **Sécurité** — `loadfile`, `setfenv`, `dofile` interdits (sandbox GearSwap)

### PHASE 4 : Databases (shared/data/)

Vérifier :
1. **Spell databases** — Cohérence des catégories, pas d'entrées dupliquées, spells manquants connus
2. **WS database** — TP bonus values correctes, tous les WS majeurs présents
3. **JA database** — Descriptions et catégories cohérentes

### PHASE 5 : Entry points et Sets

1. **Entry points** (Tetsouo/Tetsouo_*.lua) — Structure uniforme ? Include paths corrects ?
2. **Sets** (Tetsouo/sets/*_sets.lua) — Pas d'items dupliqués dans le même set ? Structure set_combine correcte ?
3. **_master/entry/** — Templates cohérents avec les entry points actifs ?

## FORMAT DU RAPPORT

Pour chaque problème trouvé :
```
[SEVERITE] fichier:ligne — Description
  Actuel: <ce qui est dans le code>
  Attendu: <ce qui devrait être>
  Fix: <correction proposée>
```

Sévérités :
- **CRITICAL** — Bug qui casse le fonctionnement en jeu
- **ERROR** — Violation d'architecture ou logique incorrecte
- **WARNING** — Code mort, duplication, non-conformité aux standards
- **INFO** — Amélioration possible mais pas urgente

## RÉSUMÉ FINAL

À la fin, fournir :
1. Score global /10 avec justification
2. Nombre de problèmes par sévérité
3. Top 5 des fichiers les plus problématiques
4. Actions prioritaires (max 10)

## RÈGLES

- Lis CHAQUE fichier avant de juger — pas de suppositions
- Cite le code exact avec numéros de ligne
- Pas de faux positifs — chaque problème doit être vérifiable
- Pas de suggestions cosmétiques (style de commentaires, formatting)
- Focus sur la logique, les bugs, l'architecture
- Si un fichier est clean, dis-le en une ligne et passe au suivant

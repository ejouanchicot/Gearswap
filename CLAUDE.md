# CLAUDE.md - GearSwap FFXI Tetsouo

Version: 3.2.0 | Score: 9.5/10

## OBJECTIF

Architecture modulaire world-class. 15 jobs: BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, THF, WAR, WHM. 9 systemes centralises, zero duplication.

## ARCHITECTURE

```
Tetsouo/Tetsouo_[JOB].lua          -- Entry point
shared/jobs/[job]/[job]_functions.lua  -- Facade
shared/jobs/[job]/functions/
  [JOB]_PRECAST.lua   -- Guard>>Cooldown>>WSPrecast>>job
  [JOB]_MIDCAST.lua   -- MidcastManager.select_set() OBLIGATOIRE
  [JOB]_AFTERCAST/IDLE/ENGAGED/STATUS/BUFFS.lua
  [JOB]_COMMANDS.lua   -- CommonCommands
  [JOB]_MOVEMENT.lua   -- AutoMove
  [JOB]_LOCKSTYLE/MACROBOOK.lua  -- Factories
Tetsouo/sets/[job]_sets.lua        -- Equipment
Tetsouo/config/[job]/              -- Keybinds/States/Lockstyle/Macrobook
```

## 9 SYSTEMES CENTRALISES

| # | Systeme | Usage | Fichier |
|---|---------|-------|---------|
| 1 | PrecastGuard | PREMIER check PRECAST | `shared/utils/precast/precast_guard.lua` |
| 2 | CooldownChecker | Apres guard en PRECAST | `shared/utils/precast/cooldown_checker.lua` |
| 3 | WSPrecastHandler | WS handling unifie | `shared/utils/precast/ws_precast_handler.lua` |
| 4 | MidcastManager | OBLIGATOIRE en MIDCAST | `shared/utils/midcast/midcast_manager.lua` |
| 5 | MessageFormatter | JAMAIS add_to_chat direct | `shared/utils/messages/message_formatter.lua` |
| 6 | LockstyleManager | Factory (JAMAIS manuel) | `shared/utils/core/lockstyle_manager.lua` |
| 7 | MacrobookManager | Factory (JAMAIS manuel) | `shared/utils/core/macrobook_manager.lua` |
| 8 | AbilityHelper | Auto-trigger avant WS | `shared/utils/precast/ability_helper.lua` |
| 9 | JobChangeManager | Debouncing 3.0s + reload | `shared/utils/core/job_change_manager.lua` |

> JA messages geres par `ability_message_handler` (v3.2.0).

## REFERENCES DETAILLEES

- Midcast standard: @.claude/MIDCAST_STANDARD.md
- Architecture standards: @.claude/standards.md

## ERREURS COURANTES

1. Lockstyle/macrobook manuel >> Factories
2. `add_to_chat()` direct >> MessageFormatter
3. Ordre precast incorrect >> Guard>>Cooldown>>WSPrecast>>job
4. Oublier `_G` exports >> `_G.job_precast` + `return`
5. Fichiers > 600 lines >> 12 modules x 100-200 lines
6. Nested midcast logic >> `MidcastManager.select_set()`

## METRIQUES

Files < 600 lines | Functions < 30 lines | Duplication 0% | 9/9 systemes

**Exception**: `job_self_command()` dispatchers exempts de la limite 30 lignes (routers structurels).

## WORKFLOW NOUVEAU JOB

Utiliser la skill `/new-job [job]` pour un workflow guide complet.

Templates: DNC_PRECAST, PLD_MIDCAST, WAR_COMMANDS, war_sets
Testing: `//gs c checksets`, `//gs c debugmidcast`, `//lua reload gearswap`

## PRINCIPES

Factory > Duplication | Centralisation > Job-Specific | 12 modules | MidcastManager OBLIGATOIRE | WSPrecastHandler OBLIGATOIRE | Debouncing | Documentation 100%

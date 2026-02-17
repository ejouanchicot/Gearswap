# CLAUDE.md - GearSwap FFXI Tetsouo

Version: 3.2.0 | Score: 9.5/10

## OBJECTIF

Architecture modulaire world-class. 15 jobs: BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, THF, WAR, WHM. 9 systèmes centralisés, zero duplication.

## ARCHITECTURE - 12 MODULES OBLIGATOIRES

```
jobs/[job]/
├── [JOB]_functions.lua (façade)
├── sets/[job]_sets.lua
└── functions/
    ├── [JOB]_PRECAST.lua (PrecastGuard>>CooldownChecker>>WSPrecastHandler>>job logic)
    ├── [JOB]_MIDCAST.lua (MidcastManager.select_set OBLIGATOIRE)
    ├── [JOB]_AFTERCAST/IDLE/ENGAGED/STATUS/BUFFS.lua
    ├── [JOB]_COMMANDS.lua (CommonCommands)
    ├── [JOB]_MOVEMENT.lua (AutoMove)
    └── [JOB]_LOCKSTYLE/MACROBOOK.lua (Factories)
```

## SYSTÈMES CENTRALISÉS (9/9 OBLIGATOIRES)

1. CooldownChecker - `CooldownChecker.check_ability_cooldown(spell, eventArgs)`

2. MessageFormatter - JAMAIS add_to_chat direct

```lua
MessageFormatter.show_ws_tp(spell.name, current_tp)
```

3. MidcastManager (OBLIGATOIRE) - Fallback automatique 7 niveaux

```lua
MidcastManager.select_set({skill = 'Enfeebling Magic', spell = spell, mode_state = state.EnfeebleMode})
```

Debug: `//gs c debugmidcast` | Ref: `.claude/MIDCAST_STANDARD.md`

4. AbilityHelper - Auto-trigger avant WS/spell

```lua
AbilityHelper.try_ability_ws(spell, eventArgs, 'Climactic Flourish', 2)
```

5. PrecastGuard - PREMIER check in PRECAST

```lua
if PrecastGuard and PrecastGuard.guard_precast(spell, eventArgs) then return end
```

6. WSPrecastHandler - Centralized WS precast (range, TP bonus, gear)

```lua
WSPrecastHandler.handle(spell, eventArgs)
```

> Note: Remplace l'ancien `WeaponSkillManager.check_weaponskill_range()` (v3.2.0)

7. Factories - JAMAIS coder manuellement

```lua
return LockstyleManager.create('[JOB]', 'config/[job]/[JOB]_LOCKSTYLE', 1, 'SAM')
return MacrobookManager.create('[JOB]', 'config/[job]/[JOB]_MACROBOOK', 'SAM', 1, 1)
```

8. UNIVERSAL_JA_DATABASE (REMPLACÉ) - Messages JA centralisés

```lua
-- REMPLACÉ (v3.2.0) - Messages JA maintenant gérés par ability_message_handler
-- Fichier: shared/utils/messages/handlers/ability_message_handler.lua
-- Chargé via: shared/hooks/init_ability_messages.lua
-- 0/15 jobs utilisent JA_DB directement (code commenté dans BLM, BRD, COR, RUN, WHM)
-- Le système centralisé ability_message_handler gère TOUS les messages JA automatiquement
```

9. JobChangeManager - Debouncing 3.0s + Reload complet (déjà intégré)

**Note**: WarpInit retiré (v3.1.1) - Redondant avec reload complet GearSwap du JobChangeManager

## WORKFLOW NOUVEAU JOB (8-12h)

PHASE 1 (30min): Copier TETSOUO_WAR.lua >> TETSOUO_[JOB].lua, créer directories

PHASE 2 (2-3h): 12 modules

- PRECAST: Guard>>Cooldown>>WSPrecastHandler>>job logic (copier jobs/dnc/functions/DNC_PRECAST.lua)
- MIDCAST: MidcastManager.select_set() (copier jobs/pld/functions/PLD_MIDCAST.lua)
- Autres: templates minimaux

PHASE 3 (1h): 3 configs (keybinds/lockstyle/macrobook) - copier config/war/

PHASE 4 (2-4h): Equipment sets - copier jobs/war/sets/war_sets.lua

## CHECKLIST

Structure: TETSOUO_[JOB].lua, 12 modules, 3 configs, equipment sets

9 Systèmes: CooldownChecker, MessageFormatter, MidcastManager, PrecastGuard, WSPrecastHandler, LockstyleManager.create(), MacrobookManager.create(), AbilityHelper, UNIVERSAL_JA_DATABASE (non implémenté), JobChangeManager

Testing: Load test, `//gs c checksets`, job/subjob changes, keybinds, lockstyle/macros

## ERREURS COURANTES

1. Coder lockstyle/macrobook manuellement >> Factories
2. add_to_chat() direct >> MessageFormatter
3. Ordre precast incorrect >> Guard>>Cooldown>>WSPrecastHandler>>job
4. Oublier _G exports >>_G.job_precast + return
5. Fichiers > 800 lines >> 12 modules × 100-200 lines
6. Nested midcast logic >> MidcastManager.select_set()
7. If/elseif JA messages >> UNIVERSAL_JA_DATABASE

## MÉTRIQUES

Doc 100% | Files < 600 lines | Functions < 30 lines | Duplication 0% | 9/9 systèmes

## NAMING

```lua
TETSOUO_[JOB].lua, [job]_functions.lua, [JOB]_PRECAST.lua
local my_var = {}, local MyModule = {}, state.MainWeapon = M{}, function job_precast()
```

## RÉFÉRENCES

Templates: DNC_PRECAST.lua, PLD_MIDCAST.lua, WAR_COMMANDS.lua, PLD_LOCKSTYLE.lua, war_sets.lua
Systems: cooldown_checker.lua, message_formatter.lua, midcast_manager.lua, MIDCAST_STANDARD.md
Testing: `//gs c checksets`, `//gs c debugmidcast`, `//lua reload gearswap`

## PRINCIPES

Factory > Duplication | Centralization > Job-Specific | Modularité 12 modules | MidcastManager OBLIGATOIRE | WSPrecastHandler OBLIGATOIRE | Warp System OBLIGATOIRE | Debouncing | Documentation 100%

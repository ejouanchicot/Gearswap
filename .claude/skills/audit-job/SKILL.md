---
name: audit-job
description: Audit a GearSwap job module for compliance with the 9 mandatory systems and 12-module architecture. Use when reviewing a job or after major changes.
argument-hint: "[job-name] (e.g., war, pld, dnc)"
context: fork
agent: job-reviewer
---

# Audit Job: $ARGUMENTS

Perform a complete audit of the **$ARGUMENTS** job module.

## Step 1: Verify 12 Modules Exist

Check for all required files:
- `Tetsouo/Tetsouo_$ARGUMENTS.lua` (entry point - uppercase JOB)
- `shared/jobs/$ARGUMENTS/$ARGUMENTS_functions.lua` (facade)
- `shared/jobs/$ARGUMENTS/functions/` directory with:
  PRECAST, MIDCAST, AFTERCAST, IDLE (or ENGAGED), STATUS, BUFFS, COMMANDS, MOVEMENT, LOCKSTYLE, MACROBOOK
- `Tetsouo/sets/$ARGUMENTS_sets.lua` (equipment sets)
- `Tetsouo/config/$ARGUMENTS/` (keybinds, states, lockstyle, macrobook configs)

## Step 2: Verify 9 Mandatory Systems

For each system, check integration:
1. **PrecastGuard** - FIRST in PRECAST
2. **CooldownChecker** - After guard in PRECAST
3. **WSPrecastHandler** - WS handling in PRECAST
4. **MidcastManager.select_set()** - In MIDCAST (OBLIGATOIRE)
5. **MessageFormatter** - No direct `add_to_chat()`
6. **LockstyleManager.create()** - Factory in LOCKSTYLE module
7. **MacrobookManager.create()** - Factory in MACROBOOK module
8. **AbilityHelper** - Auto-trigger setup (if applicable)
9. **CommonCommands** - Integrated in COMMANDS

## Step 3: Check Code Quality

- Files < 600 lines
- Functions < 30 lines (except `job_self_command`)
- All `_G` exports present
- All modules have `return` at end
- No anti-patterns (direct add_to_chat, manual lockstyle, nested midcast logic)

## Step 4: Report

Format as checklist:
```
AUDIT: [JOB] - [date]

MODULES (X/12):
- [OK/MISSING] Entry point
- [OK/MISSING] Facade
...

SYSTEMS (X/9):
- [OK/MISSING/WRONG] PrecastGuard
...

CODE QUALITY:
- [OK/WARNING] File sizes
- [OK/WARNING] Function sizes
...

SCORE: X/10
ISSUES: [list specific problems]
```

---
name: new-job
description: Guided workflow to create a new GearSwap job from scratch following the 12-module architecture.
argument-hint: "[job-abbreviation] (e.g., nin, mnk, smn)"
disable-model-invocation: true
---

# Create New Job: $ARGUMENTS

Follow the 4-phase workflow from CLAUDE.md to create a new job module.

## Phase 1: Scaffold (copy from WAR template)

1. Create entry point: `Tetsouo/Tetsouo_$ARGUMENTS.lua` (copy from `Tetsouo/Tetsouo_WAR.lua`)
2. Create directories:
   - `shared/jobs/$ARGUMENTS/`
   - `shared/jobs/$ARGUMENTS/functions/`
   - `Tetsouo/config/$ARGUMENTS/`
3. Create facade: `shared/jobs/$ARGUMENTS/$ARGUMENTS_functions.lua`

Replace all `WAR`/`war` references with `$ARGUMENTS` (uppercase/lowercase as appropriate).

## Phase 2: Create 12 Function Modules

Use these templates:
- **PRECAST**: Copy `shared/jobs/dnc/functions/DNC_PRECAST.lua` pattern (Guard>>Cooldown>>WSPrecast>>job)
- **MIDCAST**: Copy `shared/jobs/pld/functions/PLD_MIDCAST.lua` pattern (MidcastManager.select_set)
- **COMMANDS**: Copy `shared/jobs/war/functions/WAR_COMMANDS.lua` pattern (CommonCommands)
- **LOCKSTYLE**: Use `LockstyleManager.create()` factory
- **MACROBOOK**: Use `MacrobookManager.create()` factory
- **Others**: Minimal templates (AFTERCAST, IDLE, ENGAGED, STATUS, BUFFS, MOVEMENT)

Each module MUST:
- Use `ensure_modules_loaded()` lazy loading
- Export via `_G.job_function = function` AND `return`
- Stay under 200 lines

## Phase 3: Create 3 Config Files

In `Tetsouo/config/$ARGUMENTS/`:
- `$ARGUMENTS_KEYBINDS.lua` (copy from `config/war/`)
- `$ARGUMENTS_LOCKSTYLE.lua`
- `$ARGUMENTS_MACROBOOK.lua`

## Phase 4: Equipment Sets

Create `Tetsouo/sets/$ARGUMENTS_sets.lua`:
- Define equipment variables at top (CamelCase)
- Create standard sets: idle, engaged, precast, midcast categories
- Use `set_combine()` for inheritance

## Verification

After creation, run:
- `//lua reload gearswap` to test loading
- `//gs c checksets` to verify sets
- `/audit-job $ARGUMENTS` to verify compliance

---
name: check-systems
description: Check all 15 jobs for consistency of a specific system or pattern. Finds missing implementations and divergent patterns.
argument-hint: "[system-name] (e.g., PrecastGuard, MidcastManager, all)"
context: fork
agent: cross-job-checker
---

# Cross-Job System Check: $ARGUMENTS

Check the **$ARGUMENTS** system across all 15 jobs: BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, THF, WAR, WHM.

## If $ARGUMENTS is "all"

Check ALL 9 mandatory systems across all jobs and produce a full compliance matrix.

## If $ARGUMENTS is a specific system

Focus on that system. Systems to check:

| System | Where | Pattern to search |
|--------|-------|-------------------|
| PrecastGuard | *_PRECAST.lua | `PrecastGuard.guard_precast` |
| CooldownChecker | *_PRECAST.lua | `CooldownChecker.check_ability_cooldown` |
| WSPrecastHandler | *_PRECAST.lua | `WSPrecastHandler.handle` |
| MidcastManager | *_MIDCAST.lua | `MidcastManager.select_set` |
| MessageFormatter | All files | NO `add_to_chat(` (negative check) |
| LockstyleManager | *_LOCKSTYLE.lua | `LockstyleManager.create` |
| MacrobookManager | *_MACROBOOK.lua | `MacrobookManager.create` |
| AbilityHelper | *_PRECAST.lua | `AbilityHelper.try_ability` |
| CommonCommands | *_COMMANDS.lua | `CommonCommands` |

## Output Format

```
CROSS-JOB CHECK: [system]

| Job | Status | Details |
|-----|--------|---------|
| BLM | OK     |         |
| BRD | OK     |         |
| BST | WRONG  | Guard after Cooldown |
...

SUMMARY: X/15 compliant
FIXES NEEDED:
1. [job]: [what to fix]
```

Be thorough. Check ALL 15 jobs. Read the actual code, don't guess from file names.

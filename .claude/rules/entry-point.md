---
paths:
  - "Tetsouo/Tetsouo_*.lua"
  - "_master/entry/Tetsouo_*.lua"
---

# Entry Point Files - Pattern

## Structure
Entry points (`Tetsouo/Tetsouo_[JOB].lua`) are the GearSwap load target. They:

1. `include('Mote-Include.lua')` - Load Mote framework
2. Define `get_sets()` - Called by GearSwap on load
3. `include('Tetsouo/sets/[job]_sets.lua')` - Load equipment sets
4. `require('shared/jobs/[job]/[job]_functions')` - Load job facade
5. Set up states, keybinds, lockstyle, macrobook via config files

## Required Functions
- `get_sets()` - MUST exist, called by GearSwap
- `file_unload()` - Cleanup keybinds on job change
- `user_setup()` / `user_unload()` - Mote hooks for init/cleanup

## Anti-patterns
- Putting logic in entry point (belongs in function modules)
- Direct `require` of function modules (use the facade)
- Missing `file_unload()` (keybinds leak between jobs)

# Tetsouo GearSwap

A modular GearSwap framework for Final Fantasy XI (Windower 4). Built around a centralized architecture with 15 supported jobs, shared systems, and zero code duplication between jobs.

**Version 3.2.0** | Lua 5.1 | Windower 4

## What it does

Automates gear swapping for FFXI: precast, midcast, aftercast, idle, engaged. Each job is split into small, focused modules instead of one giant file. Shared logic lives in a central `shared/` directory so fixes and features apply to all jobs at once.

**Supported jobs:** BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, PUP, RDM, RUN, SAM, THF, WAR, WHM

## Project structure

```
Tetsouo/                    Character-specific files (entry points, configs, gear sets)
_master/                    Templates for creating new characters
shared/
  jobs/[job]/functions/     12 modules per job (precast, midcast, idle, etc.)
  utils/                    Centralized systems (watchdog, messages, warp, etc.)
  data/                     Spell, ability, and weaponskill databases
  hooks/                    Auto-message handlers
docs/                       User guides and reference
```

## Key features

**Per job:** 12-module architecture, per-job keybinds, lockstyle/macrobook auto-setup, gear set validation.

**Shared systems:**
- **MidcastManager** -- 7-level fallback chain for midcast gear selection. No nested if/else in job files.
- **Watchdog** -- Detects stuck midcast states using actual cast times. Auto-recovers gear.
- **Warp system** -- 50+ destinations via `//gs c warp [destination]`. Handles rings, spells, and item restoration.
- **PrecastGuard** -- Blocks actions when debuffed (silence, amnesia, terror, etc.)
- **CooldownChecker** -- Prevents ability spam, shows remaining cooldown.
- **WSPrecastHandler** -- Range check, TP bonus calculation, gear selection for weapon skills.
- **MessageFormatter** -- Centralized chat output. No direct `add_to_chat()` in job files.
- **DualBox** -- Multi-character job synchronization via IPC.

## Getting started

### Requirements

- FFXI with Windower 4
- GearSwap addon
- DressUp addon (optional, for lockstyle management)

### Installation

1. Clone or download this repo into your GearSwap `data/` folder
2. Copy `_master/entry/Tetsouo_WAR.lua` to `[YourName]/[YourName]_WAR.lua` as a starting point
3. Copy `_master/config/war/` to `[YourName]/config/war/` and edit keybinds/lockstyle
4. Copy `_master/sets/war_sets.lua` to `[YourName]/sets/war_sets.lua` and fill in your gear

Or use the clone tool: `python clone_character.py`

### Basic commands

```
//gs c reload              Reload the system
//gs c checksets           Check for missing gear
//gs c lockstyle           Reapply lockstyle
//gs c cycle HybridMode    Toggle Normal/PDT
//gs c cycle MainWeapon    Cycle through weapons
//gs c warp mea            Teleport-Mea
//gs c info                Show JA/spell/WS data
```

## Documentation

Full documentation is in [docs/](docs/README.md):
- [Installation guide](docs/user/getting-started/installation.md)
- [Quick start](docs/user/getting-started/quick-start.md)
- [Commands reference](docs/user/guides/commands.md)
- [Keybinds guide](docs/user/guides/keybinds.md)
- [Configuration](docs/user/guides/configuration.md)
- [FAQ](docs/user/guides/faq.md)
- [Job-specific docs](docs/user/jobs/) (one folder per job with keybinds, sets, states, commands)

## Adding a new job

Each job follows the same 12-module pattern. See `_master/` for templates and [CREATING_NEW_JOB.md](docs/CREATING_NEW_JOB.md) for the full walkthrough.

## License

MIT

## Author

Tetsouo

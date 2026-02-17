# Documentation

Version 3.2.0 | 15 jobs | Last updated: 2026-02

---

## Getting started

- [Installation](user/getting-started/installation.md) -- Install and configure the system
- [Quick start](user/getting-started/quick-start.md) -- Up and running in 5 minutes

## User guides

- [Commands reference](user/guides/commands.md) -- All available commands
- [Keybinds](user/guides/keybinds.md) -- Per-job keyboard shortcuts
- [Configuration](user/guides/configuration.md) -- Customize your setup
- [DualBox](user/guides/dualbox.md) -- Multi-character setup
- [FAQ](user/guides/faq.md) -- Common questions and troubleshooting

## Feature reference

- [Watchdog](user/features/watchdog.md) -- Stuck midcast auto-recovery
- [UI overlay](user/features/ui.md) -- Visual keybind display
- [Equipment validation](user/features/equipment-validation.md) -- Gear checking
- [Job change manager](user/features/job-change-manager.md) -- Anti-collision on job swap
- [Auto-tier system](user/features/auto-tier-system.md) -- WHM Cure / DNC Waltz tier selection

## Job documentation

Each job has its own folder with 8 files: README, quick-start, keybinds, commands, states, sets, configuration, troubleshooting.

| Job | Role | Highlights |
|-----|------|------------|
| [BLM](user/jobs/blm/) | Nuker | Magic burst detection, weapon cycling |
| [BRD](user/jobs/brd/) | Support | Song rotation, instrument management, Marsyas lock |
| [BST](user/jobs/bst/) | Pet | 7 ecosystems, species cycling, Ready Move system |
| [COR](user/jobs/cor/) | Support | Roll tracking, bust rates, party job detection |
| [DNC](user/jobs/dnc/) | Melee/Support | Auto-Climactic, jump chaining, step rotation |
| [DRK](user/jobs/drk/) | Melee | Weapon management, hybrid modes |
| [GEO](user/jobs/geo/) | Support | Bubble modes, auto-Entrust |
| [PLD](user/jobs/pld/) | Tank | AoE BLU rotation, rune system, auto-Majesty |
| [PUP](user/jobs/pup/) | Pet | Automaton management |
| [RDM](user/jobs/rdm/) | Hybrid | 3 enfeebling modes, 3 nuke modes, auto-Saboteur |
| [RUN](user/jobs/run/) | Tank | Rune management, ward system |
| [SAM](user/jobs/sam/) | Melee | Hasso/Seigan, Meditate tracking |
| [THF](user/jobs/thf/) | Melee | Smartbuff cycle, SA/TA management |
| [WAR](user/jobs/war/) | Melee | 6 weapons, TP bonus display |
| [WHM](user/jobs/whm/) | Healer | Cure auto-tier, Afflatus management |

## Technical reference

- [Creating a new job](CREATING_NEW_JOB.md) -- Full walkthrough for adding a job
- [Spell database system](SPELL_DATABASES_SYSTEM.md) -- How spell data is organized
- [WS database system](WS_DATABASE_SYSTEM.md) -- Weapon skill data architecture
- [JA database](JOB_ABILITIES_DATABASE.md) -- Job ability data reference
- [Attack/PDL system](ATTACK_PDL_SYSTEM.md) -- Damage calculation formulas
- [Info command](INFO_COMMAND.md) -- `//gs c info` internals
- [Watchdog internals](WATCHDOG_ITEM_SUPPORT.md) -- Watchdog technical details
- [Debuff auto-cure config](config/README_DEBUFF_AUTOCURE.md) -- Debuff cure setup

## Architecture overview

```
shared/
  jobs/[job]/functions/     12 modules per job
    [JOB]_PRECAST.lua       Guard > Cooldown > WSPrecastHandler > job logic
    [JOB]_MIDCAST.lua       MidcastManager.select_set() -- 7-level fallback
    [JOB]_AFTERCAST.lua     Post-action gear restore
    [JOB]_IDLE.lua          Idle gear selection
    [JOB]_ENGAGED.lua       Engaged gear selection
    [JOB]_STATUS.lua        Buff/debuff status changes
    [JOB]_BUFFS.lua         Buff tracking and gear adjustments
    [JOB]_COMMANDS.lua       WatchdogCommands > CommonCommands > job commands
    [JOB]_MOVEMENT.lua      AutoMove integration
    [JOB]_LOCKSTYLE.lua     LockstyleManager.create() factory
    [JOB]_MACROBOOK.lua     MacrobookManager.create() factory
    [job]_functions.lua     Facade that loads all modules

  utils/                    9 centralized systems
    core/                   COMMON_COMMANDS, INIT_SYSTEMS, midcast_watchdog
    precast/                cooldown_checker, ws_precast_handler, precast_guard
    midcast/                midcast_manager (7-level fallback)
    messages/               message_formatter + handlers + formatters
    warp/                   50+ destinations, item rings, IPC
    lockstyle/              Factory pattern
    macrobook/              Factory pattern
    equipment/              Gear validation
    debuff/                 Debuff detection and cure guard
    movement/               AutoMove system
    dualbox/                Multi-character sync
    ui/                     Visual overlay system
```

## Quick command reference

```
//gs c reload              Full reload
//gs c checksets           Validate gear against sets
//gs c lockstyle           Reapply lockstyle
//gs c cycle HybridMode    Normal / PDT
//gs c cycle MainWeapon    Cycle weapons
//gs c warp [destination]  Teleport (mea, holla, dem, jeuno, etc.)
//gs c info                Show JA/spell/WS database info
//gs c watchdog            Watchdog status
//gs c debugmidcast        Debug midcast set selection
```

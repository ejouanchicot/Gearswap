# Documentation

16 jobs (PUP does not load yet; SMN ships only with the Tetsouo template).
Pages checked against the code on 2026-09-25.

Start with the [project README](../README.md) for the overview. The player
guides below go deeper; the [developer documentation](dev/README.md) explains
how the code works.

## Getting started

- [Installation](user/getting-started/installation.md) - copy the files,
  create your character with the clone script, first load
- [Quick start](user/getting-started/quick-start.md) - the HUD, the keys and
  the first commands to try

## Guides

- [Commands](user/guides/commands.md) - every `//gs c` command shared by all jobs
- [Keybinds](user/guides/keybinds.md) - the key layout, the keybind files,
  your own modes (`<JOB>_CUSTOM.lua`) and temporary keys (`//gs c tb`)
- [Configuration](user/guides/configuration.md) - what each file in
  `<YourName>/config/` does
- [Dual-box](user/guides/dualbox.md) - main and alt, alt commands, box group
  orders, alt window
- [FAQ](user/guides/faq.md) - common problems

## Features

- [Keybind HUD](user/features/ui.md) - `//gs c ui` and its settings
- [Equipment validation](user/features/equipment-validation.md) -
  `//gs c checksets` and the other inventory tools
- [Auto-tier](user/features/auto-tier-system.md) - WHM Cure and DNC Waltz tier
  choice
- [Job changes](user/features/job-change-manager.md) - what happens when you
  change job or subjob
- [Midcast watchdog](user/features/watchdog.md) - gear recovery when a cast is
  never confirmed

## Jobs

Modes, keys and commands of each job: [user/jobs/](user/jobs/README.md).

| Role | Jobs |
|---|---|
| Mage | [BLM](user/jobs/blm/states.md) · [GEO](user/jobs/geo/states.md) · [RDM](user/jobs/rdm/states.md) · [WHM](user/jobs/whm/states.md) |
| Support | [BRD](user/jobs/brd/states.md) · [COR](user/jobs/cor/states.md) |
| Tank | [PLD](user/jobs/pld/states.md) · [RUN](user/jobs/run/README.md) |
| Melee | [DNC](user/jobs/dnc/states.md) · [DRK](user/jobs/drk/states.md) · [SAM](user/jobs/sam/states.md) · [THF](user/jobs/thf/states.md) · [WAR](user/jobs/war/states.md) |
| Pet | [BST](user/jobs/bst/states.md) · [SMN](user/jobs/smn/states.md) · [PUP](user/jobs/pup/README.md) (not functional) |

TP bonus gear, for every job: [tp-bonus.md](user/jobs/war/tp-bonus.md).

## Your character folder

```
<YourName>/
├── <YourName>_<JOB>.lua     one file per job, loaded by GearSwap
├── sets/<job>_sets.lua      your gear
└── config/
    ├── COMMON_KEYBINDS.lua, UI_CONFIG.lua, LOCKSTYLE_CONFIG.lua,
    │   DUALBOX_CONFIG.lua, REGION_CONFIG.lua, ...
    ├── alt/                 alt commands (main character only)
    └── <job>/               KEYBINDS, STATES, CUSTOM, LOCKSTYLE,
                             MACROBOOK, TP_CONFIG, ...
```

Details: [configuration](user/guides/configuration.md).

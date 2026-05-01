# Documentation

Version 3.2.0 · 14 implemented jobs · Last refreshed: 2026-05

> Looking for a one-page overview? Read the [project README](../README.md)
> first — it covers Quick Start and a feature audit. The pages below go
> deeper.

---

## Getting started

- [Installation](user/getting-started/installation.md) — Install,
  configure, and verify the framework
- [Quick start](user/getting-started/quick-start.md) — First five
  minutes after install

## User guides

- [Commands reference](user/guides/commands.md) — Verified, exhaustive
  list of `//gs c …` commands
- [Configuration](user/guides/configuration.md) — Per-character config
  layout (refill, wardrobe, dualbox, lockstyle, …)
- [Keybinds](user/guides/keybinds.md) — `<JOB>_KEYBINDS.lua` format and
  per-job examples
- [DualBox](user/guides/dualbox.md) — Main/Alt IPC sync
- [FAQ](user/guides/faq.md) — Common issues and fixes

## Feature reference

- [Auto-tier system](user/features/auto-tier-system.md) — WHM Cure /
  DNC Waltz tier selection
- [Equipment validation](user/features/equipment-validation.md) —
  `//gs c checksets`
- [Job-change manager](user/features/job-change-manager.md) — 3.0s
  debounce on rapid job/subjob swaps
- [UI overlay](user/features/ui.md) — In-game keybind HUD
- [Watchdog](user/features/watchdog.md) — Stuck-midcast auto-recovery
  with dynamic timeout

## Job documentation

Per-job state cycling, modes, and keybind notes live under
[user/jobs/](user/jobs/README.md).

| Category | Jobs |
| --- | --- |
| Mage | BLM · GEO · RDM · WHM |
| Support | BRD · COR |
| Tank | PLD · RUN |
| Melee | DNC · DRK · SAM · THF · WAR |
| Pet | BST |

> PUP has a 12-module scaffold but ships only a 20-line skeleton set
> file. See [PUP README](user/jobs/pup/README.md) if you want to fill
> it in yourself.

---

## What lives where

```
shared/utils/                    9 mandatory systems + extras
├── core/                        COMMON_COMMANDS, JobChangeManager, …
├── precast/                     PrecastGuard, CooldownChecker, WSPrecastHandler
├── midcast/                     MidcastManager
├── messages/                    Centralized formatter (76 modules)
├── inventory/                   //gs c rf
├── wardrobe/                    //gs c wo
├── craft/                       //gs c craft / fish / uncraft
├── warp/                        //gs c warp + 100+ aliases
├── ui/                          //gs c ui (overlay)
└── debug/                       fulltest / syscheck / lagdebug
```

```
shared/jobs/<job>/functions/     12 modules per job
├── <job>_functions.lua          Facade
├── <JOB>_PRECAST.lua            Guard → Cooldown → WS → job logic
├── <JOB>_MIDCAST.lua            MidcastManager.select_set() (mandatory)
├── <JOB>_AFTERCAST.lua          State restore
├── <JOB>_IDLE.lua / ENGAGED     Town detection, sub-modes
├── <JOB>_STATUS.lua / BUFFS     Buff/debuff handling
├── <JOB>_COMMANDS.lua           Per-job //gs c commands
├── <JOB>_MOVEMENT.lua           AutoMove integration
├── <JOB>_LOCKSTYLE.lua          Factory call (3 lines)
├── <JOB>_MACROBOOK.lua          Factory call (3 lines)
└── logic/                       Job-specific intelligence (set_builder, …)
```

```
<Yourname>/
├── <Yourname>_<JOB>.lua         Entry-point per job
├── sets/<job>_sets.lua          Equipment sets per job
└── config/                      All your customizations
    ├── DUALBOX_CONFIG.lua, REGION_CONFIG.lua, WARDROBE_CONFIG.lua, …
    ├── craft/CRAFT_REFILL.lua
    └── <job>/                   Per-job configs (KEYBINDS, STATES,
                                 LOCKSTYLE, MACROBOOK, REFILL, TP_CONFIG)
```

---

## Quick command sampler

```
//gs c                Toggle the keybind UI overlay
//gs c reload         Hot-reload current GearSwap
//gs c checksets      Validate every set, list missing/storage items
//gs c rf             Refill consumables for current job
//gs c wo             Wardrobe organize for current job
//gs c craft          Equip bonecraft set (HQ default)
//gs c fish           Equip fishing set
//gs c warp [dest]    Teleport (~50 destinations: w, ret, esc, tph, sd, ad, …)
//gs c info           Framework version + loaded modules
//gs c syscheck       Verify all jobs and core systems (alias: sc)
```

Full list: [commands reference](user/guides/commands.md).

# Documentation

Every page of the documentation, for players, developers and maintainers.
The code is the reference: pages are checked against it, and a page that
disagrees with the code is a bug in the page.

The same pages as one searchable site: open `docs/wiki/index.html` in a
browser (rebuild it with `python docs/tools/build_wiki.py` after editing a page).

17 jobs. PUP does not load yet. SMN's entry, configs and sets are not in the
public repository (its shared code is).

New here? Read, in this order: [installation](user/getting-started/installation.md),
[quick start](user/getting-started/quick-start.md),
[how it works](user/guides/how-it-works.md), then your job's page below. The
[project README](../README.md) is the one-page overview.

## Getting started

| Page | What it covers |
|---|---|
| [Installation](user/getting-started/installation.md) | Copy the files, create your character with the clone script, first load |
| [Quick start](user/getting-started/quick-start.md) | The HUD, the keys and the first commands to try |

## Player guides

| Page | What it covers |
|---|---|
| [How it works](user/guides/how-it-works.md) | What happens when you press an action, when gear changes by itself, the HUD, the chat lines, your files, reloads |
| [Commands](user/guides/commands.md) | Every `//gs c` command shared by all jobs |
| [Keybinds](user/guides/keybinds.md) | The key layout, Mote-Include's F9-F12 keys, the keybind files, your own modes (`<JOB>_CUSTOM.lua`), Combat Mode, Treasure Mode, temporary keys (`//gs c tb`) |
| [Set names](user/guides/sets.md) | Every set name any job understands: actions, subjob actions, Mote-Include layers, sets put on by themselves, per-job exceptions |
| [Configuration](user/guides/configuration.md) | Every file of `<YourName>/config/`: what it sets, who writes it |
| [Dual-box](user/guides/dualbox.md) | Main and alt, alt commands, box group orders, the alt window |
| [Sneak and Invisible](user/guides/stealth.md) | Alt+Z / Alt+X on you and your other characters, timers, warnings |
| [FAQ](user/guides/faq.md) | Common problems and their fix |
| [Glossary](user/guides/glossary.md) | FFXI and GearSwap words used in these pages |

## Features

| Page | What it covers |
|---|---|
| [Keybind HUD](user/features/ui.md) | `//gs c ui`, section and row order, look, settings files |
| [Equipment validation](user/features/equipment-validation.md) | `//gs c checksets`, the wardrobe audit and organizer, refill |
| [Auto-tier](user/features/auto-tier-system.md) | WHM Cure and DNC Waltz tier from missing HP; BLM, RDM and GEO spells stepping down a tier |
| [Job changes](user/features/job-change-manager.md) | What happens when you change job or subjob |
| [Midcast watchdog](user/features/watchdog.md) | Gear recovery when a cast is never confirmed |

## Jobs

Each job has a hub page, a modes-and-keys page (`states.md`) and a set-names
page (`sets.md`). Overview: [user/jobs/](user/jobs/README.md).

| Role | Jobs |
|---|---|
| Mage | [BLM](user/jobs/blm/README.md) · [BLU](user/jobs/blu/README.md) · [GEO](user/jobs/geo/README.md) · [RDM](user/jobs/rdm/README.md) · [WHM](user/jobs/whm/README.md) |
| Support | [BRD](user/jobs/brd/README.md) · [COR](user/jobs/cor/README.md) |
| Tank | [PLD](user/jobs/pld/README.md) · [RUN](user/jobs/run/README.md) |
| Melee | [DNC](user/jobs/dnc/README.md) · [DRK](user/jobs/drk/README.md) · [SAM](user/jobs/sam/README.md) · [THF](user/jobs/thf/README.md) · [WAR](user/jobs/war/README.md) |
| Pet | [BST](user/jobs/bst/README.md) · [SMN](user/jobs/smn/README.md) · [PUP](user/jobs/pup/README.md) (does not load yet) |

Shared by several jobs: [TP bonus gear](user/jobs/war/tp-bonus.md) (every job
with a `<JOB>_TP_CONFIG.lua`). SMN reference: [blood pacts and summons](SMN_BLOOD_PACTS_REFERENCE.md).

## Developer documentation

Written from the code, for anyone who changes it.

| Page | What it covers |
|---|---|
| [Developer start page](dev/README.md) | The project in one page: layers, boot sequence, life of an action, state and lifetime, map of every developer page, glossary |
| [Maintainer guide](dev/maintainer-guide.md) | How to change the project safely: workflows, checks, conventions |
| [Architecture](dev/README.md#architecture) | [Job change lifecycle](dev/architecture/job-change-lifecycle.md), [characters and templates](dev/architecture/characters-and-templates.md) |
| [Systems](dev/README.md#systems) | [Core lifecycle](dev/systems/core-lifecycle.md), [precast pipeline](dev/systems/precast-pipeline.md), [midcast and buffs](dev/systems/midcast-and-buffs.md), [commands and debug](dev/systems/commands-and-debug.md), [keybinds and CUSTOM](dev/systems/keybinds-and-custom.md), [HUD](dev/systems/ui-overlay.md), [messages](dev/systems/messages.md) ([catalog](dev/systems/messages-catalog.md), [formatters](dev/systems/messages-formatters.md)), [dual-box](dev/systems/dualbox.md), [stealth](dev/systems/stealth.md), [equipment and inventory](dev/systems/equipment-and-inventory.md), [wardrobe organizer](dev/systems/wardrobe-organizer.md), [warp](dev/systems/warp.md), [factories and helpers](dev/systems/factories-and-helpers.md) |
| [Data](dev/README.md#data) | [Spell databases](dev/data/spell-databases.md), [ability and weaponskill databases](dev/data/ability-and-weaponskill-databases.md) |
| [Jobs](dev/README.md#jobs) | [BLM](dev/jobs/blm.md) · [BLU](dev/jobs/blu.md) · [BRD](dev/jobs/brd.md) · [BST](dev/jobs/bst.md) · [COR](dev/jobs/cor.md) · [DNC](dev/jobs/dnc.md) · [DRK](dev/jobs/drk.md) · [GEO](dev/jobs/geo.md) · [PLD](dev/jobs/pld.md) · [PUP](dev/jobs/pup.md) · [RDM](dev/jobs/rdm.md) · [RUN](dev/jobs/run.md) · [SAM](dev/jobs/sam.md) · [SMN](dev/jobs/smn.md) · [THF](dev/jobs/thf.md) · [WAR](dev/jobs/war.md) · [WHM](dev/jobs/whm.md) |

## Your character folder

```
<YourName>/
├── <YourName>_<JOB>.lua     one file per job, loaded by GearSwap
├── sets/<job>_sets.lua      your gear
├── temp_binds.lua           temporary keys (//gs c tb), written in game
└── config/
    ├── COMMON_KEYBINDS.lua, UI_CONFIG.lua, LOCKSTYLE_CONFIG.lua, RECAST_CONFIG.lua,
    │   AUTO_ABILITIES.lua, WEAPON_CONFIG.lua, DW_CONFIG.lua, ELEMENTAL_BELT.lua,
    │   STEALTH_CONFIG.lua, DUALBOX_CONFIG.lua, REGION_CONFIG.lua, ...
    ├── ui_settings.lua, message_modes.lua, combat_mode.lua, ...   written in game
    ├── alt/                 alt commands (main character only)
    ├── craft/               CRAFT_REFILL.lua (you write it)
    └── <job>/               STATES, KEYBINDS, CUSTOM, LOCKSTYLE, MACROBOOK,
                             TP_CONFIG, HUD, REFILL, ...
```

Details: [configuration](user/guides/configuration.md).

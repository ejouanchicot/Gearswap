<div align="center">

# Tetsouo GearSwap

### A modular GearSwap setup for Final Fantasy XI (Windower 4)

[![Lua](https://img.shields.io/badge/Lua-5.1-blue?logo=lua&logoColor=white)](https://www.lua.org/)
[![Windower](https://img.shields.io/badge/Windower-4-purple)](https://www.windower.net/)
[![FFXI](https://img.shields.io/badge/FFXI-Retail-red)](https://www.playonline.com/ff11/)
[![Jobs](https://img.shields.io/badge/Jobs-16-green)](#jobs)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

[Quick start](#quick-start) · [Keys](#keys) · [Commands](#commands) · [Dual-box](#dual-box) · [Documentation](#documentation)

</div>

---

## What it is

A set of GearSwap files, built on Mote-Include, that swaps your gear for every
spell, ability and weaponskill, and adds the tools around it: a keybind HUD,
mode keys on the numeric keypad, warp shortcuts, a wardrobe organizer, a
consumable refill, a set checker, and a dual-box layer to drive a second
character from the first.

Every job shares the same code base: the job files only hold what is specific
to the job, and the rest (precast checks, midcast set choice, messages,
lockstyle, macro book) is common to all jobs.

## Jobs

| Job | Status |
|---|---|
| BLM, BRD, BST, COR, DNC, DRK, GEO, PLD, RDM, RUN, SAM, THF, WAR, WHM | Template shipped in `_master/`, offered by the clone script |
| SMN | Only in the Tetsouo template (`_master/Tetsouo/`): the clone script deploys it only when you rebuild the character named Tetsouo |
| PUP | **Does not load yet**: its configuration folder is missing, so the job file stops during loading. The clone script does not offer it |

The author plays BLM, BRD, BST, COR, DNC, PLD, SMN, THF and WAR on Tetsouo, and
COR, GEO, PLD and RDM on the dual-boxed alt. DRK, RUN, SAM and WHM exist as
templates but no maintained character plays them.

Per-job pages (modes, keys, commands): [docs/user/jobs/](docs/user/jobs/README.md).

## Quick start

### Requirements

- [Windower 4](https://www.windower.net/) with GearSwap.
- Python 3 on Windows, to run the clone script once.
- For dual-box only: the `send` addon on both characters.

### 1. Put the files in GearSwap's data folder

Download the repository (on GitHub: **Code** > **Download ZIP**) and copy its
content into:

```
<Windower>/addons/GearSwap/data/
```

You should see `_master/`, `shared/`, `docs/`, `clone_character.py` and
`CLONE_CHARACTER.bat` directly inside `data/`. With git:
`git clone https://github.com/ejouanchicot/Gearswap.git` into that folder.

### 2. Create your character's folder

Double-click `CLONE_CHARACTER.bat` (French prompts), or run it as
`CLONE_CHARACTER.bat en` for English. It asks, in order:

1. your character's name;
2. the jobs to deploy (comma-separated);
3. main or alt, and the name of the partner character (leave it empty to play
   without dual-box);
4. your region (US, EU or JP);
5. a final confirmation.

It then creates `data/<YourName>/` with one entry file per job
(`<YourName>_<JOB>.lua`), the set files under `sets/`, and the settings under
`config/`. If the folder already exists, it asks before replacing it and moves
the old one to `addons/GearSwap/clone_backups/` rather than deleting it; the
HUD position, message modes, alt window, alt state, owned warp items and
temporary keys you had are copied back.

### 3. Put in your gear

Open `data/<YourName>/sets/<job>_sets.lua` and replace the author's items with
yours (names and augments must match exactly). Check the result in game with
`//gs c checksets`.

### 4. Load it

Log in (or change job) with GearSwap loaded (`//lua load gearswap`): GearSwap
picks `data/<YourName>/<YourName>_<JOB>.lua` by itself. The keybind HUD appears
after a few seconds; `//gs c ui` shows or hides it.

Full walk-through: [installation](docs/user/getting-started/installation.md),
then [quick start](docs/user/getting-started/quick-start.md).

## Keys

All mode keys are on the numeric keypad, always with a modifier, so the bare
keypad stays free for the game.

| Keys | Use |
|---|---|
| Ctrl+Numpad (`^numpad0`-`^numpad9`, `^numpad.`, `^numpad+`...) | The job's modes. Ctrl+Numpad9 is Hybrid Mode on most jobs, Ctrl+Numpad1 / 2 the weapons when the job has weapon modes |
| Apps+Numpad (`#numpad1`...) | Extra modes on some jobs (BLM second spell set, BRD Etude, RDM storm) |
| Apps+Numpad0 (`#numpad0`) | Auto Medicine on/off, every job |
| Alt+Numpad7 / 8 / 9 (`!numpad7-9`) | Dual-box: alts follow you / automation on-off / mirror, every job |
| F9-F12 (with modifiers) | Mote-Include's own default keys |
| Ctrl/Alt+F1-F8 | Free for your temporary keys (`//gs c tb`) |

`^` is Ctrl, `!` Alt, `@` Windows, `#` Apps (the menu key), `~` Shift. The HUD
lists every key of the current job with the mode's current value. The keys of
each job are in `data/<YourName>/config/<job>/<JOB>_KEYBINDS.lua`, the keys
shared by every job in `data/<YourName>/config/COMMON_KEYBINDS.lua`, and your
own extra modes in `<JOB>_CUSTOM.lua`. See the
[keybinds guide](docs/user/guides/keybinds.md).

## Commands

Type them as `//gs c <command>`. `//gs c help` and `//gs c commands` print the
built-in help. Full list: [commands guide](docs/user/guides/commands.md).

| Command | What it does |
|---|---|
| `ui` | Show / hide the keybind HUD (`ui save` saves its position, `ui help` lists the options) |
| `checksets` | Lists the set items that are not in your inventory or wardrobes |
| `wa` | Wardrobe audit: items in your wardrobes that no set file uses |
| `wo` | Wardrobe organizer: moves the gear you use into the first wardrobes |
| `rf` | Refill consumables from the Mog Case and Mog Sack |
| `ls` | Re-apply the lockstyle |
| `reload` | Reload the job file |
| `warp`, `ret`, `esc`, `tph`, `sd`... | Warp, Retrace, Escape, teleports and destination items; add `all` (`warpall`) to send it to your other boxes |
| `mount` | Mount a random mount you own, or dismount |
| `naked` | Remove all gear |
| `am` | Auto Medicine on/off |
| `tb <key> <action>` | Temporary key on Ctrl/Alt+F1-F8 (`tb help`) |
| `info <name>` | Details of a job ability, spell or weaponskill |
| `waltz` / `aoewaltz` | Curing Waltz with the tier picked from the missing HP / Divine Waltz (DNC main or sub) |
| `craft` / `fish` / `uncraft` | Craft or fishing set (see [below](#craft-and-fishing)) |
| `watchdog` | Status of the midcast watchdog |

## Features

- **Precast checks, on every action.** Actions that cannot go off (silence,
  paralysis, amnesia...) are cancelled before any gear swap; with Auto Medicine
  on, Echo Drops or Remedy are used for silence, and Remedy or Panacea for
  paralysis before a job ability. Abilities and spells still on recast are
  cancelled with the time left. Weaponskills are checked for range and TP, and
  get TP-bonus gear from each job's `<JOB>_TP_CONFIG.lua`.
- **Midcast set choice.** One lookup order for every job, from the exact spell
  name down to the skill's base set. `//gs c debugmidcast` shows which set was
  picked.
- **Tier handling.** BLM nukes and RDM tiered enfeebles step down to the
  highest tier whose recast is ready and whose MP you have; GEO's nuke
  commands fall back to a lower tier that is learned and off recast. WHM picks the Cure tier from the target's missing HP,
  and `//gs c waltz` does the same for Curing Waltz.
- **Midcast watchdog.** If the game never confirms the end of a cast (packet
  loss), your normal gear comes back after the cast time plus a margin.
  See [watchdog](docs/user/features/watchdog.md).
- **Doom.** While Doomed, the Doom set goes on and neck, rings and waist
  stay locked until Doom is gone (or you die).
- **Job and subjob changes.** A subjob change reloads the job file after
  0.5 s; rapid changes collapse into one reload. If GearSwap ever loads the
  wrong job file, it is reloaded.
- **Lockstyle and macro book** per job (the macro book also per subjob and
  per partner job): the macro book is set about 1.5 s after a load, the
  lockstyle 8 s after.
  By default the DressUp addon is unloaded around `/lockstyleset` and loaded
  again 3 s later; `//gs c dressup` turns that off.
- **Keybind HUD** with the current value of every mode.
  See [HUD](docs/user/features/ui.md).
- **Inventory tools**: `checksets`, `wa`, `wo`, `rf`.
  See [equipment validation](docs/user/features/equipment-validation.md).
- **Warp**: 105 short commands. `warp`, `w2`, `ret`, `esc`, `tph`, `tpd`,
  `tpm`, `tpa`, `tpy`, `tpv` cast the spell when your job can and otherwise use
  a ring; destination commands (`sd`, `bt`, `wd`, `jn`, `ad`, `op`...) use the
  matching item. `warp help` lists the system commands.
- **Your own modes without code.** `<JOB>_CUSTOM.lua` adds a mode with a key
  and gear rules ("with this weapon, wear this") on top of the job's choice.

## Dual-box

With two characters on the same PC, each running this setup:

- The two boxes exchange their current job a few seconds after each load, so
  the macro book can follow your partner's job.
- **Alt commands**: on the main, `//gs c haste` makes a RDM alt cast Haste
  (Haste II at level 96 and up) on what you last selected. The list follows the alt's job: `//gs c altcmds`.
- **Box group orders**: `//gs c alts follow`, `alts on`, `alts off`,
  `alts mirror`, `alts do <console command>` go to every other character of
  the group (Alt+Numpad7-9 by default). Follow, automation and mirror expect
  an automation addon that answers `sm` console commands.
- **Swap roles**: `//gs c main` on the character that should lead.
- **Alt window** on the main: each alt's job, whether it is in your party, and
  the last follow / automation / mirror order. `//gs c alts window` shows or
  hides it.

Setup and details: [dual-box guide](docs/user/guides/dualbox.md).

## Craft and fishing

`//gs c craft [variant]` and `//gs c fish` equip a set from
`data/<YourName>/sets/bonecraft_sets.lua` and `fishing_sets.lua`, lock it and
apply a craft lockstyle; `//gs c uncraft` (or `craft off`) gives your job gear
back. Those two set files ship **only with the Tetsouo template**: another
character gets "No set file" until you write them. Use
`_master/Tetsouo/sets/bonecraft_sets.lua` as the model.

## Documentation

| Page | For |
|---|---|
| [docs/README.md](docs/README.md) | Index of the player guides |
| [docs/user/jobs/](docs/user/jobs/README.md) | Modes, keys and commands of each job |
| [docs/dev/README.md](docs/dev/README.md) | Developer documentation: how the code works, written from the code |

## License

[MIT](LICENSE) - Copyright (c) 2026 Tetsouo.

Made by Tetsouo - [github.com/ejouanchicot/Gearswap](https://github.com/ejouanchicot/Gearswap)
· [Issues](https://github.com/ejouanchicot/Gearswap/issues)

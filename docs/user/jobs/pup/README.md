# PUP — Puppetmaster

> **PUP does not load today.** Selecting Puppetmaster makes GearSwap stop while
> loading the job file: no gear swaps, no keys, no HUD, no commands. The clone
> script does not offer PUP, so a new character never gets a PUP file.

## Why it does not load

The job's code exists, but the configuration folder it needs does not. The
provided entry file for PUP asks for `config/pup/PUP_PET_DATA.lua` and
`config/pup/PUP_TP_CONFIG.lua` without any fallback, and the provided template
has no `config/pup/` folder at all. GearSwap stops at the first missing file.

Even with those files, it would not work as a Puppetmaster:

- The PUP code is a copy of the Beastmaster code. It knows Call Beast, jugs,
  ecosystems and Ready moves, which Puppetmaster does not have.
- Nothing in it knows the automaton: no maneuvers, no Repair, no Deploy or
  Retrieve, no Overdrive, no automaton weaponskills or spells.
- Parts it relies on were never written (idle and engaged gear, pet tracking,
  PUP chat messages), so idle, engaged, spells and most commands would fail.
- The provided `pup_sets.lua` declares no gear.

## Keys, modes and commands

None today. PUP has no key file, no modes file and no PUP command that works.
When it loads one day, the shared keys and commands of every job will apply as on
other jobs ([keybinds guide](../../guides/keybinds.md),
[commands guide](../../guides/commands.md)).

## What is documented

| Page | Content |
|---|---|
| [sets.md](sets.md) | The set names the PUP code **would** read once it loads, so nothing is lost when the job is finished |
| [Developer page](../../../dev/jobs/pup.md) | What exists, what is missing, what breaks, and the minimum work to make PUP load |

There is no PUP states page: PUP has no modes yet.

## Making it work

At least: the missing `config/pup/` files (modes, keys, pet data, TP settings,
lockstyle, macro book), automaton handling in place of the Beastmaster logic, and
real sets. The [developer page](../../../dev/jobs/pup.md) lists every piece.

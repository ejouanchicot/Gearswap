# PUP — set names and automatic gear

> **PUP does not load today.** The template entry file asks for configuration
> files that do not exist (`config/pup/`), so GearSwap stops while loading the
> job and no gear ever swaps. The clone script does not offer PUP. This page
> lists what the PUP code **would** read once it loads, so nothing is lost when
> the job is finished. See [README.md](README.md) for what is missing.

Common names (any job, subjob actions, automatic shared sets):
[set names](../../guides/sets.md). There is no PUP states page: PUP has no modes
yet.

**The PUP code is a copy of the Beastmaster code.** It handles Call Beast, jugs
and Ready moves, which Puppetmaster does not have. Nothing in it knows the
automaton: no maneuvers, no Repair, no Overdrive, no automaton weaponskills or
spells. Most names below are therefore BST names, with the same meaning as on
the [BST page](../bst/sets.md).

## The provided file

`sets/pup_sets.lua` declares no gear. It only defines a function that creates
empty tables, and nothing calls that function. Sets written inside it would never
exist: write them as plain lines (`sets.idle = {...}`) outside the function.

## Idle and engaged

The idle and engaged sets would be built by a PUP set builder that does not exist
yet. As the code stands, every gear refresh would stop with an error, so no idle
or engaged set is worn, not even `sets.idle` / `sets.engaged`.

## Weaponskills

| Set | Worn when |
|---|---|
| `sets.precast.WS` | Any weaponskill without its own set |
| `sets.precast.WS['Name']` | That weaponskill |

The TP bonus piece would be put on by itself from `PUP_TP_CONFIG.lua` (like
Moonshade on BST), but that file does not exist. A weaponskill under 1000 TP
would be cancelled.

## Job abilities

Any job ability uses `sets.precast.JA['Name']` (common rule): `Activate`,
`Deploy`, `Repair`, `Maintenance`, `Overdrive`, `Ventriloquy`, `Role Reversal`,
`Tactical Switch`, the maneuvers (`Fire Maneuver`...). Nothing in the PUP code
treats them specially.

Left over from BST, the code would also read:

| Set | Worn when |
|---|---|
| `sets.precast.JA['Call Beast']` and `sets['<pet name>']` (its `ammo`) | Call Beast / Bestial Loyalty (Beastmaster abilities: never on PUP) |
| `sets.precast.JA['Ready']`, else `sets.precast.JA['Sic']` | A Beastmaster Ready move (never on PUP) |

## Automaton actions

When the automaton acts (its weaponskills, its spells), the code would put on:

| Set | Worn when |
|---|---|
| `sets.midcast.pet_physical_moves` | **Every** automaton action. The code sorts pet actions with the BST Ready move lists, which PUP does not have, so everything falls into this "physical" set |
| `sets.midcast.Pet`, or per action `sets.midcast.Pet['<action name>']` | Every automaton action, right after, on top of the set above |

`sets.midcast.Pet` is the one to use for automaton gear once the job works:
it is read by the underlying library, not by the unfinished PUP code. Your
normal gear comes back when the automaton's action ends.

The BST category names `sets.midcast.pet_physicalMulti_moves`,
`pet_magicAtk_moves`, `pet_magicAcc_moves` and their `_ww` versions are also in
the code but can never be chosen on PUP.

## Subjob magic

Healing, Enhancing, Enfeebling, Elemental and Blue Magic from your subjob go to
the common names (`sets.midcast['Healing Magic']`...). As the code stands, every
midcast would stop with an error first, so they would not be worn either. The
precast sets (`sets.precast.FC`, `sets.precast.JA`, `sets.precast.WS`) would
still be worn: that part of the code does not depend on the missing files.

## What the job would do by itself

- **Pet check every game minute.** The template entry file registers a check
  that runs every in-game minute (about 2.4 s): it would update a "pet fighting"
  flag and, while you are engaged, send your pet to fight. Today this check
  loads a file that does not exist and prints a Lua error each time, as long as
  PUP is your main job after a failed load.
- **No automaton handling.** No gear change on maneuvers, Repair or Overdrive,
  and nothing when the automaton is deployed or retrieved.

## Sets in the provided file that nothing reads

All of them: the file's only function is never called.

## Names the code reads that the provided file lacks

Every name on this page.

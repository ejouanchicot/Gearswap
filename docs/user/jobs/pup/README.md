# PUP — Puppetmaster

> **Status: scaffold only.** PUP has a working 12-module structure plus
> the dedicated `PUP_PET_PRECAST.lua` and `PUP_PET_MIDCAST.lua` modules
> for automaton command handling, but the set file
> `_master/sets/pup_sets.lua` is a 20-line skeleton:
>
> ```lua
> --- PUP Equipment Sets - SKELETON
> --- Skeleton file for PUP (job not currently played)
> --- Allows Tetsouo_PUP.lua to load without errors
> ```
>
> If you actually play PUP, fork the project and fill the skeleton in.
> No specialty logic ships in `shared/jobs/pup/functions/logic/` (the
> folder doesn't exist).

## Modules

14 modules: 12 standard (precast / midcast / aftercast / idle / engaged /
status / buffs / commands / movement / lockstyle / macrobook + facade)
plus `PUP_PET_PRECAST.lua` and `PUP_PET_MIDCAST.lua` for automaton gear.

## Setup

1. Copy `_master/entry/Tetsouo_PUP.lua` to `<Yourname>/<Yourname>_PUP.lua`
2. Copy `_master/config/pup/` to `<Yourname>/config/pup/`
3. Copy `_master/sets/pup_sets.lua` to `<Yourname>/sets/` and **rewrite
   the skeleton** with real precast / midcast / engaged / pet sets.

## Commands

Standard universal commands only. See [commands reference](../../guides/commands.md).

There are no PUP-specific commands wired in
`shared/jobs/pup/functions/PUP_COMMANDS.lua` beyond the framework
defaults.

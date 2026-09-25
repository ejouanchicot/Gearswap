# PUP - not functional yet

PUP does not load today. Its job modules exist
(`shared/jobs/pup/functions/`), but the configuration folder they need,
`_master/config/pup/`, does not exist. The entry file
(`_master/entry/Tetsouo_PUP.lua`) requires `PUP_PET_DATA` and
`PUP_TP_CONFIG` from that folder without a fallback, so GearSwap stops while
loading the job file.

- The clone script does not offer PUP.
- `_master/sets/pup_sets.lua` declares no gear.
- No character of the author plays PUP.

Making it work would need at least the missing `config/pup/` files (states,
keybinds, pet data, TP config, lockstyle, macro book) and real sets. See the
developer page [docs/dev/jobs/pup.md](../../../dev/jobs/pup.md) for what is
missing.

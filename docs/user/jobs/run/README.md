# RUN — Rune Fencer

Tank job. Shares its rune / AOE / cure infrastructure with PLD —
`shared/jobs/run/functions/logic/` mirrors `shared/jobs/pld/functions/logic/`.

## Modules

Standard 12-module setup plus 4 logic modules:

- `aoe_manager.lua` — AOE BLU enmity rotation (requires /BLU sub)
- `rune_manager.lua` — Rune ability selection and casting
- `cure_set_builder.lua` — Priority-based cure target selection
- `set_builder.lua` — Engagement / weapon set selection

## Setup

1. Copy `_master/entry/Tetsouo_RUN.lua` to `<Yourname>/<Yourname>_RUN.lua`
2. Copy `_master/config/run/` to `<Yourname>/config/run/`
3. Copy `_master/sets/run_sets.lua` to `<Yourname>/sets/` and fill in
   your gear

## Commands

| Command | Description |
| --- | --- |
| `aoe` | AoE BLU enmity rotation (requires /BLU) |
| `rune` | Cast the currently-selected rune |
| `cyclestate MainWeapon`, `HybridMode`, `RuneMode` | Standard cycles |

See the universal [commands reference](../../guides/commands.md) for the
rest.

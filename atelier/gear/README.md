# atelier/gear — the Atelier's gear catalogue

Every equipable piece of the game with its stats, the augments of rank and path pieces, the
Ambuscade capes, the Skirmish armour, the Reive capes, the Oseem pieces and the reader of augment
strings. The page loads seven files (`ENGINE_FILES` in `atelier/app/js/engine.js`; a player's package
takes the same seven, `DATA_FILES` in `make_package.py`):

| File | Gives | Built by |
|---|---|---|
| `items.js` | `FFXI.CATALOG`: 15 527 pieces from Windower `res/items.lua` + `res/item_descriptions.lua` | `build_catalog.py` |
| `augments_ranked.js` | `FFXI.RANKED`: Odyssey, Limbus, JSE necks, Dynamis-D, ultimate weapons, Unity, Nolan by path and rank (LandSandBoat's bundles) | `augments_build.py` (`augments_all.cmd`) |
| `capes.js` | `FFXI.AMBU_CAPES`, the materials of the Ambuscade capes (BG Wiki) | `capes_build.py` |
| `skirmish.js` | `FFXI.SKIRMISH_SETS`, `SKIRMISH_STONES`, `SKIRMISH_BY_NAME`: the five Alluvion Skirmish sets and the augments each stone gives, at their max | `skirmish_build.py` from `skirmish_source.json` (BG Wiki) |
| `reive.js` | `FFXI.REIVE_BY_NAME`: the Reive / Incursion capes and their four augments, at their max | `reive_build.py` from `reive_source.json` (BG Wiki) |
| `oseem.js` | `FFXI.OSEEM_BY_NAME`, `OSEEM_DARK`: the Oseem (Reisenjima) armour and Escha weapons, each augment by path at its cap, and the Dark Matter stats | `oseem_build.py` from `oseem_source.json` (BG Wiki) |
| `augments_parse.js` | `FFXI.parse_augments`: the augment strings the export gives | by hand |

Stat names: `STAT_KEYS.md`. Augments: `AUGMENTS.md`.

## Where the values come from

- Windower's resources for what the game's text says.
- BG Wiki for what the text leaves out: `HIDDEN` in `build_catalog.py` (a dozen pieces) and
  `hidden_values.json` (`hidden_fetch.py` -> `hidden_parse.py` -> `hidden_review.py`, ~280 pieces), each
  value with its page. `hidden_review.py` ELSEWHERE holds the few read on another page than the piece's own.
- LandSandBoat and OmniWatch for the augment bundles, checked against BG Wiki (`augments_check_bgwiki.js`).
- BG Wiki tables for the Skirmish, Reive and Oseem augments (`skirmish_source.json`, `reive_source.json`,
  `oseem_source.json`), each augment written as the game shows it (`augment_labels.py`).

No value comes from wsdist (IzaKastra's damage calculator, no licence) since 2026-10-22
(`notes/docs-perso/moteur-sans-wsdist-2026-10-22/SPEC.md`, Lot 1; what was replaced: `atelier/calc/DIFFERENCES.md`
section AE). The stat names are the ones the engine before reads, so both read the same pieces.

## Rebuild

1. `python build_catalog.py [--res "D:/Windower Tetsouo/res"]` (Lua 5.1 on the PATH) -> `items.json`, `items.js`.
2. `augments_all.cmd` -> `augments_ranked.*`, `capes.*`, and the checks. Its sources must be in `cache/`.
3. `python skirmish_build.py`, `python reive_build.py`, `python oseem_build.py` -> `skirmish.js`, `reive.js`,
   `oseem.js` (`augments_all.cmd` does not run them). Each reads its `*_source.json` and `items.json` (step 1),
   writes the data followed by its `*_tail.js` (the functions: `FFXI.skirmish_max`, `reive_max`, `oseem_max`...),
   then runs its `*_check.js` (Node): every augment line must be read by `augments_parse.js` at its value.

## Kept on this PC only (gitignored)

`cache/`, `cache_base/`, `cache_bgwiki/` (copies of the sources), the `.json` twins of the built `.js`, and
the tools that compare with wsdist's `gear.py`: `validate.py`, `augments_gearpy_extract.py`,
`augments_check_gearpy.py`, `capes_gearpy_dump.py`, `capes_check.js`.

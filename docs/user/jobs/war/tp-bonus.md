# TP bonus gear (all jobs)

This page applies to every job that has a `<JOB>_TP_CONFIG.lua`, not only WAR.

Before a weaponskill, the weaponskill handler adds up your current TP and the
TP bonus you already have (weapon, buffs). If a TP bonus piece lets you reach
the next step (2000 or 3000 TP), it equips the fewest pieces that do it. If no
piece can reach the next step, nothing is added. TP is capped at 3000.

## Pieces (equipped only when they help)

| Item | Slot | Bonus | Jobs (template configs) |
|------|------|-------|------|
| Moonshade Earring | ear1 | +250 | BRD, BST, COR, DNC, DRK, GEO, PLD, RDM, RUN, SAM, THF, WAR, WHM |
| Boii Cuisses +3 | legs | +100 | WAR |
| Mpaca's Cap | head | +200 | SAM |

BLM's config names Moonshade Earring in a `moonshade` field that the
calculator does not read (it reads `pieces`), so BLM never swaps it in today.

## Weapons (counted when held)

| Job | Weapon | Bonus |
|-----|--------|-------|
| WAR | Chango | +500 |
| PLD | Sequence | +500 |
| RUN | Lionheart | +500 |
| DRK | Anguta | +500 |
| SAM | Dojikiri Yasutsuna | +500 |
| THF, DNC, BRD | Aeneas | +500 |
| THF, DNC, BRD | Centovente | +1000 |
| COR | Fomalhaut | +500 |
| COR | Anarchy +2 | +1000 |

## Buffs and traits (counted when active)

| Job | Source | Value in the code |
|-----|--------|-------------------|
| WAR | Warcry (while the buff is up) | 100 per Savagery merit, 140 per merit with Agoge Mask (`savagery_merits`, template 5 → 700) |
| WAR | Fencer (one-handed weapon, shield or empty off hand) | 630 + 11.5 per JP gift rank (`fencer_jp_gifts`, template 20 → 860) |
| BST | Fencer | Base by level: 200 at 80, 300 at 87, 400 at 94+; plus 50 / 50 / 60 / 70 for JP gift ranks 1-4 (`fencer_jp_gifts`, template 4 → 630 at 99) |
| SAM | Hagakure (while the buff is up) | 1000 + 10 per JP gift rank (`hagakure_jp_gifts`, template 0 → 1000) |

Set the merit / JP numbers and the Agoge Mask flag to match your character in
the job's TP config.

## Which jobs have it

14 of the 16 jobs ship a `<JOB>_TP_CONFIG.lua` in `_master/config/<job>/`.
SMN and PUP have none (PUP does not load yet; SMN's files only exist in the
Tetsouo template).

## Files

- Per job: `<Char>/config/<job>/<JOB>_TP_CONFIG.lua`
- Code: `shared/utils/precast/ws_precast_handler.lua`,
  `shared/utils/precast/tp_bonus_handler.lua`,
  `shared/utils/weaponskill/tp_bonus_calculator.lua`

See also: [job index](../README.md), [configuration](../../guides/configuration.md).

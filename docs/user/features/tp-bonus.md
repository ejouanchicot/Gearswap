# TP bonus gear (all jobs)

This page applies to every job that has a `<JOB>_TP_CONFIG.lua`.

Before a weaponskill, the weaponskill handler adds up your current TP and the
TP bonus you already have (weapon, buffs, and the TP pieces your weaponskill set
wears already, such as Boii Cuisses written in `sets.precast.WS`). If TP bonus
pieces let you reach the next step (2000 or 3000 TP), it equips the fewest that
do it; when one piece is enough, the smallest one that is (a gap of 100 takes
Boii Cuisses +100, not Moonshade +250, so the ear keeps the set's earring). If
the pieces cannot reach the next step, nothing is added. TP is capped at 3000.

The pieces are only ever added, never taken off: a TP piece written in a
weaponskill set stays on even when it is of no use (at 3000 TP, say). Leave them
out of your weaponskill sets and let this rule put them on.

Example (WAR, Laphria, Warcry with 5 Savagery merits and Agoge = 700, Boii
Cuisses in the base WS set):

| TP | Added | TP at the weaponskill |
|----|-------|------|
| 1000 | Moonshade | 2050 |
| 1200 | nothing | 2000 |
| 1950 | Moonshade | 3000 |
| 2200 | nothing | 3000 |

The Atelier page (Sets tab, a weaponskill set) shows these steps and the TP the
weaponskill opens with, worked out the same way.

## Pieces (equipped only when they help)

| Item | Slot | Bonus | Jobs (template configs) |
|------|------|-------|------|
| Moonshade Earring | ear1 | +250 | BLU, BRD, BST, COR, DNC, DRG, DRK, GEO, MNK, NIN, PLD, PUP, RDM, RNG, RUN, SAM, SCH, THF, WAR, WHM |
| Boii Cuisses +3 | legs | +100 | WAR |
| Mpaca's Cap | head | +200 | SAM |

BLM's config names Moonshade Earring in a `moonshade` field that the
calculator does not read (it reads `pieces`), so BLM never swaps it in today.

## Weapons (counted when held)

Any weapon, main hand or off hand, is counted without a list: its TP Bonus is read from the
game's description (`"TP Bonus"+500` on Chango, Centovente's +1000) and from your copy as
`//gs c gearscan` read it, its augments and the stats of its path rank (Ikenga's Axe R23:
+200, R25: +300, R30: +500). After upgrading a weapon, run `//gs c gearscan` then `//gs reload`.
A weapon your job's TP config lists keeps the value written there (the table below):

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
| WAR | Warcry (while the buff is up) | 100 per Savagery merit, 140 per merit with Agoge Mask (`savagery_merits` and `has_agoge_mask`, template `'auto'`: your merits read in game, the mask looked for in your bags; 5 merits with the mask → 700) |
| WAR | Fencer (one-handed weapon, shield or empty off hand) | 630 + the job point gifts (`fencer_jp_gifts`, template `'auto'`: read from the job points spent on WAR, 230 in all → 860; a number 0 to 20 forces 11.5 each) |
| BST | Fencer | Base by level: 200 at 80, 300 at 87, 400 at 94+; plus 50 / 50 / 60 / 70 for JP gift ranks 1-4 (`fencer_jp_gifts`, template `'auto'`: read from the job points spent on BST; 4 → 630 at 99) |
| SAM | Hagakure (while the buff is up) | 1000 + 10 per JP gift rank (`hagakure_jp_gifts`, template 0 → 1000) |

On `'auto'` these values are read from the game; type a number (or `true` /
`false` for the Agoge Mask) in the job's TP config only to force one. SAM's
`hagakure_jp_gifts` is a number you set.

## Which jobs have it

21 of the 22 jobs ship a `<JOB>_TP_CONFIG.lua` in `_master/config/<job>/`.
SMN has none. PUP's file also holds `pet_ws_tp`, the automaton TP from which
its weaponskill gear goes on ([PUP modes](../jobs/pup/states.md#pet-ws)).

## Files

- Per job: `<Char>/<job>/combat/<JOB>_TP_CONFIG.lua`
- Code: `shared/utils/precast/ws_precast_handler.lua`,
  `shared/utils/precast/tp_bonus_handler.lua`,
  `shared/utils/weaponskill/tp_bonus_calculator.lua`

See also: [job index](../jobs/README.md), [configuration](../guides/configuration.md).

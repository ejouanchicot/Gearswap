# TP bonus gear (all jobs)

This page applies to every job that has a `<JOB>_TP_CONFIG.lua`.

Before a weaponskill, GearSwap puts on the TP bonus pieces of your config
(Moonshade Earring, Boii Cuisses...) **when they add more damage than the set
pieces they replace**. A weaponskill's fTP rises in a straight line between its
values at 1000, 2000 and 3000 TP, and a TP Bonus counts as that much more TP:
a piece is worth something at any TP, not only where it reaches 2000 or 3000.
TP is capped at 3000: at 3000 a TP piece adds nothing and only costs the set's
piece. Measured in game in November 2026: on Disaster, Moonshade + Boii Cuisses
gave +17 % under 2000 TP, and -5 % at 3000.

How GearSwap decides, in this order:

1. **The Atelier's table.** At each export of a job, the Atelier page works out
   with its damage engine, for every weaponskill set and weapon, which pieces
   add the most at each step of 50 TP (your set's real stats, critical hit rate
   by TP, Fencer, the 3000 cap), and writes it into one file a job,
   `<Char>/atelier/overrides/tp_pieces_<JOB>.lua` (`tp_pieces_WAR.lua`...): the
   game reads only the file of the job you play. A piece goes on only where the
   engine finds a real gain. The table is used only while your weaponskill set
   is the one it was worked out for.
   - It is worked out with the buffs ticked in the Atelier's panel (Warcry aside,
     which moves the TP in game). Tick other buffs and hold still a few seconds:
     the table is worked out and written again.
   - A weaponskill set the engine cannot work out (a ranged weaponskill such as
     Blast Shot, an fTP not known) is left out and named in the message; the
     job's other sets still get their table, and that one is left to the formula.
2. **The fTP formula**, without a table or once you changed the set: the gain
   the fTP's rise gives, against `replaces` (3 % by default, in your
   `<JOB>_TP_CONFIG.lua`) for each set piece taken off. Never on a weaponskill
   whose fTP stays the same at every TP (Ukko's Fury, Evisceration: their TP
   raises the critical hit rate, accuracy or a duration).
3. **The 2000 / 3000 steps**, the rule before, for a weaponskill whose fTP is
   not known (Shadowstitch, Mordant Rime, Raging Rush, True Strike).

The TP your weapon, Fencer, Warcry, Hagakure and the TP pieces your set wears
already (Boii Cuisses written in `sets.precast.WS`) give are counted first.
Leave TP pieces out of your weaponskill sets and let this rule put them on: a
piece written in the set stays on even where it costs damage (at 3000 TP).

Example (WAR, Laphria, the Disaster set as exported on 2026-11-12, the buffs and target
chosen in the page; the Atelier's figures, which move with your set, buffs and target):

| TP | Put on | Damage added |
|----|--------|------|
| 1000 to 2800 | Moonshade + Boii Cuisses | +31 % at 1000 |
| 2850 to 3000 | Boii Cuisses alone | +5 % at 2850, +1.5 % at 3000 |

At 3000 TP the TP Bonus adds nothing: Boii Cuisses stays there for its other stats
(physical damage limit), which the engine finds worth more than the set's Nyame
Flanchard. With the table, that counts even at 3000; without it, nothing goes on
at 3000.

`//gs c trace` writes each decision on a `TP` line: the real TP, where the
decision came from (`table`, `formula`, `formula (set changed)`, `thresholds`,
`capped`), the pieces and the gain expected.

The Atelier page (Sets tab, a weaponskill set) shows the TP where the pieces
change, each with what goes on and what it adds, worked out the same way; its
optimizer and its fight simulation use the same decision.

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
- The Atelier's table, one file a job: `<Char>/atelier/overrides/tp_pieces_<JOB>.lua` (delete it: the formula decides for that job)
- Code: `shared/utils/precast/ws_precast_handler.lua`,
  `shared/utils/precast/tp_bonus_handler.lua`,
  `shared/utils/weaponskill/tp_bonus_calculator.lua`,
  `shared/utils/weaponskill/tp_piece_decision.lua`,
  `shared/utils/weaponskill/tp_pieces_table.lua`, page `atelier/app/js/tp_table.js`

See also: [job index](../jobs/README.md), [configuration](../guides/configuration.md).

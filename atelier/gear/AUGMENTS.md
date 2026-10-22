# Augment layer

What an owned piece's augments add, in the catalogue's stat keys (`STAT_KEYS.md`; the
names the engine before reads). Three parts, each a part file of the page's engine
(`FFXI_PARTS`), plus its JSON:

| File | Gives |
|---|---|
| `augments_ranked.js/.json` | `FFXI.RANKED`, `FFXI.ranked_stats(name, path, rank)`: rank/path items |
| `capes.js/.json` | `FFXI.AMBU_CAPE_OPTIONS`, `FFXI.AMBU_CAPES`, `FFXI.ambu_cape_stats(choice)` |
| `augments_parse.js` | `FFXI.parse_augments(itemName, augs, rankIfKnown)`, `FFXI.parse_augment_string(s)` |

Rebuild and check everything: `augments_all.cmd` (sources must be in `cache/`).

## Keys

The catalogue's stat keys (`FFXI.AUG_STAT_KEYS`, `augments_build.py` STAT_KEYS) go to
`stats`; anything else goes to `extra` under a readable
key: `HP`, `MP`, `Defense`, `Enmity`, `Fast Cast`, `Cure Potency`, `Refresh`,
`Regen`, `Snapshot`, `Avatar:...`, `Automaton:...`,
`Wyvern:...`, `WS Damage%:<WS>` (per-WS damage), Dynamis-D path C effects
(`Phantom Roll`, `Chakra`...). Values carry the sign the game shows: `DT -10`,
`PDT -10`, `Enmity -5`, recast/casting-time reductions negative.
`Spell Interruption Down` counts the reduction (+10).

## 1. Rank / path items (`augments_ranked`)

`FFXI.RANKED[en] = {id, kind, max_rank, wiki, paths: {A: {bundle, effects}}}`,
keyed by Windower's `en` short name (`"Sakpata's Plate"`, `"Obstin. Sash"`);
`FFXI.RANKED_ALIASES` maps full names (`"Sakpata's Breastplate"`) and log names
to it, `FFXI.ranked_entry(name)` accepts both. An effect is
`{text, keys: {key: multiplier}, values: [rank 0..30]}`; `ranked_stats` sums
`multiplier * values[rank]`.

Source: LandSandBoat `scripts/data/augments.lua`, `xi.data.augments.bundles`
(496 bundles from the client DAT, value per rank). LSB has no item names; the
layout was worked out and checked (`augments_build.py`):

| kind | items | bundles |
|---|---|---|
| odyssey | 64: Nyame (A 438, B 443, C 448, D 453, head..feet), Ikenga 408, Gleti 413, Sakpata 418, Mpaca 423, Agwu 428, Bunzi 433, 15 weapons 393-407 (skill order), 14 Atonement 1/2 and later pieces 458-471 | 393-471 |
| limbus | 25: Revelation 472, Duty 477, Indomitable 482, Sworn 487, Clemency 492 | 472-496 |
| jse_neck | 44: Dynamis-D necks +1 (rank 20) / +2 (rank 25), WAR..RUN order, one bundle per job | 199-220 |
| dynamis_weapon | 66: 22 families in item id order x NQ/HQ1/HQ2 (ranks 15/20/25) x paths A/B/C | 1-198 |
| ultimate_weapon | 64: relic/mythic/ergon/empyrean then aeonic, rank 15 (each bundle checked to name its weapon's WS) | 221-284 |
| unity | 106 Unity +1 items, matched on their augment list (`augments_unity_match.js`) | 285-392 |
| nolan | 10: Kaykaus Mitra/Bliaut/Cuffs/Tights/Boots NQ and +1, four fixed paths (Nolan, Eschalixirs), written by hand from BG Wiki in `augments_build.py` | `kaykaus<+1>:<slot>:<path>` |

Not mapped: bundles 321 (Healing/Enhancing skill +10, DT -10) and 358
(DEX/AGI +10), no Unity item found for them.

Effect conversion (`augments_effects.py`): DAT effect id or LSB parametric
(Accuracy/Attack/Defense bit masks, attribute combos, Pet/Avatar/Automaton/
Wyvern/Luopan prefixes, per-WS damage) to keys. TP Bonus (id 353) is stored in
tenths (Ikenga's Axe 50 = TP Bonus +500). Pet effect 100 is Accuracy + Magic
Accuracy (no Ranged), as LSB and BG Wiki write it.

Corrections (LSB disagreeing with BG Wiki):
- 237 Gambanteinn: LSB mask reads AGI/MND/CHR +20, others say HP, MP & MND +20.
- 280 Khatvanga: LSB DMG +26, others DMG +8 (Tishtrya's curve used).

## 2. Ambuscade capes (`capes`)

`FFXI.AMBU_CAPE_OPTIONS[material]` (thread, dust, dye, sap, resin) =
`[{label, keys, step, max}]` from BG Wiki *Template:Ambuscade Cape Augments*
(Thread: attribute +20 or HP/MP +60, pet pairs; Dust: Acc/Atk, Racc/Ratk,
Macc/Mdmg, Eva/Meva +20; Dye: one stat +10, HP/MP +20; Sap: WSD, Crit, STP, DA,
Haste, DW, Enmity +/-, Snapshot, MAB, FC, Cure, Waltz, Pet Regen/Haste +10;
Resin: DEF +50, Eva/Meva +15, PDT/MDT -10, DT -5, Regen +5, Counter +10, ...).
The wiki leaves the DT/Pet DT max blank: -5 (5 Resin at -1).
`FFXI.AMBU_CAPES` = the 22 job capes (`job, en, name, id`: Windower res/items.lua 26246-26267).
`FFXI.ambu_cape_stats({thread:'STR', dust:'Accuracy', dye:'STR', sap:'Weapon Skill Damage', resin:'PDT'})`
gives the full cape (`'Enmity-'` picks the minus Enmity Sap).

## 3. Owned items (`augments_parse`)

`FFXI.parse_augments(name, augs, rank)` ->
`{stats, extra, path, rank, rank_assumed, ranked, unknown: [strings]}`.
Strings: every label of extdata.lua `augment_values` systems 1 and 2
(`'Accuracy+20 Attack+20'`, `'"Dbl.Atk."+3'`, `'Mag. Acc+20 /Mag. Dmg.+20'`,
`'Pet: Acc.+20 Pet: R.Acc.+20'`, `'Savage Blade:DMG:+10%'`, a `'Pet:'` marker
line prefixing the next lines), plus BG Wiki and LSB spellings
(`'Acc/RngAcc/MagAcc+30'`, `'STR & DEX +15'`, `'STR DEX +20'`). `'Path: X'` and
`'Rank: N'` set path and rank; when the strings carry no stat and the item is in
`FFXI.RANKED`, its stats at that path/rank are added (rank missing: the item's
max, `rank_assumed: true`). Left in `unknown`: elemental affinities,
"Enhances ... effect", ability delays, Vs. family, additional effects,
resistances, value-less flags.

## Checks (last run)

- `augments_parse_test.js`: 75/75 golden strings; 851 extdata augments
  printed as Windower prints them: 567 parsed, 284 in ignored families, 0 other;
  1413/1413 LSB effect texts read back to the builder's keys.
- `augments_check_bgwiki.js`: 3881 checks, 96.8% exact (BG Wiki per-rank tables
  3215/3318, max-rank summaries 260/265, OmniWatch ultimate/Dynamis-D lists
  239/254, JSE necks 44/44), 349 of 369 items covered. Remaining differences are
  wiki typos (single rows), wiki shorthand (`Phalanx` for `"Phalanx" received`,
  `Pet:` for `Avatar:`), and OmniWatch giving path C a DMG line that BG Wiki
  gives to paths A & B only.
- `augments_check_gearpy.py` (local tool, kept on this PC: it reads wsdist's `gear.py`): 452 wsdist ranked variants, 81.9% exact. Most
  of the rest are gear.py's own: R0 variants already holding the augment
  (Gleti's Breeches/Ikenga's Gloves/Sakpata's Leggings Subtle Blow, Agwu's
  Slops/Ikenga's Trousers DT), Duty Pet: Ranged Accuracy, Indomitable missing
  Magic Accuracy +30, Revelation Brais +30 on Attack, Nirvana's Avatar accuracy
  given to the player.
- `capes_check.js` (local tool, after `capes_gearpy_dump.py`): the 460 Ambuscade capes wsdist
  generates are rebuilt exactly.

## Uncertain

- Nyame Sollerets C Magic burst damage II: LSB 5 at R30, BG Wiki rank table
  and wsdist 6 (BG Wiki summary 5).
- Sharanga path C ammo damage: LSB +300% at R25, BG Wiki +250%.
- Neo Animator / Duty: whether pet accuracy also covers Ranged Accuracy.
- Max ranks: JSE necks +1 20 / +2 25, Dynamis-D NQ/HQ1/HQ2 15/20/25 (BG Wiki
  RankMax agrees for every page that has one).

## Sources (cached in `cache/`)

`lsb_augments.lua` (+ `lsb_bundles.json`), `lsb_enum_augment.lua`,
`omni_*.lua` (BalladOfWorms/OmniWatch gearinfo/res), `bgwiki/*.json`
(`augments_bgwiki.py`, `augments_fetch_bgwiki.py`), `extdata_augments.json`
(Windower `libs/extdata.lua`); for the local checks only, `gearpy_ranked.json`,
`gearpy_capes.json`, `gearpy_cape_base.json` (wsdist `gear.py`).

@author ejouanchicot

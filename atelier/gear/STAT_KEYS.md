# Catalogue stat vocabulary

The base catalogue (`build_catalog.py` -> `items.json` / `items.js`) keys every stat with
the spelling the engine before (a port of wsdist's `gear.py` / `create_player.py`) reads, so
both engines read the same entries: names only, listed in `augments_build.py` STAT_KEYS (2026-10-22),
no longer read from gear.py. Keys that engine does not read are kept under names of
their own ("extra keys" below). The augment parser should map augment text to these same
keys; the alias table lives in `build_catalog.py` (`ALIAS`, built by `alias(key, *phrases)`).

## How a phrase is matched

- Text is normalised by `norm()`: lower case, quotes removed, `". "` collapsed to `"."`,
  spaces collapsed. `"Magic Atk. Bonus"+30` -> phrase `magic atk.bonus`, value `+30`.
- A value is `[+-]N` with an optional `%` (`VALUE` regex). The phrase before it is matched
  whole against the alias table. A phrase whose *tail* is a stat but that has text before
  it (`"Step" accuracy +35`, `Annuls damage taken +5%`, `"Perfect Counter" attack +30`)
  is a qualified stat, not the plain one: it goes to `extra` under its full name.
- Several stats for one value: `DEX & AGI +15`, `INT/MND +25`, `All Attributes +2`.
- Rewritten before matching: `Haste10%` -> `Haste+10%`, `STR:10` -> `STR+10`,
  `Converts 150 MP to HP` -> HP +150 / MP -150, `Spell interruption rate down 10%` ->
  SIRD -10, element glyphs U+E000..U+E007 -> `<element> resistance`,
  Unity `+15～25` -> the best value (25).

## Units

- Whole percents, as gear.py: `"DT": -9` is -9 %, `"Gear Haste": 3` is 3 % (create_player
  divides Gear Haste by 102.4 itself), `"PDL": 9`, `"Weapon Skill Damage": 10`.
- `"TP Bonus"` in TP (`500`), `"Regain"` in TP per tick, skills in points.
- A % of a stat counted in points is its own key in percent: `HP%`, `MP%`, `Enmity%`...
  Except `Attack%` / `Ranged Attack%`, written as wsdist's fractions (`0.10` for +10 %).
- `"-Gear Haste"` in the table means the phrase lowers the stat (`"Slow"+5%` -> Gear Haste -5).

## wsdist keys

| Key | Description pattern(s) (normalised) |
|---|---|
| STR DEX VIT AGI INT MND CHR | `str` ... `chr`; `all attributes` / `all attr.` gives all seven |
| Accuracy | `accuracy`, `acc.`, `acc` |
| Attack | `attack`, `atk.`, `atk` |
| Ranged Accuracy | `ranged accuracy`, `rng.acc.`, `ranged acc.`, `r.acc.` |
| Ranged Attack | `ranged attack`, `rng.atk.`, `ranged atk.`, `r.atk.` |
| Evasion | `evasion`, `eva.` |
| Magic Evasion | `magic evasion`, `mag.eva.`, `magic eva.` |
| Magic Defense | `magic def.bonus` (game "Magic Def. Bonus"), `m.def.b.`, `mag.def.bns.`, `magic defense` |
| Magic Accuracy | `magic accuracy`, `mag.acc.`, `magic acc.`, `m.acc.` |
| Magic Attack | `magic atk.bonus` (game "Magic Atk. Bonus"), `mag.atk.bns.`, `m.atk.b.`, `magic atk.` |
| Magic Damage | `magic damage`, `mag.dmg.` |
| DT / PDT / MDT | `damage taken` / `physical damage taken`, `phys.dmg.taken` / `magic damage taken`, `mag.dmg.taken` |
| PDT2 / MDT2 | the same followed by ` ii` |
| Gear Haste | `haste`; `slow` counts negative |
| DA / TA / QA | `double attack`, `dbl.atk.` / `triple attack`, `trip.atk.` / `quadruple attack`, `quad attack` |
| DA Damage% / TA Damage% | `"Double Attack" damage +N` / `"Triple Attack" damage +N` |
| Store TP | `store tp` |
| Crit Rate / Crit Damage | `critical hit rate`, `crit.hit rate` / `critical hit damage`, `crit.hit damage` |
| Weapon Skill Damage | `weapon skill damage` |
| Weapon Skill Accuracy | `weapon skill accuracy` |
| TP Bonus | `tp bonus` |
| Dual Wield | `dual wield` |
| Subtle Blow / Subtle Blow II | `subtle blow` / `subtle blow ii` |
| Skillchain Bonus | `skillchain bonus` |
| PDL | `physical damage limit` |
| Regain | `regain` |
| Magic Burst Damage / II | `magic burst damage` / `magic burst damage ii` |
| Magic Burst Accuracy | `magic burst accuracy` |
| Magic Crit Rate II | `magic crit. hit rate ii`, `magic critical hit rate ii` |
| Martial Arts | `martial arts` |
| Kick Attacks | `kick attacks` |
| Kick Attacks DMG | `kick attacks damage`, and `"Kicks" Attack+N` (Anchorite's Gaiters: gear.py files it here) |
| Zanshin, Daken, Recycle, True Shot, Double Shot, Triple Shot, Barrage, Conserve TP, Fencer, Occult Acumen | their name |
| Double Shot Damage% / Triple Shot Damage% | `"Double Shot" damage +N` / `"Triple Shot" damage +N` |
| Barrage Ranged Accuracy | `"Barrage" accuracy +N` |
| Ranged Crit Damage | `"Dead Aim"+N` |
| Blood Pact Damage | `blood pact damage` |
| EnSpell Damage | `enspell damage`, `sword enhancement spell damage` |
| Ninjutsu Magic Attack | `ninjutsu damage +N`, `elemental ninjutsu damage +N%` (gear.py's reading) |
| Quick Draw Damage + Quick Draw Magic Accuracy | `"Quick Draw"+N` raises both (gear.py's reading) |
| Sneak Attack Bonus / Trick Attack Bonus | `"Sneak Attack"+N` / `"Trick Attack"+N`, `"Trick Attack" damage +N` |
| Futae Bonus / Klimaform Damage% / Ebullience Bonus | `"Futae"+N` / `"Klimaform"+N` / `"Ebullience"+N` |
| Hasso+ JA Haste | `"Hasso"+N` and the condition line `"Hasso": Haste+N%` |
| Climactic Crit Damage | condition `Climactic Flourish: ... Critical hit damage +N%` |
| Striking Crit Rate | condition `Striking Flourish: ... Critical hit rate+N%` |
| Innin DA% | condition `Innin: "Double Attack"+N%` |
| `<Element> Elemental Bonus` (Fire, Ice, Wind, Earth, Thunder, Water, Light, Dark) | `<element> elemental "Magic Atk. Bonus"+N`, `<element> elemental damage +N` ("Lightning" -> Thunder) |
| `<Weapon> Skill` | `hand-to-hand skill` ... `throwing skill`; `combat skills +N` gives all fifteen |
| Magic Accuracy Skill, Elemental Magic Skill, Dark Magic Skill, Ninjutsu Skill | `<name> skill` |
| Automaton Skill | `Automaton: ... Skill +N` |
| Pet:`<key>` | any line after `Pet:` / `Avatar:` / `Automaton:` / `Wyvern:` / `Luopan:`; the catalogue stores them without the prefix in `pet{}` |

Weapon fields: `"Skill Type"` (Hand-to-Hand, Dagger, ..., Marksmanship, Throwing, Shield,
String/Wind Instrument, Handbell, Fishing, or `"None"` for a grip/ammo), `"DMG"`, `"Delay"`
(items.lua; for Hand-to-Hand the text's own `DMG:+N Delay:+N`, which is what wsdist stores),
`"Type"`: Weapon, Shield, Grip, Bow, Gun, Crossbow, Instrument, Throwing, Animator, Fishing
Rod (ranged), Bullet, Arrow, Bolt, Shuriken, Throwing, Bait, Equipment (ammo), and the slot
for armor (Head, Neck, Earring, Body, Hands, Ring, Back, Waist, Legs, Feet).

### wsdist keys the text never gives

`OA2`..`OA8` (multi-attack rates: "Occasionally attacks 2 to 8 times"), `ftp` (Fotia),
`Elemental Bonus` (Orpheus's Sash, distance based), `<Element> Affinity`, `Weather`, `WSC`,
`Rank`, `Zanshin OA2`, `Pet:Level`, `Pet:Damage Dealt%`, `Barrage Ranged Attack`,
`Ninjutsu Magic Accuracy`, `Ninjutsu Damage%`, `Quick Draw Damage%`, `Elemental WS Damage%`,
`Magic Crit Rate II` on most items, `JA Haste`. Values the game hides behind "Enhances X
effect" come from `HIDDEN` (build_catalog.py, a dozen items) and `hidden_values.json`
(BG Wiki notes, ~290 items: hidden_fetch.py -> cache_bgwiki/, hidden_parse.py, hidden_review.py,
which also holds the hand-read values and, since 2026-10-22, the ones read on another BG Wiki page
than the item's: ELSEWHERE; none comes from gear.py any more).
A value the text gives always wins; the phrase stays in `text_only` either way.

## Extra keys (not read by wsdist)

`HP`, `MP`, `DEF`, `Fast Cast`, `Quick Magic`, `Enmity`, `Cure Potency`, `Cure Potency II`,
`Cure Potency Received`, `Cure Spellcasting Time`, `Conserve MP`, `SIRD` (negative = less
interruption), `Enhancing Magic Duration`, `Phalanx`, `Refresh`, `Regen`, `Regen Potency`,
`Movement Speed`, `Treasure Hunter`, `Block Rate`, `Shield Defense Bonus`, `Enemy Crit Rate`,
`BDT`, `Counter`, `Song Duration`, `All Songs`, `Snapshot`, `Rapid Shot`, `Magic Crit Rate`,
`Rapture Bonus`, `Magic Skills`, `Waltz Potency`, `<Element> Resistance`,
`<Element> Elemental Magic Accuracy`, the non-combat skills (`Parrying Skill`, `Guarding Skill`,
`Evasion Skill`, `Shield Skill`, `Enhancing/Enfeebling/Healing/Divine/Summoning/Blue Magic
Skill`, `Singing Skill`, `String/Wind Instrument Skill`, `Geomancy Skill`, `Handbell Skill`,
`Automaton Melee/Ranged/Magic Skill`). Note: wsdist's `Evasion Skill` is read by
create_player (it is an extra only in that gear.py never sets it).

Anything else with a value goes to `extra` keyed by its normalised phrase
(`"mp recovered while healing": 5`, `"step accuracy": 35`, `"waltz potency%"`...).

## Entry layout (items.json)

```
id, name (en), enl, slots [main sub ranged ammo head neck ear1 ear2 body hands ring1 ring2 back waist legs feet],
jobs [war mnk ...], level, ilvl, su (superior level, when set), Type, Skill Type, DMG, Delay,
stats {key: number}          always-on stats of the base item
pet {key: number}            Pet:/Avatar:/Automaton:/Wyvern:/Luopan: lines (wsdist "Pet:<key>")
pet_extra {phrase: number}   pet phrases outside the vocabulary
slot_stats {slot: {..}}      "Right ear:" (ear2), "Left ear:" (ear1), "Main hand:" (main)...
cond [text]                  conditions kept as text: Set:, Latent effect:, Unity Ranking:,
                             Aftermath:, Enchantment:, Additional effect:, Occ. procs, days/weather
cond_stats [{when, stats, extra?}]  what each condition would add (Unity: rank-1 value)
extra {phrase: number}       valued stats outside the vocabulary
text_only [text]             effects named without a value ("Enhances "Dual Wield" effect")
hidden [key]                 keys filled from HIDDEN / hidden_values.json (BG Wiki), not from the text
hidden_source                the BG Wiki page those values come from
unparsed [text]              leftover text (WS names, "Cannot Equip Headgear", ...)
no_text                      true when res/item_descriptions.lua has no text for the id
```

# atelier/calc, stage 1: differences with the reference results

The reference battery is `scripts/audit/engine_ref/*.json` (19 files, 756 cases, master level 20).
`node scripts/audit/calc_check.js` compares `CALC.characterStats(input)` with the `stats` of every
case. 147 of the 169 stat names match in every case. The 22 others are listed here: for each one
the engine keeps what BG-Wiki says, and nothing was tuned to make a number fit.

Case ids are `<file>#<index in cases>`; "all" means every case of that job.

## A. BG-Wiki and the reference disagree on a value or a formula

| # | Stat | Cases | Reference | Engine (BG-Wiki) | Page |
|---|------|-------|-----------|------------------|------|
| A1 | Evasion | all 756 | skill part = `0.8 x skill + 60`, not rounded (336 -> 328.8, 370 -> 356, 409 -> 387.2, 440 -> 412, 460 -> 428) | `floor((skill - 200) x 0.9) + 200` for skill >= 201 (336 -> 322, 370 -> 353, 409 -> 388, 440 -> 416, 460 -> 434). The page has no tier above 200 with a 0.8 ratio (asked twice). The AGI part, `floor(AGI / 2)`, is the same on both sides. | https://www.bg-wiki.com/ffxi/Evasion |
| A2 | PDL Trait (Damage Limit+) | 534 of 582 (every tier but V) | 10 / 20 / 30 / 40 / 50 by tier | 26/256, 51/256, 77/256, 102/256, 128/256 of pDIF cap = 10.15625 / 19.921875 / 30.078125 / 39.84375 / 50 in percent. Only tier V (DRK, 48 cases) is the same number. | https://www.bg-wiki.com/ffxi/Damage_Limit%2B |
| A3 | Scythe Skill | Tetsouo_BST, all 36 | 404 = rank C- (368) + 20 + 16 | 424 = rank B- (388) + 20 + 16. The Beastmaster page gives Scythe B-, cap 388 at 99 (asked twice). | https://www.bg-wiki.com/ffxi/Beastmaster |
| A4 | Magic Attack | Tetsouo_BLM, all 18 | job part 100 | job part 90 = Magic Attack Bonus VI (40) + gifts 7+11+14+18 (50). Black Mage has no job point category for magic attack. 10 unexplained. | https://www.bg-wiki.com/ffxi/Black_Mage, https://www.bg-wiki.com/ffxi/Magic_Attack_Bonus |
| A5 | Magic Accuracy | Tetsouo_BLM, all 18 | job part 57 | job part 62 = gifts 6+9+12+15 (42) + job point category "Magic Accuracy Bonus" 20 x 1 | https://www.bg-wiki.com/ffxi/Black_Mage |
| A6 | Magic Accuracy | Kaories_GEO 24 + Tetsouo_GEO 18 | job part 50 (gifts only) | 70 = gifts 7+11+14+18 (50) + job point category "Magic Accuracy Bonus" 20 x 1. The reference does count the same category for WHM, and "Magic Atk. Bonus" for GEO. | https://www.bg-wiki.com/ffxi/Geomancer |
| A7 | Magic Accuracy | Kaories_RDM 48 + Tetsouo_RDM 48 | job part 130 | 115 = gifts 10+15+20+25 (70) + category 20 + merit "Magic Accuracy" 5 x 5 (25). The 15 more of the reference equal one "Fire/Ice/... Magic Accuracy" merit (+3 x 5), which only serves spells of that element: not added. | https://www.bg-wiki.com/ffxi/Red_Mage |
| A8 | Magic Accuracy | Tetsouo_SAM, all 48 | job part 0 | 36 = gifts 5+8+10+13 (rows at 60, 360, 910, 1710 job points) | https://www.bg-wiki.com/ffxi/Samurai |
| A9 | Magic Evasion | Tetsouo_WHM, all 30 | job part 0 | 50 = gifts 7+11+14+18 (rows at 20, 245, 720, 1445 job points) | https://www.bg-wiki.com/ffxi/White_Mage |
| A10 | Recycle | Kaories_COR 48 + Tetsouo_COR 42 | 30 (trait III) + gear | 38 = trait III (30) + gifts "Reduced Ammunition Consumption" 2+2+2+2, i.e. tier VII of the Recycle page | https://www.bg-wiki.com/ffxi/Recycle, https://www.bg-wiki.com/ffxi/Corsair |
| A11 | Snapshot | COR, 42 of 54 cases that have the stat | gear only | gear + gifts "Snapshot Effect" 5 + 5 (rows at 100 and 1200 job points) | https://www.bg-wiki.com/ffxi/Corsair |
| A12 | Fast Cast | Kaories_RDM + Tetsouo_RDM, 96 cases | gear only | gear + Fast Cast V (30) + gifts 2+2+2+2 = 38, i.e. tier IX of the Fast Cast page | https://www.bg-wiki.com/ffxi/Fast_Cast, https://www.bg-wiki.com/ffxi/Red_Mage |
| A13 | Magic Accuracy | Tetsouo_BST, all 36 | job part 36 (gifts) | 86 = gifts 36 + Tandem Strike V (50): the page says "Accuracy and Magic Accuracy". The reference adds the 50 to Accuracy only (that part matches). | https://www.bg-wiki.com/ffxi/Tandem_Strike |

## B. The reference files a number under another name, or leaves it out

| # | Stat | Cases | Reference | Engine |
|---|------|-------|-----------|--------|
| B1 | Dark Magic Skill, Dark Skill | Kaories_GEO 24 + Tetsouo_GEO 18 | "Dark Skill" 393 (rank C 373 + 20) and "Dark Magic Skill" 52 (merits 16 + gifts 36): one skill split under two names | "Dark Magic Skill" 445 = 373 + 20 + 16 + 36, no "Dark Skill" (https://www.bg-wiki.com/ffxi/Geomancer) |
| B2 | Divine Magic Skill | Tetsouo_BLM, all 18 | 420 = rank B+ (404) + 16 on BLM/SCH, as if Light Arts were on, without the master levels | 16: Black Mage has no Divine rank, the support job gives no skill, and `abilities` is empty |
| B3 | Parrying Skill, Shield Skill, Enhancing / Enfeebling Magic Skill, Singing / String / Wind Instrument Skill, Geomancy Skill | every case that has the stat | the gear only: the skill of the job itself is not there | rank cap + master levels + merits + gifts + gear, like the other skills. Example PLD/DRK Parrying: 269 against 678 (C 373 + 20 + 16 + 269). |
| B4 | Triple Shot | COR, 66 of 90 | always 0, even with Camulus's Mantle "Triple Shot +5" | the gear total (5). Nothing on the sheet says the ability is up; whether to count it belongs to the stage that plays the ability. |
| B5 | Ranged Accuracy | COR, 30 cases with Bronze Bullet and no gun | gear + job total (349...), while "Ranged Attack" is 0 in the same cases | 0 for both: a bullet without a gun cannot be fired. This is a reading rule of ours (calc_stats.js, `applyWielding`), not a game formula; with a ranged weapon both totals are kept. |

## C. One value implemented from the reference results, not documented

| # | What | Why |
|---|------|-----|
| C1 | `OBSERVED_AT_SUB_53` in calc_attributes.js: STR/DEX/VIT/AGI/INT/MND/CHR of "race + main job at 99 + support job at 53" for the 17 job pairs of the battery | BG-Wiki has no formula and no level 99 table for the attributes of a race and a job (the race pages and Category:Base_Stats only give level 1). The table is the reference total minus gear, minus 20 master levels, minus 15 merit points. It is labelled in the code. Outside those 17 pairs, or outside master level 20 to 24, `CALC.baseAttributes` returns null and the attributes start at 0. |

## D. Assumptions (documented values, but the situation is assumed)

| # | Assumption | Effect | Page |
|---|------------|--------|------|
| D1 | Every merit category shared by all jobs is bought: attributes +15 each, every combat and magic skill +16, critical hit rate +5 | Skills the job has no rank in show 16, as in the reference | https://www.bg-wiki.com/ffxi/Merit_Points |
| D2 | Job merits (5 levels an item, 10 a group): WAR Double Attack Rate; THF Triple Attack Rate and Ambush; SAM Store TP Effect and Zanshin Attack Rate; RDM Magic Accuracy and En-spell Damage | DA +5, TA +5, Accuracy +15, Store TP +10, Zanshin +5, Magic Accuracy +25, EnSpell Damage +15 | job pages |
| D3 | `CALC.ASSUME.behindTarget`: the Thief attacks from behind (Ambush, +3 accuracy a level) | THF Accuracy +15 | https://www.bg-wiki.com/ffxi/Thief |
| D4 | `CALC.ASSUME.petOnTarget`: the Beastmaster and its pet attack the same enemy (Tandem Strike V) | BST Accuracy +50, Magic Accuracy +50 | https://www.bg-wiki.com/ffxi/Tandem_Strike |
| D5 | Job points: 2100 spent (every gift), 20 points in each category used | see calc_jobs_*.js | job pages |
| D6 | Master level bonuses on skills only where the job has a rank | "for all weapons that a job has ranking in" | https://www.bg-wiki.com/ffxi/Combat_Skills |
| D7 | "Delay2" repeats "Delay1" without an off-hand weapon; "Attack2", "Accuracy2", "DMG2", "Dual Wield" are 0 | reading rule of ours, same as the reference | - |

## E. Uncertain readings of BG-Wiki (to check by eye on the page)

| # | What | Detail |
|---|------|--------|
| E1 | Dark Knight gifts "Magic Evasion Bonus" | Three reads of the gift table gave three answers (6+9+6+15 = 36; then garbled; then 6+9+15+?). 36 is used, which is also the reference number. The usual pattern on other jobs would be 6+9+12+15 = 42. https://www.bg-wiki.com/ffxi/Dark_Knight |
| E2 | Dancer Subtle Blow | The Dancer page gives gifts 3+3+3+4 (trait IV 20 + 13 = 33, used, same as the reference); the Subtle Blow page gives tier VIII = 32 for DNC at 1805 job points. https://www.bg-wiki.com/ffxi/Dancer, https://www.bg-wiki.com/ffxi/Subtle_Blow |
| E3 | Rounding of percentage attack bonuses | The Attack page gives no rounding for Smite, Chaos Roll, Fury: `Attack1` is left unrounded (2132.0625...), which is also what the reference does. https://www.bg-wiki.com/ffxi/Attack |

## F. Not covered by the battery (written from BG-Wiki, never compared)

- Hand-to-hand: delay `480 + weapon - Martial Arts`, STR ratio 0.75 (no rounding documented). No case wields hand-to-hand.
- Ranged weapons: no case has one, so the ranged totals are never non-zero in the engine's output, and the finished ranged accuracy / ranged attack (`floor(AGI x 0.75)` + skill..., `8 + skill + STR`) are not written yet.
- `abilities` is empty in every case: no job ability is read.
- Job pairs outside the 17 of the battery; master levels other than 20.

---

# atelier/calc, stage 2: differences with the reference results (physical melee weapon skills)

`node scripts/audit/calc_ws_check.js` recomputes every "<weapon skill>@<TP>" result of the battery
with `CALC.weaponskillAverage`, fed with the case's own `stats` (the differences of stage 1 stay
out). 2268 results: 1636 are physical melee weapon skills the engine computes (88 weapon skills),
8 are Disaster above 2000 TP (no fTP on BG-Wiki), 624 are magical, hybrid or untyped (stage 3).

The third number of each reference result, `n`, is 1 in all 2268: it is not a hit count (the same
1 for seven-hit Realmrazer and one-hit Circle Blade); it reads as the number of weapon skills the
average is given for.

| Mode | Damage: exact / <= 0.1% / <= 1% / <= 5% / more | TP return: exact / <= 0.1% / <= 1% / <= 5% / more |
|------|-----------------------------------------------|---------------------------------------------------|
| engine as delivered (BG-Wiki, then the game: section P) | 123 / 128 / 370 / 203 / 812 | 200 / 300 / 525 / 407 / 204 |
| the same before the measurements of 2026-10-09 were applied | 178 / 213 / 566 / 97 / 582 | 102 / 40 / 212 / 582 / 700 |
| `--as-reference` (section G applied by the checker) | 1217 / 5 / 24 / 23 / 367 | 1379 / 27 / 77 / 37 / 116 |

`atelier/calc/` holds only what BG-Wiki documents or the game showed (section P): no switch, no
constant and no function there comes from the reference. The reference is no longer the target
where the game contradicts it: the first row moved away from it for damage (the spike at pDIF 1,
which it does not have) and towards it for TP (Store TP on the later swings). The `--as-reference` mode lives entirely in the checker
(`actAsReference`, which replaces engine functions in the checker's own process); it exists to
show what the gap is made of. In that mode 42 weapon skills are exact (1e-9) for damage and TP
return in every case: Armor Break, Blitz, Calamity, Catastrophe, Chant du Cygne, Circle Blade,
Cross Reaper, Death Blossom, Dimidiation, Entropy, Fell Cleave, Fimbulvetr, Full Break, Gate of
Tartarus, Guillotine, Insurgency, King's Justice, Knights of Round, Metatron Torment, Mistral Axe,
Mystic Boon, Nightmare Scythe, Raging Rush, Rampage, Resolution, Savage Blade, Shattersoul, Shell
Crusher, Shield Break, Shockwave, Spinning Scythe, Spiral Hell, Steel Cyclone, Tachi: Ageha,
Tachi: Fudo, Tachi: Gekko, Tachi: Kaiten, Tachi: Kasha, Tachi: Mumei, Tachi: Yukikaze, Upheaval,
Weapon Break. With the weapon skill data of section H tried on top (in a scratch script, never
written anywhere in the project), 1475 damage results and 1447 TP returns of 1644 are exact and
59 weapon skills are exact in every case.

## G. BG-Wiki states a rule, the reference does something else

One line per engine function the checker replaces for `--as-reference`. "Results moved" = how many
of the 1636 results change when that one function alone goes back to BG-Wiki's, and the widest
move. These may be errors of the old engine.

| # | Function | BG-Wiki (engine) | Reference (worked out from its results) | Results moved | Page |
|---|----------|------------------|------------------------------------------|---------------|------|
| G1 | `hitRate` | 75 + floor((accuracy - evasion) / 2) | no floor: an odd difference gives x.5% (Kaories_PLD#41 Circle Blade: 56.5% against 56%) | 467 damage and TP, up to 1.8% | https://www.bg-wiki.com/ffxi/Hit_Rate |
| G2 | `weaponRank` | fSTR caps from floor(damage / 9) | damage / 9 unrounded (Colada, damage 140: lower cap -15.56 against -15) | 356 damage, up to 0.42% | https://www.bg-wiki.com/ffxi/Weapon_Rank |
| G3 | `wsAttributeBonus` | WSC = floor(A x A% + B x B%) | no floor | 939 damage, up to 0.32% | https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage |
| G4 | `wsBaseDamage` | base floored, then each Weapon Skill Damage step floored ("Flooring Between Steps"; the page does not say it of the gear step, the engine floors it too) | one floor after every multiplier: floor((D + fSTR + WSC) x fTP x (1 + gear) x (1 + trait) x weapon) | 560 damage, up to 0.29% | https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage |
| G5 | `wsMeanPdif`, critical hits | each hit is critical or not: "If you critical hit: wRatio = (cRatio + 1)", the limits from that wRatio (their conditions are written on wRatio), a value "between LL and UL", then "If the value is greater than the cap [...] set to the cap value" (3.25 / 4.25...). The mean is (1 - rate) x non critical + rate x critical | one "average hit": the ratio is cut at the cap, the critical hit RATE is added to it, the mean is the middle of the limits of that ratio, cut at the cap, plus the rate again. Above the cap both give cap + rate. Below it the reference is higher: ratio 0.94 and 25% critical hits (Kaories_PLD#14, Chant du Cygne) give 1.49 against 1.21 | 143 damage, up to 34% (uncapped cases of Chant du Cygne, Evisceration, Ukko's Fury, Raging Rush, Rampage, Hexa Strike, True Strike) | https://www.bg-wiki.com/ffxi/PDIF |
| G6 | `WS_MAX_SWINGS` | multi-attack swings "Subject to the 8-hits per round limit" | no limit that a single number reproduces: none up to 7 swings + 2, and Evisceration with Quadruple Attack sits between a limit of 8 and of 9 (Tetsouo_BRD#9, 0.2%) | 219 damage and TP, up to 2% | https://www.bg-wiki.com/ffxi/Double_Attack |
| G7 | `wsExtraSwingTP` | the page: "a flat 10 TP" for every swing after the first of a hand; the game (P2): floor(10 x (1 + Store TP / 100)), which is what the engine does | 10 x (1 + Store TP / 100), not floored (14.8 with Store TP 48, 14 in the game) | 1465 TP, up to 26% before P2; the floor alone since | https://www.bg-wiki.com/ffxi/Tactical_Points |
| G8 | `conserveTPAverage` | Conserve TP keeps "a random whole amount of TP between 10 and 200": 105 on average | 95 on average (Tetsouo_DNC#37: 19.95 TP for Conserve TP 21) | 297 TP, up to 5.3% | https://www.bg-wiki.com/ffxi/Conserve_TP |
| G9 | `wsSwingKinds` | +100 accuracy on "The first swing", "additional swings receive no bonus" | the first off-hand swing gets the +100 too (Kaories_COR#23: off-hand 95% against 54%) | 105 damage and TP, up to 37% (dual wield only) | https://www.bg-wiki.com/ffxi/Category:Weapon_Skills |
| G10 | `wsProcChances` | Occasionally Attacks X Times procs on weapon skills "only when provided by Mythic AM3" | "OA2 main" / "OA2 sub" 45 of Demers. Degen +1 and Blurred Knife +1 proc on the first swing of their hand, after Double Attack | 216 damage and TP, up to 29% (COR and DNC cases) | https://www.bg-wiki.com/ffxi/Multi-Attack |
| G11 | status effects for Naegling (argument `wield.buffs`) | attack +1% per status effect; the sheet does not list them, the checker gives 0 | 13 status effects in every case, with or without party buffs, on both hands | 83 damage, up to 12.5% (Kaories_COR and Tetsouo_COR below the pDIF cap) | https://www.bg-wiki.com/ffxi/Naegling |
| G12 | `wsMeanPdif`, "Crit Damage" | "Critical Hit Damage = (Base Damage + fSTR) x Critical pDIF x (Sum of Direct Modifiers)": the critical hits are multiplied by 1 + bonus | the whole mean, non critical hits included, is multiplied by 1 + critical hit rate x bonus. The engine is higher by bonus x rate x (1 - rate) pDIF (Tetsouo_WAR#33 Raging Rush: 0.7% at 1000 TP) | counted in G5 (the cases of WAR and THF, whose sheets have "Crit Damage") | https://www.bg-wiki.com/ffxi/Critical_Hit_Rate |

## H. Weapon skill data: BG-Wiki page against the reference

The engine uses the page (read a second time on 2026-10-09 for H13 to H27, line by line).
"Reference" is the value that reproduces its numbers to 1e-9 when tried in a scratch script; it is
written nowhere in the project. "Gap" is engine against reference in `--as-reference` mode, so
that section G is out of it.

| # | Weapon skill | BG-Wiki (engine) | Reference | Gap | Cases |
|---|--------------|------------------|-----------|-----|-------|
| H1 | Fast Blade | fTP 1.0 / 3.0 / 5.0 | 1.0 / 1.5 / 2.0 | up to x2.3 at 3000 TP | all 31 cases at 2000 and 3000 TP |
| H2 | Onslaught | fTP "4.275~4.37" (4.275 used) | 2.75 | x1.5 | Tetsouo_BST#6, #18, #30 |
| H3 | Full Swing | fTP 1 / 3 / 9 | 1 / 3 / 5 | x1.8 at 3000 TP | Tetsouo_BLM#2, Tetsouo_SMN#2 |
| H4 | Heavy Swing | fTP 1 / 2 / 3 | 1 / 1.25 / 2.25 | x1.59, x1.33 | Tetsouo_BLM#4, Tetsouo_SMN#5 |
| H5 | Retribution | fTP 2 / 3 / 5 | 2 / 2.5 / 3 | x1.19, x1.65 | Tetsouo_BLM#6, Tetsouo_SMN#7 |
| H6 | Oshala | fTP 3.95 / 7.89 / 11.84 | 1010/256, 2020/256, 3030/256 (3.9453, 7.8906, 11.8359): the page rounds | 0.16% | Tetsouo_BLM#5, Tetsouo_SMN#6 |
| H7 | Origin | fTP 3 / 6 / 9 | 3 / 6.25 / 9.5 | 4%, 5% | Tetsouo_DRK#8, #22, #36 |
| H8 | Slice | fTP 1 / 2.5 / 4.125 (all "Verification Needed") | 1.5 / 1.75 / 2.0 | x0.69, x1.4, x2.0 | Tetsouo_DRK#11, #25, #39 |
| H9 | Ground Strike | fTP 1.5 / 3 / 5 | 1.5 / 1.75 / 3.0 | x1.7 | Tetsouo_RUN#3, #13, #23, #33, #43 |
| H10 | Spinning Slash | fTP 2.5 / 5 / 7.5 | 2.5 / 3 / 3.5 | x1.67, x2.1 | Tetsouo_RUN#9, #19, #29, #39 |
| H11 | Quietus | defense ignored 12.5% / 37.5% / 62.5% (all "Verification Needed") | 10% / 30% / 50% | 3% to 33%, uncapped only | Tetsouo_DRK#37 |
| H12 | Viper Bite | hits not on the page (1 in our database) | 2 hits | x0.5; TP return too | all 10 cases |
| H13 | Ukko's Fury | critical hit rate "+20%" / "+35%" / "+65%", fTP 2.0, "twofold attack" | +20 / +35 / +55 | 0.8% to 10%, growing with TP | Tetsouo_WAR#10, #23, #36 |
| H14 | Raging Rush | critical hit rate "+15%" / "+30%" / "+50%" (the last two "Verification Needed"), fTP 1.0, three hits | same values: exact once G5 and G12 are applied | none | - |
| H15 | Evisceration | critical hit rate "+10%" / "+25%" / "+50%" (the last two "Verification Needed"), fTP 1.25 replicating, five hits | same values; 12 results of 33 left within 0.2%, the cases with Quadruple Attack (G6) | 0.2% | Tetsouo_BRD#9, #33, #41, Tetsouo_THF#12 |
| H16 | Exenterator | fTP "1.1875", replicating, "fourfold attack" | fTP 1.0 | x1.19 (x1.16 with the Fotia fTP) | all 11 cases |
| H17 | Tachi: Shoha | fTP 1.375 / 3.25 / 4.625; Attack Modifier "1.35~1.45 (1.375)" taken as attack x 1.375 | fTP 1.375 / 2.1875 / 2.6875; attack x 2.375 (the 1.375 read as +137.5%) | x0.64 to x1.56 | Tetsouo_SAM#12, #26, #40 |
| H18 | Tachi: Enpi | fTP 1.0 / 2.0 / 4.0, "two-fold attack" | 1.0 / 1.5 / 2.0 | x1.08 to x1.75 | Tetsouo_SAM#1, #15, #29, #43 |
| H19 | Raging Axe | fTP 1.0 / 3.0 / 6.0 (the last two "Verification Needed"), two hits | 1.0 / 1.5 / 2.0 | x1.5 to x2.6 | Tetsouo_BST#8, #20, #32 |
| H20 | Spinning Axe | "Single-hit attack", fTP 2.0 / 4.0 / 6.5 (the last two "Verification Needed") | 2 hits, fTP 2.0 / 2.5 / 3.0 | x0.99 to x1.8; TP return 7% to 10% under | Tetsouo_BST#11, #23, #35 |
| H21 | Sickle Moon | "two-hit attack", fTP 1.5 / 3.5 / 6.5 (all "Verification Needed") | 1 hit, fTP 1.5 / 2.0 / 2.75 | x1.4 to x2.7; TP return 3% to 9% over | Tetsouo_RUN#8, #18, #28, #38 |
| H22 | Hard Slash | "single-hit attack", fTP 1.5 / 2.5 / 3.5 (the last two "Verification Needed") | 2 swings (the TP return is exact with 2 hits); its fTP: not worked out | x0.66 to x1.7; TP return 2% to 7% under | Tetsouo_RUN#4, #14, #24, #34, #44 |
| H23 | Iron Tempest | attack "+0%" / "+100%" / "+250%" (the last two "Verification Needed") | about +0% / +17% / +42% (x1, x7/6, x17/12 fit to 0.02%) | x1.4 to x2.5, uncapped only | Tetsouo_WAR#30, #43 |
| H24 | Disaster | fTP "3.05" at 1000 TP, "9.15" at 2000 TP (both "Verification Needed"), nothing at 3000 TP, no hit count | fTP 3.05 / 6.10 / 9.15, 1 hit: the page's 9.15 sits one column too early | about x1.3 below 2000 TP; not computed above | Tetsouo_WAR#1, #14, #27, #40 |
| H25 | Mordant Rime | fTP 5.0, "twofold attack"; the TP row is the chance of the weight effect, with question marks | same damage values (exact when the hit rate is capped) plus accuracy +0 / +20 / +40 by TP on every swing | 4% to 30% damage and TP | Tetsouo_BRD#4, #20, #28, #44 |
| H26 | Bora Axe, Swift Blade (same +0 / +20 / +40 fit); Realmrazer, Dancing Edge, Tachi: Rana, Decimation, Ruinator (not fitted) | "Accuracy varies with TP" with question marks, or no accuracy line at all (Bora Axe): no accuracy bonus in the engine | an accuracy bonus by TP on every swing | up to 30% damage and TP | the cases whose hit rate is not capped |
| H27 | True Strike | accuracy "Large Penalty", no number: none in the engine; attack modifier 2.0, 100% critical | accuracy -60 / -30 / -0 by TP | up to 48% at 1000 TP, exact at 3000 TP | Tetsouo_WHM#10, #21 |
| H28 | Requiescat | attack "-20%" / "-10%" / "-0%" ("attack is penalized"), fTP 1.0 replicating, fivefold | same values (57 of 66 results exact). The 9 left are at 1000 TP with a ratio of 4.5 to 4.7 before the penalty: the engine applies 0.8 to the attack and lands under the cap (3.63 against a cap of 4.02 on Kaories_RDM#22), the reference still gives the cap. Which side of its cut at the cap the penalty sits on: not worked out | 0.2% to 9.6% | Kaories_COR#5, #16, Kaories_RDM#22, Tetsouo_COR#5, #16, #27, Tetsouo_RDM#22 |
| H29 | Dagda | "Information Needed" for modifiers and fTP on the page: our database's 3 / 6 / 9 and STR 50% MND 50% are used | 4.6 to 7.6 times lower, TP return exact: neither an fTP nor a modifier pair was found that fits | up to x7.6 | all 8 cases |
| H30 | Hexa Strike | critical hit rate +10% / nothing / ">= 25%": 17.5% taken at 2000 TP, on the straight line from 1000 to 3000 | 10 / 17.5 / 25: exact once G5 is applied | none | - |
| H31 | Fotia Gorget | "TP not depleted when weapon skill used +1%": not on the sheet, not computed | 0.1 TP more at 1000 TP, 0.2 at 2000, 0.3 at 3000 | 0.1 to 0.3 TP | Tetsouo_GEO#13, #16 (gorget in the set); the same 0.1 on Tetsouo_GEO#15, Tetsouo_BLM#12, Tetsouo_THF#34, #35, #44, #45 |

## I. Implemented from the reference results, not documented

In `atelier/calc/`: nothing.

In `scripts/audit/calc_ws_check.js`, for `--as-reference` only: `actAsReference` (ten engine
functions or constants replaced: G1 to G10, G12 being in the function of G5), `referenceMeanPdif`, and `REFERENCE_STATUS_EFFECTS = 13`
(G11). They can be deleted with the old engine.

## J. Assumptions and readings (documented values, the situation or the wording is ours)

| # | Assumption | Page |
|---|------------|------|
| J1 | Averages: the draw between the pDIF limits and the final 1.00-1.05 draw are taken as uniform (the page names no distribution); the mean is that of the unrounded product, the game's floors on integer damage are not averaged. | https://www.bg-wiki.com/ffxi/PDIF |
| J2 | Between 1000, 2000 and 3000 TP every value (fTP, critical hit rate, attack, defense ignored) follows the straight line between the two anchors; TP Bonus is added to the TP, 3000 at most. The pages give the anchors only ("extra Critical Hit Rate is awarded for TP over 1000"). | each weapon skill page, https://www.bg-wiki.com/ffxi/Critical_Hit_Rate |
| J3 | Merit weapon skills at 5/5 merits (85%). | their pages |
| J4 | The two swings that can proc a multi-attack are the first main hand swing and the off-hand swing; without an off-hand, the first two swings of a weapon skill of several hits. The page says "maximum of 2 times" and "each weapon when Dual Wielding", not which swings. | https://www.bg-wiki.com/ffxi/Double_Attack |
| J5 | The hits of a weapon skill after the first use fTP 1.0 unless the page says "fTP replicating"; a weapon skill without a hit count on its page and in our database is one hit. | https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage |
| J6 | The first swing's accuracy bonus is 100 (the page writes "~+100"). | https://www.bg-wiki.com/ffxi/Category:Weapon_Skills |
| J7 | Critical hit cap = (cap + trait) x (1 + gear) + 1: the page gives "3.25 for non-crits and 4.25 for crits" and says the gear multiplies "this limit", not whether the +1 is inside. | https://www.bg-wiki.com/ffxi/PDIF |
| J8 | A weapon skill's critical hit rate bonus is added to the character's own rate and to dDEX ("the sum of the base rate, gear, merit points, Buffs, Weapon Skill modifiers, and [dDEX]"), 100% at most ("no cap to critical hit rate"), on every swing of the weapon skill: the page does not say which hits can be critical. | https://www.bg-wiki.com/ffxi/Critical_Hit_Rate |
| J9 | Naegling's attack bonus is applied to both hands (the page gives it to the weapon skill, not to a hand). "Double Attack damage" and "Triple Attack damage" of the sheet are not applied to weapon skills (no page says they are). | https://www.bg-wiki.com/ffxi/Naegling |
| J10 | Level correction left out (the enemy of the input has no level). | https://www.bg-wiki.com/ffxi/PDIF, https://www.bg-wiki.com/ffxi/Hit_Rate |

## K. Not covered

- Magical, hybrid and ranged weapon skills (24 of the battery's 113, plus Aeolian Edge whose type our database lacks): `CALC.weaponskillAverage` returns `{unsupported: ...}`.
- Hand-to-hand: written (rank from damage + 3, 99% cap on both fists, half delay for TP), never compared: no case wields hand-to-hand.
- Job abilities and aftermaths (`abilities` is empty in every case): Sneak Attack, Climactic Flourish, Building Flourish, Mythic AM3 multi-attacks, the "Striking Crit Rate" of the sheet.
- Accuracy bonuses by TP and True Strike's penalty: BG-Wiki has no numbers (H25, H26, H27).

## L. What only a test in the game can settle

1. Critical hits below the pDIF cap (G5). Chant du Cygne or Evisceration on an enemy where the attack / defense ratio is about 1: compare the size of the critical hits with the normal ones. BG-Wiki puts them about 1 pDIF apart; the reference's average is worth more than 2.
2. "Crit Damage" (G12). Same weapon skill with and without a "Critical hit damage +%" piece: do the non critical hits change? BG-Wiki says no.
3. TP of the extra swings (G7). A multi-hit weapon skill (Resolution, Evisceration) with high and with zero Store TP, every swing landing: is the TP return above the first hit 10 a swing, or 10 x (1 + Store TP)?
4. Off-hand accuracy (G9). Dual wield, low accuracy against an evasive enemy: does the off-hand swing of a weapon skill land as often as the first swing, or as rarely as the others?
5. "Occasionally attacks twice" weapons (G10). Circle Blade with Demers. Degen +1 in a hand, no Double / Triple Attack gear: does the weapon skill ever show three swings?
6. Fast Blade, Full Swing, Heavy Swing, Retribution, Origin, Ground Strike, Spinning Slash, Tachi: Enpi, Raging Axe at 2000 and 3000 TP (H1 to H10, H18, H19): damage at 3000 TP against 1000 TP. The page and the reference differ by a factor of 1.5 to 2.6.
7. Hit counts: Viper Bite, Spinning Axe, Hard Slash (1 on the page, 2 in the reference), Sickle Moon (2 on the page, 1 in the reference): count the swings in the log.
8. Exenterator (H16): damage against Evisceration's per hit at the same attributes: fTP 1.1875 or 1.0.
9. Ukko's Fury at 3000 TP (H13): share of critical hits over a few hundred hits, +65% or +55%.
10. Tachi: Shoha (H17) and Iron Tempest (H23) on a high-defense enemy: how much the hit grows against a weapon skill without attack bonus (x1.375 or x2.375; +100% / +250% or +17% / +42%).
11. Accuracy by TP (H25, H26, H27): hit rate of Swift Blade, Bora Axe, Mordant Rime at 1000 and at 3000 TP against an enemy where hits miss; True Strike's at 1000 TP.
12. Disaster at 2000 and 3000 TP (H24), Dagda at any TP (H29): damage against a one-hit weapon skill of known fTP with the same weapon.

---

# Measured in game, 2026-10-09

Journal `Tetsouo/logs/fights/2026-10-09_hits.log`: WAR99/SAM56 on Locus Ghost Crab (level 137 to
139, six mobs), 2 208 auto-attack swings and 126 weapon skills, with Shining One, Ikenga's Axe,
Chango, Ukonvasara and Naegling. Swings under STR Down or under the enemy's Defense Boost are left
out. "w" is attack / defense fitted on the plain hits; intervals are 95 %. Each BG-Wiki quote was
read on the page that day. What was applied to the engine afterwards is in section P.

## M. Settled

| # | Point | Measured | Supports |
|---|-------|----------|----------|
| M1 | pDIF limits of a plain hit (`pdifLimits`) | A lower limit, an upper limit and a spike share fitted freely land on the page's limits at one w: Ikenga's Axe 0.85 / 1.42 (page at w 1.120: 0.849 / 1.420, 169 hits), Naegling 0.75 / 1.33 (w 1.036: 0.752 / 1.336, 113 hits), Shining One 1.00 / 1.66 (w 1.328: 1.000 / 1.660, 215 hits), Shining One under Berserk 1.43 / 2.20 (w 1.860: 1.399 / 2.235, 20 hits). Uniform between the limits (chi-square 7 to 16 on ten bins). | BG-Wiki as coded |
| M2 | Final 1.00-1.05 draw | The hits at pDIF 1 fill exactly [S, 1.05 S]: Naegling 207 to 217 (217: 4 hits, 218: none), Ikenga's Axe 272 to 285, Chango 446 to 468. | BG-Wiki as coded |
| M3 | Critical hits (G5, L1) | "wRatio = cRatio + 1", same limits, no spike: free limits 2.30..3.18 for Shining One (page at w + 1, times 1.18: 2.28..3.19, 168 critical hits), 2.02..2.92 for Ikenga's Axe (2.00..2.93, 122), 1.90..2.84 for Naegling (1.89..2.84, 49); also at w + 1 = 2.86 (Berserk) and 1.66 (enemy under Defense Boost). Mean critical / mean plain: 2.22, 2.34, 2.32 seen; 2.17, 2.25, 2.30 by the page; 3.10, 3.33, 3.45 with the reference's "one more pDIF on top". | BG-Wiki as coded; the reference's rule is excluded |
| M4 | Critical hit damage (G12) | A WAR without critical damage gear: +18.0 % [17.3, 19.0] (Shining One), 17.3 % [16.3, 18.5] (Ikenga's Axe), 18.0 % [16.5, 19.8] (Naegling) = Crit. Atk. Bonus II 8 % + gifts 10 %. It multiplies the critical hits only; the plain hits keep their base. | BG-Wiki and calc_jobs_fighters.js as coded |
| M5 | TP of a hit (`tpPerHit`) | floor(base) + floor(base x Store TP / 100) is exact on four sets: Shining One 134 + 83 = 217 (Store TP 62), Ukonvasara 206 (54), Chango 234 (75), Naegling 75 + 62 = 137 (83). Every swing of a multi-attack round gives the full amount. | BG-Wiki as coded |
| M6 | TP of the extra swings of a weapon skill (G7, L3) | Each landed swing after the first gives floor(10 x (1 + Store TP / 100)), floored per swing: Impulse Drive (Store TP 30) returns 174, 187, 200, and 13 or 26 when the first hit misses; Upheaval 174 + 13 k (30) or 180 + 13 k (35); Ukko's Fury 180 + 13 k (35: 13, not 13.5); Savage Blade 99 + 13 k (32). 46 weapon skills. Twice 40 and 41 were returned where three swings make 39. | the reference's rule, with a floor; the page's "flat 10 TP" is wrong |
| M7 | Raging Axe fTP (H19, L6) | Total at 3000 TP 6 874 (14 weapon skills), near 1130 TP 4 585 (11): ratio 1.50 +- 0.09. With the TP Bonus of Fencer, Boii Cuisses +3 and the axe's rank, the page's 1 / 3 / 6 gives 1.2 to 1.8, the reference's 1 / 1.5 / 2 gives 1.07 to 1.17; with fTP 2.0 a total of 6 874 would need a base damage above 800. | BG-Wiki; the reference's values are excluded. The 2000 TP anchor is not measured. |
| M8 | Fencer's TP Bonus on Savage Blade | Total at 3000 TP 18 334 (4), near 1130 TP 14 900 (8): ratio 1.23 +- 0.14; 1.34 expected with about +830 TP, 2.6 without any TP Bonus. | calc (Fencer) as coded |
| M9 | Hit rate cap of a two-handed weapon | On the level 137 enemy, accuracy 1364 and 1305 give the same rate, 94.0 % and 93.8 % (78 of 83 swings): a cap. A 99 % cap would allow this once in 500. | BG-Wiki as coded (95 %) |

## N. Found, not in the engine

| # | Point | Measured | To do |
|---|-------|----------|-------|
| N1 | Spike at pDIF = 1 on plain hits (J1) | A share of the plain hits has pDIF exactly 1: 22.5 % [17.0, 28.5] at w 1.33, 41 % [33, 49] at w 1.12, 27.5 % [18.5, 37.5] at w 1.04, 24.5 % [11.5, 40.5] at w 1.35, none at w 1.86. The page has it under "Average Melee pDIF(qRatio)": "the Spike frequency started at 0.5 wratio and rose linearly to plateau at 33% between 0.75 and 1.25 before finally falling linearly again to 0 at 1.5 wRatio", "sRatio = (0.5 - abs(wRatio - 1)) * 1.2". That formula is inside the five intervals (at the edge for 1.12). | Mean of a plain hit = (sRatio + (1 - sRatio) x (LL + UL) / 2) x 1.025: the uniform mean of `pdifAverage` is 5.5 % too high at w 1.33 and 4 % at w 1.12. Not on critical hits. On weapon skill hits: not measurable from totals. |
| N2 | "Double Attack" damage (J9) | Cichol's Mantle `"Double Attack" damage +20`: both swings of a round where Double Attack procs deal 20 % more, the swings of rounds without it (one, three or four swings) do not. The hits at pDIF 1 sit at 272 in two-swing rounds and 226-232 otherwise (Ikenga's Axe); fitted bonus 0.210 [0.199, 0.213] (Ikenga's Axe), 0.204 [0.166, 0.232] (Chango), 0.177 [0.157, 0.215] (Naegling), 0.189 [0.147, 0.224] (Shining One). First and second swing have the same distribution. It is damage, not attack (the hits at pDIF 1 move). With Agoge Cuisses +3 (+11) Ukonvasara needs 31 % (sum) or 33 % (product): 20 % alone would need a base above the fSTR cap. | Auto-attacks: x (1 + sum) on both swings of a Double Attack round. Weapon skills: unknown. |
| N3 | Ranks missing from the item catalogue | War. Beads +2 rank 25 "Dbl. Atk. +7%" and STR, DEX +15: without it the Shining One set has Double Attack 91 % and 41 single rounds are expected in 452; 8 are seen (98.2 %, 98 % with it). Schere Earring rank 30 "Store TP +5" (M5, M6). Sakpata's Gauntlets "Store TP +7" (rank 25 to 29). Sailfi Belt +1 rank 15 STR +15, Double Attack +5 %. Ikenga's Axe DMG +13 to +15 (its swings need floor(DMG + fSTR) = 227, above 192 + 29). | catalogue |
| N4 | Ukonvasara, Aftermath: Lv.1 | 16 of 58 landed swings (28 %, [17, 41]) deal three times the damage, plain and critical alike; 0 of 6 without the aftermath. The page gives no rate. | K (aftermaths) |
| N5 | Stoneskin on the enemy | Changes no logged damage (Ikenga's Axe plain hits 289.7 with, 294.3 without, 56 and 127 hits). | none |

## O. Still undecided

| # | Point | State |
|---|-------|-------|
| O1 | Hit rate slope and floor (G1) | Four enemies hit at two accuracies 26 to 29 apart: the rate moved by 6.7, 6.1, 15.7 and 25.7 points for 13 to 14.5 expected; slope 0.40 +- 0.10 a point, compatible with 0.5, but the rate drifts inside a fight more than chance allows. The floor is out of reach. |
| O2 | First hit accuracy bonus (J6) | First hit landed 41 / 41 (Raging Axe) and 20 / 20 (Vorpal Thrust) where auto-attacks land 55 % and 49 %: at least +75. But 16 / 23 (Savage Blade) and 17 / 23 (Impulse Drive) where auto-attacks land 57-79 % and 66 %. The accuracy of the weapon skill sets is not logged: +40 to +100 by weapon skill. |
| O3 | Ratio under Berserk | Fitted w 1.86 [1.80, 1.91] with attack 2532; the defense Naegling measures on the same enemy (1445) gives 1.75. 20 hits. |
| O4 | Four-swing rounds with Shining One | Their 12 plain hits are all between 466 and 566 (353 to 615 expected, a fifth at 353-370); their critical hits fit. Ikenga's Axe and Chango fit. |
| O5 | Great axes | Ukonvasara's swings come out 5 to 8 % above N2 with the fSTR the other weapons imply on the same enemy (two sigma). |
| O6 | Spike on weapon skill hits; "Double Attack" damage on weapon skills; Boii "Set: Augments Double Attack" (0 double-damage swing in 383 with Boii Mask +3 and Boii Earring +1: the earring may not count); Chango's aftermath (4 swings without it); absolute weapon skill damage (needs the character's attributes and the attack of the weapon skill set). | not measurable in this journal |

## P. Applied to the engine from these measurements

Labelled `// measured in game 2026-10-09:` in the code, with the sample size.
`node scripts/audit/calc_swings_check.js` compares `CALC.pdifAverage` and `CALC.pdifSpikeShare`
with the swings themselves (scripts/audit/engine_ref/swings_2026-10-09.json).

| # | Change | File | Evidence | Against the old reference |
|---|--------|------|----------|---------------------------|
| P1 | Spike at pDIF 1: `CALC.pdifSpikeShare(wRatio)` = (0.5 - abs(wRatio - 1)) x 1.2 between 0 and 0.333; a hit that is not critical is pDIF 1 with that probability, else the draw between the limits; none on critical hits | calc_ws_pdif.js | N1, and the page's "Average Melee pDIF(qRatio)". Plain mean against the engine: +2.0% (215 hits), +1.8% (169), 0.0% (113), +0.6% (37), -0.2% (20); without the spike +7.5%, +6.0%, +1.5%, +5.6%, -0.2% | the reference has no spike: every uncapped result with a ratio between 0.5 and 1.5 now sits up to 7% under it; the game agrees with the engine |
| P2 | TP of each landed swing after the first of a hand: floor(10 x (1 + Store TP / 100)) | calc_ws_tp.js | M6, 46 weapon skills; the page's "flat 10 TP" is wrong | G7 shrinks to the floor: the reference does not floor (14.8 against 14). TP returns exact against it went from 102 to 200 of 1636, and those beyond 5% from 700 to 204 |
| P3 | Critical hits: ratio + 1, the same limits, no spike; "Crit Damage" on the critical hits only | calc_ws_pdif.js, calc_ws_average.js (already so; the measurement is now in the comments) | M3 (359 critical hits), M4 (+18.0% [17.3, 19.0]). Critical mean against the engine: -0.4% (168), -2.5% (96), -0.2% (32) | G5 and G12: the game agrees with the engine; the reference's "average hit" overstates uncapped critical hits |
| P4 | `CALC.doubleAttackDamageBonus(percent, swingsInRound, fromDoubleAttack)`: x (1 + percent / 100) on both swings of an auto-attack round of two swings made by Double Attack | calc_ws_hits.js | N2 (0.210 [0.199, 0.213] on 169 hits for +20) | written for stage 3; not applied to weapon skills (open: O6); the reference does not apply it to weapon skills either (Armor Break exact without it) |
| P5 | Hit rate cap of a two-handed weapon: 95% | calc_ws_hits.js (already so; the measurement is now in the comment) | M9, 78 of 83 | same as the reference |

Settled by the game among the questions of section L: L1 and L2 (the engine, P3), L3 (P2), and
half of L6 (Raging Axe at 3000 TP against 1000 TP: the page's fTP, M7). Still open: the off-hand
accuracy (L4), "occasionally attacks twice" on weapon skills (L5), the other fTP of L6, L7 to L12,
whether the spike and "Double Attack" damage exist on weapon skill hits (O6: the engine applies
the spike to them, as to any melee hit, and not the "Double Attack" damage), the hit rate floor
and slope (O1, so G1 stays BG-Wiki against the reference), and the first swing's accuracy bonus
(O2: +40 to +100; the engine keeps the page's 100).

## Q. End to end on weapon skills measured in game (evening of 2026-10-09)

`node scripts/audit/calc_ws_ingame_check.js` (data: scripts/audit/engine_ref/ws_2026-10-09.json,
written by ws_ingame_export.py from the journal's line 3976 on). 15 Ukko's Fury with Ukonvasara
and 15 Upheaval with Chango (one set apart: STR Down). Nothing is fitted on the weapon skills.
Inputs: attributes and attack from the stats packet at the weapon skill, accuracy from the
/checkparam in the weapon skill set (three weapon skills have none of their own: the reading of
another one in the same set is used), the set's other stats by `CALC.characterStats` on the
pieces worn, the enemy's defense and VIT from that fight's auto-attack swings.

| Series | n | Measured mean | Predicted, evasion at the swings' bound | Predicted, evasion from the TP returns |
|--------|---|---------------|------------------------------------------|----------------------------------------|
| Ukko's Fury, Ukonvasara R15 | 15 | 10 466 +- 1 110 | 10 128 (-3.2%, -0.3 standard error) | 11 267 (+7.7%, +0.7) |
| Upheaval, Chango R15 | 14 | 6 377 +- 607 | 5 316 (-16.6%, -1.7) | 5 948 (-6.7%, -0.7) |

TP returned: 198.5 +- 3.4 measured against 182 to 188 (Ukko's Fury), 166.6 +- 16.3 against 135 to
151 (Upheaval). The first hit's TP confirms the Store TP the engine totals for both sets (167 =
134 + floor(134 x 0.25); 174 = 134 + floor(134 x 0.30)).

What limits the test, by size (the checker prints the whole table):
- The enemy's evasion. The auto-attacks of fights 14 and 15 land at the 95% cap (accuracy 1400),
  so they only say "evasion <= 1350 / 1360", and the weapon skill sets have 60 to 150 less
  accuracy. 40 points of evasion move Upheaval by 27 to 30% and Ukko's Fury by 5 to 12%. The TP
  returned counts the swings that landed, which gives an evasion without any damage (fight 15:
  1346 to 1352; fight 16: 1366 against 1384 from the swings): that is the second prediction.
- The first swing's accuracy bonus (O2): +40 instead of +100 takes 31% off Upheaval, whose
  first hit carries the fTP. First hits landed 12 of 14 where the later swings land a third of
  the time: at least +100 on this enemy.
- The enemy's AGI, not measured: 50 under the character's DEX would add 10% to Ukko's Fury.
- "Double Attack" damage on the weapon skill's Double Attack swings (O6): +5.7% on Ukko's Fury,
  +1.2% on Upheaval. Neither sign of gap decides it.
- Merits of Upheaval (85% assumed): 73% takes 6.5% off.
- The enemy's defense interval: 1 to 3%. Its VIT, the 8 swing limit, the spike on weapon skill
  hits (3.6% on Upheaval, nothing on Ukko's Fury whose hits are mostly critical): under 4%.

Read for this check: https://www.bg-wiki.com/ffxi/Empyrean_Aftermath ("Also unlike Mythics,
Empyrean Aftermath cannot proc on Weapon Skills": Ukonvasara's aftermath is not applied to
Ukko's Fury), https://www.bg-wiki.com/ffxi/Ukonvasara_(Level_119_III) (DMG 340, rank 15 "DMG: +12
[Ukko's Fury]: Damage +10%": the +10% was missing from calc_ws_details.js and is added),
https://www.bg-wiki.com/ffxi/Chango (aftermath: skillchain and magic burst potency, nothing on
weapon skill damage).

Out of sample for section P: the 570 plain and 97 critical Ukonvasara swings of fights 13 and 14
(a new engaged set, not used to settle any rule; `node scripts/audit/calc_swings_check.js`). The
base and the ratio are fitted on their plain hits; predicted then: share at pDIF 1 20.6% and
19.7% (measured 20.3% of 408, 16.1% of 162), critical / plain mean 2.169 and 2.165 (measured
2.139, 2.142), plain mean +0.5% and -1.8%, critical mean +1.9% and -0.7%; without the spike the
plain mean is 5.9% and 3.3% too high. Hit rate 95.3% of 506 and 96.9% of 191 against the 95% cap.

The next measurement that would tighten this most: the enemy's evasion below the cap. Fight the
same enemy for 150 to 200 auto-attack swings in a set of known lower accuracy (the weapon skill
set itself, about 1250 to 1340, checked with /checkparam), so that the hit rate sits between 30%
and 90%, then the weapon skills on that same enemy. With the evasion known to +-10, Upheaval's
uncertainty falls from about 30% to about 8%, and the first swing's accuracy bonus (first hits
landed against later swings) can be read to +-15.

## R. Hit rate against accuracy, and Upheaval again (night of 2026-10-09)

The measurement section Q asked for, made with the journal's `strip` steps: slots of the engaged
set are emptied and locked step by step, the accuracy of each step is the /checkparam's, the
steps are played three times round on one enemy. Ukonvasara, auto-attacks only, no weapon skill.

| Accuracy | Lv 138 ("low evasion and defense") | Lv 139 ("high evasion, low defense") |
|----------|-------------------------------------|---------------------------------------|
| 1415 | | 28 of 31 (90%) |
| 1390 to 1400 | 90 of 92 (98%) | |
| 1365 | 81 of 92 (88%) | 49 of 61 (80%) |
| 1324 | 65 of 92 (71%) | 49 of 91 (54%) |
| 1267 | 45 of 91 (49%) | 20 of 91 (22%) |
| 1190 | 28 of 90 (31%) | |
| 1096 | 18 of 92 (20%) | |
| 1039 | 20 of 90 (22%) | |

- Floor: 38 of 182 at 1096 and 1039, 57 points apart: 20.9%. BG-Wiki's 20% holds.
- Lv 139 follows 75 + (accuracy - evasion) / 2 with an evasion near 1365 (predicted 95 / 75 / 54.5
  / 26 for the four rows, each within the sampling error).
- Lv 138: the top of the curve gives an evasion of 1335 to 1340. Its two lowest rows above the
  floor are higher than that line gives (49% for 41, 31% for the 20% floor; about 2 and 2.6
  standard errors). NOT explained, and the Lv 139 enemy does not show it: nothing of it is in
  the engine.
- The evasion changes with the enemy's level, about 30 a level here. The same values come from
  the TP the Upheavals returned (how many later swings landed, no damage used): 1300 at Lv 137,
  1334 and 1346 at Lv 138, 1361 at Lv 139. One level's evasion must never be used for another.

Upheaval with more weapon skills (`node scripts/audit/calc_ws_ingame_check.js` on the whole
journal; the export of section Q is kept beside it as ws_2026-10-09.afternoon.bak):

| Series | n | Measured mean | Predicted, evasion from the swings | Predicted, evasion from the TP returns |
|--------|---|---------------|-------------------------------------|----------------------------------------|
| Upheaval, Chango R15 | 54 | 8 248 +- 628 | 8 308 (+0.7%, 0.1 standard error) | 8 805 (+6.8%, 0.9) |
| Ukko's Fury, Ukonvasara R15 | 17 | 10 862 +- 1 016 | 10 571 (-2.7%, -0.3) | 11 576 (+6.6%, 0.7) |

TP returned by Upheaval: 172.2 +- 9.0 measured, 173.9 predicted. By series the gap goes both
ways (-7% on 14 at Lv 139, -19% on 8 at Lv 138, +7% on 17 at Lv 137): one Upheaval is worth 0
to 12 000, so 8 to 17 of them move the mean by 10 to 20% by themselves.

What the 54 mix, and the engine does not separate: 7 were used under Restraint (its weapon skill
damage bonus is not in the engine: those are expected a little under the game), some of fight 16
under Berserk (the attack is the measured one, so they are comparable), and the Lv 137 enemy's
evasion is only bounded by its swings (at the cap).

Still open after this: the first swing's accuracy bonus by a direct measurement (O2), the lower
part of the Lv 138 curve, Restraint.

---

# atelier/calc, stage 3: differences with the reference results (the average auto-attack round)

`node scripts/audit/calc_round_check.js` recomputes the `round` of the 756 cases with
`CALC.attackRoundAverage` and `CALC.timeToWeaponskill`, fed with the case's own `stats` and enemy
(the differences of stage 1 stay out), and compares fourteen intermediate values and the three
results. The battery has no hand-to-hand, no kick, no Daken, no ability, no aftermath: those
paths are written from BG-Wiki and never compared (section V).

Cases by relative gap, engine as delivered (exact <= 1e-9 / <= 0.1% / <= 1% / <= 5% / more):

| Value | exact | 0.1% | 1% | 5% | more |
|-------|-------|------|----|----|------|
| delay of a round, delay for TP, base TP, TP per hit, critical hit rate, regain, time of a round, kick, Daken | 756 | . | . | . | . |
| hit rate, main hand (and swings landed, main hand) | 661 | . | 48 | 47 | . |
| hit rate, off-hand (and swings landed, off-hand) | 739 | . | 14 | 3 | . |
| swings landed, Zanshin | 736 | . | 7 | 13 | . |
| RESULT TP a round | 640 | 6 | 68 | 42 | . |
| RESULT damage a round | 176 | 3 | 122 | 129 | 326 |
| RESULT time to weapon skill | 640 | 6 | 68 | 42 | . |

With `--as-reference` (section S applied by the checker, in its own process): every value is
exact in the 756 cases, except the damage of 6 cases (Kaories_COR#12 to #17, 0.06% to 0.08%, S6).

`atelier/calc/` holds only what BG-Wiki documents, what the game showed, or an assumption marked
ASSUMED in the code and listed in section T: no switch, constant or function there comes from the
reference. The largest gap, the damage, is the mean pDIF (S2): the engine's is the one measured
in game on auto-attack swings (sections M, N, P), the reference's is not.

Two things the checker gives the engine because the sheet does not carry them, and that are not
"as reference": the main hand weapon's name (for a relic's hidden effect) and five merits in
Ikishoten for a Samurai (T13). And one definition: the reference's "TP a round" counts the
Regain ticked during the round; the engine returns it apart (`tpFromRegain`), the checker adds
the two.

## S. BG-Wiki or the game states a rule, the reference does something else

One line per engine function the checker replaces for `--as-reference`. "Cases moved" = how many
of the 756 change when that one behaviour alone replaces the engine's, and the widest move.

| # | What | Engine (BG-Wiki, or the game) | Reference (worked out from its results) | Cases moved | Source |
|---|------|-------------------------------|------------------------------------------|-------------|--------|
| S1 | `hitRate` | 75 + floor((accuracy - evasion) / 2) | no floor (G1 of stage 2): 20.5% against 20% | 116: damage and TP up to 2.5%, time to weapon skill up to 2.4% | https://www.bg-wiki.com/ffxi/Hit_Rate (section O1: the game has not settled it) |
| S2 | `wsMeanPdif` (mean pDIF of a swing) | a swing is critical or not; critical: ratio + 1, same limits, no spike, "Crit Damage" on it alone; not critical: the spike at pDIF 1, else the draw. Measured in game on auto-attack swings (M1, M3, M4, N1, P1, P3) | one "average hit" (G5, G12 of stage 2): the critical hit RATE added to the ratio and again to the mean, no spike, "Crit Damage" on the whole | 503 damage, up to 34% (mean 8.8%); the missing spike alone: 354, up to 8.1% | https://www.bg-wiki.com/ffxi/PDIF ; the game |
| S3 | `weaponRank` in fSTR's caps | floor(damage / 9) | damage / 9 (G2 of stage 2); the base damage itself is floored on both sides | 174 damage, up to 1.2% | https://www.bg-wiki.com/ffxi/Weapon_Rank |
| S4 | `SWING_RULES.first`: what the first swing of a Double or Triple Attack round gets | "Double Attack" damage on BOTH swings of the round: measured in game (N2, 0.210 [0.199, 0.213] for +20, first and second swing alike). "DA Attack", "TA Attack", "TA Damage%" follow the same pattern (ASSUMED, T5) | the bonuses on the extra swings only (Tetsouo_WAR#0: 1414.5 against 1390.1 once S2 is set apart, the first swing without its +20%) | 114 damage, up to 10.1%. "Double Attack" damage alone (measured): 48, up to 9.8%. "TA Damage%" alone (assumed): 72, up to 5.7%. The attack bonuses alone (assumed): 48, up to 0.5% | the game (N2); https://www.bg-wiki.com/ffxi/Double_Attack lists the gear without a rule |
| S5 | `SWING_RULES.ta.attack` | the Thief's job points: "Increases the physical attack of Triple Attack" "Increase physical attack by 1": "TA Attack" 20 added on Triple Attack rounds | "TA Attack" is not used in a round, while "DA Attack" is | 24 (Tetsouo_THF below the pDIF cap), up to 0.9% | https://www.bg-wiki.com/ffxi/Thief |
| S6 | "TA Damage%" with two weapons | on the swings of the hand that triples | 0.06% to 0.08% more than the extra swings alone give: worth about one more off-hand swing with the bonus for each off-hand Triple Attack; not worked out further | Kaories_COR#12 to #17 | - |

Where the engine and the reference agree on something BG-Wiki does not fully state, it is in
section T (the reference "does the same"): agreement there is evidence, not proof.

## T. Assumptions and readings (marked ASSUMED in the code)

"Size" is the effect on the 756 cases of dropping or changing the assumption.

| # | Assumption | Why | Size | Reference |
|---|------------|-----|------|-----------|
| T1 | A dual wield round lasts (Delay1 + Delay2) x (1 - Dual Wield) x (1 - haste) / 60 seconds | Dual_Wield gives "(Delay1 + Delay2) x (1 - Dual Wield %) / 2 = New Delay per Hand" and "the frequency of attack rounds", never the round's delay in so many words; Attack_Speed gives 60 delay a second by its example only | all 138 dual wield cases: the whole time | same (exact) |
| T2 | Hand-to-hand: the delay left is never under 20% of 480 + weapon delay | Two pages disagree: Attack_Speed "(480 Base Delay + 86 Weapon Delay)*.2 Delay cap = 113.2 minimum possible delay", Martial_Arts "the minimum H2H delay is 96 delay per round" (20% of 480). The first, which counts the weapon, is followed | no case | not compared |
| T3 | "Regain" +N is N TP every 3 seconds | Regain: "Regain restores TP over time in 3 second intervals (Ticks)." and "Regain +10" beside "10 TP/tick", never equated | 90 cases have Regain (3 to 8): up to 33% of the TP of a round where the hit rate is at its floor | same (exact) |
| T4 | Eight swing limit: the main hand's extra swings are served first, then the off-hand's (or the second fist's), then the kick; the Zanshin swing only exists in rounds of one swing; a Daken throw is not counted | Multi-Attack says "limited to 8 hits" and not which swings are dropped | no case reaches the limit (two hands of four swings make eight; only a kick, or a weapon that attacks more than four times, can pass it) | not compared |
| T5 | "DA Attack", "TA Attack" and "TA Damage%" go to every swing of the round of that hand, the first included; attack bonuses are added to the finished attack (not multiplied by Smite, Chaos Roll...) | The pages give "physical attack from double attacks", "physical attack of Triple Attack", and list "Triple Attack damage" gear without a rule. The one such bonus measured in game, "Double Attack" damage, is on both swings (N2): the others are taken to follow it | S4: "TA Damage%" 72 cases up to 5.7%; attack bonuses 48 cases up to 0.5% | extra swings only; "TA Attack" unused (S4, S5) |
| T6 | Base damage of a swing = floor(D + fSTR) | Base_Damage writes "Base Damage = D + (aD) + fSTR" for melee and "floor(D + fSTR) + Total DEX" for Sneak Attack. The game's damage at pDIF 1 is whole (M2), which quarters of fSTR would not give | 418 cases, up to 0.8% against no floor | same |
| T7 | Occasionally attacks: each weapon rolls its own "OA2" in its own hand, the off-hand included; Mythic Aftermath Lv.3 "40% 2x 20% 3x" is one roll (60% in all) of the main hand, of both fists hand-to-hand; only "attacks twice" weapons are computed | Multi-Attack: "that weapon will not be allowed to have a lower order check" (one check a weapon); nothing on the off-hand; no page gives the shares of a weapon that attacks 3 to 8 times | "OA2": 138 cases, damage and TP up to 31% | same for "OA2" (exact); aftermath not compared |
| T8 | Zanshin: one check, on the missed swing of a round where no multi-attack fired, at the "Zanshin" of the sheet (x 1.25 with Hasso, the page's "appears"); the Zanshin swing has +34 accuracy and "Zanshin Attack", lands at its own hit rate and does not multi-attack. With Hasso and Samurai as main job, a last check at Zanshin / 4 adds a swing treated as a Zanshin hit | Zanshin: "single-swing attack rounds", "Missed melee attack."; the sentence "Zanshin attacks check for Zanshin: Double Attack first, followed by Zanshin: OAT only if Z:DA check fails." is not understood well enough to compute (it may mean a Zanshin swing can itself double) | Zanshin swings: 120 cases, damage up to 30%, TP up to 47%; the +34 and the attack: 54 cases, damage up to 12% | same without Hasso (exact); Hasso not compared |
| T9 | Kick: one check a round after the fists (none when they already make eight swings), no multi-attack, the TP of a fist; base damage = skill x 0.11 + 3 + "Kick DMG", fSTR with the hand-to-hand rank of "Kick DMG" | Kick_Attacks: "an extra attack", "fSTR does apply to kick attacks (R0 weapon if you don't have kick damage modifying gear on)"; nothing on its TP, its place in the round or the rank with such gear | no case | not compared |
| T10 | Daken: one check a round; only the number of throws is returned | Daken: "occasionally throws the shuriken when autoattacking" | no case | not compared |
| T11 | Empyrean aftermath multiplies the swings of the main hand weapon (extra swings and Zanshin included, both fists, not the kick, not the off-hand), critical or not, by 1 + rate x (2 or 3 - 1) on average. Relic: Apocalypse only, 20% double damage on the main hand's first swing; its aftermath's "10% Job Ability Haste" is taken as 0.1 of the delay (102/1024 would be 0.0996) | Empyrean_Aftermath: "any additional hits (Double Attack, Triple Attack, Zanshin) initiated by the weapon"; Apocalypse's page. Measured in game for comparison only (N4): Ukonvasara Lv.1, 16 of 58 landed swings tripled (28%, [17, 41]) for the page's 30% | Apocalypse's hidden effect: 48 cases (Tetsouo_DRK), damage 12.5% to 14.6% | same for the hidden effect (exact); aftermaths not compared |
| T12 | Time to a weapon skill = TP needed / (TP of a mean round / time of a round + Regain / 3) | our own arithmetic: a mean rate, not a whole number of rounds. A real fight ends on a round, so the true mean is a little longer; nothing is added for the weapon skill's own animation | - | same (exact) |
| T13 | A Samurai has 5 merits in Ikishoten (given by the checker as an option; the engine's default is 0) | the job merits of stage 1 are all bought (D2); the sheet has no line for Ikishoten | 48 cases (Tetsouo_SAM): TP a round up to 26%, time up to 35% | same (exact) |

## U. Input data not backed by BG-Wiki

- Blurred Knife +1: the page has "Occasionally attacks twice" and no rate; the "OA2" 45 of our item
  catalogue is BG-Wiki's figure for Demers. Degen +1 only ("has an activation rate of 45%").
- A relic other than Apocalypse in the main hand gets no hidden effect: their pages were not read.

## V. Not covered

- Ranged attack rounds; the hit rate, damage and TP of a Daken throw (`swings.daken` is the number
  of throws; `tpPerDaken` the TP one would give if it lands).
- Pets; magical damage added on hit (enspells, "EnSpell Damage" of the sheet); additional effects.
- Follow-up attacks (1st order of Multi-Attack: Virtue Stone, Raetic, SU 4/5 weapons).
- Weapons that occasionally attack 3 to 8 times; Mythic Aftermath Lv.1 and Lv.2 (accuracy and attack
  amounts that depend on the TP), and Lv.3 of the weapons below level 95 or of the ranged mythics.
- Job abilities, the sheet's `abilities` being empty: Hasso's STR, accuracy and haste (only its
  effect on Zanshin is an option here), Seigan's counters, Sneak / Trick Attack, Footwork, Impetus,
  Saber Dance, Restraint... "Striking Crit Rate", "Sneak Attack Bonus" of the sheet are not read.
- Zanshin after a swing absorbed by shadows, guarded or countered; counters and retaliations.
- Hand-to-hand, kicks, aftermaths and Hasso are written and run (a scratch test checks their
  arithmetic), but no case of the battery reaches them and nothing was measured in game for them.
- Level correction (the enemy of the input has no level), as in stage 2.

## W. What only a test in the game can settle

1. "TA Damage%" (T5, S4): Triple Attack rounds of a Thief with Toutatis's Cape, swing by swing at
   pDIF 1: do the three swings carry the bonus, or the two extra ones? The same journal as N2.
2. "DA Attack" and "TA Attack" (T5, S5): the damage of the first swing of a Double Attack round
   against a single swing, below the pDIF cap, without "Double Attack" damage gear: is the first
   swing's attack raised too? (0.5% at most here: needs several hundred swings.)
3. Zanshin (T8): does a Zanshin swing ever come with a Double Attack of its own; the rate with
   Hasso (x 1.25?); the swing Hasso adds: +34 accuracy and Ikishoten's TP or not.
4. The hit rate's floor in the formula (S1, O1 of stage 2).
5. Off-hand "occasionally attacks twice" (T7), and Blurred Knife +1's rate (U): rounds of three
   and four swings without Double / Triple Attack gear.
6. Dual wield round time (T1): time 50 rounds with two weapons of different delays.
7. Hand-to-hand's minimum delay (T2): 96 or 20% of 480 + weapon.
8. Kick attacks (T9): TP of a kick, and whether a kick appears in a round of eight fist swings.
9. Empyrean aftermath on the off-hand's and on a kick's swings, and its rate by level on more
   than the 58 swings of N4 (T11).
10. Regain (T3): TP gained over a minute without attacking, with "Regain +N" gear only.

## X. The page asks this engine (2026-10-10)

`calc_page.js` gives the page's shapes, `calc_bridge.js` switches between this engine ("own") and the
one the page had before ("old"), on the page and in its workers; the choice is the page's (top bar),
"old" by default. `node scripts/audit/calc_page_check.js` plays the 756 cases through the functions
the page calls.

1. Through the page, "own" answers exactly what the engine answers when called directly (0 gap on
   2 268 weapon skill results and 756 rounds), and the page's own counting of whole rounds runs on
   the round it is given.
2. What "own" hands to "old", by reason, on the battery: 549 results of magical weapon skills, 42
   hybrid, 33 without a type in our table, 8 with an fTP unknown at that TP. A character with any
   ability on (Berserk, Hasso, an aftermath, an En-spell...) is built by "old" as a whole: the sheet
   reads no ability yet (section V), and none of the battery's cases has one.
3. The character's attributes and "Critical Hit Rate" merits read in game (the page's "Base Stats")
   replace the table of U when given (`baseAttributes`, `critRateMerits` of CALC.characterStats).
4. ASSUMED: the number of buffs a Naegling counts is not given by the page, taken as none.
5. The same calls take 362 ms with "own" for 539 ms with "old" (one run, this PC).
6. On the weapon skills measured in game (`node scripts/audit/calc_ws_ingame_check.js --old`: the
   same sheets and the same enemy given to both, the evasion of the second prediction): Ukko's Fury,
   17 measured at 10 862, "own" 11 576 (+6.6 %), "old" 14 380 (+32.4 %); Upheaval, 54 measured at
   8 248, "own" 8 805 (+6.8 %), "old" 8 970 (+8.8 %).

## Y. Job abilities (2026-10-10)

`calc_abilities.js` holds what an ability used on oneself adds to the sheet (`CALC.ABILITIES`,
`CALC.abilityTotals`); `CALC.characterStats` adds it after the buffs and before what depends on the
weapons, and `CALC.page.player` now refuses only the abilities that come back as unknown. This
replaces the line of section V and point 2 of section X that say no ability is read. Every page was
fetched on 2026-10-10 (SOURCES.md, "Job abilities").

Who uses the ability: the main job (level 99, job points counted, 20 ranks each: D5) when it has it
and the name does not end with " (sub)", else the support job at `CALC.subJobLevel(ml)` without job
points. An ability neither job has, or that the support job cannot have at its level, is unknown.

### Y1. Covered

| Ability | As main job | As support job | Page |
|---------|-------------|----------------|------|
| Berserk | Attack% and Ranged Attack% +89/256, Attack +40 | +64/256 below level 50, +69/256 at 50 to 59; no flat attack | Berserk |
| Defender | Attack% and Ranged Attack% -0.25 | the same | Defender |
| Warcry | Attack% and Ranged Attack% +29/256, Attack +60 | floor(level / 4 + 4.75) / 256 (17/256 at 49, 18/256 at 56) | Warcry |
| Aggressor | Accuracy +45, Evasion -25 | Accuracy +25, Evasion -25 | Aggressor |
| Blood Rage | Crit Rate +40 | unknown (level 87) | Blood_Rage |
| Mighty Strikes | Crit Rate +100, Accuracy +40 | unknown (SP ability) | Mighty_Strikes |
| Focus | Accuracy +120, Crit Rate +20 | Accuracy level + 1, Crit Rate (level + 1) x 0.2 | Focus |
| Composure | Accuracy +70 | unknown ("not accessible") | Composure |
| Last Resort | unknown (Y3) | Attack% +64/256; JA Haste 0.05 / 0.10 / 0.15 at level 15 / 30 / 45 with a two-handed weapon | Last_Resort, Desperate_Blows |
| Sharpshot | Ranged Accuracy +40, Ranged Attack +40 | Ranged Accuracy +40 | Sharpshot |
| Hasso | two-handed weapon only: STR +34, Accuracy +10, JA Haste 0.1 | STR floor(level / 7), Accuracy +10, JA Haste 0.1 | Hasso |
| Hagakure | TP Bonus +1200 | unknown (level 95) | Hagakure |

Hasso also puts "Hasso active" 1 on the sheet (not a game stat): `CALC.page.round` reads it to hand
`hasso` to the round, which already had Zanshin's rules under Hasso (T8). Without it a Samurai with
Hasso on would have lost them the day the page stopped falling back.

### Y2. Known, empty effect (nothing the sheet holds)

Fan Dance (physical damage taken; main job only), Sentinel (physical damage taken, enmity), Rampart
(damage taken), Crusade (enmity; PLD and RUN), Palisade (block rate), Majesty (cure potency and
recast), Reprisal (block rate, shield skill), Cocoon (defense +50 %: the sheet has no defense).
Berserk's and Last Resort's defense penalty, Defender's defense bonus and its job points are left
out for the same reason. As a support job, one of these whose level is above the support job's
(Rampart 62, Reprisal 61, Majesty 70, Crusade 88, Palisade 95) comes back unknown.

### Y3. Left out of the table (unknown: the page's case falls back)

| Ability | Why | What the page gives |
|---------|-----|---------------------|
| Brazen Rush | decays with time | "begins at 100% double attack rate and diminishes over the duration of the effect"; job points attack +4 a rank |
| Impetus | a count of hits in a row | "+2 Attack and +1% Critical Hit Rate for each consecutive successful attack", caps "+100 Attack and +50% Critical Hit Rate" |
| Conspirator | the number of people on the enemy's list | 15 accuracy and 20 Subtle Blow at 1, 25 and 50 at 6, 49 and 50 at 18; job points up to 20 accuracy |
| Innin | decays with time | "+30% Critical Hit Rate, and -30 Evasion to start, all of which decay to +-10 over time"; job points accuracy +1 a rank |
| Saber Dance | decays with time | "50% Double Attack that decays to 20% in the first 30 seconds", then stays at 20% |
| Swordplay | grows with time | "+3 Accuracy/Evasion upon activation", "+3/tick", "Caps at +60"; job points +1 to the cap a rank |
| Building Flourish | the finishing moves spent, the merits bought, and the next weapon skill only | accuracy +40 / attack +25% / critical hit rate +10% at 1 / 2 / 3 moves; merits +2, +1%, +1% a level; job points weapon skill damage +1% a rank |
| Last Resort as main job | two job merits the input does not give | attack 64/256 to 89/256 with "Last Resort Effect" merits, haste 15% to 25% with Desperate Blows merits, job points attack +2 a rank. With the merit levels in the input it can be written from the numbers already read. |

Saber Dance after its first 30 seconds (20%) and Swordplay at its cap (60, 80 with job points) are
steady values the page gives; they were not taken because nothing in the input says the ability
has been up that long.

### Y4. ASSUMED (marked in the code)

| # | Assumption | Why |
|---|------------|-----|
| Y4.1 | Warcry: no merit in Savagery, so no TP Bonus | "Adds 100 TP Bonus to Warcry per merit level."; the input does not give the job merits. A Warrior with 5 merits has 500 TP Bonus more under Warcry than the sheet says. |
| Y4.2 | Aggressor: no merit in Aggressive Aim (ranged accuracy +4 a level) | same reason |
| Y4.3 | Mighty Strikes is +100 on the sheet's "Crit Rate": every swing of a round is critical, a weapon skill that can land critical hits always does, a weapon skill that cannot still does not | The page says "Turns all melee attacks into critical hits." and "Stacks with any physical Weapon Skill, Jump or similar ability.", and nothing on the weapon skills that cannot critically hit. |
| Y4.4 | Focus as a support job uses the support job's level | "Accuracy = Level + 1": the page does not say whose level, and says nothing of the support job. Its critical hit rate is the page's "seems to be: (Monk Level + 1) * .2". |
| Y4.5 | A percentage of job ability haste is that share of 1 (Hasso 0.1, Desperate Blows 0.05 / 0.10 / 0.15) | Attack_Speed lists "Hasso (10%)", "Last Resort (15~25%)" and gives 1024ths for the cap only ("25% (256/1024)"). Same reading as T11. If 10% were 102/1024 the haste would be 0.0996 instead of 0.1. |
| Y4.6 | Last Resort as a support job: Desperate Blows comes at the support job's level, and Ranged Attack is not raised | Support_Job: "you will receive all spells, traits, and abilities available to your sub job at its level"; the Desperate Blows page lists "DRK15 / DRK 30 / DRK 45" and nothing on the support job. The Last Resort page names "attack" only (asked: ranged attack is not on the page), where Berserk's names both. |
| Y4.7 | Blood Rage reaches its user | "Enhances critical hit rate for party members within area of effect." |
| Y4.8 | Job points of an ability are added as main job only, flat attack inside the base the percentages multiply | D5; the measurement below settles the second half for Berserk and Warcry. |

Also not read: the gear that strengthens an ability when worn for its activation (Pummeler's,
Agoge, Boii, Wakido "Hasso +1"..., Anchorite's Crown "Additional 21 accuracy" on Focus, Orion
Braccae on Sharpshot), Hagakure's "400 Save TP" (the TP a round starts from is the caller's), and
the fact that Hagakure and Mighty Strikes last one weapon skill or 45 seconds: the sheet is the
character while the ability is on.

### Y5. Against the game (`node scripts/audit/sheet_check.js`)

`scripts/audit/engine_ref/sheet.json`, WAR99/SAM56 at master level 39, read on 2026-10-10. The
script now gives the engine the run's own attributes (the last block with nothing on, minus what
the sheet adds from gear) and `abilities: {<label>: true}`; nothing else, and no number of the
engine was changed after seeing these.

| Block | Predicted | Measured |
|-------|-----------|----------|
| nothing on | attack 1723.3, accuracy 1195, evasion 893 | 1723, 1195, 905 |
| Berserk | attack 2284.7 | 2284 |
| Warcry | attack 1964.8 | 1964 |
| Defender | attack 1364.0 | 1364 |
| Aggressor | accuracy 1240, evasion 868 | 1240, 880 |
| Hasso (support job, level 56) | STR 323, accuracy 1205, attack 1732.9 | 323, 1205, 1732 |
| Blood Rage | attack, accuracy, evasion as with nothing on | nothing moved (the critical hit rate is not shown by the game) |
| Restraint, Retaliation, Seigan | not in the table; sheet as with nothing on | nothing moved |

- Confirmed: Berserk at 89/256 and Warcry at 29/256 add to Smite's 51/256 (one sum of percentages),
  their job points (40 and 60) sit in the base before the percentages, Defender is -25% in the same
  sum, Aggressor is 25 + 20 accuracy and -25 evasion, Hasso's STR follows the support job's level.
  The four attacks are above the game's by less than 1: the game shows the whole part.
- Not matched: evasion is 12 under the game's in every block, ability or not (893 for 905). The gap
  is the sheet's, not an ability's: Aggressor moves both by 25. Not looked into here (A1 is about
  the same formula).
- Not compared: defense (1380 -> 1035 under Berserk, -> 1940 under Defender) is not on the sheet;
  critical hit rate, haste, ranged attack, TP Bonus are not shown by the game. Only the Warrior's
  abilities and Hasso as a support job were measured: the other lines of Y1 rest on the pages alone.

## Z. Evasion from skill above 400 (measured 2026-10-10)

Four readings of /checkparam at rest, each with the attributes from the game's own data, the pieces
worn read one by one in the game's descriptions, the job's traits and gifts from its BG-Wiki page:

| Job | Evasion skill | AGI | pieces | traits and gifts | evasion shown | left for the skill | BG-Wiki's line |
|---|---|---|---|---|---|---|---|
| WHM99/SAM49, Master Level 0 | 316 | 170 | 204 | 0 | 593 | 304 | 304 |
| BST99/SAM52, Master Level 15 | 404 | 103 | 0 | 36 | 470 | 383 | 383 |
| WAR99/SAM56, Master Level 39 | 428 | 140 | 15 (Bathy Choker +1, Unity rank 1) | 36 | 523 | 402 | 405 |
| THF99/SAM54, Master Level 28 | 468 | 127 | 15 | 72 + 70 | 654 | 434 | 441 |

1. BG-Wiki's two steps hold at 316 and are 3 and 7 too high at 428 and 468. A third step, each point
   above 400 worth 0.8, floored apart from the second, gives 304, 402 and 434: in the engine
   (CALC.evasionFromSkill). A lower worth of the Master Levels' skill points alone (about 0.82) gives
   402 for the Warrior but 439 for the Thief: excluded.
2. Bathy Choker +1's "Unity Ranking: Evasion+5~15" is 15 at Unity rank 1 (905 with it, 890 without).
3. Not checked: where the step is exactly (the Beastmaster's 404 gives 383 with or without it: the step
   is not visibly under 400, so between 400 and 428), and whether the main hand's
   accuracy has one too (skill 748 gives the accuracy shown to the point with BG-Wiki's line).

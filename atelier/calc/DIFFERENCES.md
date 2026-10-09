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

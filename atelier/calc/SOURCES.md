# atelier/calc, stage 1: sources

Every game value in `atelier/calc/*.js` was read on the BG-Wiki page listed here (fetched on
2026-10-09) and the code carries the same address beside the value. Two things come from
elsewhere: piece names from Windower's `res/items.lua` (calc_sets.js), and the base attributes,
which BG-Wiki does not document (see DIFFERENCES.md, C1).

## Rules shared by every job

| Page | What was taken | File |
|------|----------------|------|
| https://www.bg-wiki.com/ffxi/Master_Levels | +1 to each attribute per master level; +1 to combat and magic skill caps per level | calc_tables.js |
| https://www.bg-wiki.com/ffxi/Support_Job | support job level = 49 + floor(master level / 5); the support job gives its traits at that level | calc_tables.js, calc_traits.js |
| https://www.bg-wiki.com/ffxi/Merit_Points | attributes +1 x 15 each (105 for the category); combat skills +2 x 8 (152); magic skills +2 x 8 (112); critical hit rate +1% x 5; job groups: 5 levels an item, 10 a group | calc_tables.js, calc_jobs_*.js |
| https://www.bg-wiki.com/ffxi/Combat_Skills | skill cap at level 99 by rank (A+ 424, A 417, B+ 404, B 398, B- 388, C+ 378, C 373, C- 368, D 334, E 300, F 265); master levels only raise skills the job has a rank in | calc_tables.js, calc_skills.js |
| https://www.bg-wiki.com/ffxi/Critical_Hit_Rate | base critical hit rate 5% | calc_tables.js |
| https://www.bg-wiki.com/ffxi/Accuracy | accuracy = floor(DEX x 0.75) + accuracy from skill + bonuses; the four skill ranges (1:1 to 200, 0.9 to 400, 0.8 to 600, 0.9 above) | calc_derived.js |
| https://www.bg-wiki.com/ffxi/Attack | attack = 8 + skill + STR (main hand); off-hand 8 + skill + floor(STR / 2) | calc_derived.js |
| https://www.bg-wiki.com/ffxi/Strength | STR to attack ratio since December 2018: two-handed 1.0, one-handed main 1.0, off-hand 0.5, hand-to-hand 0.75 | calc_derived.js |
| https://www.bg-wiki.com/ffxi/Evasion | evasion = floor(AGI / 2) + evasion from skill + bonuses; skill 1:1 to 200 then floor((skill - 200) x 0.9) + 200 | calc_derived.js |
| https://www.bg-wiki.com/ffxi/Attack_Speed | haste in 1024ths, 1% of gear haste = 10/1024; caps: equipment 256/1024, magic 448/1024, job ability 256/1024; delay left = (1 - Dual Wield) x (1024 - hastes) / 1024; 80% delay reduction cap; hand-to-hand base delay 480 less Martial Arts | calc_derived.js, calc_stats.js |
| https://www.bg-wiki.com/ffxi/Adhemar_Attire_Set_%2B1 | set bonus: critical hit rate +4 / 6 / 8 / 10% for 2 / 3 / 4 / 5 pieces | calc_sets.js |

Read and not used yet: https://www.bg-wiki.com/ffxi/Ranged_Accuracy (floor(AGI x 0.75) + the same
skill ranges), https://www.bg-wiki.com/ffxi/Ranged_Attack (8 + skill + STR),
the dDEX table of Critical_Hit_Rate (needs the enemy: next stage).

Looked for and not found on BG-Wiki: the attributes of a race and job at level 99
(https://www.bg-wiki.com/ffxi/Category:Base_Stats, https://www.bg-wiki.com/ffxi/Category:Hume and
https://www.bg-wiki.com/ffxi/Strength only give level 1 values and the STR ratio).

## Job traits: value of each tier (calc_tables.js)

| Page | Tiers taken |
|------|-------------|
| https://www.bg-wiki.com/ffxi/Attack_Bonus | 10, 22, 35, 48, 60, 72, 84, 96 |
| https://www.bg-wiki.com/ffxi/Accuracy_Bonus | 10, 22, 35, 48, 60, 73; applies to accuracy and ranged accuracy |
| https://www.bg-wiki.com/ffxi/Evasion_Bonus | 10, 22, 35, 48, 60, 72 |
| https://www.bg-wiki.com/ffxi/Magic_Attack_Bonus | 20, 24, 28, 32, 36, 40 |
| https://www.bg-wiki.com/ffxi/Magic_Defense_Bonus | 10, 12, 14, 16, 18, 20, 22 |
| https://www.bg-wiki.com/ffxi/Double_Attack | 10, 12, 14, 16, 18 (%); later tiers are the Warrior gifts |
| https://www.bg-wiki.com/ffxi/Triple_Attack | 5, 6 (%) |
| https://www.bg-wiki.com/ffxi/Dual_Wield | 10, 15, 25, 30, 35, 40 (%); only with two weapons; (Delay1 + Delay2) x (1 - Dual Wield) / 2 |
| https://www.bg-wiki.com/ffxi/Subtle_Blow | 5, 10, 15, 20, 25 |
| https://www.bg-wiki.com/ffxi/Skillchain_Bonus | 8, 12, 16, 20, 23 (%) |
| https://www.bg-wiki.com/ffxi/Critical_Attack_Bonus | 5, 8, 11, 14 (%) |
| https://www.bg-wiki.com/ffxi/Smite | 25/256, 38/256, 51/256, 64/256, 76/256 of attack, with a two-handed or hand-to-hand weapon |
| https://www.bg-wiki.com/ffxi/Fencer | ranks I to VIII: TP Bonus 200, 300, 400, 450, 500, 550, 600, 630; critical hit rate 3, 5, 7, 9, 10, 11, 12, 13; main hand only; WAR and BST gifts add 230 TP Bonus |
| https://www.bg-wiki.com/ffxi/Store_TP | 10, 15, 20, 25, 30 |
| https://www.bg-wiki.com/ffxi/Zanshin | 15, 25, 35, 45, 50 (%) |
| https://www.bg-wiki.com/ffxi/Occult_Acumen | 25, 50, 75, 100, 125 |
| https://www.bg-wiki.com/ffxi/Magic_Burst_Bonus | 5, 7, 9, 11, 13 (%) |
| https://www.bg-wiki.com/ffxi/Conserve_TP | 15, 18, 21, 24, 26 (%) |
| https://www.bg-wiki.com/ffxi/Recycle | 10, 20, 30 (%); tiers IV to VII (32 to 38) are the Corsair gifts |
| https://www.bg-wiki.com/ffxi/Damage_Limit%2B | +26/256, +51/256, +77/256, +102/256, +128/256 of pDIF cap |
| https://www.bg-wiki.com/ffxi/WS_Damage_Boost | 7, 10, 13, 16, 19, 21 (%) |
| https://www.bg-wiki.com/ffxi/Tandem_Strike | 10, 20, 30, 40, 50 accuracy and magic accuracy, master and pet on the same enemy |
| https://www.bg-wiki.com/ffxi/Fast_Cast | 10, 15, 20, 25, 30 (%); tiers VI to IX (32 to 38) are the Red Mage gifts |

## Jobs (calc_jobs_fighters.js, calc_jobs_mages.js)

From each job page: skill ranks, level of each trait tier, job point gifts (totals at 2100 job
points), job point categories that feed a stat (20 points), job merits.

| Page | Used as |
|------|---------|
| https://www.bg-wiki.com/ffxi/Warrior | main job |
| https://www.bg-wiki.com/ffxi/Thief | main job |
| https://www.bg-wiki.com/ffxi/Paladin | main job |
| https://www.bg-wiki.com/ffxi/Dark_Knight | main and support job |
| https://www.bg-wiki.com/ffxi/Beastmaster | main job |
| https://www.bg-wiki.com/ffxi/Samurai | main and support job |
| https://www.bg-wiki.com/ffxi/Corsair | main job |
| https://www.bg-wiki.com/ffxi/Dancer | main and support job |
| https://www.bg-wiki.com/ffxi/Rune_Fencer | main job |
| https://www.bg-wiki.com/ffxi/White_Mage | main and support job |
| https://www.bg-wiki.com/ffxi/Black_Mage | main and support job |
| https://www.bg-wiki.com/ffxi/Red_Mage | main job |
| https://www.bg-wiki.com/ffxi/Bard | main job |
| https://www.bg-wiki.com/ffxi/Summoner | main job |
| https://www.bg-wiki.com/ffxi/Geomancer | main job |
| https://www.bg-wiki.com/ffxi/Dragoon | support job: traits only |
| https://www.bg-wiki.com/ffxi/Scholar | support job: traits only |
| https://www.bg-wiki.com/ffxi/Blue_Mage | support job: no trait without set spells |

Not entered yet: MNK, RNG, NIN, PUP as any job; DRG, SCH, BLU as main job (ranks, gifts).
Job traits left out because no stat of stage 1 reads them: resistances, killers, Max HP / MP Boost,
Auto Regen / Refresh, Clear Mind, Conserve MP, Shield Mastery, Shield Def. Bonus, Stalwart Soul,
Tactical Parry, True Shot, Rapid Shot, Elemental Celerity.

## How the pages were read

Through the WebFetch tool, which returns a summary of the page written by a small model, not the
page itself. Tables that matter were asked for row by row, and every number that ends up
disagreeing with the reference was asked a second time with a narrower question. Where two reads
of the same page did not agree, it is listed in DIFFERENCES.md, section E.

---

# atelier/calc, stage 2: sources (physical melee weapon skills)

Every formula, table and constant of `calc_ws_*.js` was read on the BG-Wiki page listed here
(fetched on 2026-10-09, through the same WebFetch tool as stage 1: the sentences were asked for
verbatim, and asked again when an answer was vague). The code carries the address beside each
value. Our own data: `shared/data/weaponskills/*_WS_DATABASE.lua`, turned into `calc_ws_table.js`
by `python scripts/atelier/build_ws_table.py` (generated, never edited by hand).

## Mechanics

| Page | What was taken | File |
|------|----------------|------|
| https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage | WS damage = WS base damage x pDIF; melee base = floor((weapon damage + fSTR + WSC) x fTP); WSC = floor(A x A% + B x B%); every hit computed this way with its own weapon and a pDIF of its own; "FTP replicating WSs share their fTP with each additional attack"; Weapon Skill Damage: gear and gifts additive, first hit only; traits and the weapons' own bonuses on all hits, "Multiplicative with Flooring Between Steps" | calc_ws_base.js, calc_ws_average.js |
| https://www.bg-wiki.com/ffxi/WS_Damage_Boost | the trait "Applies to all hits" and is "Multiplicative with other sources of Weapon Skill Damage listed on gear" | calc_ws_average.js |
| https://www.bg-wiki.com/ffxi/FSTR | dSTR = STR - VIT; fSTR = (dSTR + k) / 4 with k = 4, 6, 7, 8, 9, 10, 12, 13 by range; caps -rank (rank 0: -1) and rank + 8 | calc_ws_base.js |
| https://www.bg-wiki.com/ffxi/Weapon_Rank | floor(damage / 9); hand-to-hand floor((damage + 3) / 9) | calc_ws_base.js |
| https://www.bg-wiki.com/ffxi/PDIF | ratio = attack / defense; critical hit: wRatio = cRatio + 1; upper and lower limit tables; "Randomly select a value between LL and UL", then the weapon cap; caps 3.25 / 3.5 / 3.75 / 4 (+1 critical) by weapon; Physical Damage Limit gear "multiplicative with this limit"; final "random number between 1 and 1.05"; level correction not applied to content after 2013 | calc_ws_pdif.js |
| https://www.bg-wiki.com/ffxi/Damage_Limit%2B | (stage 1) the trait adds to the pDIF cap | calc_ws_pdif.js |
| https://www.bg-wiki.com/ffxi/Hit_Rate | hit rate = 75 + floor((accuracy - evasion) / 2); never under 20%; caps 99% one-handed main hand and hand-to-hand, 95% off-hand and two-handed | calc_ws_hits.js |
| https://www.bg-wiki.com/ffxi/Category:Weapon_Skills | "The first swing of any physical Weapon Skill receives a substantial (~+100) accuracy bonus, while additional swings receive no bonus"; Weapon Skill Accuracy gear counts on every hit | calc_ws_hits.js, calc_ws_average.js |
| https://www.bg-wiki.com/ffxi/Critical_Hit_Rate | rate = base + gear + merits + buffs + weapon skill modifier + dDEX; dDEX table (0 / 1 / 2 / 3 / 4 / dDEX - 35, 15 at most); critical damage = base x critical pDIF x (sum of direct modifiers), +100% at most; only the weapon skills that say so can critically hit | calc_ws_hits.js, calc_ws_average.js |
| https://www.bg-wiki.com/ffxi/Multi-Attack | order Quadruple, Triple, Double, then Occasionally Attacks X Times; 8 hits a round; Occasionally Attacks X Times "May proc on Weapon Skills only when provided by Mythic AM3" | calc_ws_hits.js, calc_ws_average.js |
| https://www.bg-wiki.com/ffxi/Double_Attack | "Can Proc a maximum of 2 times per Weapon Skill. Subject to the 8-hits per round limit"; "each weapon when Dual Wielding" | calc_ws_hits.js |
| https://www.bg-wiki.com/ffxi/Tactical_Points | TP by delay (six ranges), floored; Store TP: floor(base) + floor(base x Store TP / 100); weapon skill: "the first hit (and first Off-Hand hit) will grant full TP while each consecutive attack will grant a flat 10 TP"; dual wield and hand-to-hand delays | calc_ws_tp.js |
| https://www.bg-wiki.com/ffxi/Conserve_TP | proc rate = the Conserve TP value in percent; "a random whole amount of TP between 10 and 200 TP", added to the TP return | calc_ws_tp.js |
| https://www.bg-wiki.com/ffxi/Fotia_Gorget | adds "exactly 25/256" to the weapon skill's fTP (the "ftp" of the sheet) | calc_ws_average.js |
| https://www.bg-wiki.com/ffxi/Naegling | "Savage Blade" damage +15%; attack "+1% per buff effect" during weapon skills | calc_ws_average.js, calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Apocalypse_(Level_119_III) | hidden "Catastrophe damage +40%", rank 15 "Catastrophe: Damage +20%", multiplied together (+68%) | calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Carnwenhan_(Level_119_III) | hidden "Mordant Rime damage +30%", rank 15 "+15%", multiplied together (+49.5%) | calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Epeolatry_(Level_119_III) | rank 15 "Dimidiation: Damage +15%" | calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Idris_(Level_119_III) | rank 15 "Exudation: Damage +15%" | calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Chango | rank 15 "Upheaval: DMG:+10%" | calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Dojikiri_Yasutsuna | rank 15 "Tachi: Shoha: Damage +10%" | calc_ws_details.js |

Read and not used: https://www.bg-wiki.com/ffxi/Aymur_(Level_119_III) (Primal Rend is magical),
https://www.bg-wiki.com/ffxi/Burtgang_(Level_119_III) (Atonement is not in the battery).
Not found: https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage_(Statistic) (404).

## Weapon skills (calc_ws_details.js)

One page per weapon skill, `https://www.bg-wiki.com/ffxi/<name>`, for the 88 physical weapon
skills of the battery: attribute modifiers, fTP at 1000 / 2000 / 3000 TP, number of hits, "This is
an fTP replicating weaponskill", critical hit rate by TP, attack modifier, defense ignored, and
the weapons that raise its damage. The address is in each entry (`url`). What a page marks
"Verification Needed" or leaves blank is kept in the entry (`unverified`, `missing`) and printed by
`node scripts/audit/calc_ws_check.js`.

- Sword: Circle Blade, Fast Blade, Fast Blade II, Requiescat, Savage Blade, Swift Blade, Chant du Cygne, Knights of Round, Death Blossom
- Club: Black Halo, Dagda, Exudation, Hexa Strike, Judgment, Randgrith, Realmrazer, Skullbreaker, True Strike, Mystic Boon
- Staff: Full Swing, Gate of Tartarus, Heavy Swing, Oshala, Retribution, Shattersoul, Shell Crusher
- Axe: Blitz, Bora Axe, Calamity, Decimation, Mistral Axe, Onslaught, Raging Axe, Rampage, Ruinator, Spinning Axe
- Scythe: Catastrophe, Cross Reaper, Entropy, Guillotine, Insurgency, Nightmare Scythe, Origin, Quietus, Slice, Spinning Scythe, Spiral Hell
- Great Sword: Dimidiation, Fimbulvetr, Ground Strike, Hard Slash, Resolution, Shockwave, Sickle Moon, Spinning Slash
- Great Katana: Tachi: Ageha, Enpi, Fudo, Gekko, Kaiten, Kasha, Mumei, Rana, Shoha, Yukikaze
- Great Axe: Armor Break, Disaster, Fell Cleave, Full Break, Iron Tempest, King's Justice, Metatron Torment, Raging Rush, Shield Break, Steel Cyclone, Ukko's Fury, Upheaval, Weapon Break
- Dagger: Evisceration, Exenterator, Mercy Stroke, Mordant Rime, Ruthless Stroke, Viper Bite, Dancing Edge, Mandalic Stab, Shark Bite, Rudra's Storm

Where the page and our database disagree, the page is used: the eight merit weapon skills
(database 73%, page "73~85%", 85% at 5/5 merits, the assumption of stage 1: Entropy, Realmrazer,
Requiescat, Resolution, Ruinator, Shattersoul, Tachi: Shoha, Upheaval) and Spinning Axe (database
2 hits, page "Single-hit attack"). The dagger file of the database has no type, hits or fTP
fields: the generator reads hits and fTP in its `notes`, the type ("Class: Physical") comes from
the page.

Read a second time on 2026-10-09, every line of the infobox and of the notes asked for verbatim:
Ukko's Fury, Raging Rush, Evisceration, Exenterator, Tachi: Shoha, Tachi: Enpi, Raging Axe,
Spinning Axe, Sickle Moon, Hard Slash, Iron Tempest, Mordant Rime, Disaster, Requiescat (Dagda:
the tool refused to quote it; its page still reads "Information Needed"), and, with narrow
questions, https://www.bg-wiki.com/ffxi/Critical_Hit_Rate ("Generally, the base modification at
1000 TP varies from 0% to 40%, and extra Critical Hit Rate is awarded for TP over 1000"; "no cap to
critical hit rate"; nothing on which hits of a weapon skill can be critical) and
https://www.bg-wiki.com/ffxi/PDIF (the limits' conditions are written on wRatio; "If the value is
greater than the cap shown for your weapon type in the list below, set to the cap value"; "1H
qRatio caps at 3.25 for non-crits and 4.25 for crits"; no line adds 1 to pDIF after the limits).
Nothing changed in the table except two "Verification Needed" marks that the first read had
missed (Iron Tempest's attack bonus and Spinning Axe's fTP at 2000 and 3000 TP).

## Measurements in game (2026-10-09)

A third source, above BG-Wiki where the two differ: the per-swing journal
`Tetsouo/logs/fights/2026-10-09_hits.log` (WAR99/SAM56 on Locus Ghost Crab), summarised in
DIFFERENCES.md, "Measured in game", and applied in its section P. In the code:
`// measured in game 2026-10-09:` with the sample size.

| Page read again | What was taken | File |
|-----------------|----------------|------|
| https://www.bg-wiki.com/ffxi/PDIF , "Average Melee pDIF(qRatio)" | "the Spike frequency started at 0.5 wratio and rose linearly to plateau at 33% between 0.75 and 1.25 before finally falling linearly again to 0 at 1.5 wRatio"; "sRatio = (0.5 - abs(wRatio - 1)) * 1.2", "if (sRatio < 0) then sRatio = 0", "if (sRatio > .333) then sRatio = 0.333"; "avgPDIF = sRatio*1.0 + lowCap%*pDIFminCap + highCap%*pDIFmaxCap + (1 - sRatio - lowCap% - highCap%)*(((pDIFmax - pDIFmin) / 2) + pDIFmin)" | calc_ws_pdif.js |

Where the game overrides the page: the TP of a weapon skill's later swings (page "a flat 10 TP",
game floor(10 x (1 + Store TP / 100)), calc_ws_tp.js). Where the page lists an effect without a
rule and the game gave it: "Double Attack" damage (calc_ws_hits.js, for stage 3).

Read for the end-to-end check of 2026-10-09 (DIFFERENCES.md, section Q):
https://www.bg-wiki.com/ffxi/Ukonvasara_(Level_119_III) ("DMG:340 Delay:482 STR+50 ...", rank 15
"DMG: +12 [Ukko's Fury]: Damage +10% STR & DEX +20", aftermath "30% / 40% / 50% Triple Damage":
the +10% is in calc_ws_details.js), https://www.bg-wiki.com/ffxi/Empyrean_Aftermath ("Empyrean
Aftermath cannot proc on Weapon Skills"), https://www.bg-wiki.com/ffxi/Chango (again: aftermath
"Increases skillchain potency Increases magic burst potency"), https://www.bg-wiki.com/ffxi/Upheaval
(again: "Delivers a fourfold attack", fTP 1.0 / 3.5 / 6.5, "73~85% VIT").

---

# atelier/calc, stage 3: sources (the average auto-attack round)

Every formula and constant of `calc_round_*.js` was read on the BG-Wiki page listed here (fetched
on 2026-10-09 with the WebFetch tool) or comes from the measurements of DIFFERENCES.md, "Measured
in game". The tool refuses to copy a whole page: each page was asked narrow, numbered questions
with the answer required as short exact quotes, and asked again when an answer was a paraphrase.
The sentences below are those quotes, as the tool returned them; the code carries the same
sentence beside the value (the multiplication and division signs are written x and /). A direct download of the pages (raw wikitext) was tried and is blocked
by the site (HTTP 403), so no quote here was checked against the page's source by a second route.

## Mechanics

| Page | Quotes taken | File |
|------|--------------|------|
| https://www.bg-wiki.com/ffxi/Multi-Attack | "Each potential proc is checked in sequentially descending order, with the maximum number of attacks per round, from Dual Wielding and multi-attack, are limited to 8 hits." ; "Once a higher order multi-attack proc triggers, that weapon will not be allowed to have a lower order check." ; table of orders: 1st "Virtue Stone Weapons, Raetic Weapons SU 4/5 Follow-up Attack Weapons" "+1" ("Only form of Multi-Attack that is checked more than once."), 2nd "Quadruple Attack" "+3", 3rd "Triple Attack" "+2", 4th "Double Attack" "+1", 5th "Occasionally Attacks X Times" ("May proc on Weapon Skills only when provided by Mythic AM3." "Varying amounts from OA2 to OA8."), 6th "Hasso / Zanshin" "+1" "Rate is (Zanshin Total / 4)%" ; "This is why the low order Mythic Aftermath's chance to triple attack is "overwritten" when a Double Attack proc happens." | calc_round_swings.js |
| https://www.bg-wiki.com/ffxi/Double_Attack | "Cannot Proc off itself." ; "Has a chance to proc on each fist for Hand-to-Hand weapons or each weapon when Dual Wielding." ; "Subject to the 8-hits per round limit." | calc_round_swings.js |
| https://www.bg-wiki.com/ffxi/Triple_Attack | "Cannot Proc off itself." ; "Subject to the 8-hits per round limit." ; "Has a chance to proc on each fist for Hand-to-Hand weapons or each weapon when Dual Wielding." ; gear with "Triple Attack damage" listed, no rule ; "Forced Triple Attacks from Assassin's Charge (Merit Point Ability) are guaranteed to receive the damage and attack bonuses from "Triple Attack" Damage+ equipment and job point ranks." | calc_round_swings.js, calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Quadruple_Attack | "On a proc, allows a melee weapon to attack four times in one attack round." ; "The total attacks per round are subject to the limit of eight, and Quadruple Attack takes priority over Triple Attack, Double Attack, and Occasionally Attacks X Times during the attack quantity check." | calc_round_swings.js |
| https://www.bg-wiki.com/ffxi/Zanshin | "May attack again immediately after missing a target." ; "Zanshin will be able to activate on single-swing attack rounds for 1-handed (including "unarmed") and 2-handed weapons under any of the following conditions:" "Missed melee attack." "Evaded melee attack via shadows (Blink, Utsusemi, Third Eye) or Guard." "Attack Countered." ; "Caps at 100% proc rate (Mastered SAM has 60% proc chance base)" ; "Zanshin hits receive a 34 Accuracy bonus." ; "Zanshin does not work with hand-to-hand or dual wield, but works with single wield." ; "Zanshin on equipment or other bonuses functions without needing the trait." ; "With Hasso, Zanshin appears to proc at 125% of the normal rate (can be modified by gear)." ; "Hasso allows Zanshin to proc as an additional attack, even when the first hit lands." ; "Max additional attack rate is 25% with Zanshin +100." ; "Hasso Zanshins cannot proc on Weapon Skills." ; "Zanshin attacks check for Zanshin: Double Attack first, followed by Zanshin: OAT only if Z:DA check fails." (not used, T8) ; tiers 15 / 25 / 35 / 45 / 50, "SAM99(1805JP)" 60% | calc_round_swings.js, calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Hasso | "Hasso allows Zanshin to proc as an additional attack, even when the first hit lands." ; "The rate is approximately (total normal Zanshin Rate)/4" ; "Only works for SAM main job." ; "Is the last priority in the multi-hit check order." ; "Hasso works only with two-handed weapons." ; "Hasso grants +STR, +10 Accuracy and +10% haste for melee attacks." ; "Hasso's attack speed component is considered as Job Ability Haste, and does not affect the amount of TP gained per hit." (the last two belong to the sheet, not applied here) | calc_round_swings.js |
| https://www.bg-wiki.com/ffxi/Ikishoten | "Increases amount of TP gained with a Zanshin attack." ; "Adds 30 base TP (before Store TP) to Zanshin per merit level." ; "including ones that show up as Double Attacks with Hasso" | calc_round_average.js |
| https://www.bg-wiki.com/ffxi/Samurai | job points "Zanshin Effect": "Increases the physical attack of Zanshin. Increases physical attack by 2." ; merits, group 2 "Ikishoten": "Increases TP gained with Zanshin attack. Increase TP gained by 30." | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Warrior | job point category "Double Attack Effect": "Increases physical attack from double attacks." "Increase physical attack by 1." | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Thief | job point category "Triple Attack Effect": "Increases the physical attack of Triple Attack" "Increase physical attack by 1" | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Kick_Attacks | "Occasionally allows your character an extra attack with a kicking animation." ; "Trait activation rate is increased by 1% per 'Kick attacks +1' on equipment." ; "This trait only activates when using Hand-to-Hand weapons." ; "Kick Attack damage is equal to base Hand-to-Hand damage." ; "The damage can only be improved by wearing specific pieces of armor." ; "fSTR does apply to kick attacks (R0 weapon if you don't have kick damage modifying gear on)" ; tiers 10 / 12 / 14 % (MNK 51 / 71 / 76). Nothing on the TP of a kick. | calc_round_damage.js, calc_round_average.js |
| https://www.bg-wiki.com/ffxi/Hand-to-Hand | "Base Hand-to-Hand damage is calculated simply by multiplying Hand-to-Hand skill by 0.11 and adding 3" ; "The natural base delay of of Hand-to-Hand is 480." (only the first 100 000 characters of the page were read) | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Martial_Arts | "Martial Arts directly affects Delay, so it directly affects TP return." ; "It also counts towards the delay reduction cap, starting from a base of 480 delay." ; "So, even with Haste and Martial Arts, the minimum H2H delay is 96 delay per round." ; tiers 400 / 380 / 360 / 340 / 320 / 300 / 280 / 275 / 270 delay | calc_round_time.js |
| https://www.bg-wiki.com/ffxi/Daken | "When equipped with a shuriken, occasionally throws the shuriken when autoattacking." ; "All Daken+ equipment stacks additively and has no known cap." ; "Gives TP as if you threw your equipped shuriken (based on its delay)." ; "Daken procs receive a ranged accuracy bonus of approximately +100." ; "Damage Type of Daken procs are Piercing, not Ranged." ; tiers 20 / 25 / 30 / 35 / 40 %, gifts to 54% | calc_round_average.js |
| https://www.bg-wiki.com/ffxi/Attack_Speed | "Using a 480-delay weapon (8 seconds per round) with the effect of Haste would change the attack speed to 85% of 480, or 408 (6.8 seconds per round)." ; "(1 - 30% Dual Wield)x(1024 - 256 Equipment Haste - 150 Magic Haste - 101 Job Ability Haste)/1024 = 35.3% Delay remaining" ; "Equipment haste has its own cap of 25% (256/1024)." ; "Magic haste caps at 43.75% (448/1024)." ; "it also caps at 25% (256/1024)." ; "there is a general 80% Delay reduction cap" ; "All types of Delay Reduction fall under this cap, from Sword Strap to Martial Arts to Dual Wield." ; "(480 (Base Delay) +xx (+Weapon Delay) -xx(MA Delay Reduction))x(1024 - xx Equipment Haste - xx Magic Haste - xx Job Ability Haste)/1024" ; "The minimum delay possible for a Spharai (Level 99) would be (480 Base Delay + 86 Weapon Delay)*.2 Delay cap = 113.2 minimum possible delay." ; job ability haste list: "Hasso (10%)", "Catastrophe with Apocalypse iLv119 III (10%)" | calc_round_time.js (and calc_derived.js, stage 1) |
| https://www.bg-wiki.com/ffxi/Dual_Wield | "Reduces the combined delay of these weapons by the Dual Wield % listed above, increasing the frequency of attack rounds." ; "(Delay1 + Delay2) x (1 - Dual Wield %) / 2 = New Delay per Hand" ; "TP/hit is calculated using the above Delay instead of the weapons' listed Delays." ; "While Dual Wielding, both weapons are considered to have the same Delay, even if their listed Delays do not match." ; "(1 - Dual Wield %) x (1 - Haste %) >= 0.2" ; "Dual Wield in excess of the 80% global delay reduction cap will further reduce TP gain per hit without increasing the frequency of attack rounds." | calc_round_time.js, calc_ws_tp.js |
| https://www.bg-wiki.com/ffxi/Tactical_Points | "Players gain TP if they hit a mob for more than 0 damage. The TP gained is based on the modified delay per weapon." ; "During a Multi-Attack proc the TP return of each hit is identical for each consecutive hit, meaning that if you proc a quadruple attack, you will get the TP from 4 hits without modifiers." ; "For Dual Wield, the individual delay of each weapon is calculated with the formula [(Weapon 1 Delay + Weapon 2 Delay) x (1 - Dual Wield %)]/2." ; "For Hand to Hand, the TP gain of each fist is calculated using a delay equal to 1/2 of the total delay including (but not limited to) the Martial Arts trait, equipment, and weapon delay." ; "Unlike 'Haste', the aforementioned factors lower the actual delay of the weapon(s) and the TP gain per hit for the weapon(s) is reduced." ; "Regain: [...] the basic idea is that you gain a certain amount of TP/tick." Nothing on Zanshin, kicks or Daken. | calc_round_average.js (and calc_ws_tp.js, stage 2) |
| https://www.bg-wiki.com/ffxi/Store_TP | "TP/hit = floor( Base TP/hit x (100 + Store TP Total) / 100 )" ; ""Base TP" is the TP per hit after delay reduction (like Dual Wield) and after adding things like Ikishoten." (the same number as Tactical_Points' "floor[Base TP] + floor[Base TP * (Store TP/100)]" when the base is whole) | calc_ws_tp.js (`extraBase`) |
| https://www.bg-wiki.com/ffxi/Regain | "Regain restores TP over time in 3 second intervals (Ticks)." ; lists "Regain +10" (Vim Torque), "10 TP/tick" (Adloquium), "30 TP/tick over 180 seconds, 1,800 total" (Monarch's Drink); no sentence equates "Regain +N" with N TP a tick | calc_round_time.js |
| https://www.bg-wiki.com/ffxi/Critical_Hit_Rate | "Every time players swing at a monster, they have a chance to critical hit." ; "critical hit rate is the sum of the base rate (5%), gear/atma (0-100%), merit points (0-5%), Buffs, Weapon Skill modifiers, and player Dexterity relative to target Agility" ; "As there is no cap to critical hit rate, it can be taken all the way to 100%" ; "Critical Hit Damage = (Base Damage + fSTR) * Critical pDIF * (Sum of Direct Modifiers)" ; "The bonus is capped at +100% maximum total" | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Physical_Damage | "Physical Damage = [Base Damage] * [pDIF]" | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Base_Damage | "Base Damage = D + (aD) + fSTR" (melee) ; "Base Damage = floor((D + (aD) + fSTR + WSC)* fTP)" (weapon skills) ; "Base Damage = floor(D + fSTR) + Total DEX" (Sneak Attack). Nothing on hand-to-hand, kicks, the off-hand or Daken. | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Empyrean_Aftermath | "Every Empyrean gets an 'Occasionally Doubles Damage' aftermath(or 'Occasionally Triples Damage' at ilv119 III), that is currently thought to be the same for all weapons." ; "Unlike Mythics, Aftermath potency is thought to be static regardless of TP and weapon level." ; "Empyrean Aftermath cannot proc on Weapon Skills." ; "Unlike Relics, Empyrean double/triple damage can proc on any additional hits (Double Attack, Triple Attack, Zanshin) initiated by the weapon. It cannot proc on Counters or Retaliations." ; both tables: 1000~1999 TP 30%, 2000~2999 TP 40%, 3000 TP 50% (durations 30 / 60 / 90 s, and 60 / 120 / 180 s at 119 III) | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Mythic_Aftermath | level 3 of "Mythic Aftermath (95~119/III)": "Occasionally attacks twice or thrice", "40% 2x 20% 3x" (level 75: "40%", 80~90: "60%") ; "Mythic Aftermath Level 3 can trigger once on any physical Weapon Skills" ; levels 1 and 2 are accuracy and attack amounts that depend on the TP (not computed) | calc_round_swings.js |
| https://www.bg-wiki.com/ffxi/Apocalypse_(Level_119_III) | "Hidden Effect: Does Double Damage on the first swing of an attack round 20% of the time." ; "Will never activate on hits from Double Attack, Triple Attack, etc." ; "Unlike its predecessors, Aftermath on this version of the weapon gives 10% Job Ability Haste and 15 Accuracy." | calc_round_damage.js |
| https://www.bg-wiki.com/ffxi/Demersal_Degen_%2B1 | "Occasionally attacks twice effect has an activation rate of 45%." (the "OA2" 45 our item catalogue gives the weapon) | input data, not in the code |

Read and not used: https://www.bg-wiki.com/ffxi/Relic_Aftermath (a table of each relic's aftermath;
nothing on the hidden damage effect), https://www.bg-wiki.com/ffxi/Relic_Weapons (nothing on it
either), https://www.bg-wiki.com/ffxi/Blurred_Knife_%2B1 ("Occasionally attacks twice", no rate on
the page: the 45 of our item catalogue is not backed by BG-Wiki for this weapon).

The game overrides or completes the pages in three places, all measured on 2026-10-09 and already
in stage 2's code: every swing of a multi-attack round gives the full TP (M5, the page says the
same), critical hits (M3, M4), "Double Attack" damage on both swings of the round (N2).

## Job abilities (calc_abilities.js, pages fetched on 2026-10-10)

| Page | Quotes taken | File |
|------|--------------|------|
| https://www.bg-wiki.com/ffxi/Berserk | "Raises Attack and Ranged Attack by 25%, lowers Defense by 25%." ; "Attack effect increases by 2% (5/256) at levels 50, 60, 70, 80, and 90 for +35% (89/256) total at level 90." ; "Level Obtained: 15" ; job points "Berserk Effect": "Increase physical attack by 2." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Defender | "Raises Defense by 25% and lowers Attack and Ranged Attack by 25%." ; "Defense effect increases 2% at levels 50, 60, 70, 80, and 90, capping at +35% while the penalty is a static -25%." ; "Level Obtained: 25" ; job points: "Increase physical defense by 3." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Warcry | "Attack Boost % = floor( (Warrior Level / 4) + 4.75 ) / 256" ; "Attack and Ranged Attack bonus given by Warcry varies by level of the Warrior or Warrior Subjob using Warcry." ; "Level Obtained: 35" ; job points "Warcry Effect": "Increase physical attack by 3." ; "Can have an additional TP Bonus effect if you have Merits into Savagery." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Savagery | "Adds 100 TP Bonus to Warcry per merit level." ; "Group 2", "Ranks Available 5" (not counted: DIFFERENCES.md, Y4.1) | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Aggressor | "Raises 25 accuracy and lowers evasion by 25." ; "In the past, Aggressor natively enhanced Ranged Accuracy. However, this effect on Ranged Accuracy was removed." ; "Level Obtained: 45" ; job points "Aggressor Effect": "Increase physical accuracy by 1." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Warrior | Mighty Strikes at level 1 in the ability table ; merit "Aggressive Aim": "Adds ranged accuracy bonus to Aggressor. Increase ranged accuracy bonus by 4." ; merit "Savagery": "Adds TP bonus effect to Warcry. Increase weapon skill TP bonus by 100." (the descriptions the tool gave for the abilities themselves looked reworded and are not used) | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Blood_Rage | "Enhances critical hit rate for party members within area of effect." ; "Grants +20% Critical Hit Rate." ; "Level Obtained: 87" ; job points "Blood Rage Effect": "Increases critical hit rate by 1%." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Mighty_Strikes | "Turns all melee attacks into critical hits." ; "All melee hits will critical." ; "Stacks with any physical Weapon Skill, Jump or similar ability." ; job points "Mighty Strikes Effect": "Increase physical accuracy by 2." ; nothing on ranged attacks, no level on the page | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Focus | "Accuracy = Level + 1" ; "+100 at level 99." ; "Critical hit rate seems to be: (Monk Level + 1) * .2" ; "+20% at level 99." ; "Level Obtained: 25" ; job points "Focus Effect": "Increase accuracy by 1." ; nothing on the support job | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Composure | "Gives floor(((24 x Level) + 74) / 49) Accuracy." ; "50 Accuracy at level 99." ; "Accuracy is further enhanced by 1 per Job Point Composure Effect level for an additional 20 Accuracy (70 Total)." ; "This ability is not accessible if Red Mage is set as a sub job." ; "Level Obtained: 50" | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Last_Resort | "Increases attack by 25% (64/256) and reduces defense by 25% (64/256)." ; "Effect is increased to ~+34.77% (89/256) attack , ~-34.77% (89/256) defense with 5/5 Last Resort Effect Merits." ; "Up to 25% Job Ability Haste can be added to Last Resort through Desperate Blows merits." ; "Base of 15% at level 45." ; "Level Obtained: 15" ; job points "Last Resort Effect": "Increases physical attack by 2." ; nothing on ranged attack or the support job | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Desperate_Blows | "Reduces delay for two-handed weapons while under the effect of Last Resort." ; tiers "DRK15" "5%", "DRK 30" "10%", "DRK 45" "15%" ; "Adds 2% Job Ability Haste per merit level when Last Resort is active." ; "Despite the description this is a job ability based haste, as it does not reduce TP/hit." ; "Stacks with Hasso." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Sharpshot | "Gives a +40 Ranged Accuracy bonus for both main and sub job Ranger." ; "Gives a +40 Ranged Attack in addition with capped Sharpshot category job points for main job Ranger." ; "Level Obtained: 1" ; job points "Sharpshot Effect": "Increase ranged attack by 2." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Hasso | "Hasso works only with two-handed weapons." ; "STR Bonus = Floor(Samurai level / 7)" ; "If used when Samurai is set as a Sub Job, the subbed level is used in the above equation." ; "Hasso grants +STR, +10 Accuracy and +10% haste for melee attacks." ; "Hasso's attack speed component is considered as Job Ability Haste, and does not affect the amount of TP gained per hit." ; "Level Obtained: 25" ; job points "Hasso Effect": "Increase STR by 1." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Hagakure | "Grants "Save TP" effect and a TP bonus to your next weapon skill." ; "Grants 400 Save TP." ; "Grants 1000 TP Bonus." ; "Level Obtained: 95" ; job points: "Increases TP bonus by 10." (a second reading of the page returned none of the three sentences, a third returned them again) | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Attack_Speed , https://www.bg-wiki.com/ffxi/Job_Ability_Haste | "Job Ability Haste: - Caps at 25% (256/1024)" ; "Hasso (10%), Haste Samba (5~10%), Last Resort (15~25%)" ; no value in 1024ths for one ability | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Support_Job | "In most cases, you will receive all spells, traits, and abilities available to your sub job at its level." ; "Some job abilities and spells (such as job-specific SP Abilities) will be subject to restrictions or will be unusable by a sub job." | calc_abilities.js |
| https://www.bg-wiki.com/ffxi/Fan_Dance | "The physical damage reduction effect begins at 90% damage reduction when activated or reapplied" ; "Enmity +15" ; nothing on attack, accuracy, haste, TP or critical hits | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Dancer | Saber Dance and Fan Dance at level 75, merits of group 2 ; merit "Building Flourish Effect": "Increase Building Flourish accuracy by 2, attack power by 1%, and critical hit rating by 1%." | calc_abilities.js (level of Fan Dance) |
| https://www.bg-wiki.com/ffxi/Sentinel | "Sentinel grants a -% Physical Damage Taken for the duration of the ability, starting at -90% and decreasing by -8% every tick, ending at -50%, where it will remain until the effect wears off." ; "Level Obtained: 30" | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Rampart | "Grants all party members within the 13' area of effect -25% SDT." ; "Level Obtained: 62" | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Crusade | "Adds Enmity +30." ; "Paladin" and "Rune Fencer" at "Level 88" | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Palisade | "Increases shield block rate by +30% regardless of skill levels." ; "Level 95" | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Majesty | "Grants +25% Cure Potency II." ; "Grants Cure recast -25%." ; "Level Obtained: 70" | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Reprisal | "Increases chance of blocking with shield, and reflects portion of blocked damage back to attacker." ; "Increases current shield skill by +15%.(1.15x)" ; level "61", "Paladin" | calc_abilities.js (empty effect) |
| https://www.bg-wiki.com/ffxi/Cocoon | "Increases Defense by 50%." ; "Available Level: 8" | calc_abilities.js (empty effect) |

Read and left out of the table (DIFFERENCES.md, Y3):

| Page | Quotes |
|------|--------|
| https://www.bg-wiki.com/ffxi/Brazen_Rush | "The effect begins at 100% double attack rate and diminishes over the duration of the effect." ; level "96", "SP Ability" ; job points: "Increase physical attack by 4." |
| https://www.bg-wiki.com/ffxi/Impetus | "Impetus gives +2 Attack and +1% Critical Hit Rate for each consecutive successful attack." ; "Bonuses cap at +100 Attack and +50% Critical Hit Rate after landing 50 consecutive hits." ; "Resets to 0 upon miss, missed ranged attacks do not count." ; job points: "Increase maximum physical attack by 2." |
| https://www.bg-wiki.com/ffxi/Conspirator | "If 1 person has Enmity, players with Conspirator on will receive a 20 Subtle Blow and 15 Accuracy boost." ; "If 6 people have Enmity, players with Conspirator on will receive a 50 Subtle Blow and 25 Accuracy boost." ; "If 18 people have Enmity, players with Conspirator on will receive a 50 Subtle Blow and 49 Accuracy boost." ; "Does not affect the party member being targeted by the enemy." |
| https://www.bg-wiki.com/ffxi/Innin | "Gives approximately +30% Ninjutsu damage, +30% Critical Hit Rate, and -30 Evasion to start, all of which decay to +-10 over time." ; "These decay by 1 point every 5 ticks." ; job points "Innin Effect": "Increases accuracy by 1." |
| https://www.bg-wiki.com/ffxi/Saber_Dance | "Saber Dance grants 50% Double Attack that decays to 20% in the first 30 seconds (approximately 1%/second)." ; "It then remains at 20% for the rest of its duration." |
| https://www.bg-wiki.com/ffxi/Swordplay | "+3 Accuracy/Evasion upon activation." ; "+3/tick for a player regardless of being main or sub RUN." ; "Caps at +60 Evasion/Accuracy regardless of being main or sub RUN." ; job points: "Increase maximum amounts of accuracy and evasion by 1." |
| https://www.bg-wiki.com/ffxi/Building_Flourish | "Increases the strength of the next weapon skill used." ; "1 Finishing move gives Accuracy+40." ; "2 Finishing moves give Accuracy+40 and Attack+25%." ; "3 Finishing moves give Accuracy+40, Attack+25%, and Critical Hit Rate+10%." ; "With 20 Job Points in the relevant category, Building Flourish also grants 20% Weapon Skill Damage" |

As before, the tool returns a summary with quotes, not the page: a quote was asked a second time
when the first answer paraphrased it, and none was checked against the page's source by another route.

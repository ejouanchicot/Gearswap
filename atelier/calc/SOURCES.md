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

## Read on 2026-10-13 (the DNC session, DIFFERENCES.md section AB)

| Page | What it says | Used in |
|---|---|---|
| https://www.bg-wiki.com/ffxi/Pyrrhic_Kleos | read 2026-10-13: "Delivers a fourfold attack that lowers target's evasion. Duration of effect varies with TP." ; "40% STR / 40% DEX" ; fTP 1.75 ; "This is an fTP replicating weaponskill." ; "Evasion Down effect is -10 Evasion." | calc_ws_details.js |
| https://www.bg-wiki.com/ffxi/Exenterator | read 2026-10-13: "73~85% AGI" ; "73% AGI mod on 1st merit, +3% for 2nd-5th merits. 85% AGI mod at 5/5." ; fTP 1.1875 ; "This is an fTP replicating weaponskill." | calc_ws_details.js (weaponskillWithMerits) |
| https://www.bg-wiki.com/ffxi/Category:Prime_Weapons | read 2026-10-13: five stages, the pages named (Incomplete) = stage 2, (Level 119) = 3, (Level 119 II) = 4, (Level 119 III) = 5 ; "Once a weapon has been upgraded to stage 3 a unique weapon skill becomes available only while in Sortie" ; "Once a weapon has been upgraded to stage 4 you will be able to use the weapon skill anywhere" ; no hidden effect on the weapons' pages | calc_round_damage.js (measured, not from a page) |
| https://www.bg-wiki.com/ffxi/Climactic_Flourish | read 2026-10-13: "Allows you to deal critical hits. Requires at least one finishing move." ; "50% of your CHR (at the time the hit lands)" ; "Works on the first hit of any Weapon Skills (as if it were an attack round)." ; "If stacked with Weapon Skills, only the first hit will be forced to critical." ; "Missed first swings will not count against you." ; job points, 20 ranks: "Increases CHR bonus by 1%" ; critical hit damage: Charis Tiara +1 +10%, +2 +20%, Maculele Tiara +22%, +1 +25%, +2 +28%, +3 +31% ; duration 1:00, recast 1:30 | calc_ws_average.js (CALC.CLIMACTIC), calc_abilities.js |
| https://www.bg-wiki.com/ffxi/WS_Damage_Boost | read 2026-10-13: Dragoon 45 +7%, 55 +10%, 65 +13%, 75 +16%, 85 +19%, 95 +21% ; "Applies to all hits of a weapon skill." (the engine's table, confirmed) | calc_tables.js |

| https://www.bg-wiki.com/ffxi/Maxixi_Attire_Set_%2B3 | read 2026-10-13: "2 pieces = +15 to Accuracy, Ranged Accuracy, and Magic Accuracy", 3 pieces +30, 4 pieces +45, 5 pieces +60 ; "The set bonus is also activated by Regal Accessories from Ou." | calc_sets.js |
| https://www.bg-wiki.com/ffxi/Regal_Ring (and Regal_Earring) | read 2026-10-13: "The set bonus activates with Reforged Artifact Armor +2, +3 and +4 for an additional +15." ; "The set bonus on the ring is not activated with 5/5 AF, but activated with less than 5 AF." | calc_sets.js |

# atelier/calc, stage 4: sources (damaging spells, calc_magic_spells.js and calc_magic.js)

Fetched on 2026-10-17 with the same tool as above (a summary with quotes, not the page; a quote was
asked again when the first answer paraphrased it, the tables were asked as rows of numbers and the
six rows that do not add up were asked a second time). Every table of calc_magic_spells.js is
checked by `node scripts/audit/calc_magic_check.js` (the next row's V must be V + width x M), and
the two worked examples of Magic_Damage are recomputed there (both exact).

| Page | What it says (quotes) | Used in |
|---|---|---|
| https://www.bg-wiki.com/ffxi/Magic_Damage | "Damage Dealt = D × MTDR × Staff × Affinity × Resist × Resistance Rank Reduction × MB × MBB × Day & Weather × MAB/MDB × TMDA × Potency Multipliers" ; "the product is floored to the next lowest integer before continuing" ; "D = mDMG + V + (dINT × M)" ; "reduce the dINT by the amount factored into the V value" ; "For dINT < 0, reduced M values apply." ; "With a negative dINT, calculated value for D will be lower than V, potentially even 0." ; "MTDR = 0.9 - 0.05T" (2 to 10 targets), "MTDR = 0.4" (10 or more) ; staff 1.15 / 1.1 / 0.9 / 0.85, "For all other weapons, Staff = 1.0" ; affinity "also referred to as 'Elemental Magic Attack Bonus'", "Elemental Magic Attack Bonus from gear is additive with this term" (Pixie Hairpin +1 28% and Archon Ring 5% "would make this term = 1.33") ; Orpheus's Sash "a range of 1-15% elemental affinity bonus" ; resist 1 / 0.5 / 0.25 / 0.125 ; rank 50% or lower: an extra forced 1/2 resist ; "MB = 1.25 + (0.1 × X)", "No Magic Burst: MB = 1.0" (X is not defined; the worked example uses 1.3) ; "MBB = 1.0 + Gear + Atma/Atmacite + AMII Merits + Trait" ; "The overall term caps at 1.4 prior to the addition of effects from the Magic Burst Bonus trait" ; day and weather: "Matching day and spell proc: +0.1", "Matching single weather and spell proc: +0.1", "Matching double weather and spell proc: +0.25", the opposed ones -0.1 / -0.1 / -0.25, "The Day & Weather factor cannot exceed 1.4.", "This proc may be forced via wearing an Elemental Obi", helix forces it, no proc chance given ; "cMAB = 1 + (caster Magic Attack Bonus ÷ 100)", "tMDB = 1 + (target Magic Defense Bonus ÷ 100)", "Note that the target's MDB is always floored at 0.5." ; "The base value of TMDA is 1 (256/256)" ; potency: "Ebullience: 1.2 (up to 1.41 with SCH Empyrean head)", "Klimaform bonus (with SCH Empyrean feet): 1.05~1.25", Cumulative Magic 1.05 to 1.25 ; the V / M tables of tiers I to VI, -ga I to III, -ja, Ancient Magic I and II (caps "Verification Needed"), Comet, Helix I (header "ΔINT0-77", "ΔINT78-234", "ΔINT235+", "Verification Needed"), -ra I and II (no cap, unverified) ; "Still need Geo and Helix Spell values" ; worked examples Stone II (1235) and Thundaja (2452); Freeze II uses V 900 at dINT 100 and MB 1.3, older than the page's own tables | calc_magic_spells.js, calc_magic.js |
| https://wiki.ffo.jp/html/674.html (精霊魔法) | 「int(int(int(int(int(int((魔法D値×属性杖)×レジスト)×曜日・天候効果※2)×魔法攻撃力/魔法防御力))×MBボーナス)×魔法ダメージカット※3)」 ; 「魔法D値は、精霊D値＋int(術者と対象のINT差×系統係数※4)＋魔法ダメージ」 ; ※2「曜日、天候、イリデセンス、ソーサラートンバンなどの効果を加算する。40%でキャップする。」 ; ※3「シェル、ルビーの輝き、被魔法ダメージカット装備の効果を加算する。50%でキャップする。」 ; 「int()とはカッコの中身の小数点以下切捨てのことである。」 | calc_magic_spells.js (the dINT part floored), calc_magic.js (TMDA floor 0.5) |
| https://wiki.ffo.jp/html/1083.html (魔法ダメージ) | 精霊魔法: 「floor(精霊・神聖D値＋INT・MND関数)×相乗効果魔法))×属性杖))×アフィニティ))×MBボーナス)×MB.ボーナス特性・装備))」 「×レジスト))×曜日・天候効果)×ガンビット))×魔法攻撃力/魔法防御力))×魔法ダメージカット))」 (the burst terms before the resist, as on BG-Wiki) | calc_magic.js (order) |
| https://wiki.ffo.jp/html/1074.html (マジックバースト) | 「基本値 130%」 ; 「基本値130%に上記の補正を加算して[マジックバースト]倍率が算出される。」 ; 耐性ランク補正 「(+0～150%)」 ; 「計略/メルトンには適用外。」 ; 連携回数補正 「+0～70%」, 「連続して発生した連携ダメージの回数を元にカウントする。」, 1 to 「8以上」: +5 / +15 / +25 / +35 / +45 / +55 / +65 / +70 % ; rank bonuses listed +0 / +5 / +15 / +40 / +60 / +85 / +115 / +150 % (the table came flattened: its rows could not be paired with the ranks) ; MB.ボーナス: 「アフィニティ/曜日/天候効果のように別枠で乗算される。」 ; no number for the magic accuracy bonus of a damage spell | calc_magic.js (BURST_BASE, BURST_CHAIN, no rank bonus for helix) |
| https://wiki.ffo.jp/html/16584.html (系統係数, marked 審議中) | first-row coefficients 精霊I 2.0 / 1.8 / 1.6 / 1.4 / 1.2 / 1.0 (earth to lightning), II 3.0 to 2.0, III 4.0 to 2.5, IV 5.0 to 3.6, V 6.0 to 4.0, ガI to ガIII as II to IV ; ジャ系 (dINT 0 to 100) 5.5 / 5.17 / 4.85 / 4.52 / 4.2 / 3.87 ; コメット 3.87 ; 古代魔法 2.0 ; 計略 1.0 ; 属性遁術壱系 1.0, 参系 1.5 ; 「INT差が0すなわち同値である場合は魔法Ｄ10となる。」 (Stone) ; nothing on negative dINT | cross-check of calc_magic_spells.js: everything agrees with BG-Wiki except 壱 (BG-Wiki 0.5) |
| https://www.bg-wiki.com/ffxi/Magic_Burst | a two-stage skillchain "will result in a 35% increase in magic damage on the magic burst" ; "an additional 10% damage increase on magic bursted spells" for each further stage ; "Magic Burst Damage I (40% cap)": equipment, Atma/Atmacite and merits "caps at +40%" ; "There is currently no known cap to Magic Burst Damage II." ; the trait "exceeds the term cap" ; "The bonus to magic accuracy is speculated to be +100." ("Verification Needed") | calc_magic.js |
| https://www.bg-wiki.com/ffxi/Resist | "The game generates a random number between 0 and 100% and compares it to your Magic Hit Rate." ; "If the game's random number is higher than your Magic Hit Rate, you move up one Resist State" ; 1/1 "Magic Hit Rate", 1/2 "Magic Hit Rate×(1-Magic Hit Rate)", 1/4 "Magic Hit Rate×(1-Magic Hit Rate)^2", 1/8 "(1-Magic Hit Rate)^3" ; rank to magic evasion multiplier 150% 0.95, 130% 0.96019, 115% 0.98, 100% 1, 85% 1.023, 70% 1.049, 60% 1.0905, 50% 1.126, 40% 1.2075, 30% 1.3475, 25% 1.70065, 20% 2.141, 15% 2.65, 10% 5, 5% 10 (the last two "Verification Needed") ; "At rank 10% your hit rate is floored to 5% no matter your magic accuracy." ; "Resistance ranks modify the damage bonus that Magic Bursts give": 150% +150, 130% +115, 115% +85, 100% +60, 85% +50, 70% +40, 60% +15, 50% +5, 40% and below +0 ; "This is additive with the normal damage bonus that magic bursts give: +35% with +10% for each additional skillchain step." ; "performing a Magic Burst with spells that rely on negative status ranks will still grant a Magic Accuracy bonus of +50." | calc_magic.js (resistChances, RANKS) |
| https://www.bg-wiki.com/ffxi/Magic_Hit_Rate | "dMAcc = Caster's Magic Accuracy - Target Magic Evasion" ; "If dMAcc < 0, Magic Hit Rate = 50% + floor( dMAcc÷2 )÷100" ; "If dMAcc ≥ 0, Magic Hit Rate = 50% + dMAcc÷100" ; "Magic Hit Rate, like normal hit rate, is capped at 95%." ; dINT to MAcc: below -70 +0, -70 to -31 0.25 a point, -30 to -11 0.5, -10 to +10 1, +11 to +30 0.5, +31 to +70 0.25, above +70 "+60" (dINT 0 = +30) | calc_magic.js |
| https://www.bg-wiki.com/ffxi/Magic_Accuracy | "Total relevant magic skill (Enfeebling, Elemental, etc.)", "1 Skill = 1 Magic Accuracy" ; "Magic Accuracy Skill from mainhand weapon only", "1 Magic Accuracy Skill = 1 Magic Accuracy" ; "dSTAT is a piecewise function which caps at ±30 Magic Accuracy at ±70 dSTAT." ; "Ninjutsu accuracy is not affected by any dSTAT." | calc_magic.js |
| https://www.bg-wiki.com/ffxi/Magic_Critical_Hit_Rate | "equivalent to Magic Attack Bonus+10 in the magic damage calculation" ; "You can only "Magic Crit" Blue Magic, Divine Magic, and Elemental Magic." ; "Magic critical hit damage caps at +40 magic attack bonus (10 base, and up to +30 from gear/buffs)." ; Magic Critical Hit II: "When Magic Critical Hit II procs, applies a 25% (x1.25) increase to magic damage dealt.", "not affected by Magic Critical Hit Rate I or Magic Critical Hit Damage I" (gear: Sroda Tathlum, Amin Turban) | calc_magic.js (MAGIC_CRIT) |
| https://www.bg-wiki.com/ffxi/Magic_Burst_Bonus | trait +5 / +7 / +9 / +11 / +13 (BLM 45 / 58 / 71 / 84 / 97, SCH 79 / 89 / 99, NIN 80 / 90, RDM 85 / 95) ; "is not subject to the +40% cap from MBB on gear" ; "is additive with the equipment that enhances magic bursts" ; job point category "Increase magic burst damage by 1%." | calc_magic.js (stage 1 already had the tiers) |
| https://www.bg-wiki.com/ffxi/Magic_Burst_Damage_II | redirects to Magic_Burst: "Magic Burst Damage II ([?]% cap)", outside the 40% | calc_magic.js |
| https://www.bg-wiki.com/ffxi/Black_Mage | gifts "Increases magic burst damage by 5%." (80 JP), 5% (360), 6% (910), 7% (1710) ; category "Increase magic burst damage by 1 percent." ; Manawell category "Increase magic damage by 1." ; merits group 2 "Increase Ancient Magic Magic Attack Bonus by 3.", "Increase Ancient Magic magic burst damage by 3%." ; Elemental Magic A+ | calc_magic.js (ancientMerits) |
| https://www.bg-wiki.com/ffxi/Scholar | merit group 1 "Helix Magic Acc./Atk.": "Increase magic accuracy by 3 and magic attack bonus by 2 for Helix spells" ; gifts "Increases magic burst damage by 3%." (145, 500, 1050 JP), 4% (1900) ; Elemental Magic D*, B+ under a grimoire | calc_magic.js ("Helix Magic Accuracy" / "Helix Magic Attack" read from the sheet) |
| https://www.bg-wiki.com/ffxi/Category:Helix | "The Helix deals initial Magic Damage as a regular Elemental Magic spell" ; "This initial damage is repeated every Tock." ; "the DoT effect is capped at 9,999 damage per tock", "the initial damage is uncapped" ; day and weather "100% of the time even without an Elemental Obi" ; Dark Arts "a 24 base damage bonus" at 99 (under testing) ; merits "a total of 10% damage increase for both tiers of Helix" | calc_magic.js (initial hit only, forced day and weather) |
| https://www.bg-wiki.com/ffxi/Pyrohelix_II | "Base Damage Values" / "INT Multipliers": ΔINT 0 75, 0-49 2, 50 175, 50-99 1, 100 225, 100-199 0 ("Information Needed", revision of 7 January 2017) | calc_magic_spells.js (HELIX_2) |
| https://www.bg-wiki.com/ffxi/Pyrohelix | infobox "Base Value" 25, "Multiplier" 1, no table | (agrees with Helix I) |
| https://www.bg-wiki.com/ffxi/Ninjutsu | "Damage Dealt = [V + mDMG + (ΔINT × M)] × Staff × Affinity" then SDT, Resist, MB, MBB, Day & Weather, MAB/MDB, MDT, Misc. ; Ichi V 28 M 0.5 skill 50-250, Ni 69 / 1 / 125-325, San 134 / 1.5 / 275-475 ; potency "(100 + ((Skill − 50) × 0.5)) ÷ 100" (125, 275), "NIN main only", in the Misc. term with Futae and Innin ; "Ninjutsu have a unified V value based on tier levels" ; Futae "to deal 50% more damage" ; merits "Increases Ninjutsu Magic Attack Bonus by 4 per merit level." ; no cap, nothing on negative dINT, nothing outside the skill ranges | calc_magic_spells.js, calc_magic.js (ninjutsuPotency) |
| https://www.bg-wiki.com/ffxi/Katon:_San | infobox "Base Value" 134, "Multiplier" 1.5 | (agrees with Ninjutsu) |
| https://www.bg-wiki.com/ffxi/Impact | infobox "Base Value" 939, "Multiplier" 2.335, no table ; "Each of the target's base stats is reduced by 20% of the value at the time of cast." | calc_magic_spells.js (IMPACT, ASSUMED reading) |
| https://www.bg-wiki.com/ffxi/Comet | ΔINT 0 1000, 0-49 4, 50 1200, 50-99 3.75, 100 1387, 100-199 3.5 (the Magic_Damage table goes on to 2337) ; "Successive use enhances spell potency." | calc_magic_spells.js |
| https://www.bg-wiki.com/ffxi/Orpheus's_Sash | "Increases all elemental attacks by 1-15 based on distance to target" ; "≤1.93' Elemental Affinity = +15", "≥13' Elemental Affinity = +1", nothing in between ("Verification Needed") | calc_magic.js (options.affinity, left to the caller) |
| https://www.bg-wiki.com/ffxi/Hachirin-no-Obi | "Gain full benefit of day and weather bonuses." ; "requires the corresponding day and/or weather to be active" ; day +10%, single weather +10%, single and day +20%, double +25%, double and day +35% | calc_magic.js (an obi forces the proc) |

Read and not used: the -ra tables (no cap), the Freeze II example (older values), Twilight Cape and
Sorcerer's Tonban (+0.05 each, the input does not carry them), Rayke and skillchains lowering a rank,
the consecutive nuke penalty on Notorious Monsters.

## Aftermath of the mage weapons (calc_aftermath.js, read on 2026-10-17)

| Page | What it says | Used in |
|---|---|---|
| https://wiki.ffo.jp/html/15869.html | "TP 1000～1999 Lv1 / 2000～2999 Lv2 / 3000 Lv3" ; "レベルに応じて3つの効果のうちどれか1つが発動する" ; "倍撃はウェポンスキルには乗らない" ; Khatvanga's burst part "「マジックバーストダメージII+」に含まれる" | calc_aftermath.js (level by TP, Khatvanga as Magic Burst Damage II) |
| https://www.bg-wiki.com/ffxi/Laevateinn_(Level_119_III) (and Tupsimati, Idris, Murgleis) | Lv1 Magic Accuracy "Information Needed" ; Lv2 "floor( TP÷50 - 10 ) Magic Attack Bonus" ; Lv3 "Occasionally Attacks twice (40%) or thrice (20%)" | calc_aftermath.js (Lv2; Lv3 counted as nothing for a spell) |
| https://wiki.ffo.jp/html/15178.html | "Lv1アフターマスの魔命上昇値は+30~49、Lv2の魔攻上昇値は+30~49" | calc_aftermath.js (Lv1 Magic Accuracy floor(TP÷50 + 10), only wiki.ffo.jp gives it: to check in game) |
| https://wiki.ffo.jp/html/38965.html | Opashoro stage 4 "LV1で魔攻+10 魔法ダメージ+20 以降TP200で魔攻+1 魔法ダメージ+2 / LV2で魔攻+15 魔法ダメージ+30 以降TP66～67で魔攻+1 魔法ダメージ+2 / LV3で魔攻+30 魔法ダメージ+60" ; stage 5 "LV1で魔攻+15 魔法ダメージ+30 以降TP100で魔攻+1… / LV2で魔攻+25 魔法ダメージ+50 以降TP66～67… / LV3で魔攻+40 魔法ダメージ+80" | calc_aftermath.js |
| https://www.bg-wiki.com/ffxi/Opashoro_(Level_119_III) ; https://www.bg-wiki.com/ffxi/Aftermath | Lv3 "Magic Atk. Bonus +40, Magic Damage +80" ; stage 4 at 3000 TP "+30 MAB, +50 Magic Damage" (wiki.ffo.jp: +60, taken; to check in game) | calc_aftermath.js |
| https://wiki.ffo.jp/html/38963.html ; https://www.bg-wiki.com/ffxi/Aftermath | Lorg Mor "LV1で魔法ダメージ+30 ケアル回復量+30 / LV2で…+50 / LV3で…+80" ; BG: stage 4, "Stage 5: values unknown" | calc_aftermath.js (same values at every stage: to check in game) |
| https://www.bg-wiki.com/ffxi/Aeonic_Aftermath | Lv1 3 % (1000-1499) / 4 % (1500-1999), Lv2 5 % +1 % each 200 TP, Lv3 10 % ; "only applies to the Aeonic Aftermath player" | calc_aftermath.js (Khatvanga) |

Read and not used: the Empyrean aftermaths of Hvergelmir and Gambanteinn (30 / 40 / 50 % triple damage,
melee only), Claustrum (Damage taken -20 %, Refresh) and Mjollnir (Accuracy and Magic Accuracy +20,
Refresh): a weapon outside calc_aftermath.js with an aftermath on still goes to the engine before.

## The party's buffs (calc_buffs.js, read on 2026-10-22)

| Page | What it says | Used in |
|---|---|---|
| https://www.bg-wiki.com/ffxi/BGWiki:SongPotency | "Potency per equipment bonus": Honor March 126 ... 174 /1024, Attack 168 ... 232, Acc. 42 ... 58; Victory March 163 ... 293; Advancing March 108 ... 194; Valor Minuet V 124 ... 223, IV 112 ... 201, III 96 ... 172; Blade Madrigal 60 ... 114; Sword Madrigal 45 ... 85; Etudes 15 ... 24 | calc_buffs.js SONGS |
| https://www.bg-wiki.com/ffxi/March ; Minuet ; Madrigal ; Etude | "Every March +1 given through equipment increases song duration and potency by 10%", "maximum March bonus ... +8", "In the case of Honor March, the maximum bonus is +4"; Minuet +8, Madrigal +9, Etude +9 "and potency by 1" | the caps of SONGS |
| https://www.bg-wiki.com/ffxi/Minuet ; https://www.bg-wiki.com/ffxi/Bard | merits "+5 Attack per Minuet applied after the percentage bonus from +song", job points "+20 Attack per Minuet"; "Soul Voice doubles the potency of this type of song after Merit Point and Job Point bonuses"; Bard's gifts: none on a Minuet | MINUET_MERITS (25) |
| https://www.bg-wiki.com/ffxi/Soul_Voice ; https://www.bg-wiki.com/ffxi/Marcato | "Doubles the effect", "Multiplies by 1.5x the effect" of Minuet, Madrigal, March, Etude...; "Does NOT stack with Soul Voice" | songs() |
| https://www.bg-wiki.com/ffxi/Chaos_Roll (and Samurai, Rogue's, Monk's, Fighter's, Hunter's, Wizard's, Warlock's, Tactician's) | mod1 ... mod11, rollplus, bonus (Chaos "mod2=7.81% (80/1024)", "bonus=9.76% (100/1024)", "rollplus=3.12% (32/1024)") | ROLLS |
| https://www.bg-wiki.com/ffxi/Crooked_Cards | "Phantom roll effect +20%", "Crooked card bonus applies after Roll+ gear and job bonus" | rolls() |
| https://www.bg-wiki.com/ffxi/Indi-Fury (and Haste, Precision, Focus, Acumen, STR..., Frailty, Torpor, Malaise, Languor) | "With 900 skill (maximum potency): +34.7%"; "Idris grants an additional: +27%" (Geomancy +10) | BUBBLES, FOE_BUBBLES |
| https://www.bg-wiki.com/ffxi/Geomancy_Skill | "Geomancy+ items do not affect Entrusted spells." | bubbles() |
| https://www.bg-wiki.com/ffxi/Haste ; Haste_II | "15% Magic haste (150/1024)", "30% Magic haste (307/1024)" | SPELLS |
| https://www.bg-wiki.com/ffxi/Dia ; Dia_II ; Dia_III | "-10.16% defense reduction (-104/1024)", "(-156/1024)", "(-208/1024)"; Light Shot "an additional +2.73% (28/1024)" after a Dia | DIA, LIGHT_SHOT |
| https://www.bg-wiki.com/ffxi/Storm | 5/5 Stormsurge: "+7" of the element's stat, Voidstorm "+3 All Stats" | SPELLS (storms II) |
| https://www.bg-wiki.com/ffxi/Shell_V | "Reduces magic damage taken by -75/256 (-29%)" | SHELL_V |

Read and not used: the songs the page does not offer (Minuets I and II, the lower Etudes, Preludes), Aria
of Passion, Bolster and Blaze of Glory (the page works them out), Madrigal's merits (a trust's Madrigal has
none). What changed against the engine before: DIFFERENCES.md section AF.

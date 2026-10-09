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

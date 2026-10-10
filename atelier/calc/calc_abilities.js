// Atelier calculation engine, stage 1: what the job abilities used on oneself add to the sheet.
//
//   CALC.ABILITIES              name -> {url, job, level, mainOnly, effect(who)}
//       job       the job that has the ability (two jobs for a spell both learn)
//       level     the level it is obtained at; mainOnly: never usable by a support job
//       effect    who = {main, level, wield} -> {stat: amount} with the sheet's names and units,
//                 or null when the case cannot be told from what the sheet knows
//                 who.main   the character's main job has the ability
//                 who.level  99 as main job, else the support job's level (CALC.subJobLevel)
//                 who.wield  CALC.wielding(gearset)
//   CALC.abilityTotals(input)   {totals: {stat: number}, unknown: [names]} for input.abilities
//
// Units, as the sheet reads them: "Attack", "Accuracy", "Ranged Accuracy", "Ranged Attack",
// "Evasion", "STR", "TP Bonus" flat; "Attack%", "Ranged Attack%" and "JA Haste" fractions of 1;
// "Crit Rate" in percent. Every number was read on the BG-Wiki page named beside it (fetched on
// 2026-10-10), the sentence quoted as the page gives it.
//
// Job points belong to the main job, all 20 ranks bought, like the engine's other job point
// categories (DIFFERENCES.md, D5). An ability that only changes enmity, blocking, cures or the
// damage taken has an empty effect: it is known and adds nothing. An ability whose amount depends
// on time, on a count or on merits the input does not give is not in the table: it comes back in
// `unknown` (DIFFERENCES.md, section Y).
//
// @file    atelier/calc/calc_abilities.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var BG = "https://www.bg-wiki.com/ffxi/";
    var MAIN_LEVEL = 99;
    var JOB_POINT_RANKS = 20;
    // entries of the page's `abilities` that are measurements of the character, not abilities
    var NOT_ABILITIES = {"Base Stats": true, "Crit Rate Merits": true};
    // "Warcry (sub)": the support job's version of an ability both jobs could have
    var SUB_SUFFIX = / \(sub\)$/;

    function nothing() { return {}; }

    function jobPoints(who, perRank) { return who.main ? perRank * JOB_POINT_RANKS : 0; }

    var A = CALC.ABILITIES = {};

    function ability(name, page, job, level, effect, mainOnly) {
        A[name] = {url: BG + page, job: job, level: level, mainOnly: !!mainOnly, effect: effect};
    }

    // https://www.bg-wiki.com/ffxi/Berserk
    //   "Raises Attack and Ranged Attack by 25%, lowers Defense by 25%."
    //   "Attack effect increases by 2% (5/256) at levels 50, 60, 70, 80, and 90 for +35% (89/256)
    //   total at level 90." (so 64/256 below level 50)
    //   job points "Berserk Effect": "Increase physical attack by 2."
    // The defense is not on the sheet.
    var BERSERK = {base: 64, step: 5, levels: [50, 60, 70, 80, 90]};
    ability("Berserk", "Berserk", "war", 15, function (who) {
        var share = (BERSERK.base + BERSERK.step * CALC.traitTier(BERSERK.levels, who.level)) / 256;
        return {"Attack%": share, "Ranged Attack%": share, "Attack": jobPoints(who, 2)};
    });

    // https://www.bg-wiki.com/ffxi/Defender
    //   "Raises Defense by 25% and lowers Attack and Ranged Attack by 25%."
    //   "Defense effect increases 2% at levels 50, 60, 70, 80, and 90, capping at +35% while the
    //   penalty is a static -25%."
    //   job points: "Increase physical defense by 3." (defense is not on the sheet)
    ability("Defender", "Defender", "war", 25, function () {
        return {"Attack%": -0.25, "Ranged Attack%": -0.25};
    });

    // https://www.bg-wiki.com/ffxi/Warcry
    //   "Attack Boost % = floor( (Warrior Level / 4) + 4.75 ) / 256"
    //   "Attack and Ranged Attack bonus given by Warcry varies by level of the Warrior or Warrior
    //   Subjob using Warcry."
    //   job points "Warcry Effect": "Increase physical attack by 3."
    //   "Can have an additional TP Bonus effect if you have Merits into Savagery."
    // https://www.bg-wiki.com/ffxi/Savagery   "Adds 100 TP Bonus to Warcry per merit level."
    // ASSUMED: no merit in Savagery (the input does not give the job merits), so no TP Bonus.
    ability("Warcry", "Warcry", "war", 35, function (who) {
        var share = Math.floor(who.level / 4 + 4.75) / 256;
        return {"Attack%": share, "Ranged Attack%": share, "Attack": jobPoints(who, 3)};
    });

    // https://www.bg-wiki.com/ffxi/Aggressor
    //   "Raises 25 accuracy and lowers evasion by 25."
    //   "In the past, Aggressor natively enhanced Ranged Accuracy. However, this effect on Ranged
    //   Accuracy was removed."
    //   job points "Aggressor Effect": "Increase physical accuracy by 1."
    // https://www.bg-wiki.com/ffxi/Warrior   merit "Aggressive Aim": "Adds ranged accuracy bonus
    //   to Aggressor. Increase ranged accuracy bonus by 4."
    // ASSUMED: no merit in Aggressive Aim (the input does not give the job merits).
    ability("Aggressor", "Aggressor", "war", 45, function (who) {
        return {"Accuracy": 25 + jobPoints(who, 1), "Evasion": -25};
    });

    // https://www.bg-wiki.com/ffxi/Blood_Rage
    //   "Enhances critical hit rate for party members within area of effect."
    //   "Grants +20% Critical Hit Rate."
    //   job points "Blood Rage Effect": "Increases critical hit rate by 1%."
    ability("Blood Rage", "Blood_Rage", "war", 87, function (who) {
        return {"Crit Rate": 20 + jobPoints(who, 1)};
    });

    // https://www.bg-wiki.com/ffxi/Mighty_Strikes
    //   "Turns all melee attacks into critical hits." ; "All melee hits will critical."
    //   "Stacks with any physical Weapon Skill, Jump or similar ability."
    //   job points "Mighty Strikes Effect": "Increase physical accuracy by 2."
    // https://www.bg-wiki.com/ffxi/Support_Job   "Some job abilities and spells (such as
    //   job-specific SP Abilities) will be subject to restrictions or will be unusable by a sub job."
    // ASSUMED: +100 to the sheet's rate, which the rounds and the weapon skills that can land
    // critical hits both read; a weapon skill whose page gives no critical hit rate still lands
    // none (the page does not say whether Mighty Strikes changes that).
    ability("Mighty Strikes", "Mighty_Strikes", "war", 1, function (who) {
        return {"Crit Rate": 100, "Accuracy": jobPoints(who, 2)};
    }, true);

    // https://www.bg-wiki.com/ffxi/Focus
    //   "Accuracy = Level + 1" ; "+100 at level 99."
    //   "Critical hit rate seems to be: (Monk Level + 1) * .2" ; "+20% at level 99."
    //   job points "Focus Effect": "Increase accuracy by 1."
    // The page writes "seems to be" for the critical hit rate: its figure is used as it stands.
    // ASSUMED: as a support job the level is the support job's (the page only says "Level").
    ability("Focus", "Focus", "mnk", 25, function (who) {
        return {"Accuracy": who.level + 1 + jobPoints(who, 1), "Crit Rate": (who.level + 1) * 0.2};
    });

    // https://www.bg-wiki.com/ffxi/Composure
    //   "Gives floor(((24 x Level) + 74) / 49) Accuracy." ; "50 Accuracy at level 99."
    //   "Accuracy is further enhanced by 1 per Job Point Composure Effect level for an additional
    //   20 Accuracy (70 Total)."
    //   "This ability is not accessible if Red Mage is set as a sub job."
    ability("Composure", "Composure", "rdm", 50, function (who) {
        return {"Accuracy": Math.floor((24 * who.level + 74) / 49) + jobPoints(who, 1)};
    }, true);

    // https://www.bg-wiki.com/ffxi/Desperate_Blows
    //   "Reduces delay for two-handed weapons while under the effect of Last Resort."
    //   tiers "DRK15" "5%", "DRK 30" "10%", "DRK 45" "15%"
    //   "Adds 2% Job Ability Haste per merit level when Last Resort is active."
    //   "Despite the description this is a job ability based haste, as it does not reduce TP/hit."
    var DESPERATE_BLOWS = {levels: [15, 30, 45], haste: [0.05, 0.10, 0.15]};

    // https://www.bg-wiki.com/ffxi/Last_Resort
    //   "Increases attack by 25% (64/256) and reduces defense by 25% (64/256)."
    //   "Effect is increased to ~+34.77% (89/256) attack , ~-34.77% (89/256) defense with 5/5 Last
    //   Resort Effect Merits."
    //   "Up to 25% Job Ability Haste can be added to Last Resort through Desperate Blows merits."
    //   job points "Last Resort Effect": "Increases physical attack by 2."
    // As main job both the attack and the haste depend on merits the input does not give: no
    // answer (null). As a support job there are no merits, and the trait comes at the support
    // job's level (https://www.bg-wiki.com/ffxi/Support_Job : "you will receive all spells,
    // traits, and abilities available to your sub job at its level").
    // ASSUMED: a percentage of job ability haste is that share of 1 (10% = 0.1; the page gives
    // no value in 1024ths), as for Apocalypse's aftermath (DIFFERENCES.md, T11).
    ability("Last Resort", "Last_Resort", "drk", 15, function (who) {
        if (who.main) return null;
        var tier = CALC.traitTier(DESPERATE_BLOWS.levels, who.level);
        var haste = tier && who.wield.twoHanded ? DESPERATE_BLOWS.haste[tier - 1] : 0;
        return {"Attack%": 64 / 256, "JA Haste": haste};
    });

    // https://www.bg-wiki.com/ffxi/Sharpshot
    //   "Gives a +40 Ranged Accuracy bonus for both main and sub job Ranger."
    //   "Gives a +40 Ranged Attack in addition with capped Sharpshot category job points for main
    //   job Ranger." ; job points "Sharpshot Effect": "Increase ranged attack by 2."
    ability("Sharpshot", "Sharpshot", "rng", 1, function (who) {
        return {"Ranged Accuracy": 40, "Ranged Attack": jobPoints(who, 2)};
    });

    // https://www.bg-wiki.com/ffxi/Hasso
    //   "Hasso works only with two-handed weapons."
    //   "STR Bonus = Floor(Samurai level / 7)" ; "If used when Samurai is set as a Sub Job, the
    //   subbed level is used in the above equation."
    //   "Hasso grants +STR, +10 Accuracy and +10% haste for melee attacks."
    //   "Hasso's attack speed component is considered as Job Ability Haste, and does not affect
    //   the amount of TP gained per hit."
    //   job points "Hasso Effect": "Increase STR by 1."
    // ASSUMED: "+10% haste" is 0.1 of the delay (no value in 1024ths on the page; T11).
    // "Hasso active" is not a game stat: it tells the round that Zanshin follows Hasso's rules
    // (calc_round_swings.js, CALC.zanshinRate and the swing Hasso adds).
    ability("Hasso", "Hasso", "sam", 25, function (who) {
        if (!who.wield.twoHanded) return {};
        return {"STR": Math.floor(who.level / 7) + jobPoints(who, 1), "Accuracy": 10, "JA Haste": 0.1,
            "Hasso active": 1};
    });

    // https://www.bg-wiki.com/ffxi/Hagakure
    //   "Grants "Save TP" effect and a TP bonus to your next weapon skill."
    //   "Grants 400 Save TP." ; "Grants 1000 TP Bonus."
    //   job points: "Increases TP bonus by 10."
    // Save TP (the TP kept after the weapon skill) is not on the sheet: the starting TP of a round
    // is given by the caller.
    ability("Hagakure", "Hagakure", "sam", 95, function (who) {
        return {"TP Bonus": 1000 + jobPoints(who, 10)};
    });

    // Known, and nothing for the sheet: what each does, in the page's words.
    // "The physical damage reduction effect begins at 90% damage reduction when activated or
    // reapplied" ; level 75 on https://www.bg-wiki.com/ffxi/Dancer (a merit ability)
    ability("Fan Dance", "Fan_Dance", "dnc", 75, nothing, true);
    // "Sentinel grants a -% Physical Damage Taken for the duration of the ability, starting at -90%"
    ability("Sentinel", "Sentinel", "pld", 30, nothing);
    // "Grants all party members within the 13' area of effect -25% SDT."
    ability("Rampart", "Rampart", "pld", 62, nothing);
    // "Adds Enmity +30." ; learned by "Paladin" and "Rune Fencer" at "Level 88"
    ability("Crusade", "Crusade", ["pld", "run"], 88, nothing);
    // "Increases shield block rate by +30% regardless of skill levels."
    ability("Palisade", "Palisade", "pld", 95, nothing);
    // "Grants +25% Cure Potency II." ; "Grants Cure recast -25%."
    ability("Majesty", "Majesty", "pld", 70, nothing);
    // "Increases chance of blocking with shield, and reflects portion of blocked damage back to
    // attacker."
    ability("Reprisal", "Reprisal", "pld", 61, nothing);
    // "Increases Defense by 50%." (defense is not on the sheet) ; "Available Level: 8"
    ability("Cocoon", "Cocoon", "blu", 8, nothing);

    // Who uses the ability: the main job when it has it and the name does not say "(sub)", else
    // the support job; null when neither job can have it at its level.
    function whoOf(input, name, entry, wield) {
        var jobs = [].concat(entry.job);
        var main = !SUB_SUFFIX.test(name) && jobs.indexOf(input.job) >= 0;
        if (!main && jobs.indexOf(input.sub) < 0) return null;
        var level = main ? MAIN_LEVEL : CALC.subJobLevel(input.ml);
        if (level < entry.level || (!main && entry.mainOnly)) return null;
        return {main: main, level: level, wield: wield};
    }

    CALC.abilityTotals = function (input) {
        var abilities = input.abilities || {}, wield = CALC.wielding(input.gearset);
        var totals = {}, unknown = [];
        Object.keys(abilities).sort().forEach(function (name) {
            if (NOT_ABILITIES[name] || !abilities[name]) return;
            var entry = A[name.replace(SUB_SUFFIX, "")];
            var who = entry ? whoOf(input, name, entry, wield) : null;
            var gives = who ? entry.effect(who) : null;
            if (!gives) { unknown.push(name); return; }
            Object.keys(gives).forEach(function (stat) { totals[stat] = (totals[stat] || 0) + gives[stat]; });
        });
        return {totals: totals, unknown: unknown};
    };
});

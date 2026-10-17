// Atelier calculation engine, stage 4 (magic): the average damage of one damaging spell.
//
//   CALC.spellDamage(stats, enemy, spellName, options, context)
//       stats    the character sheet (CALC.characterStats, or any table with the same names)
//       enemy    {INT, "Magic Evasion", "Magic Defense" (its Magic Defense Bonus), "Magic Damage Taken"}
//                ("Magic Damage Taken" in percent, negative when the enemy takes less)
//       options  all optional:
//           magicBurst   true for a Magic Burst
//           chainCount   skillchains in a row behind the burst (wiki.ffo.jp "renkei kaisu"), 1 = the first
//                        skillchain, i.e. BG-Wiki's "two-stage skillchain"
//           resistRank   the enemy's resistance rank to the spell's element, 1 = "100%"
//           targets      enemies hit by an area spell (-ga, -ja)
//           day          1 matching day, -1 opposed day, 0 none
//           weather      1 / 2 matching single / double weather, -1 / -2 opposed, 0 none
//           dayWeatherProc  chance that day and weather apply (forced by an obi and by helix)
//           staff        the elemental staff term (1.15, 1.1, 0.9, 0.85), 1 otherwise
//           affinity     elemental affinity in percent, added to the gear's "<Element> Elemental
//                        Bonus" (Orpheus's Sash: 1 to 15, by distance)
//           ancientMerits  merit levels of BLM in that Ancient Magic II spell (0 to 5)
//           potency      list of the other potency multipliers (Ebullience 1.2, Futae 1.5, Klimaform...)
//       context  optional {job, gearset}: the main job (ninjutsu potency is NIN main only) and the
//                gearset (an obi forces the day and weather proc)
//   returns {damage, unresisted, hitRate, magicAccuracy, resist, parts, spell}, or {error}
//       damage      the average, over the resist states and the magic critical hits
//       unresisted  the damage when nothing is resisted and no magic critical hit happens
//   CALC.MAGIC_ASSUME  what is taken when neither the input nor a page says
//
// Order of the multipliers, each product floored before the next one
// (https://www.bg-wiki.com/ffxi/Magic_Damage): D x MTDR x Staff x Affinity x Resist x Resistance
// Rank Reduction x MB x MBB x Day & Weather x MAB/MDB x TMDA x Potency.
//
// @file    atelier/calc/calc_magic.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // ASSUMED values (DIFFERENCES.md, stage 4, section AD)
    CALC.MAGIC_ASSUME = {
        // the chart's "100%" row, where the magic evasion multiplier is 1 (https://www.bg-wiki.com/ffxi/Resist)
        resistRank: 1,
        // a burst behind one skillchain
        chainCount: 1,
        // "The bonus to magic accuracy is speculated to be +100." (https://www.bg-wiki.com/ffxi/Magic_Burst,
        // "Verification Needed"); wiki.ffo.jp 1074 gives no number for damage spells
        burstMagicAccuracy: 100,
        // no page gives the chance of a day or weather proc without an obi: none counted
        dayWeatherProc: 0
    };

    // https://www.bg-wiki.com/ffxi/Magic_Hit_Rate : dINT to magic accuracy, +1 a point from -10 to +10,
    // 0.5 to +-30, 0.25 to +-70, nothing beyond ("+0" below -70, "+60" above +70 on a scale where
    // dINT 0 is +30); https://www.bg-wiki.com/ffxi/Magic_Accuracy : "caps at +-30 Magic Accuracy at
    // +-70 dSTAT", "Ninjutsu accuracy is not affected by any dSTAT". No rounding given: unrounded.
    CALC.dIntMagicAccuracy = function (dINT) {
        var d = Math.min(Math.abs(dINT), 70);
        var gain = Math.min(d, 10) + Math.max(0, Math.min(d, 30) - 10) * 0.5 + Math.max(0, d - 30) * 0.25;
        return dINT < 0 ? -gain : gain;
    };

    // https://www.bg-wiki.com/ffxi/Magic_Hit_Rate
    //   "If dMAcc < 0, Magic Hit Rate = 50% + floor( dMAcc/2 )/100"
    //   "If dMAcc >= 0, Magic Hit Rate = 50% + dMAcc/100"
    //   "Magic Hit Rate, like normal hit rate, is capped at 95%." No lower limit on the page except
    //   rank 10% ("floored to 5%"): the rate stops at 0.
    CALC.MAGIC_HIT_CAP = 0.95;

    CALC.magicHitRate = function (magicAccuracy, magicEvasion) {
        var d = magicAccuracy - magicEvasion;
        var rate = d < 0 ? 0.5 + Math.floor(d / 2) / 100 : 0.5 + d / 100;
        return Math.max(0, Math.min(rate, CALC.MAGIC_HIT_CAP));
    };

    // https://www.bg-wiki.com/ffxi/Resist : each roll above the hit rate moves one resist state down;
    // 1/1 "Magic Hit Rate", 1/2 "Magic Hit Rate x (1-Magic Hit Rate)", 1/4 "Magic Hit
    // Rate x (1-Magic Hit Rate)^2", 1/8 "(1-Magic Hit Rate)^3"
    CALC.RESIST_STATES = [1, 0.5, 0.25, 0.125];

    CALC.resistChances = function (rate) {
        var miss = 1 - rate;
        return [rate, rate * miss, rate * miss * miss, miss * miss * miss];
    };

    // https://www.bg-wiki.com/ffxi/Resist : rank -> magic evasion multiplier, and -> Magic Burst bonus
    // ("Resistance ranks modify the damage bonus that Magic Bursts give"). 10% and 5%: "Verification
    // Needed". wiki.ffo.jp 1074 gives the same bonus values except that it lists no +50%.
    var RANKS = [
        [1.5, 0.95, 1.5], [1.3, 0.96019, 1.15], [1.15, 0.98, 0.85], [1, 1, 0.6], [0.85, 1.023, 0.5],
        [0.7, 1.049, 0.4], [0.6, 1.0905, 0.15], [0.5, 1.126, 0.05], [0.4, 1.2075, 0], [0.3, 1.3475, 0],
        [0.25, 1.70065, 0], [0.2, 2.141, 0], [0.15, 2.65, 0], [0.1, 5, 0], [0.05, 10, 0]];

    function rankRow(rank) {
        for (var i = 0; i < RANKS.length; i += 1) if (rank >= RANKS[i][0] - 1e-9) return RANKS[i];
        return RANKS[RANKS.length - 1];
    }

    // Magic Burst multiplier, wiki.ffo.jp 1074 (Magic Burst page): base value 130 %, plus the
    // skillchain count bonus +5 / +15 / +25 / +35 / +45 / +55 / +65 / +70 % for 1 to 8 ("8 or more")
    // skillchains in a row, plus the rank's bonus, which does not apply to helix and Meltdown (the
    // Japanese quotes are in SOURCES.md, stage 4). BG-Wiki Magic_Burst: two-stage "35%", "+10%" a
    // stage, and the rank bonus "additive with the normal damage bonus". The two agree.
    CALC.BURST_BASE = 1.3;
    CALC.BURST_CHAIN = [0.05, 0.15, 0.25, 0.35, 0.45, 0.55, 0.65, 0.7];

    function burstTerm(spell, options) {
        var count = Math.max(1, Math.min(options.chainCount, CALC.BURST_CHAIN.length));
        var rankBonus = spell.helix ? 0 : rankRow(options.resistRank)[2];
        return CALC.BURST_BASE + CALC.BURST_CHAIN[count - 1] + rankBonus;
    }

    // https://www.bg-wiki.com/ffxi/Magic_Damage : "MBB = 1.0 + Gear + Atma/Atmacite + AMII Merits +
    // Trait", "caps at 1.4 prior to the addition of effects from the Magic Burst Bonus trait";
    // https://www.bg-wiki.com/ffxi/Magic_Burst : Magic Burst Damage II "no known cap", outside the 40%.
    // "Magic Burst Damage Trait" of the sheet holds the trait and the BLM / SCH job point gifts and
    // category (calc_jobs_mages.js); ASSUMED that those sit with the trait, outside the cap (the
    // pages only say "Increases magic burst damage").
    CALC.BURST_GEAR_CAP = 40;

    function burstBonusTerm(stats, spell, options) {
        var merits = spell.family === "ancientII" ? 3 * options.ancientMerits : 0;
        var gear = (stats["Magic Burst Damage"] || 0) + merits;
        return 1 + (Math.min(gear, CALC.BURST_GEAR_CAP) + (stats["Magic Burst Damage II"] || 0) +
            (stats["Magic Burst Damage Trait"] || 0)) / 100;
    }

    // https://www.bg-wiki.com/ffxi/Magic_Damage : MTDR 1 for one target, "0.9 - 0.05T" for 2 to 10,
    // "0.4" for 10 or more
    function targetsTerm(spell, targets) {
        if (!spell.area || targets <= 1) return 1;
        return targets >= 10 ? 0.4 : 0.9 - 0.05 * targets;
    }

    // https://www.bg-wiki.com/ffxi/Magic_Damage : day +-0.1, single weather +-0.1, double +-0.25,
    // "cannot exceed 1.4"; "This proc may be forced via wearing an Elemental Obi", Helix spells force
    // it; https://www.bg-wiki.com/ffxi/Hachirin-no-Obi "Gain full benefit of day and weather bonuses"
    var WEATHER = {"2": 0.25, "1": 0.1, "0": 0, "-1": -0.1, "-2": -0.25};

    function dayWeatherTerm(options) {
        var value = 1 + 0.1 * (options.day || 0) + (WEATHER[String(options.weather || 0)] || 0);
        return Math.min(value, 1.4);
    }

    function wearsObi(gearset) {
        var waist = (gearset && gearset.waist && gearset.waist.Name) || "";
        return waist === "Hachirin-no-Obi" || / Obi$/.test(waist);
    }

    // https://www.bg-wiki.com/ffxi/Ninjutsu : "(100 + ((Skill - 50) x 0.5)) / 100" for Ichi (125 Ni,
    // 275 San), "NIN main only". Skill ranges 50-250 / 125-325 / 275-475; ASSUMED the skill is held
    // inside its range (the page does not say what happens outside).
    function ninjutsuPotency(stats, spell, job) {
        if (spell.skill !== "Ninjutsu" || job !== "nin") return 1;
        var range = spell.skillRange;
        var skill = Math.max(range[0], Math.min(stats["Ninjutsu Skill"] || 0, range[1]));
        return (100 + (skill - range[0]) * 0.5) / 100;
    }

    // https://www.bg-wiki.com/ffxi/Magic_Critical_Hit_Rate : a magic critical hit is "equivalent to
    // Magic Attack Bonus+10", "caps at +40 magic attack bonus (10 base, and up to +30 from gear/buffs)";
    // Magic Critical Hit II "applies a 25% (x1.25) increase", "not affected by Magic Critical Hit Rate I";
    // both for Elemental Magic (not ninjutsu: "Blue Magic, Divine Magic, and Elemental Magic").
    // ASSUMED: Magic Critical Hit II is applied with the potency multipliers, last.
    CALC.MAGIC_CRIT = {mab: 10, extraCap: 30, twoMultiplier: 1.25};

    function critChances(stats, spell) {
        if (spell.skill !== "Elemental Magic") return {one: 0, two: 0, mab: 0};
        var extra = Math.min(stats["Magic Crit Damage"] || 0, CALC.MAGIC_CRIT.extraCap);
        return {one: Math.min((stats["Magic Crit Rate"] || 0) / 100, 1),
            two: Math.min((stats["Magic Crit Rate II"] || 0) / 100, 1), mab: CALC.MAGIC_CRIT.mab + extra};
    }

    // https://www.bg-wiki.com/ffxi/Magic_Accuracy : skill 1:1, "Magic Accuracy Skill from mainhand weapon
    // only" 1:1, magic accuracy from gear and abilities, dSTAT. SCH merit "Helix Magic Acc./Atk.":
    // "Increase magic accuracy by 3 and magic attack bonus by 2 for Helix spells"
    // (https://www.bg-wiki.com/ffxi/Scholar), read from "Helix Magic Accuracy" / "Helix Magic Attack".
    function magicAccuracy(stats, enemy, spell, options) {
        var total = (stats[spell.skill + " Skill"] || 0) + (stats["main Magic Accuracy Skill"] || 0) +
            (stats["Magic Accuracy"] || 0);
        if (spell.skill !== "Ninjutsu") total += CALC.dIntMagicAccuracy((stats.INT || 0) - (enemy.INT || 0));
        if (spell.helix) total += stats["Helix Magic Accuracy"] || 0;
        if (options.magicBurst) total += CALC.MAGIC_ASSUME.burstMagicAccuracy;
        return total;
    }

    function magicAttack(stats, spell, options) {
        var mab = stats["Magic Attack"] || 0;
        if (spell.helix) mab += stats["Helix Magic Attack"] || 0;
        // https://www.bg-wiki.com/ffxi/Black_Mage merits (group 2, the Ancient Magic II spells): "Increase
        // Ancient Magic Magic Attack Bonus by 3." and "Increase Ancient Magic magic burst damage by 3%."
        if (spell.family === "ancientII") mab += 3 * options.ancientMerits;
        return mab;
    }

    function withDefaults(options, spell, gearset) {
        var o = Object.assign({magicBurst: false, chainCount: CALC.MAGIC_ASSUME.chainCount,
            resistRank: CALC.MAGIC_ASSUME.resistRank, targets: 1, day: 0, weather: 0, staff: 1, affinity: 0,
            ancientMerits: 0, potency: []}, options || {});
        if (typeof o.dayWeatherProc !== "number") {
            o.dayWeatherProc = spell.helix || wearsObi(gearset) ? 1 : CALC.MAGIC_ASSUME.dayWeatherProc;
        }
        return o;
    }

    // the terms that do not change with the dice
    function fixedParts(stats, enemy, spell, o, job) {
        var dINT = (stats.INT || 0) - (enemy.INT || 0);
        var rank = rankRow(o.resistRank);
        var mdb = Math.max(0.5, 1 + (enemy["Magic Defense"] || 0) / 100);
        return {
            dINT: dINT,
            D: (stats["Magic Damage"] || 0) + CALC.spellBase(spell, dINT),
            mtdr: targetsTerm(spell, o.targets),
            staff: o.staff,
            affinity: 1 + ((stats[spell.element + " Elemental Bonus"] || 0) + o.affinity) / 100,
            // https://www.bg-wiki.com/ffxi/Magic_Damage : rank 50% or lower, "an extra forced 1/2 resist"
            rankReduction: o.resistRank <= 0.5 + 1e-9 ? 0.5 : 1,
            mb: o.magicBurst ? burstTerm(spell, o) : 1,
            mbb: o.magicBurst ? burstBonusTerm(stats, spell, o) : 1,
            dayWeather: dayWeatherTerm(o),
            mab: magicAttack(stats, spell, o),
            mdb: mdb,
            // "The base value of TMDA is 1"; wiki.ffo.jp 674: magic damage cut "caps at 50%"
            tmda: Math.max(0.5, 1 + (enemy["Magic Damage Taken"] || 0) / 100),
            potency: [ninjutsuPotency(stats, spell, job)].concat(o.potency),
            meva: (enemy["Magic Evasion"] || 0) * rank[1]
        };
    }

    // one outcome of the dice, floored step by step
    function chain(p, resist, dayWeather, critMab, critTwo) {
        var steps = [p.mtdr, p.staff, p.affinity, resist, p.rankReduction, p.mb, p.mbb, dayWeather,
            (1 + (p.mab + critMab) / 100) / p.mdb, p.tmda];
        steps = steps.concat(p.potency, critTwo ? [CALC.MAGIC_CRIT.twoMultiplier] : []);
        return steps.reduce(function (value, factor) { return Math.floor(value * factor); }, p.D);
    }

    function average(p, chances, crit, o) {
        var total = 0;
        var dayWeathers = [[p.dayWeather, o.dayWeatherProc], [1, 1 - o.dayWeatherProc]];
        var critOnes = [[crit.mab, crit.one], [0, 1 - crit.one]];
        var critTwos = [[true, crit.two], [false, 1 - crit.two]];
        CALC.RESIST_STATES.forEach(function (resist, i) {
            dayWeathers.forEach(function (dw) {
                critOnes.forEach(function (c1) {
                    critTwos.forEach(function (c2) {
                        var weight = chances[i] * dw[1] * c1[1] * c2[1];
                        if (weight > 0) total += weight * chain(p, resist, dw[0], c1[0], c2[0]);
                    });
                });
            });
        });
        return total;
    }

    CALC.spellDamage = function (stats, enemy, spellName, options, context) {
        var spell = CALC.SPELLS[spellName];
        if (!spell) return {error: "unknown spell " + spellName};
        var job = (context && context.job) || null;
        var o = withDefaults(options, spell, context && context.gearset);
        var p = fixedParts(stats, enemy || {}, spell, o, job);
        var macc = magicAccuracy(stats, enemy || {}, spell, o);
        var rate = CALC.magicHitRate(macc, p.meva);
        var chances = CALC.resistChances(rate);
        var crit = critChances(stats, spell);
        return {
            damage: average(p, chances, crit, o),
            unresisted: chain(p, 1, o.dayWeatherProc >= 1 ? p.dayWeather : 1, 0, false),
            hitRate: rate,
            magicAccuracy: macc,
            resist: {states: CALC.RESIST_STATES.slice(), chances: chances,
                expectation: chances.reduce(function (s, c, i) { return s + c * CALC.RESIST_STATES[i]; }, 0)},
            parts: p,
            spell: spell
        };
    };
});

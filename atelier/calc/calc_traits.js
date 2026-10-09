// Atelier calculation engine, stage 1: job traits, job point gifts, job point categories and job
// merits turned into stats.
//
//   CALC.traitValues(job, sub, ml)          trait name -> {tier, value}, best of main and support job
//   CALC.jobBonuses(job, sub, ml, assume)   stat -> amount, everything the two jobs give without gear
//
// A trait both jobs know is counted once, at its better tier: the support job has "all spells,
// traits, and abilities available to your sub job at its level"
// (https://www.bg-wiki.com/ffxi/Support_Job). Gifts, job point categories and merits belong to
// the main job only. The tables are in calc_tables.js and calc_jobs_*.js with their pages.
//
// @file    atelier/calc/calc_traits.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // the stats a trait raises by its tier value
    var TRAIT_STATS = {
        "Attack Bonus": ["Attack", "Ranged Attack"],
        "Accuracy Bonus": ["Accuracy", "Ranged Accuracy"],
        "Evasion Bonus": ["Evasion"],
        "Magic Attack Bonus": ["Magic Attack"],
        "Magic Defense Bonus": ["Magic Defense"],
        "Double Attack": ["DA"],
        "Triple Attack": ["TA"],
        "Dual Wield": ["Dual Wield"],
        "Subtle Blow": ["Subtle Blow"],
        "Skillchain Bonus": ["Skillchain Bonus"],
        "Crit. Atk. Bonus": ["Crit Damage"],
        "Store TP": ["Store TP"],
        "Zanshin": ["Zanshin"],
        "Occult Acumen": ["Occult Acumen"],
        "Mag. Burst Bonus": ["Magic Burst Damage Trait"],
        "Conserve TP": ["Conserve TP"],
        "Recycle": ["Recycle"],
        "Damage Limit+": ["PDL Trait"],
        "WS Damage Boost": ["Weapon Skill Damage Trait"],
        "Fast Cast": ["Fast Cast"]
    };

    // gifts written for one stat that the game applies to two: "Increases physical and ranged
    // accuracy by N", "Increases physical and ranged attack by N" (text of the gifts on the job
    // pages, e.g. https://www.bg-wiki.com/ffxi/Corsair)
    var GIFT_ALSO = {"Accuracy": ["Ranged Accuracy"], "Attack": ["Ranged Attack"]};

    function add(out, key, amount) {
        if (amount) out[key] = (out[key] || 0) + amount;
    }

    function tierOf(job, trait, level) {
        var data = CALC.JOBS[job];
        return data ? CALC.traitTier(data.traits[trait], level) : 0;
    }

    CALC.traitValues = function (job, sub, ml) {
        var subLevel = CALC.subJobLevel(ml), out = {};
        Object.keys(CALC.TRAIT_TIERS).concat(["Fencer"]).forEach(function (trait) {
            var tier = Math.max(tierOf(job, trait, 99), tierOf(sub, trait, subLevel));
            if (!tier) return;
            var values = CALC.TRAIT_TIERS[trait];
            out[trait] = {tier: tier, value: values ? values[Math.min(tier, values.length) - 1] : 0};
        });
        return out;
    };

    function addTraits(out, traits, assume) {
        Object.keys(traits).forEach(function (trait) {
            (TRAIT_STATS[trait] || []).forEach(function (stat) { add(out, stat, traits[trait].value); });
        });
        // ranks, read later with the weapons held (calc_stats.js)
        if (traits["Smite"]) add(out, "Smite", traits["Smite"].tier);
        if (traits["Fencer"]) add(out, "Fencer", traits["Fencer"].tier);
        // Tandem Strike: "only applied when attacking the same enemy as your pet"
        if (traits["Tandem Strike"] && assume.petOnTarget) {
            add(out, "Accuracy", traits["Tandem Strike"].value);
            add(out, "Magic Accuracy", traits["Tandem Strike"].value);
        }
    }

    function addTable(out, table, also) {
        Object.keys(table || {}).forEach(function (stat) {
            add(out, stat, table[stat]);
            ((also && also[stat]) || []).forEach(function (other) { add(out, other, table[stat]); });
        });
    }

    CALC.jobBonuses = function (job, sub, ml, assume) {
        var out = {}, data = CALC.JOBS[job] || {};
        addTraits(out, CALC.traitValues(job, sub, ml), assume);
        addTable(out, data.gifts, GIFT_ALSO);
        addTable(out, data.points);
        addTable(out, data.merits);
        if (assume.behindTarget) addTable(out, data.behind);
        return out;
    };
});

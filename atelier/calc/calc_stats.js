// Atelier calculation engine, stage 1: the character sheet. One entry point.
//
//   CALC.characterStats(input)   input = {job, sub, ml, gearset, buffs, abilities}
//                                returns stat name -> number, with the names the page reads
//   CALC.ASSUME                  what is taken as true when the input does not say
//
// Order: skills and attributes of the jobs, traits / gifts / merits, gear, buffs, then what
// depends on the weapons held (Dual Wield, Smite, Fencer...), then the derived stats.
// The stats named like the gear ("Accuracy", "Attack", "Store TP"...) are plain totals;
// "Accuracy1", "Attack1" (main hand), "Accuracy2", "Attack2" (off-hand), "Evasion" and
// "Delay Reduction" are the finished values.
//
// @file    atelier/calc/calc_stats.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // Bonuses that need a situation the input does not describe. Both are how the job is played:
    // the Beastmaster's pet fights the same enemy (Tandem Strike), the Thief stands behind (Ambush).
    CALC.ASSUME = {petOnTarget: true, behindTarget: true};

    // always on the sheet, even at zero
    var ALWAYS = ["Accuracy", "Ranged Accuracy", "Attack", "Ranged Attack", "Dual Wield", "Evasion", "True Shot",
        "Crit Rate", "Magic Attack", "Magic Evasion", "Magic Accuracy", "Magic Defense", "Magic Damage",
        "Parrying Skill", "main Magic Accuracy Skill", "Gear Haste", "JA Haste", "Magic Haste",
        "Weapon Skill Damage", "Store TP", "TP Bonus", "DA", "TA", "QA", "Daken", "Kick Attacks", "Kick DMG",
        "Martial Arts", "Zanshin", "Attack%", "Ranged Attack%"];

    function addAll(stats, table) {
        Object.keys(table || {}).forEach(function (key) { stats[key] = (stats[key] || 0) + table[key]; });
    }

    function startSheet(input) {
        var stats = {}, base = CALC.baseAttributes(input.job, input.sub, input.ml);
        ALWAYS.forEach(function (key) { stats[key] = 0; });
        addAll(stats, base || {STR: 0, DEX: 0, VIT: 0, AGI: 0, INT: 0, MND: 0, CHR: 0});
        addAll(stats, CALC.baseSkills(input.job, input.ml));
        addAll(stats, CALC.jobBonuses(input.job, input.sub, input.ml, CALC.ASSUME));
        // base rate 5% and the merit points: https://www.bg-wiki.com/ffxi/Critical_Hit_Rate
        stats["Crit Rate"] += CALC.BASE_CRIT_RATE + CALC.COMMON_MERITS.critRate;
        return stats;
    }

    // Fencer: TP Bonus and critical hit rate "when wielding with the main hand only"; the job point
    // gifts of WAR and BST add TP Bonus to it. https://www.bg-wiki.com/ffxi/Fencer
    function applyFencer(stats, wield) {
        var rank = Math.min(stats["Fencer"] || 0, CALC.FENCER.tpBonus.length);
        if (!rank || !wield.oneHandedAlone) return;
        stats["Crit Rate"] += CALC.FENCER.critRate[rank - 1];
        stats["TP Bonus"] += CALC.FENCER.tpBonus[rank - 1] + (stats["Fencer TP Bonus"] || 0);
    }

    function applyWielding(stats, wield, traits) {
        // Dual Wield: "the mechanics only apply when dual wielding two weapons"
        // https://www.bg-wiki.com/ffxi/Dual_Wield
        if (!wield.dualWield) stats["Dual Wield"] = 0;
        // Martial Arts lowers the hand-to-hand base delay only: https://www.bg-wiki.com/ffxi/Attack_Speed
        if (!wield.handToHand) stats["Martial Arts"] = 0;
        // Smite: "physical attacks when equipped with a hand-to-hand or two-handed weapon"
        // https://www.bg-wiki.com/ffxi/Smite
        if (traits["Smite"] && (wield.twoHanded || wield.handToHand)) stats["Attack%"] += traits["Smite"].value;
        applyFencer(stats, wield);
        // our own reading rule, not a game formula: nothing that can be shot or thrown (a ranged
        // weapon, or ammunition that is thrown), no ranged totals on the sheet
        if (!wield.canShoot) { stats["Ranged Accuracy"] = 0; stats["Ranged Attack"] = 0; }
    }

    function weaponSheet(stats, wield, gearset) {
        var w = CALC.weaponNumbers(gearset);
        // hand-to-hand: 480 base delay + weapon delay - Martial Arts
        // https://www.bg-wiki.com/ffxi/Attack_Speed
        var mainDelay = wield.handToHand ? 480 + w.main.delay - stats["Martial Arts"] : w.main.delay;
        stats["Delay1"] = mainDelay;
        // our own reading rule: without an off-hand weapon the second delay repeats the first, so
        // that (Delay1 + Delay2) / 2 is the delay of one attack round in both cases
        stats["Delay2"] = wield.dualWield ? w.sub.delay : mainDelay;
        stats["DMG1"] = w.main.dmg;
        stats["DMG2"] = wield.dualWield ? w.sub.dmg : 0;
        stats["Ranged Delay"] = w.ranged.delay;
        stats["Ranged DMG"] = w.ranged.dmg;
        stats["Ammo Delay"] = w.ammo.delay;
        stats["Ammo DMG"] = w.ammo.dmg;
    }

    function handSkill(stats, hand, skill) {
        return (stats[skill + " Skill"] || 0) + (stats[hand + " " + skill + " Skill"] || 0);
    }

    function derive(stats, wield) {
        var hold = wield.handToHand ? "handToHand" : wield.twoHanded ? "twoHanded" : "main";
        var mainSkill = handSkill(stats, "main", wield.skill);
        stats["Attack1"] = CALC.meleeAttack(stats.STR, mainSkill, stats["Attack"], stats["Attack%"], hold);
        stats["Accuracy1"] = CALC.meleeAccuracy(stats.DEX, mainSkill, stats["Accuracy"]);
        stats["Attack2"] = 0;
        stats["Accuracy2"] = 0;
        if (wield.dualWield) {
            var subSkill = handSkill(stats, "sub", wield.subSkill);
            stats["Attack2"] = CALC.meleeAttack(stats.STR, subSkill, stats["Attack"], stats["Attack%"], "offHand");
            stats["Accuracy2"] = CALC.meleeAccuracy(stats.DEX, subSkill, stats["Accuracy"]);
        }
        stats["Evasion"] = CALC.evasion(stats.AGI, stats["Evasion Skill"], stats["Evasion"]);
        stats["Delay Reduction"] = CALC.delayReduction(stats["Dual Wield"], stats["Gear Haste"],
            stats["Magic Haste"], stats["JA Haste"]);
    }

    CALC.characterStats = function (input) {
        var wield = CALC.wielding(input.gearset);
        var stats = startSheet(input);
        var gear = CALC.gearTotals(input.gearset);
        var hastePercent = gear["Gear Haste"] || 0;
        delete gear["Gear Haste"];
        addAll(stats, gear);
        addAll(stats, CALC.setBonusTotals(input.gearset));
        stats["Gear Haste"] = CALC.gearHaste(hastePercent);
        addAll(stats, CALC.buffTotals(input.buffs));
        applyWielding(stats, wield, CALC.traitValues(input.job, input.sub, input.ml));
        weaponSheet(stats, wield, input.gearset);
        derive(stats, wield);
        return stats;
    };
});

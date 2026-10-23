// Atelier calculation engine, stage 2 (ranged): the average damage and TP return of a physical ranged weapon skill.
//
//   CALC.RANGED_WS                    what each ranged weapon skill's BG-Wiki page gives (our database has no
//                                     Marksmanship file, and its Archery one lacks hits)
//   CALC.rangedWeaponskillAverage(stats, enemy, name, tp, wield)
//       stats   the character sheet; enemy {Defense, Evasion, VIT}
//       wield   {ranged: the ranged weapon's name as the gear calls it ("Annihilator R15"), sharpshot: true}
//       returns {damage, tpReturn, hitRate, pdif} or {unsupported: "why"}
//
// Read on 2026-10-23:
// https://www.bg-wiki.com/ffxi/Weapon_Skill_Damage   "Ranged WS Base Damage = floor(( Weapon Base Damage + (Ammo Damage)
//   + fSTR(2) + WSC ) × fTP)"; "Damage = Base Damage × pDIF"; Weapon Skill Damage of gear, gifts and food on the first hit
//   only and additive, the trait and the weapon's own bonus on every hit, multiplied.
// https://www.bg-wiki.com/ffxi/FSTR   fSTR2 = (dSTR + k) / 2, k by dSTR as fSTR's; "The lower cap of fSTR2 is - (Weapon
//   Rank) x 2" ("Rank 0 weapons have a lower cap of -2"); "The upper cap of fSTR2 is (Weapon Rank+8) x 2".
// https://www.bg-wiki.com/ffxi/PDIF   ranged: qRatio caps "Archery/Throwing 3.25, Marksmanship 3.50"; the limits by
//   cRatio (below 0.9: UL cRatio × 10/9 up to 1, LL cRatio up to 0.9; 0.9 to 1.1: 1; from 1.1: UL cRatio, LL cRatio ×
//   20/19 - 3/19, both 1.1 to 3.5); one draw between them, no second random; "Critical ranged pDIF = Normal Ranged
//   pDIF × 1.25", over the cap.
// https://www.bg-wiki.com/ffxi/Ranged_Accuracy   "floor( AGI × 0.75 )" + the skill's accuracy (the melee steps) + gear.
// https://www.bg-wiki.com/ffxi/Ranged_Attack   "Ranged Attack = 8 + Combat Skill + STR".
// https://www.bg-wiki.com/ffxi/Hit_Rate   ranged cap 95 %, "Under the effects of Sharpshot the maximum hit rate becomes 99%".
// https://www.bg-wiki.com/ffxi/True_Shot   "Also applies to Weapon Skills." "Does not apply to magic Weapon Skills."
// https://www.bg-wiki.com/ffxi/Double_Shot , Triple_Shot   "Does not apply to Weapon Skills."
// https://www.bg-wiki.com/ffxi/Tactical_Points   "TP gain is based on the sum of the ranged weapon delay and their respective
//   ammo delay"; "the first hit ... will grant full TP while each consecutive attack will grant a flat 10 TP".
//
// ASSUMED (DIFFERENCES.md AN): the first shot's ~+100 accuracy ("The first swing of any physical Weapon Skill",
// Category:Weapon_Skills); no distance penalty (at the right distance) and no level correction of the ratio (the target's
// level is not on the engine's enemy), as the melee weapon skills; a weapon skill whose hits the page leaves out has one.
//
// @file    atelier/calc/calc_ws_ranged.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    var U = "https://www.bg-wiki.com/ffxi/";
    function same(v) { return [v, v, v]; }
    // name -> {url, skill, mods, ftp, hits, replicating, attack, ignoreDefense, weapons, missing}; read 2026-10-23.
    // weapons: the "(Level 119 III)" pages: Annihilator "Coronach damage +40%", Yoichinoyumi "Namas Arrow damage +40%",
    // "+68%" with its rank 15 augment; Empyreal Arrow's page: Kaja Bow and Ullr +50 %
    CALC.RANGED_WS = {
        // https://www.bg-wiki.com/ffxi/Fomalhaut_(Augmented) rank 15: "Last Stand: Damage +10%"
        "Last Stand": {url: U + "Last_Stand", skill: "Marksmanship", mods: {AGI: 85}, ftp: [2, 3, 4], hits: 2, replicating: true,
            weapons: {"Fomalhaut R15": [1.1]}},
        "Detonator": {url: U + "Detonator", skill: "Marksmanship", mods: {AGI: 70}, ftp: [1.5, 2.5, 5], attack: same(2)},
        "Coronach": {url: U + "Coronach", skill: "Marksmanship", mods: {DEX: 40, AGI: 40}, ftp: same(3),
            weapons: {"Annihilator": [1.4], "Annihilator R15": [1.4]}},
        "Split Shot": {url: U + "Split_Shot", skill: "Marksmanship", mods: {AGI: 70}, ftp: same(1), ignoreDefense: [0, 0.35, 0.5]},
        "Numbing Shot": {url: U + "Numbing_Shot", skill: "Marksmanship", mods: {AGI: 80}, ftp: same(3)},
        "Terminus": {url: U + "Terminus", skill: "Marksmanship", mods: {DEX: 70, AGI: 70}, ftp: [2.5, 5, 7.5]},
        "Empyreal Arrow": {url: U + "Empyreal_Arrow", skill: "Archery", mods: {AGI: 50, STR: 20}, ftp: [1.5, 2.5, 5], attack: same(2),
            weapons: {"Kaja Bow": [1.5], "Ullr": [1.5]}},
        "Namas Arrow": {url: U + "Namas_Arrow", skill: "Archery", mods: {STR: 40, AGI: 40}, ftp: same(2.75),
            weapons: {"Yoichinoyumi": [1.4], "Yoichinoyumi R15": [1.4, 1.2]}},
        // "Seems to be only a one-hit attack" (its description says "twofold")
        "Refulgent Arrow": {url: U + "Refulgent_Arrow", skill: "Archery", mods: {STR: 60}, ftp: [3, 4.25, 7]},
        "Piercing Arrow": {url: U + "Piercing_Arrow", skill: "Archery", mods: {AGI: 50, STR: 20}, ftp: same(1), ignoreDefense: [0, 0.35, 0.5]},
        "Sarv": {url: U + "Sarv", skill: "Archery", mods: {STR: 65, AGI: 65}, ftp: [2.75, 5.5, 8.25]},
        // the pages leave a number out: not computed
        "Apex Arrow": {url: U + "Apex_Arrow", skill: "Archery", missing: "defense ignored at 2000 and 3000 TP"},
        "Jishnu's Radiance": {url: U + "Jishnu%27s_Radiance", skill: "Archery", missing: "critical hit rate by TP"},
        "Blast Shot": {url: U + "Blast_Shot", skill: "Marksmanship", missing: "accuracy bonus by TP"},
        "Blast Arrow": {url: U + "Blast_Arrow", skill: "Archery", missing: "accuracy bonus by TP"},
        "Slug Shot": {url: U + "Slug_Shot", skill: "Marksmanship", missing: "accuracy at 3000 TP"},
        "Sidewinder": {url: U + "Sidewinder", skill: "Archery", missing: "accuracy at 3000 TP"},
        "Sniper Shot": {url: U + "Sniper_Shot", skill: "Marksmanship", missing: "critical hit rate by TP"},
        "Arching Arrow": {url: U + "Arching_Arrow", skill: "Archery", missing: "critical hit rate by TP"},
        "Dulling Arrow": {url: U + "Dulling_Arrow", skill: "Archery", missing: "critical hit rate by TP"}
    };
    CALC.RANGED_PDIF_CAP = {Archery: 3.25, Throwing: 3.25, Marksmanship: 3.5};
    CALC.RANGED_CRIT_PDIF = 1.25;
    CALC.RANGED_HIT_CAP = 0.95;
    CALC.RANGED_HIT_CAP_SHARPSHOT = 0.99;

    // fSTR2: fSTR's steps, halved; caps by the ranged weapon's rank
    CALC.fSTR2 = function (str, enemyVit, dmg) {
        var steps = [[12, 4], [6, 6], [1, 7], [-2, 8], [-7, 9], [-15, 10], [-21, 12]], delta = str - enemyVit, offset = 13;
        for (var i = 0; i < steps.length; i += 1) if (delta >= steps[i][0]) { offset = steps[i][1]; break; }
        var rank = CALC.weaponRank(dmg, false);
        return Math.max(Math.min((delta + offset) / 2, (rank + 8) * 2), rank === 0 ? -2 : -rank * 2);
    };

    function limits(c) {
        if (c < 0.9) return {lower: Math.max(0, Math.min(c, 0.9)), upper: Math.max(0, Math.min(c * 10 / 9, 1))};
        if (c < 1.1) return {lower: 1, upper: 1};
        return {lower: Math.max(1.1, Math.min(c * 20 / 19 - 3 / 19, 3.5)), upper: Math.max(1.1, Math.min(c, 3.5))};
    }
    // mean pDIF of a shot that lands, critical shots included
    CALC.rangedMeanPdif = function (ratio, cap, critRate) {
        var l = limits(ratio), normal = CALC.pdifMeanBelowCap(l.lower, l.upper, cap);
        return (1 - critRate) * normal + critRate * normal * CALC.RANGED_CRIT_PDIF;
    };

    function infoOf(name) {
        var page = CALC.RANGED_WS[name];
        return page ? Object.assign({name: name}, page) : null;
    }

    CALC.rangedWeaponskillAverage = function (stats, enemy, name, tp, wield) {
        var info = infoOf(name), w = wield || {};
        if (!info) return {unsupported: "ranged weapon skill not read on its page yet"};
        if (info.missing) return {unsupported: "ranged weapon skill: " + info.missing + " not on its page"};
        info = CALC.weaponskillWithMerits(info, w.merits);
        var used = Math.min(3000, tp + (stats["TP Bonus"] || 0));
        var skill = stats[info.skill + " Skill"] || 0, dmg = stats["Ranged DMG"] || 0;
        var attack = (8 + skill + (stats.STR || 0) + (stats["Ranged Attack"] || 0)) * (1 + (stats["Ranged Attack%"] || 0)) *
            (CALC.valueAtTP(info.attack, used) || 1);
        var accuracy = CALC.meleeAccuracy(stats.AGI || 0, skill, stats["Ranged Accuracy"] || 0);
        var cap = w.sharpshot ? CALC.RANGED_HIT_CAP_SHARPSHOT : CALC.RANGED_HIT_CAP;
        var defense = enemy.Defense * (1 - (CALC.valueAtTP(info.ignoreDefense, used) || 0));
        // the trait adds to the cap and the gear multiplies it, as calc_ws_pdif.js CALC.pdifCap
        var pdifCap = (CALC.RANGED_PDIF_CAP[info.skill] + (stats["PDL Trait"] || 0) / 100) * (1 + (stats["PDL"] || 0) / 100);
        var pdif = CALC.rangedMeanPdif(attack / defense, pdifCap, 0);
        var ftp = CALC.valueAtTP(info.ftp, used) + (stats["ftp"] || 0), later = info.replicating ? ftp : 1;
        var wsc = CALC.wsAttributeBonus(stats, info.mods), fstr2 = CALC.fSTR2(stats.STR || 0, enemy.VIT || 0, dmg);
        var trueShot = 1 + (stats["True Shot"] || 0) / 100, weapon = (info.weapons || {})[w.ranged] || [];
        var all = [1 + (stats["Weapon Skill Damage Trait"] || 0) / 100].concat(weapon);
        var first = CALC.wsBaseDamage(dmg + (stats["Ammo DMG"] || 0), fstr2, wsc, ftp, [1 + (stats["Weapon Skill Damage"] || 0) / 100].concat(all));
        var other = CALC.wsBaseDamage(dmg + (stats["Ammo DMG"] || 0), fstr2, wsc, later, all);
        var hit1 = CALC.hitRate(accuracy + CALC.WS_FIRST_SWING_ACCURACY, enemy.Evasion, cap), hitN = CALC.hitRate(accuracy, enemy.Evasion, cap);
        var hits = info.hits || 1;
        var damage = (hit1 * first + (hits - 1) * hitN * other) * pdif * trueShot;
        var full = CALC.tpPerHit((stats["Ranged Delay"] || 0) + (stats["Ammo Delay"] || 0), stats["Store TP"] || 0);
        var tpReturn = hit1 * full + (hits - 1) * hitN * CALC.wsExtraSwingTP(stats["Store TP"] || 0) +
            CALC.conserveTPAverage(stats["Conserve TP"] || 0);
        return {damage: damage, tpReturn: tpReturn, hitRate: hit1, pdif: pdif, ftp: ftp};
    };
});

// Atelier calculation engine: what the page asks, in the page's own shapes. No formula here.
//
//   CALC.page.player(input)        input = {job, sub, ml, gearset, buffs, abilities} as the page
//                                  builds it; returns the sheet (CALC.characterStats)
//   CALC.page.weaponskill(...)     [value, [damage, TP return, 1]] for the page's metric
//   CALC.page.round(...)           {result: [value, [damage, TP a round, seconds a round, sign]],
//                                  detail: the steps of the round as the page shows them}
//
// Each of them returns {unsupported: "why"} instead when the engine does not compute the case
// yet: the caller (calc_bridge.js) then asks the engine it had before and counts the reason.
// What is not computed: DIFFERENCES.md, sections V and Y (the job abilities calc_abilities.js
// does not know, aftermaths through the page, ranged and magical weapon skills).
//
// @file    atelier/calc/calc_page.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // A Samurai's merits in Ikishoten, all bought like the other job merits (DIFFERENCES.md, D2)
    var IKISHOTEN_MERITS = 5;
    // the page's OA list is by position: [1] "attacks twice" of the main hand, [8] of the off-hand
    var OA_LENGTH = 14, OA2_MAIN = 1, OA2_SUB = 8;
    var WS_VALUE = {"Damage dealt": 0, "TP return": 1};

    // The attributes read on the character over the table's; null when one is known by neither.
    function baseOf(input) {
        var table = CALC.baseAttributes(input.job, input.sub, input.ml);
        var real = (input.abilities || {})["Base Stats"];
        if (!real) return table;
        var out = {}, complete = true;
        CALC.ATTRIBUTES.forEach(function (name) {
            out[name] = typeof real[name] === "number" ? real[name] : table ? table[name] : null;
            if (out[name] === null) complete = false;
        });
        return complete ? out : null;
    }

    function player(input) {
        var unknown = CALC.abilityTotals(input).unknown;
        if (unknown.length) return {unsupported: "ability on: " + unknown.join(", ")};
        var base = baseOf(input);
        if (!base) return {unsupported: "base attributes unknown for " + input.job + "/" + input.sub};
        return CALC.characterStats({job: input.job, sub: input.sub, ml: input.ml, gearset: input.gearset,
            buffs: input.buffs, abilities: input.abilities, baseAttributes: base,
            critRateMerits: (input.abilities || {})["Crit Rate Merits"]});
    }

    function mainName(gearset) {
        var main = (gearset || {}).main || {};
        return main.Name2 || main.Name;
    }

    function weaponskill(stats, enemy, name, tp, type, metric, gearset) {
        if (!(metric in WS_VALUE)) return {unsupported: "metric " + metric};
        if (type === "ranged") return {unsupported: "ranged weapon skill"};
        // the number of buffs a Naegling counts is not given by the page: taken as none
        var got = CALC.weaponskillAverage(stats, enemy, name, tp, {main: mainName(gearset), buffs: 0});
        if (got.unsupported) return got;
        var values = [got.damage, got.tpReturn];
        return [values[WS_VALUE[metric]], [got.damage, got.tpReturn, 1]];
    }

    // The steps of a round under the names the page shows them with.
    function detailOf(stats, wield, got, start, at, timeToWs) {
        var oa = [];
        while (oa.length < OA_LENGTH) oa.push(0);
        oa[OA2_MAIN] = (stats["OA2 main"] || 0) / 100;
        oa[OA2_SUB] = (stats["OA2 sub"] || 0) / 100;
        return {
            delay1: stats["Delay1"], delay2: wield.dualWield ? stats["Delay2"] : 0, dw: stats["Dual Wield"] || 0,
            ma: stats["Martial Arts"] || 0, mdelay: wield.handToHand ? got.tpDelay * 2 : got.tpDelay,
            handDelay: got.tpDelay, stp: (stats["Store TP"] || 0) / 100, tpPerHit: got.tpPerHit, baseTp: got.baseTP,
            hits: {main: got.landed.main || 0, sub: got.landed.sub || 0, kick: got.landed.kick || 0,
                zanshin: got.landed.zanshin || 0, daken: got.swings.daken || 0},
            hitRate: {main: got.hitRate.main, sub: got.hitRate.sub},
            multi: {qa: (stats["QA"] || 0) / 100, ta: (stats["TA"] || 0) / 100, da: (stats["DA"] || 0) / 100, oa: oa},
            haste: {gear: stats["Gear Haste"] || 0, magic: stats["Magic Haste"] || 0, ja: stats["JA Haste"] || 0},
            h2h: !!wield.handToHand, regain: got.regain, timeRound: got.time, tpRound: got.tp + got.tpFromRegain,
            timeWs: timeToWs, start: start, at: at, crit: got.critRate, damage: got.damage
        };
    }

    // [value, sign]: the page ranks the sets on value x sign
    function roundValue(metric, d) {
        if (metric === "Time to WS") return [d.timeWs, -1];
        if (metric === "DPS") return [d.timeRound ? d.damage / d.timeRound : 0, 1];
        if (metric === "TP return") return [d.tpRound, 1];
        if (metric === "Damage dealt") return [d.damage, 1];
        return null;
    }

    function round(stats, enemy, start, at, metric, gearset, job) {
        var wield = CALC.wielding(gearset);
        // "Hasso active": set by the sheet when Hasso is on and works (calc_abilities.js)
        var got = CALC.attackRoundAverage(stats, enemy, {wield: wield, job: job, main: mainName(gearset),
            hasso: stats["Hasso active"] > 0, ikishoten: job === "sam" ? IKISHOTEN_MERITS : 0});
        var detail = detailOf(stats, wield, got, start, at, CALC.timeToWeaponskill(got, start, at));
        var value = roundValue(metric, detail);
        if (!value) return {unsupported: "metric " + metric};
        return {result: [value[0], [detail.damage, detail.tpRound, detail.timeRound, value[1]], 0], detail: detail};
    }

    CALC.page = {player: player, weaponskill: weaponskill, round: round};
});

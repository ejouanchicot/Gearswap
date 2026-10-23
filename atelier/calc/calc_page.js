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
    // the page's OA list is by position (atelier/opt.js oaOf): "attacks N times" of the main hand at OA_MAIN[N], of the
    // off-hand at OA_SUB[N]
    var OA_LENGTH = 14, OA_MAIN = {2: 1, 3: 0, 4: 13, 5: 12, 6: 11, 7: 10, 8: 9}, OA_SUB = {2: 8, 3: 7, 4: 6, 5: 5, 6: 4, 7: 3, 8: 2};
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
        var stats = CALC.characterStats({job: input.job, sub: input.sub, ml: input.ml, gearset: input.gearset,
            buffs: input.buffs, abilities: input.abilities, baseAttributes: base,
            critRateMerits: (input.abilities || {})["Crit Rate Merits"]});
        stats["TP Bonus"] += lycurgosTpBonus(input);
        return stats;
    }

    // https://www.bg-wiki.com/ffxi/Lycurgos (read 2026-10-22): '"TP Bonus based on current HP" is: TP Bonus =
    // Current HP / 5'; "This caps at +1000 TP Bonus (current HP at 5000+)." The HP are the set's at full: the HP
    // without gear the page worked out (abilities["Naked HP"], atelier/opt.js), then the set's HP and HP %, as the
    // page counts them (atelier/app/js/engine.js charStats). Without that figure, nothing (not guessed).
    var LYCURGOS_TP_BONUS_CAP = 1000;
    function lycurgosTpBonus(input) {
        var naked = (input.abilities || {})["Naked HP"];
        if (mainName(input.gearset) !== "Lycurgos" || typeof naked !== "number") return 0;
        var gear = CALC.gearTotals(input.gearset);
        var hp = Math.round((naked + (gear.HP || 0)) * (1 + (gear["HP%"] || 0) / 100));
        return Math.min(LYCURGOS_TP_BONUS_CAP, Math.floor(hp / 5));
    }

    function mainName(gearset) {
        var main = (gearset || {}).main || {};
        return main.Name2 || main.Name;
    }

    // The merits the character bought in a weapon skill, from the levels the page read in game
    // (abilities["WS Merits"], by the export's names: "Tachi: Shoha" is tachi_shoha); undefined when not read.
    function meritsOf(abilities, name) {
        var levels = (abilities || {})["WS Merits"] || {};
        return levels[name.toLowerCase().replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "")];
    }

    function pieceName(gearset, slot) {
        var p = (gearset || {})[slot] || {};
        return p.Name2 || p.Name;
    }

    function wsValue(got, metric) {
        return got.unsupported ? got : [[got.damage, got.tpReturn][WS_VALUE[metric]], [got.damage, got.tpReturn, 1]];
    }

    // `weaponLevel`: the item level of the weapon that uses it (the ranged one for a ranged weapon skill), for a magical
    // weapon skill (calc_ws_magic.js); a ranged physical one: calc_ws_ranged.js
    function weaponskill(stats, enemy, name, tp, type, metric, gearset, abilities, weaponLevel) {
        if (!(metric in WS_VALUE)) return {unsupported: "metric " + metric};
        var info = CALC.weaponskillInfo(name), page = CALC.MAGIC_WS[name] || {};
        if ((info && info.type === "Magical") || page.type === "Magical") {
            return wsValue(CALC.magicWeaponskillAverage(stats, enemy, name, tp, {main: pieceName(gearset, type === "ranged" ? "ranged" : "main"),
                weaponLevel: weaponLevel, gearset: gearset}), metric);
        }
        var ranged = type === "ranged", hybrid = ((ranged ? CALC.RANGED_WS[name] : info) || {}).type === "Hybrid";
        // the number of buffs a Naegling counts is not given by the page: taken as none
        var wield = ranged ? {ranged: pieceName(gearset, "ranged"), sharpshot: !!(abilities || {}).Sharpshot, merits: meritsOf(abilities, name)}
            : {main: mainName(gearset), buffs: 0, climactic: stats["Climactic Flourish active"] > 0, head: ((gearset || {}).head || {}).Name,
                merits: meritsOf(abilities, name)};
        if (hybrid) return wsValue(CALC.hybridWeaponskillAverage(stats, enemy, name, tp, wield, ranged), metric);
        return wsValue(ranged ? CALC.rangedWeaponskillAverage(stats, enemy, name, tp, wield) : CALC.weaponskillAverage(stats, enemy, name, tp, wield), metric);
    }

    // The steps of a round under the names the page shows them with.
    function detailOf(stats, wield, got, start, at, timeToWs) {
        var oa = [];
        while (oa.length < OA_LENGTH) oa.push(0);
        Object.keys(OA_MAIN).forEach(function (n) {
            oa[OA_MAIN[n]] = (stats["OA" + n + " main"] || 0) / 100;
            oa[OA_SUB[n]] = (stats["OA" + n + " sub"] || 0) / 100;
        });
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

    // What a melee weapon's aftermath does to the round (a mythic's Lv3, an empyrean's triple damage:
    // calc_aftermath.js meleeAftermath); its stats are on the sheet already (calc_abilities.js)
    function roundAftermath(gearset, abilities) {
        var ab = abilities || {}, main = ((gearset || {}).main || {}).Name;
        if (!ab.Aftermath || !main) return null;
        var am = CALC.meleeAftermath(main, ab.Aftermath, ab["Aftermath TP"], ab["Aftermath Stage"]);
        return am && am.round;
    }

    function round(stats, enemy, start, at, metric, gearset, job, abilities) {
        var wield = CALC.wielding(gearset);
        // "Hasso active": set by the sheet when Hasso is on and works (calc_abilities.js)
        var got = CALC.attackRoundAverage(stats, enemy, {wield: wield, job: job, main: mainName(gearset),
            hasso: stats["Hasso active"] > 0, ikishoten: job === "sam" ? IKISHOTEN_MERITS : 0,
            aftermath: roundAftermath(gearset, abilities)});
        var detail = detailOf(stats, wield, got, start, at, CALC.timeToWeaponskill(got, start, at));
        var value = roundValue(metric, detail);
        if (!value) return {unsupported: "metric " + metric};
        return {result: [value[0], [detail.damage, detail.tpRound, detail.timeRound, value[1]], 0], detail: detail};
    }

    CALC.page = {player: player, weaponskill: weaponskill, round: round};
});

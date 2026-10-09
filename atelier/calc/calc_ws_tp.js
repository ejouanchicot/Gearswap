// Atelier calculation engine, stage 2: the TP a weapon skill gives back.
//
//   CALC.baseTPFromDelay(delay)          TP of one hit before Store TP, from the delay
//   CALC.tpPerHit(delay, storeTP)        TP of one full hit, Store TP included
//   CALC.wsDelayForTP(stats, hold)       the delay the TP of a hit is worked out from
//   CALC.wsExtraSwingTP(storeTP)         TP of each swing after the first one of a hand
//   CALC.conserveTPAverage(conserveTP)   mean TP kept by Conserve TP
//
// @file    atelier/calc/calc_ws_tp.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // https://www.bg-wiki.com/ffxi/Tactical_Points   "Delay -> TP calculation":
    //   <= 180: 61 + (Delay - 180) x 63 / 360 ; 181-540: 61 + (Delay - 180) x 88 / 360 ;
    //   541-630: 149 + (Delay - 540) x 20 / 360 ; 631-720: 154 + (Delay - 630) x 28 / 360 ;
    //   721-900: 161 + (Delay - 720) x 24 / 360 ; above: 173 + (Delay - 900) x 28 / 360
    //   "The TP value is floored after these calculations"
    CALC.baseTPFromDelay = function (delay) {
        if (delay <= 180) return Math.floor(61 + (delay - 180) * 63 / 360);
        if (delay <= 540) return Math.floor(61 + (delay - 180) * 88 / 360);
        if (delay <= 630) return Math.floor(149 + (delay - 540) * 20 / 360);
        if (delay <= 720) return Math.floor(154 + (delay - 630) * 28 / 360);
        if (delay <= 900) return Math.floor(161 + (delay - 720) * 24 / 360);
        return Math.floor(173 + (delay - 900) * 28 / 360);
    };

    // https://www.bg-wiki.com/ffxi/Tactical_Points
    //   "floor[Base TP] + floor[Base TP x (Store TP / 100)]"; the page's example: 115 base TP and
    //   20 Store TP give 138.
    CALC.tpPerHit = function (delay, storeTP) {
        var base = CALC.baseTPFromDelay(delay);
        return base + Math.floor(base * storeTP / 100);
    };

    // https://www.bg-wiki.com/ffxi/Tactical_Points
    //   dual wield: "[(Weapon 1 Delay + Weapon 2 Delay) x (1 - Dual Wield %)] / 2" for each weapon;
    //   hand-to-hand: "a delay equal to 1/2 of the total delay" for each fist.
    // "Delay1" of the sheet already is 480 + weapon - Martial Arts for hand-to-hand (stage 1).
    CALC.wsDelayForTP = function (stats, hold, dualWield) {
        if (hold === "handToHand") return stats["Delay1"] / 2;
        if (!dualWield) return stats["Delay1"];
        return (stats["Delay1"] + stats["Delay2"]) * (1 - (stats["Dual Wield"] || 0) / 100) / 2;
    };

    // https://www.bg-wiki.com/ffxi/Tactical_Points
    //   "the first hit (and first Off-Hand hit) will grant full TP while each consecutive attack
    //   will grant a flat 10 TP."
    // The game disagrees with "flat": Store TP applies to these 10 TP, floored swing by swing.
    // measured in game 2026-10-09: floor(10 x (1 + Store TP / 100)) for each landed swing after
    // the first, on 46 weapon skills (Store TP 30, 32, 35: 13 TP a swing, never 13.5).
    CALC.WS_EXTRA_SWING_TP = 10;

    CALC.wsExtraSwingTP = function (storeTP) {
        return Math.floor(CALC.WS_EXTRA_SWING_TP * (1 + storeTP / 100));
    };

    // https://www.bg-wiki.com/ffxi/Conserve_TP
    //   "Conserve TP +X" is "increasing the Conserve TP proc rate by X%"; when it procs "it saves
    //   a random whole amount of TP between 10 and 200 TP (this is added on top of your base TP
    //   return from the Weapon Skill)". Mean of a whole number drawn evenly from 10 to 200: 105.
    CALC.CONSERVE_TP_RANGE = [10, 200];

    CALC.conserveTPAverage = function (conserveTP) {
        var range = CALC.CONSERVE_TP_RANGE;
        return Math.min(1, conserveTP / 100) * (range[0] + range[1]) / 2;
    };
});

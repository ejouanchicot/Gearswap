// Atelier calculation engine, stage 2: which swings a weapon skill makes and how often they land.
// Hit rate, critical hit rate, and the extra swings of Double / Triple / Quadruple Attack.
//
//   CALC.hitRate(accuracy, evasion, cap)          chance that one swing lands
//   CALC.critRateFromDex(dex, enemyAgi)           critical hit rate from DEX against the enemy's AGI
//   CALC.multiAttackChances(qa, ta, da, twice)    chance of 0, 1, 2, 3 extra swings on one swing
//   CALC.wsExtraSwings(first, second, room)       mean extra swings of each swing that can proc
//   CALC.doubleAttackDamageBonus(percent, swings, fromDA)   "Double Attack" damage of an auto-attack round
//
// @file    atelier/calc/calc_ws_hits.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    // https://www.bg-wiki.com/ffxi/Hit_Rate
    //   "99% For one-handed main-hand weapons", "99% For both fists of Hand-to-Hand",
    //   "95% For one-handed secondary off-handed weapons", "95% for two-handed weapons";
    //   "For melee attacks, hit rate cannot fall below 20%"
    // measured in game 2026-10-09: two-handed, 78 landed of 83 (94%) at two accuracies that the
    // formula puts above 95%: the 95% cap holds. The one-handed cap was not reached.
    CALC.HIT_RATE_CAP = {oneHanded: 0.99, handToHand: 0.99, offHand: 0.95, twoHanded: 0.95};
    CALC.HIT_RATE_FLOOR = 0.2;

    // https://www.bg-wiki.com/ffxi/Category:Weapon_Skills
    //   "The first swing of any physical Weapon Skill receives a substantial (~+100) accuracy
    //   bonus, while additional swings receive no bonus." The page writes "~": 100 is its figure.
    //   "Equipment that specifically adds Weapon Skill Accuracy does affect additional hits".
    CALC.WS_FIRST_SWING_ACCURACY = 100;

    // https://www.bg-wiki.com/ffxi/Hit_Rate
    //   Hit Rate (%) = 75 + floor((Accuracy - Evasion) / 2) - 2 x dLVL
    // dLVL "applies only in level-corrected areas" and the enemy of the input has no level: left out.
    CALC.hitRate = function (accuracy, evasion, cap) {
        var rate = (75 + Math.floor((accuracy - evasion) / 2)) / 100;
        return Math.max(CALC.HIT_RATE_FLOOR, Math.min(cap, rate));
    };

    // https://www.bg-wiki.com/ffxi/Critical_Hit_Rate   dDEX = Player DEX - Target AGI
    //   0-6: +0% ; 7-13: +1% ; 14-19: +2% ; 20-29: +3% ; 30-39: +4% ; 40-50: +(dDEX - 35)% ;
    //   "no further boost to critical hit rate once dDEX is greater than 50" (15%)
    CALC.critRateFromDex = function (dex, enemyAgi) {
        var delta = dex - enemyAgi;
        if (delta <= 6) return 0;
        if (delta <= 13) return 1;
        if (delta <= 19) return 2;
        if (delta <= 29) return 3;
        if (delta <= 39) return 4;
        return Math.min(delta, 50) - 35;
    };

    // https://www.bg-wiki.com/ffxi/Multi-Attack
    //   "Each potential proc is checked in sequentially descending order": Quadruple Attack
    //   (+3 hits), then Triple Attack (+2 hits), then Double Attack (+1 hit), then
    //   "Occasionally Attacks X Times" (`twice`: the chance of a weapon that attacks twice).
    // Returns the chance of [0, 1, 2, 3] extra swings; rates are fractions.
    CALC.multiAttackChances = function (qa, ta, da, twice) {
        var triple = (1 - qa) * ta, double = (1 - qa) * (1 - ta) * da;
        var occasional = (1 - qa) * (1 - ta) * (1 - da) * (twice || 0);
        return [1 - qa - triple - double - occasional, double + occasional, triple, qa];
    };

    // "Double Attack" damage +N of the gear (https://www.bg-wiki.com/ffxi/Double_Attack :
    // Cichol's Mantle "'Double Attack' damage +20"): the page lists it and gives no rule.
    // measured in game 2026-10-09: in an auto-attack round where Double Attack procs, BOTH swings
    // deal N% more damage (the hits at pDIF 1 move, so it is damage, not attack); the swings of
    // rounds of 1, 3 or 4 swings do not. Fitted 0.210 [0.199, 0.213] on 169 hits with Ikenga's
    // Axe for +20, and 0.18 to 0.20 with three other weapons.
    // For the auto-attack round (stage 3). NOT applied to weapon skills: whether a weapon skill's
    // Double Attack swings get it could not be measured (DIFFERENCES.md, O6).
    // `percent` is the "DA Damage%" of the sheet; returns the damage multiplier of each swing.
    CALC.doubleAttackDamageBonus = function (percent, swingsInRound, fromDoubleAttack) {
        return fromDoubleAttack && swingsInRound === 2 ? 1 + (percent || 0) / 100 : 1;
    };

    // https://www.bg-wiki.com/ffxi/Double_Attack
    //   "Can Proc a maximum of 2 times per Weapon Skill. Subject to the 8-hits per round limit."
    //   "Has a chance to proc on each fist for Hand-to-Hand weapons or each weapon when Dual Wielding."
    CALC.WS_MAX_PROCS = 2;
    CALC.WS_MAX_SWINGS = 8;

    // Mean number of extra swings of each swing that can proc (one or two: `second` is null for
    // one), when only `room` more swings fit under the 8 swing limit. The first is served first.
    CALC.wsExtraSwings = function (first, second, room) {
        var mean = [0, 0];
        for (var a = 0; a < first.length; a += 1) {
            var taken = Math.min(a, room);
            if (!second) { mean[0] += first[a] * taken; continue; }
            for (var b = 0; b < second.length; b += 1) {
                mean[0] += first[a] * second[b] * taken;
                mean[1] += first[a] * second[b] * Math.min(b, room - taken);
            }
        }
        return mean;
    };
});

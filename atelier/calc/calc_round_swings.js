// Atelier calculation engine, stage 3: which swings an auto-attack round makes.
// The multi-attack check of each hand, the limit of eight swings, and the swings a round can
// add after them: Zanshin, a kick, a shuriken thrown by Daken.
//
//   CALC.procCascade(tiers)                   outcomes of checks made one after the other
//   CALC.roundProcOutcomes(stats, offHand, more)   outcomes of one hand's multi-attack check
//   CALC.roundHands(stats, shape, more)       each hand's outcomes with the swings the limit leaves
//   CALC.roundIsFullChance(hands)             chance that the hands alone reach the limit
//   CALC.zanshinRate(stats, hasso)            chance of a Zanshin swing after a missed single swing
//
// "Rates" are fractions. An outcome is {kind, chance, extra, taken}: `kind` is "qa", "ta",
// "da", "oa" (occasionally attacks N times), "hasso" (the swing Hasso lets Zanshin add) or
// "none"; `extra` the swings it adds; `taken` the mean number of them that fit in the round,
// already weighted by `chance`.
//
// @file    atelier/calc/calc_round_swings.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    function percent(stats, name) { return Math.max(0, Math.min(1, (stats[name] || 0) / 100)); }

    // https://www.bg-wiki.com/ffxi/Multi-Attack
    //   "Each potential proc is checked in sequentially descending order, with the maximum number
    //   of attacks per round, from Dual Wielding and multi-attack, are limited to 8 hits."
    //   "Once a higher order multi-attack proc triggers, that weapon will not be allowed to have a
    //   lower order check."
    // `tiers` is the list of checks in order; a tier is a list of [kind, rate, extra swings] that
    // share one roll (Mythic Aftermath Lv.3: 40% twice, 20% thrice).
    CALC.procCascade = function (tiers) {
        var left = 1, outcomes = [];
        tiers.forEach(function (tier) {
            var used = 0;
            tier.forEach(function (choice) {
                var rate = Math.min(choice[1], 1 - used);
                outcomes.push({kind: choice[0], chance: left * rate, extra: choice[2]});
                used += rate;
            });
            left *= 1 - used;
        });
        outcomes.push({kind: "none", chance: left, extra: 0});
        return outcomes;
    };

    // https://www.bg-wiki.com/ffxi/Mythic_Aftermath   table "Mythic Aftermath (95~119/III)",
    //   Lv.3 "Occasionally attacks twice or thrice": "40% 2x 20% 3x". ASSUMED: the two shares are
    //   one roll (60% in all), the page lists them without saying so (DIFFERENCES.md, T7).
    CALC.MYTHIC_AFTERMATH_3 = [["oa", 0.4, 1], ["oa", 0.2, 2]];

    // https://www.bg-wiki.com/ffxi/Hasso
    //   "Hasso allows Zanshin to proc as an additional attack, even when the first hit lands."
    //   "The rate is approximately (total normal Zanshin Rate)/4"; "Only works for SAM main job."
    //   "Is the last priority in the multi-hit check order."; "Hasso works only with two-handed
    //   weapons."
    // https://www.bg-wiki.com/ffxi/Multi-Attack   6th order "Hasso / Zanshin", "+1",
    //   "Rate is (Zanshin Total / 4)%".
    // https://www.bg-wiki.com/ffxi/Zanshin   "Max additional attack rate is 25% with Zanshin +100."
    CALC.HASSO_ZANSHIN_SHARE = 1 / 4;

    // The checks of one hand, in the page's order:
    //   2nd "Quadruple Attack" "+3", 3rd "Triple Attack" "+2", 4th "Double Attack" "+1",
    //   5th "Occasionally Attacks X Times", 6th "Hasso / Zanshin" "+1".
    // (1st order, "Virtue Stone Weapons, Raetic Weapons SU 4/5 Follow-up Attack Weapons": the
    // sheet does not carry those weapons' rates, not computed.)
    // https://www.bg-wiki.com/ffxi/Double_Attack : "Has a chance to proc on each fist for
    //   Hand-to-Hand weapons or each weapon when Dual Wielding." (Triple_Attack: the same words.)
    // "OA2 main" / "OA2 sub" of the sheet are the weapons' own "Occasionally attacks twice".
    // `more` = {mythicAftermath3: true, hassoZanshin: true} for what the sheet does not say; both
    // are of the main hand only.
    CALC.roundProcOutcomes = function (stats, offHand, more) {
        var occasional = [["oa", percent(stats, offHand ? "OA2 sub" : "OA2 main"), 1]];
        var tiers = [[["qa", percent(stats, "QA"), 3]], [["ta", percent(stats, "TA"), 2]],
            [["da", percent(stats, "DA"), 1]]];
        if (more && more.mythicAftermath3 && !offHand) occasional = occasional.concat(CALC.MYTHIC_AFTERMATH_3);
        tiers.push(occasional);
        if (more && more.hassoZanshin && !offHand) {
            tiers.push([["hasso", percent(stats, "Zanshin") * CALC.HASSO_ZANSHIN_SHARE, 1]]);
        }
        return CALC.procCascade(tiers);
    };

    // chance of each number of extra swings, for CALC.wsExtraSwings
    function byExtra(outcomes) {
        var chances = [];
        outcomes.forEach(function (o) {
            while (chances.length <= o.extra) chances.push(0);
            chances[o.extra] += o.chance;
        });
        return chances;
    }

    function certain(extra) {
        var chances = [];
        while (chances.length < extra) chances.push(0);
        chances.push(1);
        return chances;
    }

    // Each hand's outcomes, with `taken`: the eight swing limit ("limited to 8 hits", the page of
    // CALC.procCascade; CALC.WS_MAX_SWINGS is the same limit) leaves `room` extra swings after
    // the first swing of each hand. ASSUMED: the main hand's extra swings are served first, as for
    // a weapon skill; the page does not say which swings are dropped (DIFFERENCES.md, T4).
    // `shape` = {dualWield, handToHand}: hand-to-hand is two fists that both read the main hand.
    CALC.roundHands = function (stats, shape, more) {
        var two = shape.dualWield || shape.handToHand;
        var room = Math.max(0, CALC.WS_MAX_SWINGS - (two ? 2 : 1));
        var first = CALC.roundProcOutcomes(stats, false, more);
        first.forEach(function (o) { o.taken = o.chance * Math.min(o.extra, room); });
        if (!two) return [{offHand: false, outcomes: first}];
        var second = CALC.roundProcOutcomes(stats, shape.dualWield, shape.dualWield ? null : more);
        second.forEach(function (o) {
            o.taken = o.chance * CALC.wsExtraSwings(byExtra(first), certain(o.extra), room)[1];
        });
        return [{offHand: false, outcomes: first},
            {offHand: shape.dualWield, secondFist: !shape.dualWield, outcomes: second}];
    };

    // Chance that the swings of the hands alone make eight: nothing more fits in that round.
    CALC.roundIsFullChance = function (hands) {
        var room = CALC.WS_MAX_SWINGS - hands.length, full = 0;
        var second = hands[1] ? hands[1].outcomes : [{chance: 1, extra: 0}];
        hands[0].outcomes.forEach(function (a) {
            second.forEach(function (b) {
                if (a.extra + b.extra >= room) full += a.chance * b.chance;
            });
        });
        return full;
    };

    // https://www.bg-wiki.com/ffxi/Zanshin
    //   "May attack again immediately after missing a target."
    //   "Zanshin will be able to activate on single-swing attack rounds for 1-handed (including
    //   "unarmed") and 2-handed weapons under any of the following conditions:" "Missed melee
    //   attack." [...]; "Zanshin does not work with hand-to-hand or dual wield, but works with
    //   single wield."; "Caps at 100% proc rate (Mastered SAM has 60% proc chance base)";
    //   "Zanshin on equipment or other bonuses functions without needing the trait.";
    //   "With Hasso, Zanshin appears to proc at 125% of the normal rate (can be modified by gear)."
    // The page writes "appears": 125% is its figure. Shadows, Guard and counters (the other
    // conditions of the list) depend on the enemy and are not computed. ASSUMED: one check, on
    // the missed swing of a round where no multi-attack fired (DIFFERENCES.md, T8).
    CALC.HASSO_ZANSHIN_RATE = 1.25;

    CALC.zanshinRate = function (stats, hasso) {
        return Math.min(1, Math.max(0, (stats["Zanshin"] || 0) / 100) * (hasso ? CALC.HASSO_ZANSHIN_RATE : 1));
    };
});

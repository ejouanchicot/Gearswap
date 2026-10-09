// Atelier calculation engine, stage 3: the average auto-attack round. One entry point.
//
//   CALC.attackRoundAverage(stats, enemy, options)
//       stats    the character sheet (CALC.characterStats, or any object with the same names)
//       enemy    {Defense, Evasion, VIT, AGI}
//       options  what the sheet does not say, all optional:
//           wield      CALC.wielding(gearset): {skill, dualWield, twoHanded, handToHand}. Without
//                      it the weapon is taken as one-handed, dual wield when "DMG2" is not 0.
//           hasso      true when Hasso is up, with job: the main job ("sam" for the swing Hasso
//                      lets Zanshin add). Hasso's own STR, accuracy and haste belong to the sheet.
//           main       the main hand weapon as the gear names it ("Apocalypse R15"): a relic's
//                      hidden effect on the first swing (CALC.RELIC_WEAPON)
//           aftermath  {type: "empyrean", level: 1..3, multiplier: 2 | 3} damage of the main hand,
//                      {type: "mythic", level: 3} attacks twice or thrice,
//                      {type: "relic"} the haste and accuracy of the relic named by `main`
//           ikishoten  merit levels of Ikishoten (0 to 5), TP of the Zanshin swings
//       returns {swings, landed, hitRate, damage, tp, time, tpPerHit, ...}: see `finish` below
//
// An expected value, like the weapon skill's: each kind of swing is worth
//   mean count in a round x chance to land x floored base damage x mean pDIF x bonuses
// and gives its TP when it lands. Not computed: DIFFERENCES.md, section V.
//
// @file    atelier/calc/calc_round_average.js
// @author  ejouanchicot
(globalThis.CALC_PARTS = globalThis.CALC_PARTS || []).push(function (CALC) {
    function percent(stats, name) { return Math.max(0, Math.min(1, (stats[name] || 0) / 100)); }

    function shapeOf(stats, wield) {
        var w = wield || {dualWield: (stats["DMG2"] || 0) > 0};
        var hold = w.handToHand ? "handToHand" : w.twoHanded ? "twoHanded" : "oneHanded";
        return {hold: hold, skill: w.skill, dualWield: !!w.dualWield, handToHand: !!w.handToHand,
            single: !w.dualWield && !w.handToHand};
    }

    function describe(stats, enemy, options) {
        var shape = shapeOf(stats, options.wield), am = options.aftermath || {};
        var relic = am.type === "relic" ? (CALC.RELIC_WEAPON[options.main] || {}).aftermath || {} : {};
        // Hasso's extra swing: "Only works for SAM main job", "only with two-handed weapons"
        var hassoZanshin = !!options.hasso && options.job === "sam" && shape.hold === "twoHanded";
        return {
            stats: stats, enemy: enemy, options: options, shape: shape, hold: shape.hold,
            more: {mythicAftermath3: am.type === "mythic" && am.level === 3, hassoZanshin: hassoZanshin},
            crit: CALC.roundCritRate(stats, enemy), accuracy: relic.accuracy || 0, haste: relic.haste || 0,
            pdifCap: CALC.pdifCap(shape.hold, shape.skill, (stats["PDL Trait"] || 0) / 100, (stats["PDL"] || 0) / 100),
            multipliers: CALC.aftermathMultipliers(options), kinds: []
        };
    }

    // one kind of swing: `count` of them in a mean round, each giving `tp` when it lands
    function add(ctx, name, count, attacker, rule, multiplier, tp) {
        if (!(count > 0)) return;
        var one = CALC.roundSwing(ctx, attacker, rule, multiplier);
        ctx.kinds.push({name: name, count: count, landed: one.landed, base: one.base, pdif: one.pdif,
            bonus: one.bonus, damage: count * one.damage, tp: count * one.landed * tp});
    }

    // The swings of one hand: its first swing under each outcome of the multi-attack check, then
    // the extra swings. The first swing of a Double or Triple Attack round shares the round's
    // bonuses (CALC.SWING_RULES); the main hand's first swing can carry a relic's hidden effect.
    function addHand(ctx, hand, tp) {
        var name = hand.offHand ? "sub" : "main", m = ctx.multipliers;
        var attacker = CALC.roundAttacker(ctx, name);
        attacker.accuracy += ctx.accuracy;
        var weapon = hand.offHand ? 1 : m.mainHand, first = hand.offHand || hand.secondFist ? 1 : m.firstSwing;
        hand.outcomes.forEach(function (o) {
            var rule = CALC.SWING_RULES[o.kind], opening = CALC.SWING_RULES.first[o.kind] || CALC.SWING_RULES.none;
            add(ctx, name, o.chance, attacker, opening, weapon * first, tp.full);
            add(ctx, name, o.taken, attacker, rule, weapon, rule.zanshin ? tp.zanshin : tp.full);
        });
        return attacker;
    }

    // Zanshin after a miss, in a round of one swing: calc_round_swings.js, CALC.zanshinRate.
    function addZanshin(ctx, hands, attacker, tp) {
        if (!ctx.shape.single || !(ctx.stats["Zanshin"] > 0)) return;
        var none = hands[0].outcomes[hands[0].outcomes.length - 1].chance;
        var missed = 1 - plainHitRate(ctx, attacker);
        var count = none * missed * CALC.zanshinRate(ctx.stats, ctx.options.hasso);
        add(ctx, "zanshin", count, attacker, CALC.SWING_RULES.zanshin, ctx.multipliers.mainHand, tp.zanshin);
    }

    // https://www.bg-wiki.com/ffxi/Kick_Attacks
    //   "Occasionally allows your character an extra attack with a kicking animation.";
    //   "Trait activation rate is increased by 1% per 'Kick attacks +1' on equipment.";
    //   "This trait only activates when using Hand-to-Hand weapons."
    // ASSUMED (DIFFERENCES.md, T9): one check a round, after the fists, so that a round already
    // at eight swings has no kick; the kick gives the TP of a fist and cannot multi-attack.
    function addKick(ctx, hands, tp) {
        if (!ctx.shape.handToHand) return;
        var count = percent(ctx.stats, "Kick Attacks") * (1 - CALC.roundIsFullChance(hands));
        add(ctx, "kick", count, CALC.roundAttacker(ctx, "kick"), CALC.SWING_RULES.none, 1, tp.full);
    }

    // https://www.bg-wiki.com/ffxi/Daken
    //   "When equipped with a shuriken, occasionally throws the shuriken when autoattacking.";
    //   "All Daken+ equipment stacks additively and has no known cap."; "Gives TP as if you threw
    //   your equipped shuriken (based on its delay)."
    // Only the number of throws a round is given: their hit rate and damage are ranged attacks,
    // which this stage leaves out (DIFFERENCES.md, V). ASSUMED: one check a round (T10).
    function dakenThrows(ctx) {
        return (ctx.stats["Ammo Delay"] || 0) > 0 ? percent(ctx.stats, "Daken") : 0;
    }

    // TP of a swing that lands.
    // https://www.bg-wiki.com/ffxi/Tactical_Points
    //   "Players gain TP if they hit a mob for more than 0 damage. The TP gained is based on the
    //   modified delay per weapon."; "During a Multi-Attack proc the TP return of each hit is
    //   identical for each consecutive hit, meaning that if you proc a quadruple attack, you will
    //   get the TP from 4 hits without modifiers."; "Unlike 'Haste', the aforementioned factors
    //   [Dual Wield, Martial Arts] lower the actual delay of the weapon(s) and the TP gain per hit
    //   for the weapon(s) is reduced."
    // measured in game 2026-10-09: every swing of a multi-attack round gives the full amount
    //   (four sets, Store TP 54 to 83).
    // https://www.bg-wiki.com/ffxi/Ikishoten   "Adds 30 base TP (before Store TP) to Zanshin per
    //   merit level.", "including ones that show up as Double Attacks with Hasso"
    CALC.IKISHOTEN_TP = 30;

    function tpOf(ctx) {
        var s = ctx.stats, store = s["Store TP"] || 0;
        var delay = CALC.wsDelayForTP(s, ctx.hold, ctx.shape.dualWield);
        var ikishoten = CALC.IKISHOTEN_TP * (ctx.options.ikishoten || 0);
        return {delay: delay, base: CALC.baseTPFromDelay(delay), full: CALC.tpPerHit(delay, store),
            zanshin: CALC.tpPerHit(delay, store, ikishoten),
            daken: CALC.tpPerHit(s["Ammo Delay"] || 0, store)};
    }

    function total(kinds, name, value) {
        return kinds.reduce(function (sum, k) { return k.name === name || !name ? sum + value(k) : sum; }, 0);
    }

    function byName(ctx, value) {
        var out = {};
        ["main", "sub", "kick", "zanshin"].forEach(function (name) { out[name] = total(ctx.kinds, name, value); });
        return out;
    }

    function plainHitRate(ctx, attacker) {
        return CALC.hitRate(attacker.accuracy, ctx.enemy.Evasion, attacker.cap);
    }

    function procChances(hand) {
        var out = {};
        hand.outcomes.forEach(function (o) { out[o.kind] = (out[o.kind] || 0) + o.chance; });
        return out;
    }

    // What the entry point returns. `swings`: mean swings thrown a round by kind (`daken`: throws,
    // not in the damage or the TP); `landed`: those that land; `hitRate`: of a plain swing of
    // each hand; `procs`: chance of each outcome of the multi-attack check, by hand; `kinds`: the
    // detail, one line per kind of swing; `time` in seconds; `tp` and `damage` of a mean round.
    function finish(ctx, hands, attackers, tp) {
        var time = CALC.roundTime(ctx.stats, ctx.shape.dualWield, ctx.haste);
        var result = {
            swings: byName(ctx, function (k) { return k.count; }),
            landed: byName(ctx, function (k) { return k.count * k.landed; }),
            hitRate: {main: plainHitRate(ctx, attackers[0]), sub: ctx.shape.dualWield ? plainHitRate(ctx, attackers[1]) : 0},
            procs: {main: procChances(hands[0]), sub: hands[1] ? procChances(hands[1]) : {}},
            critRate: ctx.crit, pdifCap: ctx.pdifCap, kinds: ctx.kinds,
            tpDelay: tp.delay, baseTP: tp.base, tpPerHit: tp.full, tpPerZanshin: tp.zanshin, tpPerDaken: tp.daken,
            delay: time.delay, delayReduction: time.reduction, time: time.seconds,
            damage: total(ctx.kinds, null, function (k) { return k.damage; }),
            tp: total(ctx.kinds, null, function (k) { return k.tp; }),
            regain: ctx.stats["Regain"] || 0
        };
        result.swings.daken = dakenThrows(ctx);
        result.tpFromRegain = CALC.regainPerSecond(result.regain) * result.time;
        result.tpPerSecond = (result.tp + result.tpFromRegain) / result.time;
        return result;
    }

    CALC.attackRoundAverage = function (stats, enemy, options) {
        var ctx = describe(stats, enemy, options || {});
        var tp = tpOf(ctx), hands = CALC.roundHands(stats, ctx.shape, ctx.more);
        var attackers = hands.map(function (hand) { return addHand(ctx, hand, tp); });
        addZanshin(ctx, hands, attackers[0], tp);
        addKick(ctx, hands, tp);
        return finish(ctx, hands, attackers, tp);
    };
});

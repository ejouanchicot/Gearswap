// Atelier optimizer: an engaged set's attack round. One part of the engine (FFXI_PARTS, after atelier/opt.js, whose
// value of a set calls O.roundValue for an engaged set): no DOM, no page state, so it also runs in the search's workers.
//   O.round       a set's round: the time to the weaponskill, DPS, TP a round, the attacks a round
//   O.roundsOf    the rounds to the weaponskill with the hits drawn at random (the real time)
//   O.attacksOf   the attacks of one round and how many land; O.procsOf what can go off in each hand
//   O.roundValue  an engaged set's value for its objective (opt.js valueOf)
// It reads O.playerOf and O.physMul of atelier/opt.js
//
// @file    atelier/opt_round.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt;
    if (!O) return;
    // An engaged set's attack round (the engine's average_attack_round, from 0 TP to the weaponskill at opts.wsAt, 1000
    // by default): {time: seconds to the weaponskill, dps, tp: TP a round, damage: a round's}; null for an unknown piece
    var ROUND_OBJ = {tp_real: "Time to WS", tp_time: "Time to WS", dps: "DPS", tp_round: "TP return"};
    // The hits landing in one round, as a distribution {hits: probability}: each hand swings once, plus a Quadruple
    // (3 more), else a Triple (2), else a Double Attack (1), each swing landing at the hand's hit rate
    // A hand's swings in one round, as a distribution {swings: chance}, in the game's order (BG Wiki Multi-Attack):
    // Quadruple, Triple, Double Attack, then, when none of them happened, the weapon's "Occasionally attacks X times":
    // one draw among its outcomes (a Kraken Club's 2 to 8 at 10.66/22.78/28.44/21.36/10.83/3.17/0.67 %, else one: BG
    // Wiki's count of 26,327 rounds, atelier/gear/hidden_review.py; a mythic's aftermath twice 40 %, thrice 20 %).
    // oa: [[extra swings, chance], ...]
    function swingsOf(ma, oa) {
        var out = {4: ma.qa, 3: (1 - ma.qa) * ma.ta, 2: (1 - ma.qa) * (1 - ma.ta) * ma.da}, f = (1 - ma.qa) * (1 - ma.ta) * (1 - ma.da), none = 1;
        (oa || []).forEach(function (x) { if (x[1] > 0) { out[1 + x[0]] = (out[1 + x[0]] || 0) + f * x[1]; none -= x[1]; } });
        out[1] = (out[1] || 0) + f * Math.max(0, none);
        return out;
    }
    // The engine's OA list (actions.js multi_attack) by hand, highest first
    function oaOf(list, hand) {
        var l = list || [], g = function (i) { return l[i] || 0; };
        return hand === "main" ? [[7, g(9)], [6, g(10)], [5, g(11)], [4, g(12)], [3, g(13)], [2, g(0)], [1, g(1)]]
            : [[7, g(2)], [6, g(3)], [5, g(4)], [4, g(5)], [3, g(6)], [2, g(7)], [1, g(8)]];
    }
    // The attacks of one round in theory (both hands' swings: Double / Triple / Quadruple Attack, the weapons'
    // Occasionally attacks, 8 at most) and how many of them land, on average
    O.attacksOf = function (x) {
        var m = swingsOf(x.multi, oaOf(x.multi.oa, "main")), s = x.hits.sub > 0 ? swingsOf(x.multi, oaOf(x.multi.oa, "sub")) : {0: 1}, sw = 0, hits = 0;
        Object.keys(m).forEach(function (a) { Object.keys(s).forEach(function (b) { sw += m[a] * s[b] * (+a + Math.min(+b, 8 - a)); }); });
        var d = handHits(x); Object.keys(d).forEach(function (k) { hits += k * d[k]; });
        return {swings: sw, hits: hits};
    };
    // What can go off in each hand in a round, in the game's order: Quadruple, Triple, Double Attack, the weapon's
    // Occasionally attacks (one draw: OA8..OA2), else one swing; each with its chance and its swings ({k, n, p}); the off hand
    // only when it holds a weapon. tpPerHit: the TP each landed swing gives
    O.procsOf = function (x) {
        var hand = function (oa) {
            var ma = x.multi, f = (1 - ma.qa) * (1 - ma.ta) * (1 - ma.da), none = 1;
            var out = [{k: "QA", n: 4, p: ma.qa}, {k: "TA", n: 3, p: (1 - ma.qa) * ma.ta}, {k: "DA", n: 2, p: (1 - ma.qa) * (1 - ma.ta) * ma.da}];
            oa.forEach(function (o) { if (o[1] > 0) { out.push({k: "OA" + (o[0] + 1), n: o[0] + 1, p: f * o[1]}); none -= o[1]; } });
            out.push({k: "1", n: 1, p: f * Math.max(0, none)});
            return out.filter(function (e) { return e.p > 0; });
        };
        return {main: hand(oaOf(x.multi.oa, "main")), sub: x.hits.sub > 0 ? hand(oaOf(x.multi.oa, "sub")) : null, tpPerHit: x.tpPerHit};
    };
    // n swings landing at hr each: {hits: chance}
    function landed(n, hr) {
        var out = {};
        for (var k = 0, c = 1; k <= n; k++) { out[k] = c * Math.pow(hr, k) * Math.pow(1 - hr, n - k); c = c * (n - k) / (k + 1); }
        return out;
    }
    // The hits landing in one round, both hands, at most 8 attacks a round (the off hand loses what is over)
    function handHits(x) {
        var m = swingsOf(x.multi, oaOf(x.multi.oa, "main")), out = {};
        var s = x.hits.sub > 0 ? swingsOf(x.multi, oaOf(x.multi.oa, "sub")) : {0: 1};
        Object.keys(m).forEach(function (a) { Object.keys(s).forEach(function (b) {
            var p = m[a] * s[b], hm = landed(+a, x.hitRate.main), hs = landed(Math.min(+b, 8 - a), x.hitRate.sub || x.hitRate.main);
            Object.keys(hm).forEach(function (i) { Object.keys(hs).forEach(function (j) { out[+i + +j] = (out[+i + +j] || 0) + p * hm[i] * hs[j]; }); });
        }); });
        return out;
    }
    // The rounds to the weaponskill with the hits drawn at random (not the average TP a round): the chance of each
    // count of rounds, their mean, the time, and the TP at the weaponskill (Wald: start + mean rounds x mean TP a
    // round). What the distribution leaves out (Zanshin, kicks, Daken) and Regain come every
    // round as their mean, so the mean TP a round is the engine's
    O.roundsOf = function (x) {
        var dist = handHits(x);
        var mean = 0; Object.keys(dist).forEach(function (k) { mean += k * dist[k]; });
        var fixed = Math.max(0, x.tpRound - mean * x.tpPerHit), need = Math.max(0, x.at - x.start);
        // after r rounds the TP gathered is (hits landed so far) x TP a hit + r x the rest of a round's TP: the walk
        // follows the hits landed (a whole number), the chance of each count while still short of the weaponskill
        var ks = Object.keys(dist).map(Number), ps = ks.map(function (k) { return dist[k]; });
        var cdf = [1], left = [1], mn = 0;
        for (var r = 1; r <= 1000; r++) {
            var next = [], still = 0, cap = need - r * fixed;
            for (var h = 0; h < left.length; h++) {
                var q = left[h];
                if (!q) continue;
                for (var i = 0; i < ks.length; i++) {
                    var g = h + ks[i];
                    if (g * x.tpPerHit < cap) { next[g] = (next[g] || 0) + q * ps[i]; still += q * ps[i]; }
                }
            }
            cdf.push(still); left = next;
            if (still < 1e-12) break;
        }
        var probs = [];
        for (var n = 1; n < cdf.length; n++) { probs.push(cdf[n - 1] - cdf[n]); mn += n * (cdf[n - 1] - cdf[n]); }
        return {rounds: mn, time: mn * x.timeRound, probs: probs, tpAt: x.start + mn * x.tpRound, dist: dist};
    };
    // opts.shared (the fight model): {set, gear} built once for a set tried under several buff states; opts.lean leaves
    // out the attacks a round
    O.round = function (ctx, pieces, opts) {
        opts = opts || {};
        var sh = opts.shared, set = sh ? sh.set : O.gearset(ctx, pieces);
        if (!set) return null;
        var r = roundOf(ctx, FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities, sh && sh.gear), opts);
        // the attacks a round, shown with a set (left out of the search's tries: it does not move the objective)
        if (r && r.detail && !opts.lean) r.attacks = O.attacksOf(r.detail);
        return r;
    };
    // The target's resistance to the auto-attacks: of the main weapon the set holds (ctx.physResBy: the page's
    // resistance by combat skill), the weapon the optimizer tries when it chooses the weapons
    function roundMul(ctx, player) {
        var skill = ctx.physResBy && ((player.gearset || {}).main || {})["Skill Type"];
        if (!skill) return ctx.dmgMul || 1;
        return O.physMul({physRes: ctx.physResBy[skill] || 0, mode: "engaged", banish: ctx.banish, tomahawk: ctx.tomahawk});
    }
    function roundOf(ctx, player, opts) {
        var at = +opts.wsAt || 1000, r = FFXI.average_attack_round(player, ctx.enemy, 0, at, "Time to WS");
        var m = roundMul(ctx, player), dmg = r[1][0] * m, tp = r[1][1], sec = r[1][2];
        var detail = FFXI.lastRound || null, real = detail && opts.real !== false ? O.roundsOf(detail) : null;
        return {time: r[0], dps: sec ? dmg / sec : 0, tp: tp, damage: dmg, detail: detail, real: real};
    }
    // An engaged set's value for its objective: the time to the weaponskill (less is better), DPS or TP a round
    function roundValue(ctx, pieces, opts) {
        var pl = O.playerOf(ctx, pieces);
        if (!pl) return null;
        // EXPERIMENTAL (2026-10-04, being tested in game): damage a second over a whole fight, weaponskill and skillchains
        // in (atelier/cycle.js); opts.cycle: O.cycle's input without the engaged pieces
        if (opts.objective === "cycle" && opts.cycle && O.cycle) {
            var cy = O.cycle(Object.assign({}, opts.cycle, {pieces: {engaged: pieces, ws: opts.cycle.wsPieces}}));
            return cy ? {v: cy.dps, raw: cy.dps, def: pl.def, round: null, cycle: cy} : null;
        }
        var obj = ROUND_OBJ[opts.objective] ? opts.objective : "tp_real";
        var r = roundOf(ctx, pl.player, Object.assign({}, opts, {real: obj === "tp_real"}));
        // speed only (damage has its DPS objective): the real time first, two sets as fast parted by the engine's average
        // time (the one that fills its rounds sooner keeps a margin)
        var raw = obj === "tp_real" ? r.real.time : obj === "tp_time" ? r.time : obj === "dps" ? r.dps : r.tp;
        var v = obj === "tp_real" ? -raw - r.time * 1e-6 : obj === "tp_time" ? -raw : raw;
        return {v: v, raw: raw, def: pl.def, round: r};
    }
    O.roundValue = roundValue;
});

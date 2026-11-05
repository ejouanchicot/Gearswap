// Atelier optimizer: the search for the best set. One part of the engine (FFXI_PARTS, after atelier/opt.js and its
// parts: it reads O.value, O.context, O.gear, O.gearset, O.hits, O.round, O.ambuGen): no DOM, no page state, so it
// also runs in the search's workers.
//   O.EXCLUSIVE, O.groupOf     the rewards where one item is chosen among several
//   O.run(input), O.runPaced   a whole run from plain data (what a worker receives), at once or spread over time
//   O.optimize, O.prefilter    one walk, the first sort of every item of the game
//   O.prunedChoices, O.gains, O.valueWith, O.clashes, O.startsFor, O.STARTS
//
// @file    atelier/opt_search.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt;
    if (!O) return;
    // ------------------------------------------------------------ one reward among several
    // Mission rewards where one item is chosen among several (BG Wiki): owning one rules the others
    // out, and two of a group are never worn together
    O.EXCLUSIVE = [
        {name: "The Voracious Resurgence 11-2", items: ["Medada's Ring", "Gurebu's Ring", "Cornelia's Ring", "Ragelise's Ring", "Lehko's Ring", "Fickblix's Ring", "Ephramad's Ring"]},
        {name: "Seekers of Adoulin 4-3-8", items: ["Adoulin's Refuge", "Ygnas's Resolve", "Arciela's Grace"]},
        {name: "Seekers of Adoulin 4-6-1", items: ["Adoulin's Refuge +1", "Ygnas's Resolve +1", "Arciela's Grace +1"]},
        // the scenario reward ring (BG Wiki Woltaris_Ring, Janniston_Ring, Jann._Ring_+1: "The Light Within", one ring
        // chosen, exchanged at Ploh Trishbahk for "a choice of a new NQ Ring"; the +1 is that ring "reforged and upgraded
        // to its corresponding HQ version", not a second one): one of the 24 in all, by the game's short names
        {name: "Seekers of Adoulin ring", items: ["Adoulin Ring", "Gorney Ring", "Haverton Ring", "Janniston Ring", "Karieyh Ring", "Orvail Ring",
            "Renaye Ring", "Shneddick Ring", "Thurandaut Ring", "Vocane Ring", "Weather. Ring", "Woltaris Ring",
            "Adoulin Ring +1", "Gorney Ring +1", "Haverton Ring +1", "Jann. Ring +1", "Karieyh Ring +1", "Orvail Ring +1",
            "Renaye Ring +1", "Shneddick Ring +1", "Thur. Ring +1", "Vocane Ring +1", "Weather. Ring +1", "Woltaris Ring +1"]},
        {name: "Rhapsodies of Vana'diel epilogue", items: ["Ligeia Ring", "Ligeia Sash", "Ligeia Scythe"]}
    ];
    O.groupOf = function (name) {
        for (var i = 0; i < O.EXCLUSIVE.length; i++) if (O.EXCLUSIVE[i].items.indexOf(name) !== -1) return O.EXCLUSIVE[i];
        return null;
    };

    // A choice put in a slot. The "weapons" choice is a main hand and its off hand together ({main, sub}): the
    // page makes only pairs the job can hold (a two-handed weapon with a grip, a shield, two weapons when it can
    // dual wield), so the search never stops on a main weapon whose off hand does not fit it
    function put(trial, slot, piece) {
        if (slot === "weapons") { trial.main = piece.main; trial.sub = piece.sub; } else trial[slot] = piece;
        return trial;
    }
    // A copy can go on two slots (rings, earrings) only when there are two of it
    function clashes(pieces, slot, piece) {
        if (slot === "weapons") {
            var both = put(Object.assign({}, pieces), slot, piece);
            return clashes(both, "main", piece.main) || (piece.sub ? clashes(both, "sub", piece.sub) : false);
        }
        // another item of the same one-choice group worn elsewhere
        var group = piece && O.groupOf(piece.name);
        if (group) for (var sl in pieces) if (sl !== slot && pieces[sl] && pieces[sl].name !== piece.name && group.items.indexOf(pieces[sl].name) !== -1) return true;
        var twin = {ring1: "ring2", ring2: "ring1", ear1: "ear2", ear2: "ear1"}[slot];
        if (!twin || !piece || !pieces[twin]) return false;
        var o = pieces[twin];
        // a Rare item is held once, whatever augments each reading of it shows
        if (o.name === piece.name && (o.rare || piece.rare)) return true;
        return o.name === piece.name && (o.augs || []).join("|") === (piece.augs || []).join("|") && !(piece.copies > 1 || o.copies > 1);
    }
    O.clashes = function (pieces, slot, piece) { return clashes(pieces, slot, piece); };
    // What each piece of the result you do not have yet (missing, or not at its best) brings: the
    // set's value against the same set with your best piece of that slot in its place
    O.gains = function (ctx, res, choices, opts) {
        var out = [];
        Object.keys(res.pieces).forEach(function (slot) {
            var p = res.pieces[slot];
            if (!p || !(p.missing || p.maxed) || !choices[slot]) return;
            var mine = (p.maxed ? [p.from] : choices[slot].filter(function (x) { return !x.missing && !x.maxed; })
                .concat(choices[slot].filter(function (x) { return x.maxed; }).map(function (x) { return x.from; })))
                .filter(function (x) { return !clashes(res.pieces, slot, x); });
            if (!mine.length) return;
            var alt = Math.max.apply(null, mine.map(function (x) { return O.valueWith(ctx, res.pieces, slot, x, opts).v; }));
            out.push({slot: slot, piece: p, gain: (res.best.v - alt) / Math.abs(alt || 1) * 100});
        });
        return out.sort(function (a, b) { return b.gain - a.gain; });
    };
    // Every piece the search changed is tried back to the set's own: kept back when the set loses nothing by it (a piece
    // that only came along in a pair, or that wins nothing the objective or the floors read), so no change is for nothing
    // (only a piece the search could choose: never one of the set you do not hold, in a search of your pieces)
    function keepWhatDoesNotMatter(ctx, res, start, opts, choices) {
        Object.keys(res.pieces).forEach(function (slot) {
            if (slot === "main" || slot === "sub" || !start[slot] || pieceName(res.pieces[slot]) === pieceName(start[slot])) return;
            if (!(choices[slot] || []).some(function (p) { return pieceName(p) === pieceName(start[slot]); })) return;
            var trial = Object.assign({}, res.pieces); trial[slot] = start[slot];
            if (clashes(trial, slot, start[slot])) return;
            var r = O.value(ctx, trial, opts);
            if (r.v >= res.score - 1e-13) { res.pieces = trial; res.score = r.v; res.best = r; }
        });
    }
    // The walk only takes a move that gains, so two things it leaves (the player, 2026-10-25, Kaories' WHM: a dozen
    // enhancing sets with no back, Ambuscade capes not had yet; an Empyrean earring in the left ear): each done here
    // when the set loses nothing by it.
    // A slot left empty in a set of 9 pieces or more (an overlay of a few pieces, sets.buff.Doom, stays as it is):
    // the best piece for the objectives, then the most damage taken off (DT+PDT and DT+MDT before their caps), the
    // most HP, the most magic evasion (the stats search's figures; the defense alone in the other searches)
    var GEAR_SLOTS = ["ammo", "head", "neck", "ear1", "ear2", "body", "hands", "ring1", "ring2", "back", "waist", "legs", "feet"];
    function fillGaps(ctx, res, choices, opts) {
        if (GEAR_SLOTS.filter(function (s) { return res.pieces[s]; }).length < 9) return;
        GEAR_SLOTS.forEach(function (slot) {
            if (res.pieces[slot] || !(choices[slot] || []).length) return;
            var best = null, key = null, tol = Math.abs(res.score) * 1e-12 + 1e-13;
            choices[slot].forEach(function (p) {
                if (p.missing || clashes(res.pieces, slot, p)) return;
                var trial = put(Object.assign({}, res.pieces), slot, p), r = O.value(ctx, trial, opts), f = r.stats || {}, d = r.def || {};
                if (!(r.v >= res.score - tol)) return;
                var k = [r.v, -((f.pdt != null ? f.pdt : d.pdt || 0) + (f.mdt != null ? f.mdt : d.mdt || 0)), f.hp || 0, f.meva || 0];
                var more = !key || k.some(function (x, i) { return k.slice(0, i).every(function (y, j) { return y === key[j]; }) && x > key[i]; });
                if (more) { best = {trial: trial, r: r}; key = k; }
            });
            if (best) { res.pieces = best.trial; res.best = best.r; res.score = best.r.v; }
        });
    }
    // An earring whose bonus works in one ear only (O.item's slot_stats: the Empyrean "Right ear:") worn in the
    // other, the two earrings exchanged (each copy taken from the other slot's choices, which carry that slot's figures)
    function rightSides(ctx, res, choices, opts) {
        var sideOf = function (p) { var it = p && O.item(p.name, p.id), ss = it && it.slot_stats; return ss ? (ss.ear2 ? "ear2" : ss.ear1 ? "ear1" : null) : null; };
        var pa = res.pieces.ear1, pb = res.pieces.ear2;
        if (!pa || sideOf(pa) !== "ear2" || sideOf(pb) === "ear2" || !choices.ear1 || !choices.ear2) return;
        // the copy held when the set names another one (augments of an older copy: Kaories' Aquaveil, Acc+14 written,
        // Acc+15 held)
        var held = function (list, p) { return copyIn(list, p) || list.filter(function (x) { return x.name === p.name && !x.missing; })[0] || null; };
        var nb = held(choices.ear2, pa), na = pb ? held(choices.ear1, pb) : null;
        if (!nb || (pb && !na)) return;
        var trial = Object.assign({}, res.pieces);
        trial.ear2 = nb;
        if (na) trial.ear1 = na; else delete trial.ear1;
        var r = O.value(ctx, trial, opts);
        if (r.v >= res.score - (Math.abs(res.score) * 1e-12 + 1e-13)) { res.pieces = trial; res.best = r; res.score = r.v; }
    }
    // A BST's set worn while both fight (the page's bst_pet.js, the player's rules 2026-10-26): once the master's set is
    // found, what is left goes to the pet: first the pieces with more Pet damage taken (piece.petdt, a positive %), then
    // the ones that raise its level (piece.petlv) without taking any of that damage taken back; slot by slot, the most
    // first, while the master's value stays within opts.petDtTol (0.1 %) of the one found and the floors hold
    function petDtPass(ctx, res, choices, opts) {
        if (!opts.petDtTol || !choices) return;
        var top = res.score, low = top - Math.abs(top) * opts.petDtTol;
        var of = function (k) { return function (p) { return (p && p[k]) || 0; }; }, dt = of("petdt"), lv = of("petlv");
        var pass = function (gain, keep) {
            Object.keys(choices).forEach(function (slot) {
                if (slot === "weapons" || slot === "main" || slot === "sub" || !choices[slot]) return;
                var cur = res.pieces[slot];
                var more = choices[slot].filter(function (x) { return gain(x) > gain(cur) && (!keep || keep(x) >= keep(cur)) && !clashes(res.pieces, slot, x); })
                    .sort(function (a, b) { return gain(b) - gain(a); });
                for (var i = 0; i < more.length; i++) {
                    var r = O.valueWith(ctx, res.pieces, slot, more[i], opts);
                    if (r.v >= low && !(r.miss > 0)) { res.pieces = Object.assign({}, res.pieces); res.pieces[slot] = more[i]; res.best = O.value(ctx, res.pieces, opts); res.score = res.best.v; return; }
                }
            });
        };
        pass(dt, null);
        pass(lv, dt);
    }
    // A stats search's figure traded for a lesser one (opts.tolGain {gain, keep, tol}, the page's bst_pet.js: a BST's Charm
    // set, the player's rule 2026-10-27): once the set is found, the pieces with more of piece.st[gain] go in, the most
    // first, slot by slot, while each figure of keep stays within tol of the one found and the floors hold; again until
    // none fits (Ankusa Gaiters' Charm+12 back for a few CHR)
    function tolGainPass(ctx, res, choices, opts) {
        var g = opts.tolGain;
        if (!g || !choices || !res.best.stats) return;
        var top = {}, of = function (p) { return (p && p.st && p.st[g.gain]) || 0; };
        g.keep.forEach(function (k) { top[k] = res.best.stats[k]; });
        var holds = function (r) { return !(r.miss > 0) && g.keep.every(function (k) { return r.stats[k] >= top[k] - Math.abs(top[k]) * g.tol; }); };
        for (var round = 0, moved = true; moved && round < 16; round++) {
            moved = false;
            Object.keys(choices).forEach(function (slot) {
                if (slot === "weapons" || slot === "main" || slot === "sub" || !choices[slot]) return;
                var cur = res.pieces[slot];
                var more = choices[slot].filter(function (x) { return of(x) > of(cur) && !clashes(res.pieces, slot, x); })
                    .sort(function (a, b) { return of(b) - of(a); });
                for (var i = 0; i < more.length; i++) {
                    var r = O.valueWith(ctx, res.pieces, slot, more[i], opts);
                    if (holds(r)) { res.pieces = Object.assign({}, res.pieces); res.pieces[slot] = more[i]; res.best = O.value(ctx, res.pieces, opts); res.score = res.best.v; moved = true; return; }
                }
            });
        }
    }
    // A piece of the job's TP config stays in the result only when it brings more than its TP Bonus:
    // when your best other piece for that slot does as well (the job's rule laying it at the TP when
    // needed), that one goes in (Moonshade never written in a set, Boii Cuisses kept for its stats)
    function tpOnlyOut(ctx, res, choices, opts) {
        var names = ((opts.tpRule && opts.tpRule.pieces) || []).map(function (p) { return p.name; });
        Object.keys(res.pieces).forEach(function (slot) {
            var p = res.pieces[slot];
            if (!p || names.indexOf(p.name) === -1 || !choices[slot]) return;
            var others = choices[slot].filter(function (x) { return names.indexOf(x.name) === -1 && !clashes(res.pieces, slot, x); });
            var best = null, bestV = -Infinity;
            others.forEach(function (x) { var v = O.valueWith(ctx, res.pieces, slot, x, opts).v; if (v > bestV) { bestV = v; best = x; } });
            if (best && bestV >= res.best.v - Math.abs(res.best.v) * 1e-9) { res.pieces[slot] = best; res.best = O.value(ctx, res.pieces, opts); }
        });
    }
    // The search walks from the set one improving move at a time, and stops where no move (one piece, or two) helps.
    // Two such stops are common: a set right on its defense floors, where a faster piece has to come with another
    // that gives the defense back; and every item of the game to try, which leads the walk elsewhere. So it walks
    // from several starts and keeps the best: the set; the best set with no floor, brought back over the floors piece
    // by piece; and, with pieces you do not hold yet (or not at their best), your own pieces searched first
    // The two searches, each a set of walks that can run on their own cores, the best walk kept:
    //   improve (opts.scratch false): from your set, one improving move at a time; quick, and where it ends depends on
    //     the set it starts from
    //   best (opts.scratch true): every walk builds a set from nothing (your weapons kept), so the set you start from does
    //     not change the result (it only parts two sets of the same value, and shows how far the result is from it);
    //     once a walk stops, three pieces are changed at random (seeded: the same every time) and it goes on from there,
    //     the better set kept (KICKS times)
    // The walks: "set" from where the search starts; "loose" with no floor, then brought back over them; "own" your
    // pieces as they are first, then everything; "mix<n>" like "set", the slots and pieces tried in another order.
    // A walk stops where no move (one piece, or two) helps
    O.STARTS = ["set", "loose", "own"];
    var KICKS = 4;
    // The walks that mean something for these choices and floors
    O.startsFor = function (choices, opts) {
        var more = Object.keys(choices).some(function (slot) { return choices[slot].some(function (p) { return p.missing || p.maxed; }); });
        var floors = opts.floor && Object.keys(opts.floor).some(function (k) { return +opts.floor[k]; });
        return O.STARTS.filter(function (k) { return k === "set" || (k === "loose" && floors) || (k === "own" && more); });
    };
    // A seeded random draw (the same seed, the same draws)
    function seeded(seed) { var r = seed * 9301 + 49297; return function () { r = (r * 9301 + 49297) % 233280; return r / 233280; }; }
    function shuffled(choices, rnd) {
        var mix = function (list) { var a = list.slice(); for (var i = a.length - 1; i > 0; i--) { var j = Math.floor(rnd() * (i + 1)), x = a[i]; a[i] = a[j]; a[j] = x; } return a; };
        var out = {};
        mix(Object.keys(choices)).forEach(function (slot) { out[slot] = mix(choices[slot]); });
        return out;
    }
    // The set a walk builds from: nothing but the weapons (the slots the search does not choose)
    function bare(start, choices) {
        var out = {};
        Object.keys(start).forEach(function (slot) { if (!choices[slot] && !(choices.weapons && (slot === "main" || slot === "sub"))) out[slot] = start[slot]; });
        return out;
    }
    // Three slots changed at random to pieces of theirs (not clashing): a kick out of where a walk stopped
    function kicked(pieces, choices, rnd) {
        var out = Object.assign({}, pieces), slots = Object.keys(choices).filter(function (k) { return choices[k].length > 1; });
        for (var n = 0; n < 3 && slots.length; n++) {
            var slot = slots.splice(Math.floor(rnd() * slots.length), 1)[0], list = choices[slot], piece = list[Math.floor(rnd() * list.length)];
            if (!clashes(out, slot, piece)) put(out, slot, piece);
        }
        return out;
    }
    function* walk(ctx, start, choices, opts, how) {
        var seed = /^mix(\d+)$/.exec(how), rnd = seeded(seed ? +seed[1] : how.length * 7 + 3);
        if (seed) choices = shuffled(choices, rnd);
        var mine = {};
        Object.keys(choices).forEach(function (slot) { mine[slot] = choices[slot].filter(function (p) { return !p.missing && !p.maxed; }); });
        var evals = 0, from = function* (pieces, list, o) { var r = yield* optimizeGen(ctx, pieces, list, o || opts); evals += r.evals; return r; };
        var prog = opts.prog || {}, v0 = O.value(ctx, start, opts), empty = opts.scratch ? bare(start, choices) : start;
        prog.walk = how; prog.startRaw = v0.raw; prog.best = null;
        // the stages of a walk: your pieces, or no floor, then everything over the floors, then the kicks
        prog.stage = how === "own" ? "mine" : how === "loose" ? "nofloor" : "all";
        var first = how === "own" ? yield* from(empty, mine) : how === "loose" ? yield* from(empty, choices, Object.assign({}, opts, {floor: null})) : null;
        prog.stage = "all"; prog.best = null;
        var res = yield* from(first ? first.pieces : empty, choices);
        // the fast search makes many walks instead (four a core): the kicks found nothing more there and took three
        // times as long (Laphria time to WS, Ukonvasara fight, 2026-10-05)
        var kicks = opts.kicks != null ? opts.kicks : opts.fast ? 0 : KICKS;
        for (var k = 0; opts.scratch && k < kicks; k++) {
            prog.stage = "kick";
            var again = yield* from(kicked(res.pieces, choices, rnd), choices);
            if (again.score > res.score + 1e-13) res = again;
        }
        res.start = v0; res.evals = evals;
        return res;
    }
    // The fast search's first step: a piece that can never be the best one of its slot is left out. The stats the
    // objective reads are found by trying them: a little of each laid on the set and on a bare set, the value moving
    // up (more is better), down (less is better) or not at all (not read: Magic Accuracy for an engaged set's speed,
    // Accuracy once it is capped even bare). A piece is left out when another piece of its slot is at least as good on
    // every stat read, and on DT, PDT, MDT (they part sets of the same value). Never left out: the set's own pieces,
    // a set bonus's pieces (and the job's AF when a Regal Ring or Earring may be worn), the
    // job's TP pieces, a piece of a one-choice group; a piece you hold only by another you hold (your pieces first);
    // a ring or earring only by two others (two slots to fill). Returns {choices, read: the stats read}
    var BONUS_SET = /^(Adhemar|Amalric|Lustratio|Ryuo|Flamma|Mallquis|Ayanmo|Mummu|Regal|Prophetic) |^(Horos|Etoile) Tights|^Prophetica$/;
    var SIDE = {DT: 1, PDT: 1, MDT: 1};
    function prunedChoices(ctx, start, choices, opts) {
        var slots = Object.keys(choices).filter(function (k) { return k !== "weapons"; });
        var gearOfSlot = {}, keys = {};
        slots.forEach(function (slot) {
            gearOfSlot[slot] = choices[slot].map(function (p) { return O.gear(p, slot, ctx); });
            gearOfSlot[slot].forEach(function (g) { if (g) for (var k in g) if (typeof g[k] === "number" && k !== "DMG" && k !== "Delay") keys[k] = 1; });
        });
        // the direction of each stat, tried on the set and on a bare one (every chosen slot empty)
        var bareSet = Object.assign({}, start);
        slots.forEach(function (k) { delete bareSet[k]; });
        var probe = slots.filter(function (k) { return !/^(ring|ear)/.test(k); })[0] || slots[0];
        var g0 = O.gearset, dir = {};
        ctx._noMemo = true;
        try {
            [start, bareSet].forEach(function (at) {
                var base = O.value(ctx, at, opts).v;
                Object.keys(keys).forEach(function (k) {
                    [5, 40].forEach(function (amt) {
                        O.gearset = function (c, pieces) {
                            var set = g0.apply(this, arguments);
                            if (!set) return set;
                            var out = Object.assign({}, set), sl = O.SLOT[probe];
                            out[sl] = Object.assign({}, out[sl]); out[sl][k] = (out[sl][k] || 0) + amt;
                            return out;
                        };
                        var v = O.value(ctx, at, opts).v;
                        O.gearset = g0;
                        if (!isFinite(v) || !isFinite(base)) { dir[k] = "both"; return; }
                        var d = v - base, tiny = 1e-11 * Math.max(1, Math.abs(base));
                        if (Math.abs(d) <= tiny) return;
                        var now = d > 0 ? "up" : "down";
                        dir[k] = !dir[k] || dir[k] === now ? now : "both";
                    });
                });
            });
        } finally { O.gearset = g0; ctx._noMemo = false; }
        Object.keys(SIDE).forEach(function (k) { if (keys[k] && !dir[k]) dir[k] = "down"; });
        var read = Object.keys(dir);
        var tpNames = ((opts.tpRule && opts.tpRule.pieces) || []).map(function (p) { return p.name; });
        var regal = slots.some(function (slot) { return choices[slot].some(function (p) { return /^Regal (Ring|Earring)/.test(p.name || ""); }); });
        // the artifact pieces a Regal accessory adds to (atelier/calc/calc_sets.js), kept in the search with it
        var startNames = {};
        Object.keys(start).forEach(function (k) { if (start[k] && start[k].name) startNames[start[k].name + "|" + (start[k].augs || []).join("|")] = 1; });
        var special = function (p) {
            var n = p.name || "";
            return startNames[n + "|" + (p.augs || []).join("|")] || BONUS_SET.test(n) || tpNames.indexOf(n) !== -1 || O.groupOf(n)
                || (regal && CALC.isArtifactPiece(n));
        };
        var held = function (p) { return !p.missing && !p.maxed; };
        var beats = function (a, b) {          // a at least as good as b on every stat read
            var strict = false;
            for (var i = 0; i < read.length; i++) {
                var k = read[i], x = (a && a[k]) || 0, y = (b && b[k]) || 0, d = dir[k];
                if (d === "both") { if (x !== y) return 0; continue; }
                if (d === "up" ? x < y : x > y) return 0;
                if (x !== y) strict = true;
            }
            return strict ? 2 : 1;
        };
        var out = {};
        Object.keys(choices).forEach(function (slot) {
            if (slot === "weapons" || !gearOfSlot[slot]) { out[slot] = choices[slot]; return; }
            var list = choices[slot], gs = gearOfSlot[slot], twin = /^(ring|ear)/.test(slot);
            out[slot] = list.filter(function (p, i) {
                if (!gs[i] || special(p)) return true;
                var units = 0;
                for (var j = 0; j < list.length && units < (twin ? 2 : 1); j++) {
                    if (j === i || !gs[j]) continue;
                    if (held(p) && !held(list[j])) continue;
                    var b = beats(gs[j], gs[i]);
                    // equal on everything read: the first one stays
                    if (b === 2 || (b === 1 && j < i)) units += twin && list[j].copies > 1 ? 2 : 1;
                }
                return units < (twin ? 2 : 1);
            });
        });
        return {choices: out, read: dir};
    }
    O.prunedChoices = function (ctx, start, choices, opts) { return prunedChoices(ctx, start, choices, opts); };
    // A whole run from plain data (what a worker receives): {ctx: O.context's input, start, choices, opts, prefilter
    // (keep each slot's best n first), starts (the walks to make, every one by default), seed (optional: the set the
    // walks start from instead of `start`, which stays the set the result is compared with)}; its progress in
    // opts.prog while it searches. A generator: it stops after each try of a set, so a caller can spread it over time
    // (O.runPaced)
    function* runGen(input) {
        var ctx = O.context(input.ctx), opts = Object.assign({}, input.opts, {prog: {evals: 0, moves: []}, base: input.start});
        ctx._fast = !!input.opts.fast;
        yield opts.prog;
        var seed = input.seed || input.start;
        var from0 = input.opts.scratch ? bare(seed, input.choices) : seed;
        // the Ambuscade capes of the game built (atelier/opt_ambu.js)
        var all = O.ambuGen ? yield* O.ambuGen(ctx, from0, input.choices, opts) : input.choices;
        var choices = input.prefilter ? yield* prefilterGen(ctx, from0, all, opts, input.prefilter) : all;
        // the fast search: only the pieces that can be the best of their slot
        if (ctx._fast && ctx.mode !== "stats") choices = prunedChoices(ctx, seed, choices, opts).choices;
        var res = null, evals = 0, starts = input.starts || O.startsFor(choices, opts);
        for (var i = 0; i < starts.length; i++) {
            var r = yield* walk(ctx, seed, choices, opts, starts[i]);
            evals += r.evals;
            if (!res || r.score > res.score) res = r;
        }
        res.evals = evals;
        // walked from a seed: the figures before are still those of the set itself
        if (seed !== input.start) res.start = O.value(ctx, input.start, opts);
        keepWhatDoesNotMatter(ctx, res, input.start, opts, choices);
        tpOnlyOut(ctx, res, choices, opts);
        rightSides(ctx, res, choices, opts);
        fillGaps(ctx, res, choices, opts);
        // the walks' result is ranked BEFORE the passes below: they lower the score on purpose (Pet DT for a few
        // points of the master's figure, Charm+ for a few CHR), so ranked after them the page's merge of the
        // workers (optimizer.js) kept a walk whose pass found nothing and the player's rule was lost (audit
        // 2026-10-28 A)
        var rank = res.score;
        petDtPass(ctx, res, input.choices, opts);
        tolGainPass(ctx, res, choices, opts);
        res.best.hits = O.hits(ctx, res.pieces, opts);
        res.start.hits = O.hits(ctx, input.start, opts);
        // an engaged set's round before and after, the real time worked out whatever the objective
        if (ctx.mode === "engaged") { res.best.round = O.round(ctx, res.pieces, opts); res.start.round = O.round(ctx, input.start, opts); }
        return {pieces: res.pieces, best: res.best, start: res.start, evals: res.evals, score: res.score, rank: rank, gains: O.gains(ctx, res, choices, opts)};
    }
    // A generator run to its end at once
    function drain(gen) { var x = gen.next(); while (!x.done) x = gen.next(); return x.value; }
    O.run = function (input) { return drain(runGen(input)); };
    // The same run spread over time, so the computer stays smooth beside the game: `work` ms of search, then
    // `rest` ms of pause (about half a core); after each slice onStep({walk, stage, phase, round, evals, startRaw,
    // best: {raw, miss}, moves: the moves kept since the last one}); done(result) or fail(error) at the end.
    // Returns a stop function
    O.runPaced = function (input, onStep, done, fail, work, rest) {
        var gen = runGen(input), stopped = false, prog = null;
        var now = function () { return (typeof performance !== "undefined" ? performance : Date).now(); };
        var pump = function () {
            if (stopped) return;
            var x;
            try {
                var end = now() + (work || 25);
                do { x = gen.next(); prog = prog || x.value; } while (!x.done && now() < end);
            } catch (e) { return fail(e); }
            if (x.done) return done(x.value);
            if (onStep && prog) onStep({walk: prog.walk, stage: prog.stage, phase: prog.phase, round: prog.round, evals: prog.evals,
                startRaw: prog.startRaw, best: prog.best, moves: prog.moves.splice(0)});
            setTimeout(pump, rest == null ? 25 : rest);
        };
        setTimeout(pump, 0);
        return function () { stopped = true; };
    };
    // choices: {page slot: [piece...]} (fixed slots left out); opts: {tp, tpRule, passes, top, prog}.
    // Slot by slot until nothing improves, then every pair of slots over their best few pieces
    // (a pair can beat two single moves: two pieces reaching a cap together).
    function* optimizeGen(ctx, start, choices, opts) {
        var st = {best: Object.assign({}, start), evals: 0};
        st.score = score(ctx, st.best, opts);
        var slots = Object.keys(choices), rounds = opts.rounds || 6;
        var prog = opts.prog || {};
        for (var round = 0; round < rounds; round++) {
            prog.round = round + 1; prog.phase = "singles";
            yield* singles(ctx, st, slots, choices, opts);
            var swapped = yield* sides(ctx, st, choices, opts);
            prog.phase = "shortlist";
            var list = yield* shortlist(ctx, st, slots, choices, opts, opts.top || 8, opts.extra || 4);
            prog.phase = "pairs";
            var more = yield* pairs(ctx, st, slots, list, opts);
            if (!more && !swapped) break;
        }
        return {pieces: st.best, score: st.score, best: O.value(ctx, st.best, opts), start: O.value(ctx, start, opts), evals: st.evals};
    }
    O.optimize = function (ctx, start, choices, opts) { return drain(optimizeGen(ctx, start, choices, opts)); };
    // Each slot's `keep` best pieces as single swaps from `start` (pieces flagged keep always stay):
    // a first sort before searching hundreds of pieces a slot (every item of the game)
    function* prefilterGen(ctx, start, choices, opts, keep) {
        var out = {}, slots = Object.keys(choices), loose = Object.assign({}, opts, {floor: null});
        if (opts.prog) opts.prog.phase = "prefilter";
        for (var s = 0; s < slots.length; s++) {
            var slot = slots[s], rated = [], list = choices[slot];
            if (slot === "weapons") list = yield* mainsFirst(ctx, start, list, loose, opts, keep);
            for (var i = 0; i < list.length; i++) {
                var piece = list[i], r = O.value(ctx, put(Object.assign({}, start), slot, piece), loose), d = r.def || {};
                rated.push({piece: piece, v: r.v, dt: (d.pdt || 0) + (d.mdt || 0)});
                if (opts.prog) opts.prog.evals++;
                yield;
            }
            var byDt = rated.slice().sort(function (a, b) { return a.dt - b.dt; }).slice(0, Math.ceil(keep / 3));
            rated.sort(function (a, b) { return b.v - a.v; });
            // a piece you hold stays (a pair of weapons: its main hand's)
            var held = function (x) { return x.piece.keep || (x.piece.main && x.piece.main.keep); };
            out[slot] = rated.filter(function (x, n) { return n < keep || held(x) || byDt.indexOf(x) !== -1; }).map(function (x) { return x.piece; });
        }
        return out;
    }
    // Pairs of weapons from every item of the game (thousands: each main hand with each off hand it takes): each main
    // hand rated once (with the off hand worn when it takes it, else its first), its `keep` best and yours kept with all
    // their off hands
    function* mainsFirst(ctx, start, pairs, loose, opts, keep) {
        if (pairs.length <= 300) return pairs;
        var groups = {}, order = [], worn = start.sub && start.sub.name;
        pairs.forEach(function (x) {
            var k = x.main.name + "|" + (x.main.augs || []).join(",");
            if (!groups[k]) { groups[k] = {pairs: [], main: x.main}; order.push(k); }
            groups[k].pairs.push(x);
        });
        var rated = [];
        for (var i = 0; i < order.length; i++) {
            var g = groups[order[i]], probe = g.pairs.filter(function (x) { return x.sub && x.sub.name === worn; })[0] || g.pairs[0];
            rated.push({g: g, v: O.value(ctx, put(Object.assign({}, start), "weapons", probe), loose).v});
            if (opts.prog) opts.prog.evals++;
            yield;
        }
        rated.sort(function (a, b) { return b.v - a.v; });
        return [].concat.apply([], rated.filter(function (x, n) { return n < keep || x.g.main.keep; }).map(function (x) { return x.g.pairs; }));
    }
    O.prefilter = function (ctx, start, choices, opts, keep) { return drain(prefilterGen(ctx, start, choices, opts, keep)); };
    // A set's value (the objective, floors counted) with one slot changed
    O.valueWith = function (ctx, pieces, slot, piece, opts) {
        return O.value(ctx, put(Object.assign({}, pieces), slot, piece), opts);
    };
    // A move kept when it improves the set (st: {best, score, evals}); the progress state hears of it: the slots it
    // changed, from what to what, and the set's value then
    var pieceName = function (p) { return p && p.name ? p.name : "—"; };
    function tryMove(ctx, st, trial, opts) {
        var r = O.value(ctx, trial, opts), prog = opts.prog; st.evals++;
        if (prog) prog.evals++;
        if (!(r.v > st.score + 1e-13)) return false;
        if (prog) {
            var changes = Object.keys(trial).filter(function (k) { return pieceName(trial[k]) !== pieceName(st.best[k]); })
                .map(function (k) { return {slot: k, from: pieceName(st.best[k]), to: pieceName(trial[k])}; });
            if (!prog.best || r.v > prog.best.v) prog.best = {raw: r.raw, miss: r.miss, v: r.v};
            prog.moves.push({changes: changes, raw: r.raw, miss: r.miss, stage: prog.stage});
        }
        st.best = trial; st.score = r.v;
        return true;
    }
    // Slot by slot, every piece, until a full pass changes nothing
    function* singles(ctx, st, slots, choices, opts) {
        for (var pass = 0; pass < (opts.passes || 6); pass++) {
            var moved = false;
            for (var s = 0; s < slots.length; s++) {
                var slot = slots[s];
                for (var i = 0; i < choices[slot].length; i++) {
                    var piece = choices[slot][i];
                    if (clashes(st.best, slot, piece)) continue;
                    if (tryMove(ctx, st, put(Object.assign({}, st.best), slot, piece), opts)) moved = true;
                    yield;
                }
            }
            if (!moved) return;
        }
    }
    // The two earrings exchanged, and the two rings: a bonus that works on one side only (the Empyrean earrings'
    // "Right ear:") is reached only so, as a piece worn in one ear cannot be put in the other (clashes) and the left
    // ear is tried first. Each piece is taken from the other slot's choices, which carry that slot's figures (the
    // stats search's vectors); true when the set changed
    var TWINS = [["ear1", "ear2"], ["ring1", "ring2"]];
    var sameCopy = function (x, y) { return x.name === y.name && x.rank === y.rank && (x.augs || []).join("|") === (y.augs || []).join("|"); };
    var copyIn = function (list, p) { for (var i = 0; i < list.length; i++) if (!list[i].missing === !p.missing && sameCopy(list[i], p)) return list[i]; return null; };
    function* sides(ctx, st, choices, opts) {
        var moved = false;
        for (var i = 0; i < TWINS.length; i++) {
            var a = TWINS[i][0], b = TWINS[i][1], pa = st.best[a], pb = st.best[b];
            if (!choices[a] || !choices[b] || !pa || !pb || sameCopy(pa, pb)) continue;
            var na = copyIn(choices[a], pb), nb = copyIn(choices[b], pa);
            if (!na || !nb) continue;
            var trial = Object.assign({}, st.best);
            trial[a] = na; trial[b] = nb;
            if (tryMove(ctx, st, trial, opts)) moved = true;
            yield;
        }
        return moved;
    }
    // The best few pieces of each slot, the others staying as they are
    // Three lists a slot, from one try of each piece on the set: the `top` best (floors counted), the
    // `extra` best for damage alone (floors ignored: a strong piece that drops the defense under a floor)
    // and the `extra` best for defense (DT+PDT and DT+MDT: the piece that can pay for it elsewhere)
    function* shortlist(ctx, st, slots, choices, opts, top, extra) {
        var out = {};
        for (var s = 0; s < slots.length; s++) {
            var slot = slots[s], rated = [];
            for (var i = 0; i < choices[slot].length; i++) {
                var piece = choices[slot][i];
                if (clashes(st.best, slot, piece)) continue;
                var r = O.value(ctx, put(Object.assign({}, st.best), slot, piece), opts), d = r.def || {}; st.evals++;
                if (opts.prog) opts.prog.evals++;
                if (r.v !== -Infinity) rated.push({piece: piece, v: r.v, raw: r.raw, dt: (d.pdt || 0) + (d.mdt || 0)});
                yield;
            }
            var best = function (key, n, low) {
                return rated.slice().sort(function (x, y) { return low ? x[key] - y[key] : y[key] - x[key]; }).slice(0, n).map(function (x) { return x.piece; });
            };
            var fast = opts.objective === "tp_real" || opts.objective === "tp_time";
            out[slot] = {top: best("v", top), raw: best("raw", extra, fast), dt: best("dt", extra, true)};
        }
        return out;
    }
    // Pairs of slots: the best pieces of both (two pieces can beat two single moves: a cap reached
    // together), and a strong piece for damage with a defense piece elsewhere that keeps the floors
    // (Agoge Mask under the floor alone, with a Gelatinous Ring that pays its DT back); true when the set changed
    function* pairs(ctx, st, slots, list, opts) {
        var moved = false;
        var cross = function* (a, b, la, lb) {
            for (var i = 0; i < la.length; i++) for (var j = 0; j < lb.length; j++) {
                var pa = la[i], pb = lb[j], trial = put(put(Object.assign({}, st.best), a, pa), b, pb);
                if (clashes(trial, a, pa) || clashes(trial, b, pb)) continue;
                if (tryMove(ctx, st, trial, opts)) moved = true;
                yield;
            }
        };
        for (var i = 0; i < slots.length; i++) for (var j = i + 1; j < slots.length; j++) {
            var a = slots[i], b = slots[j];
            yield* cross(a, b, list[a].top, list[b].top);
            yield* cross(a, b, list[a].raw, list[b].dt);
            yield* cross(a, b, list[a].dt, list[b].raw);
        }
        return moved;
    }
    function score(ctx, pieces, opts) { return O.value(ctx, pieces, opts).v; }
});

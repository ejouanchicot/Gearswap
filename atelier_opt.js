// Atelier optimizer: the page's sets, buffs and target turned into the engine's player and enemy
// (atelier-engine, wsdist's formulas, kept on this PC only), a weaponskill's average damage, and
// the search for the best set. One part of the engine (FFXI_PARTS): no DOM, no page state, so it
// also runs in a Web Worker (FFXI.workerSource).
//
//   FFXI.opt.gear(piece, slot, ctx)   one piece as the engine reads it (catalogue + its augments)
//   FFXI.opt.selection(b)             the page's buff state as FFXI.aggregate_buffs takes it
//   FFXI.opt.context(...)             player, buffs, target and weaponskill of one evaluation
//   FFXI.opt.ws(ctx, pieces, tp)      the weaponskill's average damage with those pieces
//   FFXI.opt.tpPieces(rule, pieces, tp)  the TP pieces the job's rule adds (tp_bonus_calculator.lua)
//   FFXI.opt.value(ctx, pieces, opts)  a set's value for an objective, with the defense floors
//   FFXI.opt.optimize(ctx, start, choices, opts)  the best set: slot by slot, then pairs of slots
//
// @file    atelier_opt.js
// @author  ejouanchicot
(globalThis.FFXI_PARTS = globalThis.FFXI_PARTS || []).push(function (FFXI) {
    var O = FFXI.opt = {};
    var ALL_JOBS = ["war", "mnk", "whm", "blm", "rdm", "thf", "pld", "drk", "bst", "brd", "rng", "smn", "sam", "nin", "drg",
        "blu", "cor", "pup", "dnc", "sch", "geo", "run"];
    // the page's slot names -> the engine's
    O.SLOT = {main: "main", sub: "sub", range: "ranged", ammo: "ammo", head: "head", neck: "neck", ear1: "ear1", ear2: "ear2",
        body: "body", hands: "hands", ring1: "ring1", ring2: "ring2", back: "back", waist: "waist", legs: "legs", feet: "feet"};
    var PAGE_SLOTS = Object.keys(O.SLOT);

    // ------------------------------------------------------------ catalogue
    var byId = null, byName = null;
    function index() {
        if (byId || !FFXI.CATALOG) return;
        byId = {}; byName = {};
        FFXI.CATALOG.items.forEach(function (it) {
            byId[it.id] = it;
            (byName[it.name] = byName[it.name] || []).push(it);
        });
    }
    // The catalogue entry of a piece: its own item id when known, else the name's entry with the
    // highest item level (several ids share a name: a stage, an NQ and HQ copy...)
    O.item = function (name, id) {
        index();
        if (!byId) return null;
        if (id && byId[id]) return byId[id];
        var list = byName[name] || [];
        return list.slice().sort(function (a, b) { return (b.ilvl || 0) - (a.ilvl || 0) || b.id - a.id; })[0] || null;
    };

    O.empty = function () { return {"Name": "Empty", "Name2": "Empty", "Type": "None", "Skill Type": "None", "Jobs": ALL_JOBS.slice()}; };

    // A weapon's second name, which the engine reads: a prime weapon's stage (aftermath),
    // a relic / mythic / empyrean / ergon / aeonic at R15 (weapon skill bonus)
    function name2(item, ctx) {
        var data = FFXI.player_data || {};
        if ((data.PRIME_WEAPONS || []).indexOf(item.name) !== -1) return item.name + " " + (ctx.primeStage || "V");
        var r = FFXI.ranked_entry ? FFXI.ranked_entry(item.name) : null;
        if (r && r.kind === "ultimate_weapon") return item.name + " R15";
        return item.name;
    }

    // One piece as the engine reads it: the catalogue's stats plus its augments (or its rank's).
    O.gear = function (piece, slot, ctx) {
        if (!piece || !piece.name || piece.name === "empty") return O.empty();
        var item = O.item(piece.name, piece.id);
        if (!item) return null;
        var g = {"Name": item.name, "Name2": name2(item, ctx || {}), "Type": item.Type, "Jobs": item.jobs.slice()};
        if (item["Skill Type"]) g["Skill Type"] = item["Skill Type"];
        if (item.DMG) { g.DMG = item.DMG; g.Delay = item.Delay; }
        var add = function (src) { for (var k in src) if (typeof src[k] === "number") g[k] = (g[k] || 0) + src[k]; };
        add(item.stats || {});
        if (FFXI.parse_augments && (piece.augs && piece.augs.length || piece.rank != null)) add(FFXI.parse_augments(item.name, piece.augs || [], piece.rank).stats);
        return g;
    };

    // ------------------------------------------------------------ buffs
    // The page's buff state (atelier.html buffState) as FFXI.aggregate_buffs takes it
    var FOOD_KEYS = {str: "STR", dex: "DEX", vit: "VIT", agi: "AGI", int: "INT", mnd: "MND", chr: "CHR", acc: "Accuracy",
        atkf: "Attack", racc: "Ranged Accuracy", ratkf: "Ranged Attack", mab: "Magic Attack", macc: "Magic Accuracy",
        hp: "HP", mp: "MP", sb: "Subtle Blow", stp: "Store TP", da: "DA"};
    O.selection = function (b, food) {
        var f = null;
        if (food) { f = {}; for (var k in food) if (FOOD_KEYS[k]) f[FOOD_KEYS[k]] = food[k]; }
        var bubble = function (kind, v) { return v ? kind + v : "None"; };
        return {
            brd: true, songs: {Song1: b.song0 || "None", Song2: b.song1 || "None", Song3: b.song2 || "None", Song4: b.song3 || "None"},
            song_bonus: +(b.songsPlus || 0), soul_voice: false, marcato: false,
            cor: true, rolls: {Roll1: {name: b.roll0 || "None", potency: b.roll0n || "XI"}, Roll2: {name: b.roll1 || "None", potency: b.roll1n || "XI"}},
            roll_bonus: +(b.rollsPlus || 0), crooked: false, job_bonus: false, light_shot: !!b.lightshot,
            geo: true, bubbles: {"Indi-": bubble("Indi-", b.indi), "Geo-": bubble("Geo-", b.geo), "Entrust-": bubble("Entrust-", b.entrust)},
            bubble_bonus: +(b.geoPlus || 0), bolster: false, bog: false, bubble_potency: 100,
            whm: true, whm_spells: {Dia: b.dia || "None", Haste: b.haste || "None", Boost: "None", Storm: b.storm || "None"},
            shell5: b.shell === "Shell V", food: f, toggles: {}
        };
    };

    // ------------------------------------------------------------ evaluation
    // ctx: {job, sub, ml, buffs, abilities, enemy (create_enemy), ws, wsType ("melee" | "ranged"),
    //       metric ("Damage dealt"), primeStage}
    O.context = function (c) {
        var agg = FFXI.aggregate_buffs(c.selection);
        return {job: c.job.toLowerCase(), sub: (c.sub || "war").toLowerCase(), ml: c.ml || 0, buffs: agg[0], abilities: c.abilities || {},
            enemy: FFXI.make_enemy(c.enemy, agg[1]), ws: c.ws, wsType: c.wsType || "melee", metric: c.metric || "Damage dealt",
            primeStage: c.primeStage};
    };
    // The slots a piece leaves empty: "Cannot equip leggear" (Onca Suit), headgear, handgear, footgear
    var BLOCK = {headgear: "head", handgear: "hands", hand: "hands", leggear: "legs", footgear: "feet"};
    O.blocks = function (piece) {
        var item = piece && piece.name && O.item(piece.name, piece.id), out = [];
        ((item && item.unparsed) || []).forEach(function (t) {
            var m = String(t).match(/Cannot equip (\w+)/i);
            if (m && BLOCK[m[1].toLowerCase()]) out.push(BLOCK[m[1].toLowerCase()]);
        });
        return out;
    };
    // Every slot a set's pieces leave empty
    O.blocked = function (pieces) {
        var out = {};
        PAGE_SLOTS.forEach(function (slot) { O.blocks(pieces[slot]).forEach(function (b) { out[b] = true; }); });
        return out;
    };
    // The engine's gear set from the page's pieces ({page slot: piece}); null when a piece is unknown.
    // A slot another piece blocks is empty.
    O.gearset = function (ctx, pieces) {
        var set = {}, blocked = O.blocked(pieces);
        for (var i = 0; i < PAGE_SLOTS.length; i++) {
            var slot = PAGE_SLOTS[i], g = blocked[slot] ? O.empty() : O.gear(pieces[slot], slot, ctx);
            if (!g) return null;
            set[O.SLOT[slot]] = g;
        }
        return set;
    };
    // The weaponskill's average with those pieces at that TP: [metric value, [damage, TP return, ...]]
    O.ws = function (ctx, pieces, tp) {
        var set = O.gearset(ctx, pieces);
        if (!set) return null;
        var player = FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities);
        return FFXI.average_ws(player, ctx.enemy, ctx.ws, tp, ctx.wsType, ctx.metric);
    };

    // ------------------------------------------------------------ TP bonus
    // The pieces the job's rule adds before a weaponskill (shared/utils/weaponskill/tp_bonus_calculator.lua):
    // rule = {bonus (weapon, buffs, Fencer), pieces [{slot, name, bonus}]}; the set's own TP pieces count;
    // one piece that closes the gap is the smallest that does, else the biggest first.
    O.tpPieces = function (rule, pieces, tp) {
        if (!rule || !rule.pieces) return {};
        var worn = 0, left = [];
        rule.pieces.forEach(function (p) {
            var on = pieces[p.slot];
            if (on && on.name === p.name) worn += p.bonus; else left.push(p);
        });
        var eff = tp + (rule.bonus || 0) + worn, th = eff < 2000 ? 2000 : eff < 3000 ? 3000 : 0;
        if (!th) return {};
        var gap = th - eff, total = left.reduce(function (n, p) { return n + p.bonus; }, 0);
        if (gap > total) return {};
        var asc = left.slice().sort(function (a, b) { return a.bonus - b.bonus; });
        for (var i = 0; i < asc.length; i++) if (asc[i].bonus >= gap) { var one = {}; one[asc[i].slot] = {name: asc[i].name}; return one; }
        var out = {}, got = 0;
        asc.reverse().forEach(function (p) { if (got < gap) { out[p.slot] = {name: p.name}; got += p.bonus; } });
        return out;
    };

    // ------------------------------------------------------------ search
    // The defensive totals of a set's gear: DT + PDT, DT + MDT (Shell not counted), Subtle Blow I + II
    O.defense = function (set) {
        var sum = function (k) { var n = 0; for (var sl in set) n += set[sl][k] || 0; return n; };
        return {pdt: sum("DT") + sum("PDT"), mdt: sum("DT") + sum("MDT"), sb: sum("Subtle Blow") + sum("Subtle Blow II")};
    };
    // How far a set is from the floors (0 when it meets them): opts.floor = {pdt: -50, mdt: -21, sb: 0}
    function shortfall(def, floor) {
        if (!floor) return 0;
        return Math.max(0, def.pdt - (floor.pdt == null ? 0 : floor.pdt)) + Math.max(0, def.mdt - (floor.mdt == null ? 0 : floor.mdt))
            + Math.max(0, (floor.sb || 0) - def.sb);
    }
    // The set worn at the weaponskill: the pieces, then the TP pieces the job's rule lays at that TP
    function wornAt(pieces, opts, tp) {
        var worn = Object.assign({}, pieces), add = O.tpPieces(opts.tpRule, pieces, tp), blocked = O.blocked(pieces);
        // no TP piece on a slot another piece blocks (no Boii Cuisses under Onca Suit)
        for (var s in add) if (!blocked[s]) worn[s] = add[s];
        return worn;
    }
    // The player of a set, kept (per context) while a search tries the same set at several TP:
    // creating it is most of the cost of an evaluation
    function playerOf(ctx, worn) {
        var key = PAGE_SLOTS.map(function (sl) { var p = worn[sl]; return p ? p.name + "|" + (p.augs || []).join("|") + "|" + (p.rank == null ? "" : p.rank) : ""; }).join("#");
        var cache = ctx._players = ctx._players || {map: {}, size: 0};
        if (cache.map[key]) return cache.map[key];
        var set = O.gearset(ctx, worn);
        if (!set) return null;
        if (cache.size > 20000) { cache.map = {}; cache.size = 0; }
        cache.size++;
        return (cache.map[key] = {player: FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities), def: O.defense(set)});
    }
    // One weaponskill: the engine's [value, [damage, TP return]] for the objective
    function once(ctx, worn, tp, metric) {
        var pl = playerOf(ctx, worn);
        if (!pl) return null;
        return {r: FFXI.average_ws(pl.player, ctx.enemy, ctx.ws, tp, ctx.wsType, metric), def: pl.def};
    }
    // A set's value for opts.objective: "damage" at opts.tp, "damage_avg" over opts.tps, "tp_return"
    // (damage breaks ties); a set short of the floors loses 1e6 per point, so the search meets them first
    O.value = function (ctx, pieces, opts) {
        var tps = opts.objective === "damage_avg" ? (opts.tps || [1000, 1500, 2000, 2500, 3000]) : [opts.tp];
        var metric = opts.objective === "tp_return" ? "TP return" : "Damage dealt", total = 0, def = null;
        for (var i = 0; i < tps.length; i++) {
            var e = once(ctx, wornAt(pieces, opts, tps[i]), tps[i], metric);
            if (!e) return {v: -Infinity};
            def = def || e.def;
            total += opts.objective === "tp_return" ? e.r[1][1] + e.r[1][0] / 1e6 : e.r[1][0];
        }
        var v = total / tps.length, miss = shortfall(def, opts.floor);
        return {v: v - 1e6 * miss, raw: v, def: def, miss: miss};
    };
    function score(ctx, pieces, opts) { return O.value(ctx, pieces, opts).v; }
    // A copy can go on two slots (rings, earrings) only when there are two of it
    function clashes(pieces, slot, piece) {
        var twin = {ring1: "ring2", ring2: "ring1", ear1: "ear2", ear2: "ear1"}[slot];
        if (!twin || !piece || !pieces[twin]) return false;
        var o = pieces[twin];
        return o.name === piece.name && (o.augs || []).join("|") === (piece.augs || []).join("|") && !(piece.copies > 1);
    }
    O.clashes = function (pieces, slot, piece) { return clashes(pieces, slot, piece); };
    // choices: {page slot: [piece...]} (fixed slots left out); opts: {tp, tpRule, passes, top, onStep}.
    // Slot by slot until nothing improves, then every pair of slots over their best few pieces
    // (a pair can beat two single moves: two pieces reaching a cap together).
    O.optimize = function (ctx, start, choices, opts) {
        var st = {best: Object.assign({}, start), evals: 0};
        st.score = score(ctx, st.best, opts);
        var slots = Object.keys(choices), rounds = opts.rounds || 6;
        for (var round = 0; round < rounds; round++) {
            singles(ctx, st, slots, choices, opts);
            if (!pairs(ctx, st, slots, shortlist(ctx, st, slots, choices, opts, opts.top || 8), opts)) break;
        }
        return {pieces: st.best, score: st.score, best: O.value(ctx, st.best, opts), start: O.value(ctx, start, opts), evals: st.evals};
    };
    // Each slot's `keep` best pieces as single swaps from `start` (pieces flagged keep always stay):
    // a first sort before searching hundreds of pieces a slot (every item of the game)
    O.prefilter = function (ctx, start, choices, opts, keep) {
        var out = {};
        Object.keys(choices).forEach(function (slot) {
            var rated = choices[slot].map(function (piece) {
                var trial = Object.assign({}, start); trial[slot] = piece;
                return {piece: piece, v: score(ctx, trial, opts)};
            }).sort(function (a, b) { return b.v - a.v; });
            out[slot] = rated.filter(function (x, i) { return i < keep || x.piece.keep; }).map(function (x) { return x.piece; });
        });
        return out;
    };
    // A set's value (the objective, floors counted) with one slot changed
    O.valueWith = function (ctx, pieces, slot, piece, opts) {
        var trial = Object.assign({}, pieces); trial[slot] = piece;
        return O.value(ctx, trial, opts);
    };
    // A move kept when it improves the set (st: {best, score, evals})
    function tryMove(ctx, st, trial, opts) {
        var v = score(ctx, trial, opts); st.evals++;
        if (v > st.score + 1e-9) { st.best = trial; st.score = v; return true; }
        return false;
    }
    // Slot by slot, every piece, until a full pass changes nothing
    function singles(ctx, st, slots, choices, opts) {
        for (var pass = 0; pass < (opts.passes || 6); pass++) {
            var moved = false;
            slots.forEach(function (slot) {
                choices[slot].forEach(function (piece) {
                    if (clashes(st.best, slot, piece)) return;
                    var trial = Object.assign({}, st.best); trial[slot] = piece;
                    if (tryMove(ctx, st, trial, opts)) moved = true;
                });
            });
            if (!moved) return;
        }
    }
    // The best few pieces of each slot, the others staying as they are
    function shortlist(ctx, st, slots, choices, opts, top) {
        var out = {};
        slots.forEach(function (slot) {
            out[slot] = choices[slot].map(function (piece) {
                if (clashes(st.best, slot, piece)) return null;
                var trial = Object.assign({}, st.best); trial[slot] = piece; st.evals++;
                return {piece: piece, v: score(ctx, trial, opts)};
            }).filter(Boolean).sort(function (a, b) { return b.v - a.v; }).slice(0, top).map(function (x) { return x.piece; });
        });
        return out;
    }
    // Every pair of slots over their shortlists: two pieces can beat two single moves (a cap
    // reached together, a floor met by one while the other gains); true when the set changed
    function pairs(ctx, st, slots, list, opts) {
        var moved = false;
        for (var i = 0; i < slots.length; i++) for (var j = i + 1; j < slots.length; j++) {
            var a = slots[i], b = slots[j];
            list[a].forEach(function (pa) {
                list[b].forEach(function (pb) {
                    var trial = Object.assign({}, st.best); trial[a] = pa; trial[b] = pb;
                    if (clashes(trial, a, pa) || clashes(trial, b, pb)) return;
                    if (tryMove(ctx, st, trial, opts)) moved = true;
                });
            });
        }
        return moved;
    }

});

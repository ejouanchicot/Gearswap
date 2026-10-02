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
    // The engine's gear set from the page's pieces ({page slot: piece}); null when a piece is unknown
    O.gearset = function (ctx, pieces) {
        var set = {};
        for (var i = 0; i < PAGE_SLOTS.length; i++) {
            var slot = PAGE_SLOTS[i], g = O.gear(pieces[slot], slot, ctx);
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
        var worn = Object.assign({}, pieces), add = O.tpPieces(opts.tpRule, pieces, tp);
        for (var s in add) worn[s] = add[s];
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
    // choices: {page slot: [piece...]} (fixed slots left out); opts: {tp, tpRule, passes, top, onStep}.
    // Slot by slot until nothing improves, then every pair of slots over their best few pieces
    // (a pair can beat two single moves: two pieces reaching a cap together).
    O.optimize = function (ctx, start, choices, opts) {
        var best = Object.assign({}, start), bestScore = score(ctx, best, opts), evals = 1;
        var slots = Object.keys(choices), passes = opts.passes || 4;
        for (var pass = 0; pass < passes; pass++) {
            var moved = false;
            slots.forEach(function (slot) {
                choices[slot].forEach(function (piece) {
                    if (clashes(best, slot, piece)) return;
                    var trial = Object.assign({}, best); trial[slot] = piece;
                    var v = score(ctx, trial, opts); evals++;
                    if (v > bestScore + 1e-9) { best = trial; bestScore = v; moved = true; }
                });
            });
            if (!moved) break;
        }
        var top = opts.top || 4;
        // the best few pieces of each slot, the others staying as they are
        var shortlist = {};
        slots.forEach(function (slot) {
            shortlist[slot] = choices[slot].map(function (piece) {
                if (clashes(best, slot, piece)) return null;
                var trial = Object.assign({}, best); trial[slot] = piece; evals++;
                return {piece: piece, v: score(ctx, trial, opts)};
            }).filter(Boolean).sort(function (a, b) { return b.v - a.v; }).slice(0, top).map(function (x) { return x.piece; });
        });
        for (var i = 0; i < slots.length; i++) for (var j = i + 1; j < slots.length; j++) {
            var a = slots[i], b = slots[j];
            shortlist[a].forEach(function (pa) {
                shortlist[b].forEach(function (pb) {
                    var trial = Object.assign({}, best); trial[a] = pa; trial[b] = pb;
                    if (clashes(trial, a, pa) || clashes(trial, b, pb)) return;
                    var v = score(ctx, trial, opts); evals++;
                    if (v > bestScore + 1e-9) { best = trial; bestScore = v; }
                });
            });
        }
        return {pieces: best, score: bestScore, best: O.value(ctx, best, opts), start: O.value(ctx, start, opts), evals: evals};
    };
});

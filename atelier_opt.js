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
    // A physical weaponskill wsdist leaves out (Avalanche Axe...), from the project's weaponskill
    // database (shared/data/weaponskills, exported as ws_info): fTP at 1000/2000/3000, its stat
    // modifiers, its hits, fTP on every hit or the first. Critical rates by TP are not in that
    // database: such a weaponskill is counted without them. Magical and hybrid ones are not made
    // (element, dINT and magic burst are no guess): false is returned.
    var STATS = {STR: "str", DEX: "dex", VIT: "vit", AGI: "agi", INT: "int", MND: "mnd", CHR: "chr"};
    O.defineWs = function (name, info, skill) {
        if (!FFXI.WS || FFXI.WS[name]) return !!(FFXI.WS && FFXI.WS[name]);
        if (!info || (info.type && info.type !== "Physical") || !info.ftp) return false;
        var mods = {};
        if (typeof info.mods === "string") info.mods.replace(/(\d+)\D*%?\s*(STR|DEX|VIT|AGI|INT|MND|CHR)/g, function (m, pct, st) { mods[st] = +pct; });
        else Object.keys(info.mods || {}).forEach(function (k) { mods[k.toUpperCase()] = +info.mods[k]; });
        var f = info.ftp, f1 = +f["1000"] || 1, f2 = +f["2000"] || f1, f3 = +f["3000"] || f2;
        FFXI.WS[name] = {skill: skill || "", sc: [], generic: true, set: function (v, tp) {
            v.ftp = tp <= 2000 ? f1 + (f2 - f1) * (tp - 1000) / 1000 : f2 + (f3 - f2) * (tp - 2000) / 1000;
            v.ftp_rep = !!info.replicating;
            v.wsc = 0;
            Object.keys(mods).forEach(function (st) { if (STATS[st]) v.wsc += mods[st] / 100 * v["player_" + STATS[st]]; });
            v.nhits = info.hits || 1;
        }};
        return true;
    };
    O.context = function (c) {
        if (c.wsInfo) O.defineWs(c.ws, c.wsInfo, c.wsSkill);
        var agg = FFXI.aggregate_buffs(c.selection);
        // Distract's Evasion down, worked out by the page (its tier, Saboteur on a monster or an NM)
        if (c.evaDown) agg[1].Evasion = (agg[1].Evasion || 0) + c.evaDown;
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

    // ------------------------------------------------------------ one reward among several
    // Mission rewards where one item is chosen among several (BG Wiki): owning one rules the others
    // out, and two of a group are never worn together
    O.EXCLUSIVE = [
        {name: "The Voracious Resurgence 11-2", items: ["Medada's Ring", "Gurebu's Ring", "Cornelia's Ring", "Ragelise's Ring", "Lehko's Ring", "Fickblix's Ring", "Ephramad's Ring"]},
        {name: "Seekers of Adoulin 4-3-8", items: ["Adoulin's Refuge", "Ygnas's Resolve", "Arciela's Grace"]},
        {name: "Seekers of Adoulin 4-6-1", items: ["Adoulin's Refuge +1", "Ygnas's Resolve +1", "Arciela's Grace +1"]},
        {name: "Seekers of Adoulin 5-5-1", items: ["Adoulin Ring", "Gorney Ring", "Haverton Ring", "Janniston Ring", "Karieyh Ring", "Orvail Ring", "Renaye Ring", "Shneddick Ring", "Thurandaut Ring", "Vocane Ring", "Weather. Ring"]},
        {name: "Seekers of Adoulin epilogue", items: ["Adoulin Ring +1", "Gorney Ring +1", "Haverton Ring +1", "Janniston Ring +1", "Karieyh Ring +1", "Orvail Ring +1", "Renaye Ring +1", "Shneddick Ring +1", "Thurandaut Ring +1", "Vocane Ring +1", "Weather. Ring +1"]},
        {name: "Rhapsodies of Vana'diel epilogue", items: ["Ligeia Ring", "Ligeia Sash", "Ligeia Scythe"]}
    ];
    O.groupOf = function (name) {
        for (var i = 0; i < O.EXCLUSIVE.length; i++) if (O.EXCLUSIVE[i].items.indexOf(name) !== -1) return O.EXCLUSIVE[i];
        return null;
    };

    // ------------------------------------------------------------ search
    // The defensive totals of a set's gear: DT + PDT, DT + MDT (Shell not counted), Subtle Blow I + II
    O.defense = function (set) {
        var sum = function (k) { var n = 0; for (var sl in set) n += set[sl][k] || 0; return n; };
        return {pdt: sum("DT") + sum("PDT"), mdt: sum("DT") + sum("MDT"), sb: sum("Subtle Blow") + sum("Subtle Blow II")};
    };
    // How far a set is from the floors (0 when it meets them): opts.floor = {pdt: -50, mdt: -21, sb: 0, hit: 0},
    // hit the weaponskill's hit rate in % (O.hit)
    function shortfall(def, floor, hit) {
        if (!floor) return 0;
        return Math.max(0, def.pdt - (floor.pdt == null ? 0 : floor.pdt)) + Math.max(0, def.mdt - (floor.mdt == null ? 0 : floor.mdt))
            + Math.max(0, (floor.sb || 0) - def.sb) + (floor.hit && hit != null ? Math.max(0, floor.hit - hit) : 0);
    }
    // The hit rates (%) of a weaponskill, as FFXI.average_ws counts them (actions.js): [its first hit
    // (+100 accuracy), the hits after it and the extra hits of a double / triple attack], the main hand's
    // accuracy for that weaponskill at that TP against the target's Evasion, capped at 99 % one-handed,
    // 95 % two-handed; null for a ranged one
    var ONE_HANDED = ["Axe", "Club", "Dagger", "Sword", "Katana", "Hand-to-Hand"];
    function hitAt(ctx, player, tp) {
        if (ctx.wsType === "ranged") return null;
        var s = player.stats, g = player.gearset, skill = (g.main || {})["Skill Type"];
        var dual = (g.sub || {}).Type === "Weapon" || skill === "Hand-to-Hand";
        var at = Math.max(1000, Math.min(3000, tp + (s["TP Bonus"] || 0)));
        var info = FFXI.weaponskill_info(ctx.ws, at, player, ctx.enemy, s.WSC || [], dual);
        var cap = ONE_HANDED.indexOf(skill) !== -1 ? 0.99 : 0.95;
        var acc = info.player_accuracy1 + (s["Weapon Skill Accuracy"] || 0), eva = ctx.enemy.stats.Evasion;
        return [100 * FFXI.get_hit_rate(acc + 100, eva, cap), 100 * FFXI.get_hit_rate(acc, eva, cap)];
    }
    // A set's hit rates at the weaponskill, {first, rest}: the lowest over the TP looked at (a
    // weaponskill's accuracy bonus grows with TP); the floor reads `rest`
    O.hits = function (ctx, pieces, opts) {
        var tps = opts.objective === "damage_avg" ? (opts.tps || [opts.tp]) : [opts.tp], low = null;
        for (var i = 0; i < tps.length; i++) {
            var pl = playerOf(ctx, wornAt(pieces, opts, tps[i]));
            var h = pl ? hitAt(ctx, pl.player, tps[i]) : null;
            if (h && (!low || h[1] < low.rest)) low = {first: h[0], rest: h[1]};
        }
        return low;
    };
    O.hit = function (ctx, pieces, opts) { var h = O.hits(ctx, pieces, opts); return h ? h.rest : null; };
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
        var hit = opts.floor && opts.floor.hit ? O.hit(ctx, pieces, opts) : null;
        var v = total / tps.length, miss = shortfall(def, opts.floor, hit);
        return {v: v - 1e6 * miss, raw: v, def: def, miss: miss};
    };
    function score(ctx, pieces, opts) { return O.value(ctx, pieces, opts).v; }
    // A copy can go on two slots (rings, earrings) only when there are two of it
    function clashes(pieces, slot, piece) {
        // another item of the same one-choice group worn elsewhere
        var group = piece && O.groupOf(piece.name);
        if (group) for (var sl in pieces) if (sl !== slot && pieces[sl] && pieces[sl].name !== piece.name && group.items.indexOf(pieces[sl].name) !== -1) return true;
        var twin = {ring1: "ring2", ring2: "ring1", ear1: "ear2", ear2: "ear1"}[slot];
        if (!twin || !piece || !pieces[twin]) return false;
        var o = pieces[twin];
        return o.name === piece.name && (o.augs || []).join("|") === (piece.augs || []).join("|") && !(piece.copies > 1);
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
            out.push({slot: slot, piece: p, gain: (res.best.v / alt - 1) * 100});
        });
        return out.sort(function (a, b) { return b.gain - a.gain; });
    };
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
    // A whole run from plain data (what a worker receives): {ctx: O.context's input, start, choices,
    // opts, prefilter (keep each slot's best n first)}; onStep(progress) while it searches
    O.run = function (input, onStep) {
        var ctx = O.context(input.ctx), opts = Object.assign({}, input.opts, {onStep: onStep});
        var choices = input.prefilter ? O.prefilter(ctx, input.start, input.choices, opts, input.prefilter) : input.choices;
        var res = O.optimize(ctx, input.start, choices, opts);
        tpOnlyOut(ctx, res, choices, opts);
        res.best.hits = O.hits(ctx, res.pieces, opts);
        res.start.hits = O.hits(ctx, input.start, opts);
        delete opts.onStep;
        return {pieces: res.pieces, best: res.best, start: res.start, evals: res.evals, gains: O.gains(ctx, res, choices, opts)};
    };
    // choices: {page slot: [piece...]} (fixed slots left out); opts: {tp, tpRule, passes, top, onStep}.
    // Slot by slot until nothing improves, then every pair of slots over their best few pieces
    // (a pair can beat two single moves: two pieces reaching a cap together).
    O.optimize = function (ctx, start, choices, opts) {
        var st = {best: Object.assign({}, start), evals: 0};
        st.score = score(ctx, st.best, opts);
        var slots = Object.keys(choices), rounds = opts.rounds || 6;
        var step = function (round) { if (opts.onStep) opts.onStep({round: round + 1, evals: st.evals, score: st.score}); };
        for (var round = 0; round < rounds; round++) {
            singles(ctx, st, slots, choices, opts); step(round);
            var more = pairs(ctx, st, slots, shortlist(ctx, st, slots, choices, opts, opts.top || 8, opts.extra || 4), opts); step(round);
            if (!more) break;
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
    // Three lists a slot, from one try of each piece on the set: the `top` best (floors counted), the
    // `extra` best for damage alone (floors ignored: a strong piece that drops the defense under a floor)
    // and the `extra` best for defense (DT+PDT and DT+MDT: the piece that can pay for it elsewhere)
    function shortlist(ctx, st, slots, choices, opts, top, extra) {
        var out = {};
        slots.forEach(function (slot) {
            var rated = choices[slot].map(function (piece) {
                if (clashes(st.best, slot, piece)) return null;
                var trial = Object.assign({}, st.best); trial[slot] = piece; st.evals++;
                var r = O.value(ctx, trial, opts), d = r.def || {};
                return r.v === -Infinity ? null : {piece: piece, v: r.v, raw: r.raw, dt: (d.pdt || 0) + (d.mdt || 0)};
            }).filter(Boolean);
            var best = function (key, n, low) {
                return rated.slice().sort(function (x, y) { return low ? x[key] - y[key] : y[key] - x[key]; }).slice(0, n).map(function (x) { return x.piece; });
            };
            out[slot] = {top: best('v', top), raw: best('raw', extra), dt: best('dt', extra, true)};
        });
        return out;
    }
    // Pairs of slots: the best pieces of both (two pieces can beat two single moves: a cap reached
    // together), and a strong piece for damage with a defense piece elsewhere that keeps the floors
    // (Agoge Mask under the floor alone, with a Gelatinous Ring that pays its DT back); true when the set changed
    function pairs(ctx, st, slots, list, opts) {
        var moved = false;
        var cross = function (a, b, la, lb) {
            la.forEach(function (pa) {
                lb.forEach(function (pb) {
                    var trial = Object.assign({}, st.best); trial[a] = pa; trial[b] = pb;
                    if (clashes(trial, a, pa) || clashes(trial, b, pb)) return;
                    if (tryMove(ctx, st, trial, opts)) moved = true;
                });
            });
        };
        for (var i = 0; i < slots.length; i++) for (var j = i + 1; j < slots.length; j++) {
            var a = slots[i], b = slots[j];
            cross(a, b, list[a].top, list[b].top);
            cross(a, b, list[a].raw, list[b].dt);
            cross(a, b, list[a].dt, list[b].raw);
        }
        return moved;
    }

});

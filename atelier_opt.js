// Atelier optimizer: the page's sets, buffs and target turned into the engine's player and enemy
// (atelier-engine, kept on this PC only), a weaponskill's average damage, and
// the search for the best set. One part of the engine (FFXI_PARTS): no DOM, no page state, so it
// also runs in a Web Worker (FFXI.workerSource).
//
//   FFXI.opt.gear(piece, slot, ctx)   one piece as the engine reads it (catalogue + its augments)
//   FFXI.opt.selection(b)             the page's buff state as FFXI.aggregate_buffs takes it
//   FFXI.opt.context(...)             player, buffs, target and weaponskill of one evaluation
//   FFXI.opt.ws(ctx, pieces, tp)      the weaponskill's average damage with those pieces
//   FFXI.opt.round(ctx, pieces, opts)  an engaged set's attack round: time to the weaponskill, DPS, TP a round
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
        // a bonus that works in one ear only (the Empyrean earrings' "Right ear:"), in that ear (ear2 = right_ear)
        if (item.slot_stats && item.slot_stats[slot]) add(item.slot_stats[slot]);
        if (FFXI.parse_augments && (piece.augs && piece.augs.length || piece.rank != null)) add(FFXI.parse_augments(item.name, piece.augs || [], piece.rank).stats);
        // a piece worn for one augment only, whatever its other one (Moonshade Earring: its TP Bonus +250)
        var only = ONLY_STATS[item.name];
        if (only) { for (var k in g) if (typeof g[k] === "number" && k !== "DMG" && k !== "Delay") delete g[k]; add(only); }
        return g;
    };
    var ONLY_STATS = {"Moonshade Earring": {"TP Bonus": 250}};

    // ------------------------------------------------------------ buffs
    // The page's buff state (atelier.html buffState) as FFXI.aggregate_buffs takes it
    var FOOD_KEYS = {str: "STR", dex: "DEX", vit: "VIT", agi: "AGI", int: "INT", mnd: "MND", chr: "CHR", acc: "Accuracy",
        atkf: "Attack", racc: "Ranged Accuracy", ratkf: "Ranged Attack", mab: "Magic Attack", macc: "Magic Accuracy",
        hp: "HP", mp: "MP", sb: "Subtle Blow", stp: "Store TP", da: "DA"};
    // The songs as the engine reads them: Song1..Song4, Song5 under Clarion Call; the song under Marcato first,
    // the engine laying Marcato on Song1 (the page's b.marcato is that song's place)
    function songsOf(b) {
        // Aria of Passion is left to the page (its Loughnashade stage: the context's ariaPdl)
        var list = [b.song0, b.song1, b.song2, b.song3].concat(b.clarion ? [b.song4] : []).map(function (x) { return x && x !== "Aria of Passion" ? x : "None"; });
        if (b.marcato != null && !b.soulVoice && list[b.marcato]) list.unshift(list.splice(b.marcato, 1)[0]);
        var out = {};
        list.forEach(function (x, i) { out["Song" + (i + 1)] = x; });
        return out;
    }
    var HASTE_AS = {"Hastega": "Haste", "Hastega II": "Haste II"};
    O.selection = function (b, food) {
        var f = null;
        if (food) { f = {}; for (var k in food) if (FOOD_KEYS[k]) f[FOOD_KEYS[k]] = food[k]; }
        var bubble = function (kind, v) { return v ? kind + v : "None"; };
        return {
            brd: true, songs: songsOf(b), song_bonus: +(b.songsPlus || 0), soul_voice: !!b.soulVoice,
            marcato: b.marcato != null && !b.soulVoice,
            cor: true, rolls: {Roll1: {name: b.roll0 || "None", potency: b.roll0n || "XI"}, Roll2: {name: b.roll1 || "None", potency: b.roll1n || "XI"}},
            roll_bonus: +(b.rollsPlus || 0), crooked: false, job_bonus: false, light_shot: !!(b.lightshot && /^Dia/.test(b.dia || "")),
            geo: true, bubbles: {"Indi-": bubble("Indi-", b.indi), "Geo-": bubble("Geo-", b.geo), "Entrust-": bubble("Entrust-", b.entrust)},
            bubble_bonus: +(b.geoPlus || 0), bolster: false, bog: false, bubble_potency: 100,
            // Garuda's Hastega / Hastega II read as Haste / Haste II (the same effect), Hastega's 3/1024 more added in context
            whm: true, whm_spells: {Dia: /^Dia/.test(b.dia || "") ? b.dia : "None", Haste: HASTE_AS[b.haste] || b.haste || "None", Boost: "None", Storm: b.storm || "None"},
            haste_extra: b.haste === "Hastega" ? 3 / 1024 : 0,
            shell5: b.shell === "Shell V", food: f, toggles: {}
        };
    };

    // ------------------------------------------------------------ evaluation
    // ctx: {job, sub, ml, buffs, abilities, enemy (create_enemy), ws, wsType ("melee" | "ranged"),
    //       metric ("Damage dealt"), primeStage}
    // A physical weaponskill the engine leaves out (Avalanche Axe...), from the project's weaponskill
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
    // The buffs with each bubble at the page's multiplier (Bolster, Blaze of Glory, Ecliptic Attrition, and an
    // NM's resistance to the debuffs: the page's geoMul): everything but the bubbles, then each bubble alone, scaled
    var GEO_SLOTS = {"Indi-": "indi", "Geo-": "geo", "Entrust-": "entrust"};
    function geoScaled(sel, mul) {
        var agg = FFXI.aggregate_buffs(Object.assign({}, sel, {geo: false}));
        agg[0].geo = agg[0].geo || {};
        // each bubble alone, scaled; the same effect twice (Indi- and Geo- Fury) does not stack: the strongest counts
        var best = {};
        Object.keys(GEO_SLOTS).forEach(function (slot) {
            var bubbles = {"Indi-": "None", "Geo-": "None", "Entrust-": "None"}, name = (sel.bubbles || {})[slot] || "None";
            bubbles[slot] = name;
            if (name === "None") return;
            var one = FFXI.aggregate_buffs({geo: true, bubbles: bubbles, bubble_bonus: sel.bubble_bonus, bolster: false, bog: false,
                bubble_potency: sel.bubble_potency, food: null, toggles: {}});
            var m = mul[GEO_SLOTS[slot]] || 1, size = 0, k, effect = name.split("-").pop();
            for (k in one[0].geo || {}) size += Math.abs(m * one[0].geo[k]);
            for (k in one[1]) size += Math.abs(m * one[1][k]);
            if (!best[effect] || size > best[effect].size) best[effect] = {one: one, m: m, size: size};
        });
        Object.keys(best).forEach(function (effect) {
            var one = best[effect].one, m = best[effect].m, k;
            for (k in one[0].geo || {}) agg[0].geo[k] = (agg[0].geo[k] || 0) + m * one[0].geo[k];
            // an offensive bubble on an NM: what its resistance leaves (the page's geoMul.foe)
            for (k in one[1]) agg[1][k] = (agg[1][k] || 0) + m * (mul.foe == null ? 1 : mul.foe) * one[1][k];
        });
        return agg;
    }
    O.context = function (c) {
        if (c.wsInfo) O.defineWs(c.ws, c.wsInfo, c.wsSkill);
        var agg = c.geoMul ? geoScaled(c.selection, c.geoMul) : FFXI.aggregate_buffs(c.selection);
        // Distract's Evasion down, worked out by the page (its tier, Saboteur on a monster or an NM)
        if (c.evaDown) agg[1].Evasion = (agg[1].Evasion || 0) + c.evaDown;
        if (c.ariaPdl) agg[0].brd.PDL = (agg[0].brd.PDL || 0) + c.ariaPdl;
        if (c.selection.haste_extra) agg[0].whm["Magic Haste"] = (agg[0].whm["Magic Haste"] || 0) + c.selection.haste_extra;
        // the rolls again, each alone with its own job bonus and Crooked Cards (the engine has one switch for both rolls)
        if (c.rollOpts && c.selection.cor) {
            agg[0].cor = {};
            [1, 2].forEach(function (n, i) {
                var roll = (c.selection.rolls || {})["Roll" + n], opt = c.rollOpts[i] || {};
                if (!roll || roll.name === "None") return;
                var one = FFXI.aggregate_buffs({cor: true, rolls: {Roll1: roll}, roll_bonus: c.selection.roll_bonus, job_bonus: !!opt.job,
                    crooked: !!opt.cc, light_shot: false, food: null, toggles: {}});
                for (var k in one[0].cor) agg[0].cor[k] = (agg[0].cor[k] || 0) + one[0].cor[k];
            });
        }
        // the abilities on the target, worked out by the page (one Defense Down effect, the strongest, and Box Step)
        if (c.foeDown && c.foeDown.def) agg[1].Defense = (agg[1].Defense || 0) + c.foeDown.def;
        if (c.foeDown && c.foeDown.mdb) agg[1]["Magic Defense"] = (agg[1]["Magic Defense"] || 0) + c.foeDown.mdb;
        // the elemental debuffs and Impact on its stats, Feather Step on your critical hits
        if (c.foeDown && c.foeDown.stats) Object.keys(c.foeDown.stats).forEach(function (st) { agg[1][st] = (agg[1][st] || 0) + c.foeDown.stats[st]; });
        if (c.foeDown && c.foeDown.crit) agg[0].feather_step = {"Crit Rate": c.foeDown.crit};
        // a RUN's Gambit: the magic damage of its runes' element taken +10 % a rune, for a weaponskill of that element
        var probe = wsProbe(c);
        if (c.foeDown && c.foeDown.gambit && probe && (probe.magical || probe.hybrid) && probe.element === c.foeDown.gambit.elem)
            agg[1]["Magic DT%"] = (agg[1]["Magic DT%"] || 0) + c.foeDown.gambit.pct;
        // a party WAR's Warcry: its attack and the TP Bonus of its Savagery merits and Agoge Mask, worked out by
        // the page (the engine's own "Warcry" is a WAR's: 700 TP Bonus and +60 attack)
        if (c.partyWarcry != null) agg[0].party_warcry = {"Attack%": Math.trunc(99 / 4 + 4.75) / 256, "TP Bonus": c.partyWarcry};
        // a WAR main's own Warcry: the engine counts 700 TP Bonus (Savagery 5/5 with Agoge Mask); the page's choice moves it
        if (c.warcryTpDelta) agg[0].own_warcry = {"TP Bonus": c.warcryTpDelta};
        // a party SMN's Avatar's Favor at BG Wiki's top values (the page's partyStats; the engine's own are lower or higher)
        if (c.partyStats && Object.keys(c.partyStats).length) agg[0].party_favor = c.partyStats;
        return {job: c.job.toLowerCase(), sub: (c.sub || "war").toLowerCase(), ml: c.ml || 0, buffs: agg[0], abilities: c.abilities || {},
            enemy: FFXI.make_enemy(c.enemy, agg[1]), ws: c.ws, wsType: c.wsType || "melee", metric: c.metric || "Damage dealt",
            primeStage: c.primeStage, dmgMul: physMul(c), mode: c.mode || "ws", sbBuff: c.sbBuff || 0,
            physResBy: c.physResBy || null, banish: c.banish, tomahawk: c.tomahawk};
    };
    // The target's resistance to the weaponskill's damage type (the page's physRes, percent: +25 takes more, -25
    // resists), Tomahawk cutting a resistance by a quarter (BG Wiki: 50 % -> 37 %), Banish II by 70 % on an undead;
    // for a physical weaponskill only,
    // the engine already counts a magical one's (Magic DT%)
    // A weaponskill's own flags (magical, hybrid, element), read by setting it up once on blank stats; null when it
    // cannot be read
    function wsProbe(c) {
        var w = FFXI.WS[c.ws], v = {};
        if (!w) return null;
        try { w.set(v, 1000, {stats: {}}, {stats: {}}); } catch (e) { return null; }
        return v;
    }
    function physMul(c) {
        // an engaged set's auto-attacks are physical, of the main weapon's type (the page's physRes)
        var r = c.physRes || 0, v = !r ? null : c.mode === "engaged" ? {} : wsProbe(c);
        if (!v || v.magical || v.hybrid) return 1;
        // a resistance cut: Banish II's 70 % (an undead) or Tomahawk's 25 %, the stronger
        return 1 + (r < 0 && c.banish ? r * 0.3 : r < 0 && c.tomahawk ? r * 0.75 : r) / 100;
    }
    // A result of FFXI.average_ws with its damage scaled by ctx.dmgMul (the TP return untouched)
    function scaled(ctx, r, metric) {
        var m = ctx.dmgMul || 1;
        if (!r || m === 1) return r;
        return [metric === "TP return" ? r[0] : r[0] * m, [r[1][0] * m, r[1][1], r[1][2]]];
    }
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
    // An engaged set's attack round (the engine's average_attack_round, from 0 TP to the weaponskill at opts.wsAt, 1000
    // by default): {time: seconds to the weaponskill, dps, tp: TP a round, damage: a round's}; null for an unknown piece
    var ROUND_OBJ = {tp_real: "Time to WS", tp_time: "Time to WS", dps: "DPS", tp_round: "TP return"};
    // The hits landing in one round, as a distribution {hits: probability}: each hand swings once, plus a Quadruple
    // (3 more), else a Triple (2), else a Double Attack (1), each swing landing at the hand's hit rate
    // A hand's swings in one round, as a distribution {swings: chance}, in the game's order (BG Wiki Multi-Attack):
    // Quadruple, Triple, Double Attack, then, when none of them happened, the weapon's "Occasionally attacks X times":
    // one draw among its outcomes (a Kraken Club's 2 to 8 at 15/25/25/15/10/3/2 %, else one; a mythic's aftermath
    // twice 40 %, thrice 20 %), as BG Wiki measured it (Kraken Club: 4.05 attacks a swing).
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
        for (var r = 1; r <= 40; r++) {
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
            if (!still) break;
        }
        var probs = [];
        for (var n = 1; n < cdf.length; n++) { probs.push(cdf[n - 1] - cdf[n]); mn += n * (cdf[n - 1] - cdf[n]); }
        return {rounds: mn, time: mn * x.timeRound, probs: probs, tpAt: x.start + mn * x.tpRound, dist: dist};
    };
    O.round = function (ctx, pieces, opts) {
        var set = O.gearset(ctx, pieces);
        if (!set) return null;
        var r = roundOf(ctx, FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities), opts || {});
        // the attacks a round, shown with a set (left out of the search's tries: it does not move the objective)
        if (r && r.detail) r.attacks = O.attacksOf(r.detail);
        return r;
    };
    // The target's resistance to the auto-attacks: of the main weapon the set holds (ctx.physResBy: the page's
    // resistance by combat skill), the weapon the optimizer tries when it chooses the weapons
    function roundMul(ctx, player) {
        var skill = ctx.physResBy && ((player.gearset || {}).main || {})["Skill Type"];
        if (!skill) return ctx.dmgMul || 1;
        return physMul({physRes: ctx.physResBy[skill] || 0, mode: "engaged", banish: ctx.banish, tomahawk: ctx.tomahawk});
    }
    function roundOf(ctx, player, opts) {
        var at = +opts.wsAt || 1000, r = FFXI.average_attack_round(player, ctx.enemy, 0, at, "Time to WS");
        var m = roundMul(ctx, player), dmg = r[1][0] * m, tp = r[1][1], sec = r[1][2];
        var detail = FFXI.lastRound || null, real = detail && opts.real !== false ? O.roundsOf(detail) : null;
        return {time: r[0], dps: sec ? dmg / sec : 0, tp: tp, damage: dmg, detail: detail, real: real};
    }
    // An engaged set's value for its objective: the time to the weaponskill (less is better), DPS or TP a round
    function roundValue(ctx, pieces, opts) {
        var pl = playerOf(ctx, pieces);
        if (!pl) return null;
        var obj = ROUND_OBJ[opts.objective] ? opts.objective : "tp_real";
        var r = roundOf(ctx, pl.player, Object.assign({}, opts, {real: obj === "tp_real"}));
        // speed only (damage has its DPS objective): the real time first, two sets as fast parted by the engine's average
        // time (the one that fills its rounds sooner keeps a margin)
        var raw = obj === "tp_real" ? r.real.time : obj === "tp_time" ? r.time : obj === "dps" ? r.dps : r.tp;
        var v = obj === "tp_real" ? -raw - r.time * 1e-6 : obj === "tp_time" ? -raw : raw;
        return {v: v, raw: raw, def: pl.def, round: r};
    }
    // The weaponskill's average with those pieces at that TP: [metric value, [damage, TP return, ...]]
    O.ws = function (ctx, pieces, tp) {
        var set = O.gearset(ctx, pieces);
        if (!set) return null;
        var player = FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities);
        return scaled(ctx, FFXI.average_ws(player, ctx.enemy, ctx.ws, tp, ctx.wsType, ctx.metric), ctx.metric);
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
    // The defensive totals of a set's gear: DT + PDT, DT + MDT (Shell not counted), Subtle Blow as the game caps it
    // (BG Wiki: I and II 50 each, 75 together; sbBuff, a party's Auspice, counts in I)
    O.defense = function (set, sbBuff) {
        var sum = function (k) { var n = 0; for (var sl in set) n += set[sl][k] || 0; return n; };
        var sb = Math.min(75, Math.min(50, sum("Subtle Blow") + (sbBuff || 0)) + Math.min(50, sum("Subtle Blow II")));
        return {pdt: sum("DT") + sum("PDT"), mdt: sum("DT") + sum("MDT"), sb: sb};
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
        if (ctx.mode === "engaged") return null;
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
        return (cache.map[key] = {player: FFXI.create_player(ctx.job, ctx.sub, ctx.ml, set, ctx.buffs, ctx.abilities), def: O.defense(set, ctx.sbBuff)});
    }
    // One weaponskill: the engine's [value, [damage, TP return]] for the objective
    function once(ctx, worn, tp, metric) {
        var pl = playerOf(ctx, worn);
        if (!pl) return null;
        return {r: scaled(ctx, FFXI.average_ws(pl.player, ctx.enemy, ctx.ws, tp, ctx.wsType, metric), metric), def: pl.def};
    }
    // A set's value for opts.objective: "damage" at opts.tp, "damage_avg" over opts.tps, "tp_return"
    // (damage breaks ties); a set short of the floors loses 1e6 per point, so the search meets them first
    // Between sets of the same value, the one that takes less damage, then the one that keeps more of the set's own
    // pieces (opts.base): a slot where nothing matters keeps its piece, rather than the first one tried (Baetyl Pendant,
    // first by name, for an engaged set whose accuracy is capped)
    function tieBreak(pieces, def, opts) {
        var keep = 0, base = opts.base || {};
        for (var k in base) if (pieces[k] && base[k] && pieces[k].name === base[k].name) keep++;
        return -((def && def.pdt) || 0) * 1e-10 - ((def && def.mdt) || 0) * 1e-10 + keep * 1e-12;
    }
    O.value = function (ctx, pieces, opts) {
        if (ctx.mode === "engaged") {
            var e0 = roundValue(ctx, pieces, opts);
            if (!e0) return {v: -Infinity};
            var miss0 = shortfall(e0.def, opts.floor, null);
            return {v: e0.v - 1e6 * miss0 + tieBreak(pieces, e0.def, opts), raw: e0.raw, def: e0.def, miss: miss0, round: e0.round};
        }
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
        return {v: v - 1e6 * miss + tieBreak(pieces, def, opts), raw: v, def: def, miss: miss};
    };
    function score(ctx, pieces, opts) { return O.value(ctx, pieces, opts).v; }
    // A choice put in a slot. The "weapons" choice is a main hand and its off hand together ({main, sub}): the
    // page makes only pairs the job can hold (a two-handed weapon with a grip, a shield, two weapons when it can
    // dual wield), so the search never stops on a main weapon whose off hand does not fit it
    function put(trial, slot, piece) {
        if (slot === "weapons") { trial.main = piece.main; trial.sub = piece.sub; } else trial[slot] = piece;
        return trial;
    }
    // A copy can go on two slots (rings, earrings) only when there are two of it
    function clashes(pieces, slot, piece) {
        if (slot === "weapons") return false;
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
            out.push({slot: slot, piece: p, gain: (res.best.v / alt - 1) * 100});
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
        prog.stage = "all";
        var res = yield* from(first ? first.pieces : empty, choices);
        for (var k = 0; opts.scratch && k < KICKS; k++) {
            prog.stage = "kick";
            var again = yield* from(kicked(res.pieces, choices, rnd), choices);
            if (again.score > res.score + 1e-13) res = again;
        }
        res.start = v0; res.evals = evals;
        return res;
    }
    // A whole run from plain data (what a worker receives): {ctx: O.context's input, start, choices, opts, prefilter
    // (keep each slot's best n first), starts (the walks to make, every one by default)}; its progress in opts.prog while it
    // searches. A generator: it stops after each try of a set, so a caller can spread it over time (O.runPaced)
    function* runGen(input) {
        var ctx = O.context(input.ctx), opts = Object.assign({}, input.opts, {prog: {evals: 0, moves: []}, base: input.start});
        yield opts.prog;
        var from0 = input.opts.scratch ? bare(input.start, input.choices) : input.start;
        var choices = input.prefilter ? yield* prefilterGen(ctx, from0, input.choices, opts, input.prefilter) : input.choices;
        var res = null, evals = 0, starts = input.starts || O.startsFor(choices, opts);
        for (var i = 0; i < starts.length; i++) {
            var r = yield* walk(ctx, input.start, choices, opts, starts[i]);
            evals += r.evals;
            if (!res || r.score > res.score) res = r;
        }
        res.evals = evals;
        keepWhatDoesNotMatter(ctx, res, input.start, opts, choices);
        tpOnlyOut(ctx, res, choices, opts);
        res.best.hits = O.hits(ctx, res.pieces, opts);
        res.start.hits = O.hits(ctx, input.start, opts);
        // an engaged set's round before and after, the real time worked out whatever the objective
        if (ctx.mode === "engaged") { res.best.round = O.round(ctx, res.pieces, opts); res.start.round = O.round(ctx, input.start, opts); }
        return {pieces: res.pieces, best: res.best, start: res.start, evals: res.evals, score: res.score, gains: O.gains(ctx, res, choices, opts)};
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
            prog.phase = "shortlist";
            var list = yield* shortlist(ctx, st, slots, choices, opts, opts.top || 8, opts.extra || 4);
            prog.phase = "pairs";
            var more = yield* pairs(ctx, st, slots, list, opts);
            if (!more) break;
        }
        return {pieces: st.best, score: st.score, best: O.value(ctx, st.best, opts), start: O.value(ctx, start, opts), evals: st.evals};
    }
    O.optimize = function (ctx, start, choices, opts) { return drain(optimizeGen(ctx, start, choices, opts)); };
    // Each slot's `keep` best pieces as single swaps from `start` (pieces flagged keep always stay):
    // a first sort before searching hundreds of pieces a slot (every item of the game)
    function* prefilterGen(ctx, start, choices, opts, keep) {
        var out = {}, slots = Object.keys(choices);
        if (opts.prog) opts.prog.phase = "prefilter";
        for (var s = 0; s < slots.length; s++) {
            var slot = slots[s], rated = [];
            for (var i = 0; i < choices[slot].length; i++) {
                var piece = choices[slot][i];
                rated.push({piece: piece, v: score(ctx, put(Object.assign({}, start), slot, piece), opts)});
                if (opts.prog) opts.prog.evals++;
                yield;
            }
            rated.sort(function (a, b) { return b.v - a.v; });
            out[slot] = rated.filter(function (x, n) { return n < keep || x.piece.keep; }).map(function (x) { return x.piece; });
        }
        return out;
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
            out[slot] = {top: best("v", top), raw: best("raw", extra), dt: best("dt", extra, true)};
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

});
